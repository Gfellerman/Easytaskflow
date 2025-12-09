import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // Use a secure way to store API key in production
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  late final GenerativeModel _model;

  AiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<Map<String, dynamic>> parseTaskFromNaturalLanguage(String input) async {
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
