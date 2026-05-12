import 'package:cloud_firestore/cloud_firestore.dart';

class ScanHistoryEntry {
  final String id;
  final String barcode;
  final String? name;
  final String? imageUrl;
  final String? brand;
  final DateTime scannedAt;

  ScanHistoryEntry({
    required this.id,
    required this.barcode,
    this.name,
    this.imageUrl,
    this.brand,
    required this.scannedAt,
  });

  factory ScanHistoryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScanHistoryEntry(
      id: doc.id,
      barcode: data['barcode'] ?? '',
      name: data['name'],
      imageUrl: data['imageUrl'],
      brand: data['brand'],
      scannedAt: (data['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'barcode': barcode,
        'name': name,
        'imageUrl': imageUrl,
        'brand': brand,
        'scannedAt': FieldValue.serverTimestamp(),
      };
}
