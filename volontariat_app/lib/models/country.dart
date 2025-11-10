class Country {
  final int? id;
  final String name;

  Country({this.id, required this.name});

  factory Country.fromMap(Map<String, Object?> m) =>
      Country(id: m['id'] as int?, name: m['name'] as String);

  Map<String, Object?> toMap() => {'id': id, 'name': name};
}
