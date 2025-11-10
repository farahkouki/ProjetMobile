import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as pp;
import 'package:sqflite/sqflite.dart';

class AppDB {
  static final AppDB _instance = AppDB._internal();
  factory AppDB() => _instance;
  AppDB._internal();

  static const _dbName = 'volontariat.db';
  static const _dbVersion = 2;

  Database? _db;
  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    if (kIsWeb) {
      return openDatabase(
        _dbName,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      );
    }
    final dir = await pp.getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, _dbName);
    return openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE countries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE volunteers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        duration_weeks INTEGER NOT NULL DEFAULT 1,
        image_url TEXT,
        image_bytes BLOB,
        country_id INTEGER NOT NULL,
        lat REAL,
        lng REAL,
        created_at TEXT NOT NULL,
        FOREIGN KEY(country_id) REFERENCES countries(id) ON DELETE CASCADE
      )
    ''');

    await _createFts(db);
    await _seed(db);
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    Future<void> safe(String sql) async { try { await db.execute(sql); } catch (_) {} }
    if (oldV < 2) {
      await safe('ALTER TABLE volunteers ADD COLUMN lat REAL');
      await safe('ALTER TABLE volunteers ADD COLUMN lng REAL');
      await safe('ALTER TABLE volunteers ADD COLUMN image_bytes BLOB');
      await _createFts(db, dropIfExists: true);

      final rows = await db.query('volunteers');
      final b = db.batch();
      for (final r in rows) {
        b.insert('volunteers_fts', {
          'rowid': r['id'],
          'title': r['title'],
          'category': r['category'],
          'description': r['description'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await b.commit(noResult: true);
    }
  }

  Future<void> _createFts(Database db, {bool dropIfExists = false}) async {
    if (dropIfExists) {
      await db.execute('DROP TABLE IF EXISTS volunteers_fts');
    }
    await db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS volunteers_fts USING fts5(
        title, category, description, content='volunteers', content_rowid='id'
      )
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS volunteers_ai AFTER INSERT ON volunteers
      BEGIN
        INSERT INTO volunteers_fts(rowid, title, category, description)
        VALUES (new.id, new.title, new.category, new.description);
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS volunteers_au AFTER UPDATE ON volunteers
      BEGIN
        UPDATE volunteers_fts
          SET title=new.title, category=new.category, description=new.description
        WHERE rowid=new.id;
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS volunteers_ad AFTER DELETE ON volunteers
      BEGIN
        DELETE FROM volunteers_fts WHERE rowid=old.id;
      END;
    ''');
  }

  Future<void> _seed(Database db) async {
    final tn = await db.insert('countries', {'name': 'Tunisie'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    final ma = await db.insert('countries', {'name': 'Maroc'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    final sn = await db.insert('countries', {'name': 'Sénégal'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    final now = DateTime.now().toIso8601String();

    await db.insert('volunteers', {
      'title': 'Protection des Plages en Tunisie',
      'category': 'Environnement',
      'description': 'Nettoyer et préserver les plages tunisiennes.',
      'duration_weeks': 2,
      'image_url': 'https://images.unsplash.com/photo-1493558103817-58b2924bce98?w=1200',
      'country_id': tn == 0 ? 1 : tn,
      'lat': 36.8065, 'lng': 10.1815,
      'created_at': now
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('volunteers', {
      'title': 'Soutien Scolaire au Maroc',
      'category': 'Éducation',
      'description': 'Aider des élèves dans des écoles locales.',
      'duration_weeks': 4,
      'image_url': 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200',
      'country_id': ma == 0 ? 1 : ma,
      'lat': 33.5731, 'lng': -7.5898,
      'created_at': now
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('volunteers', {
      'title': 'Programme Jeunesse au Sénégal',
      'category': 'Communauté',
      'description': 'Ateliers sportifs et culturels pour jeunes.',
      'duration_weeks': 3,
      'image_url': 'https://images.unsplash.com/photo-1529070538774-1843cb3265df?w=1200',
      'country_id': sn == 0 ? 1 : sn,
      'lat': 14.7167, 'lng': -17.4677,
      'created_at': now
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // ---------------- CRUD ----------------
  Future<List<Map<String, Object?>>> query(String table,
      {String? where, List<Object?>? whereArgs, String? orderBy}) async {
    final db = await database;
    return db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    final db = await database;
    return db.insert(table, values);
  }

  Future<int> update(String table, Map<String, Object?> values, int id) async {
    final db = await database;
    return db.update(table, values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Utils ----------------
  static double? _haversineKm(double? lat1, double? lon1, double? lat2, double? lon2) {
    if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) return null;
    const R = 6371.0;
    double toRad(double d) => d * math.pi / 180.0;
    final dLat = toRad(lat2 - lat1);
    final dLon = toRad(lon2 - lon1);
    final a = math.sin(dLat/2)*math.sin(dLat/2) +
        math.cos(toRad(lat1))*math.cos(toRad(lat2))*math.sin(dLon/2)*math.sin(dLon/2);
    return R * 2 * math.asin(math.sqrt(a));
  }

  // ---------------- Recherche ----------------
  Future<Map<String, Object?>> search({
    String? q,
    int? countryId,
    String? category,
    int? durationMin,
    int? durationMax,
    double? lat,
    double? lng,
    double? maxKm,
    int page = 1,
    int limit = 20,
    String sort = 'new', // new | title | duration | distance
  }) async {
    final db = await database;

    final where = <String>[];
    final args = <Object?>[];
    String joinFts = '';

    if (q != null && q.trim().isNotEmpty) {
      joinFts = 'JOIN volunteers_fts f ON f.rowid = v.id';
      where.add('f MATCH ?');
      args.add(q.trim().replaceAll(RegExp(r'\s+'), ' '));
    }
    if (countryId != null) { where.add('v.country_id = ?'); args.add(countryId); }
    if (category != null && category.trim().isNotEmpty) {
      where.add('lower(v.category) = lower(?)'); args.add(category.trim());
    }
    if (durationMin != null) { where.add('v.duration_weeks >= ?'); args.add(durationMin); }
    if (durationMax != null) { where.add('v.duration_weeks <= ?'); args.add(durationMax); }

    final clause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final offset = (page - 1) * limit;

    String orderBy = 'ORDER BY v.id DESC';
    if (sort == 'title') orderBy = 'ORDER BY v.title COLLATE NOCASE ASC';
    if (sort == 'duration') orderBy = 'ORDER BY v.duration_weeks ASC';

    final rows = await db.rawQuery('''
      SELECT v.*, c.name as country_name
      FROM volunteers v
      $joinFts
      JOIN countries c ON c.id = v.country_id
      $clause
      $orderBy
      LIMIT ? OFFSET ?
    ''', [...args, limit, offset]);

    final totalRow = await db.rawQuery(
        'SELECT COUNT(*) as c FROM volunteers v $joinFts $clause', args);
    final total = (totalRow.first['c'] as int?) ?? 0;

    final items = rows.map((r) {
      final d = _haversineKm(
        lat, lng,
        (r['lat'] as num?)?.toDouble(),
        (r['lng'] as num?)?.toDouble(),
      );
      return {
        'id': r['id'],
        'title': r['title'],
        'category': r['category'],
        'description': r['description'],
        'durationWeeks': r['duration_weeks'],
        'imageUrl': r['image_url'],
        'imageBytes': r['image_bytes'],
        'country': {'id': r['country_id'], 'name': r['country_name']},
        'lat': r['lat'],
        'lng': r['lng'],
        'createdAt': r['created_at'],
        'distanceKm': d != null ? double.parse(d.toStringAsFixed(1)) : null,
      };
    }).where((it) {
      if (maxKm == null) return true;
      final d = it['distanceKm'] as double?;
      return d != null && d <= maxKm;
    }).toList();

    if (sort == 'distance' && lat != null && lng != null) {
      items.sort((a, b) =>
          ((a['distanceKm'] as double?) ?? 1e9).compareTo(((b['distanceKm'] as double?) ?? 1e9)));
    }

    return {'page': page, 'limit': limit, 'total': total, 'items': items};
  }

  Future<Map<String, Object?>> facets({String? q}) async {
    final db = await database;

    String joinFts = '', where = '';
    final args = <Object?>[];
    if (q != null && q.trim().isNotEmpty) {
      joinFts = 'JOIN volunteers_fts f ON f.rowid = v.id';
      where = 'WHERE f MATCH ?';
      args.add(q.trim().replaceAll(RegExp(r'\s+'), ' '));
    }

    final byCountry = await db.rawQuery('''
      SELECT c.name as country, COUNT(*) as count
      FROM volunteers v
      $joinFts
      JOIN countries c ON c.id = v.country_id
      $where
      GROUP BY c.name
      ORDER BY count DESC
    ''', args);

    final byCategory = await db.rawQuery('''
      SELECT v.category as category, COUNT(*) as count
      FROM volunteers v
      $joinFts
      $where
      GROUP BY v.category
      ORDER BY count DESC
    ''', args);

    return {'countries': byCountry, 'categories': byCategory};
  }
}
