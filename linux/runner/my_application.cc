#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#include <handy.h>
#include <X11/Xlib.h>
#include <gio/gio.h>

#include "flutter/generated_plugin_registrant.h"

#ifdef NDEBUG
#define APPLICATION_FLAGS \
  G_APPLICATION_HANDLES_COMMAND_LINE | G_APPLICATION_HANDLES_OPEN
#else
#define APPLICATION_FLAGS G_APPLICATION_NON_UNIQUE
#endif

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// ------------------------------------------------------
// Overlay / HeaderBar helpers (copiados y adaptados)
// ------------------------------------------------------
// Forward-declare HeaderBars struct so we can keep a global pointer here
typedef struct HeaderBars HeaderBars;
static HeaderBars* g_header_bars = nullptr;

typedef struct HeaderBars {
  GtkHeaderBar* left;
  GtkHeaderBar* right;
  GtkWindow* window;
  /* generation and pending theme to coordinate size-allocate notifications */
  int pending_generation;
  gchar* pending_theme_name;
  int left_seen_gen;
  int right_seen_gen;
  /* last sizes we sent to Dart to avoid duplicate notifications */
  int last_sent_left;
  int last_sent_right;
} HeaderBars;

// GSettings handle for monitoring gtk theme changes
static GSettings* g_gsettings_global = NULL;
// Method channel to communicate with Dart (send sizes, theme/window events)
static FlMethodChannel* g_border_channel = NULL;
// Last theme name reported by GtkSettings notify; prefer this over GSettings when present
static gchar* g_current_theme_name = NULL;

/* Global generation counter incremented on each theme change */
static gint g_theme_generation = 0;

/* forward-declare size-allocate callback so it can be connected before its definition */
static void on_header_size_allocate(GtkWidget* widget, GtkAllocation* allocation, gpointer user_data);

static GtkWidget* create_custom_header_bar(GtkWindow* window) {
  GtkWidget* header_bar = gtk_header_bar_new();
  gtk_widget_show(header_bar);

  gtk_header_bar_set_show_close_button(GTK_HEADER_BAR(header_bar), TRUE);

  GtkWidget* empty_box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
  gtk_widget_show(empty_box);
  gtk_header_bar_set_custom_title(GTK_HEADER_BAR(header_bar), empty_box);

  return header_bar;
}

static void set_overlays_visible(gboolean visible) __attribute__((unused));
static void set_overlays_visible(gboolean visible) {
  if (!g_header_bars) return;
  if (g_header_bars->left)
    gtk_widget_set_visible(GTK_WIDGET(g_header_bars->left), visible);
  if (g_header_bars->right)
    gtk_widget_set_visible(GTK_WIDGET(g_header_bars->right), visible);
}

static void apply_custom_css(GtkWidget* window, GtkWidget* left_header, GtkWidget* right_header) {
  const char* css_data =
      "headerbar { background: transparent; border: 0; min-height:46px;box-shadow:none; }"
      "headerbar.left.top { padding-right:0; }"
      "window { background: transparent;}"
      "headerbar.right.top { padding-left:0; }"
      ".fake-titlebar { background: transparent; border: 0; min-height:0px; opacity:0; }"
      "menubar{opacity:0;}";

  GtkCssProvider* provider = gtk_css_provider_new();
  gtk_css_provider_load_from_data(provider, css_data, -1, NULL);

  GdkScreen* screen = gdk_screen_get_default();
  if (screen) {
    gtk_style_context_add_provider_for_screen(screen, GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
  } else {
    GtkStyleContext* context;
    context = gtk_widget_get_style_context(window);
    gtk_style_context_add_provider(context, GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);

    context = gtk_widget_get_style_context(left_header);
    gtk_style_context_add_provider(context, GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    gtk_style_context_add_class(context, "left");
    gtk_style_context_add_class(context, "top");

    context = gtk_widget_get_style_context(right_header);
    gtk_style_context_add_provider(context, GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    gtk_style_context_add_class(context, "right");
    gtk_style_context_add_class(context, "top");
  }

  g_object_unref(provider);
}

/* (removed) legacy print_headerbars_sizes helper — size polling now sends sizes directly */

/* Polling helper to wait until GTK finishes reallocating headerbars after theme/layout changes.
 * We poll allocated sizes every 30ms up to max_attempts. Once sizes are stable for
 * stable_required consecutive polls or max_attempts reached, the poll will send sizes
 * directly to Flutter via the MethodChannel.
 */
typedef struct _SizePoll {
  HeaderBars* bars;
  gint last_lw;
  gint last_rw;
  int stable_count;
  int attempts;
  int max_attempts;
  int stable_required;
  gchar* theme_name; /* snapshot of theme name when poll started */
} SizePoll;

static gboolean size_poll_callback(gpointer user_data) {
  SizePoll* p = (SizePoll*)user_data;
  if (!p || !p->bars) {
    if (p) {
      if (p->theme_name) g_free(p->theme_name);
      g_free(p);
    }
    return G_SOURCE_REMOVE;
  }

  GtkWidget* l = GTK_WIDGET(p->bars->left);
  GtkWidget* r = GTK_WIDGET(p->bars->right);
  gint lw = l ? gtk_widget_get_allocated_width(l) : 0;
  gint rw = r ? gtk_widget_get_allocated_width(r) : 0;

  if (lw == p->last_lw && rw == p->last_rw) {
    p->stable_count++;
  } else {
    p->stable_count = 0;
    p->last_lw = lw;
    p->last_rw = rw;
  }
  p->attempts++;

  if (p->stable_count >= p->stable_required || p->attempts >= p->max_attempts) {
    if (g_border_channel) {
      FlValue* map = fl_value_new_map();
      fl_value_set_string_take(map, "left", fl_value_new_int(lw));
      fl_value_set_string_take(map, "right", fl_value_new_int(rw));
      fl_method_channel_invoke_method(g_border_channel, "onHeaderbarSizes", map, NULL, NULL, NULL);
      fl_value_unref(map);

      /* update last-sent so we don't immediately duplicate from size-allocate */
      if (p->bars) {
        p->bars->last_sent_left = lw;
        p->bars->last_sent_right = rw;
      }

      /* Send theme snapshot taken when poll started (if any) */
      if (p->theme_name) {
        FlValue* args = fl_value_new_string(p->theme_name);
        fl_method_channel_invoke_method(g_border_channel, "onThemeChanged", args, NULL, NULL, NULL);
        fl_value_unref(args);
      } else if (g_gsettings_global) {
        gchar* theme_name = g_settings_get_string(g_gsettings_global, "gtk-theme");
        if (theme_name) {
          FlValue* args = fl_value_new_string(theme_name);
          fl_method_channel_invoke_method(g_border_channel, "onThemeChanged", args, NULL, NULL, NULL);
          fl_value_unref(args);
          g_free(theme_name);
        }
      }
    } else {
      g_print("[gtkoverlay] headerbar sizes => left:%d right:%d (no channel)\n", lw, rw);
    }

    if (p->theme_name) g_free(p->theme_name);
    g_free(p);
    return G_SOURCE_REMOVE;
  }

  return G_SOURCE_CONTINUE;
}

static void start_size_poll(HeaderBars* bars) {
  if (!bars) return;
  SizePoll* p = (SizePoll*)g_malloc0(sizeof(SizePoll));
  p->bars = bars;
  p->last_lw = -1;
  p->last_rw = -1;
  p->stable_count = 0;
  p->attempts = 0;
  p->max_attempts = 15; /* ~450ms max */
  p->stable_required = 2; /* require two consecutive equal readings */
  /* capture current theme name snapshot for this poll */
  p->theme_name = NULL;
  if (g_current_theme_name) {
    p->theme_name = g_strdup(g_current_theme_name);
  } else if (g_gsettings_global) {
    gchar* t = g_settings_get_string(g_gsettings_global, "gtk-theme");
    if (t) {
      p->theme_name = g_strdup(t);
      g_free(t);
    }
  } else {
    /* try GtkSettings directly */
    GtkSettings* s = gtk_settings_get_default();
    if (s) {
      gchar* tn = NULL;
      g_object_get(s, "gtk-theme-name", &tn, NULL);
      if (tn) { p->theme_name = g_strdup(tn); g_free(tn); }
    }
  }
  /* poll every 30ms */
  g_timeout_add(30, size_poll_callback, p);
}

// Callback when GSettings gtk-theme changes. Re-apply CSS and print sizes.
static void theme_changed_cb(GSettings* settings, gchar* key, gpointer user_data) {
  (void)settings;
  (void)key;
  HeaderBars* bars = (HeaderBars*)user_data;
  if (!bars) return;
  g_print("[gtkoverlay] theme_changed_cb: theme changed, reapplying CSS\n");
  apply_custom_css(GTK_WIDGET(bars->window), GTK_WIDGET(bars->left), GTK_WIDGET(bars->right));
  /* schedule a poll to get stable sizes after reapplication */
  /* snapshot theme name and mark pending generation on the bars */
  if (bars->pending_theme_name) { g_free(bars->pending_theme_name); bars->pending_theme_name = NULL; }
  if (settings) {
    gchar* theme_name = g_settings_get_string(G_SETTINGS(settings), "gtk-theme");
    if (theme_name) {
      bars->pending_theme_name = g_strdup(theme_name);
      g_free(theme_name);
    }
  }
  bars->pending_generation = ++g_theme_generation;
  bars->left_seen_gen = 0;
  bars->right_seen_gen = 0;
  /* start polling as a fallback in case size-allocate isn't emitted */
  start_size_poll(bars);
}

// Callback when GtkSettings 'gtk-theme-name' property changes. Fired by GTK when the active
// theme is updated; this is usually in sync with widget style updates and is preferred.
static void on_gtk_settings_theme_name_changed(GObject* settings, GParamSpec* pspec, gpointer user_data) {
  (void)pspec;
  HeaderBars* bars = (HeaderBars*)user_data;
  if (!bars) return;
  gchar* theme_name = NULL;
  g_object_get(settings, "gtk-theme-name", &theme_name, NULL);
  if (g_current_theme_name) { g_free(g_current_theme_name); g_current_theme_name = NULL; }
  if (theme_name) {
    g_current_theme_name = g_strdup(theme_name);
    g_print("[gtkoverlay] on_gtk_settings_theme_name_changed: %s\n", g_current_theme_name);
    g_free(theme_name);
  } else {
    g_print("[gtkoverlay] on_gtk_settings_theme_name_changed: <null>\n");
  }
  /* snapshot theme into bars and mark pending generation */
  if (bars->pending_theme_name) { g_free(bars->pending_theme_name); bars->pending_theme_name = NULL; }
  if (g_current_theme_name) bars->pending_theme_name = g_strdup(g_current_theme_name);
  bars->pending_generation = ++g_theme_generation;
  bars->left_seen_gen = 0;
  bars->right_seen_gen = 0;
  apply_custom_css(GTK_WIDGET(bars->window), GTK_WIDGET(bars->left), GTK_WIDGET(bars->right));
  /* start polling as a fallback */
  start_size_poll(bars);
}

// ------------------------------------------------------
// Handle gtk-decoration-layout to split decorations left/right
// ------------------------------------------------------
static void on_decoration_layout_changed(GObject* settings, GParamSpec* pspec, gpointer user_data) {
  (void)pspec;
  HeaderBars* bars = (HeaderBars*)user_data;
  if (!bars) return;

  gchar* default_layout = NULL;
  g_object_get(settings, "gtk-decoration-layout", &default_layout, NULL);
  if (!default_layout) {
    g_print("[gtkoverlay] on_decoration_layout_changed called but gtk-decoration-layout is NULL\n");
    return;
  }

  g_print("[gtkoverlay] on_decoration_layout_changed: %s\n", default_layout);

  gchar** parts = g_strsplit(default_layout, ":", 2);

  // left part (before ':')
  if (parts[0] && bars->left) {
    g_print("[gtkoverlay] left layout part: %s\n", parts[0]);
    gtk_header_bar_set_decoration_layout(bars->left, parts[0]);
  }

  // right part (after ':') - gtk expects a leading ':' for right-side layout
  if (parts[1] && bars->right) {
    g_print("[gtkoverlay] right layout part: %s\n", parts[1]);
    gchar* right_layout = g_strdup_printf(":%s", parts[1]);
    gtk_header_bar_set_decoration_layout(bars->right, right_layout);
    g_free(right_layout);
  }

  g_strfreev(parts);
  g_free(default_layout);
  /* schedule a poll to get sizes once GTK has had a chance to re-allocate widgets */
  start_size_poll(bars);
}

// legacy print helper removed — size polling sends sizes directly to Dart

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

#ifdef NDEBUG
  GList* windows = gtk_application_get_windows(GTK_APPLICATION(application));
  if (windows) {
    gtk_window_present(GTK_WINDOW(windows->data));
    return;
  }
#endif

  GtkWindow* window = GTK_WINDOW(hdy_application_window_new());
  gtk_window_set_application(window, GTK_APPLICATION(application));

  GdkGeometry geometry;
  // TODO: find better solution; set default window size based on available space
  geometry.min_width = 800 + 52;  // account for shadow from libhandy
  geometry.min_height = 600 + 52;
  gtk_window_set_geometry_hints(window, nullptr, &geometry, GDK_HINT_MIN_SIZE);
  gtk_window_set_title(GTK_WINDOW(window), "Todo List");

  /* Create a fake titlebar widget so we can position overlays and target it via CSS.
   * Note: HdyWindow does not support gtk_window_set_titlebar(), so we do NOT call it.
   * Instead we will add this widget into the overlay later so CSS can target it.
   */
  GtkWidget* fake_titlebar = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
  gtk_widget_show(fake_titlebar);
  gtk_style_context_add_class(gtk_widget_get_style_context(fake_titlebar), "fake-titlebar");

  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);

  
  /* make the Flutter view background transparent to let our window styling show */
  GdkRGBA background_color;
  gdk_rgba_parse(&background_color, "rgba(0,0,0,0)");
  fl_view_set_background_color(view, &background_color);

  /* Create an overlay and two headerbar overlays (left/right) */
  GtkOverlay* overlay = GTK_OVERLAY(gtk_overlay_new());
  /* add the fake titlebar into the overlay so CSS can target it (HdyWindow does not support set_titlebar) */
  gtk_overlay_add_overlay(overlay, fake_titlebar);
  gtk_widget_set_halign(fake_titlebar, GTK_ALIGN_FILL);
  gtk_widget_set_valign(fake_titlebar, GTK_ALIGN_START);

  GtkWidget* left_header = create_custom_header_bar(window);
  gtk_overlay_add_overlay(overlay, left_header);
  gtk_widget_set_halign(left_header, GTK_ALIGN_START);
  gtk_widget_set_valign(left_header, GTK_ALIGN_START);

  GtkWidget* right_header = create_custom_header_bar(window);
  gtk_overlay_add_overlay(overlay, right_header);
  gtk_widget_set_halign(right_header, GTK_ALIGN_END);
  gtk_widget_set_valign(right_header, GTK_ALIGN_START);

  /* headerbars do not initiate window dragging in this build - native window
    movement is handled by the window manager */

  gtk_container_add(GTK_CONTAINER(overlay), GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(overlay));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));
  
  gtk_window_set_decorated(window, TRUE);
  
  /* Create method channel to communicate with Dart */
  {
    FlEngine* engine = fl_view_get_engine(view);
    FlBinaryMessenger* messenger = fl_engine_get_binary_messenger(engine);
    FlStandardMethodCodec* codec = fl_standard_method_codec_new();
    if (g_border_channel == NULL) {
      g_border_channel = fl_method_channel_new(messenger, "gtkoverlay/border_radius", FL_METHOD_CODEC(codec));

      // Handler: support getBorderRadius and setOverlaysVisible
      fl_method_channel_set_method_call_handler(g_border_channel,
        [](FlMethodChannel* channel, FlMethodCall* call, gpointer user_data) {
          const gchar* name = fl_method_call_get_name(call);
          if (g_strcmp0(name, "getBorderRadius") == 0) {
            // We don't currently extract real border-radius; return a default
            FlValue* ret = fl_value_new_string("no-encontrado");
            fl_method_call_respond_success(call, ret, NULL);
            fl_value_unref(ret);
          } else if (g_strcmp0(name, "setOverlaysVisible") == 0) {
            FlValue* args = fl_method_call_get_args(call);
            gboolean visible = TRUE;
            if (args && fl_value_get_type(args) == FL_VALUE_TYPE_BOOL) {
              visible = fl_value_get_bool(args);
            }
            set_overlays_visible(visible);
            FlValue* ret = fl_value_new_bool(visible);
            fl_method_call_respond_success(call, ret, NULL);
            fl_value_unref(ret);
          } else if (g_strcmp0(name, "getHeaderbarSizes") == 0) {
            // Return current allocated widths for left/right headerbars
            gint lw = 0, rw = 0;
            if (g_header_bars) {
              GtkWidget* l = GTK_WIDGET(g_header_bars->left);
              GtkWidget* r = GTK_WIDGET(g_header_bars->right);
              if (l) lw = gtk_widget_get_allocated_width(l);
              if (r) rw = gtk_widget_get_allocated_width(r);
            }
            FlValue* map = fl_value_new_map();
            fl_value_set_string_take(map, "left", fl_value_new_int(lw));
            fl_value_set_string_take(map, "right", fl_value_new_int(rw));
            fl_method_call_respond_success(call, map, NULL);
            fl_value_unref(map);
          } else {
            fl_method_call_respond_not_implemented(call, NULL);
          }
        },
        NULL, NULL);
    }
    g_object_unref(codec);
  }
  gtk_widget_show(GTK_WIDGET(view));
  gtk_widget_show(GTK_WIDGET(overlay));
  gtk_widget_grab_focus(GTK_WIDGET(view));

  /* Keep a reference so other code can show/hide overlays */
  HeaderBars* bars = g_new0(HeaderBars, 1);
  bars->left = GTK_HEADER_BAR(left_header);
  bars->right = GTK_HEADER_BAR(right_header);
  bars->window = window;
  bars->pending_generation = 0;
  bars->pending_theme_name = NULL;
  bars->left_seen_gen = 0;
  bars->right_seen_gen = 0;
  bars->last_sent_left = -1;
  bars->last_sent_right = -1;
  g_header_bars = bars;

  /* connect size-allocate so we can detect when allocations complete for both headerbars */
  g_signal_connect(GTK_WIDGET(bars->left), "size-allocate", G_CALLBACK(on_header_size_allocate), bars);
  g_signal_connect(GTK_WIDGET(bars->right), "size-allocate", G_CALLBACK(on_header_size_allocate), bars);

  /* Connect settings notify so we follow the system decoration layout */
  GtkSettings* settings = gtk_settings_get_default();
  if (settings) {
    g_signal_connect(settings, "notify::gtk-decoration-layout",
                     G_CALLBACK(on_decoration_layout_changed),
                     bars);
    /* Also listen for theme-name changes via GtkSettings (preferred) */
    g_signal_connect(settings, "notify::gtk-theme-name",
                     G_CALLBACK(on_gtk_settings_theme_name_changed),
                     bars);
    /* Call once to initialize */
    on_decoration_layout_changed(G_OBJECT(settings), NULL, bars);
    /* Initialize cached gtk-theme-name if available */
    on_gtk_settings_theme_name_changed(G_OBJECT(settings), NULL, bars);
  }

  /* Monitor global GTK theme changes via GSettings and reapply CSS when theme changes */
  g_gsettings_global = g_settings_new("org.gnome.desktop.interface");
  if (g_gsettings_global) {
    g_signal_connect(g_gsettings_global, "changed::gtk-theme", G_CALLBACK(theme_changed_cb), bars);
  }

  /* Apply our lightweight CSS to ensure transparent titlebar and padding */
  apply_custom_css(GTK_WIDGET(window), left_header, right_header);
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

#ifdef NDEBUG
// Implements GApplication::command_line.
static gint my_application_command_line(GApplication* application,
                                        GApplicationCommandLine* command_line) {
  gchar** arguments =
      g_application_command_line_get_arguments(command_line, nullptr);
  gint exit_status = 0;
  my_application_local_command_line(application, &arguments, &exit_status);
  return exit_status;
}
#endif

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  if (g_gsettings_global) { g_clear_object(&g_gsettings_global); }
  if (g_border_channel) { g_object_unref(g_border_channel); g_border_channel = NULL; }
  if (g_current_theme_name) { g_free(g_current_theme_name); g_current_theme_name = NULL; }
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
#ifdef NDEBUG
  G_APPLICATION_CLASS(klass)->command_line = my_application_command_line;
#else
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
#endif
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     APPLICATION_FLAGS, nullptr));
}


/* send_sizes_and_theme_for_generation removed: replaced by per-generation size-allocate coordination */

static void on_header_size_allocate(GtkWidget* widget, GtkAllocation* allocation, gpointer user_data) {
  (void)allocation;
  HeaderBars* bars = (HeaderBars*)user_data;
  if (!bars) return;

  /* Read current allocated widths for both headerbars */
  GtkWidget* l = GTK_WIDGET(bars->left);
  GtkWidget* r = GTK_WIDGET(bars->right);
  gint lw = l ? gtk_widget_get_allocated_width(l) : 0;
  gint rw = r ? gtk_widget_get_allocated_width(r) : 0;

  /* If sizes did not change since last send, do nothing */
  if (bars->last_sent_left == lw && bars->last_sent_right == rw) {
    return;
  }

  /* Update last-sent immediately to avoid duplicate notifications during rapid events */
  bars->last_sent_left = lw;
  bars->last_sent_right = rw;

  g_print("[gtkoverlay] on_header_size_allocate: size changed left=%d right=%d\n", lw, rw);

  if (g_border_channel) {
    FlValue* map = fl_value_new_map();
    fl_value_set_string_take(map, "left", fl_value_new_int(lw));
    fl_value_set_string_take(map, "right", fl_value_new_int(rw));
    fl_method_channel_invoke_method(g_border_channel, "onHeaderbarSizes", map, NULL, NULL, NULL);
    fl_value_unref(map);
  } else {
    g_print("[gtkoverlay] headerbar sizes => left:%d right:%d (no channel)\n", lw, rw);
  }
}