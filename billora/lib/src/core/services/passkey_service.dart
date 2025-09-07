import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';

class PasskeyService {
  static final PasskeyService _instance = PasskeyService._internal();
  factory PasskeyService() => _instance;
  PasskeyService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Generate a unique user ID for passkey authentication
  String generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'passkey_user_${timestamp}_$random';
  }

  /// Generate a challenge for authentication
  String generateChallenge() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      if (kDebugMode) {
        print('Biometric check error: $e');
      }
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      if (kDebugMode) {
        print('Get biometrics error: $e');
      }
      return [];
    }
  }

  /// Authenticate user with biometrics
  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate with your biometric to continue',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Biometric authentication error: $e');
      }
      return false;
    }
  }

  /// Simulate passkey registration process
  Future<Map<String, dynamic>> registerPasskey({
    required String email,
    required String displayName,
  }) async {
    try {
      // Check if biometric is available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometric authentication not available on this device');
      }

      // Authenticate user
      final authenticated = await authenticateWithBiometrics(
        reason: 'Register your passkey for secure login',
      );

      if (!authenticated) {
        throw Exception('Biometric authentication failed');
      }

      // Generate user ID and credentials
      final userId = generateUserId();
      final challenge = generateChallenge();
      
      // Simulate creating a passkey credential
      final credentialId = base64Url.encode(
        sha256.convert(utf8.encode('$userId:$email:$challenge')).bytes,
      );

      // In a real implementation, this would be sent to your server
      // For now, we'll return the credential data
      return {
        'success': true,
        'userId': userId,
        'credentialId': credentialId,
        'challenge': challenge,
        'email': email,
        'displayName': displayName,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Passkey registration error: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Simulate passkey authentication process
  Future<Map<String, dynamic>> authenticateWithPasskey({
    required String credentialId,
  }) async {
    try {
      // Check if biometric is available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometric authentication not available on this device');
      }

      // Authenticate user
      final authenticated = await authenticateWithBiometrics(
        reason: 'Authenticate with your passkey to login',
      );

      if (!authenticated) {
        throw Exception('Biometric authentication failed');
      }

      // Generate new challenge for this session
      final challenge = generateChallenge();
      
      // In a real implementation, this would verify the credential with your server
      // For now, we'll return success with session data
      return {
        'success': true,
        'credentialId': credentialId,
        'challenge': challenge,
        'timestamp': DateTime.now().toIso8601String(),
        'sessionToken': base64Url.encode(
          sha256.convert(utf8.encode('$credentialId:$challenge')).bytes,
        ),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Passkey authentication error: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Check if passkey is already registered for this device
  Future<bool> isPasskeyRegistered() async {
    // In a real implementation, this would check with your server
    // For now, we'll simulate checking local storage
    return false;
  }

  /// Get stored passkey credential ID
  Future<String?> getStoredCredentialId() async {
    // In a real implementation, this would retrieve from secure storage
    // For now, we'll return null
    return null;
  }

  /// Store passkey credential ID securely
  Future<void> storeCredentialId(String credentialId) async {
    // In a real implementation, this would store in secure storage
    // For now, we'll just print it
    if (kDebugMode) {
      print('Storing credential ID: $credentialId');
    }
  }
}





