import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:odonto/utils/constants.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ========== ESTATÍSTICAS E AGENDAMENTOS ==========

  Future<Map<String, dynamic>> getEstatisticas() async {
    try {
      final hoje = DateTime.now();
      final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
      final fimHoje = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59);

      final agendamentosHoje = await _supabase
          .from('agendamentos')
          .select()
          .gte('data', inicioHoje.toIso8601String())
          .lte('data', fimHoje.toIso8601String());

      final agendamentosPendentes = await _supabase
          .from('agendamentos')
          .select()
          .eq('status', 'pendente');

      final totalUsuarios = await _getTotalUsuariosSafe();
      final totalProfissionais = await _getTotalProfissionaisSafe();

      return {
        'agendamentos_hoje': agendamentosHoje.length,
        'agendamentos_pendentes': agendamentosPendentes.length,
        'total_usuarios': totalUsuarios,
        'total_profissionais': totalProfissionais,
      };
    } catch (e) {
      print('Erro ao buscar estatísticas: $e');
      return {
        'agendamentos_hoje': 0,
        'agendamentos_pendentes': 0,
        'total_usuarios': 0,
        'total_profissionais': 0,
      };
    }
  }

  Future<int> _getTotalUsuariosSafe() async {
    try {
      final response = await _supabase.from('usuarios').select('id');
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getTotalProfissionaisSafe() async {
    try {
      final response = await _supabase
          .from('profissionais')
          .select('id')
          .eq('ativo', true);
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getAgendamentosHoje() async {
    try {
      final hoje = DateTime.now();
      final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
      final fimHoje = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59);

      final response = await _supabase
          .from('agendamentos')
          .select()
          .gte('data', inicioHoje.toIso8601String())
          .lte('data', fimHoje.toIso8601String())
          .order('data', ascending: true);

      return _processarAgendamentos(response);
    } catch (e) {
      print('Erro ao buscar agendamentos de hoje: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTodosAgendamentos() async {
    try {
      final response = await _supabase
          .from('agendamentos')
          .select()
          .order('data', ascending: false);

      return _processarAgendamentos(response);
    } catch (e) {
      print('Erro ao buscar todos agendamentos: $e');
      return [];
    }
  }

  // Novo método para buscar agendamentos com filtros
  Future<List<Map<String, dynamic>>> getAgendamentosComFiltro({
    String? busca,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? status,
  }) async {
    try {
      var query = _supabase.from('agendamentos').select();

      // Aplicar filtro de busca por texto
      if (busca != null && busca.isNotEmpty) {
        query = query.or(
          'nome.ilike.%${busca}%,email.ilike.%${busca}%,telefone.ilike.%${busca}%,servico.ilike.%${busca}%',
        );
      }

      // Aplicar filtro de data início
      if (dataInicio != null) {
        query = query.gte('data', dataInicio.toIso8601String());
      }

      // Aplicar filtro de data fim
      if (dataFim != null) {
        final dataFimAjustada = DateTime(
          dataFim.year,
          dataFim.month,
          dataFim.day,
          23,
          59,
          59,
        );
        query = query.lte('data', dataFimAjustada.toIso8601String());
      }

      // Aplicar filtro de status
      if (status != null && status.isNotEmpty && status != 'todos') {
        query = query.eq('status', status);
      }

      final response = await query.order('data', ascending: false);

      return _processarAgendamentos(response);
    } catch (e) {
      print('Erro ao buscar agendamentos com filtro: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _processarAgendamentos(List<dynamic> response) {
    return response.map((agendamento) {
      return {
        'id': agendamento['id'],
        'data': agendamento['data'],
        'status': agendamento['status'] ?? 'pendente',
        'nome': agendamento['nome'] ?? 'Cliente',
        'email': agendamento['email'] ?? '',
        'telefone': agendamento['telefone'] ?? '',
        'servico': agendamento['servico'] ?? 'Consulta',
        'observacoes': agendamento['observacoes'],
        'user_id': agendamento['user_id'],
        'created_at': agendamento['created_at'],
        'updated_at': agendamento['updated_at'],
      };
    }).toList();
  }

  Future<void> atualizarStatusAgendamento(
    String agendamentoId,
    String novoStatus,
  ) async {
    try {
      await _supabase
          .from('agendamentos')
          .update({'status': novoStatus})
          .eq('id', agendamentoId);
    } catch (e) {
      print('Erro ao atualizar status: $e');
      rethrow;
    }
  }

  // ========== GERENCIAMENTO DE PROFISSIONAIS ==========

  Future<List<Map<String, dynamic>>> getProfissionais() async {
    try {
      final response = await _supabase
          .from('profissionais')
          .select('''
            *,
            usuarios (
              id, nome, email, telefone, created_at
            )
          ''')
          .eq('ativo', true)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      print('Erro ao buscar profissionais: $e');
      return [];
    }
  }

  Future<void> adicionarProfissional(Map<String, dynamic> dados) async {
    try {
      // Associa o profissional ao usuário autenticado atual (não usar ID fixo)
      final currentUser = _supabase.auth.currentUser;
      final usuarioId = currentUser?.id;

      await _supabase.from('profissionais').insert({
        'usuario_id': usuarioId,
        'nome': dados['nome'], // Nome do profissional (campo novo)
        'email': dados['email'], // Email do profissional
        'especialidade': dados['especialidade'],
        'registro_profissional': dados['registro_profissional'] ?? '',
        'ativo': true,
      });

      print('Profissional criado com sucesso: ${dados['nome']}');
    } catch (e) {
      print('Erro ao adicionar profissional: $e');
      rethrow;
    }
  }

  Future<void> atualizarProfissional(
    String profissionalId,
    Map<String, dynamic> dados,
  ) async {
    try {
      await _supabase
          .from('profissionais')
          .update({
            'nome': dados['nome'], // Atualizar nome do profissional
            'email': dados['email'],
            'especialidade': dados['especialidade'],
            'registro_profissional': dados['registro_profissional'] ?? '',
          })
          .eq('id', profissionalId);
    } catch (e) {
      print('Erro ao atualizar profissional: $e');
      rethrow;
    }
  }

  Future<void> removerProfissional(String id) async {
    try {
      await _supabase
          .from('profissionais')
          .update({'ativo': false})
          .eq('id', id);
    } catch (e) {
      print('Erro ao remover profissional: $e');
      rethrow;
    }
  }

  // ========== GERENCIAMENTO DE SERVIÇOS ==========

  Future<List<Map<String, dynamic>>> getServicos() async {
    try {
      final response = await _supabase
          .from('servicos')
          .select()
          .eq('ativo', true)
          .order('nome');
      return response;
    } catch (e) {
      print('Erro ao buscar serviços: $e');
      return [];
    }
  }

  Future<void> adicionarServico(Map<String, dynamic> dados) async {
    try {
      await _supabase.from('servicos').insert({
        'nome': dados['nome'],
        'descricao': dados['descricao'] ?? '',
        'duracao_minutos': dados['duracao_minutos'],
        'preco': dados['preco'],
        'ativo': true,
      });
    } catch (e) {
      print('Erro ao adicionar serviço: $e');
      rethrow;
    }
  }

  Future<void> atualizarServico(String id, Map<String, dynamic> dados) async {
    try {
      await _supabase
          .from('servicos')
          .update({
            'nome': dados['nome'],
            'descricao': dados['descricao'] ?? '',
            'duracao_minutos': dados['duracao_minutos'],
            'preco': dados['preco'],
          })
          .eq('id', id);
    } catch (e) {
      print('Erro ao atualizar serviço: $e');
      rethrow;
    }
  }

  Future<void> removerServico(String id) async {
    try {
      await _supabase.from('servicos').update({'ativo': false}).eq('id', id);
    } catch (e) {
      print('Erro ao remover serviço: $e');
      rethrow;
    }
  }

  // ========== GERENCIAMENTO DE HORÁRIOS DE TRABALHO ==========

  Future<List<Map<String, dynamic>>> getHorariosTrabalho() async {
    try {
      final response = await _supabase
          .from('horarios_trabalho')
          .select('''
            *,
            profissionais (
              usuarios (
                nome
              )
            )
          ''')
          .eq('ativo', true)
          .order('dia_semana', ascending: true)
          .order('hora_inicio', ascending: true);
      return response;
    } catch (e) {
      print('Erro ao buscar horários de trabalho: $e');
      return [];
    }
  }

  Future<void> adicionarHorarioTrabalho(Map<String, dynamic> dados) async {
    try {
      await _supabase.from('horarios_trabalho').insert({
        'profissional_id': dados['profissional_id'],
        'dia_semana': dados['dia_semana'],
        'hora_inicio': dados['hora_inicio'],
        'hora_fim': dados['hora_fim'],
        'ativo': true,
      });
    } catch (e) {
      print('Erro ao adicionar horário de trabalho: $e');
      rethrow;
    }
  }

  Future<void> removerHorarioTrabalho(String id) async {
    try {
      await _supabase
          .from('horarios_trabalho')
          .update({'ativo': false})
          .eq('id', id);
    } catch (e) {
      print('Erro ao remover horário de trabalho: $e');
      rethrow;
    }
  }

  // ========== CONFIGURAÇÕES DO SISTEMA ==========

  Future<Map<String, dynamic>> getConfiguracoes() async {
    try {
      final response = await _supabase
          .from('configuracoes')
          .select('*')
          .limit(1);

      if (response.isNotEmpty) {
        return response.first;
      }

      return _getConfiguracoesPadrao();
    } catch (e) {
      print('Erro ao buscar configurações: $e');
      return _getConfiguracoesPadrao();
    }
  }

  Map<String, dynamic> _getConfiguracoesPadrao() {
    return {
      'nome_clinica': 'Renova Odonto',
      'telefone_contato': '(11) 99999-9999',
      'email_contato': 'contato@renovaodonto.com',
      'endereco_clinica': 'Rua Exemplo, 123 - São Paulo, SP',
      'intervalo_consultas': 30,
      'antecedencia_minima': 60,
      'aceitar_novos_agendamentos': true,
      'notificacoes_email': true,
      'lembretes_automaticos': true,
    };
  }

  Future<void> atualizarConfiguracoes(Map<String, dynamic> dados) async {
    try {
      final existing = await _supabase
          .from('configuracoes')
          .select('id')
          .limit(1);

      if (existing.isNotEmpty) {
        await _supabase
            .from('configuracoes')
            .update(dados)
            .eq('id', existing.first['id']);
      } else {
        await _supabase.from('configuracoes').insert(dados);
      }
    } catch (e) {
      print('Erro ao atualizar configurações: $e');
      rethrow;
    }
  }

  // ========== MÉTODOS ADICIONAIS ==========

  Future<List<Map<String, dynamic>>> getHorariosAtendimento() async {
    return await getHorariosTrabalho();
  }

  Future<void> adicionarHorarioAtendimento(Map<String, dynamic> dados) async {
    return await adicionarHorarioTrabalho(dados);
  }

  Future<void> atualizarHorarioAtendimento(
    String id,
    Map<String, dynamic> dados,
  ) async {
    try {
      await _supabase.from('horarios_trabalho').update(dados).eq('id', id);
    } catch (e) {
      print('Erro ao atualizar horário de atendimento: $e');
      rethrow;
    }
  }

  Future<void> removerHorarioAtendimento(String id) async {
    return await removerHorarioTrabalho(id);
  }

  Future<Map<String, dynamic>> getConfiguracoesSistema() async {
    return await getConfiguracoes();
  }

  Future<void> atualizarConfiguracoesSistema(Map<String, dynamic> dados) async {
    return await atualizarConfiguracoes(dados);
  }

  // ========== DADOS PARA GRÁFICOS ==========

  Future<Map<String, dynamic>> getDadosGraficos() async {
    try {
      final ultimos7Dias = DateTime.now().subtract(Duration(days: 7));

      final agendamentosSemana = await _supabase
          .from('agendamentos')
          .select()
          .gte('data', ultimos7Dias.toIso8601String());

      final agendamentosPorStatus = await _supabase
          .from('agendamentos')
          .select()
          .gte('created_at', ultimos7Dias.toIso8601String());

      return {
        'agendamentos_semana': agendamentosSemana.length,
        'por_status': _agruparPorStatus(agendamentosPorStatus),
      };
    } catch (e) {
      print('Erro ao buscar dados gráficos: $e');
      return {'agendamentos_semana': 0, 'por_status': {}};
    }
  }

  Map<String, int> _agruparPorStatus(List<dynamic> agendamentos) {
    final Map<String, int> resultado = {};
    for (final agendamento in agendamentos) {
      final status = agendamento['status'] ?? 'pendente';
      resultado[status] = (resultado[status] ?? 0) + 1;
    }
    return resultado;
  }

  // Adicione este método na classe AdminService
  // Adicione estes métodos na classe AdminService
  Future<Map<String, dynamic>> enviarLembretesWhatsApp() async {
    try {
      final response = await http.get(
        // Mude de POST para GET
        Uri.parse('http://localhost:5000/enviar-lembretes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'erro',
          'mensagem': 'Erro no servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'erro',
        'mensagem':
            'Servidor offline. Execute o "executar_lembretes.bat" primeiro.',
      };
    }
  }

  Future<Map<String, dynamic>> verificarStatusServidor() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/health'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {'status': 'offline', 'mensagem': 'Servidor não está rodando'};
    }
  }

  Future<Map<String, dynamic>> obterStatusEnvio() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/status-envio'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {'status': 'erro', 'mensagem': 'Erro ao verificar status'};
    }
  }

  Future<Map<String, dynamic>> obterAgendamentosAmanha() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/agendamentos/amanha'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {'status': 'erro', 'mensagem': 'Servidor offline'};
    }
  }

  // Adicione também um método para verificar se o WhatsApp Web está aberto
  Future<bool> verificarWhatsAppWeb() async {
    try {
      final process = await Process.run('tasklist', [
        '/FI',
        'IMAGENAME eq chrome.exe',
        '/FO',
        'CSV',
      ], runInShell: true);

      final output = process.stdout.toString().toLowerCase();
      return output.contains('chrome') ||
          output.contains('firefox') ||
          output.contains('edge');
    } catch (e) {
      return false;
    }
  }

  // Método para abrir WhatsApp Web manualmente
  Future<Map<String, dynamic>> abrirWhatsAppWeb() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/abrir-whatsapp'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'erro', 'mensagem': 'Erro no servidor'};
      }
    } catch (e) {
      return {'status': 'erro', 'mensagem': 'Servidor offline'};
    }
  }
}
