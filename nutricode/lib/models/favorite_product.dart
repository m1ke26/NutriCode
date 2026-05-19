import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteProduct {
  final String id;
  final String barcode;
  final String? name;
  final String? imageUrl;
  final String? brand;
  final DateTime addedAt;

  FavoriteProduct({
    required this.id,
    required this.barcode,
    this.name,
    this.imageUrl,
    this.brand,
    required this.addedAt,
  });

  factory FavoriteProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteProduct(
      id: doc.id,
      barcode: data['barcode'] ?? '',
      name: data['name'],
      imageUrl: data['imageUrl'],
      brand: data['brand'],
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'barcode': barcode,
        'name': name,
        'imageUrl': imageUrl,
        'brand': brand,
        'addedAt': FieldValue.serverTimestamp(),
      };
}
