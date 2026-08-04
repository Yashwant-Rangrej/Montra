import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
    });

    final authService = ref.read(authServiceProvider);
    final isAuth = await authService.authenticateUser();
    
    if (mounted) {
      setState(() {
        _isAuthenticating = false;
      });
      if (isAuth) {
        ref.read(authStateProvider.notifier).state = true;
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 80, color: Theme.of(context).colorScheme.onPrimary),
            const SizedBox(height: 24),
            Text(
              'Montra is Locked',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 48),
            _isAuthenticating
                ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _authenticate,
                    child: const Text('Unlock'),
                  ),
          ],
        ),
      ),
    );
  }
}
