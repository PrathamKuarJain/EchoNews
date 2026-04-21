import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers.dart';
import '../../models/user_model.dart';
import '../../models/app_settings.dart';
import '../../widgets/post_card.dart';
import '../../core/constants.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  bool _isSaving = false;

  void _updateProfile(UserModel user) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(firestoreServiceProvider).updateProfile(
            user.uid,
            name: _nameController.text.trim(),
          );
      setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadProfileImage(String uid) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      try {
        final imageUrl = await ref.read(storageServiceProvider).uploadImage(pickedFile, 'profiles');
        await ref.read(firestoreServiceProvider).updateProfile(uid, imageUrl: imageUrl);
        // Force refresh the user data provider so the new avatar shows up immediately
        ref.invalidate(currentUserDataProvider);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => ref.read(authServiceProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: AppColors.border, height: 0.5),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          final showFullProfile = ref.watch(appSettingsProvider).value?.showFullProfile ?? true;
          if (!showFullProfile) {
            return const Center(child: Text('My Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
          }

          if (!_isEditing) _nameController.text = user.name;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    Container(
                      color: AppColors.background,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar & Edit Button Row
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.background, width: 4),
                                        ),
                                        child: CircleAvatar(
                                          radius: 35,
                                          backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
                                          backgroundColor: AppColors.primary.withOpacity(0.1),
                                          child: user.profileImage == null 
                                              ? Text(user.name[0], style: const TextStyle(fontSize: 28, color: AppColors.primary)) 
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () => _pickAndUploadProfileImage(user.uid),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppColors.background, width: 2),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_isEditing)
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () => setState(() => _isEditing = false), 
                                          child: const Text('Cancel', style: TextStyle(color: AppColors.textMain)),
                                        ),
                                        ElevatedButton(
                                          onPressed: _isSaving ? null : () => _updateProfile(user),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.textMain,
                                            foregroundColor: AppColors.background,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          ),
                                          child: _isSaving 
                                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                                            : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    )
                                  else
                                    OutlinedButton(
                                      onPressed: () => setState(() => _isEditing = true),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.textMain,
                                        side: const BorderSide(color: AppColors.border),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            ),
                            // Text info
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_isEditing)
                                    TextField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        hintText: 'Name',
                                        isDense: true,
                                        border: UnderlineInputBorder(),
                                      ),
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    )
                                  else
                                    Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 2),
                                  Text('@${user.username}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 16),
                                      const SizedBox(width: 4),
                                      Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.5, color: AppColors.border),
                    // Tabs area
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text('Posts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.5, color: AppColors.border),
                  ],
                ),
              ),
              // Posts List
              ref.watch(userPostsProvider(user.uid)).when(
                    data: (posts) {
                      if (posts.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: Text('No posts yet.', style: TextStyle(color: AppColors.textSecondary))),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index.isOdd) {
                              return const Divider(height: 1, thickness: 0.5, color: AppColors.border);
                            }
                            final postIndex = index ~/ 2;
                            return PostCard(post: posts[postIndex]);
                          },
                          // We multiply by 2 and subtract 1 to account for dividers between items
                          childCount: posts.length * 2 - 1,
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
                    error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
                  ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
