import 'package:sqflite/sqflite.dart';
import '../../../core/db/app_database.dart';
import 'hotel.dart';

class HotelLocalService {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<Hotel>> list() async {
    final db = await _db;
    final rows = await db.query('hotels', orderBy: 'id DESC');
    return rows.map(Hotel.fromMap).toList();
  }

  Future<Hotel> add(Hotel h) async {
    final db = await _db;
    final id = await db.insert('hotels', h.toMap());
    return Hotel(
      id: id,
      adresse: h.adresse,
      ville: h.ville,
      pay: h.pay,
      tel: h.tel,
      email: h.email,
    );
  }
}
