class Chambre {
  final int? id;
  final int hotelId;
  final String numChambre;
  final String typeChambre;
  final double prixNuit;
  final bool disponibilite;

  const Chambre({
    this.id,
    required this.hotelId,
    required this.numChambre,
    required this.typeChambre,
    required this.prixNuit,
    required this.disponibilite,
  });

  factory Chambre.fromMap(Map<String, dynamic> m) => Chambre(
    id: m['id'] as int?,
    hotelId: m['hotel_id'] as int,
    numChambre: m['num_chambre'] as String,
    typeChambre: m['type_chambre'] as String,
    prixNuit: (m['prix_nuit'] as num).toDouble(),
    disponibilite: (m['disponibilite'] as int) == 1,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'hotel_id': hotelId,
    'num_chambre': numChambre,
    'type_chambre': typeChambre,
    'prix_nuit': prixNuit,
    'disponibilite': disponibilite ? 1 : 0,
  };
}
