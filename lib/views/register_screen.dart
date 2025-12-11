import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/auth_service.dart';
import 'login_screen.dart';

const Color backgroundColor = Color(0xFFD9F0D9);
const Color buttonPrimaryColor = Color(0xFF5D7B79);
const Color goTravelColor = Color(0xFFA5F04F);
const Color textColor = Color(0xFF333333);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void register() async {
    if (!mounted) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _passwordConfirmationController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password dan konfirmasi tidak cocok.", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Mendaftarkan akun...", style: TextStyle(color: Colors.white)),
        backgroundColor: buttonPrimaryColor,
      ),
    );

    try {
      await authService.signUpWithEmailPassword(email, password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil. Periksa email untuk verifikasi.', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF388E3C),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final errorMessage = e.toString().contains('already exists')
          ? 'Email sudah terdaftar.'
          : 'Terjadi kesalahan. Coba lagi.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Daftar',
          style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Buat Akun',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Gabung dengan Tripify dan mulai petualanganmu ke luar negeri.',
              style: GoogleFonts.inter(fontSize: 14, color: textColor.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            Text('Email', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'example@gmail.com',
                prefixIcon: const Icon(Icons.email_outlined, color: buttonPrimaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            Text('Password', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Minimal 6 karakter',
                prefixIcon: const Icon(Icons.lock_outline, color: buttonPrimaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            Text('Konfirmasi Password', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordConfirmationController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Masukkan ulang password',
                prefixIcon: const Icon(Icons.lock_reset, color: buttonPrimaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goTravelColor,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: Text(
                  "Daftar Akun",
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sudah punya akun?",
                  style: GoogleFonts.inter(color: textColor.withOpacity(0.7)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Login di sini",
                    style: GoogleFonts.inter(
                      color: buttonPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
