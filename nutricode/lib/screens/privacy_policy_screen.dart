import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSection(
            title: '1. Data We Collect',
            content:
                'NutriCode collects the following information to provide its services:\n\n'
                '• Account information: name and email address used during registration.\n'
                '• Profile picture: optionally uploaded by you.\n'
                '• Dietary preferences: allergens and vegan mode settings.\n'
                '• Scan history: barcodes and product details of items you scan.',
          ),
          _buildSection(
            title: '2. How We Use Your Data',
            content:
                'Your data is used exclusively to:\n\n'
                '• Provide personalised allergen and vegan warnings.\n'
                '• Display your scan history across sessions.\n'
                '• Improve your experience within the app.\n\n'
                'We do not sell or share your personal data with third parties for marketing purposes.',
          ),
          _buildSection(
            title: '3. Third-Party Services',
            content:
                'NutriCode uses the following third-party services:\n\n'
                '• Firebase (Google) — for authentication, database storage, and file storage. '
                'Firebase processes data in accordance with Google\'s Privacy Policy.\n\n'
                '• Open Food Facts — an open-source food database used to retrieve product information. '
                'No personal data is sent to Open Food Facts.',
          ),
          _buildSection(
            title: '4. Data Retention',
            content:
                'Your data is stored for as long as your account is active. '
                'You may clear your scan history at any time from App Settings. '
                'To delete your account and all associated data, please contact us.',
          ),
          _buildSection(
            title: '5. Your Rights',
            content:
                'You have the right to:\n\n'
                '• Access the personal data we hold about you.\n'
                '• Correct inaccurate data.\n'
                '• Request deletion of your data.\n'
                '• Withdraw consent at any time.\n\n'
                'To exercise these rights, please contact us via the Help & Support section.',
          ),
          _buildSection(
            title: '6. Security',
            content:
                'We take reasonable measures to protect your data. '
                'Authentication is handled securely by Firebase Authentication. '
                'All data in transit is encrypted using HTTPS.',
          ),
          _buildSection(
            title: '7. Contact',
            content:
                'If you have any questions about this Privacy Policy or how your data is handled, '
                'please contact us through the Help & Support section of the app.',
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Last updated: May 2025',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B998B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF1B998B), size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your privacy matters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We are committed to protecting your personal data and being transparent about how we use it.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
