import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String uid;
  final String username;
  final String name;
  final String text;
  final String? imageUrl;
  final String? authorProfileImage;
  final DateTime createdAt;
  final int commentCount;
  final List<String> likes;
  final String? category;
  final double? toxicityScore;
  final double? authenticityScore;
  final String? aiReasoning;

  PostModel({
    required this.postId,
    required this.uid,
    required this.username,
    required this.name,
    required this.text,
    this.imageUrl,
    this.authorProfileImage,
    required this.createdAt,
    this.commentCount = 0,
    this.likes = const [],
    this.category,
    this.toxicityScore,
    this.authenticityScore,
    this.aiReasoning,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'uid': uid,
      'username': username,
      'name': name,
      'text': text,
      'imageUrl': imageUrl,
      'authorProfileImage': authorProfileImage,
      'createdAt': createdAt,
      'commentCount': commentCount,
      'likes': likes,
      'category': category,
      'toxicityScore': toxicityScore,
      'authenticityScore': authenticityScore,
      'aiReasoning': aiReasoning,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      authorProfileImage: map['authorProfileImage'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      commentCount: map['commentCount'] ?? 0,
      likes: List<String>.from(map['likes'] ?? []),
      category: map['category'],
      toxicityScore: (map['toxicityScore'] as num?)?.toDouble(),
      authenticityScore: (map['authenticityScore'] as num?)?.toDouble(),
      aiReasoning: map['aiReasoning'],
    );
  }

  PostModel copyWith({
    String? postId,
    String? uid,
    String? username,
    String? name,
    String? text,
    String? imageUrl,
    String? authorProfileImage,
    DateTime? createdAt,
    int? commentCount,
    List<String>? likes,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      uid: uid ?? this.uid,
      username: username ?? this.username,
      name: name ?? this.name,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      authorProfileImage: authorProfileImage ?? this.authorProfileImage,
      createdAt: createdAt ?? this.createdAt,
      commentCount: commentCount ?? this.commentCount,
      likes: likes ?? this.likes,
      category: category ?? this.category,
      toxicityScore: toxicityScore ?? this.toxicityScore,
      authenticityScore: authenticityScore ?? this.authenticityScore,
      aiReasoning: aiReasoning ?? this.aiReasoning,
    );
  }
}
