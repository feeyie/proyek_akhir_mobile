import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/flight_model.dart';

class FlightHistoryScreen extends StatefulWidget {
  const FlightHistoryScreen({super.key});

  @override
  State<FlightHistoryScreen> createState() => _FlightHistoryScreenState();
}

class _FlightHistoryScreenState extends State<FlightHistoryScreen> {
  static const Color primaryColor = Color(0xFF5D7B79);
  static const Color goTravelColor = Color(0xFFA5F04F);

  late Box _bookingsBox;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      if (!Hive.isBoxOpen('flight_bookings')) {
        _bookingsBox = await Hive.openBox('flight_bookings');
      } else {
        _bookingsBox = Hive.box('flight_bookings');
      }
    } catch (e) {
      _bookingsBox = await Hive.openBox('flight_bookings');
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F0D9),
      appBar: AppBar(
        title: Text(
          'Riwayat Pemesanan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: !Hive.isBoxOpen('flight_bookings')
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: _bookingsBox.listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flight_takeoff_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada pemesanan',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pesan tiket pesawat pertama Anda!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final List<Map<String, dynamic>> bookings = [];
                
                for (var key in box.keys) {
                  try {
                    final bookingData = box.get(key);
                    
                    if (bookingData is Map) {
                      final Map<String, dynamic> convertedBooking = {};
                      
                      bookingData.forEach((k, v) {
                        if (k is String) {
                          convertedBooking[k] = v;
                        }
                      });
                      
                      if (convertedBooking.containsKey('flight')) {
                        final flightData = convertedBooking['flight'];
                        
                        if (flightData is Map) {
                          final Map<String, dynamic> flightMap = {};
                          
                          flightData.forEach((k, v) {
                            if (k is String) {
                              flightMap[k] = v;
                            }
                          });
                          
                          convertedBooking['flight'] = flightMap;
                        }
                      }
                      
                      bookings.add(convertedBooking);
                    }
                  } catch (e) {
                    print('Error processing booking $key: $e');
                  }
                }

                bookings.sort((a, b) {
                  try {
                    final dateA = DateTime.parse(a['bookingDate'] ?? '');
                    final dateB = DateTime.parse(b['bookingDate'] ?? '');
                    return dateB.compareTo(dateA);
                  } catch (e) {
                    return 0;
                  }
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _BookingCard(booking: booking);
                  },
                );
              },
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    try {
      final flightData = booking['flight'];
      
      FlightModel flight;
      if (flightData is Map<String, dynamic>) {
        flight = FlightModel.fromJson(flightData);
      } else if (flightData is Map) {
        final Map<String, dynamic> flightMap = {};
        flightData.forEach((k, v) {
          if (k is String) {
            flightMap[k] = v;
          }
        });
        flight = FlightModel.fromJson(flightMap);
      } else {
        flight = FlightModel(
          id: 'N/A',
          airline: 'Data tidak tersedia',
          flightNumber: 'N/A',
          originCity: 'N/A',
          destinationCity: 'N/A',
          departureTime: DateTime.now(),
          arrivalTime: DateTime.now(),
          duration: 'N/A',
          price: 0.0,
          cabinClass: 'N/A',
          stops: 0,
          origin: 'N/A',
          destination: 'N/A',
        );
      }
      
      final bookingDate = DateTime.parse(booking['bookingDate'] ?? DateTime.now().toIso8601String());
      final totalPrice = (booking['totalPrice'] ?? 0).toDouble();
      final status = booking['status'] as String? ?? 'unknown';
      final passengers = (booking['passengers'] ?? 1).toInt();
      final bookingId = booking['bookingId'] as String? ?? 'Unknown ID';

      Color statusColor;
      String statusText;
      IconData statusIcon;

      switch (status) {
        case 'confirmed':
          statusColor = Colors.green;
          statusText = 'Terkonfirmasi';
          statusIcon = Icons.check_circle;
          break;
        case 'pending':
          statusColor = Colors.orange;
          statusText = 'Menunggu';
          statusIcon = Icons.schedule;
          break;
        case 'cancelled':
          statusColor = Colors.red;
          statusText = 'Dibatalkan';
          statusIcon = Icons.cancel;
          break;
        default:
          statusColor = Colors.grey;
          statusText = 'Unknown';
          statusIcon = Icons.help;
      }

      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookingId,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5D7B79),
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(bookingDate),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D7B79).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.flight,
                      color: Color(0xFF5D7B79),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.airline,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          flight.flightNumber,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      flight.cabinClass,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
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
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          flight.originCity,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          flight.origin,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade500,
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
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 2,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            const Icon(
                              Icons.flight,
                              size: 16,
                              color: Colors.grey,
                            ),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          flight.stops == 0 ? 'Langsung' : '${flight.stops} stop',
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(flight.arrivalTime),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          flight.destinationCity,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          flight.destination,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$passengers Penumpang',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(totalPrice)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5D7B79),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error building booking card: $e');
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          'Error menampilkan data pemesanan: $e',
          style: GoogleFonts.poppins(color: Colors.red.shade700),
        ),
      );
    }
  }
}