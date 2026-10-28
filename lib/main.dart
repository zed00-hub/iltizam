import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/habits/data/local_storage_service.dart';
import 'features/habits/presentation/providers/habit_providers.dart';
import 'features/habits/presentation/screens/onboarding_screen.dart';
import 'features/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline-first Local Storage Service
  final storageService = await LocalStorageService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const EltizamApp(),
    ),
  );
}

class EltizamApp extends ConsumerWidget {
  const EltizamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return MaterialApp(
      title: 'التـزام - دبابة الالتزام',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default OLED dark luxury aesthetic

      // Arabic RTL Configuration
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // First time users see Onboarding; returning users enter directly
      home: profile.isOnboardingCompleted
          ? const MainNavigationScreen()
          : const OnboardingScreen(),
    );
  }
}
