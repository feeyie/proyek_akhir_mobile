import 'dart:math';
import 'package:geolocator/geolocator.dart';

class AirportInfo {
  final String iata;
  final String name;
  final double lat;
  final double lon;

  AirportInfo({required this.iata, required this.name, required this.lat, required this.lon});
}

final List<AirportInfo> _supportedAirports = [
  AirportInfo(iata: 'CGK', name: 'Soekarno-Hatta Intl (Jakarta)', lat: -6.125567, lon: 106.655998),
  AirportInfo(iata: 'YIA', name: 'Yogyakarta International (Kulon Progo)', lat: -7.7886, lon: 110.4314),
  AirportInfo(iata: 'SUB', name: 'Juanda Intl (Surabaya)', lat: -7.3797, lon: 112.6676),
  AirportInfo(iata: 'DPS', name: 'Ngurah Rai (Bali)', lat: -8.7481, lon: 115.1675),
  AirportInfo(iata: 'KNO', name: 'Kualanamu (Medan)', lat: 3.6429, lon: 98.8852),
  AirportInfo(iata: 'BPN', name: 'Sultan Aji Muhammad S. (Balikpapan)', lat: -1.2681, lon: 116.8947),
];

class LocationService {
  static Future<Position> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  static double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; 
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat/2) * sin(dLat/2) + cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon/2) * sin(dLon/2);
    final c = 2 * atan2(sqrt(a), sqrt(1-a));
    return R * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);

  static AirportInfo getNearestAirport(double lat, double lon) {
    AirportInfo nearest = _supportedAirports.first;
    double best = double.infinity;
    for (var a in _supportedAirports) {
      final d = _distanceKm(lat, lon, a.lat, a.lon);
      if (d < best) {
        best = d;
        nearest = a;
      }
    }
    return nearest;
  }
}
