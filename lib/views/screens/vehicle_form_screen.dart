// lib/views/screens/vehicle_form_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/vehicle_model.dart';
import '../../controllers/vehicle_controller.dart';
import 'vehicle_list_screen.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;
  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- LISTE DES TYPES AVEC ICÔNES ---
  final List<Map<String, dynamic>> _vehicleTypes = [
    {'label': 'Voiture', 'icon': Icons.directions_car_rounded, 'value': 'Voiture'},
    {'label': 'Bus', 'icon': Icons.directions_bus_rounded, 'value': 'Bus'},
    {'label': 'Minivan', 'icon': Icons.airport_shuttle_rounded, 'value': 'Minivan'},
    {'label': 'Avion', 'icon': Icons.flight_takeoff_rounded, 'value': 'Avion'},
  ];

  String _selectedType = 'Voiture'; // ← Valeur sélectionnée

  final _marqueCtl = TextEditingController();
  final _modeleCtl = TextEditingController();
  final _capCtl = TextEditingController();
  final _prixCtl = TextEditingController();
  final _kmCtl = TextEditingController();
  int _dispo = 1;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      final v = widget.vehicle!;
      _selectedType = v.type;
      _marqueCtl.text = v.marque;
      _modeleCtl.text = v.modele;
      _capCtl.text = v.capacite.toString();
      _prixCtl.text = v.prixParJour.toString();
      _kmCtl.text = v.kilometrage.toString();
      _dispo = v.disponibilite;
      _imagePath = v.image;
    } else {
      _kmCtl.text = '0';
    }
  }

  Future pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) setState(() => _imagePath = file.path);
  }

  void save() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = Vehicle(
      id: widget.vehicle?.id,
      type: _selectedType,
      marque: _marqueCtl.text.trim(),
      modele: _modeleCtl.text.trim(),
      capacite: int.tryParse(_capCtl.text.trim()) ?? 0,
      prixParJour: double.tryParse(_prixCtl.text.trim()) ?? 0.0,
      disponibilite: _dispo,
      image: _imagePath,
      kilometrage: int.tryParse(_kmCtl.text.trim()) ?? 0,
      derniereVidange: widget.vehicle?.derniereVidange ?? DateTime.now(),
    );

    final controller = Provider.of<VehicleController>(context, listen: false);
    if (widget.vehicle == null) {
      await controller.addVehicle(vehicle);
    } else {
      await controller.updateVehicle(vehicle);
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const VehicleListScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vehicle != null;
    final colorPrimary = const Color(0xFF0D47A1);
    final colorBackground = const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Modifier véhicule' : 'Ajouter véhicule',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: colorPrimary,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
      ),
      body: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- IMAGE ---
              _buildImagePicker(),
              const SizedBox(height: 28),

              // --- SÉLECTEUR TYPE HORIZONTAL ---
              _buildSectionTitle('Type de véhicule'),
              const SizedBox(height: 12),
              _typeSelector(),
              const SizedBox(height: 28),

              // --- FORMULAIRE ---
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(controller: _marqueCtl, label: 'Marque', icon: Icons.local_taxi_rounded),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _modeleCtl, label: 'Modèle', icon: Icons.design_services_rounded),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _capCtl, label: 'Capacité (pers.)', icon: Icons.people_outline, type: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _prixCtl, label: 'Prix / jour (DT)', icon: Icons.monetization_on_outlined, type: const TextInputType.numberWithOptions(decimal: true)),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _kmCtl, label: 'Kilométrage actuel', icon: Icons.speed_rounded, type: TextInputType.number),
                    const SizedBox(height: 24),

                    // --- DISPONIBILITÉ ---
                    SwitchListTile(
                      value: _dispo == 1,
                      onChanged: (v) => setState(() => _dispo = v ? 1 : 0),
                      title: const Text('Véhicule disponible', style: TextStyle(fontWeight: FontWeight.w600)),
                      activeColor: colorPrimary,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 32),

                    // --- BOUTON ---
                    _buildSubmitButton(isEdit, colorPrimary),
                  ],
                ),
              ),
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
      child: GestureDetector(
        onTap: pickImage,
        child: Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _imagePath != null
                ? (kIsWeb
                ? Image.network(_imagePath!, width: double.infinity, height: 190, fit: BoxFit.cover)
                : Image.file(File(_imagePath!), width: double.infinity, height: 190, fit: BoxFit.cover))
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_rounded, size: 54, color: const Color(0xFF0D47A1)),
                const SizedBox(height: 12),
                Text("Ajouter une photo", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
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
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (s) {
          if (s == null || s.isEmpty) return 'Champ requis';
          if (type == TextInputType.number || type == const TextInputType.numberWithOptions(decimal: true)) {
            if (double.tryParse(s) == null) return 'Entrez un nombre valide';
          }
          return null;
        },
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
      ),
    );
  }

  // --- BOUTON SOUMETTRE ---
  Widget _buildSubmitButton(bool isEdit, Color color) {
    return ElasticInUp(
      duration: const Duration(milliseconds: 600),
      child: ElevatedButton(
        onPressed: save,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 10,
          shadowColor: color.withOpacity(0.4),
        ),
        child: Text(
          isEdit ? 'Enregistrer les modifications' : 'Ajouter le véhicule',
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}