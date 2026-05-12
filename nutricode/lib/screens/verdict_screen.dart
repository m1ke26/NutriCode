import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/product_provider.dart';
import '../providers/allergen_provider.dart';
import '../providers/vegan_provider.dart';
import '../utils/ingredient_classifier.dart';
import '../utils/vegan_classifier.dart';
import 'product_screen.dart';

import '../services/open_food_facts_service.dart';
import '../providers/history_provider.dart';

class VerdictScreen extends StatelessWidget {
  final String barcode;
  final OpenFoodFactsService? service;
  final bool saveToHistory;
  const VerdictScreen({super.key, required this.barcode, this.service, this.saveToHistory = true});

  @override
  Widget build(BuildContext context) {
    return _VerdictScreenContent(barcode: barcode, service: service, saveToHistory: saveToHistory);
  }
}

class _VerdictScreenContent extends StatefulWidget {
  final String barcode;
  final OpenFoodFactsService? service;
  final bool saveToHistory;
  const _VerdictScreenContent({required this.barcode, this.service, this.saveToHistory = true});

  @override
  State<_VerdictScreenContent> createState() => _VerdictScreenContentState();
}

class _VerdictScreenContentState extends State<_VerdictScreenContent> {
  bool _historySaved = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(service: widget.service)..fetchProduct(widget.barcode),
      child: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          // Save to history once when product is successfully loaded (skip if opened from history)
          if (widget.saveToHistory && provider.state == ProductState.success && !_historySaved) {
            _historySaved = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<HistoryProvider>().addScan(
                  provider.product!,
                  widget.barcode,
                );
              }
            });
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(title: const Text('NutriCode'), centerTitle: true),
            body: _buildBody(context, provider),
          );
        },
      ),
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
    final isTimeout = widget.barcode == 'FAILED_TO_SCAN';

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
                child: Icon(
                  Icons.help_outline,
                  size: 64,
                  color: Color(0xFF8B4513),
                ),
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
                'Barcode: ${widget.barcode}',
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
                    'https://www.google.com/search?q=${widget.barcode}+product+barcode',
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

  // ── Allergen status card ────────────────────────────────────────
  Widget? _buildAllergenBanner(BuildContext context, ProductProvider provider) {
    final allergenProvider = context.watch<AllergenProvider>();
    final userAllergens = allergenProvider.selectedAllergens;
    if (userAllergens.isEmpty) return null;

    final product = provider.product!;
    final matches = product.allergens
        .where((a) => userAllergens.contains(a))
        .toList();

    if (matches.isNotEmpty) {
      final allergenNames = matches
          .map((a) => AllergenProvider.displayName(a))
          .toList();
      return _StatusCard(
        type: _StatusType.danger,
        icon: Icons.warning_amber_rounded,
        title: 'Allergens Detected',
        tags: allergenNames,
        action: _pillButton(
          label: 'Find Alternatives',
          icon: Icons.search,
          color: const Color(0xFFE74C3C),
          onPressed: () async {
            final query = Uri.encodeComponent(
              '${product.name ?? 'product'} alternatives without ${matches.first}',
            );
            final url = Uri.parse('https://www.google.com/search?q=$query');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      );
    }

    if (product.allergens.isEmpty) {
      return const _StatusCard(
        type: _StatusType.warning,
        icon: Icons.help_outline,
        title: 'Allergen data unavailable',
        subtitle: 'Check the physical label',
      );
    }

    return const _StatusCard(
      type: _StatusType.safe,
      icon: Icons.shield_outlined,
      title: 'No Allergens Detected',
    );
  }

  // ── Vegan status card ──────────────────────────────────────────
  Widget? _buildVeganBanner(BuildContext context, ProductProvider provider) {
    final veganProvider = context.watch<VeganProvider>();
    if (!veganProvider.isEnabled) return null;

    final product = provider.product!;

    if (product.ingredients.isEmpty) {
      return const _StatusCard(
        type: _StatusType.warning,
        icon: Icons.eco_outlined,
        title: 'Vegan status unknown',
        subtitle: 'Ingredient data unavailable',
      );
    }

    final nonVegan = getNonVeganIngredients(product.ingredients);

    if (nonVegan.isNotEmpty) {
      return _StatusCard(
        type: _StatusType.danger,
        icon: Icons.eco,
        title: 'Not Vegan',
        tags: nonVegan,
        action: _pillButton(
          label: 'Find Alternatives',
          icon: Icons.search,
          color: const Color(0xFFE74C3C),
          onPressed: () async {
            final query = Uri.encodeComponent(
              'vegan alternatives to ${product.name ?? 'product'}',
            );
            final url = Uri.parse('https://www.google.com/search?q=$query');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      );
    }

    return const _StatusCard(
      type: _StatusType.safe,
      icon: Icons.eco,
      title: 'Vegan Friendly',
    );
  }

  // ── Small pill-shaped action button ─────────────────────────────
  Widget _pillButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

    return SingleChildScrollView(
      child: Center(
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
                child: Center(child: Icon(icon, size: 64, color: circleColor)),
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
            const SizedBox(height: 20),

            // Allergen alert banner
            Builder(
              builder: (context) {
                final banner = _buildAllergenBanner(context, provider);
                if (banner == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: banner,
                );
              },
            ),

            // Vegan banner
            Builder(
              builder: (context) {
                final banner = _buildVeganBanner(context, provider);
                if (banner == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: banner,
                );
              },
            ),

            const SizedBox(height: 16),

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
                      builder: (_) => ProductScreen(barcode: widget.barcode),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: const BorderSide(color: Colors.blueGrey),
              ),
            ),
          ],
        ),
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

enum _StatusType { safe, warning, danger }

class _StatusCard extends StatelessWidget {
  final _StatusType type;
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<String>? tags;
  final Widget? action;

  const _StatusCard({
    required this.type,
    required this.icon,
    required this.title,
    this.subtitle,
    this.tags,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary;
    final Color bg;
    final Color border;
    final Color iconBg;

    switch (type) {
      case _StatusType.safe:
        primary = const Color(0xFF27AE60);
        bg = const Color(0xFFF0FFF4);
        border = const Color(0xFFB7EBC9);
        iconBg = const Color(0xFFD5F5E3);
        break;
      case _StatusType.warning:
        primary = const Color(0xFFF39C12);
        bg = const Color(0xFFFFF9E6);
        border = const Color(0xFFF7DC6F);
        iconBg = const Color(0xFFFEF3C7);
        break;
      case _StatusType.danger:
        primary = const Color(0xFFE74C3C);
        bg = const Color(0xFFFFF5F5);
        border = const Color(0xFFFCA5A5);
        iconBg = const Color(0xFFFEE2E2);
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Icon badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                child: Icon(icon, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            color: primary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Tag chips for detected items
          if (tags != null && tags!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags!.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          // Action button
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: action!,
              ),
            ),
        ],
      ),
    );
  }
}
