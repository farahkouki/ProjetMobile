import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../controllers/driver_controller.dart';
import '../../models/driver_model.dart';

class DriverFormDialog extends StatefulWidget {
  final Driver? driver;
  const DriverFormDialog({super.key, this.driver});

  @override
  State<DriverFormDialog> createState() => _DriverFormDialogState();
}

class _DriverFormDialogState extends State<DriverFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _exp = TextEditingController();
  String? _phone;

  @override
  void initState() {
    super.initState();
    if (widget.driver != null) {
      _nom.text = widget.driver!.nom;
      _phone = widget.driver!.telephone;
      _exp.text = widget.driver!.experience.toString();
    }
  }

  @override
  void dispose() {
    _nom.dispose();
    _exp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dc = Provider.of<DriverController>(context, listen: false);
    final isEdit = widget.driver != null;

    return AlertDialog(
      title: Text(isEdit ? 'Modifier chauffeur' : 'Ajouter chauffeur'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _nom,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 10),

            IntlPhoneField(
              initialCountryCode: 'TN',
              initialValue: _phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
              ),
              onChanged: (phone) {
                _phone = phone.completeNumber;
              },
              validator: (phone) {
                if (phone == null || phone.number.isEmpty) return 'Requis';
                return null;
              },
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _exp,
              decoration: const InputDecoration(labelText: 'Années expérience'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requis';
                if (int.tryParse(v) == null) return 'Doit être un nombre';
                return null;
              },
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final driver = Driver(
                id: widget.driver?.id,
                nom: _nom.text.trim(),
                telephone: _phone!,
                experience: int.tryParse(_exp.text.trim()) ?? 0,
              );

              if (isEdit) {
                dc.updateDriver(driver);
              } else {
                dc.addDriver(driver);
              }
              Navigator.pop(context);
            }
          },
          child: Text(isEdit ? 'Enregistrer' : 'Ajouter'),
        ),
      ],
    );
  }
}
