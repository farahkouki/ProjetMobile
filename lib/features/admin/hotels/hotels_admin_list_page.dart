// lib/features/admin/hotels/hotels_admin_list_page.dart
import 'package:flutter/material.dart';
import '../../../features/hotels/data/hotel.dart';
import '../../../features/hotels/data/hotel_local_service.dart';
import 'hotel_add_page.dart';
// NEW: import the chambres list page (relative path from /admin/hotels/)
import '../chambres/chambres_admin_list_page.dart';

class HotelsAdminListPage extends StatefulWidget {
  const HotelsAdminListPage({super.key});

  @override
  State<HotelsAdminListPage> createState() => _HotelsAdminListPageState();
}

class _HotelsAdminListPageState extends State<HotelsAdminListPage> {
  final _svc = HotelLocalService();
  final _searchCtrl = TextEditingController();

  List<Hotel> _all = [];
  List<Hotel> _filtered = [];
  bool _loading = true;
  String? _error;

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _all = await _svc.list();
      _applyFilterAndSort();
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _applyFilterAndSort() {
    final q = _searchCtrl.text.trim().toLowerCase();
    _filtered = q.isEmpty
        ? List.of(_all)
        : _all.where((h) {
      final s = '${h.ville} ${h.pay} ${h.adresse} ${h.email} ${h.tel}';
      return s.toLowerCase().contains(q);
    }).toList();

    _filtered.sort((a, b) {
      int r;
      switch (_sortColumnIndex) {
        case 0: r = (a.id ?? 0).compareTo(b.id ?? 0); break;
        case 1: r = a.adresse.toLowerCase().compareTo(b.adresse.toLowerCase()); break;
        case 2: r = a.ville.toLowerCase().compareTo(b.ville.toLowerCase()); break;
        case 3: r = a.pay.toLowerCase().compareTo(b.pay.toLowerCase()); break;
        case 4: r = a.tel.compareTo(b.tel); break;
        case 5: r = a.email.toLowerCase().compareTo(b.email.toLowerCase()); break;
        default: r = 0;
      }
      return _sortAscending ? r : -r;
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _applyFilterAndSort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final toolbar = Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Rechercher (adresse, ville, pays, email, tel)…',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(_applyFilterAndSort),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ],
    );

    Widget content;
    if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    } else if (_filtered.isEmpty) {
      content = const Center(child: Text('Aucun hôtel.'));
    } else {
      content = Expanded(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView( // vertical
            child: SingleChildScrollView( // horizontal
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  DataColumn(label: const Text('ID'), numeric: true,
                      onSort: (i, a) => _onSort(i, a)),
                  DataColumn(label: const Text('Adresse'),
                      onSort: (i, a) => _onSort(i, a)),
                  DataColumn(label: const Text('Ville'),
                      onSort: (i, a) => _onSort(i, a)),
                  DataColumn(label: const Text('Pays'),
                      onSort: (i, a) => _onSort(i, a)),
                  DataColumn(label: const Text('Téléphone'), numeric: true,
                      onSort: (i, a) => _onSort(i, a)),
                  DataColumn(label: const Text('Email'),
                      onSort: (i, a) => _onSort(i, a)),
                  // NEW column header
                  const DataColumn(label: Text('Actions')),
                ],
                // NEW: add the Actions cell with "Chambres" button
                rows: _filtered.map((h) => DataRow(cells: [
                  DataCell(Text(h.id?.toString() ?? '—')),
                  DataCell(Text(h.adresse)),
                  DataCell(Text(h.ville)),
                  DataCell(Text(h.pay)),
                  DataCell(Text(h.tel.toString())),
                  DataCell(Text(h.email)),
                  DataCell(
                    TextButton.icon(
                      icon: const Icon(Icons.meeting_room),
                      label: const Text('Chambres'),
                      onPressed: (h.id == null)
                          ? null // shouldn’t happen, but safe-guard
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChambresAdminListPage(
                              hotelId: h.id!,
                              hotelLabel: '${h.ville} • ${h.pay}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ])).toList(),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hôtels (Admin)')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            toolbar,
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HotelAddPage()),
          );
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}
