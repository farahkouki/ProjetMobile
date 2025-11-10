import 'package:flutter/material.dart';
import '../hotels/hotels_admin_list_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil Admin — Agence')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.hotel),
              title: const Text('Gérer les Hôtels'),
              subtitle: const Text('Lister et ajouter des hôtels'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HotelsAdminListPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
