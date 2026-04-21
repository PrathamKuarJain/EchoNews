import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';
import '../../core/constants.dart';

import '../admin/admin_panel.dart';
import '../ai/ai_section_page.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  int _clickCount = 0;
  DateTime? _lastClickTime;

  void _handleAdminAccess() {
    final now = DateTime.now();
    if (_lastClickTime == null || now.difference(_lastClickTime!) > const Duration(seconds: 2)) {
      _clickCount = 1;
    } else {
      _clickCount++;
    }
    _lastClickTime = now;

    if (_clickCount >= 5) {
      _clickCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanel()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: _handleAdminAccess,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.eco, color: AppColors.primary, size: 28),
              SizedBox(width: 8),
              Text('Echo News', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AISectionPage()),
              );
            },
            icon: const Icon(Icons.auto_awesome, color: AppColors.primary),
            tooltip: 'AI Section',
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: AppColors.border, height: 0.5),
        ),
      ),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet. Be the first!', style: TextStyle(color: AppColors.textSecondary)));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(postsProvider),
            child: ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5, color: AppColors.border),
              itemBuilder: (context, index) {
                return PostCard(post: posts[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
