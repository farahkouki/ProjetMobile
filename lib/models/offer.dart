// lib/models/offer.dart
class Offer {
  final String id;
  final String title;
  final String location;
  final String description;
  final double price;
  
  Offer({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.price,
  });
}