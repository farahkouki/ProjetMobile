// lib/models/driver_model.dart
class Driver {
  int? id;
  String nom;
  String telephone;
  int experience;

  Driver({
    this.id,
    required this.nom,
    required this.telephone,
    required this.experience,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'telephone': telephone,
      'experience': experience,
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'],
      nom: map['nom'],
      telephone: map['telephone'],
      experience: map['experience'],
    );
  }
}
