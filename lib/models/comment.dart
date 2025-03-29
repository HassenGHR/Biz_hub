import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String id;
  String userId;
  String userName;
  String content;
  String companyId;
  String userProfileUrl;
  bool isPositive;
  DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.companyId,
    required this.userProfileUrl,
    required this.isPositive,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'companyId': companyId,
      'userProfileUrl': userProfileUrl,
      'isPositive': isPositive,
      'createdAt': createdAt,
    };
  }

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      content: data['content'] ?? '',
      companyId: data['companyId'] ?? '',
      userProfileUrl: data['userProfileUrl'] ?? '',
      isPositive: data['isPositive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
