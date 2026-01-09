import 'dart:io';
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:gtk/gtk.dart';
import 'package:gtk_theme_fl/gtk_theme_fl.dart';
import 'package:handy_window/handy_window.dart';
import 'package:libadwaita_searchbar/libadwaita_searchbar.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
//import 'package:yaru/yaru.dart';
import '../window_captions.dart';
import '../yaru_title_bar_gesture_detector.dart';

Color baseColor = const Color.fromARGB(255, 21, 15, 31).withAlpha(0);
Color bgColor = const Color.fromARGB(255, 32, 22, 48).withAlpha(0);

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<StartPage> {
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
        setState(() => _expandedHeight = null);
        // but reset scroll position to avoid jump
        pos.correctPixels(0);
      }
    }
  }
    double top = 0.0;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: CustomScrollView(
                    // physics: BouncingScrollPhysics(),
                    //controller: _scrollController,
                      slivers: [
                        SliverAppBar(
                          stretch: true,
                          actions: [
                            MaterialButton(onPressed: (){})
                          ],
                          surfaceTintColor: Colors.transparent,
                          //automaticallyImplyLeading: false,
                          toolbarHeight: 40,

                          pinned: true,
                          //floating: true,
                          //expandedHeight: _expandedHeight,
                          collapsedHeight: 50,
                          
                          elevation: 3,
                          foregroundColor: const Color.fromARGB(244, 255, 0, 0),
                          stretchTriggerOffset: 100.0,
                          expandedHeight: 80.0,
                          flexibleSpace: ClipRRect(
                            child: BackdropFilter(
                                         filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                              child: const FlexibleSpaceBar(
                                centerTitle: true,
                                collapseMode: CollapseMode.parallax,
                                title: Text('SliverAppBar'),
                                background: FlutterLogo(),
                              ),
                            ),
                          ),
                  //         flexibleSpace:  LayoutBuilder(
                  // builder: (BuildContext context, BoxConstraints constraints) {
                  //               top = constraints.biggest.height;
                                
                  //               return FlexibleSpaceBar(
                  //             centerTitle: true,
                  //             expandedTitleScale: 1,
                  //             collapseMode: CollapseMode.parallax,
                  //             titlePadding: EdgeInsets.all(0),
                  //             title: YaruTitleBarGestureDetector(
                                
                  //               child: Container(
                  //                 child: Align(
                  //                   alignment: Alignment(0, 1),
                  //                   child: 
                  //                    Container(
                  //                     clipBehavior: Clip.antiAlias,
                  //                     decoration: BoxDecoration(
                                        
                  //                     ),
                  //                       height: 46,
                  //                       child:
                  //                       BackdropFilter(
                  //                     filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  //                     child: 
                                      
                                      
                  //                     AppBar(
                  //                         surfaceTintColor: Colors.transparent,
                  //                         backgroundColor: baseColor.withAlpha(220),
                  //                         actions: [
                  //                           RightWindowButtonsSpacing(hideBtnSpacing: top<= 90,),
                  //                           ],
                  //                         centerTitle: true,
                  //                         title: AnimatedContainer(
                  //                           duration: const Duration(milliseconds: 100),
                  //                                     height: 34,
                  //                                     width: 500,
                                                      
                  //                                   ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //             background: Container(
                  //               alignment: Alignment(0, 0),
                  //               padding: EdgeInsets.only(bottom: 46),
                  //               child: Text('Caca',style: TextStyle(
                  //                 fontSize: 30,
                  //               ),),
                  //             ),
                  //           );
                  //       },),
                          backgroundColor: Colors.transparent,
                          leadingWidth: 30,
                        ),



                        SliverFillRemaining(
              hasScrollBody: false,
              
              child: Container(),
            ),



                        SliverToBoxAdapter(child:
                          ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
                            child: Scrollbar(
                              
                              scrollbarOrientation: ScrollbarOrientation.right,
                              //controller: _scrollController,
                              child: Container(
                              
                              color:baseColor,
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.green,
                                  ),
                                  Container( height: 44,),
                                  ColorFiltered( colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcATop),child: SizedBox()),
                                    Container(
                                      color: Colors.yellow,
                                      height: 400,
                                    ),
                                    Container(
                                      color: Colors.blue,
                                      height: 400,
                                    ),
                                    Container(
                                      color: const Color.fromARGB(255, 20, 212, 49),
                                      height: 400,
                                    ),
                                    CupertinoNavigationBar(
                                                enableBackgroundFilterBlur: false,
                                                backgroundColor: baseColor.withAlpha(220),
                                                leading: YaruTitleBarGestureDetector(
                                                  
                                                  child: AppBar(
                                                    backgroundColor: Colors.transparent,
                                                    actions: [
                              ElevatedButton(
                                
                                onPressed: (){
                              }, child: Icon(Icons.add),), 
                              ],
                                                    centerTitle: true,
                                                    title: SizedBox(
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
                            ),
                          ),
                        ),
                        
                      ],
                    
                  ),
                );
  }
}