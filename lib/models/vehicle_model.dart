// lib/models/vehicle_model.dart
class Vehicle {
  int? id;
  String type;
  String marque;
  String modele;
  int capacite;
  double prixParJour;
  int disponibilite; // 1 = dispo, 0 = non
  String? image;
  int kilometrage; // ← AJOUTÉ
  DateTime derniereVidange; // ← AJOUTÉ

  Vehicle({
    this.id,
    required this.type,
    required this.marque,
    required this.modele,
    required this.capacite,
    required this.prixParJour,
    this.disponibilite = 1,
    this.image,
    this.kilometrage = 0,
    required this.derniereVidange,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'marque': marque,
      'modele': modele,
      'capacite': capacite,
      'prix_par_jour': prixParJour,
      'disponibilite': disponibilite,
      'image': image,
      'kilometrage': kilometrage,
      'derniereVidange': derniereVidange.millisecondsSinceEpoch,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      type: map['type'] ?? '',
      marque: map['marque'] ?? '',
      modele: map['modele'] ?? '',
      capacite: map['capacite'] ?? 0,
      prixParJour: (map['prix_par_jour'] is int)
          ? (map['prix_par_jour'] as int).toDouble()
          : (map['prix_par_jour'] ?? 0.0) as double,
      disponibilite: map['disponibilite'] ?? 1,
      image: map['image'],
      kilometrage: map['kilometrage'] ?? 0,
      derniereVidange: DateTime.fromMillisecondsSinceEpoch(map['derniereVidange'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}