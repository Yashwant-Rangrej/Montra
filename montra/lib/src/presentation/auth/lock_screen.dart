import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isAuthenticating = false;
  bool _hasAuthenticated = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _checkDeviceAndAuthenticate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If already authenticated or app state is unlocked, never prompt again
    if (_hasAuthenticated || ref.read(authStateProvider)) return;

    // When returning to foreground, automatically prompt mobile local authentication
    if (state == AppLifecycleState.resumed && !_isAuthenticating && mounted) {
      _authenticate();
    }
  }

  Future<void> _checkDeviceAndAuthenticate() async {
    final authService = ref.read(authServiceProvider);
    final biometrics = await authService.getAvailableBiometrics();

    if (mounted) {
      setState(() {
        _availableBiometrics = biometrics;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasAuthenticated && !ref.read(authStateProvider)) {
          _authenticate();
        }
      });
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating || _hasAuthenticated || !mounted) return;
    if (ref.read(authStateProvider)) return;

    setState(() {
      _isAuthenticating = true;
    });

    final authService = ref.read(authServiceProvider);
    final isAuth = await authService.authenticateUser(
      reason: 'Unlock Montra using your mobile screen lock or biometrics',
    );

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
      });
      if (isAuth) {
        _hasAuthenticated = true;
        // Unregister observer immediately so resumed event cannot trigger a second prompt
        WidgetsBinding.instance.removeObserver(this);
        ref.read(authStateProvider.notifier).state = true;
        final target = ref.read(routerNotifierProvider).previousLocation;
        context.go(
          target.isNotEmpty && target != '/auth' && target != '/splash'
              ? target
              : '/',
        );
      }
    }
  }

  IconData _getAuthIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face_rounded;
    }
    return Icons.fingerprint_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(color: AppTheme.background),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 12),

                  // Center Logo & Title (App Splash Screen style)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo Container
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Montra',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppTheme.onSurface,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Expense Tracking & Financial Insights',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Area: Tap to Unlock button (if cancelled/prompt closed) + Footer
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isAuthenticating && !_hasAuthenticated)
                        TextButton.icon(
                          onPressed: _authenticate,
                          icon: Icon(_getAuthIcon(), size: 20, color: AppTheme.primary),
                          label: Text(
                            'Tap to Unlock',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'Developed by Yashwant Rangrej',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.outline,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
