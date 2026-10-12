import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sms_providers.dart';
import '../../data/repositories/notification_repository.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  void _finishOnboarding() {
    ref.read(onboardingCompletedProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final isAppLockEnabled = ref.watch(appLockEnabledProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'One Last Step',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'To automatically detect your transactions, Montra needs permission to read financial SMS messages. Your messages never leave your device and are processed completely offline.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Permission Cards
              _PermissionCard(
                icon: Icons.message_outlined,
                title: 'SMS',
                subtitle: 'Detect bank messages',
                value: notificationSettings.smsDetectionEnabled,
                onChanged: (val) async {
                  // FIX: Actually request the OS-level SMS permission and
                  // register the Dart callback handle so the background
                  // SmsReceiver can spin up a Flutter engine.
                  if (val) {
                    final interceptor = ref.read(smsInterceptorProvider);
                    final granted = await interceptor.requestPermissions();
                    if (granted) {
                      await interceptor.initialize();
                    }
                    ref.read(notificationSettingsProvider.notifier)
                       .updateSettings(notificationSettings.copyWith(
                         smsDetectionEnabled: granted,
                       ));
                  } else {
                    ref.read(notificationSettingsProvider.notifier)
                       .updateSettings(notificationSettings.copyWith(
                         smsDetectionEnabled: false,
                       ));
                  }
                },
              ),
              const SizedBox(height: 16),
              _PermissionCard(
                icon: Icons.notifications_none_outlined,
                title: 'Alerts',
                subtitle: 'Budget and summary alerts',
                value: notificationSettings.budgetAlertsEnabled,
                onChanged: (val) {
                  ref.read(notificationSettingsProvider.notifier)
                     .updateSettings(notificationSettings.copyWith(
                       budgetAlertsEnabled: val,
                       dailySummaryEnabled: val,
                     ));
                },
              ),
              const SizedBox(height: 16),
              _PermissionCard(
                icon: Icons.fingerprint,
                title: 'Biometrics',
                subtitle: 'Secure your data with device biometrics',
                badgeText: 'Optional',
                value: isAppLockEnabled,
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

              const SizedBox(height: 32),

              // Decorative 3D Lock Illustration
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: AppTheme.surfaceVariant,
                      child: const Center(
                        child: Icon(Icons.security, size: 64, color: AppTheme.primary),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _finishOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badgeText;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surfaceVariant.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeText!,
                          style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
