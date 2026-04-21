import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../feed/feed_page.dart';
import '../post/add_post_page.dart';
import '../profile/profile_page.dart';
import '../../core/constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDataProvider).value;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex == 2 ? 1 : _selectedIndex,
        children: const [
          FeedPage(),
          ProfilePage(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SizedBox(
          width: 65,
          height: 65,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddPostPage(onPostSuccess: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              })));
            },
            shape: const CircleBorder(),
            backgroundColor: AppColors.primary,
            elevation: 2,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.background,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedIndex = 0),
                icon: Icon(
                  _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                  size: 30,
                  color: _selectedIndex == 0 ? AppColors.textMain : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 48), // Space for FAB
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedIndex == 2 ? AppColors.textMain : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user?.profileImage != null ? NetworkImage(user!.profileImage!) : null,
                    child: user?.profileImage == null
                        ? Text(user?.name[0].toUpperCase() ?? 'U', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
