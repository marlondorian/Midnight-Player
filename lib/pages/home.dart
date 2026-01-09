import 'dart:io' show Platform;
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_acrylic/flutter_acrylic.dart';
// import 'package:gtk/gtk.dart';
import 'package:gtk_theme_fl/gtk_theme_fl.dart';
// import 'package:handy_window/handy_window.dart';
// import 'package:libadwaita_searchbar/libadwaita_searchbar.dart';
// import 'package:macos_ui/macos_ui.dart';
// import 'package:provider/provider.dart';
// //import 'package:sharing_option/pages/start.dart';
// import 'package:system_theme/system_theme.dart';
// import 'package:themed/themed.dart';
// import 'package:web_smooth_scroll/web_smooth_scroll.dart';
import '../window_captions.dart';
import '../yaru_title_bar_gesture_detector.dart';
//import 'package:yaru/yaru.dart';



bool isWindows = false;
bool isLinux = false;
bool isMacOS = false;
bool isAndroid = false;
bool isIOS = false;
Color baseColor = const Color.fromARGB(255, 21, 15, 31).withAlpha(0);
Color bgColor = const Color.fromARGB(255, 32, 22, 48).withAlpha(0);
double headerBarSize = 46;
double blurRadius = 30;
 

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    this.appBarColor=Colors.transparent,

  });
  final Color appBarColor;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  GtkThemeData themeData =GtkThemeData(name: 'Default');
  

  @override
  void initState() {
  if (!kIsWeb) {
  isWindows = Platform.isWindows;
  isLinux = Platform.isLinux;
  isMacOS = Platform.isMacOS;
  isAndroid = Platform.isAndroid;
  isIOS = Platform.isIOS;
}
    super.initState();
    // _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListen);
    // initially expanded height is full
    initPlatformState();
  }
  Color gtkThemeRefresh =Colors.black;
  
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
  if (isLinux) {
        themeData = await GtkThemeData.initialize();
        setState(() {
          
        });
  }
  }

 
  bool _handleScrollNotification(ScrollNotification notification) {

    // print(notification.metrics.axisDirection);
    
      if (blurRadius!=0&&(notification.metrics.axisDirection==AxisDirection.down||notification.metrics.axisDirection==AxisDirection.up)){if (notification.metrics.pixels>0) {
        if (notification.metrics.pixels<notification.metrics.maxScrollExtent) {
         if (notification.metrics.pixels/10>blurRadius) {}else{
        setState(() {
        // Call set state to respond to a change in the scroll notification.
        customPixel = notification.metrics.pixels/10;
      });
      }
      }
        else{
          if (customPixel!=blurRadius) {
            setState(() {
          // Call set state to respond to a change in the scroll notification.
          customPixel = blurRadius;
        });}
      } 
      
      } else{
        if (customPixel!=0) {
          setState(() {
        // Call set state to respond to a change in the scroll notification.
        customPixel = 0;
      });}}}
    
     return false;
    }
  
  
  // late ScrollController _scrollController;
  //ScrollController _blurAmount = ScrollController();
  // variable height passed to SliverAppBar expanded height

  // constant more height that is given to the expandedHeight
  // of the SliverAppBar
  final double _expandedHeight = 100;



  // @override
  // dispose() {
  //   // dispose the scroll listener and controller
  //   _scrollController.removeListener(_scrollListen);
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  // void _scrollListen() {
  //   final pos = _scrollController.position;
  //   final offset = pos.pixels;
  //   // if (_expandedHeight == null) {
  //   //   if (offset == 0) {
  //   //     // AppBar is collapsed and user scrolls to top => enable expansion
  //   //     setState(() => _expandedHeight = _moreHeight);
  //   //     // but reset scroll position to avoid jump
  //   //     pos.correctPixels(_moreHeight - kToolbarHeight);
  //   //   }
  //   // } else {
  //   //   if (offset > _moreHeight - kToolbarHeight) {
  //   //     // AppBar is expandable and user has collapsed it by scrolling => disable expansion
  //   //     setState(() => _expandedHeight = null);
  //   //     // but reset scroll position to avoid jump
  //   //     pos.correctPixels(0);
  //   //   }
  //   // }
  // }
  double scrollPos =0.0;
    double top = 0.0;
    double customPixel=0;
  @override
  Widget build(BuildContext context) {
    
    return 
  
ClipRRect(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: NestedScrollView(
                      //physics: BouncingScrollPhysics(),
                      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
                        <Widget>[
                          
                                  SliverOverlapAbsorber(
                                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                                    sliver: SliverAppBar(
                                      
                                      leadingWidth: 60,
                                      systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Theme.of(context).brightness,statusBarColor: const Color.fromARGB(255, 0, 0, 0),statusBarIconBrightness: Theme.of(context).brightness==Brightness.dark?Brightness.light:Brightness.dark),

                                      
                                      surfaceTintColor: const Color.fromARGB(173, 255, 255, 255),
                                      automaticallyImplyLeading: false,
                                      pinned: true,
                                      floating: true,
                                      toolbarHeight: headerBarSize,
                                      expandedHeight: _expandedHeight,
                                      collapsedHeight: headerBarSize,
                                      elevation: 6,
                                      shadowColor: Color.fromARGB(255, 0, 0, 0),
                                      foregroundColor: const Color.fromARGB(244, 255, 0, 0),
                                      flexibleSpace:  LayoutBuilder(
                                                                    builder: (BuildContext context, BoxConstraints constraints) {
                                            top = constraints.biggest.height;
                                            
                                            return Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [ BoxShadow(
                                                      color: Color.fromARGB(top.toInt()==headerBarSize?10:0, 0, 0, 0),
                                                      spreadRadius: 2,
                                                      blurRadius: 3,
                                                      offset: Offset(0, 3),)
                                                    ]
                                              ),
                                              child: Stack(
                                                children: [
                                                   Container(
                                                                                                       child: FlexibleSpaceBar(
                                                     
                                                                                             centerTitle: true,
                                                                                             expandedTitleScale: 1,
                                                                                             collapseMode: CollapseMode.parallax,
                                                                                             titlePadding: EdgeInsets.all(0),
                                                                                             title: YaruTitleBarGestureDetector(
                                                   
                                                   onDrag: (details) { 
                                                     if (isLinux||isMacOS||isWindows) {
                                                       appWindow.startDragging();}
                                                     }
                                                      ,
                                                   child: Column(
                                                     mainAxisAlignment: MainAxisAlignment.end,
                                                     children: [
                                                       Container(
                                                         clipBehavior: Clip.antiAlias,
                                                         decoration: BoxDecoration(
                                                           
                                                         ),
                                                           
                                                           child:
                                                           BackdropFilter(
                                                                                           
                                                             blendMode: BlendMode.src,
                                                         filter: ImageFilter.blur(sigmaX:customPixel, sigmaY:customPixel),
                                                         child: 
                                                         AppBar(
                                                          systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Theme.of(context).brightness,statusBarColor: const Color.fromARGB(255, 0, 0, 0),statusBarIconBrightness: Theme.of(context).brightness==Brightness.dark?Brightness.light:Brightness.dark),
                                                           toolbarHeight: headerBarSize,
                                                             surfaceTintColor: const Color.fromARGB(160, 65, 0, 0),
                                                             backgroundColor: const Color.fromARGB(0, 255, 153, 0),
                                                             toolbarOpacity: 0,
                                                             elevation: 0,
                                                             leadingWidth:0,
                                                             leading: SizedBox(),
                                                             actions: [
                                                               
                                                               Padding(
                                                                 padding: const EdgeInsets.all(4.0),
                                                                 child: Tooltip(
                                                                   message:'Collapse sidebar',
                                                                   child: MaterialButton(
                                                                    hoverElevation: 0,
                                                                    elevation: 0,
                                                                    
                                                                    color: Color.fromARGB(79, 130, 130, 130),
                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                            minWidth: 45,
                                                                            height: 45,
                                                                    onPressed: (){
                                                                    // print("object");
                                                                        
                                                                  
                                                                    },
                                                              
                                                                    child: Icon(Icons.menu),
                                                                         
                                                                    ),
                                                                    ),
                                                               ),
                                                                                                   
                                                               RightWindowButtonsSpacing(hideBtnSpacing: top<= 90,)
                                                               ],
                                                             centerTitle: true,
                                                             // title: AnimatedContainer(
                                                               
                                                             //   alignment: Alignment(0, 0),
                                                             //   duration: const Duration(milliseconds: 100),
                                                             //             height: 34,
                                                             //             width: 500,
                                                             //             child: CupertinoSearchTextField(
                                                                           
                                                             //               prefixIcon: const Padding(
                                                             //                 padding: EdgeInsets.fromLTRB(4,6,4,4),
                                                             //                 child: ColorFiltered( colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcATop),
                                                             //                   child: SizedBox(),
                                                             //                 ),
                                                             //               ),
                                                             //               placeholder: 'Ayer me llamo una niña',
                                                             //               style: TextStyle(
                                                             //                 color: Theme.of(context).hintColor,
                                                             //               ),
                                                             //             ),
                                                             //           ),
                                                           ),
                                                         ),
                                                       ),
                                                     ],
                                                   ),
                                                                                             ),
                                                                                             
                                                                                             background: Container(
                                                   alignment: Alignment(0, 0),
                                                   padding: EdgeInsets.only(bottom: 46),),
                                                                                           ),
                                                                                                       ),
                                                  
                                                   SafeArea(bottom: false,child: Center(child: Text('Home',style: TextStyle(fontSize: ((top-headerBarSize-MediaQuery.of(context).padding.top)/(top-MediaQuery.of(context).padding.top))*24+16,fontWeight: FontWeight.bold),))),
                                                
                                                ]
                                              ),
                                            );
                                    },),
                                      backgroundColor: Colors.transparent,
                                    ),
                                                                    
                                                                    
                                                                    ),
                                    
                                    
                                    
                                    
                        ], 
                        
                        body: SafeArea(top: false,bottom: false,
                          child: Scaffold(
                            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                            extendBody: true,
                            extendBodyBehindAppBar: true,
                            appBar: AppBar(toolbarOpacity: 0,primary: false,surfaceTintColor: Colors.transparent,backgroundColor: Colors.transparent,elevation: 0,),
                            // appBar: AppBar(toolbarHeight: headerBarSize,backgroundColor: const Color.fromARGB(0, 90, 73, 73),surfaceTintColor: const Color.fromARGB(0, 63, 63, 139),elevation: 3,toolbarOpacity: 0,),
                            body: Stack(
                              children: [
                                // Container(
                                //   margin: EdgeInsets.only(top:headerBarSize),
                                //   decoration: BoxDecoration(
                                //     border: BoxBorder.fromLTRB(top: BorderSide(color: blurRadius==0&&isWindows ?const Color.fromARGB(58, 0, 0, 0):Colors.transparent,width: .6),left: BorderSide(color: blurRadius==0&&isWindows ?const Color.fromARGB(58, 0, 0, 0):Colors.transparent,width: .6)),
                                //     borderRadius: BorderRadius.only(topLeft: Radius.circular(9)),
                                //     color: blurRadius==0&&isWindows ?const Color.fromARGB(88, 40, 40, 40):Colors.transparent
                                //   ),),
                                                    
                                  
                            
                                 NotificationListener<ScrollNotification>(
                                  
                                   //child: CustomScrollView(..),
                                   onNotification: _handleScrollNotification,
                                 
                                   child: Scrollbar(
                                     child: SingleChildScrollView(
                                      
                                                               
                                                               
                                      
                                        physics: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
                                        //controller: _blurAmount,
                                        padding: EdgeInsets.only(top:headerBarSize),
                                        
                                        
                                        child:Container(
                                          padding: EdgeInsets.only(top:0),
                                          decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(9)),
                                          color: blurRadius!=0&&isWindows ?const Color.fromARGB(88, 40, 40, 40):Colors.transparent),
                                        child: Padding(
                                          padding: EdgeInsetsGeometry.only(top: MediaQuery.of(context).padding.top,bottom: MediaQuery.of(context).padding.bottom),
                                          child: Column(
                                            
                                            children: [
                                                           
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                
                                                margin: EdgeInsets.all(20),
                                                height: 200,
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(20, 142, 142, 147),
                                                  border: Border.all(color: const Color.fromARGB(47, 142, 142, 147),),
                                                  borderRadius: BorderRadius.circular(25),
                                                  boxShadow: [ BoxShadow(
                                                    color: const Color.fromARGB(26, 0, 0, 0),
                                                    spreadRadius: 7,
                                                    blurRadius: 12,
                                                    offset: Offset(0, 3),)
                                                    ]
                                                ),
                                                child: ClipRRect(
                                                  clipBehavior: Clip.antiAlias,
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: ListView(
                                                    scrollDirection: Axis.horizontal,
                                                    children: [
                                                      Container(color: const Color.fromARGB(217, 76, 175, 79),width: 100,),
                                                      Container(color: Colors.blue,width: 100,),
                                                      Container(color: const Color.fromARGB(217, 76, 175, 79),width: 100,),
                                                      Container(color: Colors.blue,width: 100,),
                                                      Container(color: const Color.fromARGB(217, 76, 175, 79),width: 100,),
                                                      Container(color: Colors.blue,width: 100,),
                                                      Container(color: const Color.fromARGB(217, 76, 175, 79),width: 100,),
                                                      Container(color: Colors.blue,width: 100,),
                                                      Container(color: const Color.fromARGB(217, 76, 175, 79),width: 100,),
                                                      Container(color: Colors.blue,width: 100,),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              MaterialButton(onPressed: (){
                                                // print(customPixel);
                                                // print(top);
                                                // print(scrollPos);
                                                
                                                }),
                                              Container(color: const Color.fromARGB(217, 76, 175, 79),height: 100,),
                                              Container(color: const Color.fromARGB(0, 76, 175, 79),height: 100,),
                                              Container(color: const Color.fromARGB(0, 76, 175, 79),height: 100,),
                                              Container(color: const Color.fromARGB(0, 76, 175, 79),height: 100,),
                                              Container(color: const Color.fromARGB(0, 76, 175, 79),height: 100,),
                                              Container(color: const Color.fromARGB(0, 76, 175, 79),height: 100,),
                                              Container(
                                                                  color: Colors.blue,
                                                                  height: 400,
                                                                ),
                                            ],
                                          ),
                                        ),
                                                                          ),
                                                                   ),
                                   ),
                                 ),
                              ],
                            ),
                          ),
                        ),),
                  );
                  }
}
