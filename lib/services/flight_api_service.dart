import 'dart:math';
import '../models/flight_model.dart';

class FlightApiService {
  static final List<String> _airlines = [
    'Garuda Indonesia',
    'Singapore Airlines',
    'Emirates',
    'Qatar Airways',
    'Cathay Pacific',
    'Japan Airlines',
    'Korean Air',
    'Turkish Airlines',
    'Air France',
    'British Airways',
    'Qantas',
    'Thai Airways',
    'Lufthansa',
    'KLM',
  ];

  static final List<Map<String, dynamic>> _internationalDestinations = [
    {'city': 'Paris', 'code': 'CDG', 'country': 'France', 'basePrice': 12500000, 'duration': 15, 'currency': 'EUR'},
    {'city': 'Tokyo', 'code': 'HND', 'country': 'Japan', 'basePrice': 8500000, 'duration': 7, 'currency': 'JPY'},
    {'city': 'New York', 'code': 'JFK', 'country': 'USA', 'basePrice': 15500000, 'duration': 21, 'currency': 'USD'},
    {'city': 'London', 'code': 'LHR', 'country': 'UK', 'basePrice': 11500000, 'duration': 14, 'currency': 'GBP'},
    {'city': 'Dubai', 'code': 'DXB', 'country': 'UAE', 'basePrice': 6500000, 'duration': 9, 'currency': 'AED'},
    {'city': 'Bangkok', 'code': 'BKK', 'country': 'Thailand', 'basePrice': 3500000, 'duration': 4, 'currency': 'THB'},
    {'city': 'Sydney', 'code': 'SYD', 'country': 'Australia', 'basePrice': 9500000, 'duration': 7, 'currency': 'AUD'},
    {'city': 'Seoul', 'code': 'ICN', 'country': 'South Korea', 'basePrice': 7500000, 'duration': 7, 'currency': 'KRW'},
    {'city': 'Rome', 'code': 'FCO', 'country': 'Italy', 'basePrice': 10500000, 'duration': 13, 'currency': 'EUR'},
    {'city': 'Istanbul', 'code': 'IST', 'country': 'Turkey', 'basePrice': 8500000, 'duration': 12, 'currency': 'TRY'},
  ];

  static final Map<String, Map<String, dynamic>> _destinationCache = {};

  static Future<List<FlightModel>> searchFlights({
    required String origin,
    required String destination,
    required DateTime departDate,
    DateTime? returnDate,
    int passengers = 1,
    String cabinClass = 'Economy',
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final random = Random();
    final List<FlightModel> flights = [];

    if (destination.isEmpty) return flights;

    final originCode = _extractAirportCode(origin);
    final destinationCode = _extractAirportCode(destination);

    final destInfo = _findDestination(destination);
    if (destInfo == null) {
      return flights;
    }

    final double basePrice = destInfo['basePrice'] as double;
    final int baseDuration = destInfo['duration'] as int;
    final String destCity = destInfo['city'] as String;
    final String destCode = destInfo['code'] as String;

    double adjustedPrice = basePrice;
    switch (cabinClass) {
      case 'Premium':
        adjustedPrice *= 1.5;
        break;
      case 'Business':
        adjustedPrice *= 2.5;
        break;
      case 'First':
        adjustedPrice *= 4.0;
        break;
    }

    final flightCount = 2 + random.nextInt(3);

    for (int i = 0; i < flightCount; i++) {
      final departHour = 8 + random.nextInt(12); 
      final departMinute = random.nextInt(4) * 15; 
      
      final departTime = DateTime(
        departDate.year,
        departDate.month,
        departDate.day,
        departHour,
        departMinute,
      );

      final flightHours = baseDuration;
      final flightMinutes = random.nextInt(60);
      
      final arrivalTime = departTime.add(
        Duration(hours: flightHours, minutes: flightMinutes),
      );

      final durationStr = '${flightHours}h ${flightMinutes}m';

      final priceVariation = 0.85 + random.nextDouble() * 0.3;
      final price = (adjustedPrice * priceVariation).roundToDouble();

      final stops = random.nextInt(2);

      final airline = _selectAirlineByRegion(destCode, random);
      final flightNumber = _generateFlightNumber(airline, random);

      flights.add(FlightModel(
        id: 'FL${departDate.millisecondsSinceEpoch}${random.nextInt(1000)}',
        airline: airline,
        flightNumber: flightNumber,
        originCity: _getCityName(originCode),
        destinationCity: destCity,
        origin: originCode,
        destination: destCode,
        departureTime: departTime,
        arrivalTime: arrivalTime,
        duration: durationStr,
        price: price,
        cabinClass: cabinClass,
        stops: stops,
      ));
    }

    flights.sort((a, b) => a.departureTime.compareTo(b.departureTime));

    return flights;
  }

  static Map<String, dynamic>? _findDestination(String query) {
    if (query.isEmpty) return null;

    final cacheKey = query.toLowerCase();
    if (_destinationCache.containsKey(cacheKey)) {
      return _destinationCache[cacheKey];
    }

    final regex = RegExp(r'\(([A-Z]{3})\)');
    final match = regex.firstMatch(query);
    
    if (match != null) {
      final code = match.group(1);
      for (var dest in _internationalDestinations) {
        if (dest['code'] == code) {
          _destinationCache[cacheKey] = dest;
          return dest;
        }
      }
    }

    final normalizedQuery = query.toLowerCase();
    for (var dest in _internationalDestinations) {
      final cityName = dest['city'].toString().toLowerCase();
      if (normalizedQuery.contains(cityName) || cityName.contains(normalizedQuery)) {
        _destinationCache[cacheKey] = dest;
        return dest;
      }
    }

    return null;
  }

  static String _selectAirlineByRegion(String destCode, Random random) {
    final Map<String, List<String>> regionAirlines = {
      'CDG': ['Air France', 'Garuda Indonesia', 'KLM', 'Lufthansa'],
      'LHR': ['British Airways', 'Garuda Indonesia', 'Qatar Airways'],
      'FCO': ['Garuda Indonesia', 'Emirates', 'Turkish Airlines'],
      'HND': ['Japan Airlines', 'Garuda Indonesia', 'Singapore Airlines'],
      'ICN': ['Korean Air', 'Garuda Indonesia', 'Asiana Airlines'],
      'DXB': ['Emirates', 'Garuda Indonesia', 'Qatar Airways'],
      'IST': ['Turkish Airlines', 'Garuda Indonesia', 'Emirates'],
      'BKK': ['Thai Airways', 'Garuda Indonesia', 'Singapore Airlines'],
      'JFK': ['Garuda Indonesia', 'Singapore Airlines', 'Qatar Airways'],
      'SYD': ['Qantas', 'Garuda Indonesia', 'Singapore Airlines'],
    };

    return regionAirlines[destCode]?[random.nextInt(regionAirlines[destCode]!.length)] 
           ?? _airlines[random.nextInt(_airlines.length)];
  }

  static String _extractAirportCode(String input) {
    final regex = RegExp(r'\(([A-Z]{3})\)');
    final match = regex.firstMatch(input);
    return match?.group(1) ?? 'CGK';
  }

  static String _getCityName(String airportCode) {
    for (var dest in _internationalDestinations) {
      if (dest['code'] == airportCode) {
        return dest['city'] as String;
      }
    }
    return 'Jakarta';
  }

  static String _generateFlightNumber(String airline, Random random) {
    final Map<String, String> airlinePrefixes = {
      'Garuda Indonesia': 'GA',
      'Singapore Airlines': 'SQ',
      'Emirates': 'EK',
      'Qatar Airways': 'QR',
      'Cathay Pacific': 'CX',
      'Japan Airlines': 'JL',
      'Korean Air': 'KE',
      'Turkish Airlines': 'TK',
      'Air France': 'AF',
      'British Airways': 'BA',
      'Qantas': 'QF',
      'Thai Airways': 'TG',
      'Lufthansa': 'LH',
      'KLM': 'KL',
    };

    final prefix = airlinePrefixes[airline] ?? 'GA';
    final flightNum = 100 + random.nextInt(800);
    return '$prefix$flightNum';
  }

  static List<Map<String, dynamic>> getInternationalDestinations() {
    return _internationalDestinations;
  }
}