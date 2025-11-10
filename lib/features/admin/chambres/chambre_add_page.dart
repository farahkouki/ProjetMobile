import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/chambres/data/chambre.dart';
import '../../../features/chambres/data/chambre_local_service.dart';

class ChambreAddPage extends StatefulWidget {
  final int hotelId;
  const ChambreAddPage({super.key, required this.hotelId});

  @override
  State<ChambreAddPage> createState() => _ChambreAddPageState();
}

class _ChambreAddPageState extends State<ChambreAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _numCtrl  = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  bool _dispo = true;

  bool _saving = false;
  final _svc = ChambreLocalService();

  @override
  void dispose() {
    _numCtrl.dispose(); _typeCtrl.dispose(); _prixCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final prix = double.tryParse(_prixCtrl.text.trim().replaceAll(',', '.'));
    if (prix == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prix invalide.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final c = Chambre(
        hotelId: widget.hotelId,
        numChambre: _numCtrl.text.trim(),
        typeChambre: _typeCtrl.text.trim(),
        prixNuit: prix,
        disponibilite: _dispo,
      );
      await _svc.add(c);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chambre ajoutée.')),
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
      appBar: AppBar(title: const Text('Ajouter une chambre')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(children: [
              Text('Hôtel ID: ${widget.hotelId}'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numCtrl,
                decoration: const InputDecoration(labelText: 'Numéro de chambre'),
                validator: (v) => (v==null || v.trim().isEmpty) ? 'Numéro obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeCtrl,
                decoration: const InputDecoration(labelText: 'Type de chambre'),
                validator: (v) => (v==null || v.trim().isEmpty) ? 'Type obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prixCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]'))],
                decoration: const InputDecoration(labelText: 'Prix par nuit'),
                validator: (v) => (v==null || v.trim().isEmpty) ? 'Prix obligatoire' : null,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Disponible'),
                value: _dispo,
                onChanged: (v) => setState(() => _dispo = v),
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
