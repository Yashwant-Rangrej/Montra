import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/bento_cards.dart';
import 'permissions_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final void Function(Map<String, bool> permissions)? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStepData> _steps = const [
    OnboardingStepData(
      title: "Take Control of Your Money",
      subtitle: "Montra automatically organizes your spending so you always know where your money goes.",
    ),
    OnboardingStepData(
      title: "Automatic Transaction Tracking",
      subtitle: "Montra securely detects financial SMS messages and automatically records your transactions. No need to enter every expense manually.",
      privacyPill: "Everything stays on your device.",
    ),
    OnboardingStepData(
      title: "Build Better Financial Habits",
      subtitle: "Track budgets, monitor spending, discover insights, and achieve your savings goals with beautiful reports.",
    ),
    OnboardingStepData(
      title: "Your Data Belongs to You",
      subtitle: "Montra works offline, stores your financial data securely on your device, and never uploads your SMS or transactions.",
    ),
  ];

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PermissionsScreen(),
        ),
      );
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PermissionsScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return OnboardingStepView(
                    stepIndex: index,
                    data: _steps[index],
                  );
                },
              ),
            ),

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: AppTheme.background,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  _currentPage > 0
                      ? TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Back', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                        )
                      : const SizedBox(width: 60),

                  // Dots Indicator
                  Row(
                    children: List.generate(
                      _steps.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primary
                              : AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_currentPage == _steps.length - 1 ? 'Get Started' : 'Next'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingStepData {
  final String title;
  final String subtitle;
  final String? privacyPill;

  const OnboardingStepData({
    required this.title,
    required this.subtitle,
    this.privacyPill,
  });
}

class OnboardingStepView extends StatelessWidget {
  final int stepIndex;
  final OnboardingStepData data;

  const OnboardingStepView({
    super.key,
    required this.stepIndex,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphic Illustration according to step
          Expanded(
            child: Center(
              child: _buildGraphic(stepIndex),
            ),
          ),

          // Typography
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (data.privacyPill != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: AppTheme.secondary),
                  const SizedBox(width: 6),
                  Text(
                    data.privacyPill!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGraphic(int step) {
    switch (step) {
      case 0:
        return Image.network(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBjCrO4MSgC3N_CVHZsgEBczEMcdBaSw-vplKsVW42K7U3_FMtmGZbTwotZncXV-lMOBRRI9dtOPnaFJ5LlIImlLpUFCl2CHoaVz3q3lqmMcfaLt7pwZTitEHOaMdCNOVid8m41w6WLMAzqL-t5DlShOrbYXdUvwmdlR2jVBDUY3phS6Rl0j12pfGDzOwbsR3K6faTxf8JI3DvrO7Xy5cWa8C6iz-8voPBydqkKY4C_XDsWbyh3MQ3A',
          fit: BoxFit.contain,
          height: 260,
          errorBuilder: (context, error, stackTrace) {
             return const Icon(Icons.account_balance_wallet, size: 100, color: AppTheme.primary);
          },
        );
      case 1:
        return const AutoSmsGraphic();
      case 2:
        return const FinancialHabitsBento();
      case 3:
        return const PrivacyShieldGraphic();
      default:
        return const SizedBox.shrink();
    }
  }
}
