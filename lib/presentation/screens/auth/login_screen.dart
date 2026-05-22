import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/common/glass_card.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (_, next) {
      next.whenData((user) {
        if (user != null) context.go('/home');
      });
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonPurple.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: Colors.white, size: 48),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 24),

                Text(
                  'SCROLLBATTLE',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [AppTheme.neonPurple, AppTheme.neonCyan],
                          ).createShader(
                              const Rect.fromLTWH(0, 0, 300, 50)),
                      ),
                ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 8),

                Text(
                  'Scroll less. Win more.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate(delay: 350.ms).fadeIn(duration: 500.ms),

                const Spacer(flex: 2),

                // Sign-in card
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to start competing',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 28),

                        // Google Sign-In button
                        SizedBox(
                          width: double.infinity,
                          child: authState.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : OutlinedButton.icon(
                                  onPressed: () => ref
                                      .read(authNotifierProvider.notifier)
                                      .signInWithGoogle(),
                                  icon: Image.asset(
                                    'assets/icons/google_logo.png',
                                    width: 22,
                                    height: 22,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.g_mobiledata,
                                            size: 22),
                                  ),
                                  label: const Text('Continue with Google'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.textPrimary,
                                    side: const BorderSide(
                                        color: AppTheme.divider),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),

                        if (authState.hasError) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Sign-in failed. Please try again.',
                            style: TextStyle(
                                color: AppTheme.neonRed, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),

                const Spacer(),

                Text(
                  'By continuing you agree to our Terms & Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ).animate(delay: 700.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
