import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../data/app_db.dart';
import '../models/volunteer.dart';
import 'volunteer_form_screen.dart';

class VolunteerDetailScreen extends StatefulWidget {
  static const routeName = '/volunteer-detail';

  final int volunteerId;
  const VolunteerDetailScreen({super.key, required this.volunteerId});

  @override
  State<VolunteerDetailScreen> createState() => _VolunteerDetailScreenState();
}

class _VolunteerDetailScreenState extends State<VolunteerDetailScreen> {
  final _db = AppDB();
  Map<String, Object?>? _row; // jointure volunteer + country
  bool _loading = true;

  Future<void> _load() async {
    setState(() => _loading = true);

    // On charge l’item avec le nom du pays
    final rows = await _db.database.then((db) => db.rawQuery('''
      SELECT v.*, c.name AS country_name
      FROM volunteers v
      JOIN countries c ON c.id = v.country_id
      WHERE v.id = ?
      LIMIT 1
    ''', [widget.volunteerId]));

    setState(() {
      _row = rows.isNotEmpty ? rows.first : null;
      _loading = false;
    });
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Confirmer la suppression de ce volontariat ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      await _db.delete('volunteers', widget.volunteerId);
      if (!mounted) return;
      Navigator.pop(context, 'deleted'); // on revient à la liste
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final row = _row;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails'),
        actions: [
          // CRAYON MODIFIER
          if (!_loading && row != null)
            IconButton(
              tooltip: 'Modifier',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                // On convertit la ligne en modèle Volunteer pour le formulaire
                final v = Volunteer.fromMap(row);
                await Navigator.pushNamed(
                  context,
                  VolunteerFormScreen.routeName,
                  arguments: v,
                );
                if (!mounted) return;
                _load(); // recharger après édition
              },
            ),
          // SUPPRIMER
          IconButton(
            tooltip: 'Supprimer',
            icon: const Icon(Icons.delete_outline),
            onPressed: _loading ? null : _delete,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (row == null)
          ? const Center(child: Text('Introuvable'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image
          _HeaderImage(
            networkUrl: (row['image_url'] as String?) ?? '',
            bytes: row['image_bytes'] as Uint8List?,
          ),
          const SizedBox(height: 16),

          // Catégorie
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text('${row['category']}'),
              avatar: const Icon(Icons.category_outlined, size: 18),
            ),
          ),
          const SizedBox(height: 8),

          // Titre
          Text(
            '${row['title']}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          // Meta (pays + durée)
          Row(
            children: [
              const Icon(Icons.place, size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text('${row['country_name']}', style: const TextStyle(color: Color(0xFF6B7280))),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text('${row['duration_weeks']} semaines',
                  style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          if ((row['description'] as String?)?.isNotEmpty == true) ...[
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('${row['description']}'),
            const SizedBox(height: 16),
          ],

          // Coordonnées si présentes
          if (row['lat'] != null && row['lng'] != null) ...[
            const Text('Localisation (lat, lng)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('${row['lat']} , ${row['lng']}'),
            const SizedBox(height: 16),
          ],

          // Date de création
          const Text('Créé le', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('${row['created_at']}'),
        ],
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final String networkUrl;
  final Uint8List? bytes;
  const _HeaderImage({required this.networkUrl, required this.bytes});

  @override
  Widget build(BuildContext context) {
    Widget? image;
    if (bytes != null && bytes!.isNotEmpty) {
      image = Image.memory(bytes!, fit: BoxFit.cover);
    } else if (networkUrl.isNotEmpty) {
      image = Image.network(networkUrl, fit: BoxFit.cover);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: image ??
            Container(
              color: const Color(0xFFE9ECF5),
              child: const Center(child: Text('Aucune image')),
            ),
      ),
    );
  }
}
