import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/product_search_service.dart';
import 'verdict_screen.dart';

class SearchScreen extends StatefulWidget {
  final ProductSearchService? service;
  const SearchScreen({super.key, this.service});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  late final ProductSearchService _searchService;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchService = widget.service ?? ProductSearchService();
  }

  List<ProductSearchResult> _results = [];

  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  bool _isNetworkError = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    // Rebuild to show/hide the clear button immediately
    setState(() {});
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _searchService.searchByName(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasSearched = true;
          
          if (e is SocketException || e is TimeoutException) {
            _errorMessage = 'Could not connect. Please check your internet connection.';
            _isNetworkError = true;
          } else {
            // Usually means Open Food Facts returned a 50x error or rate limit
            _errorMessage = 'The search service is currently unavailable. Please try again later.';
            _isNetworkError = false;
          }
        });
      }
    }
  }

  void _onSubmit() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // Unfocus keyboard when searching
      _focusNode.unfocus();
      _performSearch(query);
    }
  }

  void _navigateToProduct(String barcode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerdictScreen(barcode: barcode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App wordmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.eco_rounded, color: Color(0xFF1B998B), size: 22),
                      const SizedBox(width: 7),
                      const Text(
                        'NutriCode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B998B),
                          letterSpacing: 2.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Search Products',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C3E50),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find products by name when barcode is unavailable',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('search_text_field'),
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        onSubmitted: (_) => _onSubmit(),
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C3E50),
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Coca-Cola, Nutella...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF1B998B),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  key: const Key('clear_search_button'),
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                    _focusNode.requestFocus();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    // Submit button
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Material(
                        color: const Color(0xFF1B998B),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          key: const Key('search_submit_button'),
                          onTap: _onSubmit,
                          borderRadius: BorderRadius.circular(12),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(Icons.search, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ── Results Area ──────────────────────────────────────
            Expanded(
              child: _buildResultsArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF1B998B)),
            SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(fontSize: 15, color: Colors.blueGrey),
            ),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isNetworkError ? Icons.wifi_off : Icons.error_outline, 
                size: 56, 
                color: _isNetworkError ? Colors.redAccent : Colors.orangeAccent
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    // No results state
    if (_hasSearched && _results.isEmpty) {
      return _buildNoResults();
    }

    // Results list
    if (_results.isNotEmpty) {
      return _buildResultsList();
    }

    // Initial / empty state
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1B998B).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.manage_search_rounded,
              size: 56,
              color: Color(0xFF1B998B),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Type a product name to search',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Great for when a barcode is damaged\nor hard to read',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 56,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No results found',
              key: Key('no_results_text'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any products matching\n"${_searchController.text}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 28),

            // Suggestions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 18, color: Color(0xFF1B998B)),
                      SizedBox(width: 8),
                      Text(
                        'Suggestions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSuggestionItem(
                    Icons.spellcheck,
                    'Check your spelling and try again',
                  ),
                  const SizedBox(height: 8),
                  _buildSuggestionItem(
                    Icons.short_text,
                    'Try a shorter or more general name',
                  ),
                  const SizedBox(height: 8),
                  _buildSuggestionItem(
                    Icons.qr_code_scanner,
                    'Try scanning the barcode instead',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final product = _results[index];
        return _buildResultCard(product, index);
      },
    );
  }

  Widget _buildResultCard(ProductSearchResult product, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: Key('search_result_$index'),
          onTap: () => _navigateToProduct(product.barcode),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade100,
                    child: product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
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

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.brand != null &&
                          product.brand!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          product.brand!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Arrow
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B998B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF1B998B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
