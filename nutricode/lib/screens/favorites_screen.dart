import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorite_product.dart';
import '../providers/favorites_provider.dart';
import 'verdict_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback? onGoToScan;
  const FavoritesScreen({super.key, this.onGoToScan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, _) {
          if (favoritesProvider.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildList(context, favoritesProvider);
        },
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 60,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add products to your favorites\nto quickly check them later.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[500], height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onGoToScan?.call();
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Start Scanning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B998B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Favorites list ───────────────────────────────────────────────
  Widget _buildList(BuildContext context, FavoritesProvider provider) {
    final favorites = provider.favorites;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildCard(context, favorites[index], provider),
    );
  }

  Widget _buildCard(BuildContext context, FavoriteProduct item, FavoritesProvider provider) {
    return Dismissible(
      key: Key('fav_${item.barcode}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Remove Favorite'),
            content: Text('Remove "${item.name ?? 'this product'}" from favorites?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        provider.removeFavorite(item.barcode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name ?? 'Product'} removed from favorites'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF2C3E50),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade100,
                  child: item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey,
                            size: 28,
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Info + button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? 'Unknown Product',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.brand != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.brand!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(item.addedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VerdictScreen(barcode: item.barcode, saveToHistory: false),
                          ),
                        ),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Check Product'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1B998B),
                          side: const BorderSide(color: Color(0xFF1B998B)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Favorite heart — tap to remove
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  key: Key('remove_fav_${item.barcode}'),
                  onTap: () {
                    provider.removeFavorite(item.barcode);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name ?? 'Product'} removed from favorites'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF2C3E50),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.favorite_rounded,
                    color: Colors.amber.shade600,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    final base = '$d/$m/$y';

    if (diff.inDays == 0) return 'Added $base (today)';
    if (diff.inDays == 1) return 'Added $base (yesterday)';
    if (diff.inDays < 7) return 'Added $base (${diff.inDays} days ago)';
    return 'Added $base';
  }
}
