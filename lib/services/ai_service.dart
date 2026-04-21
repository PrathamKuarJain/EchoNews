import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class AIService {
  Future<({String category, double authenticityScore, String reasoning})> analyzePost(String text) async {
    if (AppConstants.geminiApiKey.isEmpty) {
      return (category: 'General', authenticityScore: 0.5, reasoning: 'API Key missing.');
    }

    try {
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${AppConstants.geminiApiKey}';

      final prompt = '''
Analyze the following news post text and return a JSON object with three fields:
1. "category": A single-word category name (e.g., Politics, Tech, Sports, Entertainment, Health, Science).
2. "authenticityScore": A double between 0.0 and 1.0 representing how likely the post is to be authentic/true (1.0 is highly likely authentic, 0.0 is likely fake/misinformation).
3. "reasoning": A brief one-sentence explanation of why you chose this category and this score.

Post text:
"$text"

Return ONLY the JSON object.
''';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
             'response_mime_type': 'application/json',
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        final jsonResult = jsonDecode(content);

        final String category = (jsonResult['category'] as String?) ?? 'General';
        final double authenticityScore = (jsonResult['authenticityScore'] as num?)?.toDouble() ?? 0.5;
        final String reasoning = (jsonResult['reasoning'] as String?) ?? 'No reasoning provided.';

        print('--- Gemini AI Analysis ---');
        print('Category: $category');
        print('Authenticity Score: $authenticityScore');
        print('AI Reasoning: $reasoning');

        return (
          category: category,
          authenticityScore: authenticityScore,
          reasoning: reasoning,
        );
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return (category: 'General', authenticityScore: 0.5, reasoning: 'API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('AI Analysis Error: $e');
      return (category: 'General', authenticityScore: 0.5, reasoning: 'Exception: $e');
    }
  }
}
