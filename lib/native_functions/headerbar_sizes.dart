import 'package:flutter/foundation.dart';

class HeaderbarSizes extends ChangeNotifier {
  double _left = 84.0;
  double _right = 0.0;

  double get left => _left;
  double get right => _right;

  void setSizes(double left, double right) {
    if (_left != left || _right != right) {
      _left = left;
      _right = right;
      notifyListeners();
    }
  }
}
