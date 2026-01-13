import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get user profile data
  Map<String, dynamic> getUserProfile() {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    return {
      'id': user.id,
      'email': user.email ?? '',
      'full_name':
          user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '',
      'avatar_url':
          user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
      'provider': user.appMetadata['provider'] ?? 'email',
      'created_at': user.createdAt,
    };
  }

  Future<void> updateProfile({required String fullName}) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': fullName}),
      );

      if (response.user == null) {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload profile picture to Supabase Storage
  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      final bytes = await imageFile.readAsBytes();

      // Upload to Supabase Storage
      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

      await _supabase.auth.updateUser(
        UserAttributes(data: {'avatar_url': imageUrl}),
      );

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  Future<void> deleteOldProfilePicture(String oldUrl) async {
    try {
      final user = currentUser;
      if (user == null) return;

      final uri = Uri.parse(oldUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 2) {
        final fileName = pathSegments
            .sublist(pathSegments.length - 2)
            .join('/');

        await _supabase.storage.from('avatars').remove([fileName]);
      }
    } catch (e) {
      debugPrint('Failed to delete old profile picture: $e');
    }
  }
}
