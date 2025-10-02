import 'package:flutter/material.dart';
import 'package:odonto/screens/landing_page/agendamento.dart';
import 'package:odonto/services/servico.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgendamentoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Método para buscar todos os serviços disponíveis
  Future<List<Servico>> getServicos() async {
    try {
      final response = await _supabase.from('servicos').select('*');
      return response.map((json) => Servico.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar serviços: $e');
      throw Exception('Erro ao carregar serviços');
    }
  }

  // Método para buscar um serviço pelo nome
  // Método para buscar um serviço pelo nome
  Future<Servico?> getServicoByName(String nomeServico) async {
    try {
      if (nomeServico.isEmpty) {
        return null;
      }

      final response = await _supabase
          .from('servicos')
          .select('*')
          .eq('nome', nomeServico)
          .single();

      // Verificar se a resposta é válida
      if (response != null &&
          response['id'] != null &&
          response['nome'] != null &&
          response['duracao_minutos'] != null) {
        return Servico.fromJson(response);
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao buscar serviço por nome: $e');
      return null;
    }
  }

  // Método para buscar horários disponíveis para uma data e serviço específicos
  // Método para buscar horários disponíveis para uma data e serviço específicos
  // Método para buscar horários disponíveis para uma data e serviço específicos
  Future<List<TimeOfDay>> getHorariosDisponiveis(
    DateTime data,
    String nomeServico,
  ) async {
    try {
      final Servico? servico = await getServicoByName(nomeServico);
      if (servico == null) {
        throw Exception('Serviço não encontrado.');
      }

      // 1. GERAR TODOS OS HORÁRIOS POSSÍVEIS
      final List<TimeOfDay> todosHorarios = [];
      for (int hour = 8; hour <= 17; hour++) {
        for (int minute = 0; minute < 60; minute += 30) {
          todosHorarios.add(TimeOfDay(hour: hour, minute: minute));
        }
      }

      // 2. BUSCAR AGENDAMENTOS EXISTENTES para esta data e serviço
      final startOfDay = DateTime(data.year, data.month, data.day, 0, 0, 0);
      final endOfDay = DateTime(data.year, data.month, data.day, 23, 59, 59);

      final response = await _supabase
          .from('agendamentos')
          .select('data')
          .eq('servico', nomeServico) // FILTRAR POR SERVIÇO
          .gte('data', startOfDay.toIso8601String())
          .lte('data', endOfDay.toIso8601String())
          .neq('status', 'cancelado');

      // 3. EXTRAIR OS HORÁRIOS OCUPADOS
      final Set<TimeOfDay> horariosOcupados = {};

      for (var agendamento in response) {
        final DateTime dataHora = DateTime.parse(agendamento['data']);
        final TimeOfDay horarioOcupado = TimeOfDay(
          hour: dataHora.hour,
          minute: dataHora.minute,
        );
        horariosOcupados.add(horarioOcupado);
      }

      // 4. FILTRAR HORÁRIOS DISPONÍVEIS (remover os ocupados)
      final List<TimeOfDay> horariosDisponiveis = todosHorarios
          .where((horario) => !horariosOcupados.contains(horario))
          .toList();

      print('📅 Horários para $data - $nomeServico:');
      print('   🕒 Disponíveis: ${horariosDisponiveis.length}');
      print('   ❌ Ocupados: ${horariosOcupados.length}');

      return horariosDisponiveis;
    } catch (e) {
      print('Erro ao buscar horários disponíveis: $e');
      throw Exception('Erro ao carregar horários disponíveis');
    }
  }

  // Método para criar um agendamento
  // Método para criar um agendamento
  Future<Agendamento> criarAgendamento({
    required String nome,
    required String email,
    required String telefone,
    required DateTime data,
    required TimeOfDay hora,
    required String nomeServico,
    String? observacoes,
  }) async {
    try {
      final user = _supabase.auth.currentUser;

      final Servico? servico = await getServicoByName(nomeServico);
      if (servico == null) {
        throw Exception('Serviço não encontrado.');
      }

      final DateTime dataHoraAgendamento = DateTime(
        data.year,
        data.month,
        data.day,
        hora.hour,
        hora.minute,
      );

      // VALIDAÇÃO SIMPLES: Verificar se já existe agendamento no MESMO horário e serviço
      final agendamentosConflitantes = await _supabase
          .from('agendamentos')
          .select('id')
          .eq('data', dataHoraAgendamento.toIso8601String())
          .eq('servico', nomeServico)
          .neq('status', 'cancelado');

      if (agendamentosConflitantes.isNotEmpty) {
        throw Exception(
          'Este horário já está reservado para este serviço. Por favor, escolha outro horário.',
        );
      }

      // Criar o agendamento
      final Map<String, dynamic> agendamentoData = {
        'nome': nome.trim(),
        'email': email.trim(),
        'telefone': telefone.trim(),
        'data': dataHoraAgendamento.toIso8601String(),
        'servico': nomeServico,
        'observacoes': observacoes?.trim(),
        'user_id': user?.id,
        'status': 'pendente',
      };

      final response = await _supabase
          .from('agendamentos')
          .insert(agendamentoData)
          .select()
          .single();

      return Agendamento.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception(
          'Este horário já está reservado. Por favor, escolha outro horário.',
        );
      }
      print('Erro no agendamento (PostgrestException): $e');
      rethrow;
    } catch (e) {
      print('Erro no agendamento: $e');
      rethrow;
    }
  }

  // Método para buscar agendamentos do usuário logado
  Future<List<Agendamento>> getMeusAgendamentos() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('agendamentos')
          .select('*')
          .eq('user_id', user.id)
          .order('data', ascending: false);

      return response.map((json) => Agendamento.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar meus agendamentos: $e');
      throw Exception('Erro ao carregar agendamentos');
    }
  }

  // Método para cancelar agendamento
  Future<void> cancelarAgendamento(String agendamentoId) async {
    try {
      await _supabase
          .from('agendamentos')
          .update({'status': 'cancelado'})
          .eq('id', agendamentoId);
    } catch (e) {
      print('Erro ao cancelar agendamento: $e');
      rethrow;
    }
  }
}
