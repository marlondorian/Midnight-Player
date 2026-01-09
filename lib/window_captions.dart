import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
//import 'package:fluentui_system_icons/fluentui_system_icons.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gtk/gtk.dart';
import 'package:gtk_theme_fl/gtk_theme_fl.dart';
//import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:snap_layouts/snap_layouts.dart';
import 'package:window_manager/window_manager.dart';

import 'package:xdg_icons/xdg_icons.dart';
//import 'package:yaru/yaru.dart';
import 'main.dart';
import 'yaru_title_bar_gesture_detector.dart';







double unnecesaryRefreshConditionX = 0;
double unnecesaryRefreshConditionY = 0;
Color gtkWindowButtonsBg = Colors.black;
int _hoverGtkCloseBg = Platform.isWindows ?0 :28;
double windowsButtonSize = 15;
String gtkValue = 'nogtk';
int gtkValueIndex = gtkValue.indexOf(',',0);



class closeWindowControl extends StatefulWidget {
  const closeWindowControl({super.key});

  @override
  State<closeWindowControl> createState() => _closeWindowControlState();
}

class _closeWindowControlState extends State<closeWindowControl> {
  @override
  Widget build(BuildContext context) {
    return File('$home/.themes/$themeValue/xfwm4/close-active.png').existsSync()?
                  
                    Align(alignment: Alignment.topCenter, child: Image(image: AssetImage('$home/.themes/$themeValue/xfwm4/close-active.png'),fit: BoxFit.cover,))
                  :File('$home/.themes/$themeValue/xfwm4/close-active.svg').existsSync()?
                  SvgPicture.asset('$home/.themes/$themeValue/xfwm4/close-active.svg'):

                  File('/usr/share/themes/$themeValue/xfwm4/close-active.png').existsSync()?
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(image: AssetImage('/usr/share/themes/$themeValue/xfwm4/close-active.png')),
                  )
                  :File('/usr/share/themes/$themeValue/xfwm4/close-active.svg').existsSync()?
                  SvgPicture.asset('/usr/share/themes/$themeValue/xfwm4/close-active.svg'):
                  XdgIcon(
                    name: 'window-close-symbolic',
                    size: 16,
                  );
                  // File('$home/.themes/$themeValue/metacity-1/metacity-theme-1.xml').existsSync()?
                  // metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString().split('.').last == 'png'?
                  // Image(image: AssetImage('$home/.themes/$themeValue/metacity-1/${metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString()}'))
                  // :metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString().split('.').last == 'svg'
                  // ?SvgPicture.asset('$home/.themes/$themeValue/metacity-1/${metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString()}')
                  // :XdgIcon(
                  //                                     name: 'window-close-symbolic',
                  //                                     size: 16,
                  //                                     )
                  // :metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString().split('.').last == 'png'?
                  // Image(image: AssetImage('/usr/share/themes/$themeValue/metacity-1/${metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString()}'))
                  // :metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString().split('.').last == 'svg'
                  // ?SvgPicture.asset('/usr/share/themes/$themeValue/metacity-1/${metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString()}')
                  // :XdgIcon(
                  //                                     name: 'window-close-symbolic',
                  //                                     size: 16,
                  //                                     ),;
  }
}


class GtkWindowControl extends StatefulWidget {
  const GtkWindowControl({
    super.key,
    required this.themedatas,
    required this.indexer
  });
  final GtkThemeData themedatas;
  final String indexer;
  @override
  State<GtkWindowControl> createState() => _GtkWindowControlState();
}

class _GtkWindowControlState extends State<GtkWindowControl> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 38,
                      child: MaterialButton(
                        animationDuration: Duration(milliseconds: 150),
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        padding: EdgeInsets.all(12),
                        color: gtkWindowButtonsBg.withAlpha(28),
                        hoverColor: gtkWindowButtonsBg.withAlpha(14),
                        minWidth: 24,
                        height: 24,
                        shape: CircleBorder(),
                        onPressed: appWindow.maximizeOrRestore,
                        child: ColorFiltered( 
                          colorFilter: ColorFilter.mode(Color(widget.themedatas.theme_text_color).withAlpha(180), BlendMode.srcATop),child: 
                          Stack(
                            children: [
                              Visibility(
                                visible: appWindow.isMaximized,
                                child: XdgIcon(
                                  name: 'window-restore-symbolic',
                                  size: 16,
                                ),
                              ),
                              Visibility(
                                visible: !appWindow.isMaximized,
                                child: XdgIcon(
                                  name: 'window-maximize-symbolic',
                                  size: 16,
                                ),
                              ),
                            ],
                          ),),
                      ));
  }
}


class RightWindowButtons extends StatefulWidget {
  const RightWindowButtons({
    super.key,
    required this.headerSize,
  });
  final double headerSize;
  @override
  State<RightWindowButtons> createState() => _RightWindowButtonsState();
}


String themeValue = "";
Map<String, String> envVars = Platform.environment;
String home = Platform.isMacOS||Platform.isLinux?envVars['HOME']!:envVars['UserProfile']!;

class _RightWindowButtonsState extends State<RightWindowButtons> {
  
    GtkThemeData themeData =GtkThemeData(name: 'Default');
  Future<void> initPlatformState() async {
    
  // print(home);
    if (Platform.isLinux) {
      themeData = await GtkThemeData.initialize();    
    setState(() {});
    }
  }

  
  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  // Get the brightness. 
  initPlatformState();
}

  @override
  Widget build(BuildContext context) {
    if (isLinux) {  
      // initPlatformState is called from lifecycle hooks (didChangeDependencies);
      // avoid calling it directly inside build to prevent repeated async work.
    }
    if (Platform.isLinux) {
      gtkValue = context.select((GtkSettings s) => s.getProperty(kGtkDecorationLayout)).toString();
      themeValue = context.select((GtkSettings s) => s.getProperty(kGtkThemeName)).toString();
      
      
    }
    // final metacity = File('$home/.themes/$themeValue/metacity-1/metacity-theme-1.xml').existsSync()
    //                   ?File('$home/.themes/$themeValue/metacity-1/metacity-theme-1.xml')
    //                   :File('/usr/share/themes/$themeValue/metacity-1/metacity-theme-1.xml');
    // final metacityXml = metacity.existsSync()? XmlDocument.parse(metacity.readAsStringSync()):XmlDocument.parse('');
        // print(metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString().split('.').last);



  // Avoid calling setState from build(); MediaQuery changes will trigger rebuilds.
  // Keep cached values up-to-date for any calculations.
  unnecesaryRefreshConditionX = MediaQuery.sizeOf(context).width;
  unnecesaryRefreshConditionY = MediaQuery.sizeOf(context).height;
    if (gtkWindowButtonsBg != Theme.of(context).hintColor) {
      // schedule platform initialization after this frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) initPlatformState();
      });
    }
    gtkWindowButtonsBg = Theme.of(context).hintColor;
    // print('$home/.themes/$themeValue/xfwm4/');
    
    return Stack(
      children: [
        
        Platform.isWindows?
        SizedBox(
          height: widget.headerSize,
          child: 
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
    

                SizedBox(
                    width: 48,
                    height: widget.headerSize,
                    child: WindowCaptionButton.minimize(
                      brightness: Theme.of(context).brightness,
                    onPressed: () async {
                      bool isMinimized = await windowManager.isMinimized();
                      if (isMinimized) {
                        windowManager.restore();
                      } else {
                        windowManager.minimize();
                      }
                    },
                  ),
                ),
                
                // GestureDetector(
                    
                //     child: MouseRegion(
                //       onEnter: (event) {
                        
                //         setState(() {
                //           _hoverGtkMinimizeBg = Theme.of(context).brightness == Brightness.light?10:15;
                //         });
                //       },
                //       onExit: (event) {
                //         setState(() {
                //           _hoverGtkMinimizeBg = 0;
                //         });
                //       },
                //       child: AnimatedContainer(
                //         alignment: Alignment(0, 0),
                //         duration: const Duration(milliseconds: 70),
                //         width: 48,
                //         height: 46,
                //         color: (Theme.of(context).brightness == Brightness.light ?Colors.black :Colors.white).withAlpha(_hoverGtkMinimizeBg),
                //         child: ColorFiltered( 
                //           colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.light ?Colors.black :Colors.white, 
                //           BlendMode.srcATop,),child: SizedBox(height: windowsButtonSize+1,width: windowsButtonSize+1,
                //             child: SvgPicture.asset('assets/minimize.svg'),),),
                //       ),
                //     ),
                //   ),
                  

                  SizedBox(width: 48, height: widget.headerSize, child: FutureBuilder<bool>(
                    future: windowManager.isMaximized(),
                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.data == true) {
                        return SnapLayoutsButton.unmaximize(
                          brightness: Theme.of(context).brightness,
                          onPressed: () {
                            windowManager.unmaximize();
                          },
                        );
                      }
                      return SnapLayoutsButton.maximize(
                        brightness: Theme.of(context).brightness,
                        onPressed: () {
                          windowManager.maximize();
                        },
                      );
                    },
                  ),),

                  // SizedBox(
                  //   width: 48,
                  //   height: 46,
                  //   child: SnapLayoutsButton(
                  //     brightness: Theme.of(context).brightness,
                  //     iconName: appWindow.isMaximized?'icon_chrome_unmaximize':appWindow.isVisible?'icon_chrome_maximize':'icon_chrome_unmaximize',
                  //     onPressed: () => appWindow.maximizeOrRestore(),
                  //   )
                  // ),
                  // SizedBox(
                  //   width: 48,
                  //   height: 46,
                  //   child: WindowCaptionButton.close()
                  // ),

                  // GestureDetector(
                  //   onTap: appWindow.maximizeOrRestore,
                  //   child: MouseRegion(
                  //     onEnter: (event) {
                        
                  //       setState(() {
                  //         _hoverGtkMaximizeBg = 42;
                  //       });
                  //     },
                  //     onExit: (event) {
                  //       setState(() {
                  //         _hoverGtkMaximizeBg = 0;
                  //       });
                  //     },
                  //     child: AnimatedContainer(
                  //       alignment: Alignment(0, 0),
                  //       duration: const Duration(milliseconds: 150),
                  //       width: 48,
                  //       height: 46,
                  //       decoration: BoxDecoration(
                  //         color: gtkWindowButtonsBg.withAlpha(_hoverGtkMaximizeBg)
                  //    ,
                  //       ),
                  //       child: Stack(
                  //         children: [
                  //           ColorFiltered( 
                  //             colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.light ?Colors.black :Colors.white, BlendMode.srcATop),child: 
                  //             SizedBox(width: windowsButtonSize+1,height: windowsButtonSize+1,
                  //               child: Stack(
                  //                 children: [
                  //                   Visibility(
                  //                     visible: appWindow.isMaximized,
                  //                     child: SvgPicture.asset('assets/restore.svg'),),
                  //                   Visibility(
                  //                     visible: !appWindow.isMaximized,
                  //                     child: SvgPicture.asset('assets/maximize.svg'),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
    
                  GestureDetector(
                    onTap: appWindow.close,
                    child: MouseRegion(
                      onEnter: (event) {
                        
                        setState(() {
                          _hoverGtkCloseBg = 225;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          _hoverGtkCloseBg = 0;
                        });
                      },
                      child: AnimatedContainer(
                        alignment: Alignment(0, 0),
                        duration: const Duration(milliseconds: 70),
                        width: 48,
                        height: widget.headerSize,
                        color: const Color.fromARGB(255, 206, 29, 16).withAlpha(_hoverGtkCloseBg),
                        child: ColorFiltered( 
                          colorFilter: 
                          ColorFilter.mode(Theme.of(context).brightness == Brightness.dark || _hoverGtkCloseBg == 225 ?Colors.white :Colors.black, 
                          BlendMode.srcATop,),child: SizedBox(height: windowsButtonSize-1,width: windowsButtonSize-1,
                            child: SvgPicture.asset('assets/close.svg'),),),
                      ),
                    ),
                  ),
              
            ],),)
        
        :Platform.isLinux?
        Align(
          alignment: Alignment(1, -1),
          child: YaruTitleBarGestureDetector(
            onDrag: (details) {appWindow.startDragging();},
            onDoubleTap:appWindow.maximizeOrRestore,
            child:  // Container(color:,),
                // metacity!=File('')?
                // File('$home/.themes/$themeValue/metacity-1/metacity-theme-1.xml').existsSync()?
                // metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString().split('.').last == 'png'?
                // Image(image: AssetImage('$home/.themes/$themeValue/metacity-1/${metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString()}'))
                // :metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString().split('.').last == 'svg'
                // ?SvgPicture.asset('$home/.themes/$themeValue/metacity-1/${metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString()}')
                // :XdgIcon(
                //                                     name: 'window-close-symbolic',
                //                                     size: 16,
                //                                     )
                // :metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString().split('.').last == 'png'?
                // Image(image: AssetImage('/usr/share/themes/$themeValue/metacity-1/${metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString()}'))
                // :metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString().split('.').last == 'svg'
                // ?SvgPicture.asset('/usr/share/themes/$themeValue/metacity-1/${metacityXml.xpath('//draw_ops[@name="close_focused"]/image[@filename]').first.getAttribute('filename').toString()}')
                // :XdgIcon(
                //                                     name: 'window-close-symbolic',
                //                                     size: 16,
                //                                     )
                //                                     :
        
                // File('$home/.themes/$themeValue/xfwm4/close-active.png').existsSync()?
                
                //   Align(alignment: Alignment.topCenter, child: Image(image: AssetImage('$home/.themes/$themeValue/xfwm4/close-active.png'),fit: BoxFit.cover,))
                // :File('$home/.themes/$themeValue/xfwm4/close-active.svg').existsSync()?
                // SvgPicture.asset('$home/.themes/$themeValue/xfwm4/close-active.svg'):
        
                // File('/usr/share/themes/$themeValue/xfwm4/close-active.png').existsSync()?
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Image(image: AssetImage('/usr/share/themes/$themeValue/xfwm4/close-active.png')),
                // )
                // :File('/usr/share/themes/$themeValue/xfwm4/close-active.svg').existsSync()?
                // SvgPicture.asset('/usr/share/themes/$themeValue/xfwm4/close-active.svg'):
                // XdgIcon(
                //   name: 'window-close-symbolic',
                //   size: 16,
                // ),
            Container(
        
              alignment: Alignment(-1, 0),
              width: gtkValue.substring(gtkValue.indexOf(":")+1).split(',').toString()=='[]'?0:38*gtkValue.substring(gtkValue.indexOf(":")+1).split(',').length.toDouble()+6,
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: gtkValue.substring(gtkValue.indexOf(":")+1).split(',').length,
                itemBuilder: (context, controlIndex) {
                  return  Center(
                    child: 
                    gtkValue.substring(gtkValue.indexOf(":")+1).split(',').elementAt(controlIndex)=='minimize'
                    ?
                    SizedBox(width: 38,
                      child: MaterialButton(
                        animationDuration: Duration(milliseconds: 150),
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        padding: EdgeInsets.all(12),
                        color: gtkWindowButtonsBg.withAlpha(28),
                        hoverColor: gtkWindowButtonsBg.withAlpha(14),
                        minWidth: 24,
                        mouseCursor: MouseCursor.defer,
                        height: 24,
                        shape: CircleBorder(),
                        onPressed:  (){
                          appWindow.minimize();
                          print(gtkValue.substring(0,gtkValue.indexOf(":")).split(','));
                        },
                        child: ColorFiltered( 
                                                colorFilter: ColorFilter.mode(Color(themeData.theme_text_color).withAlpha(180), BlendMode.srcATop),child: XdgIcon(
                                                name: 'window-minimize-symbolic',
                                                size: 16,
                                                ),),
                                      ),
                    )
                    
                    :gtkValue.substring(gtkValue.indexOf(":")+1).split(',').elementAt(controlIndex)=='maximize'
                    
                    ?SizedBox(width: 38,
                    child: MaterialButton(
                      animationDuration: Duration(milliseconds: 150),
                      elevation: 0,
                      focusElevation: 0,
                      hoverElevation: 0,
                      highlightElevation: 0,
                      mouseCursor: MouseCursor.defer,
                      padding: EdgeInsets.all(12),
                      color: gtkWindowButtonsBg.withAlpha(28),
                      hoverColor: gtkWindowButtonsBg.withAlpha(14),
                      minWidth: 24,
                      height: 24,
                      shape: CircleBorder(),
                      onPressed: appWindow.maximizeOrRestore,
                      child: ColorFiltered( 
                        colorFilter: ColorFilter.mode(Color(themeData.theme_text_color).withAlpha(180), BlendMode.srcATop),child: 
                        Stack(
                          children: [
                            Visibility(
                              visible: appWindow.isMaximized,
                              child: XdgIcon(
                                name: 'window-restore-symbolic',
                                size: 16,
                              ),
                            ),
                            Visibility(
                              visible: !appWindow.isMaximized,
                              child: XdgIcon(
                                name: 'window-maximize-symbolic',
                                size: 16,
                              ),
                            ),
                          ],
                        ),),
                    ))
                  :gtkValue.substring(gtkValue.indexOf(":")+1).split(',').elementAt(controlIndex)=='close'
            
                    ?SizedBox(width: 38,
                      child: MaterialButton(
                        animationDuration: Duration(milliseconds: 150),
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        mouseCursor: MouseCursor.defer,
                        highlightElevation: 0,
                        padding: EdgeInsets.all(12),
                        color: gtkWindowButtonsBg.withAlpha(28),
                        hoverColor: gtkWindowButtonsBg.withAlpha(14),
                        minWidth: 24,
                        height: 24,
                        shape: CircleBorder(),
                        onPressed: appWindow.close,
                        child: ColorFiltered( 
                          colorFilter: ColorFilter.mode(Color(themeData.theme_text_color).withAlpha(180), BlendMode.srcIn),child: XdgIcon(
                          name: 'window-close-symbolic',
                          size: 16,
                          ),),
                      ),
                    )
                    :gtkValue.substring(0,gtkValue.indexOf(":")).split(',').elementAt(controlIndex)=='icon'
                    ?
                    SizedBox(width: 38,
                    child: Center(child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color:const Color.fromARGB(106, 114, 114, 114),
                        borderRadius: BorderRadius.circular(5)
                      ),
                    )),
                    )
                  :SizedBox(width: 0,height: 0,)
                  );
                },
              ),
            ),
          ),
        ):SizedBox(width: 0,height: 0,)
      ],
    );
  }
}

Color gtkWindowButtonsBgLeft = Colors.black;



class LeftWindowButtons extends StatefulWidget {
  const LeftWindowButtons({super.key});

  @override
  State<LeftWindowButtons> createState() => _LeftWindowButtonsState();
}

class _LeftWindowButtonsState extends State<LeftWindowButtons> {
  
    GtkThemeData themeData = GtkThemeData(name: 'Default');
  Future<void> initPlatformState() async {
    if (isLinux){
    themeData = await GtkThemeData.initialize();    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    if (Platform.isLinux) {
      gtkValue = context.select((GtkSettings s) => s.getProperty(kGtkDecorationLayout)).toString();
    }
    // update cached sizes
    unnecesaryRefreshConditionX = MediaQuery.sizeOf(context).width;
    unnecesaryRefreshConditionY = MediaQuery.sizeOf(context).height;
    if (gtkWindowButtonsBgLeft != Theme.of(context).canvasColor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) initPlatformState();
      });
    }
    gtkWindowButtonsBgLeft = Theme.of(context).canvasColor;
    
    return 
    
    Stack(
      children: [
        Platform.isLinux?
        Align(
          alignment: Alignment(-1, -1),
          child: YaruTitleBarGestureDetector(
            onDrag: (details) {appWindow.startDragging();},
            onDoubleTap:appWindow.maximizeOrRestore,
            child: Container(
              alignment: Alignment(1, 0),
              width: gtkValue.substring(0,gtkValue.indexOf(":")).split(',').toString()=='[]'?0:38*(gtkValue.substring(0,gtkValue.indexOf(":")).split(',').length.toDouble())+6,
              height: headerBarSize,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 6),
                scrollDirection: Axis.horizontal,
                itemCount: gtkValue.substring(0,gtkValue.indexOf(":")).split(',').length,
                itemBuilder: (context, controlIndex) {
                
                  return  Center(
                    child: 
                    gtkValue.substring(0,gtkValue.indexOf(":")).split(',').elementAt(controlIndex)=='minimize'
                    ?
                    SizedBox(width: 38,
                      child: MaterialButton(
                        animationDuration: Duration(milliseconds: 150),
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        padding: EdgeInsets.all(12),
                        color: gtkWindowButtonsBg.withAlpha(28),
                        hoverColor: gtkWindowButtonsBg.withAlpha(14),
                        minWidth: 24,
                        mouseCursor: MouseCursor.defer,
                        height: 24,
                        shape: CircleBorder(),
                        onPressed: (){
                          appWindow.minimize();
                          print(gtkValue.substring(0,gtkValue.indexOf(":")).split(','));
                          print(gtkValue.substring(0,gtkValue.indexOf(":")).split(','));
                          print(gtkValue.substring(gtkValue.indexOf(":")+1).split(',').toString()=='[]');
                        },
                        child: ColorFiltered( 
                                                colorFilter: ColorFilter.mode(Color(themeData.theme_text_color).withAlpha(180), BlendMode.srcATop),child: XdgIcon(
                                                name: 'window-minimize-symbolic',
                                                size: 16,
                                                ),),
                                      ),
                    )
                    
                    :gtkValue.substring(0,gtkValue.indexOf(":")).split(',').elementAt(controlIndex)=='maximize'
                    
                    ?SizedBox(width: 38,
                    child: MaterialButton(
                      animationDuration: Duration(milliseconds: 150),
                      elevation: 0,
                      focusElevation: 0,
                      hoverElevation: 0,
                      highlightElevation: 0,
                      mouseCursor: MouseCursor.defer,
                      padding: EdgeInsets.all(12),
                      color: gtkWindowButtonsBg.withAlpha(28),
                      hoverColor: gtkWindowButtonsBg.withAlpha(14),
                      minWidth: 24,
                      height: 24,
                      shape: CircleBorder(),
                      onPressed: appWindow.maximizeOrRestore,
                      child: ColorFiltered( 
                        colorFilter: ColorFilter.mode(Color(themeData.theme_text_color).withAlpha(180), BlendMode.srcATop),child: 
                        Stack(
                          children: [
                            Visibility(
                              visible: appWindow.isMaximized,
                              child: XdgIcon(
                                name: 'window-restore-symbolic',
                                size: 16,
                              ),
                            ),
                            Visibility(
                              visible: !appWindow.isMaximized,
                              child: XdgIcon(
                                name: 'window-maximize-symbolic',
                                size: 16,
                              ),
                            ),
                          ],
                        ),),
                    ))
                  :gtkValue.substring(0,gtkValue.indexOf(":")).split(',').elementAt(controlIndex)=='close'
            
                    ?SizedBox(width: 38,
                      child: MaterialButton(
                        animationDuration: Duration(milliseconds: 150),
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        mouseCursor: MouseCursor.defer,
                        highlightElevation: 0,
                        padding: EdgeInsets.all(12),
                        color: gtkWindowButtonsBg.withAlpha(28),
                        hoverColor: gtkWindowButtonsBg.withAlpha(14),
                        minWidth: 24,
                        height: 24,
                        shape: CircleBorder(),
                        onPressed: appWindow.close,
                        child: ColorFiltered( 
                          colorFilter: ColorFilter.mode(Color(themeData.theme_text_color).withAlpha(180), BlendMode.srcIn),child: XdgIcon(
                          name: 'window-close-symbolic',
                          size: 16,
                          ),),
                      ),
                    )
                    :gtkValue.substring(0,gtkValue.indexOf(":")).split(',').elementAt(controlIndex)=='icon'
                    ?
                    SizedBox(width: 38,
                    child: Center(child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color:const Color.fromARGB(106, 114, 114, 114),
                        borderRadius: BorderRadius.circular(5)
                      ),
                    )),
                    )
                    
                    :SizedBox(width: 0,height: 0,)
                  );
                },
              ),
            ),
          ),
        )
            :Container()
      ],
    );
  }
}

double windowButtonSpacing = 0.0;

class RightWindowButtonsSpacing extends StatelessWidget {
  const RightWindowButtonsSpacing({super.key,this.hideBtnSpacing} );
final bool? hideBtnSpacing;


  @override
  Widget build(BuildContext context) {
    
    return AnimatedContainer(
      color: const Color.fromARGB(0, 33, 149, 243),
      duration: const Duration(milliseconds: 200),
      width: hideBtnSpacing!? 38*gtkValue.substring(gtkValue.indexOf(":")+1).split(',').length.toDouble()+6:0,
      );
  }
}


double leftWindowPadding = 38*gtkValue.substring(0,gtkValue.indexOf(":")-1).split(',').length.toDouble()+6;

