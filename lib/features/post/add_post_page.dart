import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/providers.dart';
import '../../models/post_model.dart';
import '../../models/app_settings.dart';
import '../../core/constants.dart';

class AddPostPage extends ConsumerStatefulWidget {
  final VoidCallback? onPostSuccess;

  const AddPostPage({super.key, this.onPostSuccess});

  @override
  ConsumerState<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends ConsumerState<AddPostPage> {
  final _textController = TextEditingController();
  XFile? _imageFile;
  bool _isLoading = false;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateWordCount);
  }

  void _updateWordCount() {
    final text = _textController.text.trim();
    setState(() {
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  String _loadingMessage = '';

  void _createPost() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      Fluttertoast.showToast(msg: 'Post content cannot be empty');
      return;
    }

    final words = text.split(RegExp(r'\s+'));
    final wordLimit = 500;
    if (words.length > wordLimit) {
      Fluttertoast.showToast(msg: 'Post exceeds the $wordLimit word limit');
      return;
    }

    final user = ref.read(currentUserDataProvider).value;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Initiating AI safety checks...';
    });

    try {
      final settings = ref.read(appSettingsProvider).value ?? AppSettings();
      double? toxicityScore;
      String? category;
      double? authenticityScore;

      // 1. Toxicity Check
      setState(() => _loadingMessage = 'Scanning for toxicity...');
      final toxicityResult = await ref.read(moderationServiceProvider).analyzeToxicity(text);
      toxicityScore = toxicityResult.score;

      if (settings.usePerspectiveApi && toxicityResult.isOffensive) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Inappropriate content detected. Post blocked.',
            backgroundColor: Colors.red,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      // 2. AI Analysis (Category & Authenticity)
      setState(() => _loadingMessage = 'AI is categorizing & verifying authenticity...');
      final aiResult = await ref.read(aiServiceProvider).analyzePost(text);
      category = aiResult.category;
      authenticityScore = aiResult.authenticityScore;
      final aiReasoning = aiResult.reasoning;

      print('Post Analysis - Category: $category, Authenticity: $authenticityScore, Reasoning: $aiReasoning');

      // 3. Upload image
      String? imageUrl;
      if (_imageFile != null) {
        setState(() => _loadingMessage = 'Uploading media...');
        imageUrl = await ref.read(storageServiceProvider).uploadImage(_imageFile!, 'posts');
      }

      // 4. Create post
      setState(() => _loadingMessage = 'Publishing your post...');
      final post = PostModel(
        postId: const Uuid().v4(),
        uid: user.uid,
        username: user.username,
        name: user.name,
        text: text,
        imageUrl: imageUrl,
        authorProfileImage: user.profileImage,
        createdAt: DateTime.now(),
        toxicityScore: toxicityScore,
        category: category,
        authenticityScore: authenticityScore,
        aiReasoning: aiReasoning,
      );

      await ref.read(firestoreServiceProvider).createPost(post);

      if (mounted) {
        _textController.clear();
        setState(() => _imageFile = null);
        Fluttertoast.showToast(msg: 'Posted successfully!');
        widget.onPostSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error: ${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isLoading || _wordCount > 500 ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Post'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  maxLines: null,
                  minLines: 5,
                  decoration: const InputDecoration(
                    hintText: "What's happening?",
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                if (ref.watch(appSettingsProvider).value?.showWordCounter ?? true)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '$_wordCount / 500 words',
                        style: TextStyle(
                          color: _wordCount > 500 ? Colors.red : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: _wordCount > 500 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                if (_imageFile != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.network(_imageFile!.path, fit: BoxFit.cover, width: double.infinity, height: 300)
                            : Image.file(File(_imageFile!.path), fit: BoxFit.cover, width: double.infinity, height: 300),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () => setState(() => _imageFile = null),
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(backgroundColor: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                const Divider(),
                Row(
                  children: [
                    IconButton(
                      onPressed: _isLoading ? null : _pickImage,
                      icon: const Icon(Icons.image_outlined, color: AppColors.primary),
                    ),
                    const Text('Add image', style: TextStyle(color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _loadingMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This ensures a safe and authentic community.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
