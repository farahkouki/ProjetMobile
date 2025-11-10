import 'package:flutter/material.dart';
import '../data/app_db.dart';
import '../models/country.dart';
import '../models/volunteer.dart';
import 'volunteer_form_screen.dart';
import 'country_list_screen.dart';
import 'search_ai_screen.dart';
import 'volunteer_detail_screen.dart';

class VolunteerListScreen extends StatefulWidget {
  const VolunteerListScreen({super.key});

  @override
  State<VolunteerListScreen> createState() => _VolunteerListScreenState();
}

class _VolunteerListScreenState extends State<VolunteerListScreen> {
  final _db = AppDB();
  int? _selectedCountryId;
  List<Country> _countries = [];
  List<_VolunteerWithCountry> _items = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final cs = (await _db.query('countries', orderBy: 'name ASC'))
        .map((m) => Country.fromMap(m))
        .toList();
    setState(() => _countries = cs);
    await _loadVolunteers();
  }

  Future<void> _loadVolunteers() async {
    final where = _selectedCountryId == null ? null : 'country_id = ?';
    final whereArgs = _selectedCountryId == null ? null : [_selectedCountryId];
    final rows = await _db.query(
      'volunteers',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'id DESC',
    );

    final mapCountries = {for (var c in _countries) c.id!: c.name};
    final list = rows.map((r) {
      final v = Volunteer.fromMap(r);
      return _VolunteerWithCountry(v, mapCountries[v.countryId] ?? '');
    }).toList();

    setState(() => _items = list);
  }

  Future<void> _deleteItem(Volunteer v) async {
    await _db.delete('volunteers', v.id!);
    await _loadVolunteers();
  }

  Widget _buildChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        const SizedBox(width: 8),
        FilterChip(
          avatar: const Icon(Icons.filter_alt_outlined, size: 16),
          label: const Text('Filtrer'),
          selected: _selectedCountryId == null,
          onSelected: (_) => setState(() {
            _selectedCountryId = null;
            _loadVolunteers();
          }),
        ),
        const SizedBox(width: 4),
        ..._countries.map((c) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilterChip(
            label: Text(c.name),
            selected: _selectedCountryId == c.id,
            onSelected: (_) => setState(() {
              _selectedCountryId = c.id;
              _loadVolunteers();
            }),
          ),
        )),
        const SizedBox(width: 8),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        title: const Text('Volontariat'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Recherche & IA',
            onPressed: () =>
                Navigator.pushNamed(context, SearchAIScreen.routeName),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Gérer les pays',
            onPressed: () => Navigator
                .pushNamed(context, CountryListScreen.routeName)
                .then((_) => _loadAll()),
            icon: const Icon(Icons.public),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator
            .pushNamed(context, VolunteerFormScreen.routeName)
            .then((_) => _loadVolunteers()),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadVolunteers,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            const SizedBox(height: 8),
            _buildChips(),
            const SizedBox(height: 8),
            ..._items.map((item) => _VolunteerCard(
              data: item,
              onEdit: () => Navigator
                  .pushNamed(context, VolunteerFormScreen.routeName,
                  arguments: item.v)
                  .then((_) => _loadVolunteers()),
              onDelete: () => _deleteItem(item.v),
            )),
            if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Aucune opportunité')),
              ),
          ],
        ),
      ),
      // ⚠️ ne pas mettre 'const' car pas 100% const
      bottomNavigationBar: NavigationBar(
        selectedIndex: 3,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.flight), label: 'Voyages'),
          NavigationDestination(icon: Icon(Icons.directions_bus), label: 'Transports'),
          NavigationDestination(icon: Icon(Icons.volunteer_activism), label: 'Volontariat'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _VolunteerWithCountry {
  final Volunteer v;
  final String countryName;
  _VolunteerWithCountry(this.v, this.countryName);
}

class _VolunteerCard extends StatelessWidget {
  final _VolunteerWithCountry data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VolunteerCard({
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final v = data.v;
    final countryName = data.countryName;

    Widget? headerImage;
    if (v.imageBytes != null && v.imageBytes!.isNotEmpty) {
      headerImage = Image.memory(v.imageBytes!, fit: BoxFit.cover);
    } else if (v.imageUrl != null && v.imageUrl!.isNotEmpty) {
      headerImage = Image.network(v.imageUrl!, fit: BoxFit.cover);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 0,
      color: const Color(0xFFF6F7FB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headerImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: AspectRatio(aspectRatio: 16 / 9, child: headerImage),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.category,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8E97A6))),
                const SizedBox(height: 6),
                Text(v.title,
                    style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  v.description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.place, size: 16, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(countryName, style: const TextStyle(color: Color(0xFF6B7280))),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 16, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text('${v.durationWeeks} semaines',
                        style: const TextStyle(color: Color(0xFF6B7280))),
                    const Spacer(),

                    // Détails -> écran de détails “lecture seule”
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(84, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () async {
                        final res = await Navigator.pushNamed(
                          context,
                          VolunteerDetailScreen.routeName,
                          arguments: v.id,
                        );
                        if (res == 'deleted') {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Volontariat supprimé')),
                          );
                        }
                      },
                      child: const Text('Détails'),
                    ),

                    // ✏️ Modifier -> ouvre le formulaire prérempli
                    IconButton(
                      tooltip: 'Modifier',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEdit,
                    ),

                    // 🗑️ Supprimer
                    IconButton(
                      tooltip: 'Supprimer',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
