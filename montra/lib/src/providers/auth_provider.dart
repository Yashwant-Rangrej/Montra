import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final appLockEnabledProvider = StateNotifierProvider<AppLockNotifier, bool>((ref) {
  return AppLockNotifier(ref.watch(secureStorageProvider));
});

final onboardingCompletedProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier(ref.watch(secureStorageProvider));
});

class AppLockNotifier extends StateNotifier<bool> {
  final FlutterSecureStorage _storage;
  static const _key = 'app_lock_enabled';

  AppLockNotifier(this._storage) : super(false) {
    _init();
  }

  Future<void> _init() async {
    final value = await _storage.read(key: _key);
    state = value == 'true';
  }

  Future<void> toggle(bool value) async {
    try {
      await _storage.write(key: _key, value: value.toString());
    } catch (_) {}
    state = value;
  }
}

class OnboardingNotifier extends StateNotifier<bool> {
  final FlutterSecureStorage _storage;
  static const _key = 'onboarding_completed';

  OnboardingNotifier(this._storage) : super(false) {
    _init();
  }

  Future<void> _init() async {
    final value = await _storage.read(key: _key);
    state = value == 'true';
  }

  Future<void> complete() async {
    try {
      await _storage.write(key: _key, value: 'true');
    } catch (_) {}
    state = true;
  }
}

// Global state indicating if app is unlocked for this session
final authStateProvider = StateProvider<bool>((ref) => false);
