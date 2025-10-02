import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoggedIn = false;
  String? _userEmail;
  bool _isAdmin = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  bool get isAdmin => _isAdmin;

  AuthService() {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _isLoggedIn = true;
      _userEmail = user.email;
      _isAdmin = user.email?.toLowerCase() == 'san@gmail.com';
      notifyListeners();
    }
  }

  Future<AuthResponse?> signUp({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: senha,
        data: {'nome': nome.trim(), 'telefone': telefone.trim()},
      );

      final user = response.user;

      if (user == null) {
        throw Exception('Não foi possível criar o usuário.');
      }

      await _supabase.from('usuarios').insert({
        'id': user.id,
        'email': email.trim(),
        'nome': nome.trim(),
        'telefone': telefone.trim(),
        'is_admin': false,
      });

      _isLoggedIn = true;
      _userEmail = email.trim();
      _isAdmin = false;
      notifyListeners();

      return response;
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    } catch (e) {
      throw Exception('Erro inesperado ao cadastrar: $e');
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: senha,
      );

      _isLoggedIn = true;
      _userEmail = email.trim();
      _isAdmin = email.toLowerCase() == 'san@gmail.com';
      notifyListeners();

      return response;
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();

      _isLoggedIn = false;
      _userEmail = null;
      _isAdmin = false;
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao sair: $e');
    }
  }

  User? get currentUser => _supabase.auth.currentUser;

  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Email ou senha incorretos.';
    } else if (lower.contains('email not confirmed')) {
      return 'Email ainda não confirmado.';
    } else if (lower.contains('already registered')) {
      return 'Este email já está cadastrado.';
    } else if (lower.contains('password')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    } else if (lower.contains('network')) {
      return 'Falha na conexão. Verifique sua internet.';
    }
    return message;
  }
}
