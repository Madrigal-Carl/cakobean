import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase project credentials for the app, loaded from `.env` (see
/// `.env.example`). The `anon`/publishable key is safe to ship — security is
/// enforced by Row Level Security in `supabase/schema.sql`, not by the key.
String get supabaseUrl => dotenv.get('SUPABASE_URL');

String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY');
