#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#include <gdk/gdk.h>

#include "flutter/generated_plugin_registrant.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <errno.h>
 
#include <gio/gio.h>

// Globals for theme polling/notification
static GSettings* g_gsettings_global = NULL;
static char* g_last_theme = NULL;
// forward declarations
static char* get_border_radius_value(void);
static FlMethodChannel* g_border_channel = NULL;
// forward-declare HeaderBars struct so we can keep a global pointer here
struct HeaderBars;
// Keep a pointer to the HeaderBars so we can show/hide overlays from Dart
static struct HeaderBars* g_header_bars = NULL;
// forward-declare helpers defined later so they can be used above
static int is_dir(const char* path);
static void add_path(char*** arr, size_t* n, const char* path);

static gboolean theme_poll_cb(gpointer user_data) {
    (void)user_data;
    if (!g_gsettings_global) return G_SOURCE_CONTINUE;
    gchar* cur = g_settings_get_string(g_gsettings_global, "gtk-theme");
    if (!cur) return G_SOURCE_CONTINUE;
    if (!g_last_theme || g_strcmp0(g_last_theme, cur) != 0) {
        // theme changed
        if (g_last_theme) g_free(g_last_theme);
        g_last_theme = g_strdup(cur);
        char* val = get_border_radius_value();
        if (val) {
            FlValue* args = fl_value_new_string(val);
            if (g_border_channel) {
                fl_method_channel_invoke_method(g_border_channel, "onThemeChanged", args, NULL, NULL, NULL);
            }
            fl_value_unref(args);
            free(val);
        }
    }
    g_free(cur);** (flutter_application_1:64413): ERROR **: 17:43:49.516: gtk_window_set_titlebar() is not supported for HdyWindow
Error waiting for a debug connection: The log reader stopped unexpectedly, or never started.
Error launching application on Linux.
    return G_SOURCE_CONTINUE;
}
// ------------------------------------------------------
// Helper functions to extract `border-radius` from GTK theme CSS
// ------------------------------------------------------
// Scan a directory tree under `base` and add any .css files inside
// directories named gtk-3.0 or gtk-4.0 (non-recursive inside those dirs).
static void scan_gtk_dirs_under(const char* base, char*** files, size_t* n) {
    DIR* d = opendir(base);
    if (!d) return;
    struct dirent* ent;
    while ((ent = readdir(d)) != NULL) {
        if (ent->d_type != DT_DIR) continue;
        if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) continue;
        // look for gtk-3.0 or gtk-4.0 subdirs
        char path[4096];
        snprintf(path, sizeof(path), "%s/%s/gtk-3.0", base, ent->d_name);
        if (is_dir(path)) {
            DIR* dd = opendir(path);
            if (dd) {
                struct dirent* e2;
                while ((e2 = readdir(dd)) != NULL) {
                    if (e2->d_type == DT_REG) {
                        const char* s = e2->d_name;
                        size_t L = strlen(s);
                        if (L > 4 && strcmp(s + L - 4, ".css") == 0) {
                            char fpath[4096];
                            snprintf(fpath, sizeof(fpath), "%s/%s", path, s);
                            add_path(files, n, fpath);
                        }
                    }
                }
                closedir(dd);
            }
        }
        snprintf(path, sizeof(path), "%s/%s/gtk-4.0", base, ent->d_name);
        if (is_dir(path)) {
            DIR* dd = opendir(path);
            if (dd) {
                struct dirent* e2;
                while ((e2 = readdir(dd)) != NULL) {
                    if (e2->d_type == DT_REG) {
                        const char* s = e2->d_name;
                        size_t L = strlen(s);
                        if (L > 4 && strcmp(s + L - 4, ".css") == 0) {
                            char fpath[4096];
                            snprintf(fpath, sizeof(fpath), "%s/%s", path, s);
                            add_path(files, n, fpath);
                        }
                    }
                }
                closedir(dd);
            }
        }
    }
    closedir(d);
}

static int is_dir(const char* path) {
    struct stat st;
    if (stat(path, &st) != 0) return 0;
    return S_ISDIR(st.st_mode);
}

static void add_path(char*** arr, size_t* n, const char* path) {
    char** tmp = (char**)realloc(*arr, (*n + 1) * sizeof(char*));
    if (!tmp) return;
    *arr = tmp;
    (*arr)[*n] = strdup(path);
    (*n)++;
}

static void scan_recursive(const char* base, char*** files, size_t* n) {
    DIR* d = opendir(base);
    if (!d) return;
    struct dirent* ent;
    while ((ent = readdir(d)) != NULL) {
        if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) continue;
        char path[4096];
        snprintf(path, sizeof(path), "%s/%s", base, ent->d_name);
        if (ent->d_type == DT_DIR) {
            scan_recursive(path, files, n);
        } else {
            const char* s = ent->d_name;
            size_t L = strlen(s);
            if (L > 4 && strcmp(s + L - 4, ".css") == 0) {
                add_path(files, n, path);
            }
        }
    }
    closedir(d);
}

static char* read_file_all(const char* path) {
    FILE* f = fopen(path, "rb");
    if (!f) return NULL;
    if (fseek(f, 0, SEEK_END) != 0) { fclose(f); return NULL; }
    long sz = ftell(f);
    if (sz < 0) { fclose(f); return NULL; }
    rewind(f);
    char* buf = (char*)malloc(sz + 1);
    if (!buf) { fclose(f); return NULL; }
    size_t r = fread(buf, 1, sz, f);
    buf[r] = '\0';
    fclose(f);
    return buf;
}

static char* extract_br_from_buffer(const char* buf, int prefer_decoration) {
    const char* p = buf;
    while ((p = strstr(p, "border-radius")) != NULL) {
        const char* colon = strchr(p, ':');
        if (!colon) { p += 12; continue; }
        const char* semi = strchr(colon, ';');
        if (!semi) { p += 12; continue; }
        const char* vstart = colon + 1;
        while (*vstart == ' ' || *vstart == '\t') vstart++;
        size_t vlen = semi - vstart;
        while (vlen && (vstart[vlen-1] == ' ' || vstart[vlen-1] == '\t')) vlen--;
        const char* sel_end = p;
        const char* sel_start = sel_end;
        while (sel_start > buf && *(sel_start-1) != '}') sel_start--;
        (void)sel_start; // sel_start used for decoration detection; avoid unused-var warning
        int has_dec = 0;
        if (prefer_decoration) {
            const char* q = sel_start;
            while (q < sel_end) {
                if (strncmp(q, "decoration", 10) == 0) { has_dec = 1; break; }
                q++;
            }
            if (!has_dec) { p = semi+1; continue; }
        }
        char* res = (char*)malloc(vlen + 1);
        if (!res) return NULL;
        memcpy(res, vstart, vlen);
        res[vlen] = '\0';
        return res;
    }
    return NULL;
}

static char* get_border_radius_value(void) {
    // Use GSettings instead of spawning `gsettings` process
    char* theme = NULL;
    GSettings* s = g_settings_new("org.gnome.desktop.interface");
    if (s) {
        gchar* gtheme = g_settings_get_string(s, "gtk-theme");
        if (gtheme) {
            theme = strdup(gtheme);
            g_free(gtheme);
        }
        g_clear_object(&s);
    }

    char** files = NULL;
    size_t nfiles = 0;
    const char* home = getenv("HOME");
    if (!home) home = "/root";
    if (theme) {
        char cand[4096];
        snprintf(cand, sizeof(cand), "%s/.themes/%s/gtk-3.0", home, theme);
        if (is_dir(cand)) scan_recursive(cand, &files, &nfiles);
        snprintf(cand, sizeof(cand), "/usr/share/themes/%s/gtk-3.0", theme);
        if (is_dir(cand)) scan_recursive(cand, &files, &nfiles);
        snprintf(cand, sizeof(cand), "%s/.themes/%s", home, theme);
        if (is_dir(cand)) scan_recursive(cand, &files, &nfiles);
        snprintf(cand, sizeof(cand), "/usr/share/themes/%s", theme);
        if (is_dir(cand)) scan_recursive(cand, &files, &nfiles);
    }
    if (nfiles == 0) scan_gtk_dirs_under("/usr/share/themes", &files, &nfiles);
    if (nfiles == 0) {
        if (theme) free(theme);
        return strdup("no-archivos");
    }
    // Limit: skip very large files (>1MB) to avoid heavy reads
    for (size_t i = 0; i < nfiles; ++i) {
        struct stat st;
        if (stat(files[i], &st) != 0) continue;
        if (st.st_size > (1<<20)) continue; // skip >1MB
        char* buf = read_file_all(files[i]);
        if (!buf) continue;
        char* val = extract_br_from_buffer(buf, 1);
        free(buf);
        if (val) {
            // free file list
            for (size_t j = 0; j < nfiles; ++j) free(files[j]);
            free(files);
            if (theme) free(theme);
            return val;
        }
    }
    for (size_t i = 0; i < nfiles; ++i) {
        struct stat st;
        if (stat(files[i], &st) != 0) continue;
        if (st.st_size > (1<<20)) continue;
        char* buf = read_file_all(files[i]);
        if (!buf) continue;
        char* val = extract_br_from_buffer(buf, 0);
        free(buf);
        if (val) {
            for (size_t j = 0; j < nfiles; ++j) free(files[j]);
            free(files);
            if (theme) free(theme);
            return val;
        }
    }
    for (size_t j = 0; j < nfiles; ++j) free(files[j]);
    free(files);
    if (theme) free(theme);
    return strdup("no-encontrado");
}

struct _MyApplication {
    GtkApplication parent_instance;
    char** dart_entrypoint_arguments;
    };

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// ------------------------------------------------------
// Callback para mostrar la ventana en el primer frame
// ------------------------------------------------------
static void first_frame_cb(MyApplication* self, FlView* view) {
    gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// ------------------------------------------------------
// Estructura para mantener referencias a ambos HeaderBars
// ------------------------------------------------------
typedef struct HeaderBars {
    GtkHeaderBar* left;
    GtkHeaderBar* right;
    GtkWindow* window;
} HeaderBars;

// ------------------------------------------------------
// Callback cuando cambia la propiedad gtk-decoration-layout
// ------------------------------------------------------
static void on_decoration_layout_changed(GObject* settings, GParamSpec* pspec, gpointer user_data) {
    HeaderBars* bars = (HeaderBars*)user_data;

    gchar* default_layout = NULL;
    g_object_get(settings, "gtk-decoration-layout", &default_layout, NULL);
    if (!default_layout) return;

    gchar** parts = g_strsplit(default_layout, ":", 2);

    // Headerbar izquierdo normal
    if (parts[0])
        gtk_header_bar_set_decoration_layout(bars->left, parts[0]);

    // Headerbar derecho siempre con ":" delante
    if (parts[1]) {
        gchar* right_layout = g_strdup_printf(":%s", parts[1]);
        gtk_header_bar_set_decoration_layout(bars->right, right_layout);
        g_free(right_layout);
    }

    g_strfreev(parts);
    g_free(default_layout);
}

// ------------------------------------------------------
// Crear HeaderBar personalizado sin título
// ------------------------------------------------------
static GtkWidget* create_custom_header_bar(GtkWindow* window) {
    GtkWidget* header_bar = gtk_header_bar_new();
    gtk_widget_show(header_bar);

    gtk_header_bar_set_show_close_button(GTK_HEADER_BAR(header_bar), TRUE);

    GtkWidget* empty_box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_show(empty_box);
    gtk_header_bar_set_custom_title(GTK_HEADER_BAR(header_bar), empty_box);

    gtk_widget_add_events(header_bar, GDK_BUTTON_PRESS_MASK);

    return header_bar;
}

// ------------------------------------------------------
// Callback para arrastrar la ventana
// ------------------------------------------------------
static gboolean on_header_button_press(GtkWidget* widget, GdkEventButton* event, gpointer user_data) {
    if (event->type == GDK_BUTTON_PRESS && event->button == 1) {
        GtkWindow* window = GTK_WINDOW(user_data);
        gtk_window_begin_move_drag(window,
                                   event->button,
                                   event->x_root,
                                   event->y_root,
                                   event->time);
        return TRUE;
    }
    return FALSE;
}

// ------------------------------------------------------
// Window state event handler: notify Dart when window is maximized/fullscreen/tiled/normal
// ------------------------------------------------------
static gboolean on_window_state_event(GtkWidget* widget, GdkEventWindowState* event, gpointer user_data) {
    (void)user_data;
    const char* state_str = "normal";
    GdkWindowState state = event->new_window_state;
    if (state & GDK_WINDOW_STATE_MAXIMIZED) state_str = "maximized";
    else if (state & GDK_WINDOW_STATE_FULLSCREEN) state_str = "fullscreen";
    else if (state & GDK_WINDOW_STATE_TILED) state_str = "tiled";

    FlValue* args = fl_value_new_string(state_str);
    if (g_border_channel) {
        fl_method_channel_invoke_method(g_border_channel, "onWindowStateChanged", args, NULL, NULL, NULL);
    }
    fl_value_unref(args);
    return FALSE; /* propagate */
}

// Show or hide headerbar overlays created earlier
static void set_overlays_visible(gboolean visible) {
    if (!g_header_bars) return;
    if (g_header_bars->left)
        gtk_widget_set_visible(GTK_WIDGET(g_header_bars->left), visible);
    if (g_header_bars->right)
        gtk_widget_set_visible(GTK_WIDGET(g_header_bars->right), visible);
}

/* system decoration toggle removed — reverted to previous behaviour */

// ------------------------------------------------------
// Aplicar CSS a la ventana y headerbars
// ------------------------------------------------------
static void apply_custom_css(GtkWidget* window, GtkWidget* left_header, GtkWidget* right_header) {
    /*
     * Use a simple, explicit class selector for the fake titlebar and
     * register the provider for the whole screen so rules are applied
     * consistently across the widget tree.
     */
    const char* css_data =
        
        // "headerbar { background: transparent; border: 0; min-height:46px;box-shadow:none; }"
        // "headerbar.left.top { padding-right:0; }"
        // "window { background: transparent;}"
        "headerbar.right.top { padding-left:0; }"
        // ".fake-titlebar { background: transparent; border: 0; min-height:0px; opacity:0; }"
        "menubar{opacity:0;}";

    GtkCssProvider* provider = gtk_css_provider_new();
    gtk_css_provider_load_from_data(provider, css_data, -1, NULL);

    /* Prefer registering the provider for the entire screen (GTK3).
     * If that fails (unlikely), fall back to setting it on the window
     * and headerbar contexts individually.
     */
    GdkScreen* screen = gdk_screen_get_default();
    if (screen) {
        gtk_style_context_add_provider_for_screen(screen, GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    } else {
        /* Fallback: attach to the window and headerbars (keeps previous behaviour)
         * This branch should rarely run on GTK3 setups where screen is available.
         */
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

// ------------------------------------------------------
// Activación de la aplicación
// ------------------------------------------------------
static void my_application_activate(GApplication* application) {
    MyApplication* self = MY_APPLICATION(application);

    GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
    gtk_window_set_title(window, "");
    gtk_window_set_decorated(window, TRUE);
    gtk_window_set_default_size(window, 1280, 720);

    GtkWidget* fake_titlebar = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_show(fake_titlebar);
    /* Add an explicit class so CSS can target the titlebar reliably */
    gtk_style_context_add_class(gtk_widget_get_style_context(fake_titlebar), "fake-titlebar");
    gtk_window_set_titlebar(window, fake_titlebar);

    g_autoptr(FlDartProject) project = fl_dart_project_new();
    fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

    FlView* view = fl_view_new(project);
    GdkRGBA background_color;
    gdk_rgba_parse(&background_color, "rgba(0,0,0,0)");
    fl_view_set_background_color(view, &background_color);
    gtk_widget_show(GTK_WIDGET(view));

    GtkOverlay* overlay = GTK_OVERLAY(gtk_overlay_new());
    gtk_widget_show(GTK_WIDGET(overlay));

    GtkWidget* left_header = create_custom_header_bar(window);
    gtk_overlay_add_overlay(overlay, left_header);
    gtk_widget_set_halign(left_header, GTK_ALIGN_START);
    gtk_widget_set_valign(left_header, GTK_ALIGN_START);

    GtkWidget* right_header = create_custom_header_bar(window);
    gtk_overlay_add_overlay(overlay, right_header);
    gtk_widget_set_halign(right_header, GTK_ALIGN_END);
    gtk_widget_set_valign(right_header, GTK_ALIGN_START);

    g_signal_connect(left_header, "button-press-event", G_CALLBACK(on_header_button_press), window);
    g_signal_connect(right_header, "button-press-event", G_CALLBACK(on_header_button_press), window);

    gtk_container_add(GTK_CONTAINER(overlay), GTK_WIDGET(view));
    gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(overlay));

    fl_register_plugins(FL_PLUGIN_REGISTRY(view));
    g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb), self);
    gtk_widget_realize(GTK_WIDGET(view));
    gtk_widget_grab_focus(GTK_WIDGET(view));

    /* Monitor window state changes (maximized/fullscreen/tiled) and notify Dart */
    g_signal_connect(window, "window-state-event", G_CALLBACK(on_window_state_event), NULL);

    /* Send initial window state once window is realized */
    GdkWindow* gdk_win = gtk_widget_get_window(GTK_WIDGET(window));
    if (gdk_win && g_border_channel) {
        GdkWindowState st = gdk_window_get_state(gdk_win);
        const char* s = "normal";
        if (st & GDK_WINDOW_STATE_MAXIMIZED) s = "maximized";
        else if (st & GDK_WINDOW_STATE_FULLSCREEN) s = "fullscreen";
        else if (st & GDK_WINDOW_STATE_TILED) s = "tiled";
        FlValue* args = fl_value_new_string(s);
        fl_method_channel_invoke_method(g_border_channel, "onWindowStateChanged", args, NULL, NULL, NULL);
        fl_value_unref(args);
    }

    // Register a MethodChannel so Dart can request the GTK border-radius
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
                        char* val = get_border_radius_value();
                        FlValue* ret = fl_value_new_string(val ? val : "no-encontrado");
                        fl_method_call_respond_success(call, ret, NULL);
                        fl_value_unref(ret);
                        if (val) free(val);
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
                    
                    } else {
                        fl_method_call_respond_not_implemented(call, NULL);
                    }
                },
                NULL, NULL);
        }

        g_object_unref(codec);
        // keep g_border_channel alive
    }

    // Initialize GSettings global and start poller to detect theme changes
    g_gsettings_global = g_settings_new("org.gnome.desktop.interface");
    if (g_gsettings_global) {
        gchar* initial = g_settings_get_string(g_gsettings_global, "gtk-theme");
        if (initial) {
            g_last_theme = g_strdup(initial);
            g_free(initial);
        }
        // start a 2s poller as a fallback (lower CPU pressure)
        g_timeout_add_seconds(2, theme_poll_cb, NULL);
    }

    HeaderBars* bars = g_new0(HeaderBars, 1);
    bars->left = GTK_HEADER_BAR(left_header);
    bars->right = GTK_HEADER_BAR(right_header);
    bars->window = window;
    /* keep global reference so Dart can show/hide overlays */
    g_header_bars = bars;

    GtkSettings* settings = gtk_settings_get_default();
    g_signal_connect(settings, "notify::gtk-decoration-layout",
                     G_CALLBACK(on_decoration_layout_changed),
                     bars);
    on_decoration_layout_changed(G_OBJECT(settings), NULL, bars);

    // Aplicar CSS personalizado
    apply_custom_css(GTK_WIDGET(window), left_header, right_header);

    // Extraer y mostrar el border-radius del tema GTK actual
    char* br = get_border_radius_value();
    if (br) {
        g_print("GTK border-radius: %s\n", br);
        free(br);
    }
}

// ------------------------------------------------------
// Local command line
// ------------------------------------------------------
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
    MyApplication* self = MY_APPLICATION(application);
    self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

    g_autoptr(GError) error = NULL;
    if (!g_application_register(application, NULL, &error)) {
        g_warning("Failed to register: %s", error->message);
        *exit_status = 1;
        return TRUE;
    }

    g_application_activate(application);
    *exit_status = 0;
    return TRUE;
}

// ------------------------------------------------------
// Startup / Shutdown / Dispose
// ------------------------------------------------------
static void my_application_startup(GApplication* application) {
    G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

static void my_application_shutdown(GApplication* application) {
    // Cleanup globals used for theme polling
    if (g_last_theme) { g_free(g_last_theme); g_last_theme = NULL; }
    if (g_gsettings_global) { g_clear_object(&g_gsettings_global); }
    if (g_border_channel) { g_object_unref(g_border_channel); g_border_channel = NULL; }
    if (g_header_bars) { g_free(g_header_bars); g_header_bars = NULL; }

    G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

static void my_application_dispose(GObject* object) {
    MyApplication* self = MY_APPLICATION(object);
    g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
    G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

// ------------------------------------------------------
// Class init / instance init
// ------------------------------------------------------
static void my_application_class_init(MyApplicationClass* klass) {
    G_APPLICATION_CLASS(klass)->activate = my_application_activate;
    G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
    G_APPLICATION_CLASS(klass)->startup = my_application_startup;
    G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
    G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

// ------------------------------------------------------
// Constructor
// ------------------------------------------------------
MyApplication* my_application_new() {
    g_set_prgname(APPLICATION_ID);

    return MY_APPLICATION(g_object_new(
        my_application_get_type(),
        "application-id", APPLICATION_ID,
        "flags", G_APPLICATION_NON_UNIQUE,
        NULL));
}
