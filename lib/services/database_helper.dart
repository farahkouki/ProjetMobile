// lib/services/database_helper.dart
// SQLite Database Manager with Web Support

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';

// Import for Web support
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/**
 * DatabaseHelper - Manages SQLite database operations
 * Works on: Android, iOS, Windows, macOS, Linux, AND WEB
 */
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String DATABASE_NAME = 'travel_agency.db';
  static const String TABLE_USERS = 'users';
  static const int DATABASE_VERSION = 1;

  /**
   * Get database instance
   * Handles Web and Mobile differently
   */
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    
    _database = await _initDatabase();
    return _database!;
  }

  /**
   * Initialize database
   * Different initialization for Web vs Mobile
   */
  Future<Database> _initDatabase() async {
    // FOR WEB: Use sqflite_common_ffi_web
    if (kIsWeb) {
      print('🌐 Initializing database for WEB');
      
      // Set database factory for web
      databaseFactory = databaseFactoryFfiWeb;
      
      // Open database (stored in browser IndexedDB)
      return await databaseFactory.openDatabase(
        DATABASE_NAME,
        options: OpenDatabaseOptions(
          version: DATABASE_VERSION,
          onCreate: _createDatabase,
          onUpgrade: _upgradeDatabase,
        ),
      );
    }
    // FOR MOBILE/DESKTOP: Use regular sqflite
    else {
      print('📱 Initializing database for MOBILE/DESKTOP');
      
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, DATABASE_NAME);

      print('📁 Database path: $path');

      return await openDatabase(
        path,
        version: DATABASE_VERSION,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    }
  }

  /**
   * Create database tables
   */
  Future<void> _createDatabase(Database db, int version) async {
    print('🔨 Creating database tables...');

    await db.execute('''
      CREATE TABLE $TABLE_USERS (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    print('✅ Database tables created successfully!');
  }

  /**
   * Upgrade database
   */
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    print('⬆️ Upgrading database from v$oldVersion to v$newVersion');
  }

  /**
   * Password encryption with SHA-256
   */
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /**
   * CREATE - Sign up new user
   */
  Future<User> signUp(String name, String email, String password) async {
    try {
      final db = await database;

      print('📝 Signing up user: $email');

      // Check if email already exists
      final existingUsers = await db.query(
        TABLE_USERS,
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUsers.isNotEmpty) {
        throw Exception('Email already exists!');
      }

      // Hash password
      String hashedPassword = _hashPassword(password);

      // Prepare user data
      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'password': hashedPassword,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Insert into database
      int userId = await db.insert(
        TABLE_USERS,
        userData,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      print('✅ User created with ID: $userId');

      return User(
        id: userId,
        name: name,
        email: email,
        password: '',
      );
    } catch (e) {
      print('❌ Sign up error: $e');
      throw Exception('Sign up failed: $e');
    }
  }

  /**
   * READ - Login user
   */
  Future<User> login(String email, String password) async {
    try {
      final db = await database;

      print('🔐 Logging in user: $email');

      // Find user by email
      final users = await db.query(
        TABLE_USERS,
        where: 'email = ?',
        whereArgs: [email],
      );

      if (users.isEmpty) {
        throw Exception('Invalid email or password!');
      }

      Map<String, dynamic> userData = users.first;

      // Hash input password
      String hashedPassword = _hashPassword(password);

      // Compare passwords
      if (userData['password'] != hashedPassword) {
        throw Exception('Invalid email or password!');
      }

      print('✅ Login successful!');

      return User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        password: '',
      );
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  /**
   * READ - Get user by ID
   */
  Future<User?> getUserById(int id) async {
    try {
      final db = await database;

      final users = await db.query(
        TABLE_USERS,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (users.isEmpty) {
        return null;
      }

      Map<String, dynamic> userData = users.first;

      return User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        password: '',
      );
    } catch (e) {
      print('❌ Get user error: $e');
      return null;
    }
  }

  /**
   * READ - Get user by email
   */
  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await database;

      final users = await db.query(
        TABLE_USERS,
        where: 'email = ?',
        whereArgs: [email],
      );

      if (users.isEmpty) {
        return null;
      }

      Map<String, dynamic> userData = users.first;

      return User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        password: '',
      );
    } catch (e) {
      print('❌ Get user error: $e');
      return null;
    }
  }

  /**
   * READ - Get all users
   */
  Future<List<User>> getAllUsers() async {
    try {
      final db = await database;

      final users = await db.query(TABLE_USERS);

      return users.map((userData) {
        return User(
          id: userData['id'] as int,
          name: userData['name'] as String,
          email: userData['email'] as String,
          password: '',
        );
      }).toList();
    } catch (e) {
      print('❌ Get all users error: $e');
      return [];
    }
  }

  /**
   * UPDATE - Modify user
   */
  Future<User> updateUser(int id, String name, String? newPassword) async {
    try {
      final db = await database;

      print('✏️ Updating user ID: $id');

      // Check if user exists
      final existingUser = await getUserById(id);
      if (existingUser == null) {
        throw Exception('User not found!');
      }

      // Prepare update data
      Map<String, dynamic> updateData = {
        'name': name,
      };

      // Add password if provided
      if (newPassword != null && newPassword.isNotEmpty) {
        updateData['password'] = _hashPassword(newPassword);
      }

      // Update in database
      int updatedRows = await db.update(
        TABLE_USERS,
        updateData,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (updatedRows == 0) {
        throw Exception('Update failed!');
      }

      print('✅ User updated successfully!');

      return User(
        id: id,
        name: name,
        email: existingUser.email,
        password: '',
      );
    } catch (e) {
      print('❌ Update error: $e');
      throw Exception('Update failed: $e');
    }
  }

  /**
   * DELETE - Remove user
   */
  Future<void> deleteUser(int id) async {
    try {
      final db = await database;

      print('🗑️ Deleting user ID: $id');

      int deletedRows = await db.delete(
        TABLE_USERS,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (deletedRows == 0) {
        throw Exception('User not found!');
      }

      print('✅ User deleted successfully!');
    } catch (e) {
      print('❌ Delete error: $e');
      throw Exception('Delete failed: $e');
    }
  }

  /**
   * CHECK - Email exists
   */
  Future<bool> emailExists(String email) async {
    try {
      final db = await database;

      final users = await db.query(
        TABLE_USERS,
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      return users.isNotEmpty;
    } catch (e) {
      print('❌ Email check error: $e');
      return false;
    }
  }

  /**
   * UTILITY - Clear all data
   */
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete(TABLE_USERS);
      print('🧹 All data cleared!');
    } catch (e) {
      print('❌ Clear data error: $e');
    }
  }

  /**
   * Close database
   */
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}