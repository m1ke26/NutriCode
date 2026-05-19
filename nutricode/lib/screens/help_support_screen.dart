import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'privacy_policy_screen.dart';
// ignore_for_file: unused_element

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
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
      ),
    );
  }

  // ── How to Use bottom sheet ───────────────────────────────────────
  void _showHowToUse(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HowToUseSheet(),
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
class HowToUseSheet extends StatelessWidget {
  const HowToUseSheet({super.key});

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
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text(
              'How to Use NutriCode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 4),
            Text('Follow these steps to get started', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(height: 12),
            // ── Animation scene ──────────────────────────────────────
            const _ScanAnimationWidget(),
            const SizedBox(height: 8),
            // ── Step list ────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: _steps.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final step = _steps[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: step.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(step.icon, color: step.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 20, height: 20,
                                    decoration: BoxDecoration(color: step.color, shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('${i + 1}',
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(step.title,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(step.desc, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4)),
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

// ── Scan animation widget ─────────────────────────────────────────────
class _ScanAnimationWidget extends StatefulWidget {
  const _ScanAnimationWidget();

  @override
  State<_ScanAnimationWidget> createState() => _ScanAnimationWidgetState();
}

class _ScanAnimationWidgetState extends State<_ScanAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // ── Phase timings (total 5.8 s) ──────────────────────────────────────
  // 0.00-0.16  product slides in
  // 0.18-0.34  phone slides in
  // 0.36-0.55  finger tap on Scan button
  // 0.57-0.75  laser sweep
  // 0.77-0.89  checkmark
  // 0.91-1.00  fade out

  late Animation<double> _productOpacity;
  late Animation<Offset>  _productSlide;
  late Animation<double> _phoneOpacity;
  late Animation<Offset>  _phoneSlide;
  late Animation<double> _tapOpacity;   // fade in/hold/fade out
  late Animation<double> _tapScale;    // press → release bounce
  late Animation<double> _tapRipple;   // expanding ring after tap
  late Animation<double> _laserProgress;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<double> _sceneOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5800),
    )..repeat();

    // Product
    _productOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.00, 0.16, curve: Curves.easeOut)));
    _productSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.00, 0.16, curve: Curves.easeOut)));

    // Phone
    _phoneOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.18, 0.34, curve: Curves.easeOut)));
    _phoneSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.18, 0.34, curve: Curves.easeOut)));

    // Tap: appear → hold → disappear
    _tapOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: ConstantTween(1.0),           weight: 11),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 2),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.36, 0.55)));

    // Tap: scale 1 → press (0.6) → release bounce (1.25) → settle (1.0)
    _tapScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0),                                                                    weight: 3),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.60).chain(CurveTween(curve: Curves.easeIn)),                 weight: 3),
      TweenSequenceItem(tween: Tween(begin: 0.60, end: 1.25).chain(CurveTween(curve: Curves.easeOut)),               weight: 4),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),                 weight: 2),
      TweenSequenceItem(tween: ConstantTween(1.0),                                                                    weight: 3),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.36, 0.55)));

    // Ripple expands right after release (middle of tap phase)
    _tapRipple = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.44, 0.52, curve: Curves.easeOut)));

    // Laser
    _laserProgress = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.57, 0.75, curve: Curves.easeInOut)));

    // Checkmark
    _checkScale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.77, 0.89, curve: Curves.elasticOut)));
    _checkOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.77, 0.83, curve: Curves.easeOut)));

    // Fade out everything
    _sceneOpacity = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.91, 1.0, curve: Curves.easeIn)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return FadeTransition(
          opacity: _sceneOpacity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 190,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(color: Color(0xFFF0F7F6)),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // ── Product (left) ──────────────────────────────────
                  Positioned(
                    left: 30,
                    child: FadeTransition(
                      opacity: _productOpacity,
                      child: SlideTransition(
                        position: _productSlide,
                        child: _buildProductBox(),
                      ),
                    ),
                  ),

                  // ── Arrow ───────────────────────────────────────────
                  FadeTransition(
                    opacity: _phoneOpacity,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF1B998B), size: 22),
                    ),
                  ),

                  // ── Phone (right) ───────────────────────────────────
                  Positioned(
                    right: 30,
                    child: FadeTransition(
                      opacity: _phoneOpacity,
                      child: SlideTransition(
                        position: _phoneSlide,
                        child: _buildPhone(),
                      ),
                    ),
                  ),

                  // ── Checkmark ───────────────────────────────────────
                  ScaleTransition(
                    scale: _checkScale,
                    child: FadeTransition(
                      opacity: _checkOpacity,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 44),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductBox() {
    return Container(
      width: 70,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_rounded, color: Color(0xFF1B998B), size: 30),
          const SizedBox(height: 6),
          ...List.generate(4, (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Container(
              width: 36 - (i % 2) * 8.0,
              height: 2.5,
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPhone() {
    const phoneW = 58.0;
    const phoneH = 100.0;

    // Positions for the Scan button inside the phone (relative to phone top-left)
    // The phone screen inner area starts ~6px from top/left after border+margin
    // Scan button sits near vertical center-bottom of the screen
    const scanBtnCenterX = phoneW / 2;
    const scanBtnCenterY = phoneH * 0.68;
    const tapCircleR     = 10.0;

    return SizedBox(
      width: phoneW,
      height: phoneH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Phone shell ──────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Dark border / body
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C3E50), width: 3),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECF8F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.eco_rounded, color: Color(0xFF1B998B), size: 16),
                        const SizedBox(height: 8),
                        // Scan button on phone screen
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B998B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Scan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Laser line ──────────────────────────────────────
                if (_laserProgress.value > 0)
                  Positioned(
                    top: phoneH * _laserProgress.value - 2,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.transparent,
                          const Color(0xFF1B998B).withValues(alpha: 0.8),
                          Colors.transparent,
                        ]),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B998B).withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Tap ripple (outside ClipRRect so it can overflow slightly) ──
          if (_tapOpacity.value > 0 && _tapRipple.value > 0)
            Positioned(
              left: scanBtnCenterX - tapCircleR - _tapRipple.value * 12,
              top:  scanBtnCenterY - tapCircleR - _tapRipple.value * 12,
              child: Opacity(
                opacity: (1 - _tapRipple.value) * _tapOpacity.value * 0.55,
                child: Container(
                  width:  (tapCircleR * 2) + _tapRipple.value * 24,
                  height: (tapCircleR * 2) + _tapRipple.value * 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1B998B),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

          // ── Tap finger dot ───────────────────────────────────────
          if (_tapOpacity.value > 0)
            Positioned(
              left: scanBtnCenterX - tapCircleR,
              top:  scanBtnCenterY - tapCircleR,
              child: Opacity(
                opacity: _tapOpacity.value,
                child: Transform.scale(
                  scale: _tapScale.value,
                  child: Container(
                    width:  tapCircleR * 2,
                    height: tapCircleR * 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1B998B), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
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
