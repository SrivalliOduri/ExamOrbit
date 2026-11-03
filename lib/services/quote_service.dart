
import 'dart:convert';

import 'package:http/http.dart' as http;

/// A motivational quote shown on the dashboard.
class Quote {
  const Quote({required this.text, required this.author});

  final String text;
  final String author;
}

/// Fetches motivational quotes from the ZenQuotes API.
class QuoteService {
  QuoteService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _endpoint = Uri.parse(
    'https://zenquotes.io/api/random',
  );

  static const Duration _timeout = Duration(seconds: 8);

  /// Default quote displayed whenever the API is unavailable.
  static const Quote _fallbackQuote = Quote(
    text: 'Small steps every day lead to meaningful progress.',
    author: 'ExamOrbit',
  );

  final http.Client _client;

  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await _client
          .get(_endpoint)
          .timeout(_timeout);

      if (response.statusCode != 200) {
        return _fallbackQuote;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List ||
          decoded.isEmpty ||
          decoded.first is! Map) {
        return _fallbackQuote;
      }

      final first = decoded.first as Map;
      final text = first['q'];
      final author = first['a'];

      if (text is! String || text.trim().isEmpty) {
        return _fallbackQuote;
      }

      return Quote(
        text: text,
        author: author is String && author.trim().isNotEmpty
            ? author
            : 'Unknown',
      );
    } catch (_) {
      return _fallbackQuote;
    }
  }

  void dispose() => _client.close();
}
