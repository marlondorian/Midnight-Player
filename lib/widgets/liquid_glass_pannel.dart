import 'dart:math';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class LiquidGlassPannel extends StatefulWidget {
  const LiquidGlassPannel({
    super.key,
    this.child,
    this.borderRadius = 20,
    this.borderWidth = 1,
    this.roundedCornerMode = "continuous",
    this.backgroundColor,
    this.blurred = true,
    this.continuousBorder = false,
    this.visible = true,
    this.borderColor,
    this.spreadBlur = false,

  });
  final Widget? child;
  final double borderRadius;
  final double borderWidth;
  final String roundedCornerMode;
  final Color? backgroundColor;
  final bool blurred;
  final bool continuousBorder;
  final bool visible;
  final Color? borderColor;
  final bool spreadBlur;
  @override
  State<LiquidGlassPannel> createState() => _LiquidGlassPannelState();
}

class _LiquidGlassPannelState extends State<LiquidGlassPannel>
    with WindowListener {
  bool isFocused = true;
  @override
  void initState() {
    super.initState();
    print("object");
    windowManager.addListener(this); // Register the listener
  }

  @override
  void dispose() {
    windowManager.removeListener(this); // Clean up
    super.dispose();
  }

  @override
  void onWindowFocus() async {
    // Intercept close attempt to show a confirmation dialog
    isFocused = await windowManager.isFocused();
    setState(() {});
  }

  @override
  void onWindowBlur() async {
    // Intercept blur change to update button appearance
    isFocused = await windowManager.isFocused();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ShapeBorder roundedShape = widget.roundedCornerMode == "continuous"
        ? RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          )
        : widget.roundedCornerMode == "circle"
        ? CircleBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          );

    Color focusedColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(150, 51, 51, 51)
        : const Color.fromARGB(112, 218, 218, 218);
    Color macosButtonBackgroundColor =
        widget.backgroundColor ?? (Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(109, 24, 24, 24)
        : const Color.fromARGB(163, 247, 247, 247));
    Color macosButtonBorderColor =
        widget.borderColor ?? (Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(30, 153, 153, 153)
        : const Color.fromARGB(219, 255, 255, 255));

    return widget.visible ? LiquidGlassAttempt(
        spreadBlur: widget.spreadBlur,
        isFocused: isFocused,
        blurred: widget.blurred,
        roundedCornerMode: widget.roundedCornerMode,
        borderRadius: widget.borderRadius,
        child: Container(
      decoration: ShapeDecoration(
        shape: roundedShape,

        // borderRadius: BorderRadius.circular(widget.borderRadius),
        color: isFocused ? Colors.transparent : focusedColor,
        shadows: [
          BoxShadow(
            color: Colors.black.withAlpha(isFocused ? 30 : 0),
            blurRadius: 25,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(shape: roundedShape),
            child: Container(
              padding: EdgeInsets.all(widget.borderWidth),
              decoration: BoxDecoration(
                // border: Border(top: BorderSide(color: _macosButtonBorderColor),bottom: BorderSide(color: _macosButtonBorderColor)),
        
                // borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  stops: Theme.of(context).brightness == Brightness.dark && !widget.continuousBorder?[
                    0.0,
                    0.45,
                    0.55,
                    1.0
                  ]:
                  [
                    0,1

                  ]
                  
                  ,
                  transform: GradientRotation(pi / 2),
                  colors: Theme.of(context).brightness == Brightness.dark && !widget.continuousBorder
                            ? isFocused 
                              ? [
                                macosButtonBorderColor,
                                // macosButtonBorderColor.withAlpha(
                                //   (macosButtonBorderColor.a * 255 / 2).toInt(),
                                // ),
                                // macosButtonBorderColor.withAlpha(
                                //   (macosButtonBorderColor.a * 255 / 3).toInt(),
                                // ),
                                // macosButtonBackgroundColor.withAlpha(
                                //   (macosButtonBorderColor.a * 255 / 5).toInt(),
                                // ),
                                macosButtonBackgroundColor.withAlpha(80),
                                macosButtonBackgroundColor.withAlpha(80),
                                // macosButtonBackgroundColor.withAlpha(
                                //   (macosButtonBorderColor.a * 255 / 5).toInt(),
                                // ),
                                // macosButtonBorderColor.withAlpha(
                                //   (macosButtonBorderColor.a * 255 / 3).toInt(),
                                // ),
                                // macosButtonBorderColor.withAlpha(
                                //   (macosButtonBorderColor.a * 255 / 2).toInt(),
                                // ),
                                macosButtonBorderColor,
                              ]
                              :[Colors.transparent, Colors.transparent,Colors.transparent, Colors.transparent

                              ]
                              

                            :isFocused ? [macosButtonBorderColor, macosButtonBorderColor]
                      : [Colors.transparent, Colors.transparent],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  shape: widget.roundedCornerMode == "continuous"
                      ? RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius - widget.borderWidth,
                          ),
                        )
                      : widget.roundedCornerMode == "circle"
                      ? CircleBorder()
                      : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius - widget.borderWidth,
                          ),
                        ),
                ),
                child: BackdropFilter(
                  filter: .blur(sigmaX: 0, sigmaY: 0),
                  blendMode: BlendMode.src,
                  child: Container(
                    color:isFocused
                              ? macosButtonBackgroundColor
                              : Colors.transparent,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    )
    : SizedBox(child: widget.child,)
  ;
  
  }
}



class LiquidGlassAttempt extends StatelessWidget {
  const LiquidGlassAttempt({
    super.key , 
    required this.child, 
    required this.roundedCornerMode,
    this.borderRadius = 20,
    this.blurred = true,
    this.isFocused = true,
    this.spreadBlur = false,
  });
  final Widget child;
  final String roundedCornerMode;
  final double borderRadius;
  final bool blurred;
  final bool isFocused;
  final bool spreadBlur;

  @override
  Widget build(BuildContext context) {

    double margin = 8;

    return Stack(
      children: [
        Visibility(
          visible: blurred,
          child: Positioned.fill(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.transparent,
                shape: roundedCornerMode == "continuous"
                    ? RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      )
                    : roundedCornerMode == "circle"
                    ? CircleBorder()
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
              ),
              child: BackdropFilter(
                filter: .blur(sigmaX: 30, sigmaY: 30),
                
                child:  Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: roundedCornerMode == "continuous"
                        ? RoundedSuperellipseBorder(
                            borderRadius: BorderRadius.circular(borderRadius-margin),
                          )
                        : roundedCornerMode == "circle"
                        ? CircleBorder()
                        : RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius-margin),
                          ),),
                  margin: EdgeInsets.all(margin),
                    child:BackdropFilter(
                      blendMode: BlendMode.src,
                      filter: .blur(sigmaX: 0, sigmaY: 0),
                      child: ColoredBox(
                      color: const Color.fromARGB(0, 33, 149, 243)
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        Visibility(
          visible: blurred,
          child: Positioned.fill(
            child: Container(
              margin: EdgeInsets.all(1),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.transparent,
                shape: roundedCornerMode == "continuous"
                    ? RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      )
                    : roundedCornerMode == "circle"
                    ? CircleBorder()
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
              ),
              child: BackdropFilter(
                filter: .blur(sigmaX: 9, sigmaY: 9),
                blendMode: BlendMode.src,
                child:  Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: roundedCornerMode == "continuous"
                        ? RoundedSuperellipseBorder(
                            borderRadius: BorderRadius.circular(borderRadius-margin-margin),
                          )
                        : roundedCornerMode == "circle"
                        ? CircleBorder()
                        : RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius-margin),
                          ),),
                  margin: EdgeInsets.all(margin+margin),
                    child:BackdropFilter(
                      filter: .blur(sigmaX: 0, sigmaY: 0),
                      child: ColoredBox(
                      color: const Color.fromARGB(0, 33, 149, 243)
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),


        
        Visibility(
          visible: isFocused&&spreadBlur,
          child:  Positioned.fill(
              child:Opacity(
                opacity: 0.4,
                child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  shape: roundedCornerMode == "continuous"
                      ? RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        )
                      : roundedCornerMode == "circle"
                      ? CircleBorder()
                      : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                ),
            child: BackdropFilter(
                filter: .blur(sigmaX: 100, sigmaY: 100),
                child: SizedBox(),
                ),
              ),
            ),
          ),
        ),

        Container(
            clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.transparent,
                shape: roundedCornerMode == "continuous"
                    ? RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      )
                    : roundedCornerMode == "circle"
                    ? CircleBorder()
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
              ),
          child: BackdropFilter(
              filter: .blur(sigmaX: blurred? 4 : 0, sigmaY: blurred? 4 : 0),
              
              child: child),),


      
      
      ],
    );
  }
}