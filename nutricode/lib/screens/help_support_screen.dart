import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'privacy_policy_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _contactEmail = 'nutricode.support@gmail.com';
  static const String _appVersion = '3.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionLabel('GETTING STARTED'),
          const SizedBox(height: 12),
          _buildNavTile(
            context,
            icon: Icons.play_circle_outline_rounded,
            iconColor: const Color(0xFF1B998B),
            title: 'How to Use NutriCode',
            subtitle: 'Step-by-step guide',
            onTap: () => _showHowToUse(context),
          ),
          const SizedBox(height: 28),
          _buildSectionLabel('ABOUT'),
          const SizedBox(height: 12),
          _buildNavTile(
            context,
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF1B998B),
            title: 'About NutriCode',
            subtitle: 'Version, team & credits',
            onTap: () => _showAbout(context),
          ),
          const SizedBox(height: 8),
          _buildNavTile(
            context,
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF1B998B),
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          const SizedBox(height: 28),
          _buildSectionLabel('CONTACT'),
          const SizedBox(height: 12),
          _buildNavTile(
            context,
            icon: Icons.mail_outline_rounded,
            iconColor: const Color(0xFF1B998B),
            title: 'Send Feedback',
            subtitle: _contactEmail,
            onTap: () => _launchEmail(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFFB0B0B0),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ── How to Use bottom sheet ───────────────────────────────────────
  void _showHowToUse(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _HowToUseSheet(),
    );
  }

  // ── About bottom sheet ────────────────────────────────────────────
  void _showAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AboutSheet(version: _appVersion),
    );
  }

  // ── Email launcher ────────────────────────────────────────────────
  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _contactEmail,
      queryParameters: {
        'subject': 'NutriCode Feedback v$_appVersion',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open email app.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ── How to Use sheet ─────────────────────────────────────────────────
class _HowToUseSheet extends StatelessWidget {
  const _HowToUseSheet();

  static const _steps = [
    (
      icon: Icons.qr_code_scanner_rounded,
      color: Color(0xFF1B998B),
      title: 'Scan a product',
      desc: 'Tap the Scan button at the bottom and point your camera at any product barcode.',
    ),
    (
      icon: Icons.list_alt_rounded,
      color: Color(0xFF3498DB),
      title: 'View ingredients & nutrition',
      desc: 'See the full ingredient list, nutritional values, and a safety verdict for your dietary profile.',
    ),
    (
      icon: Icons.no_food_rounded,
      color: Color(0xFFE67E22),
      title: 'Set your allergens',
      desc: 'Go to Profile → My Allergens and select the allergens you want to be warned about.',
    ),
    (
      icon: Icons.eco_rounded,
      color: Colors.green,
      title: 'Enable Vegan Mode',
      desc: 'Turn on Vegan Mode in your Profile to get warnings about animal-derived ingredients.',
    ),
    (
      icon: Icons.history_rounded,
      color: Color(0xFF9B59B6),
      title: 'Check your history',
      desc: 'Access Scan History in your Profile to revisit previously scanned products.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'How to Use NutriCode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Follow these steps to get started',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _steps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final step = _steps[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: step.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(step.icon, color: step.color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: step.color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    step.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                step.desc,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── About sheet ───────────────────────────────────────────────────────
class _AboutSheet extends StatelessWidget {
  final String version;
  const _AboutSheet({required this.version});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1B998B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Color(0xFF1B998B),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'NutriCode',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C3E50),
            ),
          ),
          Text(
            'v$version',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          Text(
            'NutriCode helps you make informed food choices by scanning product barcodes and checking ingredients against your dietary preferences and allergen profile.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.6),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.school_rounded, 'Faculty of Engineering, University of Porto (FEUP)'),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.group_rounded, 'Software Engineering — Group T2'),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.calendar_today_rounded, '2025 / 2026'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge('Flutter'),
              const SizedBox(width: 8),
              _buildBadge('Firebase'),
              const SizedBox(width: 8),
              _buildBadge('Open Food Facts'),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1B998B)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B998B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B998B),
        ),
      ),
    );
  }
}
