import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:NutriCode/providers/allergen_provider.dart';
import 'package:NutriCode/screens/verdict_screen.dart';

// ── Mock API responses ────────────────────────────────────────────────────────

// A product whose allergens_tags contains gluten.
// Empty ingredients avoids hitting TranslationService.
const _glutenProductJson = '''
{
  "status": 1,
  "product": {
    "product_name": "Wheat Bread",
    "brands": "Test Bakery",
    "ingredients": [],
    "allergens_tags": ["en:gluten"],
    "nutriscore_grade": "c",
    "nutrient_levels": {}
  }
}
''';

// A product that exists but has no allergen data at all.
const _noAllergenDataJson = '''
{
  "status": 1,
  "product": {
    "product_name": "Mystery Snack",
    "brands": "Unknown Brand",
    "ingredients": [],
    "allergens_tags": [],
    "nutriscore_grade": "b",
    "nutrient_levels": {}
  }
}
''';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Clears all allergens from the singleton so tests are isolated.
void _resetAllergens() {
  for (final a in AllergenProvider.instance.selectedAllergens.toList()) {
    AllergenProvider.instance.toggle(a);
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(_resetAllergens);

  group('US05 — Allergen Filter', () {
    // ── Scenario 1 ──────────────────────────────────────────────────────────
    testWidgets(
      'Scenario 1: red alert banner with allergen name and See Alternatives '
      'button when scanned product contains a user-configured allergen',
      (WidgetTester tester) async {
        await HttpOverrides.runZoned(
          () async {
            // Given: user has configured Gluten as a personal allergen
            AllergenProvider.instance.toggle('gluten');

            // When: the verdict screen loads for a product containing gluten
            await tester.pumpWidget(
              const MaterialApp(
                home: VerdictScreen(barcode: '3017624010701'),
              ),
            );
            await tester.pumpAndSettle();

            // Then: a red alert banner shows the allergen name in upper case
            expect(
              find.textContaining('GLUTEN'),
              findsOneWidget,
              reason: 'Red banner must highlight the matched allergen name',
            );

            // And: a "See Alternatives" button is present
            expect(
              find.text('See Alternatives'),
              findsOneWidget,
              reason: '"See Alternatives" button must appear on allergen match',
            );

            // And: no yellow "data unavailable" warning is shown
            expect(
              find.textContaining('Allergen data unavailable'),
              findsNothing,
            );
          },
          createHttpClient: (_) => _MockHttpClient(_glutenProductJson),
        );
      },
    );

    // ── Scenario 2 ──────────────────────────────────────────────────────────
    testWidgets(
      'Scenario 2: yellow warning shown when product has no allergen data '
      'and no red allergen-match banner appears',
      (WidgetTester tester) async {
        await HttpOverrides.runZoned(
          () async {
            // Given: user has configured Nuts as a personal allergen
            AllergenProvider.instance.toggle('nuts');

            // When: the verdict screen loads for a product with no allergen data
            await tester.pumpWidget(
              const MaterialApp(
                home: VerdictScreen(barcode: '1234567890123'),
              ),
            );
            await tester.pumpAndSettle();

            // Then: a yellow warning about missing allergen data is shown
            expect(
              find.text(
                '⚠️ Allergen data unavailable — check the physical label',
              ),
              findsOneWidget,
              reason: 'Yellow warning must appear when allergen data is absent',
            );

            // And: no red allergen-match banner is shown
            expect(
              find.textContaining('matches your allergen profile'),
              findsNothing,
              reason: 'Red banner must NOT appear when there is no allergen match',
            );

            // And: no "See Alternatives" button (only present on a match)
            expect(
              find.text('See Alternatives'),
              findsNothing,
            );
          },
          createHttpClient: (_) => _MockHttpClient(_noAllergenDataJson),
        );
      },
    );
  });
}

// ── Mock HTTP infrastructure (mirrors scanner_screen_test.dart) ───────────────

class _MockHttpClient implements HttpClient {
  final String _responseBody;
  _MockHttpClient(this._responseBody);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockHttpClientRequest(_responseBody);
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final String _responseBody;
  final _headers = _MockHttpHeaders();

  _MockHttpClientRequest(this._responseBody);

  @override
  Encoding encoding = utf8;

  @override
  HttpHeaders get headers => _headers;

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse(_responseBody);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final String _responseBody;
  _MockHttpClientResponse(this._responseBody);

  @override
  int get statusCode => 200;

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  int get contentLength => utf8.encode(_responseBody).length;

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => 'OK';

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  Future<Socket> detachSocket() {
    throw UnsupportedError('detachSocket is not supported');
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([
      utf8.encode(_responseBody),
    ]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError ?? false,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _values = {};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _values.putIfAbsent(name.toLowerCase(), () => []).add(value.toString());
  }

  @override
  void clear() => _values.clear();

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _values.forEach(action);
  }

  @override
  List<String>? operator [](String name) => _values[name.toLowerCase()];

  @override
  void noFolding(String name) {}

  @override
  void remove(String name, Object value) {
    _values[name.toLowerCase()]?.remove(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = [value.toString()];
  }

  @override
  String? value(String name) {
    final values = this[name];
    if (values == null || values.isEmpty) return null;
    return values.first;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
