import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/flight_model.dart';
import 'flight_booking_screen.dart';

class FlightResultsScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final DateTime departDate;
  final DateTime? returnDate;
  final int passengers;
  final String cabinClass;

  const FlightResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.departDate,
    this.returnDate,
    required this.passengers,
    required this.cabinClass,
  });

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  static const Color primaryColor = Color(0xFF5D7B79);
  static const Color goTravelColor = Color(0xFFA5F04F);
  static const Color bgColor = Color(0xFFD9F0D9);

  List<FlightModel> _flights = [];
  bool _isLoading = true;
  bool _sortByPrice = true;
  bool _showDirectOnly = false;
  double _maxPrice = 5000000;

  @override
  void initState() {
    super.initState();
    _generateDummyFlights();
  }

  void _generateDummyFlights() {
    setState(() => _isLoading = true);

    String extractCity(String input) {
      try {
        if (input.contains('(') && input.contains(')')) {
          return input.split('(').first.trim();
        }
        return input.trim();
      } catch (e) {
        return input.trim();
      }
    }

    String extractCode(String input) {
      try {
        if (input.contains('(') && input.contains(')')) {
          final parts = input.split('(');
          if (parts.isNotEmpty && parts.length > 1) {
            final codePart = parts.last;
            if (codePart.contains(')')) {
              return codePart.replaceAll(')', '').trim();
            }
            return codePart.trim();
          }
        }

        final lowerInput = input.toLowerCase();
        if (lowerInput.contains('jakarta')) return 'CGK';
        if (lowerInput.contains('bali') || lowerInput.contains('denpasar')) return 'DPS';
        if (lowerInput.contains('surabaya')) return 'SUB';
        if (lowerInput.contains('medan')) return 'KNO';
        if (lowerInput.contains('makassar')) return 'UPG';
        if (lowerInput.contains('singapore')) return 'SIN';
        if (lowerInput.contains('bangkok')) return 'BKK';
        if (lowerInput.contains('kuala') || lowerInput.contains('lumpur')) return 'KUL';
        if (lowerInput.contains('tokyo')) return 'NRT';
        if (lowerInput.contains('seoul')) return 'ICN';
        if (lowerInput.contains('sydney')) return 'SYD';
        if (lowerInput.contains('london')) return 'LHR';
        if (lowerInput.contains('paris')) return 'CDG';
        if (lowerInput.contains('dubai')) return 'DXB';
        if (lowerInput.contains('new york')) return 'JFK';
        return 'XXX';
      } catch (e) {
        return 'XXX';
      }
    }

    final originCity = extractCity(widget.origin);
    final originCode = extractCode(widget.origin);
    final destinationCity = extractCity(widget.destination);
    final destinationCode = extractCode(widget.destination);

    final airlines = [
      {'name': 'Garuda Indonesia', 'code': 'GA', 'premium': true},
      {'name': 'Lion Air', 'code': 'JT', 'premium': false},
      {'name': 'AirAsia', 'code': 'QZ', 'premium': false},
      {'name': 'Singapore Airlines', 'code': 'SQ', 'premium': true},
      {'name': 'Citilink', 'code': 'QG', 'premium': false},
      {'name': 'Batik Air', 'code': 'ID', 'premium': true},
      {'name': 'Emirates', 'code': 'EK', 'premium': true},
      {'name': 'Qatar Airways', 'code': 'QR', 'premium': true},
      {'name': 'Sriwijaya Air', 'code': 'SJ', 'premium': false},
      {'name': 'Thai Airways', 'code': 'TG', 'premium': true},
    ];

    final List<FlightModel> flights = [];

    final randomCount = 12 + (DateTime.now().microsecondsSinceEpoch % 4);
    for (int i = 0; i < randomCount; i++) {
      final airlineIndex = i % airlines.length;
      final airline = airlines[airlineIndex];
      
      final hourOffset = 6 + (i * 2) % 16;
      final minuteOffset = (i * 15) % 60;
      
      final departTime = DateTime(
        widget.departDate.year,
        widget.departDate.month,
        widget.departDate.day,
        hourOffset,
        minuteOffset,
      );
      
      final isLongHaul = destinationCode.length == 3 && 
          !['CGK', 'SUB', 'DPS', 'BKK', 'SIN', 'KUL'].contains(destinationCode);
      
      final flightHours = isLongHaul 
          ? 4 + (i % 5) 
          : 1 + (i % 3); 
      
      final flightMinutes = (i * 7) % 60;
      final arrivalTime = departTime.add(Duration(
        hours: flightHours,
        minutes: flightMinutes,
      ));
      
      final durationHours = flightHours;
      final durationMinutes = flightMinutes;
      final duration = '${durationHours}j ${durationMinutes.toString().padLeft(2, '0')}m';
      
      final stops = (i % 10) < 7 ? 0 : (i % 3) + 1;
      
      double basePrice;
      if (airline['premium'] as bool) {
        basePrice = isLongHaul ? 3500000 : 1500000;
      } else {
        basePrice = isLongHaul ? 2500000 : 800000;
      }

      double classMultiplier;
      switch (widget.cabinClass) {
        case 'Economy':
          classMultiplier = 1.0;
          break;
        case 'Premium':
          classMultiplier = 1.5;
          break;
        case 'Business':
          classMultiplier = 2.5;
          break;
        case 'First':
          classMultiplier = 4.0;
          break;
        default:
          classMultiplier = 1.0;
      }

      final priceVariation = 0.8 + (i % 5) * 0.1;
      final finalPrice = (basePrice * classMultiplier * priceVariation);

      final id = 'FL${DateTime.now().millisecondsSinceEpoch}$i';
      
      final flightNumber = '${airline['code'] as String} ${100 + i}';
      
      flights.add(FlightModel(
        id: id,
        airline: airline['name'] as String,
        flightNumber: flightNumber,
        originCity: originCity,
        destinationCity: destinationCity,
        departureTime: departTime,
        arrivalTime: arrivalTime,
        duration: duration,
        price: finalPrice,
        cabinClass: widget.cabinClass,
        stops: stops,
        origin: widget.origin,
        destination: widget.destination,
      ));
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _flights = flights;
          _isLoading = false;
        });
      }
    });
  }

  void _onSelectFlight(FlightModel flight) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlightBookingScreen(
          flight: flight,
          passengers: widget.passengers,
        ),
      ),
    );
  }

  void _sortFlights() {
    setState(() {
      _sortByPrice = !_sortByPrice;
      if (_sortByPrice) {
        _flights.sort((a, b) => a.price.compareTo(b.price));
      } else {
        _flights.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      }
    });
  }

  void _toggleDirectOnly() {
    setState(() {
      _showDirectOnly = !_showDirectOnly;
    });
  }


  List<FlightModel> get _filteredFlights {
    var filtered = _flights;
    
    if (_showDirectOnly) {
      filtered = filtered.where((f) => f.stops == 0).toList();
    }
    
    filtered = filtered.where((f) => f.price <= _maxPrice).toList();
    
    if (_sortByPrice) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else {
      filtered.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }
    
    return filtered;
  }

  String _getCityOnly(String input) {
    try {
      if (input.contains('(')) {
        final parts = input.split('(');
        if (parts.isNotEmpty) {
          return parts.first.trim();
        }
      }
      return input;
    } catch (e) {
      return input;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Hasil Pencarian',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateDummyFlights,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getCityOnly(widget.origin)} → ${_getCityOnly(widget.destination)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEE, dd MMM yyyy').format(widget.departDate),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.passengers} Penumpang',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          widget.cabinClass,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredFlights.length} penerbangan ditemukan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.airplane_ticket,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Data Simulasi',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sortFlights,
                    icon: Icon(
                      _sortByPrice ? Icons.attach_money : Icons.access_time,
                      size: 18,
                    ),
                    label: Text(
                      _sortByPrice ? 'Harga Terendah' : 'Waktu Keberangkatan',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[50],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _toggleDirectOnly,
                  icon: Icon(
                    _showDirectOnly ? Icons.check_circle : Icons.flight,
                    size: 18,
                  ),
                  label: Text(
                    'Langsung',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showDirectOnly ? primaryColor.withOpacity(0.1) : Colors.grey[50],
                    foregroundColor: _showDirectOnly ? primaryColor : Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _showDirectOnly ? primaryColor : Colors.grey[300]!,
                      ),
                    ),
                  ),
                ),    
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? _buildLoading()
                : _filteredFlights.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: () async {
                          _generateDummyFlights();
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredFlights.length,
                          itemBuilder: (context, index) {
                            final flight = _filteredFlights[index];
                            return _buildFlightCard(flight);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Mencari penerbangan terbaik...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data simulasi sedang di-generate',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada penerbangan yang sesuai',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba ubah filter atau tanggal',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showDirectOnly = false;
                  _maxPrice = 5000000;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Reset Filter',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightCard(FlightModel flight) {
    final isPremiumAirline = flight.airline.contains('Garuda') ||
        flight.airline.contains('Singapore') ||
        flight.airline.contains('Emirates') ||
        flight.airline.contains('Qatar');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _onSelectFlight(flight),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isPremiumAirline 
                              ? Colors.blue[50] 
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.airplanemode_active,
                          size: 20,
                          color: isPremiumAirline 
                              ? Colors.blue[700] 
                              : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.airline,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            flight.flightNumber,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(flight.price)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        'per orang',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(flight.departureTime),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          flight.originCity,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM').format(flight.departureTime),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          flight.duration,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[400],
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                flight.stops == 0
                                    ? Icons.flight
                                    : Icons.flight_land,
                                size: 16,
                                color: primaryColor,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[400],
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: flight.stops == 0
                                ? Colors.green[50]
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            flight.stops == 0
                                ? 'Langsung'
                                : '${flight.stops} transit',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: flight.stops == 0
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(flight.arrivalTime),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          flight.destinationCity,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM').format(flight.arrivalTime),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildAmenityChip(
                          icon: Icons.luggage,
                          text: '20kg',
                        ),
                        _buildAmenityChip(
                          icon: Icons.restaurant,
                          text: 'Makanan',
                        ),
                        if (isPremiumAirline)
                          _buildAmenityChip(
                            icon: Icons.wifi,
                            text: 'WiFi',
                          ),
                        if (flight.cabinClass == 'Business' || flight.cabinClass == 'First')
                          _buildAmenityChip(
                            icon: Icons.event_seat,
                            text: 'Seat Premium',
                          ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () => _onSelectFlight(flight),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goTravelColor,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pilih',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}