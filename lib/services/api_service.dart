import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tripify/models/search_result_model.dart';

const String _apiKey =
    'c2ce8e28c5bd2bc45691daf2bb5646d7b7bc33a8f8b5aa2fad485482a4e92bf3';
const String _baseUrl = 'https://serpapi.com/search.json';

Future<List<SearchResult>> fetchResults(String query) async {
  if (query.trim().isEmpty) return [];

  final uri = Uri.https('serpapi.com', '/search.json', {
    'engine': 'google',
    'q': query,
    'api_key': _apiKey,
    'hl': 'en', 
    'gl': 'us', 
    'num': '10', 
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> items = data['organic_results'] ?? [];
    return items.map((e) => SearchResult.fromJson(e)).toList();
  } else {
    throw Exception(
      'Gagal memuat hasil pencarian: ${response.statusCode} - ${response.reasonPhrase}',
    );
  }
}
