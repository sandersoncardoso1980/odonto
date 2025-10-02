import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:odonto/services/admin_service.dart';

// Definindo a paleta de cores para facilitar a manutenção
class AppColors {
  static const Color primary = Color(
    0xFF1976D2,
  ); // Azul mais escuro e profissional
  static const Color secondary = Color(
    0xFF4CAF50,
  ); // Verde para sucesso (WhatsApp)
  static const Color background = Color(0xFFF5F5F5); // Cinza claro para o fundo
  static const Color confirmed = Color(0xFF388E3C);
  static const Color confirmedBg = Color(0xFFE8F5E9);
  static const Color pending = Color(0xFFF57C00);
  static const Color pendingBg = Color(0xFFFFF3E0);
  static const Color cancelled = Color(0xFFD32F2F);
  static const Color cancelledBg = Color(0xFFFFEBEE);
  static const Color completed = Color(0xFF1976D2);
  static const Color completedBg = Color(0xFFE3F2FD);
}

class AgendaPage extends StatefulWidget {
  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _agendamentos = [];
  List<Map<String, dynamic>> _agendamentosFiltrados = [];
  bool _isLoading = true;
  String _erro = '';

  // Filtros
  String _filtroStatus = 'todos';
  DateTime? _filtroDataInicio;
  DateTime? _filtroDataFim;
  String _termoBusca = '';

  // Controle do drawer de filtros
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _termoBusca = _searchController.text;
    });
    _aplicarFiltros();
  }

  // Método para abrir WhatsApp com mensagem pré-definida
  void _abrirWhatsApp(Map<String, dynamic> agendamento) async {
    try {
      final nome = agendamento['nome'] ?? 'Cliente';
      final data = DateTime.parse(agendamento['data'].toString());
      final servico = agendamento['servico'] ?? 'Consulta';
      final telefone = agendamento['telefone'] ?? '';

      // Formatar data e hora
      final dataFormatada = _formatarData(data);
      final horaFormatada = _formatarHora(data);

      // Montar mensagem conforme especificado com emojis
      final mensagem =
          "Olá $nome! 😊\n\n"
          "Este é um lembrete do seu agendamento na *Clínica RENOVA Odontologia*.\n\n"
          "📅 Data: $dataFormatada\n"
          "⏰ Horário: $horaFormatada\n"
          "🦷 Serviço: $servico\n\n"
          "Estamos ansiosos para recebê-lo! 😁\n\n"
          "_*Para remarcar ou cancelar, responda esta mensagem.*_";

      if (telefone.isEmpty) {
        _mostrarSnackBar(
          'Telefone não disponível para este cliente',
          AppColors.pending,
        );
        return;
      }

      // Limpar e formatar o telefone
      final telefoneLimpo = telefone.replaceAll(RegExp(r'[^\d+]'), '');
      String telefoneFormatado = telefoneLimpo;
      if (!telefoneFormatado.startsWith('+')) {
        telefoneFormatado = telefoneFormatado.replaceFirst(RegExp(r'^0+'), '');
        if (!telefoneFormatado.startsWith('55')) {
          telefoneFormatado = '55$telefoneFormatado';
        }
      }

      if (telefoneFormatado.isEmpty) {
        _mostrarSnackBar('Telefone inválido', AppColors.pending);
        return;
      }

      final url =
          'https://wa.me/$telefoneFormatado?text=${Uri.encodeComponent(mensagem)}';

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        final urlAlternativo =
            'whatsapp://send?phone=$telefoneFormatado&text=${Uri.encodeComponent(mensagem)}';
        if (await canLaunch(urlAlternativo)) {
          await launch(urlAlternativo);
        } else {
          _mostrarSnackBar(
            'Não foi possível abrir o WhatsApp',
            AppColors.cancelled,
          );
        }
      }
    } catch (e) {
      print('Erro ao abrir WhatsApp: $e');
      _mostrarSnackBar('Erro ao abrir WhatsApp: $e', AppColors.cancelled);
    }
  }

  // O método _enviarLembretesWhatsApp foi mantido, mas com as cores atualizadas.

  void _mostrarSnackBar(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _carregarAgendamentos() async {
    try {
      setState(() {
        _isLoading = true;
        _erro = '';
      });

      final agendamentos = await _adminService.getTodosAgendamentos();

      setState(() {
        _agendamentos = agendamentos;
        _isLoading = false;
      });

      _aplicarFiltros();
    } catch (e) {
      print('Erro ao carregar agendamentos: $e');
      setState(() {
        _isLoading = false;
        _erro = 'Erro ao carregar agendamentos: ${e.toString()}';
      });
    }
  }

  void _aplicarFiltros() {
    List<Map<String, dynamic>> agendamentosFiltrados = List.from(_agendamentos);

    // Filtrar por busca (mantido)
    if (_termoBusca.isNotEmpty) {
      final termo = _termoBusca.toLowerCase();
      agendamentosFiltrados = agendamentosFiltrados.where((agendamento) {
        return agendamento['nome'].toString().toLowerCase().contains(termo) ||
            agendamento['email'].toString().toLowerCase().contains(termo) ||
            agendamento['telefone'].toString().toLowerCase().contains(termo) ||
            agendamento['servico'].toString().toLowerCase().contains(termo) ||
            _formatarData(
              DateTime.parse(agendamento['data'].toString()),
            ).toLowerCase().contains(termo);
      }).toList();
    }

    // Filtrar por status (mantido)
    if (_filtroStatus != 'todos') {
      agendamentosFiltrados = agendamentosFiltrados.where((agendamento) {
        return agendamento['status'] == _filtroStatus;
      }).toList();
    }

    // Filtrar por data (mantido)
    if (_filtroDataInicio != null) {
      agendamentosFiltrados = agendamentosFiltrados.where((agendamento) {
        final dataAgendamento = DateTime.parse(agendamento['data'].toString());
        return dataAgendamento.isAfter(_filtroDataInicio!) ||
            dataAgendamento.isAtSameMomentAs(_filtroDataInicio!);
      }).toList();
    }

    if (_filtroDataFim != null) {
      final dataFimAjustada = DateTime(
        _filtroDataFim!.year,
        _filtroDataFim!.month,
        _filtroDataFim!.day,
        23,
        59,
        59,
      );
      agendamentosFiltrados = agendamentosFiltrados.where((agendamento) {
        final dataAgendamento = DateTime.parse(agendamento['data'].toString());
        return dataAgendamento.isBefore(dataFimAjustada) ||
            dataAgendamento.isAtSameMomentAs(dataFimAjustada);
      }).toList();
    }

    // Ordenação (mantida, pois é lógica de negócio)
    agendamentosFiltrados.sort((a, b) {
      final dataA = DateTime.parse(a['data'].toString());
      final dataB = DateTime.parse(b['data'].toString());
      final agora = DateTime.now();

      final bool aEPassado = dataA.isBefore(
        agora.subtract(Duration(minutes: 5)),
      ); // Pequena margem
      final bool bEPassado = dataB.isBefore(
        agora.subtract(Duration(minutes: 5)),
      );

      if (aEPassado && !bEPassado) {
        return 1;
      } else if (!aEPassado && bEPassado) {
        return -1;
      } else if (aEPassado && bEPassado) {
        // Passado: mais recente primeiro
        return dataB.compareTo(dataA);
      } else {
        // Futuro: mais próximo primeiro
        return dataA.compareTo(dataB);
      }
    });

    setState(() {
      _agendamentosFiltrados = agendamentosFiltrados;
    });
  }

  void _limparFiltros() {
    setState(() {
      _filtroStatus = 'todos';
      _filtroDataInicio = null;
      _filtroDataFim = null;
      _searchController.clear();
    });
    _aplicarFiltros();
    _scaffoldKey.currentState?.closeEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background, // Fundo suave
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar branca e limpa
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        actions: [
          // Botão de filtros
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.filter_list),
                if (_filtroStatus != 'todos' ||
                    _filtroDataInicio != null ||
                    _filtroDataFim != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.pending,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(minWidth: 10, minHeight: 10),
                    ),
                  ),
              ],
            ),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _carregarAgendamentos,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      endDrawer: _buildFiltrosDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Carregando agendamentos...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_erro.isNotEmpty) {
      // Estado de erro aprimorado
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.cancelled),
            SizedBox(height: 16),
            Text(
              'Falha ao carregar dados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _erro.length > 100
                    ? 'Erro detalhado: ${_erro.substring(0, 100)}...'
                    : _erro,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _carregarAgendamentos,
              icon: Icon(Icons.refresh),
              label: Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Barra de busca (Design moderno)
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome, data ou serviço...',
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _termoBusca.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              filled: true, // Campo preenchido
              fillColor: Colors.white, // Fundo branco dentro do campo
              contentPadding: EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 20.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  30.0,
                ), // Bordas bem arredondadas
                borderSide: BorderSide.none, // Sem borda visível
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: AppColors.primary, width: 2.0),
              ),

              // Adiciona uma sombra suave (boxShadow não é nativo, mas elevamos o Padding ou o Container se necessário)
              // Neste caso, a elevação do Scaffold é 0, vamos confiar no design limpo.
            ),
          ),
        ),

        // Contador de resultados
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resultados: ${_agendamentosFiltrados.length} de ${_agendamentos.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Botão para enviar lembretes hoje (mantido como opcional)
            ],
          ),
        ),

        // Lista de agendamentos
        Expanded(
          child: RefreshIndicator(
            onRefresh: _carregarAgendamentos,
            color: AppColors.primary,
            child: _agendamentosFiltrados.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
                    itemCount: _agendamentosFiltrados.length,
                    itemBuilder: (context, index) {
                      final agendamento = _agendamentosFiltrados[index];
                      return _buildAgendamentoCard(agendamento);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltrosDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header limpo do Drawer
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 10,
              left: 16,
            ),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros de Agendamento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  onPressed: () => _scaffoldKey.currentState?.closeEndDrawer(),
                ),
              ],
            ),
          ),
          Divider(height: 1),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Filtro de status
                _buildFilterSection(
                  title: 'Status',
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusChip('todos', 'Todos'),
                        _buildStatusChip('pendente', 'Pendente'),
                        _buildStatusChip('confirmado', 'Confirmado'),
                        _buildStatusChip('cancelado', 'Cancelado'),
                        _buildStatusChip('concluido', 'Concluído'),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Filtro de data
                _buildFilterSection(
                  title: 'Período',
                  children: [
                    _buildDateFilterTile(
                      label: 'Data inicial',
                      data: _filtroDataInicio,
                      onClear: _filtroDataInicio != null
                          ? () {
                              setState(() {
                                _filtroDataInicio = null;
                              });
                              _aplicarFiltros();
                            }
                          : null,
                      onTap: () async {
                        final data = await showDatePicker(
                          context: context,
                          initialDate: _filtroDataInicio ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.primary, // Cor Primária
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (data != null) {
                          setState(() {
                            _filtroDataInicio = data;
                          });
                          _aplicarFiltros();
                        }
                      },
                    ),

                    _buildDateFilterTile(
                      label: 'Data final',
                      data: _filtroDataFim,
                      onClear: _filtroDataFim != null
                          ? () {
                              setState(() {
                                _filtroDataFim = null;
                              });
                              _aplicarFiltros();
                            }
                          : null,
                      onTap: () async {
                        final data = await showDatePicker(
                          context: context,
                          initialDate: _filtroDataFim ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (data != null) {
                          setState(() {
                            _filtroDataFim = data;
                          });
                          _aplicarFiltros();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botões de ação
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _limparFiltros,
                    child: Text('Limpar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _scaffoldKey.currentState?.closeEndDrawer(),
                    child: Text('Aplicar Filtros'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Componente reutilizável para a seção de filtro
  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  // Componente reutilizável para o tile de data
  Widget _buildDateFilterTile({
    required String label,
    required DateTime? data,
    required VoidCallback? onClear,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(Icons.calendar_today_outlined, color: AppColors.primary),
      title: Text(label),
      subtitle: Text(
        data != null ? _formatarData(data) : 'Selecione a data',
        style: TextStyle(
          color: data != null ? Colors.black87 : Colors.grey,
          fontWeight: data != null ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.clear,
          color: onClear != null ? Colors.grey : Colors.transparent,
        ),
        onPressed: onClear,
      ),
      onTap: onTap,
    );
  }

  // Chip de Status estilizado
  Widget _buildStatusChip(String status, String label) {
    final bool selecionado = _filtroStatus == status;
    Color color;
    Color bgColor;

    switch (status) {
      case 'confirmado':
        color = AppColors.confirmed;
        bgColor = AppColors.confirmedBg;
        break;
      case 'pendente':
        color = AppColors.pending;
        bgColor = AppColors.pendingBg;
        break;
      case 'cancelado':
        color = AppColors.cancelled;
        bgColor = AppColors.cancelledBg;
        break;
      case 'concluido':
        color = AppColors.completed;
        bgColor = AppColors.completedBg;
        break;
      default:
        color = Colors.grey[700]!;
        bgColor = Colors.grey[200]!;
    }

    return FilterChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (selected) {
        setState(() {
          _filtroStatus = selected ? status : 'todos';
        });
        _aplicarFiltros();
      },
      backgroundColor: selecionado ? color.withOpacity(0.2) : Colors.grey[100],
      selectedColor: bgColor,
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: selecionado ? color : Colors.grey[700],
        fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: selecionado
            ? BorderSide(color: color.withOpacity(0.5))
            : BorderSide.none,
      ),
    );
  }

  // Estado Vazio aprimorado
  Widget _buildEmptyState() {
    bool hasFilters =
        _termoBusca.isNotEmpty ||
        _filtroStatus != 'todos' ||
        _filtroDataInicio != null ||
        _filtroDataFim != null;
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasFilters ? Icons.search_off : Icons.calendar_today_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16),
                Text(
                  hasFilters ? 'Nenhum Agendamento Encontrado' : 'Agenda Vazia',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  hasFilters
                      ? 'Ajuste seus filtros ou recarregue a lista para ver outros agendamentos.'
                      : 'Não há agendamentos cadastrados para este período.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                if (hasFilters)
                  ElevatedButton.icon(
                    onPressed: _limparFiltros,
                    icon: Icon(Icons.clear_all),
                    label: Text('Limpar Filtros'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _carregarAgendamentos,
                    icon: Icon(Icons.refresh),
                    label: Text('Recarregar Agenda'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Card de Agendamento (Refatorado para o novo design)
  Widget _buildAgendamentoCard(Map<String, dynamic> agendamento) {
    try {
      final data = DateTime.parse(agendamento['data'].toString());
      final status = agendamento['status'] ?? 'pendente';
      final bool ePassado = data.isBefore(
        DateTime.now().subtract(Duration(minutes: 5)),
      );

      Color statusColor;
      Color statusBackground;

      switch (status) {
        case 'confirmado':
          statusColor = AppColors.confirmed;
          statusBackground = AppColors.confirmedBg;
          break;
        case 'pendente':
          statusColor = AppColors.pending;
          statusBackground = AppColors.pendingBg;
          break;
        case 'cancelado':
          statusColor = AppColors.cancelled;
          statusBackground = AppColors.cancelledBg;
          break;
        case 'concluido':
          statusColor = AppColors.completed;
          statusBackground = AppColors.completedBg;
          break;
        default:
          statusColor = Colors.grey[600]!;
          statusBackground = Colors.grey[200]!;
      }

      final Color cardColor = ePassado ? Colors.white : Colors.white;
      final Color primaryTextColor = ePassado
          ? Colors.grey[600]!
          : Colors.black87;
      final Color secondaryTextColor = ePassado
          ? Colors.grey[500]!
          : Colors.grey[700]!;
      final Color iconColor = ePassado
          ? Colors.grey[500]!
          : AppColors.primary.withOpacity(0.8);

      return Card(
        margin: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ), // Margem ajustada
        elevation: ePassado ? 0 : 4, // Sombra maior para agendamentos futuros
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Mais arredondado
          side: ePassado
              ? BorderSide(color: Colors.grey[200]!)
              : BorderSide.none,
        ),
        child: Padding(
          padding: EdgeInsets.all(20), // Mais padding interno
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: Cliente e Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: ePassado
                        ? Colors.grey[300]!
                        : AppColors.primary.withOpacity(0.1),
                    radius: 20,
                    child: Icon(
                      Icons.person_outline,
                      color: ePassado ? Colors.grey[600]! : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agendamento['nome'] ?? 'Cliente Desconhecido',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: primaryTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((agendamento['email'] ?? '').isNotEmpty)
                          Text(
                            agendamento['email'] ?? '',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Chip de Status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),
              Divider(color: Colors.grey[100]), // Divisor suave
              SizedBox(height: 16),

              // Detalhes (Data, Hora, Serviço)
              _buildDetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Data',
                value: _formatarData(data),
                iconColor: iconColor,
                ePassado: ePassado,
              ),
              SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.access_time_outlined,
                label: 'Hora',
                value: _formatarHora(data),
                iconColor: iconColor,
                ePassado: ePassado,
              ),
              SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.medical_services_outlined,
                label: 'Serviço',
                value: agendamento['servico'] ?? 'Consulta Padrão',
                iconColor: iconColor,
                ePassado: ePassado,
              ),

              // Telefone
              if ((agendamento['telefone'] ?? '').isNotEmpty) ...[
                SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Telefone',
                  value: agendamento['telefone'] ?? '',
                  iconColor: iconColor,
                  ePassado: ePassado,
                ),
              ],

              // Observações (se houver)
              if (agendamento['observacoes'] != null &&
                  agendamento['observacoes'].toString().isNotEmpty) ...[
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ePassado ? Colors.grey[100]! : Colors.blue[50]!,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OBSERVAÇÕES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        agendamento['observacoes'].toString(),
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],

              // Botão WhatsApp (com estilo de Elevated mais moderno)
              SizedBox(height: 20),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _abrirWhatsApp(agendamento),
                    icon: Icon(
                      Icons.message,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    label: Text(
                      'WhatsApp',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Erro ao construir card do agendamento: $e');
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: AppColors.cancelledBg,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: AppColors.cancelled),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Erro ao carregar agendamento: Dados incompletos ou inválidos.',
                  style: TextStyle(color: AppColors.cancelled),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Novo Widget Auxiliar para Linhas de Detalhe
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required bool ePassado,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: ePassado ? Colors.grey[600]! : Colors.grey[900],
              fontStyle: ePassado ? FontStyle.italic : FontStyle.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (label == 'Hora')
          Text(
            ePassado ? ' (Passado)' : ' (Futuro)',
            style: TextStyle(
              fontSize: 12,
              color: ePassado ? Colors.grey[400] : AppColors.secondary,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  String _formatarHora(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }
}
