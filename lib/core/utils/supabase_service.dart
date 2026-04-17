import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // Upload image to Supabase Storage
  Future<String> uploadImage(File file, String fileName) async {
    try {
      await _client.storage
          .from(SupabaseConfig.bucketName)
          .upload('products/$fileName', file);

      final publicUrl = _client.storage
          .from(SupabaseConfig.bucketName)
          .getPublicUrl('products/$fileName');

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image from Supabase Storage
  Future<void> deleteImage(String fileName) async {
    try {
      await _client.storage
          .from(SupabaseConfig.bucketName)
          .remove(['products/$fileName']);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
