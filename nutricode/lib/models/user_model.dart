import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isVegan;
  final List<String> allergens;
  final int bannerPattern;
  final bool isNewUser;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isVegan = false,
    this.allergens = const [],
    this.bannerPattern = 0,
    this.isNewUser = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      isVegan: data['isVegan'] ?? false,
      allergens: List<String>.from(data['allergens'] ?? []),
      bannerPattern: (data['bannerPattern'] as int?) ?? 0,
      isNewUser: data['isNewUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isVegan': isVegan,
      'allergens': allergens,
      'bannerPattern': bannerPattern,
      'isNewUser': isNewUser,
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    bool? isVegan,
    List<String>? allergens,
    int? bannerPattern,
    bool? isNewUser,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      isVegan: isVegan ?? this.isVegan,
      allergens: allergens ?? this.allergens,
      bannerPattern: bannerPattern ?? this.bannerPattern,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}
