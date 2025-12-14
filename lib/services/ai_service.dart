import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Removing User input requirement

class AiService {
  // TODO: Replace with your actual Gemini API Key.
  // Ideally, this should be built with --dart-define=GEMINI_API_KEY=your_key
  // or fetched from a secure remote config (Firebase Remote Config).
  // For this "free" version, we hardcode or use environment.
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_SECURE_API_KEY_HERE'
  );

  late final GenerativeModel _model;

  AiService() {
    // Only initialize if we have a valid-looking key to avoid crashes on init
    if (_apiKey != 'YOUR_SECURE_API_KEY_HERE') {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );
    }
  }

  Future<Map<String, dynamic>> parseTaskFromNaturalLanguage(String input) async {
    // Check if key is the placeholder
    if (_apiKey == 'YOUR_SECURE_API_KEY_HERE') {
      // Return a special error map that the UI can detect
      return {'error': 'AI_NOT_CONFIGURED'};
    }

    final content = [Content.text('''
      Parse the following task description into a JSON object with keys:
      - taskName (string)
      - dueDate (ISO8601 string, relative to now if unspecified)
      - subtasks (list of strings)

      Input: "$input"
      Return ONLY valid JSON. Do not include markdown formatting.
    ''')];

    try {
      final response = await _model.generateContent(content);
      final text = response.text;
      if (text == null) return {};

      // Basic cleanup if markdown code blocks are returned
      final jsonString = text.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(jsonString);
    } catch (e) {
      // print('AI Error: $e');
      return {};
    }
  }
}
