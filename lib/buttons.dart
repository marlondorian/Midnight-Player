import 'dart:io' show Platform;
import 'package:flutter/material.dart';


bool isWindows = true;
bool isLinux = Platform.isLinux;
bool isMacOS = Platform.isMacOS;
bool isAndroid = Platform.isAndroid;
bool isIOS = Platform.isIOS;


class SidebarCtrls extends StatefulWidget {
  const SidebarCtrls({
    super.key,
    this.text = '',
    this.extendedSidebar = true,
    required this.pageController,
    this.icon = const SizedBox(width: 0,height: 0,),
    this.filledIcon = const SizedBox(width: 0,height: 0,),
    required this.page,
    required this.currentPage,
    this.iconWidth = 30
  
  });
  final PageController pageController;
  final Widget icon;
  final Widget filledIcon;
  final int page;
  final int currentPage;
  final String text;
  final bool extendedSidebar;
  final double iconWidth;

  @override
  State<SidebarCtrls> createState() => _SidebarCtrlsState();
}

class _SidebarCtrlsState extends State<SidebarCtrls> {
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment(-1, 0),
      children: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: MaterialButton(
            mouseCursor: SystemMouseCursors.basic,
            onPressed: (){
              print(MediaQuery.sizeOf(context).width);
              print(widget.currentPage);
              widget.pageController.jumpToPage(widget.page);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)
            ),
            elevation:0,
            highlightElevation: 0,
            focusElevation: 0,
            splashColor: const Color.fromARGB(23, 130, 130, 130),
            height: 43,
            hoverElevation: 0,
            minWidth: 240,
            child: AnimatedContainer(
              alignment: Alignment(0, 0),
              duration: Duration(milliseconds: 200),
              child: widget.extendedSidebar
              ?SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: SizedBox(
                        height: widget.iconWidth,
                        width: widget.iconWidth,
                        child: widget.currentPage==widget.page ?widget.filledIcon :widget.icon),
                    ),
                    Text(widget.text),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: SizedBox(
                        height: widget.iconWidth,
                        width: widget.iconWidth,
                        child: SizedBox()),
                    ),
                  ],
                ),
              )
              :Padding(padding:EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    SizedBox(
                      width: widget.iconWidth,
                      child: widget.currentPage==widget.page ?widget.filledIcon :widget.icon),
                  ],
                ),
              ),
            ),
            color:widget.currentPage==widget.page ?const Color.fromARGB(35, 130, 130, 130) :const Color.fromARGB(0, 130, 130, 130) ,
          ),
        ),
        AnimatedContainer(
          curve: Curves.easeInExpo,
          margin: EdgeInsets.only(left: 2,top: widget.currentPage>widget.page ?15 :0,bottom:  widget.currentPage<widget.page ?15 :0),
          height: widget.currentPage==widget.page ?16:24,
          width: 3,
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color:isWindows ?widget.currentPage==widget.page ?Colors.green :const Color.fromARGB(0, 34, 255, 0) :const Color.fromARGB(0, 130, 130, 130),
          ),
          
        )
      ],
    );
  }
}