import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/auth_service.dart';
import '../services/storage_service.dart';
import 'message_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryColor = Color(0xFF5D7B79);
  static const Color darkColor = Color(0xFF003049);

  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  String? _currentUserEmail;
  String? _avatarUrl;
  String? _currentUserId;
  bool _isLoading = true;
  int _cacheBuster = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    _currentUserId = _authService.getCurrentUserId();
    _currentUserEmail = _authService.getCurrentUserEmail();

    await Future.delayed(const Duration(milliseconds: 300));

    if (_currentUserId != null) {
      final fileName = '$_currentUserId.png';
      _avatarUrl = _storageService.getPublicUrl(fileName);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _goToMessageScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MessageScreen()),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    if (_currentUserId == null) {
      _showSnackBar('You must log in to change your profile photo.');
      return;
    }

    final XFile? pickedFile =
        await _picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      try {
        _showSnackBar('Uploading photo...', Colors.orange);

        final newUrl =
            await _storageService.uploadAvatar(pickedFile.path, _currentUserId!);

        setState(() {
          _cacheBuster++;
          _avatarUrl = '$newUrl?v=$_cacheBuster';
        });

        _showSnackBar('Profile photo updated successfully.', Colors.green);
      } catch (e) {
        _showSnackBar('Failed to upload photo.', Colors.red);
      }
    }
  }

  Future<void> _deleteAvatar() async {
    if (_currentUserId == null || _avatarUrl == null) return;

    try {
      await _storageService.deleteAvatar(_currentUserId!);
      setState(() {
        _avatarUrl = null;
        _cacheBuster = 0;
      });
      _showSnackBar('Profile photo deleted successfully.', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to delete photo.', Colors.red);
    }
  }

  void _showSnackBar(String message, [Color color = primaryColor]) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.poppins()), backgroundColor: color),
    );
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: primaryColor),
                  title: Text('Choose from Gallery',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  onTap: () {
                    _pickAndUploadImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: primaryColor),
                  title: Text('Take Photo',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  onTap: () {
                    _pickAndUploadImage(ImageSource.camera);
                    Navigator.pop(context);
                  },
                ),
                if (_avatarUrl != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Delete Profile Photo',
                      style: GoogleFonts.poppins(
                          color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      _deleteAvatar();
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final poppins = GoogleFonts.poppins();

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFD9F0D9),
      appBar: AppBar(
        title: Text('My Profile',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            )),
        backgroundColor: primaryColor,
        foregroundColor: Color(0xFFA5F04F),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => _showImageOptions(context),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: primaryColor.withOpacity(0.7),
                    backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: _avatarUrl == null || _avatarUrl!.isEmpty
                        ? const Icon(Icons.person,
                            size: 90, color: Colors.white)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2),
                    ),
                    child: const Icon(Icons.edit, color: primaryColor, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              _currentUserEmail ?? 'Tripify User',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: darkColor,
              ),
            ),

            Text(
              'ID: ${_currentUserId ?? 'Not Logged In'}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 25),
            _buildSectionCard(),

            const SizedBox(height: 40),
            Text(
              '© 2025 Tripify Team | Version 1.0',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade600),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          _buildProfileInfoTile(
            icon: Icons.rate_review_outlined,
            title: 'Send Feedback',
            subtitle: 'Share your suggestions to imprfove Tripify.',
            onTap: _goToMessageScreen,
          ),
          _divider(),
          _buildProfileInfoTile(
            icon: Icons.lock_outline,
            title: 'Account Security',
            subtitle: 'Active',
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        indent: 20,
        endIndent: 20,
        height: 10,
        color: Colors.grey.shade300,
      );

  Widget _buildProfileInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: darkColor)),
      subtitle:
          Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey.shade700)),
      trailing: showArrow
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          : null,
    );
  }
}
