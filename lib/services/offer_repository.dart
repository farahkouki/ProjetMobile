// lib/services/offer_repository.dart
import '../models/offer.dart';

class OfferRepository {
  static final List<Offer> offers = [
    Offer(
      id: '1',
      title: 'Weekend in Paris',
      location: 'Paris, France',
      description: '2 nights, hotel included, city tour',
      price: 299.0,
    ),
    Offer(
      id: '2',
      title: 'Relaxing Tunisian Beach',
      location: 'Hammamet, Tunisia',
      description: 'All inclusive, 5 nights, sea view',
      price: 399.0,
    ),
    Offer(
      id: '3',
      title: 'Discover Rome',
      location: 'Rome, Italy',
      description: '4 nights, guided visits of the Colosseum and Vatican',
      price: 359.0,
    ),
  ];

  static Offer? findById(String id) =>
      offers.firstWhere((o) => o.id == id, orElse: () => offers[0]);
}