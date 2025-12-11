import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import 'package:tripify/controllers/destination_detail_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class DestinationDetailScreen extends StatefulWidget {
  final DestinationModel destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  late DestinationDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = DestinationDetailController(widget.destination);
    controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerUpdate);
    controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F4),
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 320,
                width: double.infinity,
                child: Image.network(
                  controller.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),

              Container(
                height: 320,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 20,
                left: 20,
                child: Text(
                  controller.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.description,
                    style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 25),
                  _glassCard(
                    title: "Currency Conversion",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDropdown(
                          value: controller.selectedCurrency,
                          items: controller.currencyList,
                          onChanged: (v) => controller.updateCurrency(v!),
                          icon: Icons.monetization_on,
                        ),

                        const SizedBox(height: 12),
                        Text("Estimated Flight Price", style: _subTitle),
                        const SizedBox(height: 4),

                        Text(
                          controller.getConvertedPrice(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: const Color(0xFF5D7B79),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text("Estimated Price (IDR)", style: _subTitle),
                        const SizedBox(height: 4),

                        Text(
                          controller.getPriceInIDR(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _glassCard(
                    title: "Time Zone Conversion",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDropdown(
                          value: controller.selectedTimeZone,
                          items: controller.timeZoneList,
                          onChanged: (v) => controller.updateTimeZone(v!),
                          icon: Icons.access_time,
                        ),
                        const SizedBox(height: 12),

                        Text("Local Time in ${controller.title}", style: _subTitle),
                        Text(
                          controller.getFormattedLocalTime(),
                          style: _timeStyle,
                        ),

                        const SizedBox(height: 12),
                        Text("Time in ${controller.selectedTimeZone}", style: _subTitle),
                        Text(
                          controller.getFormattedConvertedTime(),
                          style: _timeStyle.copyWith(color: const Color(0xFF5D7B79)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }


  Widget _glassCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: const Color(0xFF4A6060),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: const Color(0xFF5D7B79)),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: GoogleFonts.poppins(fontSize: 15)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  TextStyle get _subTitle => GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.black54,
        fontWeight: FontWeight.w600,
      );

  TextStyle get _timeStyle => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
}