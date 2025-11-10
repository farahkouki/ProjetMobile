// lib/screens/volunteer_form_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../data/app_db.dart';
import '../models/country.dart';
import '../models/volunteer.dart';

class VolunteerFormScreen extends StatefulWidget {
  static const routeName = '/volunteer-form';
  final Volunteer? editing;
  const VolunteerFormScreen({super.key, this.editing});

  @override
  State<VolunteerFormScreen> createState() => _VolunteerFormScreenState();
}

class _VolunteerFormScreenState extends State<VolunteerFormScreen> {
  final _db = AppDB();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _category;
  late final TextEditingController _description;
  late final TextEditingController _duration;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;

  int? _countryId;
  List<Country> _countries = [];

  Uint8List? _pickedImage;     // image BLOB
  String? _imageUrlReadonly;   // URL existante (édition)
  String? _imageError;         // message d’erreur pour l’upload

  @override
  void initState() {
    super.initState();
    final e = widget.editing;

    // ---- Valeurs par défaut : vides si création, remplies si édition ----
    _title       = TextEditingController(text: e?.title ?? '');
    _category    = TextEditingController(text: e?.category ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _duration    = TextEditingController(text: e == null ? '' : e.durationWeeks.toString());
    _latCtrl     = TextEditingController(text: e?.lat?.toString() ?? '');
    _lngCtrl     = TextEditingController(text: e?.lng?.toString() ?? '');
    _pickedImage = e?.imageBytes;
    _imageUrlReadonly = e?.imageUrl;

    _loadCountries().then((_) {
      if (!mounted) return;
      setState(() {
        // Pays vide en création, pays de l’élément en édition sinon
        _countryId = e?.countryId;
      });
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _category.dispose();
    _description.dispose();
    _duration.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    final cs = (await _db.query('countries', orderBy: 'name ASC'))
        .map((m) => Country.fromMap(m))
        .toList();
    setState(() => _countries = cs);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _pickedImage = bytes;
      _imageUrlReadonly = null; // on arrête d’utiliser une éventuelle ancienne URL
      _imageError = null;
    });
  }

  // ---------- Validators ----------
  String? _validateRequired(String? v, {int min = 1}) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Champ obligatoire';
    if (t.length < min) return 'Minimum $min caractères';
    return null;
  }

  String? _validateInt(String? v, {int min = 1, int max = 520}) {
    final t = v?.trim() ?? '';
    final n = int.tryParse(t);
    if (n == null) return 'Nombre entier requis';
    if (n < min) return '≥ $min';
    if (n > max) return '≤ $max';
    return null;
  }

  String? _validateLat(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    final d = double.tryParse(t);
    if (d == null) return 'Nombre invalide';
    if (d < -90 || d > 90) return 'Entre -90 et 90';
    return null;
  }

  String? _validateLng(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    final d = double.tryParse(t);
    if (d == null) return 'Nombre invalide';
    if (d < -180 || d > 180) return 'Entre -180 et 180';
    return null;
  }

  bool _validateImageRequired() {
    final ok = _pickedImage != null ||
        (_imageUrlReadonly != null && _imageUrlReadonly!.isNotEmpty);
    setState(() {
      _imageError = ok ? null : 'Image obligatoire';
    });
    return ok;
  }

  bool _validateLatLngPair() {
    final hasLat = _latCtrl.text.trim().isNotEmpty;
    final hasLng = _lngCtrl.text.trim().isNotEmpty;
    if (hasLat ^ hasLng) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Renseignez latitude ET longitude, ou laissez les deux vides.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    // Valide le formulaire
    final formOk = _formKey.currentState!.validate();
    final imgOk  = _validateImageRequired();
    final pairOk = _validateLatLngPair();
    if (!formOk || !imgOk || !pairOk || _countryId == null) return;

    final lat = _latCtrl.text.trim().isEmpty ? null : double.tryParse(_latCtrl.text.trim());
    final lng = _lngCtrl.text.trim().isEmpty ? null : double.tryParse(_lngCtrl.text.trim());

    final values = Volunteer(
      id: widget.editing?.id,
      title: _title.text.trim(),
      category: _category.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      durationWeeks: int.parse(_duration.text.trim()),
      imageUrl: _imageUrlReadonly, // si pas d’upload, on garde l’URL existante (édition)
      imageBytes: _pickedImage,    // si upload, priorité au BLOB
      countryId: _countryId!,
      lat: lat,
      lng: lng,
      createdAt: widget.editing?.createdAt ?? DateTime.now().toIso8601String(),
    ).toMap();

    if (widget.editing == null) {
      await _db.insert('volunteers', values);
    } else {
      await _db.update('volunteers', values, widget.editing!.id!);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;

    final preview = _pickedImage != null
        ? ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.memory(
        _pickedImage!,
        fit: BoxFit.cover,
        height: 180,
        width: double.infinity,
      ),
    )
        : (_imageUrlReadonly != null && _imageUrlReadonly!.isNotEmpty)
        ? ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        _imageUrlReadonly!,
        fit: BoxFit.cover,
        height: 180,
        width: double.infinity,
      ),
    )
        : Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6DBE8)),
      ),
      child: const Center(child: Text('Aucune image')),
    );

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Modifier' : 'Créer')),
      body: _countries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ------- Carte Image & Upload -------
            Card(
              elevation: 0,
              color: const Color(0xFFF6F7FB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    preview,
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choisir une image'),
                    ),
                    if (_imageError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _imageError!,
                        style: const TextStyle(
                          color: Color(0xFFB00020),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    const Text(
                      'PNG/JPG, ~1–3 Mo recommandés',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ------- Carte Formulaire -------
            Card(
              elevation: 0,
              color: const Color(0xFFF6F7FB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _title,
                        decoration: const InputDecoration(
                          labelText: 'Titre',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (v) => _validateRequired(v, min: 3),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _category,
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        validator: (v) => _validateRequired(v, min: 2),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<int>(
                        value: _countryId,
                        items: _countries
                            .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _countryId = v),
                        decoration: const InputDecoration(
                          labelText: 'Pays',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        validator: (_) =>
                        _countryId == null ? 'Choisir un pays' : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _duration,
                        decoration: const InputDecoration(
                          labelText: 'Durée (semaines)',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (v) => _validateInt(v, min: 1, max: 52),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _description,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                        minLines: 3,
                        maxLines: 5,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Champ obligatoire'
                            : (v.trim().length < 10
                            ? 'Minimum 10 caractères'
                            : null),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Latitude (optionnel)',
                                prefixIcon: Icon(Icons.my_location_outlined),
                              ),
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true, signed: true),
                              validator: _validateLat,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lngCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Longitude (optionnel)',
                                prefixIcon: Icon(Icons.my_location_outlined),
                              ),
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true, signed: true),
                              validator: _validateLng,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_outlined),
                          label: Text(editing ? 'Enregistrer' : 'Créer'),
                          style: FilledButton.styleFrom(
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
