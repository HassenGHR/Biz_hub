import 'package:biz_hub/models/resume.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final int reputation;
  final List<String> contributions;
  final List<String> savedCompanies;
  final List<ResumeData> savedResumes;
  final DateTime createdAt;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.photoUrl,
      required this.reputation,
      required this.contributions,
      required this.savedCompanies,
      required this.savedResumes,
      required this.createdAt});

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return User(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        photoUrl: data['photoUrl'] ?? '',
        reputation: data['reputation'] ?? 0,
        contributions: List<String>.from(data['contributions'] ?? []),
        savedCompanies: List<String>.from(data['savedCompanies'] ?? []),
        savedResumes: List<ResumeData>.from(data['savedResumes'] ?? []),
        createdAt: data['createdAt'] ?? DateTime.now());
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'reputation': reputation,
      'contributions': contributions,
      'savedCompanies': savedCompanies,
      'savedResumes': savedResumes,
      'createdAt': createdAt
    };
  }
}
