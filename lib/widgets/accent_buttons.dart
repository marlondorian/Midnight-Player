import 'package:flutter/material.dart';
import 'package:sharing_option/widgets/liquid_glass_pannel.dart';
import 'package:window_manager/window_manager.dart';


class PlatformThemedAccentButton extends StatelessWidget {
  const PlatformThemedAccentButton({super.key, this.onPressed, this.child, this.backgroundColor});
   final String platform = "MacOS";
   final void Function()? onPressed;
  final Widget? child;
  final Color? backgroundColor;


  @override
  Widget build(BuildContext context) {
    return switch (platform) {
      "MacOS" => TahoeAccentButton(onPressed: onPressed, backgroundColor: backgroundColor, child: child),
      "Windows" => WinUiAccentButton(onPressed: onPressed, backgroundColor: backgroundColor, child: child),
      "Linux" => LibadwaitaAccentButton(onPressed: onPressed, backgroundColor: backgroundColor, child: child),
      _ => WinUiAccentButton(onPressed: onPressed, backgroundColor: backgroundColor, child: child)
    };
  }
}


class TahoeAccentButton extends StatefulWidget {
  const TahoeAccentButton({super.key, this.onPressed, this.child, this.backgroundColor});
  final void Function()? onPressed;
  final Widget? child;
  final double width = 36;
  final Color? backgroundColor;

  @override
  State<TahoeAccentButton> createState() => _TahoeAccentButtonState();
}

class _TahoeAccentButtonState extends State<TahoeAccentButton> with WindowListener {
    bool isFocused = true;
    @override
  void initState() {
    super.initState();
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
    setState(() {
      
    });
  }
  @override
  void onWindowBlur() async {
    // Intercept blur change to update button appearance
    isFocused = await windowManager.isFocused();
    setState(() {
      
    });
  }

    
  @override
  Widget build(BuildContext context) {
    Color buttonBackgroundColor = widget.backgroundColor ?? Theme.of(context).colorScheme.primary;
    Color focusedColor = Theme.of(context).brightness == Brightness.dark ? const Color.fromARGB(255, 70, 71, 72) : const Color.fromARGB(255, 216, 216, 216);

    return Container(
        decoration: ShapeDecoration(
            color: isFocused ? buttonBackgroundColor : focusedColor,
            shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(18)),
            shadows: [
          BoxShadow(
            color: Colors.black.withAlpha(isFocused ? 90 : 0),
            blurRadius: 30,
            offset: const Offset(0, 12),
          )
        ]),
      child: InkWell(
        borderRadius: BorderRadius.circular(300),
          onTap: () {
              widget.onPressed?.call();
          },
          
        child: LiquidGlassPannel(
          blurred: false,
          borderRadius: 18,
          backgroundColor: Colors.transparent,
          roundedCornerMode: "continuous",
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      ((buttonBackgroundColor.r) + (buttonBackgroundColor.g) + (buttonBackgroundColor.b) ) / 3 > 0.5 ?
                         Colors.black : Colors.white, BlendMode.srcIn), 
                    child: widget.child,),
          ),
        ),
      ),
    );
  }
}

class WinUiAccentButton extends StatefulWidget {
  const WinUiAccentButton({super.key, this.onPressed, this.child, this.backgroundColor});
    final void Function()? onPressed;
    final Widget? child;
    final Color? backgroundColor;
  @override
  State<WinUiAccentButton> createState() => _WinUiAccentButtonState();
}

class _WinUiAccentButtonState extends State<WinUiAccentButton> {
    int hoverAlpha = 0;
  @override
  Widget build(BuildContext context) {
    Color buttonBackgroundColor = widget.backgroundColor ?? Theme.of(context).colorScheme.primary;
    Color hoverColorTemp =  Color.fromARGB(Theme.brightnessOf(context) == Brightness.dark ? hoverAlpha : (hoverAlpha / 5).toInt() , 92, 92, 92);
    double borderRadius = 5;
    return Container(
        decoration: BoxDecoration(
            color: buttonBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius)
        ),
      child: Container(
          decoration: BoxDecoration(
              color: hoverColorTemp,
              borderRadius: BorderRadius.circular(borderRadius)
          ),
        child: InkWell(
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            onHover: (value) {
                setState(() {
                    hoverAlpha = value ? 110 : 0;
                });
            },
            onTapCancel: () {
                setState(() {
                    hoverAlpha = 0;
                });
            },
            onTapUp: (details)  {   
              setState(() {
                hoverAlpha = 110;
                
              });
            },
            onTapDown: (details)  { 
              setState(() {
                hoverAlpha = 70;
              });
            },
            onTap: () {
                widget.onPressed?.call();
            },
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    ((buttonBackgroundColor.r) + (buttonBackgroundColor.g) + (buttonBackgroundColor.b) ) / 3 > 0.5 ?
                       Colors.black : Colors.white, BlendMode.srcIn), 
                  child: widget.child,),
            ),
        ),
      ),
    );
  }
}

class LibadwaitaAccentButton extends StatefulWidget {
  const LibadwaitaAccentButton({super.key, this.onPressed, this.child, this.backgroundColor});
  final void Function()? onPressed;
    final Widget? child;
    final Color? backgroundColor;
  @override
  State<LibadwaitaAccentButton> createState() => _LibadwaitaAccentButtonState();
}

class _LibadwaitaAccentButtonState extends State<LibadwaitaAccentButton> with WindowListener {

  int hoverAlpha = 0;
  bool isFocused = false;
    @override
  void initState() {
    super.initState();
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
    setState(() {
      
    });
  }
  @override
  void onWindowBlur() async {
    // Intercept blur change to update button appearance
    isFocused = await windowManager.isFocused();
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    Color buttonBackgroundColor = widget.backgroundColor ?? Theme.of(context).colorScheme.primary;
    Color hoverColorTemp =  Color.fromARGB(Theme.brightnessOf(context) == Brightness.dark ? hoverAlpha : (hoverAlpha / 5).toInt() , 92, 92, 92);
    double borderRadius = 10;
    return Container(
        decoration: BoxDecoration(
            color: buttonBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius)
        ),
      child: Container(
          decoration: BoxDecoration(
              color: hoverColorTemp,
              borderRadius: BorderRadius.circular(borderRadius)
          ),
        child:  InkWell(
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            onHover: (value) {
                setState(() {
                    hoverAlpha = value ? 110 : 0;
                });
            },
            onTapCancel: () {
                setState(() {
                    hoverAlpha = 0;
                });
            },
            onTapUp: (details)  {   
              setState(() {
                hoverAlpha = 110;
                
              });
            },
            onTapDown: (details)  { 
              setState(() {
                hoverAlpha = 70;
              });
            },
            onTap: () {
                widget.onPressed?.call();
            },
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    ((buttonBackgroundColor.r) + (buttonBackgroundColor.g) + (buttonBackgroundColor.b) ) / 3 > 0.5 ?
                       Colors.black : Colors.white, BlendMode.srcIn), 
                  child: widget.child,),
            ),
        ),
      ),
    );
  }
}

