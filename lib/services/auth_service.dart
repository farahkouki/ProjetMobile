// lib/services/auth_service.dart
// Authentication service using SQLite database

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import 'database_helper.dart';

/**
 * AuthService - Manages user authentication
 * 
 * Features:
 * 1. Sign Up - Create new account (stored in SQLite)
 * 2. Sign In - Verify credentials (checked against SQLite)
 * 3. Sign Out - Clear session
 * 4. Remember user - Save/load logged-in user
 * 5. Password validation
 * 
 * Flow:
 * App starts → Check if user saved → Auto-login OR show sign-in page
 * User signs in → Save to SharedPreferences → Navigate to offers
 * User signs out → Clear SharedPreferences → Back to sign-in
 */
class AuthService {
  // Current logged-in user
  User? _user;

  // Database helper
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // SharedPreferences keys
  static const String _userKey = 'logged_in_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  /**
   * ========================================
   * INITIALIZE - Load saved user session
   * ========================================
   * 
   * Call this when app starts:
   * - Check if user was logged in before
   * - If yes → load user data
   * - If no → user needs to sign in
   * 
   * Example in main.dart:
   * await AuthService().initialize();
   * bool isLoggedIn = AuthService().isLoggedIn;
   * // Navigate to appropriate page
   */
  Future<void> initialize() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Check if user was logged in
      bool wasLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (wasLoggedIn) {
        // Load user data
        String? userJson = prefs.getString(_userKey);
        
        if (userJson != null) {
          Map<String, dynamic> userMap = jsonDecode(userJson);
          _user = User.fromJson(userMap);
          
          print('✅ User session restored: ${_user!.email}');
        }
      }
    } catch (e) {
      print('❌ Initialize error: $e');
    }
  }

  /**
   * ========================================
   * SIGN UP - Create new account
   * ========================================
   * 
   * Process:
   * 1. Validate input (name, email, password)
   * 2. Check email format
   * 3. Check password strength
   * 4. Call DatabaseHelper.signUp()
   * 5. Save user to SQLite database
   * 6. Save session to SharedPreferences
   * 7. Set current user
   * 
   * Validations:
   * - Name: At least 3 characters
   * - Email: Must contain @
   * - Password: At least 6 characters
   */
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // ===== VALIDATION =====
      
      // 1. Check empty fields
      if (name.trim().isEmpty) {
        throw Exception('Please enter your name');
      }
      if (email.trim().isEmpty) {
        throw Exception('Please enter your email');
      }
      if (password.isEmpty) {
        throw Exception('Please enter a password');
      }

      // 2. Validate name length
      if (name.trim().length < 3) {
        throw Exception('Name must be at least 3 characters');
      }

      // 3. Validate email format
      if (!_isValidEmail(email.trim())) {
        throw Exception('Please enter a valid email');
      }

      // 4. Validate password strength
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // ===== CREATE USER =====
      
      print('📝 Creating account for: $email');

      // Call database helper to create user
      User newUser = await _dbHelper.signUp(
        name.trim(),
        email.trim().toLowerCase(),
        password,
      );

      // Save session
      await _saveUserSession(newUser);

      // Set current user
      _user = newUser;

      print('✅ Account created successfully!');

      return newUser;
    } catch (e) {
      print('❌ Sign up error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /**
   * ========================================
   * SIGN IN - Login user
   * ========================================
   * 
   * Process:
   * 1. Validate input
   * 2. Call DatabaseHelper.login()
   * 3. Database checks email and password
   * 4. If correct → save session
   * 5. Set current user
   * 6. Return user data
   */
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // ===== VALIDATION =====
      
      if (email.trim().isEmpty) {
        throw Exception('Please enter your email');
      }
      if (password.isEmpty) {
        throw Exception('Please enter your password');
      }

      if (!_isValidEmail(email.trim())) {
        throw Exception('Please enter a valid email');
      }

      // ===== LOGIN USER =====
      
      print('🔐 Logging in: $email');

      // Call database helper to verify credentials
      User loggedInUser = await _dbHelper.login(
        email.trim().toLowerCase(),
        password,
      );

      // Save session
      await _saveUserSession(loggedInUser);

      // Set current user
      _user = loggedInUser;

      print('✅ Logged in successfully!');

      return loggedInUser;
    } catch (e) {
      print('❌ Sign in error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /**
   * ========================================
   * SIGN OUT - Logout user
   * ========================================
   * 
   * Process:
   * 1. Clear user from memory
   * 2. Clear session from SharedPreferences
   * 3. User needs to sign in again
   */
  Future<void> signOut() async {
    try {
      print('👋 Signing out user: ${_user?.email}');

      // Clear current user
      _user = null;

      // Clear saved session
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);

      print('✅ Signed out successfully!');
    } catch (e) {
      print('❌ Sign out error: $e');
    }
  }

  /**
   * ========================================
   * UPDATE USER - Modify profile
   * ========================================
   * 
   * Process:
   * 1. Check if user is logged in
   * 2. Validate new data
   * 3. Call DatabaseHelper.updateUser()
   * 4. Update in SQLite database
   * 5. Update current user
   * 6. Update saved session
   */
  Future<User> updateUser({
    required String name,
    String? newPassword,
  }) async {
    try {
      // Check if user is logged in
      if (_user == null) {
        throw Exception('No user logged in');
      }

      // Validate name
      if (name.trim().isEmpty) {
        throw Exception('Please enter your name');
      }
      if (name.trim().length < 3) {
        throw Exception('Name must be at least 3 characters');
      }

      // Validate password if provided
      if (newPassword != null && newPassword.isNotEmpty) {
        if (newPassword.length < 6) {
          throw Exception('Password must be at least 6 characters');
        }
      }

      print('✏️ Updating user: ${_user!.email}');

      // Update in database
      User updatedUser = await _dbHelper.updateUser(
        _user!.id!,
        name.trim(),
        newPassword,
      );

      // Update current user
      _user = updatedUser;

      // Update saved session
      await _saveUserSession(updatedUser);

      print('✅ User updated successfully!');

      return updatedUser;
    } catch (e) {
      print('❌ Update error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /**
   * ========================================
   * DELETE ACCOUNT - Remove user
   * ========================================
   */
  Future<void> deleteAccount() async {
    try {
      if (_user == null) {
        throw Exception('No user logged in');
      }

      print('🗑️ Deleting account: ${_user!.email}');

      // Delete from database
      await _dbHelper.deleteUser(_user!.id!);

      // Sign out
      await signOut();

      print('✅ Account deleted successfully!');
    } catch (e) {
      print('❌ Delete error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /**
   * ========================================
   * CHECK EMAIL EXISTS
   * ========================================
   */
  Future<bool> checkEmailExists(String email) async {
    try {
      return await _dbHelper.emailExists(email.trim().toLowerCase());
    } catch (e) {
      print('❌ Email check error: $e');
      return false;
    }
  }

  /**
   * ========================================
   * PRIVATE HELPER METHODS
   * ========================================
   */

  /**
   * Save user session to SharedPreferences
   * This allows auto-login when app restarts
   */
  Future<void> _saveUserSession(User user) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Save user as JSON
      String userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
      await prefs.setBool(_isLoggedInKey, true);
      
      print('💾 User session saved');
    } catch (e) {
      print('❌ Save session error: $e');
    }
  }

  /**
   * Validate email format
   * Basic check for @ symbol and domain
   */
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  /**
   * Get all users (for debugging/admin)
   */
  Future<List<User>> getAllUsers() async {
    return await _dbHelper.getAllUsers();
  }

  /**
   * Clear all data (for testing)
   * WARNING: Deletes all users!
   */
  Future<void> clearAllData() async {
    await _dbHelper.clearAllData();
    await signOut();
  }

  /// Reset password after OTP verification (email already verified on the page)
Future<void> resetPassword({
  required String email,
  required String newPassword,
}) async {
  final e = email.trim().toLowerCase();
  if (newPassword.length < 6) {
    throw Exception('Password must be at least 6 characters');
  }

  // Find user by email then update their password (DatabaseHelper re-hashes it)
  final user = await _dbHelper.getUserByEmail(e);
  if (user == null) {
    throw Exception('No account found for this email');
  }

  await _dbHelper.updateUser(user.id!, user.name, newPassword);
}

}