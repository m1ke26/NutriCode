import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scan_history_entry.dart';
import '../providers/history_provider.dart';
import 'verdict_screen.dart';

class HistoryScreen extends StatelessWidget {
  final VoidCallback? onGoToScan;
  const HistoryScreen({super.key, this.onGoToScan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          'Scan History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, history, _) {
          if (history.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildList(context, history.entries);
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
                color: const Color(0xFF1B998B).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 60,
                color: Color(0xFF1B998B),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No scans yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by scanning a product.\nYour scan history will appear here.',
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

  // ── History list ──────────────────────────────────────────────────
  Widget _buildList(BuildContext context, List<ScanHistoryEntry> entries) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildCard(context, entries[index]),
    );
  }

  Widget _buildCard(BuildContext context, ScanHistoryEntry entry) {
    return Container(
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
                child: entry.imageUrl != null
                    ? Image.network(
                        entry.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
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
                    entry.name ?? 'Unknown Product',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entry.brand != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.brand!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(entry.scannedAt),
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
                              VerdictScreen(barcode: entry.barcode, saveToHistory: false),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('View Full Scan'),
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
          ],
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

    if (diff.inDays == 0) return '$base (today)';
    if (diff.inDays == 1) return '$base (yesterday)';
    if (diff.inDays < 7) return '$base (${diff.inDays} days ago)';
    return base;
  }
}
