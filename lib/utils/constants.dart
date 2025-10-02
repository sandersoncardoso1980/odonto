class AppConstants {
  static const String appName = 'Sistema de Agendamentos';

  // Supabase Configuration - SUAS CREDENCIAIS
  static const String supabaseUrl = 'https://yozucrjwshtvuablirag.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvenVjcmp3c2h0dnVhYmxpcmFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxNTA2OTMsImV4cCI6MjA3NDcyNjY5M30.y5VByk_bdglYfukNEccKWZgJpzoeRLJdIiy1ibXJFjs';

  // API Tables
  static const String usuariosTable = 'usuarios';
  static const String agendamentosTable = 'agendamentos';
  static const String servicosTable = 'servicos';

  // SharedPreferences Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isAdminKey = 'is_admin';

  // Timeouts
  static const int apiTimeout = 30;

  // Storage Buckets
  static const String avatarsBucket = 'avatars';
}
