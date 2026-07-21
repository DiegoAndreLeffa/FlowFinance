import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const _authKey = 'is_app_lock_enabled';

  Future<bool> isProtectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_authKey) ?? false;
  }

  Future<void> setProtectionEnabled(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, enable);
  }

  Future<bool> authenticate() async {
    if (kIsWeb) return true;

    try {
      final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canCheck) return true;

      return await _auth.authenticate(
        localizedReason: 'Desbloqueie o FlowFinance para acessar seus dados',
      );
    } catch (e) {
      return true; 
    }
  }
}