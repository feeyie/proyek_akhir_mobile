import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'avatars';

  Future<String> uploadAvatar(String filePath, String userId) async {
    final file = File(filePath);
    final fileName = '$userId.png';

    await _supabase.storage.from(_bucketName).upload(
      fileName,
      file,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: true, 
        contentType: 'image/png',
      ),
    );

    return getPublicUrl(fileName);
  }

  String getPublicUrl(String fileName) {
    return _supabase.storage.from(_bucketName).getPublicUrl(fileName);
  }

  Future<void> deleteAvatar(String userId) async {
    final fileName = '$userId.png';
    await _supabase.storage.from(_bucketName).remove([fileName]);
  }
}
