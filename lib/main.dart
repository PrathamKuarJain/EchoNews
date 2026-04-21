import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'features/auth/splash_screen.dart';
import 'core/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  if (kIsWeb) {
    // Explicitly set persistence to local storage so user stays logged in
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo News',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          background: AppColors.background,
          surface: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textMain),
          titleTextStyle: TextStyle(
            color: AppColors.textMain,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        dividerColor: AppColors.border,
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textMain),
          bodyMedium: TextStyle(color: AppColors.textMain),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
