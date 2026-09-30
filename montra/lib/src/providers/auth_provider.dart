import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final appLockEnabledProvider = StateNotifierProvider<AppLockNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppLockNotifier(ref.watch(secureStorageProvider), prefs);
});

final onboardingCompletedProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(ref.watch(secureStorageProvider), prefs);
});

class AppLockNotifier extends StateNotifier<bool> {
  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs;
  static const _key = 'app_lock_enabled';

  AppLockNotifier(this._storage, this._prefs)
      : super(_prefs.getBool(_key) ?? false) {
    _init();
  }

  Future<void> _init() async {
    final value = await _storage.read(key: _key);
    if (value != null) {
      final isEnabled = value == 'true';
      if (state != isEnabled) {
        state = isEnabled;
      }
      await _prefs.setBool(_key, isEnabled);
    }
  }

  Future<void> toggle(bool value) async {
    try {
      await _storage.write(key: _key, value: value.toString());
      await _prefs.setBool(_key, value);
    } catch (_) {}
    state = value;
  }
}

class OnboardingNotifier extends StateNotifier<bool> {
  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs;
  static const _key = 'onboarding_completed';

  OnboardingNotifier(this._storage, this._prefs)
      : super(_prefs.getBool(_key) ?? false) {
    _init();
  }

  Future<void> _init() async {
    final value = await _storage.read(key: _key);
    if (value != null) {
      final isCompleted = value == 'true';
      if (state != isCompleted) {
        state = isCompleted;
      }
      await _prefs.setBool(_key, isCompleted);
    }
  }

  Future<void> complete() async {
    try {
      await _storage.write(key: _key, value: 'true');
      await _prefs.setBool(_key, true);
    } catch (_) {}
    state = true;
  }
}

// Global state indicating if app is unlocked for this session
final authStateProvider = StateProvider<bool>((ref) => false);

final usernameProvider = StateNotifierProvider<UsernameNotifier, String>((ref) {
  return UsernameNotifier(ref.watch(secureStorageProvider));
});

class UsernameNotifier extends StateNotifier<String> {
  final FlutterSecureStorage _storage;
  static const _key = 'user_name';

  UsernameNotifier(this._storage) : super('User') {
    _init();
  }

  Future<void> _init() async {
    final value = await _storage.read(key: _key);
    if (value != null && value.isNotEmpty) {
      state = value;
    }
  }

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty) return;
    try {
      await _storage.write(key: _key, value: newName.trim());
    } catch (_) {}
    state = newName.trim();
  }
}
