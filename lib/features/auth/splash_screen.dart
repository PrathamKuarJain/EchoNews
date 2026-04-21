import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'login_screen.dart';
import '../feed/home_screen.dart';
import '../../core/constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _minSplashTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _minSplashTimeElapsed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_minSplashTimeElapsed) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, size: 80, color: AppColors.primary),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      );
    }

    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: authState.when(
        data: (user) {
          if (user != null) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, size: 80, color: AppColors.primary),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
        error: (e, stack) => Center(
          child: Text('Error: $e'),
        ),
      ),
    );
  }
}
