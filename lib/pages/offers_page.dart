// lib/pages/offers_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/offer_repository.dart';
import '../widgets/offer_card.dart';
import 'offer_detail_page.dart';

class OffersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AuthService().user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Voyage Offers'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
              Navigator.of(context).pushReplacementNamed('/signin');
            },
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 1,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: OfferRepository.offers.length,
          itemBuilder: (context, index) {
            final offer = OfferRepository.offers[index];
            return OfferCard(
              offer: offer,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OfferDetailPage(offer: offer),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}