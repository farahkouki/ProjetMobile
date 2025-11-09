// lib/views/screens/add_edit_vehicle_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';

import '../../models/vehicle_model.dart';
import '../../controllers/vehicle_controller.dart';
import 'vehicle_list_screen.dart'; // ← AJOUTÉ

class AddEditVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;
  const AddEditVehicleScreen({super.key, this.vehicle});

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marqueCtl = TextEditingController();
  final _modeleCtl = TextEditingController();
  final _capaciteCtl = TextEditingController();
  final _prixCtl = TextEditingController();
  final _kmCtl = TextEditingController();

  // --- LISTE DES TYPES AVEC ICÔNES ---
  final List<Map<String, dynamic>> _vehicleTypes = [
    {'label': 'Voiture', 'icon': Icons.directions_car_rounded, 'value': 'Voiture'},
    {'label': 'Bus', 'icon': Icons.directions_bus_rounded, 'value': 'Bus'},
    {'label': 'Minivan', 'icon': Icons.airport_shuttle_rounded, 'value': 'Minivan'},
    {'label': 'Avion', 'icon': Icons.flight_takeoff_rounded, 'value': 'Avion'},
  ];

  String _selectedType = 'Voiture';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      final v = widget.vehicle!;
      _marqueCtl.text = v.marque;
      _modeleCtl.text = v.modele;
      _capaciteCtl.text = v.capacite.toString();
      _prixCtl.text = v.prixParJour.toString();
      _kmCtl.text = v.kilometrage.toString();
      _selectedType = v.type;
      _imagePath = v.image;
    } else {
      _kmCtl.text = '0';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = Vehicle(
      id: widget.vehicle?.id,
      marque: _marqueCtl.text.trim(),
      modele: _modeleCtl.text.trim(),
      type: _selectedType,
      capacite: int.tryParse(_capaciteCtl.text.trim()) ?? 0,
      prixParJour: double.tryParse(_prixCtl.text.trim()) ?? 0.0,
      image: _imagePath,
      kilometrage: int.tryParse(_kmCtl.text.trim()) ?? 0,
      derniereVidange: widget.vehicle?.derniereVidange ?? DateTime.now(),
    );

    final vc = Provider.of<VehicleController>(context, listen: false);
    widget.vehicle == null
        ? await vc.addVehicle(vehicle)
        : await vc.updateVehicle(vehicle);

    // REDIRECTION DIRECTE VERS LA LISTE
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const VehicleListScreen()),
            (route) => false, // Supprime tout l'historique
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vehicle != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Modifier le véhicule' : 'Ajouter un véhicule',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
          ),
        ),
      ),
      body: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _buildImagePicker(),
              const SizedBox(height: 28),

              _buildSectionTitle('Type de véhicule'),
              const SizedBox(height: 12),
              _typeSelector(),
              const SizedBox(height: 28),

              _textField(_marqueCtl, 'Marque', Icons.local_taxi_rounded),
              const SizedBox(height: 16),
              _textField(_modeleCtl, 'Modèle', Icons.design_services_rounded),
              const SizedBox(height: 16),
              _textField(_capaciteCtl, 'Capacité (pers.)', Icons.people_outline, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _textField(_prixCtl, 'Prix / jour (DT)', Icons.monetization_on_rounded, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),
              _textField(_kmCtl, 'Kilométrage actuel', Icons.speed_rounded, keyboardType: TextInputType.number),
              const SizedBox(height: 32),

              _buildSubmitButton(isEdit),
            ],
          ),
        ),
      ),
    );
  }

  // --- SÉLECTEUR TYPE HORIZONTAL ---
  Widget _typeSelector() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SizedBox(
        height: 70,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _vehicleTypes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final type = _vehicleTypes[index];
            final isSelected = _selectedType == type['value'];

            return GestureDetector(
              onTap: () => setState(() => _selectedType = type['value']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)])
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? const Color(0xFF0D47A1).withOpacity(0.4) : Colors.black.withOpacity(0.06),
                      blurRadius: isSelected ? 14 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type['icon'],
                      color: isSelected ? Colors.white : const Color(0xFF0D47A1),
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      type['label'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- IMAGE PICKER ---
  Widget _buildImagePicker() {
    return ZoomIn(
      duration: const Duration(milliseconds: 400),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _pickImage,
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _imagePath == null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_rounded, size: 54, color: const Color(0xFF0D47A1)),
                const SizedBox(height: 12),
                Text("Ajouter une photo", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            )
                : (kIsWeb
                ? Image.network(_imagePath!, fit: BoxFit.cover, width: double.infinity, height: 190)
                : Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity, height: 190)),
          ),
        ),
      ),
    );
  }

  // --- SECTION TITLE ---
  Widget _buildSectionTitle(String title) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 400),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
      ),
    );
  }

  // --- TEXT FIELD ---
  Widget _textField(TextEditingController ctl, String label, IconData icon, {TextInputType? keyboardType}) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: TextFormField(
        controller: ctl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2)),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Champ requis';
          if (keyboardType == TextInputType.number || keyboardType == const TextInputType.numberWithOptions(decimal: true)) {
            if (double.tryParse(v) == null) return 'Nombre invalide';
          }
          return null;
        },
      ),
    );
  }

  // --- BOUTON ---
  Widget _buildSubmitButton(bool isEdit) {
    return ElasticInUp(
      duration: const Duration(milliseconds: 600),
      child: ElevatedButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.save_rounded, size: 28),
        label: Text(
          isEdit ? 'Enregistrer' : 'Ajouter',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 10,
          shadowColor: const Color(0xFF0D47A1).withOpacity(0.4),
        ),
      ),
    );
  }
}