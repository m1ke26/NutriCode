import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../services/open_food_facts_service.dart';
import '../utils/ingredient_classifier.dart';
import '../widgets/ingredient_info_sheet.dart';

class ProductScreen extends StatelessWidget {
  final String barcode;
  final ProductProvider? provider;
  
  const ProductScreen({super.key, required this.barcode, this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider != null) {
      return ChangeNotifierProvider<ProductProvider>.value(
        value: provider!,
        child: const _ProductScreenContent(),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => ProductProvider()..fetchProduct(barcode),
      child: const _ProductScreenContent(),
    );
  }
}

class _ProductScreenContent extends StatelessWidget {
  const _ProductScreenContent();



  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('NutriCode: Scan')),
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
              Text('Analyzing package... 🔍', style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
            ],
          ),
        );
      case ProductState.error:
        return _buildError(provider.errorMessage ?? 'Unknown error');
      case ProductState.notFound:
        return _buildNotFound(context);
      case ProductState.success:
        return _buildProductInfo(context, provider.product!);
    }
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Product not found',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We couldn\'t find this barcode in our database.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manual search feature will be added soon!')),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Search by name'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B998B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context, ProductResult product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.imageUrl != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Image.network(
                  product.imageUrl!,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                ),
              ),
            ),

          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                Text(
                  product.name ?? 'Unknown Product',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2C3E50),
                    letterSpacing: -0.5,
                  ),
                ),
                if (product.brand != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B998B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.brand!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B998B),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          if (product.nutriScore != null && product.nutriScore!.isNotEmpty)
            Center(child: _buildNutriScore(product.nutriScore!)),
            
          if (product.nutrientLevels.isNotEmpty)
            _buildNutrientLevels(product.nutrientLevels),

          if (product.ingredients.isNotEmpty)
            _IngredientsListWidget(
              ingredients: product.ingredients,
              allergens: product.allergens,
            )
          else if (product.ingredientsText != null && product.ingredientsText!.isNotEmpty) ...[
            const Text('Ingredients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildHighlightedText(product.ingredientsText!, product.allergens),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ingredients not available for this product.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutriScore(String grade) {
    grade = grade.toUpperCase();
    Color badgeColor;
    switch (grade) {
      case 'A': badgeColor = const Color(0xFF008137); break;
      case 'B': badgeColor = const Color(0xFF85BB2F); break;
      case 'C': badgeColor = const Color(0xFFFDB900); break;
      case 'D': badgeColor = const Color(0xFFEE8100); break;
      case 'E': badgeColor = const Color(0xFFE63E11); break;
      default: return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Nutri-Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2C3E50))),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              grade,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientLevels(Map<String, String> levels) {
    if (levels.isEmpty) return const SizedBox.shrink();

    final validKeys = ['fat', 'saturated-fat', 'sugars', 'salt'];
    final tiles = validKeys
        .where((k) => levels.containsKey(k))
        .map((k) => _buildNutrientTile(k, levels[k]!))
        .toList();

    if (tiles.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tiles.map((t) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: t))).toList(),
      ),
    );
  }

  Widget _buildNutrientTile(String key, String level) {
    String name;
    IconData icon;
    switch (key) {
      case 'fat': name = 'Fat'; icon = Icons.water_drop; break;
      case 'saturated-fat': name = 'Sat. Fat'; icon = Icons.opacity; break;
      case 'sugars': name = 'Sugars'; icon = Icons.cookie; break;
      case 'salt': name = 'Salt'; icon = Icons.scatter_plot; break;
      default: return const SizedBox.shrink();
    }

    Color color;
    String label;
    switch (level.toLowerCase()) {
      case 'low': color = Colors.green; label = 'Low'; break;
      case 'moderate': color = Colors.orange; label = 'Moderate'; break;
      case 'high': color = Colors.red; label = 'High'; break;
      default: return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(String text, List<String> allergens) {
    return Text(
      text.toLowerCase(),
      style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
    );
  }
}

class _IngredientsListWidget extends StatefulWidget {
  final List<Ingredient> ingredients;
  final List<String> allergens;

  const _IngredientsListWidget({required this.ingredients, required this.allergens});

  @override
  State<_IngredientsListWidget> createState() => _IngredientsListWidgetState();
}

class _IngredientsListWidgetState extends State<_IngredientsListWidget> {
  IngredientLevel _getEffectiveLevel(Ingredient ingredient) {
    final textToClassify = ingredient.englishText.isNotEmpty ? ingredient.englishText : ingredient.text;
    IngredientLevel level = classifyIngredient(textToClassify, widget.allergens);
    if (level == IngredientLevel.bad) return IngredientLevel.bad;

    for (final sub in ingredient.subIngredients) {
      final subLevel = _getEffectiveLevel(sub);
      if (subLevel == IngredientLevel.bad) return IngredientLevel.bad;
      if (subLevel == IngredientLevel.moderate) level = IngredientLevel.moderate;
    }
    return level;
  }

  bool _hasAllergenRecursive(Ingredient ingredient) {
    final lower = ingredient.text.toLowerCase().trim();
    for (final allergen in widget.allergens) {
      if (lower.contains(allergen.toLowerCase().trim())) {
        return true;
      }
    }
    return ingredient.subIngredients.any(_hasAllergenRecursive);
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort ingredients: Red first (allergens or bad), then Orange, then Green
    final sortedIngredients = List<Ingredient>.from(widget.ingredients)..sort((a, b) {
      final levelA = _getEffectiveLevel(a);
      final levelB = _getEffectiveLevel(b);
      
      final scoreComparison = levelB.index.compareTo(levelA.index); // Higher index (bad) first
      if (scoreComparison != 0) return scoreComparison;
      return a.text.compareTo(b.text); // Alphabetical fallback
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFF1B998B),
          collapsedIconColor: const Color(0xFF1B998B),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B998B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long, color: Color(0xFF1B998B)),
          ),
          title: const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                  _legendDot(Colors.green, 'Good'),
                  _legendDot(Colors.orange, 'Moderate'),
                  _legendDot(Colors.red, 'Avoid'),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: sortedIngredients.map((ingredient) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _IngredientItemWidget(
                    ingredient: ingredient,
                    allergens: widget.allergens,
                    effectiveLevel: _getEffectiveLevel(ingredient),
                    hasAllergen: _hasAllergenRecursive(ingredient),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientItemWidget extends StatefulWidget {
  final Ingredient ingredient;
  final List<String> allergens;
  final IngredientLevel effectiveLevel;
  final bool hasAllergen;

  const _IngredientItemWidget({
    required this.ingredient,
    required this.allergens,
    required this.effectiveLevel,
    required this.hasAllergen,
  });

  @override
  State<_IngredientItemWidget> createState() => _IngredientItemWidgetState();
}

class _IngredientItemWidgetState extends State<_IngredientItemWidget> {
  bool _isExpanded = false;

  Color _getLevelColor(IngredientLevel level) {
    switch (level) {
      case IngredientLevel.bad:
        return Colors.red;
      case IngredientLevel.moderate:
        return Colors.orange;
      case IngredientLevel.good:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getLevelColor(widget.effectiveLevel);
    final hasSubs = widget.ingredient.subIngredients.isNotEmpty;
    final hasDesc = hasIngredientDescription(
      _getDisplayText(),
      englishName: widget.ingredient.englishText,
    );
    
    // The user wants: if it expands to others (hasSubs) AND doesn't have its own description (!hasDesc),
    // you can't click on it to see the fallback description.
    final canShowInfo = !hasSubs || hasDesc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: hasSubs ? () => setState(() => _isExpanded = !_isExpanded) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _getDisplayText(),
                          style: const TextStyle(
                            color: Color(0xFF2C3E50),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (canShowInfo) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            showIngredientInfo(
                              context,
                              ingredientName: _getDisplayText(),
                              englishName: widget.ingredient.englishText,
                              level: widget.effectiveLevel,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.blueGrey.shade300,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasSubs) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 24,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 24), // keep row height fairly stable structurally
                ],
              ],
            ),
          ),
        ),
        if (_isExpanded && hasSubs)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 6, bottom: 8, right: 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.ingredient.subIngredients.map((sub) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _IngredientItemWidget(
                      ingredient: sub,
                      allergens: widget.allergens,
                      effectiveLevel: _getEffectiveLevelForSub(sub),
                      hasAllergen: _hasAllergenRecursive(sub),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  IngredientLevel _getEffectiveLevelForSub(Ingredient ingredient) {
    final textToClassify = ingredient.englishText.isNotEmpty ? ingredient.englishText : ingredient.text;
    IngredientLevel level = classifyIngredient(textToClassify, widget.allergens);
    if (level == IngredientLevel.bad) return IngredientLevel.bad;

    for (final sub in ingredient.subIngredients) {
      final subLevel = _getEffectiveLevelForSub(sub);
      if (subLevel == IngredientLevel.bad) return IngredientLevel.bad;
      if (subLevel == IngredientLevel.moderate) level = IngredientLevel.moderate;
    }
    return level;
  }

  bool _hasAllergenRecursive(Ingredient ingredient) {
    final lower = ingredient.text.toLowerCase().trim();
    for (final allergen in widget.allergens) {
      if (lower.contains(allergen.toLowerCase().trim())) {
        return true;
      }
    }
    return ingredient.subIngredients.any(_hasAllergenRecursive);
  }

  String _getDisplayText() {
    String text = widget.ingredient.englishText.isNotEmpty 
        ? widget.ingredient.englishText 
        : widget.ingredient.text;
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
