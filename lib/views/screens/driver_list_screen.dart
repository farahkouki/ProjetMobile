// lib/views/screens/driver_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart'; // <-- import QR Flutter

import '../../controllers/driver_controller.dart';
import '../../models/driver_model.dart';
import '../widgets/driver_form_dialog.dart';
import '../../core/utils/country_utils.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  String _searchQuery = '';
  int _hoveredIndex = -1;

  static const _primary = Color(0xFF0D47A1);
  static const _primaryLight = Color(0xFF1976D2);
  static const _bg = Color(0xFFF8FAFC);
  static const _cardBg = Colors.white;
  static const _border = Color(0xFFE0E0E0);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final dc = Provider.of<DriverController>(context);
    final filteredDrivers = dc.drivers.where((d) {
      final query = _searchQuery.toLowerCase();
      return d.nom.toLowerCase().contains(query) ||
          d.telephone.contains(query) ||
          d.experience.toString().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: dc.loading
          ? _buildShimmer()
          : filteredDrivers.isEmpty
          ? _buildEmptyState()
          : _buildDriverList(filteredDrivers),
      floatingActionButton: _buildFAB(dc),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Chauffeurs',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 21, color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_primary, _primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: _buildSearchBar(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: _primary.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Rechercher...',
            hintStyle:
            TextStyle(color: Colors.grey.shade500, fontSize: 15),
            prefixIcon: Icon(Icons.search_rounded, color: _primary, size: 26),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon:
              const Icon(Icons.clear_rounded, color: Colors.grey),
              onPressed: () => setState(() => _searchQuery = ''),
            )
                : null,
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverList(List<Driver> drivers) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: drivers.length,
      itemBuilder: (context, i) {
        return FadeInUp(
          duration: Duration(milliseconds: 400 + (i * 80)),
          child: _buildDriverCard(drivers[i], i),
        );
      },
    );
  }

  Widget _buildDriverCard(Driver d, int index) {
    final isHovered = _hoveredIndex == index;
    final country = getCountryFromPhone(d.telephone);
    final flag = countryFlags[country] ?? 'Unknown flag';

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient:
          isHovered ? const LinearGradient(colors: [_primaryLight, _primary]) : null,
          color: isHovered ? null : _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isHovered ? Colors.transparent : _border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? _primary.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isHovered ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AVATAR avec popup QR code au clic ---
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('QR Code de ${d.nom}'),
                    content: QrImageView(
                      data: '${d.id}_${d.nom}_${d.telephone}',
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 26,
                backgroundColor:
                isHovered ? Colors.white.withOpacity(0.2) : _primary.withOpacity(0.1),
                child: Text(
                  d.nom.isNotEmpty ? d.nom[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: isHovered ? Colors.white : _primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.nom,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isHovered ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _infoRow(Icons.phone_rounded, d.telephone, isHovered),
                  const SizedBox(height: 3),
                  _infoRow(Icons.emoji_events_rounded, '${d.experience} ans', isHovered),
                  const SizedBox(height: 3),
                  _infoRow(null, '$flag $country', isHovered, isFlag: true),
                  const SizedBox(height: 6),
                  // QR code dans la carte
                  QrImageView(
                    data: '${d.id}_${d.nom}_${d.telephone}',
                    version: QrVersions.auto,
                    size: 60.0,
                  ),
                ],
              ),
            ),

            Wrap(
              spacing: 6,
              children: [
                _actionButton(
                  icon: Icons.edit_rounded,
                  color: isHovered ? Colors.white : _primary,
                  onTap: () =>
                      showDialog(context: context, builder: (_) => DriverFormDialog(driver: d)),
                ),
                _actionButton(
                  icon: Icons.delete_rounded,
                  color: Colors.red.shade400,
                  onTap: () => _confirmDelete(d),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData? icon, String text, bool isHovered, {bool isFlag = false}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: isHovered ? Colors.white70 : _textSecondary),
          const SizedBox(width: 4),
        ],
        if (isFlag)
          Text(text,
              style: TextStyle(fontSize: 13, color: isHovered ? Colors.white70 : _textSecondary))
        else
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: isHovered ? Colors.white70 : _textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElasticIn(
              duration: const Duration(milliseconds: 800),
              child:
              Icon(Icons.person_search_rounded, size: 80, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text('Aucun chauffeur',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: _textSecondary)),
            const SizedBox(height: 6),
            Text('Essayez une autre recherche',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: 6,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(DriverController dc) {
    return ElasticInUp(
      duration: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: "add_driver",
            onPressed: () =>
                showDialog(context: context, builder: (_) => const DriverFormDialog()),
            backgroundColor: _primary,
            elevation: 10,
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 24),
            label: const Text('Ajouter',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Driver d) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 34),
        title: const Text('Supprimer ?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Confirmer la suppression de ${d.nom} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Provider.of<DriverController>(context, listen: false).deleteDriver(d.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chauffeur supprimé'), backgroundColor: Colors.red),
      );
    }
  }
}
