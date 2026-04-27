import 'package:flutter/material.dart';
import '../providers/allergen_provider.dart';
import 'allergen_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    AllergenProvider.instance.addListener(_onAllergenChange);
  }

  @override
  void dispose() {
    AllergenProvider.instance.removeListener(_onAllergenChange);
    super.dispose();
  }

  void _onAllergenChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar placeholder
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B998B).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1B998B).withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 48,
                      color: Color(0xFF1B998B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C3E50),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Coming soon! Your profile settings,\ndietary preferences, and scan history\nwill appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Feature cards preview
                  _buildFeaturePreview(
                    Icons.history,
                    'Scan History',
                    'Review your previously scanned products',
                  ),
                  const SizedBox(height: 12),
                  _buildAllergenCard(context),
                  const SizedBox(height: 12),
                  _buildFeaturePreview(
                    Icons.settings_outlined,
                    'Settings',
                    'Customize your NutriCode experience',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllergenCard(BuildContext context) {
    final count = AllergenProvider.instance.selectedAllergens.length;
    final subtitle = count == 0
        ? 'None configured — tap to set up'
        : '$count allergen${count == 1 ? '' : 's'} configured';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AllergenScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B998B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restaurant_menu,
                  color: Color(0xFF1B998B), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Allergens',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: count > 0
                          ? const Color(0xFF1B998B)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF1B998B)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePreview(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B998B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1B998B), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline, size: 18, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
