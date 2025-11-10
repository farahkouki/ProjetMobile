import 'package:sqflite/sqflite.dart';
import '../../../core/db/app_database.dart';
import 'chambre.dart';

class ChambreLocalService {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<Chambre>> listByHotel(int hotelId) async {
    final db = await _db;
    final rows = await db.query(
      'chambres',
      where: 'hotel_id = ?',
      whereArgs: [hotelId],
      orderBy: 'id DESC',
    );
    return rows.map(Chambre.fromMap).toList();
  }

  Future<Chambre> add(Chambre c) async {
    final db = await _db;
    final id = await db.insert('chambres', c.toMap());
    return Chambre(
      id: id,
      hotelId: c.hotelId,
      numChambre: c.numChambre,
      typeChambre: c.typeChambre,
      prixNuit: c.prixNuit,
      disponibilite: c.disponibilite,
    );
  }

  // Optional for later:
  Future<int> remove(int id) async {
    final db = await _db;
    return db.delete('chambres', where: 'id = ?', whereArgs: [id]);
  }
}
