import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/destination_model.dart';
import '../services/notification_service.dart';
import '../services/search_service.dart';
import '../services/travel_api_service.dart';
import '../services/location_service.dart';
import '../auth/auth_service.dart';

import 'destination_detail_screen.dart';
import 'result_page.dart';
import 'liked_history_screen.dart';
import 'login_screen.dart';
import 'nearby_screen.dart';
import 'profile_screen.dart';
import 'flight_search_screen.dart';
import 'flight_history_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Set<String> _liked = {};
  late Box _likedBox;
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  List<DestinationModel> filteredDestinations = [];

  static const Color primaryColor = Color(0xFF5D7B79);
  static const Color goTravelColor = Color(0xFFA5F04F);

  final Map<String, double> _exchangeRates = const {
    'USD': 0.000062,
    'EUR': 0.000057,
    'JPY': 0.0092,
    'GBP': 0.00005,
    'AUD': 0.000094,
    'SGD': 0.000084,
    'KRW': 0.085,
    'THB': 0.0022,
    'AED': 0.00023,
    'CNY': 0.00045,
    'TRY': 0.00033,
  };

  late List<DestinationModel> allDestinations = [
    DestinationModel(
        title: 'Paris',
        thumbnail: 'https://picsum.photos/200?1',
        currencyCode: 'EUR',
        timezoneOffset: 1,
        description: 'Menara Eiffel...',
        flightCostIDR: 9800000),
    DestinationModel(
        title: 'Tokyo',
        thumbnail: 'https://picsum.photos/200?2',
        currencyCode: 'JPY',
        timezoneOffset: 9,
        description: 'Kota Futuristik...',
        flightCostIDR: 4500000),
    DestinationModel(
        title: 'New York',
        thumbnail: 'https://picsum.photos/200?3',
        currencyCode: 'USD',
        timezoneOffset: -5,
        description: 'The city that never sleeps',
        flightCostIDR: 13500000),
    DestinationModel(
        title: 'London',
        thumbnail: 'https://picsum.photos/200?4',
        currencyCode: 'GBP',
        timezoneOffset: 0,
        description: 'Big Ben dan sejarah',
        flightCostIDR: 12000000),
    DestinationModel(
        title: 'Dubai',
        thumbnail: 'https://picsum.photos/200?5',
        currencyCode: 'AED',
        timezoneOffset: 4,
        description: 'Gedung pencakar langit',
        flightCostIDR: 8800000),
    DestinationModel(
        title: 'Bangkok',
        thumbnail: 'https://picsum.photos/200?6',
        currencyCode: 'THB',
        timezoneOffset: 7,
        description: 'Surga kuliner',
        flightCostIDR: 4200000),
    DestinationModel(
        title: 'Sydney',
        thumbnail: 'https://picsum.photos/200?7',
        currencyCode: 'AUD',
        timezoneOffset: 10,
        description: 'Opera House',
        flightCostIDR: 9200000),
    DestinationModel(
        title: 'Seoul',
        thumbnail: 'https://picsum.photos/200?8',
        currencyCode: 'KRW',
        timezoneOffset: 9,
        description: 'Budaya Kpop',
        flightCostIDR: 4900000),
    DestinationModel(
        title: 'Rome',
        thumbnail: 'https://picsum.photos/200?9',
        currencyCode: 'EUR',
        timezoneOffset: 1,
        description: 'Kota sejarah',
        flightCostIDR: 10500000),
    DestinationModel(
        title: 'Istanbul',
        thumbnail: 'https://picsum.photos/200?10',
        currencyCode: 'TRY',
        timezoneOffset: 3,
        description: 'Eropa & Asia',
        flightCostIDR: 9300000),
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      _likedBox = Hive.box('liked_destinations_box');
      if (!Hive.isBoxOpen('flight_bookings')) {
        await Hive.openBox('flight_bookings');
      }
    } catch (e) {
      _likedBox = await Hive.openBox('liked_destinations_box');
      await Hive.openBox('flight_bookings');
    }
    _liked = _likedBox.keys.cast<String>().toSet();
    filteredDestinations = List.from(allDestinations);
  }

  bool get _isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (r) => false);
    }
  }

  void _toggleLike(DestinationModel destination) {
    setState(() {
      if (_liked.contains(destination.title)) {
        _liked.remove(destination.title);
        _likedBox.delete(destination.title);
      } else {
        _liked.add(destination.title);
        _likedBox.put(destination.title, {
          'title': destination.title,
          'description': destination.description,
          'thumbnail': destination.thumbnail,
        });
        NotificationService().showNotification(
          destination.title.hashCode,
          'Ditambahkan',
          '${destination.title} ditambahkan ke favorit!',
        );
      }
    });
  }

  void _searchDestination(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDestinations = List.from(allDestinations);
      } else {
        filteredDestinations = allDestinations
            .where((d) => d.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _onTapDestination(DestinationModel d) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));

    String originIata = 'CGK';

    try {
      final pos = await LocationService.getCurrentPosition();
      final airport = LocationService.getNearestAirport(
        pos.latitude,
        pos.longitude,
      );
      originIata = airport.iata;
    } catch (_) {}

    final info = await TravelApiService.fetchDestinationInfo(
        cityName: d.title, originIata: originIata);

    if (!mounted) return;
    Navigator.of(context).pop();

    final updated = d.copyWith(
      apiPhoto: info['photo'] as String?,
      apiDescription: info['description'] as String?,
      apiFlightPrice: (info['flightPrice'] is num)
          ? (info['flightPrice'] as num).toDouble()
          : null,
      apiCurrency: info['flightCurrency'] as String?,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(destination: updated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeContent(),
      const NearbyScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: goTravelColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.near_me), label: 'Nearby'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F0D9),
      appBar: AppBar(
        title: Text("Tripify",
            style: GoogleFonts.pacifico(fontSize: 28, color: goTravelColor)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isLoggedIn ? Icons.logout : Icons.login),
            onPressed: _isLoggedIn
                ? _logout
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: goTravelColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LikedHistoryScreen(likedBox: _likedBox),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: goTravelColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FlightHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Cari artikel kota atau negara...",
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: (query) async {
                final results = await SearchService.fetchResults(query);
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultsPage(
                      query: query,
                      apiResults: results,
                      currencyCode: "USD",
                      timezoneOffset: 0,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FlightSearchScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: goTravelColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flight_takeoff,
                        size: 36,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pesan Tiket Pesawat',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Temukan penerbangan terbaik dengan harga terjangkau',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Popular Destinations",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 15),

            GridView.builder(
              shrinkWrap: true,
              itemCount: filteredDestinations.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.90,
              ),
              itemBuilder: (_, i) {
                final d = filteredDestinations[i];
                final liked = _liked.contains(d.title);
                return _DestinationCardItem(
                  destination: d,
                  isLiked: liked,
                  onTap: () => _onTapDestination(d),
                  onToggleLike: () => _toggleLike(d),
                  exchangeRates: _exchangeRates,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationCardItem extends StatelessWidget {
  final DestinationModel destination;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback onToggleLike;
  final Map<String, double> exchangeRates;

  static const Color goTravelColor = Color(0xFFA5F04F);

  const _DestinationCardItem({
    required this.destination,
    required this.isLiked,
    required this.onTap,
    required this.onToggleLike,
    required this.exchangeRates,
  });

  @override
  Widget build(BuildContext context) {
    final rate = exchangeRates[destination.currencyCode] ?? 1;
    final converted = destination.flightCostIDR * rate;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    destination.apiPhoto ?? destination.thumbnail,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? goTravelColor : Colors.white,
                      ),
                      onPressed: onToggleLike,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "✈️ Rp ${destination.flightCostIDR.toStringAsFixed(0)}",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    "${destination.currencyCode} ${converted.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF5D7B79),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}