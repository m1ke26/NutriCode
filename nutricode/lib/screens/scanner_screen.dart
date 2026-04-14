import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'product_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _barcodeController = TextEditingController();
  bool _isNavigating = false;

  @override
  void dispose() {
    _controller.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isNavigating) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _navigateToProduct(barcode.rawValue!);
  }

  void _navigateToProduct(String barcode) {
    if (_isNavigating || barcode.trim().isEmpty) return;

    setState(() => _isNavigating = true);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductScreen(barcode: barcode.trim()),
      ),
    ).then((_) {
      if (mounted) setState(() => _isNavigating = false);
    });
  }

  void _onManualSubmit() {
    _navigateToProduct(_barcodeController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('NutriCode'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Camera preview 500x300 with white background
          Center(
            child: Container(
              width: 500,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onBarcodeDetected,
                    ),
                    Center(
                      child: Container(
                        width: 224,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.greenAccent, width: 3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Point camera at a barcode',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // Manual barcode input below camera - responsive
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 800
                  ? MediaQuery.of(context).size.width * 0.3
                  : 24,
            ),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _barcodeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Enter barcode...',
                        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _onManualSubmit(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _onManualSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B998B),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.search, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
