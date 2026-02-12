import 'package:flutter/material.dart';

import '../screens/card_analysis_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/landing_screen.dart';
import '../screens/my_page_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/report_screen.dart';
import '../widgets/page_background.dart';
import 'app_screen.dart';
import 'app_state.dart';
import 'app_theme.dart';

class SavvyApp extends StatelessWidget {
  const SavvyApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savvy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      home: AnimatedBuilder(
        animation: appState,
        builder: (BuildContext context, Widget? child) {
          if (!appState.isInitialized) {
            return const Scaffold(
              body: PageBackground(
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          switch (appState.currentScreen) {
            case AppScreen.landing:
              return LandingScreen(appState: appState);
            case AppScreen.onboarding:
              return OnboardingScreen(appState: appState);
            case AppScreen.dashboard:
              return DashboardScreen(appState: appState);
            case AppScreen.cardAnalysis:
              return CardAnalysisScreen(appState: appState);
            case AppScreen.report:
              return ReportScreen(appState: appState);
            case AppScreen.myPage:
              return MyPageScreen(appState: appState);
          }
        },
      ),
    );
  }
}
