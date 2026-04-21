import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'verdict_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.itf,
    ],
  );

  final TextEditingController _barcodeController = TextEditingController();
  bool _isNavigating = false;
  bool _isTorchOn = false;

  // ── Scan-button state ──────────────────────────────────────────────
  bool _isScanning = false;
  String? _lastDetectedBarcode;
  Timer? _scanTimer;
  late AnimationController _scanAnimController;
  late Animation<double> _scanLinePosition;

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scanLinePosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _scanAnimController.dispose();
    _controller.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  // ── Normalize barcode (fix leading-zero drops from ML Kit) ──────────
  String _normalizeBarcode(Barcode barcode) {
    final raw = barcode.rawValue?.trim() ?? '';
    if (raw.isEmpty) return raw;

    // Clean to digits only
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return raw;

    // Determine the expected length from the detected format
    final int? expectedLength;
    switch (barcode.format) {
      case BarcodeFormat.ean13:
        expectedLength = 13;
        break;
      case BarcodeFormat.ean8:
        expectedLength = 8;
        break;
      case BarcodeFormat.upcA:
        expectedLength = 12;
        break;
      case BarcodeFormat.upcE:
        expectedLength = 8;
        break;
      default:
        expectedLength = null;
    }

    // Pad with leading zeros if the scanner dropped them
    if (expectedLength != null && digits.length < expectedLength) {
      return digits.padLeft(expectedLength, '0');
    }

    return digits;
  }

  // ── Barcode detection (only buffers — never auto-navigates) ────────
  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanning || _isNavigating) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.trim().isEmpty) continue;

      _lastDetectedBarcode = _normalizeBarcode(barcode);

      // Found one — stop the timer, stop the animation, navigate immediately
      _scanTimer?.cancel();
      _scanAnimController.stop();
      if (mounted) {
        setState(() => _isScanning = false);
      }
      _navigateToProduct(_lastDetectedBarcode!);
      return;
    }
  }

  // ── Scan button pressed ────────────────────────────────────────────
  void _startScanWindow() {
    if (_isScanning || _isNavigating) return;

    setState(() {
      _isScanning = true;
      _lastDetectedBarcode = null;
    });

    // Animate the scan line back-and-forth indefinitely
    _scanAnimController.repeat(reverse: true);

    // After 8 s, if nothing was found → "product not found"
    _scanTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted || _isNavigating) return;

      _scanAnimController.stop();
      setState(() => _isScanning = false);

      if (_lastDetectedBarcode != null) {
        _navigateToProduct(_lastDetectedBarcode!);
      } else {
        // Navigate with a dummy barcode so VerdictScreen shows "failed to scan"
        _navigateToProduct('FAILED_TO_SCAN');
      }
    });
  }

  void _cancelScan() {
    if (!_isScanning || _isNavigating) return;
    
    _scanTimer?.cancel();
    setState(() {
      _isScanning = false;
    });
    _scanAnimController.stop();
  }

  // ── Navigation ─────────────────────────────────────────────────────
  Future<void> _navigateToProduct(String barcode) async {
    if (_isNavigating || barcode.trim().isEmpty) return;

    setState(() => _isNavigating = true);

    try {
      await _controller.stop();
    } catch (e) {
      debugPrint('Error stopping scanner: $e');
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerdictScreen(barcode: barcode.trim()),
      ),
    );

    // After returning to this screen
    if (mounted) {
      try {
        await _controller.start();
      } catch (e) {
        debugPrint('Error starting scanner: $e');
      }

      // Brief "blind period" to prevent immediately re-scanning the same item
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isNavigating = false;
          _lastDetectedBarcode = null;
          // Flashlight physical state resets when camera stops, so sync state here
          _isTorchOn = false; 
        });
      }
    }
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
          // Scanner area takes up most of the screen
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onBarcodeDetected,
                      fit: BoxFit.cover,
                    ),

                    // Stylized scan window overlay
                    Center(
                      child: Container(
                        width: 280,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isScanning
                                ? const Color(0xFF1B998B)
                                : const Color(0xFF1B998B).withOpacity(0.4),
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            // Animated scan line (only visible while scanning)
                            if (_isScanning)
                              AnimatedBuilder(
                                animation: _scanLinePosition,
                                builder: (context, child) {
                                  return Positioned(
                                    top: _scanLinePosition.value *
                                        (180 - 3 - 16) + 8, // padding offset
                                    left: 30,
                                    right: 30,
                                    child: Container(
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B998B),
                                        borderRadius:
                                            BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF1B998B)
                                                .withOpacity(0.8),
                                            blurRadius: 12,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              // Static scan line when idle
                              Center(
                                child: Container(
                                  height: 3,
                                  width: 220,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B998B)
                                        .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1B998B)
                                            .withOpacity(0.3),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Flashlight toggle
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: IconButton(
                        onPressed: () {
                          _controller.toggleTorch();
                          setState(() {
                            _isTorchOn = !_isTorchOn;
                          });
                        },
                        icon: Icon(
                          _isTorchOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 32,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── SCAN BUTTON ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isNavigating
                    ? null
                    : (_isScanning ? _cancelScan : _startScanWindow),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isScanning
                      ? const Color(0xFF15796E)
                      : const Color(0xFF1B998B),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF15796E),
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _isScanning ? 0 : 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isScanning) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'A ler código...',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Small X part to cancel
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ] else ...[
                      const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Scan',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            _isScanning
                ? 'A procurar código de barras...'
                : 'Aponte a câmara para um código de barras',
            style: TextStyle(
              color: _isScanning ? const Color(0xFF1B998B) : Colors.black54,
              fontSize: 14,
              fontWeight:
                  _isScanning ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 12),

          // Manual barcode input
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 800
                  ? MediaQuery.of(context).size.width * 0.3
                  : 24,
            ),
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _barcodeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Inserir código manualmente...',
                        hintStyle: const TextStyle(
                            color: Colors.black38, fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _onManualSubmit(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: _onManualSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B998B),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.search,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
