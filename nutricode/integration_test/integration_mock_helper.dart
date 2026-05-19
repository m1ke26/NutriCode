import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NutriCode/services/auth_service.dart';
import 'package:NutriCode/providers/allergen_provider.dart';
import 'package:NutriCode/providers/vegan_provider.dart';
import 'package:NutriCode/providers/history_provider.dart';
import 'package:NutriCode/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:NutriCode/models/scan_history_entry.dart';

class MockAuthService implements AuthService {
  @override
  User? get currentUser => null;
  @override
  Stream<User?> get userStateChanges => Stream.value(null);
  @override
  Future<UserModel?> getUserData() async => UserModel(
        uid: 'test_uid',
        email: 'test@example.com',
        name: 'Test User',
        isVegan: false,
        allergens: [],
      );
  @override
  Future<void> signOut() async {}
  @override
  Future<void> updateProfile({String? name, String? photoUrl, bool? isVegan, List<String>? allergens}) async {}
  @override
  Future<String> uploadProfilePicture(dynamic file) async => '';
  @override
  Future<UserCredential?> signIn({required String emailOrUsername, required String password}) async => null;
  @override
  Future<UserCredential?> signInWithGoogle() async => null;
  @override
  Future<UserCredential?> signUp({required String email, required String password, required String name}) async => null;
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  Future<void> resendVerificationEmail() async {}
  @override
  Future<bool> isEmailVerified() async => true;
  @override
  Future<void> addScanToHistory({
    required String barcode,
    String? name,
    String? imageUrl,
    String? brand,
  }) async {}
  @override
  Future<void> clearScanHistory() async {}
  @override
  Future<List<ScanHistoryEntry>> getScanHistory() async => [];
}

Widget createTestableWidget(Widget child, {MockAuthService? authService, AllergenProvider? allergenProvider, VeganProvider? veganProvider, HistoryProvider? historyProvider}) {
  final mockAuth = authService ?? MockAuthService();
  return MultiProvider(
    providers: [
      Provider<AuthService>.value(value: mockAuth),
      ChangeNotifierProvider(create: (_) => allergenProvider ?? AllergenProvider(mockAuth)),
      ChangeNotifierProvider(create: (_) => veganProvider ?? VeganProvider(mockAuth)),
      ChangeNotifierProvider(create: (_) => historyProvider ?? HistoryProvider(mockAuth)),
    ],
    child: MaterialApp(home: child),
  );
}
