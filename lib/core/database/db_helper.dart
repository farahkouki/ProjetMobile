// lib/core/database/db_helper.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/vehicle_model.dart';
import '../../models/driver_model.dart';
import '../../models/reservation_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;
  static const int _version = 3; // ← Mise à jour

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'voyagea.db');
    return await openDatabase(path, version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async => await _createTables(db);

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE reservations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vehicle_id INTEGER,
          driver_id INTEGER,
          client_name TEXT,
          client_phone TEXT,
          start_date INTEGER,
          end_date INTEGER,
          total_price REAL,
          status TEXT,
          FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE,
          FOREIGN KEY (driver_id) REFERENCES drivers (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE vehicles ADD COLUMN kilometrage INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE vehicles ADD COLUMN derniereVidange INTEGER NOT NULL DEFAULT ${DateTime.now().millisecondsSinceEpoch}');
      await db.execute('''
        CREATE TABLE maintenance_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vehicleId INTEGER,
          type TEXT,
          date INTEGER,
          kilometrage INTEGER,
          FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE vehicles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        marque TEXT,
        modele TEXT,
        capacite INTEGER,
        prix_par_jour REAL,
        image TEXT,
        disponibilite INTEGER DEFAULT 1,
        kilometrage INTEGER NOT NULL DEFAULT 0,
        derniereVidange INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE drivers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT,
        telephone TEXT,
        experience INTEGER,
        vehicle_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE reservations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER,
        driver_id INTEGER,
        client_name TEXT,
        client_phone TEXT,
        start_date INTEGER,
        end_date INTEGER,
        total_price REAL,
        status TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE,
        FOREIGN KEY (driver_id) REFERENCES drivers (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER,
        type TEXT,
        date INTEGER,
        kilometrage INTEGER,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- Vehicles ---
  Future<int> insertVehicle(Vehicle v) async => await (await database).insert('vehicles', v.toMap());
  Future<int> updateVehicle(Vehicle v) async => await (await database).update('vehicles', v.toMap(), where: 'id = ?', whereArgs: [v.id]);
  Future<int> deleteVehicle(int id) async => await (await database).delete('vehicles', where: 'id = ?', whereArgs: [id]);
  Future<List<Vehicle>> getAllVehicles() async {
    final res = await (await database).query('vehicles', orderBy: 'id DESC');
    return res.map((e) => Vehicle.fromMap(e)).toList();
  }

  // --- Drivers ---
  Future<int> insertDriver(Driver d) async => await (await database).insert('drivers', d.toMap());
  Future<int> updateDriver(Driver d) async => await (await database).update('drivers', d.toMap(), where: 'id = ?', whereArgs: [d.id]);
  Future<int> deleteDriver(int id) async => await (await database).delete('drivers', where: 'id = ?', whereArgs: [id]);
  Future<List<Driver>> getAllDrivers() async {
    final res = await (await database).query('drivers', orderBy: 'id DESC');
    return res.map((e) => Driver.fromMap(e)).toList();
  }

  // --- Reservations ---
  Future<int> insertReservation(Reservation r) async {
    final db = await database;
    return await db.insert('reservations', r.toMap());
  }

  Future<List<Reservation>> getAllReservations() async {
    final res = await (await database).query('reservations', orderBy: 'start_date DESC');
    return res.map((e) => Reservation.fromMap(e)).toList();
  }

  Future<List<Reservation>> getActiveReservationsByVehicle(int vehicleId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final res = await db.query(
      'reservations',
      where: 'vehicle_id = ? AND status != ? AND status != ? AND end_date >= ?',
      whereArgs: [vehicleId, 'terminée', 'annulée', now],
      orderBy: 'start_date ASC',
    );
    return res.map((e) => Reservation.fromMap(e)).toList();
  }

  Future<int> updateReservationStatus(int id, String status) async {
    final db = await database;
    return await db.update('reservations', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteReservation(int id) async {
    final db = await database;
    return await db.delete('reservations', where: 'id = ?', whereArgs: [id]);
  }

  // --- Maintenance ---
  Future<int> insertMaintenance(int vehicleId, String type, int date, int km) async {
    final db = await database;
    return await db.insert('maintenance_history', {
      'vehicleId': vehicleId,
      'type': type,
      'date': date,
      'kilometrage': km,
    });
  }

  Future<void> updateVehicleKilometrageAndOil(int vehicleId, int km, int oilDate) async {
    final db = await database;
    await db.update(
      'vehicles',
      {'kilometrage': km, 'derniereVidange': oilDate},
      where: 'id = ?',
      whereArgs: [vehicleId],
    );
  }
}