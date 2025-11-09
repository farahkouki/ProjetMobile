// lib/database/db_helper.dart

import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart'; // AJOUTÉ ICI
import '../models/voyage.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gestion_voyages.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    String path = join(docsDir.path, fileName);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE voyages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL,
        destination TEXT NOT NULL,
        dateDepart TEXT NOT NULL,
        dateArrivee TEXT NOT NULL,
        budget REAL NOT NULL,
        description TEXT
      )
    ''');

    // Ajoute un index pour trier par date
    await db.execute('CREATE INDEX idx_dateDepart ON voyages(dateDepart)');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajoute la colonne uuid
      await db.execute('ALTER TABLE voyages ADD COLUMN uuid TEXT');

      // Génère un UUID pour chaque voyage existant
      final result = await db.query('voyages');
      final uuid = const Uuid();
      for (var row in result) {
        final id = row['id'] as int;
        final newUuid = uuid.v4();
        await db.update(
          'voyages',
          {'uuid': newUuid},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }

  // INSERT
  Future<int> insertVoyage(Voyage voyage) async {
    final db = await database;
    return await db.insert('voyages', voyage.toMap());
  }

  // GET ALL
  Future<List<Voyage>> getAllVoyages() async {
    final db = await database;
    final maps = await db.query(
      'voyages',
      orderBy: 'dateDepart DESC',
    );
    return List.generate(maps.length, (i) => Voyage.fromMap(maps[i]));
  }

  // UPDATE
  Future<int> updateVoyage(Voyage voyage) async {
    final db = await database;
    return await db.update(
      'voyages',
      voyage.toMap(),
      where: 'id = ?',
      whereArgs: [voyage.id],
    );
  }

  // DELETE
  Future<int> deleteVoyage(int id) async {
    final db = await database;
    return await db.delete(
      'voyages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // FERMER LA BASE (optionnel, mais propre)
  Future close() async {
    final db = await database;
    db.close();
  }
}