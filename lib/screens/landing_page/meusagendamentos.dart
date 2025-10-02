import 'package:flutter/material.dart';
import 'package:odonto/screens/landing_page/agendamento.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/agendamento_service.dart';
import '../../services/auth_service.dart';

class MeusAgendamentos extends StatefulWidget {
  const MeusAgendamentos({Key? key}) : super(key: key);

  @override
  State<MeusAgendamentos> createState() => _MeusAgendamentosState();
}

class _MeusAgendamentosState extends State<MeusAgendamentos> {
  String _filtroStatus = 'todos';
  bool _loading = true;
  String _error = '';
  List<Agendamento> _agendamentos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarAdminRedirecionar();
      _carregarAgendamentos();
    });
  }

  void _verificarAdminRedirecionar() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.userEmail == 'san@gmail.com') {
      Navigator.pushReplacementNamed(context, '/admin-home');
    }
  }

  Future<void> _carregarAgendamentos() async {
    try {
      setState(() {
        _loading = true;
        _error = '';
      });

      final agendamentoService = Provider.of<AgendamentoService>(
        context,
        listen: false,
      );

      final List<Agendamento> agendamentos = await agendamentoService
          .getMeusAgendamentos();

      // Aplicar filtro localmente
      List<Agendamento> agendamentosFiltrados = agendamentos;
      if (_filtroStatus != 'todos') {
        agendamentosFiltrados = agendamentos.where((agendamento) {
          final status = agendamento.status;
          return status == _filtroStatus;
        }).toList();
      }

      setState(() {
        _agendamentos = agendamentosFiltrados;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar agendamentos: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'confirmado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'concluido':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'confirmado':
        return 'Confirmado';
      case 'cancelado':
        return 'Cancelado';
      case 'concluido':
        return 'Concluído';
      default:
        return status;
    }
  }

  String _formatarData(DateTime dateTime) {
    try {
      final format = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');
      return format.format(dateTime);
    } catch (e) {
      return 'Data inválida';
    }
  }

  Widget _buildAgendamentoCard(Agendamento agendamento) {
    final status = agendamento.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: _getStatusColor(status), width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com serviço e status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      agendamento.servico,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getStatusColor(status)),
                    ),
                    child: Text(
                      _getStatusText(status).toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Informações do agendamento
              _buildInfoRow('Data', _formatarData(agendamento.dataHora)),
              _buildInfoRow('Nome', agendamento.nome),
              _buildInfoRow('Email', agendamento.email),
              _buildInfoRow('Telefone', agendamento.telefone),

              if (agendamento.observacoes != null &&
                  agendamento.observacoes!.isNotEmpty)
                _buildInfoRow('Observações', agendamento.observacoes!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Verificar se é admin (caso ainda não tenha redirecionado)
    if (authService.userEmail == 'san@gmail.com') {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        backgroundColor: const Color.fromARGB(255, 101, 31, 255),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarAgendamentos,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtro
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtrar por Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _filtroStatus,
                      onChanged: (String? newValue) {
                        setState(() {
                          _filtroStatus = newValue!;
                        });
                        _carregarAgendamentos();
                      },
                      items: const [
                        DropdownMenuItem(value: 'todos', child: Text('Todos')),
                        DropdownMenuItem(
                          value: 'pendente',
                          child: Text('Pendentes'),
                        ),
                        DropdownMenuItem(
                          value: 'confirmado',
                          child: Text('Confirmados'),
                        ),
                        DropdownMenuItem(
                          value: 'cancelado',
                          child: Text('Cancelados'),
                        ),
                        DropdownMenuItem(
                          value: 'concluido',
                          child: Text('Concluídos'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mensagem de erro
            if (_error.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(_error, style: const TextStyle(color: Colors.red)),
              ),

            const SizedBox(height: 16),

            // Loading
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator())),

            // Lista vazia
            if (!_loading && _agendamentos.isEmpty)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum agendamento encontrado',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _carregarAgendamentos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            101,
                            31,
                            255,
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Recarregar'),
                      ),
                    ],
                  ),
                ),
              ),

            // Lista de agendamentos
            if (!_loading && _agendamentos.isNotEmpty)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _carregarAgendamentos,
                  child: ListView.builder(
                    itemCount: _agendamentos.length,
                    itemBuilder: (context, index) {
                      final agendamento = _agendamentos[index];
                      return _buildAgendamentoCard(agendamento);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
