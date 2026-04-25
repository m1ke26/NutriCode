  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/product_provider.dart';
import '../utils/ingredient_classifier.dart';
import 'product_screen.dart';

class VerdictScreen extends StatelessWidget {
  final String barcode;
  const VerdictScreen({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider()..fetchProduct(barcode),
      child: _VerdictScreenContent(barcode: barcode),
    );
  }
}

class _VerdictScreenContent extends StatelessWidget {
  final String barcode;
  const _VerdictScreenContent({required this.barcode});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('NutriCode'),
        centerTitle: true,
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, ProductProvider provider) {
    switch (provider.state) {
      case ProductState.initial:
      case ProductState.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF1B998B)),
              SizedBox(height: 16),
              Text(
                'Analyzing product... 🔍',
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
            ],
          ),
        );
      case ProductState.error:
        return _buildErrorState(context, provider);
      case ProductState.notFound:
        return _buildNotFoundState(context);
      case ProductState.success:
        return _buildVerdictState(context, provider);
    }
  }

  // ── Error (network) ───────────────────────────────────────────────
  Widget _buildErrorState(BuildContext context, ProductProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 72, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text(
              provider.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 28),
            _actionButton(
              context,
              icon: Icons.camera_alt,
              label: 'Scan again',
              color: const Color(0xFF1B998B),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── Not Found / Failed Scan ───────────────────────────────────
  Widget _buildNotFoundState(BuildContext context) {
    final isTimeout = barcode == 'FAILED_TO_SCAN';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brown circle
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B4513).withOpacity(0.15),
                border: Border.all(color: const Color(0xFF8B4513), width: 6),
              ),
              child: const Center(
                child: Icon(Icons.help_outline, size: 64, color: Color(0xFF8B4513)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isTimeout ? 'Failed to scan' : 'Product Not Found',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 8),
            if (!isTimeout)
              Text(
                'Barcode: $barcode',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            const SizedBox(height: 32),

            // Search the Internet
            if (!isTimeout) ...[
              _actionButton(
                context,
                icon: Icons.language,
                label: 'Search the Internet',
                color: const Color(0xFF8B4513),
                onPressed: () async {
                  final url = Uri.parse(
                    'https://www.google.com/search?q=$barcode+product+barcode',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 12),
            ],

            // Scan again
            _actionButton(
              context,
              icon: Icons.camera_alt,
              label: 'Scan again',
              color: const Color(0xFF1B998B),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── Success → green / yellow / red verdict ────────────────────────
  Widget _buildVerdictState(BuildContext context, ProductProvider provider) {
    final product = provider.product!;
    final bool hasIngredients = product.ingredients.isNotEmpty;

    final Color circleColor;
    final String message;
    final IconData icon;

    if (!hasIngredients) {
      // No ingredient data available
      circleColor = Colors.blueGrey;
      message = 'Details not available';
      icon = Icons.info_outline;
    } else {
      final verdict = worstCaseVerdict(product.ingredients, product.allergens);

      switch (verdict) {
        case IngredientLevel.good:
          circleColor = Colors.green;
          message = 'All ingredients are safe';
          icon = Icons.check_circle_outline;
          break;
        case IngredientLevel.moderate:
          circleColor = Colors.orange;
          message = 'Some ingredients need attention';
          icon = Icons.info_outline;
          break;
        case IngredientLevel.bad:
          circleColor = Colors.red;
          message = 'Contains harmful ingredients';
          icon = Icons.warning_amber_rounded;
          break;
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product image thumbnail (if available)
            if (product.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product.imageUrl!,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Product name
            Text(
              product.name ?? 'Unknown Product',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            if (product.brand != null)
              Text(
                product.brand!,
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
              ),
            const SizedBox(height: 28),

            // Traffic light circle
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor.withOpacity(0.15),
                  border: Border.all(color: circleColor, width: 6),
                  boxShadow: [
                    BoxShadow(
                      color: circleColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, size: 64, color: circleColor),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Verdict message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: circleColor,
              ),
            ),
            const SizedBox(height: 36),

            // View Details button — only shown when ingredients are available
            if (hasIngredients) ...[
              _actionButton(
                context,
                icon: Icons.list_alt,
                label: 'View Details',
                color: const Color(0xFF1B998B),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductScreen(barcode: barcode),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            // Scan again
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: const BorderSide(color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable styled button ────────────────────────────────────────
  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
