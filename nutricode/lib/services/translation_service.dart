import 'package:translator/translator.dart';

class TranslationService {
  static final _translator = GoogleTranslator();

  /// Translates a list of strings to English efficiently using a single bulk request.
  /// If [texts] is empty, returns an empty list.
  static Future<List<String>> translateToEnglishBulk(List<String> texts) async {
    if (texts.isEmpty) return [];

    try {
      // Use a strong delimiter to prevent Google Translate from merging lines
      const delimiter = ' | ';
      final combined = texts.join(delimiter);

      final translation = await _translator.translate(combined, to: 'en');
      final translatedCombined = translation.text;

      final result = translatedCombined
          .split('|')
          .map((s) => s.trim().toLowerCase())
          .toList();

      if (result.length != texts.length) {
        return await _translateIndividually(texts);
      }

      return result;
    } catch (e) {
      // If bulk translation fails, try individual
      return await _translateIndividually(texts);
    }
  }

  static Future<List<String>> _translateIndividually(List<String> texts) async {
    final List<String> results = [];
    for (final text in texts) {
      try {
        final t = await _translator.translate(text, to: 'en');
        results.add(t.text.trim().toLowerCase());
        // Small delay to prevent rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        results.add(text.toLowerCase()); // Fallback to original
      }
    }
    return results;
  }

  /// Translates a single string to English.
  static Future<String> translateToEnglish(String text) async {
    if (text.trim().isEmpty) return '';
    try {
      final translation = await _translator.translate(text, to: 'en');
      return translation.text.trim().toLowerCase();
    } catch (e) {
      return text.toLowerCase();
    }
  }
}
