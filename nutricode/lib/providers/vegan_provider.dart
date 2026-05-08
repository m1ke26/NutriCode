import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class VeganProvider extends ChangeNotifier {
  static final VeganProvider instance = VeganProvider._();
  VeganProvider._();

  final AuthService _authService = AuthService();

  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  // Initialize from Firestore
  Future<void> loadFromFirestore() async {
    final userData = await _authService.getUserData();
    if (userData != null) {
      _isEnabled = userData.isVegan;
      notifyListeners();
    }
  }

  void toggle() async {
    _isEnabled = !_isEnabled;
    notifyListeners();
    
    // Save to Firestore
    await _authService.updateProfile(isVegan: _isEnabled);
  }
}

