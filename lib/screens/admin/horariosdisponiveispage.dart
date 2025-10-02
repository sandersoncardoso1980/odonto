import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/agendamento_service.dart';

class HorariosDisponiveisPage extends StatefulWidget {
  const HorariosDisponiveisPage({Key? key}) : super(key: key);

  @override
  State<HorariosDisponiveisPage> createState() =>
      _HorariosDisponiveisPageState();
}

class _HorariosDisponiveisPageState extends State<HorariosDisponiveisPage> {
  final AgendamentoService _agendamentoService = AgendamentoService();
  DateTime _selectedDate = DateTime.now();
  String _servicoSelecionado = 'Consulta Odontológica';
  final List<String> _servicos = [
    'Consulta Odontológica',
    'Limpeza Dental',
    'Clareamento Dental',
    'Ortodontia',
    'Implante Dentário',
    'Extração Dentária',
    'Tratamento de Canal',
    'Prótese Dentária',
    'Lente de Contato Dental',
    'Faceta Resina',
  ];

  List<DateTime> _horariosDisponiveis = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _carregarHorariosDisponiveis();
  }

  Future<void> _carregarHorariosDisponiveis() async {
    setState(() {
      _loading = true;
    });

    try {
      final horarios = await _agendamentoService.getHorariosDisponiveis(
        _selectedDate,
        _servicoSelecionado,
      );

      setState(() {
        _horariosDisponiveis = horarios.cast<DateTime>();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar horários: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _carregarHorariosDisponiveis();
    }
  }

  String _formatDate(DateTime date) {
    final format = DateFormat("EEEE, dd 'de' MMMM 'de' yyyy", 'pt_BR');
    return format.format(date);
  }

  void _agendarHorario(DateTime horario) {
    Navigator.pushNamed(
      context,
      '/agendamento',
      arguments: {
        'data': _selectedDate,
        'hora': TimeOfDay.fromDateTime(horario),
        'servico': _servicoSelecionado,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horários Disponíveis'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Data
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Data'),
                      subtitle: Text(_formatDate(_selectedDate)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _selectDate,
                      ),
                    ),

                    // Serviço
                    DropdownButtonFormField<String>(
                      value: _servicoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Serviço',
                        border: OutlineInputBorder(),
                      ),
                      items: _servicos.map((String servico) {
                        return DropdownMenuItem<String>(
                          value: servico,
                          child: Text(servico),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _servicoSelecionado = newValue;
                          });
                          _carregarHorariosDisponiveis();
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Botão Atualizar
                    ElevatedButton.icon(
                      onPressed: _carregarHorariosDisponiveis,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Atualizar Horários'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Título
            Text(
              'Horários Disponíveis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de Horários
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_horariosDisponiveis.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum horário disponível',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tente selecionar outra data ou serviço',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: _horariosDisponiveis.length,
                  itemBuilder: (context, index) {
                    final horario = _horariosDisponiveis[index];
                    final timeOfDay = TimeOfDay.fromDateTime(horario);

                    return Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _agendarHorario(horario),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                timeOfDay.format(context),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Disponível',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
