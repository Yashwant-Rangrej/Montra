import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticateUser() async {
    bool authenticated = false;
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (canAuthenticate) {
        authenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to access Montra',
        );
      } else {
        // If device has no security set up, allow access or prompt setup.
        // For offline-first privacy, we assume true if unsupported in dev
        authenticated = true; 
      }
    } on PlatformException {
      // Handle error
      authenticated = false;
    }
    return authenticated;
  }
}
