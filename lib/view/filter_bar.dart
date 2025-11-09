import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget {
  final Function(String?, DateTime?, String?) onFilterChanged;

  const FilterBar({super.key, required this.onFilterChanged});

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  String? destination;
  DateTime? date;
  String? budget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDropdown(
          label: 'Destination',
          icon: Icons.location_on_outlined,
          value: destination,
          items: ['Rome', 'Paris', 'Tunis', 'Sahara'],
          onChanged: (val) {
            setState(() => destination = val);
            widget.onFilterChanged(destination, date, budget);
          },
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2025),
              lastDate: DateTime(2026),
            );
            if (picked != null) {
              setState(() => date = picked);
              widget.onFilterChanged(destination, date, budget);
            }
          },
          child: _buildCardField(
            label: date == null
                ? 'Date'
                : 'Date : ${date!.day}/${date!.month}/${date!.year}',
            icon: Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(height: 10),
        _buildDropdown(
          label: 'Budget',
          icon: Icons.attach_money_outlined,
          value: budget,
          items: ['< 1000 TND', '1000-2000 TND', '> 2000 TND'],
          onChanged: (val) {
            setState(() => budget = val);
            widget.onFilterChanged(destination, date, budget);
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.blue),
          border: InputBorder.none,
          labelText: label,
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCardField({required String label, required IconData icon}) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 16)),
        ],
      ),
    );
  }
}
