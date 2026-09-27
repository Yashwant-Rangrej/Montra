import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_provider.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(secureStorageProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final FlutterSecureStorage _storage;
  static const _key = 'theme_mode';

  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _init();
  }

  Future<void> _init() async {
    final value = await _storage.read(key: _key);
    if (value != null) {
      if (value == 'light') state = ThemeMode.light;
      else if (value == 'dark') state = ThemeMode.dark;
      else state = ThemeMode.system;
    }
  }

  Future<void> updateThemeMode(ThemeMode newMode) async {
    state = newMode;
    String modeString = 'system';
    if (newMode == ThemeMode.light) modeString = 'light';
    else if (newMode == ThemeMode.dark) modeString = 'dark';
    
    try {
      await _storage.write(key: _key, value: modeString);
    } catch (_) {}
  }
}
