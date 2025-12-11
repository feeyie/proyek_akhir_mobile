import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'flight_results_screen.dart';

class FlightSearchScreen extends StatefulWidget {
  final String? preFilledDestination;
  
  const FlightSearchScreen({super.key, this.preFilledDestination});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  static const Color primaryColor = Color(0xFF5D7B79);
  static const Color goTravelColor = Color(0xFFA5F04F);
  static const Color bgColor = Color(0xFFD9F0D9);

  String _tripType = 'roundtrip';
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  DateTime? _departDate;
  DateTime? _returnDate;
  int _passengers = 1;
  String _classType = 'Economy';

  final List<String> _popularRoutes = [
    'Jakarta (CGK) → Paris (CDG)',
    'Jakarta (CGK) → Tokyo (HND)',
    'Jakarta (CGK) → Bangkok (BKK)',
    'Jakarta (CGK) → Dubai (DXB)',
    'Jakarta (CGK) → London (LHR)',
    'Jakarta (CGK) → Sydney (SYD)',
    'Jakarta (CGK) → New York (JFK)',
    'Jakarta (CGK) → Rome (FCO)',
    'Jakarta (CGK) → Istanbul (IST)',
    'Jakarta (CGK) → Seoul (ICN)',
  ];

  @override
  void initState() {
    super.initState();
    _fromController.text = 'Jakarta (CGK)';
    _departDate = DateTime.now().add(const Duration(days: 1));
    
    if (widget.preFilledDestination != null) {
      _toController.text = widget.preFilledDestination!;
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeparture 
          ? (_departDate ?? DateTime.now().add(const Duration(days: 1)))
          : (_returnDate ?? _departDate?.add(const Duration(days: 3)) ?? 
             DateTime.now().add(const Duration(days: 4))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departDate = picked;
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = null;
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  void _searchFlights() {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mohon isi lokasi keberangkatan dan tujuan',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_departDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mohon pilih tanggal keberangkatan',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_tripType == 'roundtrip' && _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mohon pilih tanggal kepulangan',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlightResultsScreen(
          origin: _fromController.text,
          destination: _toController.text,
          departDate: _departDate!,
          returnDate: _returnDate,
          passengers: _passengers,
          cabinClass: _classType,
        ),
      ),
    );
  }

  void _onPopularRouteTap(String route) {
    try {
      final parts = route.split(' → ');
      if (parts.length == 2) {
        setState(() {
          _fromController.text = parts[0];
          _toController.text = parts[1];
          _departDate = DateTime.now().add(const Duration(days: 1));
          _returnDate = _tripType == 'roundtrip' 
              ? DateTime.now().add(const Duration(days: 4))
              : null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rute telah diisi',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: primaryColor,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Cari Penerbangan',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                children: [
                  Icon(
                    Icons.flight_takeoff,
                    size: 60,
                    color: goTravelColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Temukan Penerbangan Terbaik',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Bandingkan harga dari berbagai maskapai',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTripTypeButton('roundtrip', 'Pulang Pergi'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTripTypeButton('oneway', 'Sekali Jalan'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildLocationField(
                        controller: _fromController,
                        label: 'Dari',
                        hint: 'Jakarta (CGK)',
                        icon: Icons.flight_takeoff,
                      ),

                      const SizedBox(height: 16),
                      Center(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              final temp = _fromController.text;
                              _fromController.text = _toController.text;
                              _toController.text = temp;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: goTravelColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.swap_vert,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildLocationField(
                        controller: _toController,
                        label: 'Ke',
                        hint: 'Contoh: Paris (CDG)',
                        icon: Icons.flight_land,
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: 'Berangkat',
                              date: _departDate,
                              onTap: () => _selectDate(context, true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (_tripType == 'roundtrip')
                            Expanded(
                              child: _buildDateField(
                                label: 'Pulang',
                                date: _returnDate,
                                onTap: () => _selectDate(context, false),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _buildPassengerField()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildClassField()),
                        ],
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _searchFlights,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search),
                              const SizedBox(width: 8),
                              Text(
                                'Cari Penerbangan',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rute Populer',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._popularRoutes.map((route) => _buildPopularRouteItem(route)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeButton(String value, String label) {
    final isSelected = _tripType == value;
    return InkWell(
      onTap: () => setState(() => _tripType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: primaryColor),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('dd MMM yyyy').format(date)
                        : 'Pilih tanggal',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: date != null ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Penumpang',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _passengers,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: primaryColor),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              items: List.generate(9, (i) => i + 1).map((num) {
                return DropdownMenuItem(value: num, child: Text('$num Orang'));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _passengers = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kelas',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _classType,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: primaryColor),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              items: ['Economy', 'Premium', 'Business', 'First']
                  .map((cls) => DropdownMenuItem(value: cls, child: Text(cls)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _classType = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularRouteItem(String route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: goTravelColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.flight, color: primaryColor),
        ),
        title: Text(
          route,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _onPopularRouteTap(route),
      ),
    );
  }
}