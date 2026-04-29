import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:gtk/gtk.dart';
import 'package:gtk_theme_fl/gtk_theme_fl.dart';
import 'package:provider/provider.dart';
import 'package:sharing_option/widgets/platform_themed_scaffold.dart';
import 'constants/current_platform.dart';
import 'native_functions/headerbar_sizes.dart';
import 'package:sharing_option/pages/config.dart';
import 'package:window_manager/window_manager.dart';
import 'window_captions.dart';
import 'pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isWindows || isMacOS || isLinux) {
    await windowManager.ensureInitialized();

    WindowOptions(
      minimumSize: const Size(500, 450),
      size: const Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
    );
  }

  runApp(const MyApp());

  if (isMacOS) {
    await Window.initialize();
    Window.enableFullSizeContentView();
    Window.hideTitle();
    Window.makeTitlebarTransparent();
    appWindow.show();
  }

  if (isWindows || isLinux) {
    doWhenWindowReady(() {
      final win = appWindow;
      const initialSize = Size(800, 600);
      win.minSize = const Size(500, 450);
      win.title = 'Custom window with Flutter';
      win.size = Size(initialSize.width - 1, initialSize.height);
      win.size = initialSize;
    });
  }
  if (isLinux){
    // Ensure GTK is initialized before running the app
    HeaderbarSizes();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  GtkThemeData themeDatas = GtkThemeData(name: 'Colloid-Purple-Light');
  Color gtkThemeRefresh = Colors.black;
  @override
  void initState() {
    super.initState();

    initPlatformState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // if (isMacOS) {
    //   Window.makeTitlebarTransparent();
    //   Window.hideTitle();
    //   Window.enableFullSizeContentView();
    //   await Window.initialize();
    // }

    if (isLinux) {
      themeDatas = await GtkThemeData.initialize();
      setState(() {});
    }
  }

  @override
  void onWindowEnterFullScreen() {
    if (isMacOS) {
      // Window.removeToolbar();
      // Ensure the titlebar is transparent when entering fullscreen
      // Window.makeTitlebarTransparent();
      // Window.hideTitle();
    }
  }

  @override
  void onWindowLeaveFullScreen() {
    if (isMacOS) {
      // Window.addToolbar();
    }
  }

  @override
  Widget build(BuildContext context) {
    double grayscale =
        Color(themeDatas.theme_bg_color).r +
        Color(themeDatas.theme_bg_color).g +
        Color(themeDatas.theme_bg_color).b;
    // Avoid calling async initializers or setState inside build().
    // `initPlatformState` is called from initState/didChangeDependencies.
    // Update local cached value without forcing another build here.
    gtkThemeRefresh = Theme.of(context).cardColor;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GtkSettings()),
        ChangeNotifierProvider(create: (_) => HeaderbarSizes()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        themeMode: isLinux
            ? grayscale <= 1.5
                  ? ThemeMode.dark
                  : ThemeMode.light
            : ThemeMode.system,
        home: const Structure(),
      ),
    );
  }
}

class Structure extends StatefulWidget {
  const Structure({super.key});
  @override
  State<Structure> createState() => _StructureState();
}

class _StructureState extends State<Structure> {
  String _borderRadius = 'cargando...';
  double _borderRadiusValue = 0.0;
  bool _isWindowed = true;
  late Color baseColor;
  late Color bgColor;
  // true when window is not maximized/tiled/fullscreen
  // header widths are provided by HeaderbarSizes provider (updated from native)
  // overlays visibility is controlled natively; don't keep an unused local field

  @override
  void initState() {
    super.initState();
    baseColor = const Color.fromARGB(255, 21, 15, 31).withAlpha(0);
    bgColor = const Color.fromARGB(255, 32, 22, 48).withAlpha(0);
    // Channel to receive visibility events from native macOS code

    _setOverlaysVisible(true);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListen);
    _pageController = PageController(initialPage: 0);
    // initially expanded height is full
    _expandedHeight = _moreHeight;
    initPlatformState();
    // Listen for native-initiated updates when the GTK theme changes
    if (isLinux) {
      platform.setMethodCallHandler((call) async {
        if (call.method == 'onThemeChanged') {
          // Theme changed on native side: re-initialize GTK theme data and refresh border radius
          if (isLinux) {
            await initPlatformState();
            await _fetchBorderRadius();
            // Rely on native to report stable headerbar sizes (onHeaderbarSizes), no fallback request here.
          }
        } else if (call.method == 'onWindowStateChanged') {
          final String? state = call.arguments as String?;
          final bool nowWindowed = (state == null || state == 'normal');
          if (nowWindowed != _isWindowed) {
            if (!mounted) return null;
            setState(() {
              _isWindowed = nowWindowed;
              // apply radius only when windowed
              _borderRadiusValue = _isWindowed
                  ? _parseBorderRadius(_borderRadius)
                  : 0.0;
            });
          }
        } else if (call.method == 'onHeaderbarSizes') {
          final Map<dynamic, dynamic>? args =
              call.arguments as Map<dynamic, dynamic>?;
          final int left = (args != null && args['left'] != null)
              ? (args['left'] as int)
              : 0;
          final int right = (args != null && args['right'] != null)
              ? (args['right'] as int)
              : 0;
          if (!mounted) return null;
          // update provider so any widget listening will rebuild
          final headerNotifier = Provider.of<HeaderbarSizes>(
            context,
            listen: false,
          );
          headerNotifier.setSizes(left.toDouble(), right.toDouble());
          print(
            'Received headerbar sizes from native: left=${left.toDouble()} right=${right.toDouble()}',
          );
        }
        return null;
      });
      _fetchBorderRadius();
    }
  }

  static const platform = MethodChannel('gtkoverlay/border_radius');

  Future<void> _fetchBorderRadius() async {
    try {
      final String? value = await platform.invokeMethod<String>(
        'getBorderRadius',
      );
      final String display = (value == null || value.isEmpty) ? 'vacío' : value;
      if (display != _borderRadius) {
        final double parsed = _parseBorderRadius(display);
        if (!mounted) return;
        setState(() {
          _borderRadius = display;
          _borderRadiusValue = _isWindowed ? parsed : 0.0;
        });
      }
      print('GTK border-radius (via platform channel): $_borderRadius');
    } catch (e) {
      setState(() {
        _borderRadius = 'error: $e';
      });
      print('Error invoking platform channel: $e');
    }
  }

  Future<void> _setOverlaysVisible(bool visible) async {
    try {
      await platform.invokeMethod('setOverlaysVisible', visible);
      // no local state kept here; the native side will control overlays and
      // any updates will arrive via the platform channel handler.
    } catch (e) {
      print('Error setting overlays visible: $e');
    }
  }

  double _parseBorderRadius(String s) {
    // Extract first numeric value from strings like '6px' or '6.0px'
    final m = RegExp(r"([0-9]+(?:\.[0-9]+)?)").firstMatch(s);
    if (m != null) {
      return double.tryParse(m.group(1) ?? '') ?? 0.0;
    }
    return 0.0;
  }

  GtkThemeData themeData = GtkThemeData(name: 'Default');

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (isLinux) {
      themeData = await GtkThemeData.initialize();
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the brightness.
    // initPlatformState();
    // if (isWindows) {
    //       Window.setEffect(
    //     effect: WindowEffect.acrylic,
    //     dark: Theme.of(context).brightness == Brightness.dark,
    //     );

    //    }
  }

  late ScrollController _scrollController;
  // variable height passed to SliverAppBar expanded height
  late double? _expandedHeight;
  // keep a single PageController for the lifetime of this State
  late final PageController _pageController;

  // constant more height that is given to the expandedHeight
  // of the SliverAppBar
  final double _moreHeight = 130;

  @override
  dispose() {
    // dispose the scroll listener and controller
    _scrollController.removeListener(_scrollListen);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _scrollListen() {
    final pos = _scrollController.position;
    final offset = pos.pixels;
    // if (_expandedHeight == null) {
    //   if (offset == 0) {
    //     // AppBar is collapsed and user scrolls to top => enable expansion
    //     setState(() => _expandedHeight = _moreHeight);
    //     // but reset scroll position to avoid jump
    //     pos.correctPixels(_moreHeight - kToolbarHeight);
    //   }
    // } else {
    //   if (offset > _moreHeight - kToolbarHeight) {
    //     // AppBar is expandable and user has collapsed it by scrolling => disable expansion
    //     setState(() => _expandedHeight = null);
    //     // but reset scroll position to avoid jump
    //     pos.correctPixels(0);
    //   }
    // }
  }


  // search field activation was unused; removed to avoid unused-field warnings
int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    bgColor = Theme.of(context).canvasColor;
    baseColor = Theme.of(context).cardColor;
    if (isMacOS) {
      bgColor = Colors.transparent;
      baseColor = Colors.transparent;
    }
    if (isLinux) {
      // read GTK decoration layout from provider (no side-effects here)
      gtkValue = context
          .select((GtkSettings s) => s.getProperty(kGtkDecorationLayout))
          .toString();
      // update colors from the last-initialized GTK theme data (initPlatformState runs in init/didChangeDependencies)
      bgColor = Color(themeData.theme_bg_color);
      baseColor = Color(themeData.theme_base_color);
    }

    // Use the page controller stored on State to avoid recreating it every build
    // (recreating controllers each build can leak/allocate resources repeatedly).

  
    return Scaffold(
      backgroundColor: baseColor,
      body: Stack(
        children: [
            PlatformThemedScaffold(
              navigationWidgetBackgroundColor: bgColor,
              navigationWidget: PlatformThemedNavigationWidget(
                currentIndex: pageIndex,
                onTap: (index){ 
                print(index);
                pageIndex = index;
                setState(() {
                  
                });},
                destinations: [
                  PlatformThemedNavigationDestination(icon: FluentIcons.home_16_filled, label: "Home"),
                  PlatformThemedNavigationDestination(icon: FluentIcons.music_note_1_20_filled, label: "Music"),
                ]
              ),
              body: <Widget>[
                        MainPage(),
                        ConfigPage(),
                      ].elementAt(pageIndex),
            ),
        ],
      ),
    );
  }
}

