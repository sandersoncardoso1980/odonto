import 'package:flutter/material.dart';
import 'package:odonto/services/admin_service.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic> _estatisticas = {};
  List<Map<String, dynamic>> _todosAgendamentos = [];
  List<Map<String, dynamic>> _agendamentosFiltrados = [];
  bool _isLoading = true;

  // Filtros
  String _filtroOrdenacao = 'recente_antigo';
  String _filtroStatus = 'todos';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final estatisticas = await _adminService.getEstatisticas();
      final agendamentos = await _adminService.getTodosAgendamentos();
      setState(() {
        _estatisticas = estatisticas;
        _todosAgendamentos = agendamentos;
        _isLoading = false;
      });
      _aplicarFiltros();
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  void _aplicarFiltros() {
    List<Map<String, dynamic>> agendamentosFiltrados = List.from(
      _todosAgendamentos,
    );

    // Filtrar por status
    if (_filtroStatus != 'todos') {
      agendamentosFiltrados = agendamentosFiltrados.where((agendamento) {
        return agendamento['status'] == _filtroStatus;
      }).toList();
    }

    // Aplicar ordenação
    switch (_filtroOrdenacao) {
      case 'recente_antigo':
        agendamentosFiltrados.sort((a, b) {
          final dataA = DateTime.parse(a['data']);
          final dataB = DateTime.parse(b['data']);
          return dataB.compareTo(dataA); // Mais recente primeiro
        });
        break;
      case 'antigo_recente':
        agendamentosFiltrados.sort((a, b) {
          final dataA = DateTime.parse(a['data']);
          final dataB = DateTime.parse(b['data']);
          return dataA.compareTo(dataB); // Mais antigo primeiro
        });
        break;
      case 'a_z':
        agendamentosFiltrados.sort((a, b) {
          final nomeA = (a['nome'] ?? 'Cliente').toString().toLowerCase();
          final nomeB = (b['nome'] ?? 'Cliente').toString().toLowerCase();
          return nomeA.compareTo(nomeB);
        });
        break;
      case 'z_a':
        agendamentosFiltrados.sort((a, b) {
          final nomeA = (a['nome'] ?? 'Cliente').toString().toLowerCase();
          final nomeB = (b['nome'] ?? 'Cliente').toString().toLowerCase();
          return nomeB.compareTo(nomeA);
        });
        break;
      case 'status':
        agendamentosFiltrados.sort((a, b) {
          final statusA = (a['status'] ?? 'pendente').toString();
          final statusB = (b['status'] ?? 'pendente').toString();
          return statusA.compareTo(statusB);
        });
        break;
    }

    setState(() {
      _agendamentosFiltrados = agendamentosFiltrados;
    });
  }

  // Método para lidar com a alteração dos filtros
  void _onFiltrosAlterados(String novaOrdenacao, String novoStatus) {
    setState(() {
      _filtroOrdenacao = novaOrdenacao;
      _filtroStatus = novoStatus;
    });
    _aplicarFiltros();
  }

  Future<void> _atualizarStatus(String agendamentoId, String novoStatus) async {
    try {
      await _adminService.atualizarStatusAgendamento(agendamentoId, novoStatus);
      await _carregarDados();
    } catch (e) {
      debugPrint('Erro ao atualizar status: $e');
    }
  }

  void _mostrarDialogoFiltros() {
    showDialog(
      context: context,
      builder: (context) => FiltrosDialog(
        filtroOrdenacao: _filtroOrdenacao,
        filtroStatus: _filtroStatus,
        onFiltrosAlterados: _onFiltrosAlterados,
      ),
    );
  }

  String _getLabelOrdenacao() {
    switch (_filtroOrdenacao) {
      case 'recente_antigo':
        return 'Mais recente';
      case 'antigo_recente':
        return 'Mais antigo';
      case 'a_z':
        return 'A-Z';
      case 'z_a':
        return 'Z-A';
      case 'status':
        return 'Status';
      default:
        return 'Ordenar';
    }
  }

  String _getLabelStatus() {
    switch (_filtroStatus) {
      case 'todos':
        return 'Todos';
      case 'pendente':
        return 'Pendente';
      case 'confirmado':
        return 'Confirmado';
      case 'cancelado':
        return 'Cancelado';
      case 'concluido':
        return 'Concluído';
      default:
        return 'Status';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Painel de Controle',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Visão geral de todos os agendamentos',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Cards de Estatísticas
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final cards = [
                  {
                    "title": "Total de Agendamentos",
                    "value":
                        _estatisticas['total_agendamentos']?.toString() ??
                        _todosAgendamentos.length.toString(),
                    "icon": Icons.calendar_today_outlined,
                    "color": Colors.blue,
                  },
                  {
                    "title": "Agendamentos Pendentes",
                    "value":
                        _estatisticas['agendamentos_pendentes']?.toString() ??
                        '0',
                    "icon": Icons.pending_actions_outlined,
                    "color": Colors.orange,
                  },
                  {
                    "title": "Total de Usuários",
                    "value": _estatisticas['total_usuarios']?.toString() ?? '0',
                    "icon": Icons.people_outlined,
                    "color": Colors.green,
                  },
                  {
                    "title": "Profissionais",
                    "value":
                        _estatisticas['total_profissionais']?.toString() ?? '0',
                    "icon": Icons.medical_services_outlined,
                    "color": Colors.purple,
                  },
                ];

                final card = cards[index];
                return _buildStatCard(
                  card["title"] as String,
                  card["value"] as String,
                  card["icon"] as IconData,
                  card["color"] as Color,
                );
              },
            ),

            const SizedBox(height: 32),

            // Cabeçalho com filtros
            Row(
              children: [
                Text(
                  'Todos os Agendamentos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                // Botão de filtros
                OutlinedButton.icon(
                  onPressed: _mostrarDialogoFiltros,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: Text('Filtrar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Indicadores de filtros ativos
            if (_filtroStatus != 'todos' ||
                _filtroOrdenacao != 'recente_antigo')
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (_filtroStatus != 'todos')
                      Chip(
                        label: Text('Status: ${_getLabelStatus()}'),
                        deleteIcon: Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _filtroStatus = 'todos';
                          });
                          _aplicarFiltros();
                        },
                      ),
                    Chip(
                      label: Text('Ordenação: ${_getLabelOrdenacao()}'),
                      deleteIcon: Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _filtroOrdenacao = 'recente_antigo';
                        });
                        _aplicarFiltros();
                      },
                    ),
                  ],
                ),
              ),

            // Contador de resultados
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${_agendamentosFiltrados.length} de ${_todosAgendamentos.length} agendamento(s)',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            if (_agendamentosFiltrados.isEmpty)
              _buildEmptyState('Nenhum agendamento encontrado')
            else
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _agendamentosFiltrados.length; i++)
                      Column(
                        children: [
                          _buildAgendamentoItem(_agendamentosFiltrados[i]),
                          if (i < _agendamentosFiltrados.length - 1)
                            const Divider(height: 1),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendamentoItem(Map<String, dynamic> agendamento) {
    try {
      final data = DateTime.parse(agendamento['data']);
      final hora =
          '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
      final status = agendamento['status'] ?? 'pendente';
      final dataFormatada =
          '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

      String nomeUsuario = agendamento['nome'] ?? 'Cliente';
      String servico = agendamento['servico'] ?? 'Consulta';
      String telefone = agendamento['telefone'] ?? '';

      Color statusColor = _getStatusColor(status);

      // Verificar se é um agendamento passado
      // CORREÇÃO: ePassado será true apenas se a data/hora do agendamento for anterior ao momento atual
      final bool ePassado = data.isBefore(DateTime.now());

      Color cardColor = ePassado ? Colors.grey[50]! : Colors.white;

      return Container(
        color: cardColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: ePassado ? Colors.grey[300]! : Colors.blue,
            child: Icon(
              ePassado ? Icons.archive_outlined : Icons.person_outline,
              color: ePassado ? Colors.grey[600]! : Colors.white,
            ),
          ),
          title: Text(
            nomeUsuario,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ePassado ? Colors.grey[600] : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                servico,
                style: TextStyle(
                  color: ePassado ? Colors.grey[500] : Colors.grey[700],
                ),
              ),
              if (telefone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  telefone,
                  style: TextStyle(
                    fontSize: 12,
                    color: ePassado ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (ePassado)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PASSADO',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                hora,
                style: TextStyle(
                  fontSize: ePassado ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: ePassado ? Colors.grey[500] : Colors.grey[800],
                ),
              ),
              Text(
                dataFormatada,
                style: TextStyle(
                  fontSize: ePassado ? 14 : 16,
                  color: ePassado ? Colors.grey[400] : Colors.black,
                ),
              ),
            ],
          ),
          onTap: () => _showStatusDialog(agendamento['id'], status),
        ),
      );
    } catch (e) {
      return const ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.error_outline, color: Colors.white),
        ),
        title: Text(
          'Erro ao carregar',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
        ),
        subtitle: Text('Dados corrompidos'),
      );
    }
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 72,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(String agendamentoId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Alterar Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(
              'pendente',
              'Pendente',
              currentStatus,
              agendamentoId,
            ),
            _buildStatusOption(
              'confirmado',
              'Confirmado',
              currentStatus,
              agendamentoId,
            ),
            _buildStatusOption(
              'cancelado',
              'Cancelado',
              currentStatus,
              agendamentoId,
            ),
            _buildStatusOption(
              'concluido',
              'Concluído',
              currentStatus,
              agendamentoId,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    String status,
    String label,
    String currentStatus,
    String agendamentoId,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.circle, color: _getStatusColor(status), size: 14),
      title: Text(label),
      trailing: currentStatus == status
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () {
        Navigator.pop(context);
        _atualizarStatus(agendamentoId, status);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmado':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      case 'concluido':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// Widget separado para o diálogo de filtros
class FiltrosDialog extends StatefulWidget {
  final String filtroOrdenacao;
  final String filtroStatus;
  final Function(String, String) onFiltrosAlterados;

  const FiltrosDialog({
    Key? key,
    required this.filtroOrdenacao,
    required this.filtroStatus,
    required this.onFiltrosAlterados,
  }) : super(key: key);

  @override
  _FiltrosDialogState createState() => _FiltrosDialogState();
}

class _FiltrosDialogState extends State<FiltrosDialog> {
  late String _filtroOrdenacao;
  late String _filtroStatus;

  @override
  void initState() {
    super.initState();
    _filtroOrdenacao = widget.filtroOrdenacao;
    _filtroStatus = widget.filtroStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  const Text(
                    'Filtrar e Ordenar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Conteúdo com scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filtro de Ordenação
                      _buildFiltroSection('Ordenar por:', [
                        _buildOpcaoFiltro(
                          'recente_antigo',
                          'Mais recente primeiro',
                          _filtroOrdenacao,
                          (valor) {
                            setState(() {
                              _filtroOrdenacao = valor;
                            });
                          },
                        ),
                        _buildOpcaoFiltro(
                          'antigo_recente',
                          'Mais antigo primeiro',
                          _filtroOrdenacao,
                          (valor) {
                            setState(() {
                              _filtroOrdenacao = valor;
                            });
                          },
                        ),
                        _buildOpcaoFiltro('a_z', 'Nome A-Z', _filtroOrdenacao, (
                          valor,
                        ) {
                          setState(() {
                            _filtroOrdenacao = valor;
                          });
                        }),
                        _buildOpcaoFiltro('z_a', 'Nome Z-A', _filtroOrdenacao, (
                          valor,
                        ) {
                          setState(() {
                            _filtroOrdenacao = valor;
                          });
                        }),
                        _buildOpcaoFiltro(
                          'status',
                          'Status',
                          _filtroOrdenacao,
                          (valor) {
                            setState(() {
                              _filtroOrdenacao = valor;
                            });
                          },
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // Filtro de Status
                      _buildFiltroSection('Filtrar por status:', [
                        _buildOpcaoFiltro('todos', 'Todos', _filtroStatus, (
                          valor,
                        ) {
                          setState(() {
                            _filtroStatus = valor;
                          });
                        }),
                        _buildOpcaoFiltro(
                          'pendente',
                          'Pendente',
                          _filtroStatus,
                          (valor) {
                            setState(() {
                              _filtroStatus = valor;
                            });
                          },
                        ),
                        _buildOpcaoFiltro(
                          'confirmado',
                          'Confirmado',
                          _filtroStatus,
                          (valor) {
                            setState(() {
                              _filtroStatus = valor;
                            });
                          },
                        ),
                        _buildOpcaoFiltro(
                          'cancelado',
                          'Cancelado',
                          _filtroStatus,
                          (valor) {
                            setState(() {
                              _filtroStatus = valor;
                            });
                          },
                        ),
                        _buildOpcaoFiltro(
                          'concluido',
                          'Concluído',
                          _filtroStatus,
                          (valor) {
                            setState(() {
                              _filtroStatus = valor;
                            });
                          },
                        ),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _filtroOrdenacao = 'recente_antigo';
                          _filtroStatus = 'todos';
                        });
                      },
                      child: const Text('Limpar Filtros'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onFiltrosAlterados(
                          _filtroOrdenacao,
                          _filtroStatus,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroSection(String titulo, List<Widget> opcoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...opcoes,
      ],
    );
  }

  Widget _buildOpcaoFiltro(
    String valor,
    String label,
    String filtroAtual,
    Function(String) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            onChanged(valor);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Radio<String>(
                  value: valor,
                  groupValue: filtroAtual,
                  onChanged: (value) {
                    onChanged(value!);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
