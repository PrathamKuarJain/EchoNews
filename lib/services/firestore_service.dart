import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import '../models/app_settings.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // App Settings
  Stream<AppSettings> getAppSettings() {
    return _firestore
        .collection('app_config')
        .doc('settings')
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return AppSettings.fromMap(doc.data()!);
          }
          return AppSettings(); // Return default if not exists
        });
  }

  Future<void> updateAppSettings(AppSettings settings) async {
    await _firestore
        .collection('app_config')
        .doc('settings')
        .set(settings.toMap());
  }

  // Post Methods
  Future<void> createPost(PostModel post) async {
    await _firestore.collection('posts').doc(post.postId).set(post.toMap());
  }

  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<PostModel>> getUserPosts(String uid) {
    return _firestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> updatePost(String postId, String text) async {
    await _firestore.collection('posts').doc(postId).update({'text': text});
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  Future<void> toggleLike(String postId, String uid) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final doc = await postRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      final List<String> likes = List<String>.from(data['likes'] ?? []);
      if (likes.contains(uid)) {
        likes.remove(uid);
      } else {
        likes.add(uid);
      }
      await postRef.update({'likes': likes});
    }
  }

  // Comment Methods
  Future<void> addComment(String postId, CommentModel comment) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(comment.commentId)
        .set(comment.toMap());
    
    // Increment comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
    
    // Decrement comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  // User Methods
  Future<void> updateProfile(String uid, {String? name, String? imageUrl}) async {
    Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (imageUrl != null) data['profileImage'] = imageUrl;
    
    if (data.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(data);
      
      // Update name and profile image in posts
      if (name != null || imageUrl != null) {
        final postQuery = await _firestore.collection('posts').where('uid', isEqualTo: uid).get();
        final batch = _firestore.batch();
        for (var doc in postQuery.docs) {
          final Map<String, dynamic> up = {};
          if (name != null) up['name'] = name;
          if (imageUrl != null) up['authorProfileImage'] = imageUrl;
          batch.update(doc.reference, up);
        }
        await batch.commit();
      }
    }
  }

  Stream<UserModel> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      throw Exception('User not found');
    });
  }
}
