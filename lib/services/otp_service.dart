import 'dart:convert';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:http/http.dart' as http;

class OtpService {
  // Change to your deployed URL in prod
  static const String _base = kReleaseMode ? 'https://your-domain.com' : 'http://localhost:8081';

  static Future<void> requestOtp(String email) async {
    final r = await http.post(Uri.parse('$_base/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}));
    final body = jsonDecode(r.body);
    if (r.statusCode != 200 || body['ok'] != true) {
      throw Exception(body['error'] ?? 'Failed to send OTP');
    }
  }

  static Future<void> verifyOtp(String email, String code) async {
    final r = await http.post(Uri.parse('$_base/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}));
    final body = jsonDecode(r.body);
    if (r.statusCode != 200 || body['ok'] != true) {
      throw Exception(body['error'] ?? 'Invalid code');
    }
  }
}
