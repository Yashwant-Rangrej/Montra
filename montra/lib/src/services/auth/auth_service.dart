import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication auth = LocalAuthentication();

  /// Flag indicating if native authentication is actively prompting the user.
  /// Used to distinguish system authentication prompt pauses from user leaving the app.
  bool isAuthenticating = false;

  /// Timestamp of the last completed authentication attempt.
  DateTime? lastAuthCompletedAt;

  /// Returns true if an authentication attempt was completed very recently (within 1.5 seconds),
  /// to protect against OS lifecycle jitter during biometric dialog dismissal.
  bool get justFinishedAuthenticating {
    if (lastAuthCompletedAt == null) return false;
    return DateTime.now().difference(lastAuthCompletedAt!).inMilliseconds < 1500;
  }

  /// Checks if the mobile device has local authentication available (biometrics or device credentials like PIN/Pattern/Password).
  Future<bool> isDeviceSupported() async {
    try {
      final bool canCheck = await auth.canCheckBiometrics;
      final bool isSupported = await auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (e) {
      debugPrint('Error checking local auth device support: $e');
      return false;
    }
  }

  /// Retrieves available biometric types (fingerprint, face, etc.) enrolled on the device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return const <BiometricType>[];
    }
  }

  /// Authenticates using the mobile device's local authentication system.
  /// Supports both device biometrics (fingerprint/face) and device credentials (PIN/pattern/password).
  Future<bool> authenticateUser({String? reason}) async {
    if (isAuthenticating || justFinishedAuthenticating) {
      debugPrint('AuthService: ignoring duplicate or rapid authentication attempt.');
      return false;
    }
    isAuthenticating = true;
    bool authenticated = false;

    try {
      final supported = await isDeviceSupported();
      if (!supported) {
        // If device has no screen lock or biometrics setup, allow access gracefully
        debugPrint('Mobile device does not have local authentication hardware or credentials setup.');
        authenticated = true;
      } else {
        authenticated = await auth.authenticate(
          localizedReason: reason ??
              'Please authenticate using your device screen lock or biometrics to access Montra',
          biometricOnly: false, // Allows device PIN, pattern, passcode alongside biometrics
          persistAcrossBackgrounding: true, // Automatically handles backgrounding/resuming
          sensitiveTransaction: true,
        );
      }
    } on LocalAuthException catch (e) {
      debugPrint('Mobile local authentication LocalAuthException: ${e.code} - ${e.description}');
      authenticated = false;
    } on PlatformException catch (e) {
      debugPrint('Mobile local authentication PlatformException: ${e.code} - ${e.message}');
      authenticated = false;
    } catch (e) {
      debugPrint('Mobile local authentication unexpected error: $e');
      authenticated = false;
    } finally {
      isAuthenticating = false;
      lastAuthCompletedAt = DateTime.now();
    }

    return authenticated;
  }
}
