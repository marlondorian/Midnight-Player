import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sharing_option/widgets/buttons.dart';
import 'package:sharing_option/constants/current_platform.dart';
import 'package:sharing_option/widgets/liquid_glass_pannel.dart';

class PlatformThemedRoute {
  final String name;
  final Widget icon;
  final Widget filledIcon;

  PlatformThemedRoute({
    this.name = '', 
    this.icon = const SizedBox(width: 0,height: 0,),
    this.filledIcon = const SizedBox(width: 0,height: 0,),});
}

class PlatformThemedSidebar extends StatelessWidget {
  const PlatformThemedSidebar({
    super.key,
    this.width = 250,
    this.sidebarShouldBeExtended = true,
    this.smallSidebar = false,
    this.routes = const [],
    this.homeNavigatorKey,
    this.currentPage = 0, 
    this.onTap,
    this.changeSidebarWidth,
    });
    final double width;
    final bool sidebarShouldBeExtended;
    final bool smallSidebar;
    final List<PlatformThemedRoute> routes;
    final GlobalKey<NavigatorState>? homeNavigatorKey;
    final int currentPage;
    final void Function(int)? onTap;
    final void Function()? changeSidebarWidth;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
          width: width,
          child:LiquidGlassPannel(
            spreadBlur: true,
            blurred: smallSidebar,
            continuousBorder: true,
            borderRadius: 18,
            visible: isLiquidGlass,
            child:  Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  AnimatedContainer(
                    height: !sidebarShouldBeExtended ? 28 : 0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.fastLinearToSlowEaseIn,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                    curve: Curves.fastLinearToSlowEaseIn,
                      margin: EdgeInsets.only(bottom: 4.0),
                      constraints: BoxConstraints(
                        maxWidth: sidebarShouldBeExtended ? 34 : 200,
                      ),
                      height: 34,
                      child: MaterialButton(
                        splashColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        padding: EdgeInsets.zero,
                        child: Center(child: Icon(FluentIcons.navigation_16_regular,size: 20,)),
                        onPressed: (){
                          if(changeSidebarWidth != null){
                            changeSidebarWidth!();
                          }},
                        ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: routes.length,
                        itemBuilder: (context, index) {
                          final route = routes[index];
                          return SidebarCtrls(
                            onTap: onTap,
                            currentPage: currentPage,
                            page: index,
                            text: route.name,
                            extendedSidebar: sidebarShouldBeExtended,
                            icon: route.icon,
                            filledIcon: route.filledIcon,
                          );
                        },
                      ),
                  ),
                ],
              ),
            ),
            ),
    );
  }
}