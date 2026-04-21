import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/constants.dart';

class ModerationService {

  Future<({bool isOffensive, double score})> analyzeToxicity(String text) async {
    if (AppConstants.perspectiveApiKey.isEmpty || AppConstants.perspectiveApiKey == 'YOUR_PERSPECTIVE_API_KEY_HERE') {
      print('WARNING: Perspective API key not set in AppConstants. Skipping moderation.');
      return (isOffensive: false, score: 0.0);
    }

    try {
      final String url = 'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=${AppConstants.perspectiveApiKey}';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'comment': {'text': text},
          'languages': ['en'],
          'requestedAttributes': {
            'TOXICITY': {},
            'IDENTITY_ATTACK': {},
            'INSULT': {},
            'PROFANITY': {},
            'THREAT': {},
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final scores = data['attributeScores'];

        // Get scores for all requested attributes
        double toxicity = scores['TOXICITY']?['summaryScore']?['value'] ?? 0.0;
        double identityAttack = scores['IDENTITY_ATTACK']?['summaryScore']?['value'] ?? 0.0;
        double insult = scores['INSULT']?['summaryScore']?['value'] ?? 0.0;
        double profanity = scores['PROFANITY']?['summaryScore']?['value'] ?? 0.0;
        double threat = scores['THREAT']?['summaryScore']?['value'] ?? 0.0;

        // Combine them by taking the maximum score across all categories
        // This ensures if a post is highly insulting but not technically "toxic", it's still caught.
        double maxScore = [toxicity, identityAttack, insult, profanity, threat]
            .reduce((curr, next) => curr > next ? curr : next);

        print('--- Perspective Scores ---');
        print('Combined Max Score: $maxScore (T:$toxicity, IA:$identityAttack, I:$insult, P:$profanity, T:$threat)');

        // Threshold is 0.6
        if (maxScore > 0.6) {
          return (isOffensive: true, score: maxScore);
        }
        
        return (isOffensive: false, score: maxScore);
      } else {
        print('Perspective API Error: ${response.statusCode} - ${response.body}');
        return (isOffensive: false, score: 0.0);
      }
    } catch (e) {
      print('Moderation Error: $e');
      return (isOffensive: false, score: 0.0);
    }
  }

  Future<bool> isPostOffensive(String text) async {
    final result = await analyzeToxicity(text);
    return result.isOffensive;
  }
}
