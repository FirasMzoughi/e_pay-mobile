import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUtils {
  static const String url = 'https://aqbadacramqrrqirtmxa.supabase.co';
  static const String anonKey = 'sb_publishable_iiyNjHMObUREXgRK4TAoyg_XH2QLeIL'; // User needs to replace this

  static Future<void> init() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
