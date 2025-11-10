import 'dart:typed_data';

class Volunteer {
  final int? id;
  final String title;
  final String category;
  final String? description;
  final int durationWeeks;
  final String? imageUrl;
  final Uint8List? imageBytes; // upload
  final int countryId;
  final double? lat;
  final double? lng;
  final String createdAt;

  Volunteer({
    this.id,
    required this.title,
    required this.category,
    this.description,
    required this.durationWeeks,
    this.imageUrl,
    this.imageBytes,
    required this.countryId,
    this.lat,
    this.lng,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'description': description,
    'duration_weeks': durationWeeks,
    'image_url': imageUrl,
    'image_bytes': imageBytes,
    'country_id': countryId,
    'lat': lat,
    'lng': lng,
    'created_at': createdAt,
  };

  factory Volunteer.fromMap(Map<String, Object?> m) => Volunteer(
    id: m['id'] as int?,
    title: m['title'] as String,
    category: m['category'] as String,
    description: m['description'] as String?,
    durationWeeks: (m['duration_weeks'] as num).toInt(),
    imageUrl: m['image_url'] as String?,
    imageBytes: m['image_bytes'] as Uint8List?,
    countryId: (m['country_id'] as num).toInt(),
    lat: (m['lat'] as num?)?.toDouble(),
    lng: (m['lng'] as num?)?.toDouble(),
    createdAt: m['created_at'] as String,
  );
}
