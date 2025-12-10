import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiService {
  AiService();

  Future<Map<String, dynamic>> parseTaskFromNaturalLanguage(String input) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key');

    if (apiKey == null || apiKey.isEmpty) {
      // Return empty or maybe a special error key if the UI can handle it.
      // For now, empty map will just show "Could not understand task" in UI.
      return {};
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final content = [Content.text('''
      Parse the following task description into a JSON object with keys:
      - taskName (string)
      - dueDate (ISO8601 string, relative to now if unspecified)
      - subtasks (list of strings)

      Input: "$input"
      Return ONLY valid JSON. Do not include markdown formatting.
    ''')];

    try {
      final response = await model.generateContent(content);
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
