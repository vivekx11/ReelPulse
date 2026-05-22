import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/gradient_button.dart';

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> colors;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.colors,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      emoji: '📱',
      title: 'Track Your Scrolling',
      subtitle:
          'ScrollBattle automatically counts every Reel and Short you watch — no manual input needed.',
      colors: [AppTheme.neonPurple, AppTheme.neonBlue],
    ),
    _OnboardingPage(
      emoji: '🏆',
      title: 'Compete With Friends',
      subtitle:
          'Add friends and see who scrolls the least. The winner gets bragging rights.',
      colors: [AppTheme.neonBlue, AppTheme.neonCyan],
    ),
    _OnboardingPage(
      emoji: '🌿',
      title: 'Break the Habit',
      subtitle:
          'Real-time warnings, addiction scores, and streaks help you reclaim your time.',
      colors: [AppTheme.neonCyan, AppTheme.neonGreen],
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Skip',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji in gradient circle
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: page.colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: page.colors.first.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              page.emoji,
                              style: const TextStyle(fontSize: 52),
                            ),
                          ),
                        )
                            .animate(key: ValueKey(i))
                            .scale(duration: 500.ms, curve: Curves.elasticOut),

                        const SizedBox(height: 40),

                        Text(
                          page.title,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(fontSize: 26),
                          textAlign: TextAlign.center,
                        )
                            .animate(key: ValueKey('t$i'))
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 16),

                        Text(
                          page.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                                height: 1.6,
                              ),
                          textAlign: TextAlign.center,
                        )
                            .animate(key: ValueKey('s$i'))
                            .fadeIn(duration: 400.ms, delay: 350.ms),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == i
                        ? AppTheme.neonPurple
                        : AppTheme.textMuted,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GradientButton(
                label: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                onTap: _next,
                gradient: LinearGradient(
                  colors: _pages[_currentPage].colors,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
