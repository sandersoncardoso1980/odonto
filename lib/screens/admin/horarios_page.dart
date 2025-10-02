import 'package:flutter/material.dart';
import 'package:odonto/services/admin_service.dart';

class HorariosPage extends StatefulWidget {
  @override
  _HorariosPageState createState() => _HorariosPageState();
}

class _HorariosPageState extends State<HorariosPage> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _horarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarHorarios();
  }

  Future<void> _carregarHorarios() async {
    try {
      final horarios = await _adminService.getHorariosAtendimento();
      setState(() {
        _horarios = horarios;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar horários: $e');
      setState(() => _isLoading = false);
    }
  }

  void _adicionarHorario() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar Horário'),
        content: SingleChildScrollView(
          child: HorarioForm(
            onSave: (dados) async {
              try {
                await _adminService.adicionarHorarioAtendimento(dados);
                Navigator.pop(context);
                _carregarHorarios();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Horário adicionado com sucesso!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao adicionar horário: $e')),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _editarHorario(Map<String, dynamic> horario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Horário'),
        content: SingleChildScrollView(
          child: HorarioForm(
            horario: horario,
            onSave: (dados) async {
              try {
                await _adminService.atualizarHorarioAtendimento(
                  horario['id'],
                  dados,
                );
                Navigator.pop(context);
                _carregarHorarios();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Horário atualizado com sucesso!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao atualizar horário: $e')),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horários de Atendimento'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _adicionarHorario),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _horarios.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum horário configurado',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _carregarHorarios,
              child: ListView.builder(
                itemCount: _horarios.length,
                itemBuilder: (context, index) {
                  final horario = _horarios[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange[100],
                        child: Icon(
                          Icons.access_time,
                          color: Colors.orange[800],
                        ),
                      ),
                      title: Text(
                        '${_formatarDiaSemana(horario['dia_semana'])}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${horario['hora_inicio']} - ${horario['hora_fim']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editarHorario(horario),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerHorario(horario['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatarDiaSemana(int dia) {
    final dias = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    return dias[dia - 1];
  }

  void _removerHorario(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Horário'),
        content: Text('Tem certeza que deseja remover este horário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _adminService.removerHorarioAtendimento(id);
        _carregarHorarios();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Horário removido com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao remover horário: $e')));
      }
    }
  }
}

class HorarioForm extends StatefulWidget {
  final Map<String, dynamic>? horario;
  final Function(Map<String, dynamic>) onSave;

  const HorarioForm({this.horario, required this.onSave});

  @override
  _HorarioFormState createState() => _HorarioFormState();
}

class _HorarioFormState extends State<HorarioForm> {
  final _formKey = GlobalKey<FormState>();
  int? _diaSemana;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;

  @override
  void initState() {
    super.initState();
    if (widget.horario != null) {
      _diaSemana = widget.horario!['dia_semana'];
      _horaInicio = _parseTime(widget.horario!['hora_inicio']);
      _horaFim = _parseTime(widget.horario!['hora_fim']);
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            value: _diaSemana,
            decoration: InputDecoration(labelText: 'Dia da Semana*'),
            items: [
              DropdownMenuItem(value: 1, child: Text('Segunda-feira')),
              DropdownMenuItem(value: 2, child: Text('Terça-feira')),
              DropdownMenuItem(value: 3, child: Text('Quarta-feira')),
              DropdownMenuItem(value: 4, child: Text('Quinta-feira')),
              DropdownMenuItem(value: 5, child: Text('Sexta-feira')),
              DropdownMenuItem(value: 6, child: Text('Sábado')),
              DropdownMenuItem(value: 7, child: Text('Domingo')),
            ],
            validator: (value) => value == null ? 'Selecione um dia' : null,
            onChanged: (value) => setState(() => _diaSemana = value),
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text('Hora de Início*'),
            subtitle: Text(
              _horaInicio != null ? _formatTime(_horaInicio!) : 'Selecionar',
            ),
            trailing: Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _horaInicio ?? TimeOfDay.now(),
              );
              if (time != null) setState(() => _horaInicio = time);
            },
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text('Hora de Fim*'),
            subtitle: Text(
              _horaFim != null ? _formatTime(_horaFim!) : 'Selecionar',
            ),
            trailing: Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _horaFim ?? TimeOfDay.now(),
              );
              if (time != null) setState(() => _horaFim = time);
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate() &&
                  _diaSemana != null &&
                  _horaInicio != null &&
                  _horaFim != null) {
                final dados = <String, dynamic>{
                  'dia_semana': _diaSemana,
                  'hora_inicio': _formatTime(_horaInicio!),
                  'hora_fim': _formatTime(_horaFim!),
                };
                widget.onSave(dados);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preencha todos os campos obrigatórios'),
                  ),
                );
              }
            },
            child: Text(
              widget.horario != null ? 'Atualizar Horário' : 'Salvar Horário',
            ),
          ),
        ],
      ),
    );
  }
}
