import 'dart:convert';
import 'package:http/http.dart' as http;


const String _SERPAPI_KEY = 'c2ce8e28c5bd2bc45691daf2bb5646d7b7bc33a8f8b5aa2fad485482a4e92bf3';

class TravelApiService {
  static Future<Map<String, String?>> fetchWikiInfo(String cityName) async {
    final title = Uri.encodeComponent(cityName);
    final url = Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$title');

    try {
      final resp = await http.get(url);
      if (resp.statusCode != 200) return {'description': null, 'photo': null};

      final data = json.decode(resp.body) as Map<String, dynamic>;
      final extract = (data['extract'] as String?)?.trim();
      String? thumb;
      if (data['thumbnail'] != null && data['thumbnail']['source'] != null) {
        thumb = data['thumbnail']['source'] as String;
      } else if (data['originalimage'] != null && data['originalimage']['source'] != null) {
        thumb = data['originalimage']['source'] as String;
      }

      return {'description': extract, 'photo': thumb};
    } catch (e) {
      return {'description': null, 'photo': null};
    }
  }

  static Future<Map<String, dynamic>> fetchFlightInfo(String originIata, String destinationName) async {
    if (_SERPAPI_KEY == 'YOUR_SERPAPI_API_KEY') {
      return {'flightPrice': null, 'flightCurrency': null, 'snippet': null, 'photo': null};
    }

    try {
      final q = 'explore $destinationName from $originIata';
      final uri = Uri.https('serpapi.com', '/search.json', {
        'engine': 'google_travel_explore',
        'q': q,
        'api_key': _SERPAPI_KEY,
        'hl': 'en',
        'gl': 'us',
        'currency': 'USD',
      });

      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        return {'flightPrice': null, 'flightCurrency': null, 'snippet': null, 'photo': null};
      }

      final Map<String, dynamic> data = json.decode(resp.body);
      if (data['destinations'] != null && data['destinations'] is List) {
        final List destinations = data['destinations'] as List;
        Map? match;
        for (var d in destinations) {
          final name = (d['name'] as String?)?.toLowerCase() ?? '';
          if (name.contains(destinationName.toLowerCase().split(' ').first)) {
            match = d as Map;
            break;
          }
        }
        match ??= destinations.first as Map;

        final flightPrice = (match['flight_price'] is num) ? (match['flight_price'] as num).toDouble() : null;
        final hotelPrice = (match['hotel_price'] is num) ? (match['hotel_price'] as num).toDouble() : null;
        final snippet = match['name'] ?? match['destination_id'] ?? null;
        final photo = match['thumbnail'] as String?;
        return {
          'flightPrice': flightPrice ?? hotelPrice,
          'flightCurrency': 'USD',
          'snippet': snippet,
          'photo': photo,
        };
      }

      if (data['organic_results'] != null && (data['organic_results'] as List).isNotEmpty) {
        final first = (data['organic_results'] as List).first as Map<String, dynamic>;
        return {
          'flightPrice': null,
          'flightCurrency': null,
          'snippet': first['snippet'] as String?,
          'photo': first['thumbnail']?['src'] as String?,
        };
      }

      return {'flightPrice': null, 'flightCurrency': null, 'snippet': null, 'photo': null};
    } catch (e) {
      return {'flightPrice': null, 'flightCurrency': null, 'snippet': null, 'photo': null};
    }
  }

  static Future<Map<String, dynamic>> fetchDestinationInfo({required String cityName, required String originIata}) async {
    final wiki = await fetchWikiInfo(cityName);
    final flight = await fetchFlightInfo(originIata, cityName);

    return {
      'photo': (flight['photo'] as String?) ?? (wiki['photo'] as String?),
      'description': (wiki['description'] as String?) ?? (flight['snippet'] as String?),
      'flightPrice': flight['flightPrice'],
      'flightCurrency': flight['flightCurrency'],
    };
  }
}
