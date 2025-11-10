// lib/pages/signin_page.dart
// Complete Sign In page with SQLite authentication

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/risk_engine.dart';
import '../services/otp_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';


class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Loading state
  bool _isLoading = false;
  
  // Password visibility toggle
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /**
   * Handle Sign In
   * 
   * Process:
   * 1. Validate form
   * 2. Show loading
   * 3. Call AuthService.signIn()
   * 4. AuthService calls DatabaseHelper
   * 5. DatabaseHelper checks SQLite database
   * 6. If success → Navigate to offers
   * 7. If error → Show error message
   */
  Future<void> _handleSignIn() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final emailNorm = _emailController.text.trim().toLowerCase();
  final password = _passwordController.text;

  try {
    // 1) Password check (creates session in AuthService on success)
    await AuthService().signIn(email: emailNorm, password: password);

    // 2) Load profile + counters from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final user = AuthService().user!;              // safe: we just signed in
    final userId = user.id!;
    final now = DateTime.now();

    final failedKey = 'failed_email_$emailNorm';
    final recentFailures = prefs.getInt(failedKey) ?? 0;

    final meanHour = prefs.getDouble('meanHour_$userId') ?? now.hour.toDouble();
    final hourStd  = prefs.getDouble('hourStd_$userId')  ?? 2.0; // >=1.0 inside engine
    final lastAtMs = prefs.getInt('lastAt_$userId');
    final idle = (lastAtMs == null)
        ? Duration.zero
        : now.difference(DateTime.fromMillisecondsSinceEpoch(lastAtMs));

    final lastUa = prefs.getString('ua_$userId');          // previously saved UA
    final currentUa = RiskEngine.currentUaHash();
    // deviceChanged = only true if we have a previous device and it's different
    final deviceChanged = (lastUa != null) && (lastUa != currentUa);

    // 3) Compute AI risk
    final currentHour = now.hour;
    final risk = RiskEngine.compute(
      currentHour: currentHour,
      meanHour: meanHour,
      hourStd: hourStd,
      deviceChanged: deviceChanged,
      failedAttempts: recentFailures,
      idleDuration: idle,
    );

    const riskThreshold = 0.20; // tweak 0.50–0.60
    final needOtp = (recentFailures >= 3) || (risk >= riskThreshold);

    // (Optional) quick explain popup for your professor
    if (mounted) {
      final hourZ = ((currentHour - meanHour).abs() / (hourStd <= 0 ? 1 : hourStd)) / 3.0;
      final reasons = <String>[];
      if (hourZ >= 0.5) reasons.add('Unusual hour');
      if (deviceChanged) reasons.add('New device');
      if (recentFailures >= 2) reasons.add('Recent failures');
      if (idle.inDays >= 7) reasons.add('Long idle');
      final verdict = needOtp ? 'STEP-UP (OTP)' : 'ALLOW';
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('AI Login Risk'),
          content: Text('Score: ${risk.toStringAsFixed(2)} → $verdict\n'
              'Reasons: ${reasons.isEmpty ? 'None' : reasons.join(' • ')}'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
          ],
        ),
      );
    }

    // 4) Step-up if needed
    if (needOtp) {
      await OtpService.requestOtp(emailNorm);

      final codeCtrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Extra verification'),
          content: TextField(
            controller: codeCtrl,
            decoration: const InputDecoration(labelText: 'Enter the 6-digit code'),
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Verify'),
            ),
          ],
        ),
      );

      if (ok == true) {
        await OtpService.verifyOtp(emailNorm, codeCtrl.text.trim());
      } else {
        codeCtrl.dispose();
        await AuthService().signOut();
        throw Exception('Verification cancelled');
      }
      codeCtrl.dispose();
    }

    // 5) SUCCESS → reset counters and update the AI profile
    await prefs.setInt(failedKey, 0);
    await prefs.setInt('lastAt_$userId', now.millisecondsSinceEpoch);
    await prefs.setString('ua_$userId', currentUa);

    // Online update of mean & std (simple EMA + variance)
    final diff = currentHour - meanHour;
    final newMean = meanHour + 0.10 * diff; // learn 10%
    final oldVar = hourStd * hourStd;
    final newVar = oldVar + 0.10 * ((diff * diff) - oldVar);
    final newStd = sqrt(newVar.clamp(1.0, 36.0)); // keep in sane range [1h..6h]
    await prefs.setDouble('meanHour_$userId', newMean);
    await prefs.setDouble('hourStd_$userId', newStd);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/offers');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome back!'), backgroundColor: Colors.green),
    );
  } catch (e) {
    // ❌ Wrong password or other error → increment failure counter for THIS email
    final prefs = await SharedPreferences.getInstance();
    final failedKey = 'failed_email_$emailNorm';
    final current = prefs.getInt(failedKey) ?? 0;
    await prefs.setInt(failedKey, current + 1);
    debugPrint('❌ Incremented failures for $emailNorm -> ${current + 1}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove app bar for cleaner look
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or app icon (optional)
                  Icon(
                    Icons.travel_explore,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 24),
                  
                  // Welcome text
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 16),
                        
                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSignIn(),
                        ),
                        SizedBox(height: 24),

                        Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () => Navigator.of(context).pushNamed('/reset-password'),
    child: const Text('Forgot password?'),
  ),
),
const SizedBox(height: 8),
                        
                        // Sign In button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignIn,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Sign Up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/signup');
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}