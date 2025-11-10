import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/app_db.dart';
import '../utils/ai_rank.dart';

class SearchAIScreen extends StatefulWidget {
  static const routeName = '/search-ai';
  const SearchAIScreen({super.key});

  @override
  State<SearchAIScreen> createState() => _SearchAIScreenState();
}

class _SearchAIScreenState extends State<SearchAIScreen> {
  final _db = AppDB();

  final _qCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _profileCtrl = TextEditingController(text: "J'aime l'environnement et l'éducation des enfants.");
  double? _lat, _lng;
  double _maxKm = 100;
  int _durationMin = 1, _durationMax = 12;

  bool _loading = false;
  List<Map<String, Object?>> _items = [];
  Map<String, Object?> _facets = {};

  Future<void> _getMyLocation() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission localisation refusée')));
        return;
      }
    }
    final pos = await Geolocator.getCurrentPosition();
    setState(() { _lat = pos.latitude; _lng = pos.longitude; });
  }

  Future<void> _doSearch() async {
    setState(() { _loading = true; });
    try {
      final res = await _db.search(
        q: _qCtrl.text.trim(),
        category: _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
        durationMin: _durationMin,
        durationMax: _durationMax,
        lat: _lat, lng: _lng, maxKm: _lat==null ? null : _maxKm,
        sort: (_lat!=null && _lng!=null) ? 'distance' : 'new',
        page: 1, limit: 50,
      );
      final fac = await _db.facets(q: _qCtrl.text.trim());
      setState(() {
        _items = (res['items'] as List).cast<Map<String, Object?>>();
        _facets = fac;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur recherche: $e')));
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _rankAI() async {
    if (_items.isEmpty) return;
    setState(() { _loading = true; });
    try {
      final ranked = rankByProfile(profileText: _profileCtrl.text.trim(), items: _items);
      setState(() { _items = ranked; });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur IA: $e')));
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  void dispose() {
    _qCtrl.dispose(); _categoryCtrl.dispose(); _profileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facetsCountries = (_facets['countries'] as List?) ?? [];
    final facetsCategories = (_facets['categories'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Recherche & IA')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextFormField(controller: _qCtrl, decoration: const InputDecoration(labelText: 'Recherche texte (FTS5)')),
          const SizedBox(height: 8),
          TextFormField(controller: _categoryCtrl, decoration: const InputDecoration(labelText: 'Catégorie (ex: Éducation, Environnement)')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Durée min: $_durationMin semaines'),
                  Slider(value: _durationMin.toDouble(), min: 1, max: 52, divisions: 51, label: '$_durationMin',
                      onChanged: (v)=> setState(()=> _durationMin = v.toInt())),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Durée max: $_durationMax semaines'),
                  Slider(value: _durationMax.toDouble(), min: 1, max: 52, divisions: 51, label: '$_durationMax',
                      onChanged: (v)=> setState(()=> _durationMax = v.toInt())),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text(_lat==null ? 'Localisation: non définie' : 'Localisation: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}')),
            IconButton(onPressed: _getMyLocation, icon: const Icon(Icons.my_location)),
          ]),
          if (_lat != null) ...[
            const SizedBox(height: 8),
            Text('Rayon max: ${_maxKm.toInt()} km'),
            Slider(value: _maxKm, min: 10, max: 1000, divisions: 99, label: '${_maxKm.toInt()}',
                onChanged: (v)=> setState(()=> _maxKm = v)),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: _loading ? null : _doSearch, icon: const Icon(Icons.search), label: const Text('Rechercher')),
          const SizedBox(height: 8),
          TextFormField(controller: _profileCtrl, decoration: const InputDecoration(labelText: 'Profil (IA) : centres d’intérêt')),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: _loading ? null : _rankAI, icon: const Icon(Icons.auto_awesome), label: const Text('Trier par pertinence IA')),
          const Divider(height: 24),
          if (facetsCountries.isNotEmpty) ...[
            const Text('Facettes pays:'),
            Wrap(spacing: 8, children: facetsCountries
                .map((e)=> Chip(label: Text('${e['country']} (${e['count']})'))).toList().cast<Widget>()),
            const SizedBox(height: 8),
          ],
          if (facetsCategories.isNotEmpty) ...[
            const Text('Facettes catégories:'),
            Wrap(spacing: 8, children: facetsCategories
                .map((e)=> Chip(label: Text('${e['category']} (${e['count']})'))).toList().cast<Widget>()),
            const SizedBox(height: 8),
          ],
          if (_loading) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          ..._items.map((it) => Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: it['imageUrl']!=null ? Image.network(it['imageUrl'] as String, width: 60, fit: BoxFit.cover) : null,
              title: Text((it['title'] ?? '') as String),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${it['category']} • ${(it['country'] as Map?)?['name'] ?? ''}'),
                  if (it['distanceKm'] != null) Text('Distance: ${it['distanceKm']} km'),
                  if (it['score'] != null) Text('IA: ${(((it['score'] as num))*100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          )),
          if (_items.isEmpty && !_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Aucun résultat')),
            ),
        ],
      ),
    );
  }
}
