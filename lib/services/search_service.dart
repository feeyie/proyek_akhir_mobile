import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchResult {
  final String title;
  final String link;
  final String snippet;

  SearchResult({
    required this.title,
    required this.link,
    required this.snippet,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      title: json['title'] ?? 'No Title',
      link: json['link'] ?? '',
      snippet: json['snippet'] ?? 'No description available',
    );
  }
}

class SearchService {
  static const String _apiKey =
      'c2ce8e28c5bd2bc45691daf2bb5646d7b7bc33a8f8b5aa2fad485482a4e92bf3';

  static const String _baseUrl = 'https://serpapi.com/search.json';

  static Future<List<SearchResult>> fetchResults(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      '$_baseUrl?engine=google&q=${Uri.encodeComponent(query)}+travel&api_key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Gagal memuat hasil pencarian (${response.statusCode})");
    }

    final data = json.decode(response.body);

    if (data == null || data['organic_results'] == null) {
      return [];
    }

    final List results = data['organic_results'];
    return results.map((e) => SearchResult.fromJson(e)).toList();
  }
}
