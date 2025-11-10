import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/hotels/data/hotel.dart';
import '../../../features/hotels/data/hotel_local_service.dart';

class HotelAddPage extends StatefulWidget {
  const HotelAddPage({super.key});

  @override
  State<HotelAddPage> createState() => _HotelAddPageState();
}

class _HotelAddPageState extends State<HotelAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _adresse = TextEditingController();
  final _ville   = TextEditingController();
  final _pay     = TextEditingController();
  final _tel     = TextEditingController();
  final _email   = TextEditingController();

  bool _saving = false;
  final _svc = HotelLocalService();

  @override
  void dispose() {
    _adresse.dispose(); _ville.dispose(); _pay.dispose(); _tel.dispose(); _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final telInt = int.tryParse(_tel.text.trim());
    if (telInt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Téléphone invalide (chiffres uniquement).')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final h = Hotel(
        adresse: _adresse.text.trim(),
        ville: _ville.text.trim(),
        pay: _pay.text.trim(),
        tel: telInt,
        email: _email.text.trim(),
      );
      await _svc.add(h);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hôtel enregistré.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un hôtel')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _adresse,
                decoration: const InputDecoration(labelText: 'Adresse'),
                validator: (v) => (v==null || v.trim().isEmpty) ? 'Adresse obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ville,
                decoration: const InputDecoration(labelText: 'Ville'),
                validator: (v) => (v==null || v.trim().isEmpty) ? 'Ville obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pay,
                decoration: const InputDecoration(labelText: 'Pay (pays)'),
                validator: (v) => (v==null || v.trim().isEmpty) ? 'Pays obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tel,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Téléphone'),
                validator: (v) => (v==null || v.trim().isEmpty) ? 'Téléphone obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Email obligatoire';
                  final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!re.hasMatch(s)) return 'Email invalide';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Enregistrer'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
