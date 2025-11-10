import 'package:flutter/material.dart';
import '../../../features/chambres/data/chambre.dart';
import '../../../features/chambres/data/chambre_local_service.dart';
import 'chambre_add_page.dart';

class ChambresAdminListPage extends StatefulWidget {
  final int hotelId;
  final String? hotelLabel;
  const ChambresAdminListPage({super.key, required this.hotelId, this.hotelLabel});

  @override
  State<ChambresAdminListPage> createState() => _ChambresAdminListPageState();
}

class _ChambresAdminListPageState extends State<ChambresAdminListPage> {
  final _svc = ChambreLocalService();
  List<Chambre> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _svc.listByHotel(widget.hotelId);
      setState(() { _items = list; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = Text('Chambres — ${widget.hotelLabel ?? 'Hôtel ${widget.hotelId}'}');

    Widget content;
    if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    } else if (_items.isEmpty) {
      content = const Center(child: Text('Aucune chambre.'));
    } else {
      content = Expanded(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID'), numeric: true),
                  DataColumn(label: Text('Numéro')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Prix/Nuit'), numeric: true),
                  DataColumn(label: Text('Disponible')),
                ],
                rows: _items.map((c) => DataRow(cells: [
                  DataCell(Text(c.id?.toString() ?? '—')),
                  DataCell(Text(c.numChambre)),
                  DataCell(Text(c.typeChambre)),
                  DataCell(Text(c.prixNuit.toStringAsFixed(2))),
                  DataCell(Icon(c.disponibilite ? Icons.check_circle : Icons.cancel,
                      color: c.disponibilite ? Colors.green : Colors.red)),
                ])).toList(),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: title),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text('Hôtel ID: ${widget.hotelId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChambreAddPage(hotelId: widget.hotelId),
            ),
          );
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter chambre'),
      ),
    );
  }
}
