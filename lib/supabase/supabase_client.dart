import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:odonto/utils/constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseService get instance => _instance;

  // Agora retorna o SupabaseClient do pacote oficial
  SupabaseClient get client => Supabase.instance.client;
}

// Helper para acesso rápido - use este em todo o app
final supabase = Supabase.instance.client;
