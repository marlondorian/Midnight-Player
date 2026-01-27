import 'dart:io' show Platform;
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/rendering.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_acrylic/widgets/transparent_macos_sidebar.dart';
import 'package:gtk/gtk.dart';
import 'package:gtk_theme_fl/gtk_theme_fl.dart';
// import 'package:handy_window/handy_window.dart';
// import 'package:libadwaita_searchbar/libadwaita_searchbar.dart';
// import 'package:macos_ui/macos_ui.dart';
// import 'package:macos_window_utils/macos_window_utils.dart';
// import 'package:macos_window_utils/widgets/transparent_macos_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:snap_layouts/snap_layouts.dart';
import 'src/headerbar_sizes.dart';
import 'package:sharing_option/pages/config.dart';
import 'package:sharing_option/pages/start.dart';
// import 'package:system_theme/system_theme.dart';
// import 'package:themed/themed.dart';
import 'package:window_manager/window_manager.dart';
//import 'package:yaru/yaru.dart';
import 'buttons.dart';
import 'window_captions.dart';
import 'yaru_title_bar_gesture_detector.dart';
import 'pages/home.dart';
import 'player.dart';





bool isWindows = false;
bool isLinux = false;
bool isMacOS = false;
bool isAndroid = false;
bool isIOS = false;

// if (kIsWeb) {
//   isWindows = Platform.isWindows;
//   isLinux = Platform.isLinux;
//   isMacOS = Platform.isMacOS;
//   isAndroid = Platform.isAndroid;
//   isIOS = Platform.isIOS;
// } else {
//   if (defaultTargetPlatform == TargetPlatform.windows) {
//     isWindows = true;
//   } else if (defaultTargetPlatform == TargetPlatform.linux) {
//     isLinux = true;
//   } else if (defaultTargetPlatform == TargetPlatform.macOS) {
//     isMacOS = true;
//   } else if (defaultTargetPlatform == TargetPlatform.android) {
//     isAndroid = true;
//   } else if (defaultTargetPlatform == TargetPlatform.iOS) {
//     isIOS = true;
//   }
// }

Color baseColor = const Color.fromARGB(255, 21, 15, 31).withAlpha(0);
Color bgColor = const Color.fromARGB(255, 32, 22, 48).withAlpha(0);

Future<void> main() async {
  if (!kIsWeb) {
  isWindows = Platform.isWindows;
  isLinux = Platform.isLinux;
  isMacOS = Platform.isMacOS;
  isAndroid = Platform.isAndroid;
  isIOS = Platform.isIOS;
}
if (isWindows||isMacOS||isLinux) {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();
  
  await Window.initialize();
  WindowOptions windowOptions = WindowOptions(
    minimumSize: Size(500, 450),
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
  );
}
if (isWindows) {
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
}
  
  runApp(const MyApp());
  if (isMacOS) {    
    Window.enableFullSizeContentView();
      Window.hideTitle();
      Window.makeTitlebarTransparent();

      
    // doWhenWindowReady(() {
    //   // Window.setEffect(
    //   //       effect: WindowEffect.windowBackground,
    //   //       );
    //   // Window.addToolbar();
    //   // 
    //   // Window.setToolbarStyle(toolbarStyle: MacOSToolbarStyle.unifiedCompact);
      appWindow.show();
    // });
    
  }
 if (isWindows||isLinux) { 
  
  
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(800, 600);
    win.minSize = Size(500, 450);
    win.title = 'Custom window with Flutter';
    win.size = Size(initialSize.width-1, initialSize.height);
    win.size = initialSize;
    if (isWindows||isMacOS) {
      
    }
    
  });
  Window.hideWindowControls;
  
}
}



class MyApp extends StatefulWidget {
 const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener{
  GtkThemeData themeDatas =GtkThemeData(name: 'Colloid-Purple-Light');
  Color gtkThemeRefresh =Colors.black;
  @override
  void initState() {
    super.initState();
    Window.hideWindowControls;
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
        setState(() {
          
        });
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
    print('MaximizadoMiamol');
  }
  @override
  void onWindowLeaveFullScreen() {
    if (isMacOS) {
      // Window.addToolbar();
      
    }
    print('DesmaximizadoMiamol');
  }
  @override
  Widget build(BuildContext context) {
    double grayscale = Color(themeDatas.theme_bg_color).r+Color(themeDatas.theme_bg_color).g+Color(themeDatas.theme_bg_color).b;
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
        theme:  ThemeData(),
        darkTheme: ThemeData.dark(),
        themeMode: isLinux ?grayscale<=1.5? ThemeMode.dark:ThemeMode.light :ThemeMode.system,
        home: const Structure(),
        
           ),
     );
  }

  
}

double headerBarSize = 46;


class Structure extends StatefulWidget {
  const Structure({super.key});
  @override
  State<Structure> createState() => _StructureState();
}

class _StructureState extends State<Structure> {
  String _borderRadius = 'cargando...';
  double _borderRadiusValue = 0.0;
  bool _isWindowed = true; // true when window is not maximized/tiled/fullscreen
  // header widths are provided by HeaderbarSizes provider (updated from native)
  // overlays visibility is controlled natively; don't keep an unused local field

  @override
  void initState() {
  super.initState();
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
          _borderRadiusValue = _isWindowed ? _parseBorderRadius(_borderRadius) : 0.0;
        });
      }
    }
    else if (call.method == 'onHeaderbarSizes') {
      final Map<dynamic, dynamic>? args = call.arguments as Map<dynamic, dynamic>?;
      final int left = (args != null && args['left'] != null) ? (args['left'] as int) : 0;
      final int right = (args != null && args['right'] != null) ? (args['right'] as int) : 0;
      if (!mounted) return null;
      // update provider so any widget listening will rebuild
      final headerNotifier = Provider.of<HeaderbarSizes>(context, listen: false);
      headerNotifier.setSizes(left.toDouble(), right.toDouble());
      print('Received headerbar sizes from native: left=${left.toDouble()} right=${right.toDouble()}');
    }
    return null;
  });
  _fetchBorderRadius();
  }
  }

  static const platform = MethodChannel('gtkoverlay/border_radius');

  Future<void> _fetchBorderRadius() async {
    try {
      final String? value = await platform.invokeMethod<String>('getBorderRadius');
      final String display = (value == null || value.isEmpty) ? 'vacío' : value;
      if (display != _borderRadius) {
        final double parsed = _parseBorderRadius(display);
        if (!mounted) return;
        setState(() { _borderRadius = display; _borderRadiusValue = _isWindowed ? parsed : 0.0; });
      }
      print('GTK border-radius (via platform channel): $_borderRadius');
    } catch (e) {
      setState(() { _borderRadius = 'error: $e'; });
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

  GtkThemeData themeData =GtkThemeData(name: 'Default');
  
  
  Color gtkThemeRefresh =Colors.black;
  
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
  if (isLinux) {
        themeData = await GtkThemeData.initialize();
        setState(() {
          
        });
  }
  }

 @override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Get the brightness. 
  initPlatformState();
  if (isWindows) {
        Window.setEffect(
      effect: WindowEffect.tabbed,
      dark: Theme.of(context).brightness == Brightness.dark,
      );

     }
  
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
    if (_expandedHeight == null) {
      if (offset == 0) {
        // AppBar is collapsed and user scrolls to top => enable expansion
        setState(() => _expandedHeight = _moreHeight);
        // but reset scroll position to avoid jump
        pos.correctPixels(_moreHeight - kToolbarHeight);
      }
    } else {
      if (offset > _moreHeight - kToolbarHeight) {
        // AppBar is expandable and user has collapsed it by scrolling => disable expansion
        setState(() => _expandedHeight = null);
        // but reset scroll position to avoid jump
        pos.correctPixels(0);
      }
    }
  }
    double top = 0.0;
    int _pageIndex = 0;
    bool _extendSidebarSmall = false;
    bool _extendSidebarLarge = true;
    bool _hideSidebar = false;
    // search field activation was unused; removed to avoid unused-field warnings

  @override
  Widget build(BuildContext context) {
    bgColor = Theme.of(context).canvasColor;
    baseColor = Theme.of(context).cardColor;
    if (isMacOS||isWindows) {
      bgColor = Colors.transparent;
      baseColor = Colors.transparent;
    }
    if (isLinux) {
      // read GTK decoration layout from provider (no side-effects here)
      gtkValue = context.select((GtkSettings s) => s.getProperty(kGtkDecorationLayout)).toString();
      // update colors from the last-initialized GTK theme data (initPlatformState runs in init/didChangeDependencies)
      bgColor = Color(themeData.theme_bg_color);
      baseColor = Color(themeData.theme_base_color);
    }
    
    // update cached theme color without calling setState from build
    if (gtkThemeRefresh != Theme.of(context).cardColor) {
      gtkThemeRefresh = Theme.of(context).cardColor;
      if (isLinux) {
        bgColor = Color(themeData.theme_bg_color);
        baseColor = Color(themeData.theme_base_color);
      }
    }

  // Use the page controller stored on State to avoid recreating it every build
  // (recreating controllers each build can leak/allocate resources repeatedly).
  final PageController currentPageController = _pageController;
  // Read headerbar sizes from provider so widgets rebuild on native updates
  final double leftHeaderWidth = context.select((HeaderbarSizes h) => h.left);
  // context.select((HeaderbarSizes h) => h.left);
    
           
    return Directionality(textDirection: TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: const Color.fromARGB(0, 200, 42, 42),
        body: 
        
          Stack(
            alignment: Alignment(-1, -1),
            children: [
              Container(color: baseColor,),
              AnimatedPadding(
                duration: Duration(milliseconds: 400),
                curve: Curves.fastLinearToSlowEaseIn,
                padding: EdgeInsets.only(
                  left:MediaQuery.sizeOf(context).width>=800&&_extendSidebarLarge&&!_hideSidebar 
                  ?230 
                  :(MediaQuery.sizeOf(context).width<=700&&isAndroid)||(MediaQuery.sizeOf(context).width<=700&&isIOS)||_hideSidebar 
                    ?0
                    :isLinux?
                    // (38*(gtkValue.substring(0,gtkValue.indexOf(":")).split(',').length.toDouble())+6<=84?84:38*(gtkValue.substring(0,gtkValue.indexOf(":")).split(',').length.toDouble())+6):0)
                    leftHeaderWidth-6<=84?84:leftHeaderWidth-6:84),
                child: PageView(
                  onPageChanged: (pageIndex){
                    setState(() {
                      _extendSidebarSmall = false;
                      print(pageIndex);
                      _pageIndex = pageIndex;
                    });
                  },
                  //physics: NeverScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  controller: currentPageController,
                  scrollDirection: Axis.horizontal,
                  children: [
                    
                    
                    MainPage(appBarColor: isLinux?baseColor:Colors.black,),
                    ColoredBox(color: Colors.blue),
                    ColoredBox(color: Colors.purple),
                    // ConfigPage(),
                    // StartPage()
                  ],
                ),
              ),
    
    
    
              Visibility(
                visible: MediaQuery.sizeOf(context).width<800&&_extendSidebarSmall&&!_hideSidebar,
                child: GestureDetector(
                  onTap: () {
                    print('sex');
                    setState(() {
                      _extendSidebarSmall = false;
                    });
                  },
                  child: Container(
                    color: const Color.fromARGB(0, 33, 149, 243),
                    height: double.infinity,
                    width: double.infinity,
                    ),
                ),
              ),
             
    
    
              SafeArea(
                child: Visibility(
                  visible: 
                  // (isLinux||isMacOS||isWindows||
                  (!(MediaQuery.sizeOf(context).width<700&&(isAndroid||isIOS)))&&
                  !_hideSidebar,
                  child: YaruTitleBarGestureDetector(
                    onSecondaryTap: (){print(gtkValue);},
                    behavior: HitTestBehavior.opaque,
                                                      onDoubleTap: () {if (isLinux||isMacOS||isWindows) {appWindow.maximizeOrRestore();}},
                                                  onDrag: (details) { 
                                                    if (isLinux||isMacOS||isWindows) {
                                                      appWindow.startDragging();}
                                                    }
                                                     ,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastLinearToSlowEaseIn,
                      tween: Tween<double>(
                        begin: (_extendSidebarSmall&&MediaQuery.sizeOf(context).width<800)||(MediaQuery.sizeOf(context).width>=800&&_extendSidebarLarge) ?230 :isLinux?
                            
                            // (38*(gtkValue.substring(0,gtkValue.indexOf(":")).split(',').length.toDouble())+6<=84?84:38*(gtkValue.substring(0,gtkValue.indexOf(":")).split(',').length.toDouble())+6)
                            leftHeaderWidth-6<=84?84:leftHeaderWidth-6
                            :84,
                        end: (_extendSidebarSmall&&MediaQuery.sizeOf(context).width<800)||(MediaQuery.sizeOf(context).width>=800&&_extendSidebarLarge) ?230 :isLinux?
                            
                            // (38*(gtkValue.substring(0,gtkValue.indexOf(":")).split(',').length.toDouble())+6<=84?84:38*(gtkValue.substring(0,gtkValue.indexOf(":")).split(',').length.toDouble())+6)
                            leftHeaderWidth-6<=84?84:leftHeaderWidth-6
                            :84,
                      ),
                      builder: (BuildContext context, double valueSidebarW, Widget? child) {
                        return TransparentMacOSSidebar(
                          child: Container(
                            width: valueSidebarW,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: isWindows 
                                                  ?(Theme.of(context).brightness == Brightness.dark 
                              ?const Color.fromARGB(255, 44, 44, 44)
                              :const Color.fromARGB(255, 254, 254, 254)).withAlpha(MediaQuery.sizeOf(context).width<800&&_extendSidebarSmall  
                                ?200 
                                :0)
                              :isLinux
                              ?bgColor.withAlpha(MediaQuery.sizeOf(context).width<800&&_extendSidebarSmall  
                                ?200 
                                :255)
                              :const Color.fromARGB(0, 0, 0, 0),
                              boxShadow:  [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 0, 0, 0).withAlpha(_extendSidebarSmall&&MediaQuery.sizeOf(context).width<800 ?20:0),
                                  spreadRadius: 7,
                                  blurRadius: 12,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ],
                              border: Border.all(color: const Color.fromARGB(255, 145, 145, 145).withAlpha(_extendSidebarSmall&&MediaQuery.sizeOf(context).width<800 ?50:0),style: BorderStyle.solid,width:1,strokeAlign: BorderSide.strokeAlignOutside),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(MediaQuery.sizeOf(context).width<800&&_extendSidebarSmall?15:0),bottomRight: Radius.circular(MediaQuery.sizeOf(context).width<800&&_extendSidebarSmall?15:0)),
                            ),
                            child:BackdropFilter(
                              blendMode: isLinux? BlendMode.srcOver:BlendMode.src,
                              filter: ImageFilter.blur(sigmaX:MediaQuery.sizeOf(context).width<800&&_extendSidebarSmall ?30 :0,sigmaY:MediaQuery.sizeOf(context).width<800&&_extendSidebarSmall ?30 :0,),
                              child: Column(
                                    children: [
                                                    AnimatedContainer(duration: Duration(milliseconds: 200), height:!((_extendSidebarSmall&&MediaQuery.sizeOf(context).width<800)||(MediaQuery.sizeOf(context).width>=800&&_extendSidebarLarge))?isLinux?(gtkValue.substring(0,gtkValue.indexOf(":")).split(',').singleOrNull!='')?headerBarSize-10:0:isMacOS?32:0:0,),
                                                    SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          
                                                          Container(
                                                            decoration: BoxDecoration(
                                                            color: Color.fromARGB(0, 1, 1, 1),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          width: MediaQuery.sizeOf(context).width+300,
                                                          height: MediaQuery.sizeOf(context).height-66,
                                                          margin: EdgeInsets.all(8),
                                                          child: ListView(
                                                            
                                                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5,right: 2,left: 2,top: 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    
                                    Tooltip(
                                      message: 'Hide sidebar',
                                      child: MaterialButton(
                                        hoverElevation: 0,
                                        padding: EdgeInsets.all(0),
                                        elevation: 0,
                                        color: Color.fromARGB(0, 130, 130, 130),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10))),
                                        minWidth: 26,
                                        height: 40,
                                        
                                        onLongPress: () {
                                          Window.showCloseButton();
                                                  Window.showMiniaturizeButton();
                                                  Window.showZoomButton();
                                          _setOverlaysVisible(true);
                                          print (leftHeaderWidth);
                                        },
                                        onPressed: () async{
                                          Window.hideWindowControls;
                                          
                                          
                                      
                                                  Window.hideCloseButton();
                                                  Window.hideMiniaturizeButton();
                                                  Window.hideZoomButton();
                                                  
                                                  // setState(() {
                                                  //   _hideSidebar = true;
                                                  // });
                                                  _setOverlaysVisible(false);
                                                  // print(gtkValue);
                                                  // print(gtkValue.substring(0,gtkValue.indexOf(":")).split(',').singleOrNull=='');
                                                 
                                              
                                              
                                                },
                                                child: Icon(CupertinoIcons.back,size: 15,),
                                      ),
                                    ),
                                    SizedBox(width: 2,),
                                    Tooltip(
                                      message:_extendSidebarSmall&&MediaQuery.sizeOf(context).width<800||_extendSidebarLarge&&MediaQuery.sizeOf(context).width>=800 ?'Collapse sidebar' :'Expand sidebar',
                                      child: MaterialButton(
                                        hoverElevation: 0,
                                      elevation: 0,
                                      color: Color.fromARGB(0, 130, 130, 130),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10))),
                                              minWidth: 52,
                                              height: 40,
                                              onPressed: (){
                                                if (MediaQuery.sizeOf(context).width<800){
                                                  if (!_extendSidebarSmall) {
                                                    print("object");
                                                  setState(() {
                                                    _extendSidebarSmall = true;
                                                  });
                                                  }else
                                                  {
                                                    print('sex');
                                                  setState(() {
                                                    _extendSidebarSmall = false;
                                                  });
                                                  }}
                                                  
                                                  else{
                                                    if (!_extendSidebarLarge) {
                                                    print("object");
                                                  setState(() {
                                                    _extendSidebarLarge = true;
                                                  });
                                                  }else
                                                  {
                                                    print('sex');
                                                  setState(() {
                                                    _extendSidebarLarge = false;
                                                  });
                                                  }
                                            
                                                  }
                                            
                                            
                                              },
                                        
                                              child: Icon(FluentIcons.navigation_16_regular,size: 20,)
                                            
                                            ),),
                                  ],
                                ),
                              ),
                              // InkWell(
                              //   onTap: () {
                                  
                              //     showDialog(
                                    
                              //       context: context,
                              //       barrierColor: const Color.fromARGB(0, 0, 0, 0),
                              //       builder:
                              //         (BuildContext context) => TapRegion(
                              //           onTapOutside: (event) => setState(() {_searchFieldActive = false;}),
                              //           child: Stack(
                              //             alignment: Alignment(0,0),
                              //             children: [
                              //               Padding(padding: EdgeInsets.all(20),
                              //                 child: ClipRRect(
                              //                   borderRadius: BorderRadius.circular(15),
                              //                   clipBehavior: Clip.hardEdge,
                              //                   child:BackdropFilter(filter:ImageFilter.compose(outer:ImageFilter.blur(sigmaX:30, sigmaY:30), inner: ColorFilter.srgbToLinearGamma() ),blendMode: BlendMode.src,child:Container(
                                                  
                                                  
                              //                     decoration: BoxDecoration(
                              //                     color: isWindows 
                              //                       ?(Theme.of(context).brightness == Brightness.dark 
                              //                         ?const Color.fromARGB(255, 32, 32, 32)
                              //                         :const Color.fromARGB(255, 243, 243, 243)).withAlpha(150)
                              //                         :Color.fromARGB(0, 0, 0, 0),
                              //                     borderRadius: BorderRadius.circular(15),
                              //                   ),
                              //                     constraints: BoxConstraints(maxWidth: 600,maxHeight: 700,minHeight: 0,minWidth: 0),
                                                  
                              //                   ),
                              //                                                                     ),
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         )
                              //     );
                              //     setState(() {_searchFieldActive = true;});
                              //   },
                              //   mouseCursor: SystemMouseCursors.text,
                              //   child: Container(
                              //     margin: EdgeInsets.all(3),
                              //     width: 30,
                              //     height: 35,
                              //     decoration: BoxDecoration(
                              //       color: const Color.fromARGB(35, 130, 130, 130),
                                            
                              //     ),
                              // ),),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(
                                  height: 40,
                                  child: SearchBar())
                              ),
                              SidebarCtrls(pageController: currentPageController,page: 0,currentPage: _pageIndex,icon: Icon(FluentIcons.home_20_regular,size: 20),filledIcon: Icon(FluentIcons.home_16_filled,size: 20,),extendedSidebar: (_extendSidebarSmall&&MediaQuery.sizeOf(context).width<800)||(MediaQuery.sizeOf(context).width>=800&&_extendSidebarLarge),text: 'Home',),
                                  SidebarCtrls(pageController: currentPageController,page: 1,currentPage: _pageIndex,icon: Icon(FluentIcons.music_note_1_20_regular,size: 20,),filledIcon: Icon(FluentIcons.music_note_1_20_filled,size: 20),extendedSidebar: (_extendSidebarSmall&&MediaQuery.sizeOf(context).width<800)||(MediaQuery.sizeOf(context).width>=800&&_extendSidebarLarge),text: 'Music',),
                                  SidebarCtrls(pageController: currentPageController,page: 2,currentPage: _pageIndex,extendedSidebar: (_extendSidebarSmall&&MediaQuery.sizeOf(context).width<800)||(MediaQuery.sizeOf(context).width>=800&&_extendSidebarLarge),),
                                  SidebarCtrls(pageController: currentPageController,page: 3,currentPage: _pageIndex,extendedSidebar: (_extendSidebarSmall&&MediaQuery.sizeOf(context).width<800)||(MediaQuery.sizeOf(context).width>=800&&_extendSidebarLarge), ),
                                  SidebarCtrls(pageController: currentPageController,page: 4,currentPage: _pageIndex,extendedSidebar: (_extendSidebarSmall&&MediaQuery.sizeOf(context).width<800)||(MediaQuery.sizeOf(context).width>=800&&_extendSidebarLarge),),
                              ListTile(contentPadding: EdgeInsets.all(30),),
                                                            ],
                                                          ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                    ],
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ),
              ),
                        // isAndroid||kIsWeb 
                        // ?Padding(padding: EdgeInsets.all(0)) :
                        RightWindowButtons(headerSize: 46,),
                        // isAndroid||kIsWeb 
                        // ?Padding(padding: EdgeInsets.all(0)) :LeftWindowButtons(),
    
    
    
              PlayerScreen()
                        
                        /*CupertinoTabBar(
                          currentIndex: _pageIndex,
                          onTap: (_gtkValue) {
                             print(MediaQuery.sizeOf(context).width);
                              print(_gtkValue);
                              currentPageController.jumpToPage(_gtkValue);
                          },
                          items: [
                          BottomNavigationBarItem(icon: Icon(FluentIcons.home_20_regular,size: 20),label:'Home',activeIcon: Icon(FluentIcons.home_16_filled,size: 20,)),
                           BottomNavigationBarItem(icon: Icon(FluentIcons.home_20_regular,size: 20),label:'Home',activeIcon: Icon(FluentIcons.home_16_filled,size: 20,))
                        ],),*/
                       
                      ],
          ), 
    
      ),
    );
  }
}
