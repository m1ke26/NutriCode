import 'package:flutter/material.dart';
import '../services/open_food_facts_service.dart';

// Harmful ingredients (red)
const _badIngredients = {
  'high fructose corn syrup', 'aspartame', 'acesulfame k', 'acesulfame',
  'sodium nitrite', 'sodium nitrate', 'monosodium glutamate', 'msg',
  'tartrazine', 'red 40', 'yellow 5', 'yellow 6', 'blue 1', 'red dye',
  'trans fat', 'hydrogenated', 'partially hydrogenated',
  'butylated hydroxyanisole', 'bha', 'butylated hydroxytoluene', 'bht',
  'sodium benzoate', 'potassium benzoate', 'artificial sweetener',
  'artificial flavour', 'artificial flavor', 'artificial colour',
  'artificial color', 'propylene glycol', 'polysorbate 80',
  'carrageenan', 'sodium phosphate', 'phosphoric acid',
  'caramel colour', 'caramel color', 'e150d', 'e951', 'e950',
  'e621', 'e211', 'e249', 'e250', 'e320', 'e321', 'e102',
  'e129', 'e110', 'e133', 'e338', 'e452', 'e407',
};

// Moderate concern ingredients (yellow)
const _moderateIngredients = {
  'sugar', 'salt', 'sodium', 'palm oil', 'corn syrup', 'dextrose',
  'maltodextrin', 'modified starch', 'corn starch', 'glucose syrup',
  'fructose', 'sucrose', 'citric acid', 'malic acid',
  'natural flavour', 'natural flavor', 'flavouring', 'flavoring',
  'emulsifier', 'stabiliser', 'stabilizer', 'thickener',
  'acidity regulator', 'anti-caking agent', 'preservative',
  'sunflower oil', 'rapeseed oil', 'vegetable oil',
  'e330', 'e322', 'e471', 'e300', 'e412', 'e415',
  'lecithin', 'mono- and diglycerides',
};

class ProductScreen extends StatefulWidget {
  final String barcode;
  const ProductScreen({super.key, required this.barcode});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<ProductResult> _future;

  @override
  void initState() {
    super.initState();
    _future = OpenFoodFactsService.fetchProduct(widget.barcode);
  }

  Color _getIngredientColor(String ingredient) {
    final lower = ingredient.toLowerCase().trim();
    for (final bad in _badIngredients) {
      if (lower.contains(bad)) return Colors.red;
    }
    for (final mod in _moderateIngredients) {
      if (lower.contains(mod)) return Colors.orange;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Product Info')),
      body: FutureBuilder<ProductResult>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildError('Network error: ${snapshot.error}');
          }

          final product = snapshot.data!;
          if (!product.found) {
            return _buildError(
                'Product not found for barcode:\n${widget.barcode}');
          }

          return _buildProductInfo(product);
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(ProductResult product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          if (product.imageUrl != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  product.imageUrl!,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Name & brand
          Text(
            product.name ?? 'Unknown product',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (product.brand != null)
            Text(product.brand!,
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),

          const SizedBox(height: 8),
          Text('Barcode: ${widget.barcode}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),

          // Allergens
          if (product.allergens.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Allergens',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.allergens
                  .map((a) => Chip(
                        label: Text(a),
                        backgroundColor: Colors.red[50],
                        labelStyle: const TextStyle(color: Colors.red),
                      ))
                  .toList(),
            ),
          ],

          // Ingredients with color coding
          if (product.ingredients.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Ingredients',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            // Legend
            Row(
              children: [
                _legendDot(Colors.green, 'Good'),
                const SizedBox(width: 12),
                _legendDot(Colors.orange, 'Moderate'),
                const SizedBox(width: 12),
                _legendDot(Colors.red, 'Harmful'),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: product.ingredients.map((ingredient) {
                final color = _getIngredientColor(ingredient);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    border: Border.all(color: color, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ingredient,
                    style: TextStyle(
                      color: color.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else if (product.ingredientsText != null &&
              product.ingredientsText!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Ingredients',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(product.ingredientsText!,
                  style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

extension on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness * 0.6).clamp(0.0, 1.0)).toColor();
  }
}
