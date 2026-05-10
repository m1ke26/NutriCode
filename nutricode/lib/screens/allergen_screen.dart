import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/allergen_provider.dart';

class AllergenScreen extends StatefulWidget {
  const AllergenScreen({super.key});

  @override
  State<AllergenScreen> createState() => _AllergenScreenState();
}

class _AllergenScreenState extends State<AllergenScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return _AllergenScreenContent(
      query: _query,
      onQueryChanged: (q) => setState(() => _query = q),
    );
  }
}

class _AllergenScreenContent extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQueryChanged;

  const _AllergenScreenContent({
    required this.query,
    required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AllergenProvider>();
    final selectedCount = provider.selectedAllergens.length;

    final filtered = AllergenProvider.commonAllergens.where((a) {
      if (query.isEmpty) return true;
      return AllergenProvider.displayName(a)
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Allergens'),
            if (selectedCount > 0)
              Text(
                '$selectedCount selected',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Search allergens...',
                prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? const Center(
              child: Text(
                'No allergens match your search.',
                style: TextStyle(color: Colors.blueGrey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final allergen = filtered[index];
                final isSelected = provider.isSelected(allergen);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => provider.toggle(allergen),
                  title: Text(
                    AllergenProvider.displayName(allergen),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF1B998B)
                          : const Color(0xFF2C3E50),
                    ),
                  ),
                  activeColor: const Color(0xFF1B998B),
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.trailing,
                  shape: const RoundedRectangleBorder(),
                );
              },
            ),
    );
  }
}
