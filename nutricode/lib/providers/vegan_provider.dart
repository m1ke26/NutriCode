import 'package:flutter/material.dart';

class VeganProvider extends ChangeNotifier {
  static final VeganProvider instance = VeganProvider._();
  VeganProvider._();

  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  void toggle() {
    _isEnabled = !_isEnabled;
    notifyListeners();
  }
}
