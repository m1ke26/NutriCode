import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:NutriCode/screens/scanner_screen.dart';
import 'package:NutriCode/screens/verdict_screen.dart';
import '../mock_helper.dart';

const _mockProductResponse = '''
{
  "status": 1,
  "product": {
    "product_name": "Test Product",
    "brands": "Test Brand",
    "ingredients": [],
    "image_front_url": "https://example.com/image.jpg",
    "nutriscore_grade": "a",
    "nutrient_levels": {"fat": "low"}
  }
}
''';

void main() {
  group('ScannerScreen widget tests', () {
    testWidgets('scan button enters scanning mode and can be cancelled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ScannerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Point the camera at a barcode'), findsOneWidget);

      await tester.tap(find.text('Scan'));
      await tester.pump();

      expect(find.text('Scanning...'), findsOneWidget);
      expect(find.text('Looking for barcode...'), findsOneWidget);

      // Tap the same button again to cancel the scan
      await tester.tap(find.text('Scanning...'));
      await tester.pump();

      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Point the camera at a barcode'), findsOneWidget);
    });

    testWidgets('manual barcode submission navigates to VerdictScreen', (
      WidgetTester tester,
    ) async {
      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(createTestableWidget(const ScannerScreen()));
        await tester.pumpAndSettle();

        final inputField = find.byType(TextField);
        expect(inputField, findsOneWidget);

        await tester.enterText(inputField, '0123456789012');
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        expect(find.byType(VerdictScreen), findsOneWidget);
        expect(find.text('NutriCode'), findsOneWidget);
      }, createHttpClient: (_) => _MockHttpClient());
    });

    testWidgets('renders scanner screen elements correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ScannerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('NutriCode'), findsOneWidget);
      expect(find.text('Point the camera at a barcode'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter barcode manually...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('manual barcode field accepts input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ScannerScreen()));
      await tester.pumpAndSettle();

      final fieldFinder = find.byType(TextField);
      expect(fieldFinder, findsOneWidget);

      await tester.enterText(fieldFinder, '123456789012');
      await tester.pump();

      final textField = tester.widget<TextField>(fieldFinder);
      expect(textField.controller?.text, '123456789012');
    });

    testWidgets('empty manual barcode submission does not navigate away', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ScannerScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(VerdictScreen), findsNothing);
      expect(find.text('NutriCode'), findsOneWidget);
    });

    testWidgets('flashlight toggle button exists on scanner screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(const ScannerScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.flash_off), findsOneWidget);
    });
  });
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockHttpClientRequest();
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final _headers = _MockHttpHeaders();

  @override
  Encoding encoding = utf8;

  @override
  HttpHeaders get headers => _headers;

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  int get contentLength => utf8.encode(_mockProductResponse).length;

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
      utf8.encode(_mockProductResponse),
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
  void clear() {
    _values.clear();
  }

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
