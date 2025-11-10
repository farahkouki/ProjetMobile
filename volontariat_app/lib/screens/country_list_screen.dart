import 'package:flutter/material.dart';
import '../data/app_db.dart';
import '../models/country.dart';
import 'package:sqflite/sqflite.dart';

class CountryListScreen extends StatefulWidget {
  static const routeName = '/countries';
  const CountryListScreen({super.key});

  @override
  State<CountryListScreen> createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
  final _db = AppDB();
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  List<Country> _countries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cs = (await _db.query('countries', orderBy: 'name ASC'))
        .map((m) => Country.fromMap(m))
        .toList();
    setState(() => _countries = cs);
  }

  // RegExp compatible Dart (lettres latines + accents, espaces, tirets, apostrophes)
  // Plage \u00C0-\u024F couvre la majorité des lettres accentuées latines.
  String? _validateCountry(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Nom obligatoire';
    if (t.length < 2) return 'Minimum 2 caractères';
    final reg = RegExp(r"^[A-Za-z\u00C0-\u024F\s\-']+$");
    if (!reg.hasMatch(t)) return 'Seulement lettres, espaces, tirets, apostrophes';
    return null;
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _controller.text.trim();
    try {
      await _db.insert('countries', {'name': name});
      _controller.clear();
      await _load();
    } on DatabaseException catch (e) {
      // Détection contrainte UNIQUE (si dispo) sinon fallback via toString()
      final isUnique = e.isUniqueConstraintError() || e.toString().toLowerCase().contains('unique');
      final msg = isUnique ? 'Ce pays existe déjà.' : 'Erreur lors de l’ajout.';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _edit(Country c) async {
    final ctrl = TextEditingController(text: c.name);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Modifier le pays'),
        content: TextFormField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nom du pays'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result == null) return;

    final error = _validateCountry(result);
    if (error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    try {
      await _db.update('countries', {'name': result}, c.id!);
      await _load();
    } on DatabaseException catch (e) {
      final isUnique = e.isUniqueConstraintError() || e.toString().toLowerCase().contains('unique');
      final msg = isUnique ? 'Ce pays existe déjà.' : 'Erreur lors de la mise à jour.';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _delete(Country c) async {
    await _db.delete('countries', c.id!); // ON DELETE CASCADE côté DB
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pays')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ajouter un pays',
                        prefixIcon: Icon(Icons.public),
                      ),
                      validator: _validateCountry,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _add, child: const Text('Ajouter')),
                ],
              ),
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: ListView.builder(
              itemCount: _countries.length,
              itemBuilder: (_, i) {
                final c = _countries[i];
                return ListTile(
                  title: Text(c.name),
                  leading: const Icon(Icons.flag_outlined),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Modifier',
                        onPressed: () => _edit(c),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Supprimer',
                        onPressed: () => _delete(c),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
