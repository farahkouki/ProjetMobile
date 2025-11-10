// lib/pages/offer_detail_page.dart
import 'package:flutter/material.dart';
import '../models/offer.dart';

class OfferDetailPage extends StatelessWidget {
  final Offer offer;

  OfferDetailPage({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Offer Details')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.title,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                offer.location,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(offer.description),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${offer.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Interested'),
                          content: Text(
                            'Thank you! In a real app we would start the booking flow.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('I am interested'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}