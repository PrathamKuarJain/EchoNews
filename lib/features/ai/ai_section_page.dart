import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../post/add_post_page.dart';

class AISectionPage extends StatelessWidget {
  const AISectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'EchoNews AI Hub',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.background,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_awesome,
                    size: 80,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                    'AI-Powered News Experience',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Our platform uses advanced Artificial Intelligence to ensure every post is safe, correctly sorted, and verified.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  _buildFeatureItem(
                    icon: Icons.security_outlined,
                    title: 'Smart Safety Filter',
                    description: 'Every post is scanned for toxicity, insults, and threats to keep our community healthy.',
                    color: Colors.teal,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _buildFeatureItem(
                    icon: Icons.category_outlined,
                    title: 'Auto Categorization',
                    description: 'AI automatically tags your news into categories like Tech, Politics, or Science for better reach.',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _buildFeatureItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Truth Verification',
                    description: 'Advanced algorithms check the authenticity of news to protect users from misinformation.',
                    color: Colors.indigoAccent,
                  ),

                  const SizedBox(height: 60),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => const AddPostPage())
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text(
                        'Post with AI Now',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
