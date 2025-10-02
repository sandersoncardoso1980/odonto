import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:odonto/services/servico.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_button.dart';
import '../../services/agendamento_service.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

  @override
  _AgendamentoPageState createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _observacoesController = TextEditingController();

  Servico? _servicoSelecionado;
  List<Servico> _servicosDisponiveis = [];

  late AgendamentoService _agendamentoService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _agendamentoService = Provider.of<AgendamentoService>(
        context,
        listen: false,
      );
      _carregarServicos();
    });
  }

  Future<void> _carregarServicos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _servicosDisponiveis = await _agendamentoService.getServicos();
      if (_servicosDisponiveis.isNotEmpty) {
        _servicoSelecionado = _servicosDisponiveis.first;
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar serviços: $e';
      _showErrorDialog(_errorMessage!);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _getEmptySuffixIcon() {
    return const IconButton(
      icon: Icon(Icons.abc, color: Colors.transparent, size: 0),
      onPressed: null,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              onSurface: Colors.grey[800]!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue[600]),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Reset time when date changes
      });
    }
  }

  Future<void> _selectTime() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, selecione uma data primeiro'),
          backgroundColor: Colors.orange[600],
        ),
      );
      return;
    }
    if (_servicoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, selecione um serviço primeiro'),
          backgroundColor: Colors.orange[600],
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final horariosDisponiveis = await _agendamentoService
          .getHorariosDisponiveis(_selectedDate!, _servicoSelecionado!.nome);

      await _mostrarHorariosDisponiveis(horariosDisponiveis);
    } catch (e) {
      _showErrorDialog('Erro ao carregar horários: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _mostrarHorariosDisponiveis(
    List<TimeOfDay> horariosDisponiveis,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Text(
              'Horários Disponíveis - ${_formatDate(_selectedDate!)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (horariosDisponiveis.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum horário disponível para esta data e serviço.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: horariosDisponiveis.length,
                  itemBuilder: (context, index) {
                    final horario = horariosDisponiveis[index];

                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedTime = horario;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        foregroundColor: Colors.green[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.green[300]!),
                        ),
                      ),
                      child: Text(
                        horario.format(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('FECHAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _agendar() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null &&
        _servicoSelecionado != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _agendamentoService.criarAgendamento(
          nome: _nomeController.text,
          email: _emailController.text,
          telefone: _telefoneController.text,
          data: _selectedDate!,
          hora: _selectedTime!,
          nomeServico: _servicoSelecionado!.nome,
          observacoes: _observacoesController.text.isNotEmpty
              ? _observacoesController.text
              : null,
        );

        _showSuccessDialog();
      } catch (e) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        if (_errorMessage!.contains('Horário indisponível')) {
          _showHorarioIndisponivelDialog();
        } else {
          _showErrorDialog(_errorMessage!);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, preencha todos os campos obrigatórios e selecione data/hora/serviço.',
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showHorarioIndisponivelDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.schedule, color: Colors.orange[600], size: 24),
            const SizedBox(width: 8),
            const Text(
              'Horário Indisponível',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _errorMessage ??
                  'Este horário já está reservado para outro paciente.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Por favor, escolha outro horário para seu agendamento.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fechar o dialog
            },
            child: const Text('ESCOLHER OUTRO HORÁRIO'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 24),
            const SizedBox(width: 8),
            Text(
              'Agendamento Confirmado!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seu agendamento foi realizado com sucesso.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📅 ${_formatDate(_selectedDate!)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '⏰ ${_selectedTime!.format(context)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '👤 ${_nomeController.text}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🦷 ${_servicoSelecionado!.nome}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você receberá um e-mail de confirmação em breve.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _limparFormulario();
              Navigator.pop(context); // Fechar dialog
              Navigator.pop(context); // Voltar para tela anterior
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _limparFormulario() {
    _nomeController.clear();
    _emailController.clear();
    _telefoneController.clear();
    _observacoesController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      if (_servicosDisponiveis.isNotEmpty) {
        _servicoSelecionado = _servicosDisponiveis.first;
      } else {
        _servicoSelecionado = null;
      }
      _errorMessage = null;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600], size: 24),
            const SizedBox(width: 8),
            Text(
              'Erro no Agendamento',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'TENTAR NOVAMENTE',
              style: TextStyle(color: Colors.blue[600]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Agendamento Rápido'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading && _servicosDisponiveis.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Agende sua consulta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preencha os dados abaixo para agendar seu horário',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

                    // Nome
                    CustomInput(
                      controller: _nomeController,
                      label: 'Nome Completo',
                      hintText: 'Digite seu nome completo',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      suffixIcon: _getEmptySuffixIcon(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite seu nome';
                        }
                        if (value.trim().split(' ').length < 2) {
                          return 'Digite nome e sobrenome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    CustomInput(
                      controller: _emailController,
                      label: 'E-mail',
                      hintText: 'seu.email@exemplo.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      suffixIcon: _getEmptySuffixIcon(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite seu e-mail';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Por favor, digite um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Telefone
                    CustomInput(
                      controller: _telefoneController,
                      label: 'Telefone',
                      hintText: '(11) 99999-9999',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      suffixIcon: _getEmptySuffixIcon(),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                        _TelefoneInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite seu telefone';
                        }
                        final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                        if (digits.length < 10) {
                          return 'Digite um telefone válido com DDD';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Serviço
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonFormField<Servico>(
                          value: _servicoSelecionado,
                          decoration: InputDecoration(
                            labelText: 'Serviço Desejado',
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.medical_services_outlined,
                              color: Colors.grey[600],
                            ),
                          ),
                          items: _servicosDisponiveis.map((Servico servico) {
                            return DropdownMenuItem<Servico>(
                              value: servico,
                              child: Text(
                                servico.nome,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                          onChanged: (Servico? newValue) {
                            setState(() {
                              _servicoSelecionado = newValue!;
                              _selectedTime =
                                  null; // Reset time when service changes
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor, selecione um serviço';
                            }
                            return null;
                          },
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[600],
                          ),
                          isExpanded: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Observações
                    CustomInput(
                      controller: _observacoesController,
                      label: 'Observações (Opcional)',
                      hintText: 'Alguma observação sobre o agendamento...',
                      prefixIcon: const Icon(Icons.note_outlined),
                      suffixIcon: _getEmptySuffixIcon(),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Seção de Data e Hora
                    _buildSectionTitle('Data e Horário'),
                    const SizedBox(height: 16),

                    // Data
                    _buildDateTimeButton(
                      icon: Icons.calendar_today_outlined,
                      text: _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : 'Selecionar Data',
                      isSelected: _selectedDate != null,
                      onPressed: _selectDate,
                    ),
                    const SizedBox(height: 12),

                    // Hora
                    _buildDateTimeButton(
                      icon: Icons.access_time_rounded,
                      text: _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Selecionar Hora',
                      isSelected: _selectedTime != null,
                      onPressed: _selectTime,
                    ),
                    const SizedBox(height: 8),

                    // Indicador de campos obrigatórios
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '* Campos marcados com asterisco são obrigatórios',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botão Agendar
                    CustomButton(
                      text: 'Confirmar Agendamento',
                      onPressed: _isLoading ? null : _agendar,
                      isLoading: _isLoading,
                      backgroundColor: Colors.blue[600]!,
                      foregroundColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildDateTimeButton({
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          backgroundColor: isSelected ? Colors.blue[50] : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue[600] : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.blue[800] : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }
}

class _TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length > 11) return oldValue;
    if (text.isEmpty) return const TextEditingValue();

    String formattedText = '';
    if (text.length >= 2) {
      formattedText = '(${text.substring(0, 2)})';
    } else {
      formattedText = '($text';
    }

    if (text.length > 2) {
      final parteNumero = text.substring(2);
      if (parteNumero.length <= 5) {
        formattedText += ' $parteNumero';
      } else {
        formattedText +=
            ' ${parteNumero.substring(0, 5)}-${parteNumero.substring(5)}';
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
