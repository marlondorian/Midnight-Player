import 'package:flutter/material.dart';
import 'package:sharing_option/widgets/liquid_glass_pannel.dart';
import 'package:window_manager/window_manager.dart';


class PlatformThemedToolbarButton extends StatelessWidget {
  const PlatformThemedToolbarButton({super.key, this.onPressed, this.child});
   final String platform = "MacOS";
   final void Function()? onPressed;
  final Widget? child;


  @override
  Widget build(BuildContext context) {
    return switch (platform) {
      "MacOS" => TahoeToolbarButton(onPressed: onPressed, child: child),
      "Windows" => WinUiToolbarButton(onPressed: onPressed, child: child),
      "Linux" => LibadwaitaToolbarButton(onPressed: onPressed, child: child),
      _ => WinUiToolbarButton(onPressed: onPressed, child: child)
    };
  }
}


class TahoeToolbarButton extends StatefulWidget {
  const TahoeToolbarButton({super.key, this.onPressed, this.child});
  final void Function()? onPressed;
  final Widget? child;
  final double width = 36;

  @override
  State<TahoeToolbarButton> createState() => _TahoeToolbarButtonState();
}




class _TahoeToolbarButtonState extends State<TahoeToolbarButton> with WindowListener {
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

    Color focusedColor = Theme.of(context).brightness == Brightness.dark ? const Color.fromARGB(109, 45, 45, 46) : const Color.fromARGB(133, 242, 242, 242);

    return Container(
      width: widget.width,
      height: widget.width,
        decoration: BoxDecoration(
            color: isFocused ? Colors.transparent : focusedColor,
            shape: BoxShape.circle,
            boxShadow: [
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
          roundedCornerMode: "circle",
          child: SizedBox(
            width: widget.width,
            height: widget.width,
            child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).brightness == Brightness.dark ?
                       isFocused ? Colors.white : const Color.fromARGB(255, 109, 109, 111) : isFocused ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 178, 178, 178), BlendMode.srcIn), 
                    child: widget.child,),
          ),
        ),
      ),
    );
  }
}

class WinUiToolbarButton extends StatefulWidget {
  const WinUiToolbarButton({super.key, this.onPressed, this.child});
    final void Function()? onPressed;
    final Widget? child;
  @override
  State<WinUiToolbarButton> createState() => _WinUiToolbarButtonState();
}
Color hoverColor = Color.fromARGB(0, 92, 92, 92);

class _WinUiToolbarButtonState extends State<WinUiToolbarButton> {
    int hoverAlpha = 0;
  @override
  Widget build(BuildContext context) {
    Color hoverColorTemp =  Color.fromARGB(Theme.brightnessOf(context) == Brightness.dark ? hoverAlpha : (hoverAlpha / 5).toInt() , 92, 92, 92);
    return Container(
        decoration: BoxDecoration(
            color: hoverColorTemp,
            borderRadius: BorderRadius.circular(5)
        ),
      child: InkWell(
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          borderRadius: BorderRadius.circular(5),
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
              child: widget.child,
          ),
      ),
    );
  }
}


class LibadwaitaToolbarButton extends StatefulWidget {
  const LibadwaitaToolbarButton({super.key, this.onPressed, this.child});
  final void Function()? onPressed;
    final Widget? child;
  @override
  State<LibadwaitaToolbarButton> createState() => _LibadwaitaToolbarButtonState();
}

class _LibadwaitaToolbarButtonState extends State<LibadwaitaToolbarButton> with WindowListener {

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

    return InkWell(
        highlightColor: Color.fromARGB(Theme.brightnessOf(context) == Brightness.dark ? 100 : 40 , 92, 92, 92),
        hoverColor: Color.fromARGB(Theme.brightnessOf(context) == Brightness.dark ? 100 : 20 , 92, 92, 92),
        splashColor: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
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
                Theme.of(context).brightness == Brightness.dark ?
                  isFocused ? Colors.white : 
                  const Color.fromARGB(255, 149, 149, 152) : 
                  isFocused ? const Color.fromARGB(255, 0, 0, 0) : 
                  const Color.fromARGB(255, 144, 144, 146), BlendMode.srcIn), 
              child: widget.child,),
        ),
    );
  }
}

