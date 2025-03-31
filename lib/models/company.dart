import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String id;
  final String name;
  final String? email;
  final String? description;
  final String category;
  final String address;
  final String phone;
  final String? website;
  final String imageUrl;
  final GeoPoint? location;
  final int thumbsUp;
  final double ratings;
  final int thumbsDown;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String lastUpdatedBy;

  Company({
    required this.id,
    required this.name,
    this.email,
    this.description,
    required this.category,
    required this.address,
    required this.phone,
    required this.ratings,
    this.website,
    required this.imageUrl,
    this.location,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.lastUpdatedBy,
  });

  // Create from Firestore document
  factory Company.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return Company(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] as String?,
      description: data['description'] as String?,
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      ratings: (data['ratings'] as num?)?.toDouble() ?? 0.0,
      website: data['website'] as String?,
      imageUrl: data['imageUrl'] ?? '',
      location: data['location'] as GeoPoint?,
      thumbsUp: data['thumbsUp'] ?? 0,
      thumbsDown: data['thumbsDown'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
      lastUpdatedBy: data['lastUpdatedBy'] ?? '',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'description': description,
      'phone': phone,
      'website': website,
      'email': email,
      'ratings': ratings,
      'imageUrl': imageUrl,
      'location': location,
      'thumbsUp': thumbsUp,
      'thumbsDown': thumbsDown,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'lastUpdatedBy': lastUpdatedBy,
    };
  }
}
