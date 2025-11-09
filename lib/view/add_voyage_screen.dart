// lib/view/add_voyage_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/voyage.dart';
import '../../database/db_helper.dart';
import '../services/pdf_generator.dart';

class AddVoyageScreen extends StatefulWidget {
  final Voyage? voyageToEdit;
  final VoidCallback? onVoyageAdded;

  const AddVoyageScreen({
    super.key,
    this.voyageToEdit,
    this.onVoyageAdded,
  });

  @override
  State<AddVoyageScreen> createState() => _AddVoyageScreenState();
}

class _AddVoyageScreenState extends State<AddVoyageScreen> {
  final _formKey = GlobalKey<FormState>();
  final db = DBHelper.instance;

  late TextEditingController _destinationController;
  late TextEditingController _budgetController;
  late TextEditingController _descriptionController;
  DateTime? _dateDepart;
  DateTime? _dateArrivee;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController();
    _budgetController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.voyageToEdit != null) {
      _isEditing = true;
      final v = widget.voyageToEdit!;
      _destinationController.text = v.destination;
      _budgetController.text = v.budget.toStringAsFixed(0).replaceAll('.00', '');
      _descriptionController.text = v.description;
      _dateDepart = v.dateDepart;
      _dateArrivee = v.dateArrivee;
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final voyage = (widget.voyageToEdit ?? Voyage(
      destination: '',
      dateDepart: DateTime.now(),
      dateArrivee: DateTime.now().add(const Duration(days: 7)),
      budget: 0,
      description: '',
    )).copyWith(
      destination: _destinationController.text.trim(),
      dateDepart: _dateDepart ?? DateTime.now(),
      dateArrivee: _dateArrivee ?? DateTime.now().add(const Duration(days: 7)),
      budget: double.tryParse(_budgetController.text.replaceAll(' ', '')) ?? 0.0,
      description: _descriptionController.text.trim(),
    );

    try {
      if (_isEditing) {
        await db.updateVoyage(voyage);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voyage modifié avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await db.insertVoyage(voyage);
        await PdfGenerator.generatePdf(voyage);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voyage ajouté + PDF généré automatiquement !'),
            backgroundColor: Colors.indigo,
            duration: Duration(seconds: 3),
          ),
        );
      }

      widget.onVoyageAdded?.call();

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier le voyage' : 'Nouveau voyage',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _destinationController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  hintText: 'Paris, Tokyo, New York...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v!.trim().isEmpty ? 'La destination est obligatoire' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget total (TND)',
                  hintText: '1500',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.paid_outlined),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Le budget est obligatoire';
                  if (double.tryParse(v.replaceAll(' ', '')) == null) return 'Entrez un nombre valide';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  hintText: 'Voyage en famille, séminaire, vacances...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.flight_takeoff, color: Colors.indigo),
                      label: Text(
                        _dateDepart == null
                            ? 'Date départ'
                            : DateFormat('EEEE dd MMM yyyy', 'fr_FR').format(_dateDepart!),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _dateDepart ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 730)),
                          locale: const Locale('fr', 'FR'),
                        );
                        if (d != null) setState(() => _dateDepart = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.flight_land, color: Colors.indigo),
                      label: Text(
                        _dateArrivee == null
                            ? 'Date retour'
                            : DateFormat('EEEE dd MMM yyyy', 'fr_FR').format(_dateArrivee!),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _dateArrivee ?? (_dateDepart ?? DateTime.now()).add(const Duration(days: 7)),
                          firstDate: _dateDepart ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 730)),
                          locale: const Locale('fr', 'FR'),
                        );
                        if (d != null) setState(() => _dateArrivee = d);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isEditing
                      ? const Icon(Icons.save, size: 28)
                      : const Icon(Icons.flight_takeoff, size: 28),
                  label: Text(
                    _isEditing ? 'Mettre à jour le voyage' : 'Ajouter + Générer le PDF',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing ? Colors.green : Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 12,
                    shadowColor: Colors.indigo.withOpacity(0.5),
                  ),
                  onPressed: _onSave,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}