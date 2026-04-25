import 'package:flutter/material.dart';
import '../utils/ingredient_classifier.dart';
import '../utils/ingredient_descriptions.dart';

/// Shows a modal bottom sheet with a description of the given ingredient.
///
/// The description is looked up from the local dictionary first.  If no entry
/// is found the sheet displays a generic message based on the ingredient's
/// classification level.
void showIngredientInfo(
  BuildContext context, {
  required String ingredientName,
  String? englishName,
  required IngredientLevel level,
}) {
  final nameForLookup = englishName?.isNotEmpty == true ? englishName! : ingredientName;
  final lower = nameForLookup.toLowerCase().trim();

  // Try exact match first, then substring match against known keys
  String? description = ingredientDescriptions[lower];
  if (description == null) {
    final entries = ingredientDescriptions.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in entries) {
      if (lower.contains(entry.key)) {
        description = entry.value;
        break;
      }
    }
  }

  // Fallback when not in dictionary
  description ??= _fallbackDescription(level);

  final Color color;
  final IconData icon;
  final String levelLabel;
  switch (level) {
    case IngredientLevel.bad:
      color = Colors.red;
      icon = Icons.warning_amber_rounded;
      levelLabel = 'Avoid';
      break;
    case IngredientLevel.moderate:
      color = Colors.orange;
      icon = Icons.info_outline;
      levelLabel = 'Moderate';
      break;
    case IngredientLevel.good:
      color = Colors.green;
      icon = Icons.check_circle_outline;
      levelLabel = 'Good';
      break;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.55,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Icon + level badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      ingredientName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      levelLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      description!,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF34495E),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Close button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: color.withValues(alpha: 0.1),
                    foregroundColor: color,
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _fallbackDescription(IngredientLevel level) {
  switch (level) {
    case IngredientLevel.good:
      return 'This ingredient is generally considered safe and is commonly found in everyday foods. No significant health concerns have been identified.';
    case IngredientLevel.moderate:
      return 'This ingredient is acceptable in small amounts but may pose health concerns if consumed excessively. Consider moderating your intake.';
    case IngredientLevel.bad:
      return 'This ingredient has been flagged as potentially harmful. It may be associated with adverse health effects. Consider avoiding products that contain it.';
  }
}
