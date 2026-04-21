import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/moderation_service.dart';
import '../services/ai_service.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/app_settings.dart';

// Services
final authServiceProvider = Provider((ref) => AuthService());
final firestoreServiceProvider = Provider((ref) => FirestoreService());
final storageServiceProvider = Provider((ref) => StorageService());
final moderationServiceProvider = Provider((ref) => ModerationService());
final aiServiceProvider = Provider((ref) => AIService());

// Auth State
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// User Data
final userProfileProvider = StreamProvider.autoDispose.family<UserModel, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).getUserStream(uid);
});

final currentUserDataProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getUserStream(user.uid);
  }
  return Stream.value(null);
});

// Posts
final postsProvider = StreamProvider.autoDispose<List<PostModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.watch(firestoreServiceProvider).getPosts();
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final userPostsProvider = StreamProvider.autoDispose.family<List<PostModel>, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).getUserPosts(uid);
});

// Admin App Settings
final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(AppSettings());
      return ref.watch(firestoreServiceProvider).getAppSettings();
    },
    loading: () => Stream.value(AppSettings()),
    error: (_, __) => Stream.value(AppSettings()),
  );
});
