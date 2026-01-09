import 'dart:io' show Platform;
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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



bool isWindows = Platform.isWindows;
bool isLinux = Platform.isLinux;
bool isMacOS = Platform.isMacOS;
bool isAndroid = Platform.isAndroid;
bool isIOS = Platform.isIOS;
Color baseColor = const Color.fromARGB(255, 21, 15, 31).withAlpha(0);
Color bgColor = const Color.fromARGB(255, 32, 22, 48).withAlpha(0);
double headerBarSize = 46;
double blurRadius = 20;
const double maxHeaderSize = 100;


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GtkThemeData themeData =GtkThemeData(name: 'Default');

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListen);
    // initially expanded height is full
    _expandedHeight = _moreHeight;
    initPlatformState();
  }
  Color gtkThemeRefresh =Colors.black;
  
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
  if (Platform.isLinux) {
        themeData = await GtkThemeData.initialize();
        setState(() {
          
        });
  }
  }

 
  
  
  
  late ScrollController _scrollController;
  ScrollController _blurAmount = ScrollController();
  // variable height passed to SliverAppBar expanded height
  late double? _expandedHeight;

  // constant more height that is given to the expandedHeight
  // of the SliverAppBar
  final double _moreHeight = 130;



  @override
  dispose() {
    // dispose the scroll listener and controller
    _scrollController.removeListener(_scrollListen);
    _scrollController.dispose();
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
        setState(() => _expandedHeight = offset);
        // but reset scroll position to avoid jump
        pos.correctPixels(0);
      }
    }
  }
  double scrollPos =0.0;
    double top = 0.0;
  @override
  Widget build(BuildContext context) {
    return 
  
ClipRRect(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: ColoredBox(
                      color: baseColor.withAlpha(0),
                      child: Scaffold(
                        appBar: AppBar(),
                        backgroundColor: Colors.transparent,

                        body: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                              
                                        SliverAppBar(
                                            leadingWidth: 60,
                                                  
                                                  
                                                  surfaceTintColor: Colors.transparent,
                                                  automaticallyImplyLeading: false,
                                                  pinned: true,
                                                  floating: false,
                                                  toolbarHeight: headerBarSize,
                                                  expandedHeight: _expandedHeight,
                                                  collapsedHeight: headerBarSize,
                                                  elevation: 3,
                                                  foregroundColor: const Color.fromARGB(244, 255, 0, 0),
                                                  flexibleSpace:  LayoutBuilder(
                                          builder: (BuildContext context, BoxConstraints constraints) {
                                                        top = constraints.biggest.height;
                                                        
                                                        return FlexibleSpaceBar(
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
                                                                  filter: ImageFilter.blur(sigmaX:1, sigmaY:1),
                                                              // filter: ImageFilter.blur(sigmaX:_blurAmount.position.pixels>maxHeaderSize?_blurAmount.offset-maxHeaderSize:1, sigmaY:_blurAmount.position.pixels>maxHeaderSize?_blurAmount.offset-maxHeaderSize:1),
                                                              child: 
                                                              AppBar(
                                                                toolbarHeight: headerBarSize,
                                                                  surfaceTintColor: Colors.transparent,
                                                                  backgroundColor: baseColor.withAlpha(isWindows ?0 :220),
                                                                  leadingWidth:0,
                                                                  leading: SizedBox(),
                                                                  actions: [
                                                                    RightWindowButtonsSpacing(hideBtnSpacing: top<= 90,),
                                                                    ],
                                                                  centerTitle: true,
                                                                  title: AnimatedContainer(
                                                                    alignment: Alignment(0, 0),
                                                                    duration: const Duration(milliseconds: 100),
                                                                              height: 34,
                                                                              width: 500,
                                                                              child: CupertinoSearchTextField(
                                                                                
                                                                                prefixIcon: const Padding(
                                                                                  padding: EdgeInsets.fromLTRB(4,6,4,4),
                                                                                  child: ColorFiltered( colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcATop),
                                                                                    child: SizedBox(),
                                                                                  ),
                                                                                ),
                                                                                placeholder: 'Ayer me llamo una niña',
                                                                                style: TextStyle(
                                                                                  color: Theme.of(context).hintColor,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      background: Container(
                                                        alignment: Alignment(0, 0),
                                                        padding: EdgeInsets.only(bottom: 46),
                                                        child: Text('Caca',style: TextStyle(
                                                          fontSize: 30,
                                                        ),),
                                                      ),
                                                    );
                                                },),
                                                  backgroundColor: Colors.transparent,
                                                ),
                                                // SliverToBoxAdapter(child: Scaffold(),),
                                        SliverList(delegate:SliverChildListDelegate([
                                          
                                          
                                          Stack(
                                                                                   children: [
                                                                                     Container(
                                                                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                         margin: EdgeInsets.only(top:headerBarSize),
                                                                         decoration: BoxDecoration(
                                                                           border: BoxBorder.fromLTRB(top: BorderSide(color: blurRadius==0 ?const Color.fromARGB(58, 0, 0, 0):Colors.transparent,width: .6),left: BorderSide(color: blurRadius==0 ?const Color.fromARGB(58, 0, 0, 0):Colors.transparent,width: .6)),
                                                                           borderRadius: BorderRadius.only(topLeft: Radius.circular(9)),
                                                                           color: blurRadius==0 ?const Color.fromARGB(88, 40, 40, 40):Colors.transparent
                                                                           
                                                                         ),
                                                                         child: ColoredBox(color: Colors.transparent),
                                                                         ),
                                                                            
                                                                         
                                                                        Container(
                                                                          decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(9)),
                                                                          color: blurRadius!=0 ?const Color.fromARGB(88, 40, 40, 40):Colors.transparent),
                                                                        child: Column(
                                                                          
                                                                          children: [
                                                                            
                                                                            LayoutBuilder(
                                                                                  builder: (BuildContext context, BoxConstraints constraints) {
                                                                                  scrollPos = constraints.biggest.height;
                                                                                  
                                                                                  return
                                                                            SizedBox(
                                                                              height: 30,
                                                                            );}),
                                            
                                                                            Container(
                                                                              color: Colors.black,
                                                                              height: 20,
                                                                              width: 1,
                                                                            ),
                                            
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
                                                                              print(_expandedHeight);
                                                                              print(top);
                                                                              print(_scrollController.position.pixels);
                                                                              
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
                                                                                   ],
                                                                                 ),
                        
                        
                                        ]) ),
                                    
                                        
                                        
                            ], 
                            
                            ),
                      ),
                    ),
                  );
                  }
}
