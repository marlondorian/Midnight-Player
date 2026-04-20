import 'package:flutter/material.dart';

class LiquidGlassAttemp extends StatefulWidget {
  const LiquidGlassAttemp({super.key, this.child});
  final Widget? child;
  @override
  State<LiquidGlassAttemp> createState() => _LiquidGlassAttempState();
}

class _LiquidGlassAttempState extends State<LiquidGlassAttemp> {
  @override
  Widget build(BuildContext context) {
    double radius = 80;
    double padding = 4;
    return Stack(
      alignment: .center,
      children: [
        widget.child!,

    //     LiquidGlassLayer(
    //           settings: const LiquidGlassSettings(
    //             chromaticAberration: 1,
    //             thickness: 10,
    //             blur: 1,
    //             glassColor: Color(0x33FFFFFF),
    //           ),
    //           child: LiquidGlass(
    //             shape: LiquidRoundedSuperellipse(
    //               borderRadius: 50,
    //             ),
    //             child: Container(
    //               width: radius * 2,
    //               height: radius * 2,
    //               padding: EdgeInsets.all(padding),
    //               decoration: BoxDecoration(
    //                 color: Colors.transparent,
    //                 borderRadius: BorderRadius.circular(radius),
    //               ),
    //             ),
    //   ),
    // ),
      ],
    );
  }
}