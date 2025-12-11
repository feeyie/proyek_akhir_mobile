import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/flight_model.dart';

class FlightBookingScreen extends StatefulWidget {
  final FlightModel flight;
  final int passengers;

  const FlightBookingScreen({
    super.key,
    required this.flight,
    required this.passengers,
  });

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  static const Color primaryColor = Color(0xFF5D7B79);
  static const Color goTravelColor = Color(0xFFA5F04F);

  final _formKey = GlobalKey<FormState>();
  List<Map<String, TextEditingController>> passengerControllers = [];
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.passengers; i++) {
      passengerControllers.add({
        'title': TextEditingController(text: 'Mr'),
        'firstName': TextEditingController(),
        'lastName': TextEditingController(),
        'nationality': TextEditingController(text: 'Indonesia'),
        'passport': TextEditingController(),
      });
    }
  }

  @override
  void dispose() {
    for (var controllers in passengerControllers) {
      controllers.values.forEach((controller) => controller.dispose());
    }
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _processBooking() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mohon lengkapi semua data',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Memproses pesanan...',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    final bookingId = 'BK${DateTime.now().millisecondsSinceEpoch}';
    final bookingsBox = Hive.box('flight_bookings');
    
    await bookingsBox.put(bookingId, {
      'bookingId': bookingId,
      'flight': widget.flight.toJson(),
      'passengers': widget.passengers,
      'totalPrice': widget.flight.price * widget.passengers,
      'bookingDate': DateTime.now().toIso8601String(),
      'status': 'confirmed',
      'email': _emailController.text,
      'phone': _phoneController.text,
    });

    if (!mounted) return;
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pemesanan Berhasil!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kode Booking: $bookingId',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Detail pemesanan telah dikirim ke email Anda',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: goTravelColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Kembali ke Beranda',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.flight.price * widget.passengers;

    return Scaffold(
      backgroundColor: const Color(0xFFD9F0D9),
      appBar: AppBar(
        title: Text(
          'Detail Pemesanan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFlightSummary(),

                    const SizedBox(height: 24),

                    _buildSectionTitle('Informasi Kontak'),
                    const SizedBox(height: 12),
                    _buildContactForm(),

                    const SizedBox(height: 24),

                    _buildSectionTitle('Data Penumpang'),
                    const SizedBox(height: 12),

                    ...List.generate(widget.passengers, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPassengerForm(index),
                      );
                    }),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Pembayaran',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'Rp ${NumberFormat('#,###', 'id_ID').format(totalPrice)}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _processBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goTravelColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Bayar Sekarang',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
    );
  }

  Widget _buildFlightSummary() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.flight.airline,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
                    widget.flight.cabinClass,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              widget.flight.flightNumber,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(widget.flight.departureTime),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.flight.originCity,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      widget.flight.duration,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(widget.flight.arrivalTime),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.flight.destinationCity,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: GoogleFonts.poppins(),
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!value.contains('@')) {
                  return 'Email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
                labelStyle: GoogleFonts.poppins(),
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor telepon wajib diisi';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerForm(int index) {
    final controllers = passengerControllers[index];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penumpang ${index + 1}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: controllers['title']!.text,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: ['Mr', 'Mrs', 'Ms'].map((title) {
                return DropdownMenuItem(
                  value: title,
                  child: Text(title, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controllers['title']!.text = value;
                }
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: controllers['firstName'],
              decoration: InputDecoration(
                labelText: 'Nama Depan',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama depan wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: controllers['lastName'],
              decoration: InputDecoration(
                labelText: 'Nama Belakang',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama belakang wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: controllers['nationality'],
              decoration: InputDecoration(
                labelText: 'Kewarganegaraan',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kewarganegaraan wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: controllers['passport'],
              decoration: InputDecoration(
                labelText: 'Nomor Paspor',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor paspor wajib diisi';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}