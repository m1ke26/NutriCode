import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PatternProvider extends ChangeNotifier {
  final AuthService _authService;
  PatternProvider(this._authService);

  int _patternIndex = 0;
  int get patternIndex => _patternIndex;

  Future<void> loadFromFirestore() async {
    final userData = await _authService.getUserData();
    if (userData != null) {
      _patternIndex = userData.bannerPattern;
      notifyListeners();
    }
  }

  Future<void> setPattern(int index) async {
    _patternIndex = index;
    notifyListeners();
    await _authService.updateProfile(bannerPattern: index);
  }
}
