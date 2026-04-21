import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../core/constants.dart';
import '../core/providers.dart';
import '../models/app_settings.dart';
import '../features/feed/comment_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PostCard extends ConsumerWidget {
  final PostModel post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDataProvider).value;
    final isOwner = currentUser?.uid == post.uid;
    final isLiked = currentUser != null && post.likes.contains(currentUser.uid);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: AppColors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Avatar
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: post.authorProfileImage != null ? NetworkImage(post.authorProfileImage!) : null,
            child: post.authorProfileImage == null ? Text(post.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary)) : null,
          ),
          const SizedBox(width: 12),
          // Right Column: Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Name, Username, Time, More options)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            post.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '@${post.username} • ${timeago.format(post.createdAt, locale: 'en_short')}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (isOwner)
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 20),
                          color: AppColors.background,
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final controller = TextEditingController(text: post.text);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Edit Post'),
                                  content: TextField(
                                    controller: controller,
                                    maxLines: null,
                                    decoration: const InputDecoration(hintText: 'Edit your post...'),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (controller.text.trim().isNotEmpty) {
                                          await ref.read(firestoreServiceProvider).updatePost(post.postId, controller.text.trim());
                                          if (context.mounted) Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ),
                              );
                            }
                            if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Post'),
                                  content: const Text('Are you sure you want to delete this post?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true), 
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref.read(firestoreServiceProvider).deletePost(post.postId);
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Post Text
                _ExpandableText(text: post.text),
                // Post Image (if any)
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                          backgroundColor: Colors.black,
                          leading: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        body: Center(
                          child: InteractiveViewer(
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrl!,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[900]!,
                                highlightColor: Colors.grey[800]!,
                                child: Container(color: Colors.black, width: double.infinity, height: double.infinity),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      )));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrl!,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[900]!,
                            highlightColor: Colors.grey[800]!,
                            child: Container(
                              color: Colors.black,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // AI Analysis Section
                if (post.category != null || post.toxicityScore != null || post.authenticityScore != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (post.category != null)
                          _buildAIChip(
                            context: context,
                            icon: Icons.auto_awesome,
                            label: post.category!,
                            color: AppColors.primary,
                            onTap: () => _showAIReasoning(context, 'Category: ${post.category}', post.aiReasoning),
                          ),
                        if (post.toxicityScore != null)
                          _buildAIChip(
                            context: context,
                            icon: Icons.sentiment_very_dissatisfied,
                            label: '${(post.toxicityScore! * 100).toInt()}% Toxicity',
                            color: post.toxicityScore! > 0.4 ? Colors.redAccent : Colors.teal,
                            onTap: () => _showAIReasoning(context, 'Safety Analysis', 'Toxicity score reflects potential offensive content based on security scanning.'),
                          ),
                        if (post.authenticityScore != null)
                          _buildAIChip(
                            context: context,
                            icon: post.authenticityScore! > 0.6 ? Icons.verified : Icons.warning_amber_rounded,
                            label: '${(post.authenticityScore! * 100).toInt()}% Authentic',
                            color: post.authenticityScore! > 0.7 ? Colors.indigoAccent : (post.authenticityScore! > 0.4 ? Colors.amber : Colors.deepOrange),
                            onTap: () => _showAIReasoning(context, 'Truth Verification', post.aiReasoning),
                          ),
                      ],
                    ),
                  ),
                // Interaction Bar (Love react & Comments)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Comment Button
                    if (ref.watch(appSettingsProvider).value?.showComment ?? true) ...[
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CommentScreen(postId: post.postId)),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              post.commentCount > 0 ? '${post.commentCount}' : '0',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                    // Love React Button
                    if (ref.watch(appSettingsProvider).value?.showReaction ?? true) ...[
                      InkWell(
                        onTap: () {
                          if (currentUser != null) {
                            ref.read(firestoreServiceProvider).toggleLike(post.postId, currentUser.uid);
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isLiked ? Colors.red : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              post.likes.isNotEmpty ? '${post.likes.length}' : '0',
                              style: TextStyle(
                                color: isLiked ? Colors.red : AppColors.textSecondary,
                                fontSize: 13,
                                ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                    // Share Button
                    if (ref.watch(appSettingsProvider).value?.showShare ?? true)
                      InkWell(
                        onTap: () => _sharePost(post),
                        child: const Row(
                          children: [
                            Icon(Icons.share_outlined, size: 20, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Share',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePost(PostModel post) async {
    final String shareText = "${post.text}\n\nShared via EchoNews";

    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(post.imageUrl!);
        final response = await http.get(uri).timeout(const Duration(seconds: 15));
        
        if (response.statusCode == 200) {
          final String fileName = 'echonews_${DateTime.now().millisecondsSinceEpoch}.jpg';
          
          if (kIsWeb) {
            // Web implementation: Share bytes directly using XFile.fromData
            await Share.shareXFiles(
              [
                XFile.fromData(
                  response.bodyBytes,
                  mimeType: 'image/jpeg',
                  name: fileName,
                )
              ],
              text: shareText,
            );
            return;
          } else {
            // Mobile implementation: Save to temp directory first
            final directory = await getTemporaryDirectory();
            final String imagePath = '${directory.path}/$fileName';
            
            final File imageFile = File(imagePath);
            await imageFile.writeAsBytes(response.bodyBytes, flush: true);

            if (await imageFile.exists() && await imageFile.length() > 0) {
              await Share.shareXFiles(
                [
                  XFile(
                    imagePath,
                    mimeType: 'image/jpeg',
                    name: fileName,
                  )
                ],
                text: shareText,
              );
              return;
            }
          }
        }
      } catch (e) {
        debugPrint('Error sharing image: $e');
      }
    }

    // Fallback to text sharing if image fails or doesn't exist
  await Share.share(shareText);
  }

  Widget _buildAIChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAIReasoning(BuildContext context, String title, String? reasoning) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'AI Analysis Reasoning:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reasoning ?? 'No detailed reasoning available for this post.',
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Text(
        widget.text,
        style: const TextStyle(fontSize: 15),
        maxLines: _isExpanded ? null : 5,
        overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
      ),
    );
  }
}
