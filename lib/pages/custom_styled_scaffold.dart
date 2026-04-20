import 'dart:io' show Platform;
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_acrylic/flutter_acrylic.dart';
// import 'package:gtk/gtk.dart';
import 'package:gtk_theme_fl/gtk_theme_fl.dart';
import 'package:sharing_option/configs/config_values.dart';
import 'package:sharing_option/constants/current_platform.dart';
import 'package:sharing_option/widgets/toolbar_themed_buttons.dart';
// import 'package:handy_window/handy_window.dart';
// import 'package:libadwaita_searchbar/libadwaita_searchbar.dart';
// import 'package:macos_ui/macos_ui.dart';
// import 'package:provider/provider.dart';
// //import 'package:sharing_option/pages/start.dart';
// import 'package:system_theme/system_theme.dart';
// import 'package:themed/themed.dart';
// import 'package:web_smooth_scroll/web_smooth_scroll.dart';
import '../yaru_title_bar_gesture_detector.dart';
//import 'package:yaru/yaru.dart';


Color baseColor = const Color.fromARGB(255, 21, 15, 31).withAlpha(0);
Color bgColor = const Color.fromARGB(255, 32, 22, 48).withAlpha(0);
double blurRadius = 30;

class CustomStyledScaffold extends StatefulWidget {
  const CustomStyledScaffold({
    super.key,
    this.appBarColor = Colors.transparent,
    required this.body,
    this.title = 'Custom Styled Scaffold',
    this.actions,
  });
  final Color appBarColor;
  final Widget body;
  final String title;
  final List<Widget>? actions;
  @override
  State<CustomStyledScaffold> createState() => _CustomStyledScaffoldState();
}

class _CustomStyledScaffoldState extends State<CustomStyledScaffold> {
  GtkThemeData themeData = GtkThemeData(name: 'Default');

  @override
  void initState() {
    super.initState();
    // _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListen);
    // initially expanded height is full
    initPlatformState();
  }

  Color gtkThemeRefresh = Colors.black;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (Platform.isLinux) {
      themeData = await GtkThemeData.initialize();
      setState(() {});
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    print(notification.metrics.axisDirection);

    if (blurRadius != 0 &&
        (notification.metrics.axisDirection == AxisDirection.down ||
            notification.metrics.axisDirection == AxisDirection.up)) {
      if (notification.metrics.pixels > 0) {
        if (notification.metrics.pixels <
            notification.metrics.maxScrollExtent) {
          if (notification.metrics.pixels / 10 > blurRadius) {
          } else {
            setState(() {
              // Call set state to respond to a change in the scroll notification.
              customPixel = notification.metrics.pixels / 10;
            });
          }
        } else {
          if (customPixel != blurRadius) {
            setState(() {
              // Call set state to respond to a change in the scroll notification.
              customPixel = blurRadius;
            });
          }
        }
      } else {
        if (customPixel != 0) {
          setState(() {
            // Call set state to respond to a change in the scroll notification.
            customPixel = 0;
          });
        }
      }
    }

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
  double scrollPos = 0.0;
  double top = 0.0;
  double customPixel = 0;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: NestedScrollView(
        //physics: BouncingScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
            <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              leadingWidth: 60,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              pinned: true,
              floating: true,
              toolbarHeight: headerBarSize,
              expandedHeight: _expandedHeight,
              collapsedHeight: headerBarSize,
              elevation: 6,
              shadowColor: Color.fromARGB(255, 0, 0, 0),
              foregroundColor: const Color.fromARGB(244, 255, 0, 0),
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  top = constraints.biggest.height;

                  return Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(
                            top.toInt() == headerBarSize ? 10 : 0, 0, 0, 0),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: Offset(0, 3),
                      )
                    ]),
                    child: Stack(children: [
                      FlexibleSpaceBar(
                        centerTitle: true,
                        expandedTitleScale: 1,
                        collapseMode: CollapseMode.parallax,
                        titlePadding: EdgeInsets.all(0),
                        title: YaruTitleBarGestureDetector(
                          onDrag: (details) {
                            if (isLinux || isMacOS || isWindows) {
                              appWindow.startDragging();
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Container(
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(),
                                        child: Opacity(
                                          opacity: 0.5,
                                          child: BackdropFilter(
                                            blendMode: BlendMode.src,
                                            filter: ImageFilter.blur(
                                                sigmaX: customPixel,
                                                sigmaY: customPixel),
                                            child: Opacity(
                                                opacity: 1, child: SizedBox()),
                                          ),
                                        ),
                                      ),
                                    ),

                                    AppBar(
                                      systemOverlayStyle: SystemUiOverlayStyle(
                                          statusBarBrightness:
                                              Theme.of(context).brightness,
                                          statusBarColor: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          statusBarIconBrightness:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Brightness.light
                                                  : Brightness.dark),
                                      toolbarHeight: headerBarSize,
                                      surfaceTintColor:
                                          const Color.fromARGB(160, 65, 0, 0),
                                      backgroundColor:
                                          const Color.fromARGB(0, 255, 153, 0),
                                      toolbarOpacity: 0,
                                      elevation: 0,
                                      leadingWidth: 0,
                                      leading: SizedBox(),
                                      actions: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Tooltip(
                                            message: 'Collapse sidebar',
                                            child: PlatformThemedToolbarButton(
                                              child: Icon(Icons.menu),
                                              onPressed: () => print(operatingSystemVersion),
                                            ),
                                          ),
                                        ),
                                        // RightWindowButtonsSpacing(
                                        //   hideBtnSpacing: top <= 90,
                                        // )
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
                                    Container(width: 40, height: 40, decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black,
                                          blurRadius: 30,
                                        )
                                      ]
                                    ),)
                                  ],
                                ),
                            ],
                          ),
                        ),
                        background: Container(
                          alignment: Alignment(0, 0),
                          padding: EdgeInsets.only(bottom: headerBarSize),
                        ),
                      ),
                      Center(
                          child: Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: ((top - headerBarSize) / top) * 24 + 16,
                            fontWeight: FontWeight.bold),
                      )),
                    ]),
                  );
                },
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        ],

        body: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            toolbarHeight: headerBarSize,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarOpacity: 0,
          ),
          body: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: headerBarSize),
                decoration: BoxDecoration(
                    border: BoxBorder.fromLTRB(
                        top: BorderSide(
                            color: blurRadius == 0 && isWindows
                                ? const Color.fromARGB(58, 0, 0, 0)
                                : Colors.transparent,
                            width: .6),
                        left: BorderSide(
                            color: blurRadius == 0 && isWindows
                                ? const Color.fromARGB(58, 0, 0, 0)
                                : Colors.transparent,
                            width: .6)),
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(9)),
                    color: blurRadius == 0 && isWindows
                        ? const Color.fromARGB(88, 40, 40, 40)
                        : Colors.transparent),
              ),
              NotificationListener<ScrollNotification>(
                //child: CustomScrollView(..),
                onNotification: _handleScrollNotification,

                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast),
                  //controller: _blurAmount,
                  padding: EdgeInsets.only(top: headerBarSize),

                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(9)),
                        color: blurRadius != 0 && isWindows
                            ? const Color.fromARGB(88, 40, 40, 40)
                            : Colors.transparent),
                    child: widget.body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
