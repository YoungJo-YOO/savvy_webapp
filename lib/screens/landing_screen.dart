import 'package:flutter/material.dart';

import '../app/app_screen.dart';
import '../app/app_state.dart';
import '../app/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/page_background.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 26),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '연말정산 최적화 솔루션',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      '놓치던 환급금,\nSavvy가 찾아드립니다',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '복잡한 연말정산을 쉽게 확인하고\n내 상황에 맞는 공제전략을 바로 확인하세요.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      size: AppButtonSize.lg,
                      onPressed:
                          () => appState.setCurrentScreen(
                            AppScreen.onboardingStep1,
                          ),
                      child: const Text('내 환급액 확인하기'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '무료로 시작하기 · 3분이면 충분합니다',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 44),
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final cardWidth = constraints.maxWidth >= 940
                            ? (constraints.maxWidth - 32) / 3
                            : (constraints.maxWidth >= 640
                                ? (constraints.maxWidth - 16) / 2
                                : constraints.maxWidth);
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: <Widget>[
                            _FeatureCard(
                              icon: Icons.ads_click_rounded,
                              title: '맞춤 공제 추천',
                              description:
                                  '나이·급여·특수상황을 바탕으로 내게 맞는 공제 항목을 추천합니다.',
                              width: cardWidth,
                            ),
                            _FeatureCard(
                              icon: Icons.calculate_outlined,
                              title: '실시간 시뮬레이션',
                              description:
                                  '카드, 연금, 기부금 입력을 바꾸면서 환급액 변화를 바로 확인할 수 있습니다.',
                              width: cardWidth,
                            ),
                            _FeatureCard(
                              icon: Icons.trending_up,
                              title: '최대 환급 전략',
                              description:
                                  '중소기업 감면 등 여러 조건을 반영해 가능한 환급액을 계산합니다.',
                              width: cardWidth,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[AppTheme.primary, Color(0xFF42A5F5)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        child: Column(
                          children: <Widget>[
                            const Text(
                              '13월의 월급, 준비해볼까요?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '지금 시작하면 이번 시즌에 적용 가능한 공제전략을 빠르게 확인할 수 있습니다.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                            const SizedBox(height: 22),
                            AppButton(
                              variant: AppButtonVariant.secondary,
                              size: AppButtonSize.lg,
                              onPressed:
                                  () => appState.setCurrentScreen(
                                    AppScreen.onboardingStep1,
                                  ),
                              child: const Text('지금 시작하기'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.width,
  });

  final IconData icon;
  final String title;
  final String description;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
