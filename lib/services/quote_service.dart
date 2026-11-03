import 'dart:convert';

import 'package:http/http.dart' as http;

/// A motivational quote shown on the dashboard.
class Quote {
  const Quote({required this.text, required this.author});

  final String text;
  final String author;
}

class QuoteException implements Exception {
  const QuoteException(this.message);

  final String message;
}

/// Fetches a random quote from the public ZenQuotes API.
class QuoteService {
  QuoteService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _endpoint = Uri.parse('https://zenquotes.io/api/random');
  static const Duration _timeout = Duration(seconds: 8);

  final http.Client _client;

  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await _client.get(_endpoint).timeout(_timeout);
      if (response.statusCode != 200) {
        throw QuoteException('The quote service responded with ${response.statusCode}.');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty || decoded.first is! Map) {
        throw const QuoteException('The quote service returned an unexpected reply.');
      }
      final first = decoded.first as Map<String, dynamic>;
      final text = first['q'];
      if (text is! String || text.isEmpty) {
        throw const QuoteException('The quote service returned an empty quote.');
      }
      final author = first['a'];
      return Quote(text: text, author: author is String ? author : 'Unknown');
    } on QuoteException {
      rethrow;
    } on Exception {
      throw const QuoteException('Could not load a quote. Check your connection and try again.');
    }
  }

  void dispose() => _client.close();
}
