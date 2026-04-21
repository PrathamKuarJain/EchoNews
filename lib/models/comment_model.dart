import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String uid;
  final String username;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.commentId,
    required this.uid,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'uid': uid,
      'username': username,
      'text': text,
      'createdAt': createdAt,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
