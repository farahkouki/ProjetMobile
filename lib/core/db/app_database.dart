import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'agence.db');

    _db = await openDatabase(
      path,
      version: 2, // ← bump version
      onCreate: (db, v) async {
        await _createHotels(db);
        await _createChambres(db);
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await _createChambres(db);
        }
      },
    );
    return _db!;
  }

  Future<void> _createHotels(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hotels(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        adresse TEXT NOT NULL,
        ville   TEXT NOT NULL,
        pay     TEXT NOT NULL,
        tel     INTEGER NOT NULL,
        email   TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createChambres(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON'); // ensure FK on SQLite
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chambres(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hotel_id INTEGER NOT NULL,
        num_chambre TEXT NOT NULL,
        type_chambre TEXT NOT NULL,
        prix_nuit REAL NOT NULL,
        disponibilite INTEGER NOT NULL, -- 0/1
        FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE CASCADE
      )
    ''');
  }
}
