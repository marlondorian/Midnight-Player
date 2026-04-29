import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

bool isWindows =kIsWeb ? false : Platform.isWindows;
bool isLinux = kIsWeb ? false : Platform.isLinux;
bool isMacOS = kIsWeb ? false : Platform.isMacOS;
bool isAndroid = kIsWeb ? false : Platform.isAndroid;
bool isIOS = kIsWeb ? false : Platform.isIOS;
bool isLiquidGlass = isMacOS && (operatingSystemVersion >= 26);

double operatingSystemVersion = double.parse("${Platform.operatingSystemVersion.split(" ").elementAt(1).split(".").first}.${Platform.operatingSystemVersion.split(" ").elementAt(1).split(".").elementAt(1)}");

int currentPlatform() {
  if(isWindows) return 0;
  if(isMacOS) return 1;
  if(isLinux) return 2;
  if(isAndroid) return 3;
  if(isIOS) return 4;
  return -1;
}

