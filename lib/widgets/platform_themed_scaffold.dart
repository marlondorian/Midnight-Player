import 'package:flutter/material.dart';
import 'package:flutter_acrylic/widgets/transparent_macos_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:sharing_option/constants/current_platform.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:sharing_option/native_functions/headerbar_sizes.dart';
import 'package:sharing_option/widgets/sidebar.dart';

class PlatformThemedAppBar {
  final String title;
  PlatformThemedAppBar({this.title = ''});
}

class PlatformThemedNavigationWidget {
  PlatformThemedNavigationWidget({
    this.destinations = const [],
    this.currentIndex = 0,
    this.onTap,
  });
  final List<PlatformThemedNavigationDestination> destinations;
  final int currentIndex;
  final void Function(int)? onTap;
}

class PlatformThemedNavigationDestination {
  final IconData icon;
  final String label;
  PlatformThemedNavigationDestination({
    required this.icon,
    required this.label,
  });
}

class BodyWithSidebar extends StatefulWidget {
  const BodyWithSidebar({super.key,
    this.body,
    this.navigationWidget, 
    this.sidebarVisible = true,
    this.SidebarColor = Colors.transparent,
  });
  final PlatformThemedNavigationWidget? navigationWidget;
  final Widget? body;
  final bool sidebarVisible;
  final Color SidebarColor;

  @override
  State<BodyWithSidebar> createState() => _BodyWithSidebarState();
}

class _BodyWithSidebarState extends State<BodyWithSidebar> {
  bool _extendSidebarSmall = false;
  bool _extendSidebarLarge = true;
  @override
  Widget build(BuildContext context) {
    
    final double leftHeaderWidth = context.select((HeaderbarSizes h) => h.left);
    double minSidebarWidth = isLinux
        ?
          // (38*(gtkValue.substring(0,gtkValue.indexOf(":")).split(',').length.toDouble())+6<=84?84:38*(gtkValue.substring(0,gtkValue.indexOf(":")).split(',').length.toDouble())+6)
          leftHeaderWidth - 6 <= 84
              ? 84
              : leftHeaderWidth - 6
        : 84 + (isMacOS ? 8 : 0);
    double maxSidebarWidth = 230;
    bool smallSidebar =
        MediaQuery.sizeOf(context).width < 800 && _extendSidebarSmall;
    double sidebarWidth =
        smallSidebar ||
            (MediaQuery.sizeOf(context).width >= 800 && _extendSidebarLarge)
        ? maxSidebarWidth
        : minSidebarWidth;

    bool sidebarShouldBeExtended =
        smallSidebar ||
        (MediaQuery.sizeOf(context).width >= 800 && _extendSidebarLarge);
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastLinearToSlowEaseIn,
      tween: Tween<double>(end: sidebarWidth),
      builder: (BuildContext context, double valueSidebar, Widget? child) {
        return Stack(
          children: [
            TransparentMacOSSidebar(
              // effect: smallSidebar ? WindowEffect.windowBackground : WindowEffect.sidebar,
              child: SizedBox(width: !isLiquidGlass&&!smallSidebar&&widget.sidebarVisible ? valueSidebar : 0,height: double.infinity,)
              ),
            AnimatedPadding(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastLinearToSlowEaseIn,
              padding: widget.sidebarVisible ? EdgeInsets.fromLTRB(!(MediaQuery.sizeOf(context).width < 800) ? sidebarWidth : minSidebarWidth, 0, 0, 0) : EdgeInsets.zero,
              child: widget.body,
            ),

            Visibility(
                  visible: smallSidebar,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _extendSidebarSmall = false;
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      height: double.infinity,
                      width: double.infinity,
                      ),
                  ),
                ),

              Visibility(
                visible: widget.sidebarVisible,
                child: PlatformThemedSidebar(
                  backgroundColor: widget.SidebarColor,
                  smallSidebar: smallSidebar,
                    changeSidebarWidth: () {
                      if (MediaQuery.sizeOf(context).width<800){
                        if (!_extendSidebarSmall) {
                        setState(() {
                          _extendSidebarSmall = true;
                        });
                        }else
                        {
                        setState(() {
                          _extendSidebarSmall = false;
                        });
                        }}
                            
                        else{
                          if (!_extendSidebarLarge) {
                        setState(() {
                          _extendSidebarLarge = true;
                        });
                        }else
                        {
                        setState(() {
                          _extendSidebarLarge = false;
                        });
                    }
                    }
                    },
                    currentPage: widget.navigationWidget!.currentIndex,
                    onTap: (e){
                      widget.navigationWidget!.onTap!(e);
                      setState(() {
                        if (smallSidebar)
                        {_extendSidebarSmall = false;}
                      });
                      },
                    width: valueSidebar,
                    sidebarShouldBeExtended: sidebarShouldBeExtended,
                    routes: widget.navigationWidget!.destinations
                        .map(
                          (e) => PlatformThemedRoute(
                            name: e.label,
                            icon: Icon(e.icon),
                            filledIcon: Icon(e.icon),
                          ),
                        )
                        .toList(),
                  ),
              ),
          ],
        );
      },
    );
  }
}

class PlatformThemedScaffold extends StatelessWidget {
  const PlatformThemedScaffold({
    super.key,
    this.body,
    this.appBar,
    this.navigationWidget,
    this.navigationWidgetBackgroundColor = Colors.transparent,
  });
  final Widget? body;
  final PlatformThemedAppBar? appBar;
  final PlatformThemedNavigationWidget? navigationWidget;
  final Color navigationWidgetBackgroundColor;

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    bool isMobile = screenSize < 480;
    return PlatformInfo.isIOS26OrHigher()
        ? AdaptiveScaffold(
            appBar: appBar != null
                ? AdaptiveAppBar(title: appBar!.title)
                : null,
            body: body,
            bottomNavigationBar: AdaptiveBottomNavigationBar(
              items: navigationWidget!.destinations
                  .map(
                    (e) => AdaptiveNavigationDestination(
                      icon: 'house.fill',
                      label: e.label,
                    ),
                  )
                  .toList(),
              selectedIndex: navigationWidget!.currentIndex,
              onTap: navigationWidget!.onTap,
            ),
          )
        : Scaffold(
          backgroundColor: Colors.transparent,
            appBar: appBar != null ? AppBar(title: Text(appBar!.title)) : null,
            body: BodyWithSidebar(
              body: body,
              navigationWidget: navigationWidget, 
              sidebarVisible: !isMobile&&navigationWidget != null,
              SidebarColor: navigationWidgetBackgroundColor,
              ),
            bottomNavigationBar: isMobile
                ? NavigationBar(
                  backgroundColor: navigationWidgetBackgroundColor,
                    destinations: navigationWidget!.destinations
                        .map(
                          (e) => NavigationDestination(
                            icon: Icon(e.icon),
                            label: e.label,
                          ),
                        )
                        .toList(),
                    selectedIndex: navigationWidget!.currentIndex,
                    onDestinationSelected: navigationWidget!.onTap,
                  )
                : null,
          );
  }
}
