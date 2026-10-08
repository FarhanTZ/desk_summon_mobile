import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> init() async {
    final url = dotenv.env['SUPABASE_URL'] ?? 'https://yfoigkrmqwtbrkkptgad.supabase.co';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'sb_publishable_vk6p3LJQkahLPkz4SeUaGQ_ezfXeQZc';

    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
