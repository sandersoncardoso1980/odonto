import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select('nome, email, telefone, created_at')
          .eq('id', uid) // CORRIGIDO: de 'uid' para 'id'
          .single();

      return response;
    } catch (e) {
      debugPrint('Erro ao buscar dados do usuário: $e');
      return null;
    }
  }

  Future<String?> getUserName(String uid) async {
    final userData = await getUserData(uid);
    return userData?['nome'];
  }
}
