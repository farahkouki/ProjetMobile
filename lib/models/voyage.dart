// lib/models/voyage.dart

import 'package:uuid/uuid.dart';

class Voyage {
  int? id; // Pour SQFLite (null si pas encore inséré)
  String uuid; // ID unique pour QR code + PDF
  String destination;
  DateTime dateDepart;
  DateTime dateArrivee;
  double budget;
  String description;

  Voyage({
    this.id,
    String? uuid,
    required this.destination,
    required this.dateDepart,
    required this.dateArrivee,
    required this.budget,
    this.description = '',
  }) : uuid = uuid ?? const Uuid().v4();

  // Convertir depuis la base SQFLite (SÉCURISÉ CONTRE LES ERREURS)
  factory Voyage.fromMap(Map<String, dynamic> map) {
    return Voyage(
      id: map['id'] as int?,
      uuid: (map['uuid'] as String?) ?? const Uuid().v4(), // Sécurité si null
      destination: (map['destination'] as String?) ?? 'Inconnu',
      dateDepart: _parseDate(map['dateDepart']),
      dateArrivee: _parseDate(map['dateArrivee']),
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      description: (map['description'] as String?) ?? '',
    );
  }

  // Fonction privée pour parser les dates en toute sécurité
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // Convertir vers la base SQFLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'destination': destination,
      'dateDepart': dateDepart.toIso8601String(),
      'dateArrivee': dateArrivee.toIso8601String(),
      'budget': budget,
      'description': description,
    };
  }

  // Pour modifier un voyage
  Voyage copyWith({
    int? id,
    String? uuid,
    String? destination,
    DateTime? dateDepart,
    DateTime? dateArrivee,
    double? budget,
    String? description,
  }) {
    return Voyage(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      destination: destination ?? this.destination,
      dateDepart: dateDepart ?? this.dateDepart,
      dateArrivee: dateArrivee ?? this.dateArrivee,
      budget: budget ?? this.budget,
      description: description ?? this.description,
    );
  }

  // Pour afficher dans la liste (EN FRANÇAIS + PROPRE)
  @override
  String toString() {
    final formatter = (DateTime d) => '${d.day}/${d.month}/${d.year}';
    return '$destination • ${formatter(dateDepart)} → ${formatter(dateArrivee)} • ${budget.toStringAsFixed(0)} TND';
  }

  // Pour le PDF + QR Code (format lisible)
  String get formattedInfo => '''
Destination: $destination
Du: ${dateDepart.day}/${dateDepart.month}/${dateDepart.year}
Au: ${dateArrivee.day}/${dateArrivee.month}/${dateArrivee.year}
Budget: ${budget.toStringAsFixed(0)} TND
${description.isNotEmpty ? 'Notes: $description' : ''}
ID: $uuid
  '''.trim();
}