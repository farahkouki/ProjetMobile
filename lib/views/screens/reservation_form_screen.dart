// lib/views/screens/reservation_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/vehicle_model.dart';
import '../../models/driver_model.dart';
import '../../models/reservation_model.dart';
import '../../controllers/reservation_controller.dart';
import '../../controllers/vehicle_controller.dart';
import '../../controllers/driver_controller.dart';
import '../../core/constants/app_colors.dart';

class ReservationFormScreen extends StatefulWidget {
  final Vehicle vehicle;
  const ReservationFormScreen({super.key, required this.vehicle});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  String _phone = '';
  Driver? _selectedDriver;
  DateTime? _startDate;
  DateTime? _endDate;
  late double _total;

  // --- LISTE DES TYPES ---
  final List<Map<String, dynamic>> _vehicleTypes = [
    {'label': 'Voiture', 'icon': Icons.directions_car, 'value': 'voiture'},
    {'label': 'Bus', 'icon': Icons.directions_bus, 'value': 'bus'},
    {'label': 'Minivan', 'icon': Icons.airport_shuttle, 'value': 'minivan'},
    {'label': 'Avion', 'icon': Icons.flight, 'value': 'avion'},
  ];

  String? _selectedType; // ← Valeur sélectionnée

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 1));
    _total = widget.vehicle.prixParJour * 2;
    _selectedType = widget.vehicle.type.toLowerCase(); // Pré-sélection
  }

  void _calculateTotal() {
    if (_startDate != null && _endDate != null) {
      final days = _endDate!.difference(_startDate!).inDays + 1;
      setState(() => _total = days * widget.vehicle.prixParJour);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = Provider.of<VehicleController>(context, listen: false);
    final rc = Provider.of<ReservationController>(context, listen: false);
    final drivers = Provider.of<DriverController>(context).drivers;

    if (drivers.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Réservation')),
        body: const Center(child: Text('Aucun chauffeur disponible')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Réserver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepBlue,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
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
              // --- TYPE DE VÉHICULE ---
              _buildSectionTitle(''),
              const SizedBox(height: 12),
              _typeSelector(),
              const SizedBox(height: 28),

              // --- VÉHICULE ---
              _buildSectionTitle('Véhicule sélectionné'),
              const SizedBox(height: 12),
              _vehicleCard(),
              const SizedBox(height: 28),

              // --- CHAUFFEUR ---
              _buildSectionTitle('Chauffeur'),
              const SizedBox(height: 12),
              _driverDropdown(drivers),
              const SizedBox(height: 28),

              // --- CLIENT ---
              _buildSectionTitle('Informations client'),
              const SizedBox(height: 12),
              _textField(_nameCtl, 'Nom complet', Icons.person_outline),
              const SizedBox(height: 16),
              _phoneField(),
              const SizedBox(height: 28),

              // --- PÉRIODE ---
              _buildSectionTitle('Période de location'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _datePicker('Début', _startDate, (d) {
                    setState(() {
                      _startDate = d;
                      _calculateTotal();
                    });
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _datePicker('Fin', _endDate, (d) {
                    setState(() {
                      _endDate = d;
                      _calculateTotal();
                    });
                  }),
                ),
              ]),
              const SizedBox(height: 28),

              // --- TOTAL ---
              _totalCard(),
              const SizedBox(height: 32),

              // --- BOUTON ---
              _submitButton(rc, vc),
            ],
          ),
        ),
      ),
    );
  }

  // --- SÉLECTEUR HORIZONTAL DE TYPE ---
  Widget _typeSelector() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: SizedBox(
        height: 70,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _vehicleTypes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final type = _vehicleTypes[index];
            final isSelected = _selectedType == type['value'];

            return GestureDetector(
              onTap: () => setState(() => _selectedType = type['value']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.deepBlue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.deepBlue : const Color(0xFFE0E0E0), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? AppColors.deepBlue.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                      blurRadius: isSelected ? 12 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type['icon'],
                      color: isSelected ? Colors.white : AppColors.deepBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type['label'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

  // --- CARTE VÉHICULE ---
  Widget _vehicleCard() {
    return ElasticIn(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF0D47A1)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(_getVehicleIcon(widget.vehicle.type), color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.vehicle.marque} ${widget.vehicle.modele}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                  Text('${widget.vehicle.prixParJour} DT/jour', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // --- Icône dynamique ---
  IconData _getVehicleIcon(String type) {
    final map = _vehicleTypes.firstWhere((t) => t['value'] == type.toLowerCase(), orElse: () => _vehicleTypes[0]);
    return map['icon'];
  }

  // --- CHAUFFEUR DROPDOWN ---
  Widget _driverDropdown(List<Driver> drivers) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: DropdownButtonFormField<Driver>(
        value: _selectedDriver,
        decoration: _inputDecoration('Sélectionner un chauffeur', Icons.person),
        items: drivers.map((d) => DropdownMenuItem(
          value: d,
          child: Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: AppColors.deepBlue.withOpacity(0.1), child: Text(d.nom[0], style: const TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Text('${d.nom}', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(' • ${d.experience} ans', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        )).toList(),
        onChanged: (d) => setState(() => _selectedDriver = d),
        validator: (d) => d == null ? 'Choisissez un chauffeur' : null,
      ),
    );
  }

  // --- CHAMP TÉLÉPHONE ---
  Widget _phoneField() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: IntlPhoneField(
        decoration: _inputDecoration('Téléphone', Icons.phone),
        initialCountryCode: 'TN',
        onChanged: (phone) => _phone = phone.completeNumber,
      ),
    );
  }

  // --- SÉLECTEUR DE DATE ---
  Widget _datePicker(String label, DateTime? date, Function(DateTime) onSelect) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: AppColors.deepBlue)), child: child!),
          );
          if (d != null) onSelect(d);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date == null ? label : '${date.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: date == null ? Colors.grey.shade600 : Colors.black87, fontWeight: FontWeight.w600),
              ),
              Icon(Icons.calendar_today, color: AppColors.deepBlue, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- TOTAL ---
  Widget _totalCard() {
    return ZoomIn(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total à payer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${_total.toStringAsFixed(2)} DT', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // --- BOUTON CONFIRMER ---
  Widget _submitButton(ReservationController rc, VehicleController vc) {
    return ElasticInUp(
      duration: const Duration(milliseconds: 600),
      child: ElevatedButton.icon(
        onPressed: _selectedDriver == null
            ? null
            : () async {
          if (!_formKey.currentState!.validate() || _phone.isEmpty) return;

          final error = await rc.addReservation(
            Reservation(
              vehicleId: widget.vehicle.id!,
              driverId: _selectedDriver!.id!,
              clientName: _nameCtl.text,
              clientPhone: _phone,
              startDate: _startDate!,
              endDate: _endDate!,
              totalPrice: _total,
            ),
            vc,
          );

          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
            return;
          }

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Réservation confirmée !'), backgroundColor: Colors.green),
            );
          }
        },
        icon: const Icon(Icons.check_circle, size: 28),
        label: const Text('Confirmer la réservation', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          disabledBackgroundColor: Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: Colors.green.withOpacity(0.4),
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildSectionTitle(String title) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 400),
      child: Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.deepBlue),
      ),
    );
  }

  Widget _textField(TextEditingController ctl, String label, IconData icon) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: TextFormField(
        controller: ctl,
        decoration: _inputDecoration(label, icon),
        validator: (v) => v!.isEmpty ? 'Requis' : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.deepBlue),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.deepBlue, width: 2)),
    );
  }
}