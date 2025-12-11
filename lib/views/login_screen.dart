import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';
import 'home_screen.dart'; 
import 'register_screen.dart'; 
import 'package:google_fonts/google_fonts.dart';

const Color backgroundColor = Color(0xFFD9F0D9);
const Color buttonPrimaryColor = Color(0xFF5D7B79);
const Color goTravelColor = Color(0xFFA5F04F);
const Color textColor = Color(0xFF333333);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = LoginController();
    controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerUpdate);
    controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted) return;
   
    if (controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage!,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      controller.clearErrorMessage();
    }
    
    setState(() {});
  }

  void _handleLogin() async {
    if (controller.isLoading) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Logging in...",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: buttonPrimaryColor,
        duration: const Duration(seconds: 2),
      ),
    );

    final success = await controller.login();
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, 
      appBar: AppBar(
        title: Text(
          'Login', 
          style: GoogleFonts.inter(
            color: textColor, 
            fontWeight: FontWeight.bold,
          ),
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
              'Selamat datang di Tripify!',
              style: GoogleFonts.inter(
                fontSize: 28, 
                fontWeight: FontWeight.w800, 
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Masukkan email dan password kamu untuk melanjutkan ke Tripify.',
              style: GoogleFonts.inter(
                fontSize: 14, 
                color: textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            Text(
              'Email', 
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, 
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.emailController,
              enabled: !controller.isLoading,
              decoration: InputDecoration(
                labelText: 'example@contoh.com',
                prefixIcon: const Icon(
                  Icons.email_outlined, 
                  color: buttonPrimaryColor,
                ),
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

            Text(
              'Password', 
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, 
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.passwordController,
              enabled: !controller.isLoading,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Masukkan password Anda',
                prefixIcon: const Icon(
                  Icons.lock_outline, 
                  color: buttonPrimaryColor,
                ),
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
                onPressed: controller.isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  disabledBackgroundColor: buttonPrimaryColor.withOpacity(0.6),
                ),
                child: controller.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Login",
                        style: GoogleFonts.inter(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Belum punya akun?",
                  style: GoogleFonts.inter(
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                TextButton(
                  onPressed: controller.isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                  child: Text(
                    "Daftar di sini",
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