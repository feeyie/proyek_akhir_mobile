import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/auth_service.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  static const Color primaryColor = Color(0xFF5D7B79);
  static const Color darkColor = Color(0xFF003049);
  static const Color bgColor = Color(0xFFD9F0D9);

  final AuthService _authService = AuthService();
  final Box userBox = Hive.box('userBox');

  String? _currentUserId;
  bool _isLoading = true;
  Map<dynamic, dynamic>? _loadedFeedback;

  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _loadFeedback() async {
    _currentUserId = _authService.getCurrentUserId();
    await Future.delayed(const Duration(milliseconds: 100));

    if (_currentUserId != null && userBox.isOpen) {
      final loadedData = userBox.get('feedback_data') as Map<dynamic, dynamic>?;
      setState(() {
        _loadedFeedback = loadedData;
      });

      final String loadedText =
          loadedData?['feedback_text'] ?? loadedData?['kesan'] ?? '';
      _feedbackController.text = loadedText;
    } else {
      _feedbackController.text = 'Silakan login untuk mengirim feedback.';
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveFeedback() async {
    if (_currentUserId == null) {
      _showSnackBar('Anda harus login untuk menyimpan data.', Colors.red);
      return;
    }

    final newFeedback = _feedbackController.text.trim();
    final feedbackMap = {
      'feedback_text': newFeedback,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _showSnackBar('Menyimpan feedback...', Colors.orange);

    try {
      await userBox.put('feedback_data', feedbackMap);
      setState(() {
        _loadedFeedback = feedbackMap;
      });
      _showSnackBar('Feedback berhasil disimpan.', Colors.green);
    } catch (e) {
      _showSnackBar('Gagal menyimpan: $e', Colors.red);
    }

    FocusScope.of(context).unfocus();
  }

  void _showSnackBar(String message, [Color color = primaryColor]) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
  }

  Widget _buildFeedbackEditor({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isMultiline,
  }) {
    final bool isEnabled = _currentUserId != null;

    return TextFormField(
      enabled: isEnabled,
      controller: controller,
      maxLines: isMultiline ? 6 : 1,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: primaryColor),
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        suffixIcon: isEnabled
            ? IconButton(
                icon: const Icon(Icons.send, color: darkColor),
                onPressed: _saveFeedback,
              )
            : null,
      ),
    );
  }

  Widget _buildLoadedDataDisplay() {
    final feedback =
        (_loadedFeedback?['feedback_text'] ?? _loadedFeedback?['kesan'] ?? '')
            as String;

    final timestampStr = _loadedFeedback?['timestamp'];
    if (feedback.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(
          child: Text('There is no feedback yet.',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    String formattedTime = 'Tidak diketahui';
    if (timestampStr != null) {
      try {
        final dateTime = DateTime.parse(timestampStr).toLocal();
        formattedTime = DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
      } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Text(
          'Last Saved Feedback',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.feedback_outlined,
                        color: primaryColor, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Your Feedback:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  feedback,
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: darkColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Saved on: $formattedTime',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(title: const Text('Send Us Feedback')),
        body: const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Send Feedback', style: GoogleFonts.poppins()),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send us your feedback to help us improve our app experience!',
                style:
                    GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              _buildFeedbackEditor(
                controller: _feedbackController,
                label: 'Your Feedback',
                icon: Icons.chat_bubble_outline,
                isMultiline: true,
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _currentUserId != null ? _saveFeedback : null,
                  icon: const Icon(Icons.save),
                  label: Text('Save Feedback',
                      style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              _buildLoadedDataDisplay(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
