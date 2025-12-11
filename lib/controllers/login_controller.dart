import 'package:flutter/material.dart';
import '../auth/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<bool> login() async {
    if (!_validateInputs()) {
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    final email = emailController.text.trim();
    final password = passwordController.text;
    
    try {
      await _authService.signInWithEmailPassword(email, password);
      _setLoading(false);
      return true; 
    } catch (e) {
      _setLoading(false);
      _handleError(e);
      return false; 
    }
  }

  bool _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    
    if (email.isEmpty) {
      _setError("Email tidak boleh kosong");
      return false;
    }
    
    if (!_isValidEmail(email)) {
      _setError("Format email tidak valid");
      return false;
    }
    
    if (password.isEmpty) {
      _setError("Password tidak boleh kosong");
      return false;
    }
    
    if (password.length < 6) {
      _setError("Password minimal 6 karakter");
      return false;
    }
    
    return true;
  }
  
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _handleError(dynamic error) {
    final errorString = error.toString();
    
    if (errorString.contains('Invalid login credentials')) {
      _setError("Email atau password salah");
    } else if (errorString.contains('Email not confirmed')) {
      _setError("Email belum diverifikasi. Cek inbox Anda");
    } else if (errorString.contains('Network')) {
      _setError("Tidak ada koneksi internet");
    } else {
      _setError("Login gagal. Silakan coba lagi");
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearErrorMessage() {
    _clearError();
  }
  
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}