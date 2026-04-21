import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String> _generateUniqueUsername(String fullName) async {
    String baseUsername = fullName.split(' ').first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (baseUsername.isEmpty) baseUsername = "user";

    String username = baseUsername;
    bool isAvailable = await _checkUsernameAvailability(username);

    while (!isAvailable) {
      int randomNumber = Random().nextInt(9000) + 1000;
      username = '$baseUsername$randomNumber';
      isAvailable = await _checkUsernameAvailability(username);
    }

    return username;
  }

  Future<bool> _checkUsernameAvailability(String username) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return query.docs.isEmpty;
  }

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String username = await _generateUniqueUsername(fullName);

      UserModel userModel = UserModel(
        uid: credential.user!.uid,
        name: fullName,
        email: email,
        username: username,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(credential.user!.uid).set(userModel.toMap());

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
}
