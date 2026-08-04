import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../data/repositories/notification_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skip() {
    _pageController.animateToPage(
      4,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding() {
    ref.read(onboardingCompletedProvider.notifier).complete();
    // After complete, the router redirect will automatically kick in!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Soft warm beige background
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Placeholder for symmetry
                  if (_currentPage < 4)
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildSMSPage(),
                  _buildBudgetsPage(),
                  _buildPrivacyPage(),
                  _buildPermissionsPage(),
                ],
              ),
            ),
            
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_currentPage == 4) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Continue →'),
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton.icon(
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            )
          else
            const SizedBox(width: 80),
            
          Row(
            children: List.generate(5, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: _currentPage == index ? 20 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Text(_currentPage == 3 ? 'Get Started' : 'Next →'),
          ),
        ],
      ),
    );
  }

  // --- Graphic Page Builders ---

  Widget _buildWelcomePage() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40)
                ]
              ),
              child: Center(
                child: Icon(Icons.phone_iphone, size: 100, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Take Control\nof Your Money', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Montra automatically organizes your spending so you always know where your money goes.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600, height: 1.5),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildSMSPage() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3EFE6), // Slightly darker beige circle
                    shape: BoxShape.circle,
                  ),
                ),
                Positioned(
                  top: 50,
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 12, height: 12, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text('Bank XYZ', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Payment of ₹45.00 to Starbucks\nwas successful.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 150,
                  child: Icon(Icons.arrow_downward, color: Theme.of(context).colorScheme.primary),
                ),
                Positioned(
                  bottom: 50,
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.coffee, size: 16, color: Colors.green.shade700),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Starbucks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Coffee & Snacks', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Text('-₹45.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Automatic Transaction\nTracking', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Montra securely detects financial SMS messages and automatically records your transactions. No need to enter every expense manually.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text('Everything stays on your device.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBudgetsPage() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top-right Monthly Trend
                Positioned(
                  top: 40,
                  right: 20,
                  child: Transform.rotate(
                    angle: 0.1,
                    child: Container(
                      width: 180,
                      height: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly Trend', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: 8),
                          // Placeholder for chart bars
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(width: 12, height: 30, color: Colors.blue.shade100), const SizedBox(width: 8),
                              Container(width: 12, height: 50, color: Colors.blue.shade300), const SizedBox(width: 8),
                              Container(width: 12, height: 70, color: Colors.blue.shade700),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // Center Savings
                Positioned(
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)]),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.savings, color: Colors.teal),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Savings', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                Text('₹12,450', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Target: ₹15k', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text('83%', style: TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(value: 0.83, backgroundColor: Colors.teal.shade50, valueColor: const AlwaysStoppedAnimation(Colors.teal), borderRadius: BorderRadius.circular(4)),
                      ],
                    ),
                  ),
                ),
                // Bottom-left Over Budget
                Positioned(
                  bottom: 50,
                  left: 20,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Dining', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('₹450', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: 1.0, backgroundColor: Colors.red.shade50, valueColor: const AlwaysStoppedAnimation(Colors.red), borderRadius: BorderRadius.circular(4)),
                          const SizedBox(height: 4),
                          const Center(child: Text('Over budget', style: TextStyle(fontSize: 10, color: Colors.red))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Build Better Financial\nHabits', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Track budgets, monitor spending, discover insights, and achieve your savings goals with beautiful reports.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600, height: 1.5),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildPrivacyPage() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30)],
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.shield, size: 100, color: Theme.of(context).colorScheme.primary),
                    const Icon(Icons.lock, size: 40, color: Colors.white),
                    const Positioned(bottom: 40, left: 40, child: Icon(Icons.visibility_off, size: 24, color: Colors.teal)),
                    const Positioned(top: 40, right: 40, child: Icon(Icons.description, size: 24, color: Colors.brown)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text('Your Data Belongs to You', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Montra works offline, stores your financial data securely on your device, and never uploads your SMS or transactions.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600, height: 1.5),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildPermissionsPage() {
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final isAppLockEnabled = ref.watch(appLockEnabledProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text('One Last Step', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'To automatically detect your transactions, Montra needs permission to read financial SMS messages. Your messages never leave your device and are processed completely offline.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700, height: 1.5),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildSettingsGroup(
            context,
            children: [
              _buildSwitchTile(
                context,
                title: 'SMS',
                subtitle: 'Detect bank messages',
                icon: Icons.message,
                iconColor: Colors.blue,
                value: notificationSettings.smsDetectionEnabled,
                onChanged: (val) {
                  ref.read(notificationSettingsProvider.notifier).updateSettings(notificationSettings.copyWith(smsDetectionEnabled: val));
                },
              ),
              _buildSwitchTile(
                context,
                title: 'Alerts',
                subtitle: 'Budget and summary alerts',
                icon: Icons.notifications_active,
                iconColor: Colors.teal,
                value: notificationSettings.budgetAlertsEnabled,
                onChanged: (val) {
                  ref.read(notificationSettingsProvider.notifier).updateSettings(notificationSettings.copyWith(
                    budgetAlertsEnabled: val,
                    dailySummaryEnabled: val,
                    goalRemindersEnabled: val,
                  ));
                },
              ),
              _buildSwitchTile(
                context,
                title: 'Biometrics',
                subtitle: 'Secure your data with device biometrics',
                icon: Icons.fingerprint,
                iconColor: Colors.brown,
                value: isAppLockEnabled,
                isLast: true,
                onChanged: (val) async {
                  if (val) {
                    final authService = ref.read(authServiceProvider);
                    final success = await authService.authenticateUser();
                    if (success) {
                      ref.read(appLockEnabledProvider.notifier).toggle(true);
                    }
                  } else {
                    ref.read(appLockEnabledProvider.notifier).toggle(false);
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Icon(Icons.security, size: 100, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
          ),
        ),
      ],
    );
  }

  // --- Utility Methods ---

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          secondary: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 76, right: 24),
            child: Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ),
      ],
    );
  }
}
