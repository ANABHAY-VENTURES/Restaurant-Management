// Anabhay Ventures — Cryptographic Security, Password Hashing & Rate Limiting

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final Random _secureRandom = Random.secure();

  // Failed login attempts tracker: identifier -> (count, lockedUntil)
  final Map<String, _LoginAttemptState> _failedAttempts = {};

  // Active sessions in memory: tokenHash -> SessionInfo
  final Map<String, Map<String, dynamic>> _activeSessions = {};

  // Verification tokens in memory: token -> TokenInfo
  final Map<String, Map<String, dynamic>> _verificationTokens = {};

  /// Hash a plain password using SHA-256 with a unique salt
  String hashPassword(String password, {String? salt}) {
    final effectiveSalt = salt ?? generateSalt();
    final combined = '$effectiveSalt:$password:anabhay_security_v2';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return '$effectiveSalt:${digest.toString()}';
  }

  /// Verify a plain password against a stored salted hash
  bool verifyPassword(String password, String storedHash) {
    final parts = storedHash.split(':');
    if (parts.length != 2) return false;
    final salt = parts[0];
    final expectedHash = hashPassword(password, salt: salt);
    return expectedHash == storedHash;
  }

  /// Generate a cryptographically strong 32-byte hex salt
  String generateSalt([int length = 32]) {
    final values = List<int>.generate(length, (_) => _secureRandom.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Generate a random 64-character bearer token
  String generateBearerToken() {
    final randomBytes = List<int>.generate(32, (_) => _secureRandom.nextInt(256));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final raw = '${base64Url.encode(randomBytes)}.$timestamp';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  /// Generate a 6-digit numeric OTP for verification
  String generateOtp() {
    final otp = 100000 + _secureRandom.nextInt(900000);
    return otp.toString();
  }

  /// Rate Limiting & Account Lockout: Check if identifier is currently locked out
  bool isLockedOut(String identifier) {
    final state = _failedAttempts[identifier];
    if (state == null) return false;
    if (state.lockedUntil != null && DateTime.now().isBefore(state.lockedUntil!)) {
      return true;
    }
    if (state.lockedUntil != null && DateTime.now().isAfter(state.lockedUntil!)) {
      _failedAttempts.remove(identifier);
      return false;
    }
    return false;
  }

  /// Record a failed login attempt; lock out after 5 consecutive failures for 15 minutes
  int recordFailedAttempt(String identifier) {
    final now = DateTime.now();
    var state = _failedAttempts[identifier];
    if (state == null) {
      state = _LoginAttemptState(attempts: 1, lastAttempt: now);
      _failedAttempts[identifier] = state;
      return 1;
    }

    state.attempts += 1;
    state.lastAttempt = now;

    if (state.attempts >= 5) {
      state.lockedUntil = now.add(const Duration(minutes: 15));
    }
    return state.attempts;
  }

  /// Clear failed attempts on successful login
  void clearFailedAttempts(String identifier) {
    _failedAttempts.remove(identifier);
  }

  /// Store session
  void storeSession(String token, Map<String, dynamic> sessionData) {
    _activeSessions[token] = sessionData;
  }

  /// Retrieve session
  Map<String, dynamic>? getSession(String token) {
    return _activeSessions[token];
  }

  /// Revoke session
  void revokeSession(String token) {
    _activeSessions.remove(token);
  }

  /// Store verification token (OTP or reset token)
  void storeVerificationToken(String key, String token, {required String type, required String userId, int expiryMinutes = 15}) {
    _verificationTokens[key] = {
      'token': token,
      'type': type,
      'user_id': userId,
      'expires_at': DateTime.now().add(Duration(minutes: expiryMinutes)).toIso8601String(),
      'is_used': false,
    };
  }

  /// Verify and consume verification token
  bool verifyAndConsumeToken(String key, String token) {
    final record = _verificationTokens[key];
    if (record == null) return false;
    if (record['is_used'] == true) return false;

    final expiresAt = DateTime.parse(record['expires_at'] as String);
    if (DateTime.now().isAfter(expiresAt)) return false;

    if (record['token'] == token) {
      record['is_used'] = true;
      return true;
    }
    return false;
  }
}

class _LoginAttemptState {
  int attempts;
  DateTime lastAttempt;
  DateTime? lockedUntil;

  _LoginAttemptState({required this.attempts, required this.lastAttempt});
}
