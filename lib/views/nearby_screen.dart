import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  LatLng? _userLocation;
  String? _userAddress;

  List<Map<String, dynamic>> _tourismList = [];
  bool _loading = true;

  final Distance _distance = const Distance();

  final String NOMINATIM_URL =
      'https://nominatim.openstreetmap.org/reverse?format=json';
  final String USER_AGENT =
      'TripifyAppFlutter/1.0 (ferawati@example.org)'; 

  final List<Map<String, dynamic>> _foreignTourism = const [
    {"name": "Eiffel Tower", "lat": 48.8584, "lng": 2.2945, "default_address": "Paris, France", "country": "Paris, France"},
    {"name": "Statue of Liberty", "lat": 40.6892, "lng": -74.0445, "default_address": "New York, USA", "country": "New York, USA"},
    {"name": "Big Ben", "lat": 51.5007, "lng": -0.1246, "default_address": "London, UK", "country": "London, UK"},
    {"name": "Tokyo Skytree", "lat": 35.7100, "lng": 139.8107, "default_address": "Tokyo, Japan", "country": "Tokyo, Japan"},
    {"name": "Colosseum", "lat": 41.8902, "lng": 12.4922, "default_address": "Rome, Italy", "country": "Rome, Italy"},
    {"name": "Burj Khalifa", "lat": 25.1972, "lng": 55.2744, "default_address": "Dubai, UAE", "country": "Dubai, UAE"},
    {"name": "Sydney Opera House", "lat": -33.8568, "lng": 151.2153, "default_address": "Sydney, Australia", "country": "Sydney, Australia"},
    {"name": "Christ The Redeemer", "lat": -22.9519, "lng": -43.2105, "default_address": "Rio de Janeiro, Brazil", "country": "Rio de Janeiro, Brazil"},
  ];

  double _maxDistanceKm = 3000.0;

  @override
  void initState() {
    super.initState();
    _fetchNearby();
  }

  Future<LatLng?> _getUserLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar('Layanan lokasi dimatikan.');
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnackbar('Izin lokasi ditolak.');
        return null;
      }
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    debugPrint("User Location: ${pos.latitude}, ${pos.longitude}");

    return LatLng(pos.latitude, pos.longitude);
  }

  Future<String> _getFullAddress(double lat, double lng) async {
    try {
      final url = Uri.parse(
        '$NOMINATIM_URL&lat=$lat&lon=$lng&zoom=18&addressdetails=1'
      );

      final res = await http.get(
        url,
        headers: {
          'User-Agent': USER_AGENT,
          'Accept-Language': 'id'
        },
      );

      debugPrint("Reverse response: ${res.statusCode}");
      debugPrint("BODY: ${res.body}");

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['display_name'] ?? 'Alamat tidak ditemukan';
      }
    } catch (e) {
      debugPrint("Reverse ERROR: $e");
    }

    return 'Alamat tidak ditemukan';
  }

  Future<String> _getCountry(double lat, double lng) async {
    try {
      final url = Uri.parse(
        '$NOMINATIM_URL&lat=$lat&lon=$lng&zoom=10&addressdetails=1'
      );

      final res = await http.get(
        url,
        headers: {
          'User-Agent': USER_AGENT,
          'Accept-Language': 'en'
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['address']?['country'] ?? 'Unknown Country';
      }
    } catch (e) {
      debugPrint("Country Error: $e");
    }
    return 'Unknown Country';
  }

  Future<void> _getNearbyTourism(LatLng userLocation) async {
    List<Map<String, dynamic>> nearby = [];

    for (var poi in _foreignTourism) {
      final poiLatLng = LatLng(poi['lat'], poi['lng']);
      final km = _distance.as(LengthUnit.Kilometer, poiLatLng, userLocation);

      if (km <= _maxDistanceKm) {
        final country = await _getCountry(poi['lat'], poi['lng']);
        if (country.toLowerCase() != 'indonesia') {
          nearby.add({
            ...poi,
            "distance": km,
            "address": country,
          });
        }
      }
    }

    nearby.sort((a, b) => a['distance'].compareTo(b['distance']));
    setState(() => _tourismList = nearby);
  }

  Future<void> _fetchNearby() async {
    setState(() => _loading = true);

    final loc = await _getUserLocation();
    if (loc == null) {
      setState(() => _loading = false);
      return;
    }

    _userLocation = loc;
    _userAddress = await _getFullAddress(loc.latitude, loc.longitude);

    await _getNearbyTourism(loc);

    setState(() => _loading = false);
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.poppins())));
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5D7B79);
    const accentColor = Color(0xFF3E5F5C);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),

      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Nearby Destinations",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFFA5F04F),
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          if (_userLocation != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.15),
                      primaryColor.withOpacity(0.05)
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.my_location, color: Colors.black, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Current Location",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _userAddress ?? "Mengambil alamat...",
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Lat: ${_userLocation!.latitude.toStringAsFixed(4)} | Lng: ${_userLocation!.longitude.toStringAsFixed(4)}",
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Search Radius",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      "${_maxDistanceKm.toStringAsFixed(0)} km",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey.shade700),
                    ),
                    Slider(
                      value: _maxDistanceKm,
                      min: 50,
                      max: 20000,
                      activeColor: primaryColor,
                      label: "${_maxDistanceKm.toStringAsFixed(0)} km",
                      onChanged: (v) => setState(() => _maxDistanceKm = v),
                      onChangeEnd: (_) => _fetchNearby(),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: _fetchNearby,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                        ),
                        child: Text(
                          "Refresh",
                          style: GoogleFonts.poppins(fontSize: 14, color: Color(0xFFA5F04F)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _tourismList.isEmpty
                    ? Center(
                        child: Text(
                        "There is no destinations found.",
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade700, fontSize: 14),
                      ))
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _tourismList.length,
                        itemBuilder: (context, i) {
                          final item = _tourismList[i];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.07),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.public,
                                  color: primaryColor,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                item['name'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                item['address'],
                                style: GoogleFonts.poppins(
                                    color: Colors.grey.shade700, fontSize: 13),
                              ),
                              trailing: Text(
                                "${item['distance'].toStringAsFixed(1)} km",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }),
          ),
        ],
      ),
    );
  }
}
