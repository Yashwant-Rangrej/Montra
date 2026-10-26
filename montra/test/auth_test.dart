import 'package:flutter_test/flutter_test.dart';
import 'package:montra/src/services/auth/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService Unit Tests', () {
    test('AuthService can be instantiated and initialized', () {
      final authService = AuthService();
      expect(authService.isAuthenticating, isFalse);
    });

    test('isDeviceSupported returns boolean without crashing', () async {
      final authService = AuthService();
      final supported = await authService.isDeviceSupported();
      expect(supported, isA<bool>());
    });

    test('getAvailableBiometrics returns list without crashing', () async {
      final authService = AuthService();
      final biometrics = await authService.getAvailableBiometrics();
      expect(biometrics, isA<List>());
    });
  });
}
