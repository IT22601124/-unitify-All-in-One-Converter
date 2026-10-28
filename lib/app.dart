import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'core/theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/app_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';

class UnitifyApp extends StatelessWidget {
  const UnitifyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<AppState, ThemeMode>(
      (state) => state.themeMode,
    );
    final hasCompletedOnboarding = context.select<AppState, bool>(
      (state) => state.hasCompletedOnboarding,
    );
    return MaterialApp(
      title: 'Unitify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: hasCompletedOnboarding
            ? UpgradeAlert(
                key: const ValueKey('app-shell'),
                child: const AppShell(),
              )
            : const OnboardingScreen(key: ValueKey('onboarding')),
      ),
    );
  }
}
