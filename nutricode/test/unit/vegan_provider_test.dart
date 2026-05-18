import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/providers/vegan_provider.dart';
import 'package:NutriCode/models/user_model.dart';
import '../mock_helper.dart';

class LocalMockAuthService extends MockAuthService {
  UserModel? mockUser;
  bool updateProfileCalled = false;
  bool? lastIsVeganUpdate;

  @override
  Future<UserModel?> getUserData() async => mockUser;

  @override
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    bool? isVegan,
    List<String>? allergens,
  }) async {
    updateProfileCalled = true;
    lastIsVeganUpdate = isVegan;
    if (mockUser != null && isVegan != null) {
      mockUser = UserModel(
        uid: mockUser!.uid,
        email: mockUser!.email,
        name: mockUser!.name,
        photoUrl: mockUser!.photoUrl,
        isVegan: isVegan,
        allergens: mockUser!.allergens,
      );
    }
  }
}

void main() {
  group('VeganProvider Unit Tests', () {
    late LocalMockAuthService mockAuth;
    late VeganProvider provider;

    setUp(() {
      mockAuth = LocalMockAuthService();
      provider = VeganProvider(mockAuth);
    });

    test('initializes with isEnabled as false', () {
      expect(provider.isEnabled, isFalse);
    });

    test('loadFromFirestore sets isEnabled to true if user is vegan', () async {
      mockAuth.mockUser = UserModel(
        uid: '123',
        email: 'test@example.com',
        name: 'Test',
        isVegan: true,
        allergens: [],
      );

      await provider.loadFromFirestore();

      expect(provider.isEnabled, isTrue);
    });

    test('loadFromFirestore keeps isEnabled false if user is not vegan', () async {
      mockAuth.mockUser = UserModel(
        uid: '123',
        email: 'test@example.com',
        name: 'Test',
        isVegan: false,
        allergens: [],
      );

      await provider.loadFromFirestore();

      expect(provider.isEnabled, isFalse);
    });

    test('toggle inverts status, saves to firestore and notifies listeners', () async {
      bool listenerNotified = false;
      provider.addListener(() {
        listenerNotified = true;
      });

      expect(provider.isEnabled, isFalse);

      provider.toggle();

      expect(provider.isEnabled, isTrue);
      expect(listenerNotified, isTrue);
      expect(mockAuth.updateProfileCalled, isTrue);
      expect(mockAuth.lastIsVeganUpdate, isTrue);

      listenerNotified = false;
      provider.toggle();

      expect(provider.isEnabled, isFalse);
      expect(listenerNotified, isTrue);
      expect(mockAuth.lastIsVeganUpdate, isFalse);
    });
  });
}
