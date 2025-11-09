// lib/views/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fond gris très clair
      appBar: AppBar(
        title: const Text(
          'À propos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.deepBlue,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // -------------------------------------------------
              //  Logo + Titre avec Shimmer subtil
              // -------------------------------------------------
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Shimmer.fromColors(
                  baseColor: AppColors.deepBlue.withOpacity(0.8),
                  highlightColor: Colors.white,
                  period: const Duration(seconds: 3),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.deepBlue.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          size: 50,
                          color: AppColors.deepBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Voyagea',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'Votre partenaire voyage',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // -------------------------------------------------
              //  Description riche et structurée
              // -------------------------------------------------
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepBlue.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15.5,
                        height: 1.7,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Voyagea',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepBlue,
                          ),
                        ),
                        const TextSpan(
                            text:
                            ' est une agence de voyage moderne, dédiée à offrir des expériences uniques et accessibles à tous.\n\n'),
                        _buildBullet('Voyages organisés', ''),

                        _buildBullet('Volontariat', ''),
                        _buildBullet('Gestion complète', ' de flotte : véhicules, chauffeurs, réservations.'),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // -------------------------------------------------
              //  Carte Contact
              // -------------------------------------------------
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.deepBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.contact_mail_rounded,
                                color: AppColors.deepBlue,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Nous contacter',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildContactRow(Icons.email_rounded, 'contact@voyagea.tn'),
                        const SizedBox(height: 12),
                        _buildContactRow(Icons.phone_rounded, '+216 71 234 567'),
                        const SizedBox(height: 12),
                        _buildContactRow(Icons.location_on_rounded, 'Tunis, Tunisie'),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // -------------------------------------------------
              //  Footer animé avec cœur
              // -------------------------------------------------
              FadeInUp(
                duration: const Duration(milliseconds: 1200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Fait avec ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    BeatAnimation(
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 22,
                      ),
                    ),
                    const Text(
                      ' par l’équipe Voyagea',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------
  //  Helper : Bullet point stylisé
  // -------------------------------------------------
  TextSpan _buildBullet(String bold, String normal) {
    return TextSpan(children: [
      TextSpan(
        text: '• ',
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue),
      ),
      TextSpan(
        text: bold,
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue),
      ),
      TextSpan(text: normal),
      const TextSpan(text: '\n'),
    ]);
  }

  // -------------------------------------------------
  //  Helper : Ligne de contact
  // -------------------------------------------------
  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deepBlue, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      ],
    );
  }
}

// -------------------------------------------------
//  Animation de battement pour le cœur
// -------------------------------------------------
class BeatAnimation extends StatefulWidget {
  final Widget child;
  const BeatAnimation({super.key, required this.child});

  @override
  State<BeatAnimation> createState() => _BeatAnimationState();
}

class _BeatAnimationState extends State<BeatAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _beatController;
  late Animation<double> _beatAnimation;

  @override
  void initState() {
    super.initState();
    _beatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _beatAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _beatController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _beatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _beatAnimation,
      child: widget.child,
    );
  }
}