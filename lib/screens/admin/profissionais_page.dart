import 'package:flutter/material.dart';
import 'package:odonto/services/admin_service.dart';

class ProfissionaisPage extends StatefulWidget {
  @override
  _ProfissionaisPageState createState() => _ProfissionaisPageState();
}

class _ProfissionaisPageState extends State<ProfissionaisPage> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _profissionais = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarProfissionais();
  }

  Future<void> _carregarProfissionais() async {
    try {
      final profissionais = await _adminService.getProfissionais();
      setState(() {
        _profissionais = profissionais;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar profissionais: $e');
      setState(() => _isLoading = false);
    }
  }

  void _adicionarProfissional() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar Profissional'),
        content: SingleChildScrollView(
          child: ProfissionalForm(
            onSave: (dados) async {
              try {
                await _adminService.adicionarProfissional(dados);
                Navigator.pop(context);
                _carregarProfissionais();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profissional adicionado com sucesso!'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao adicionar profissional: $e')),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _editarProfissional(Map<String, dynamic> profissional) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Profissional'),
        content: SingleChildScrollView(
          child: ProfissionalForm(
            profissional: profissional,
            onSave: (dados) async {
              try {
                await _adminService.atualizarProfissional(
                  profissional['id'],
                  dados,
                );
                Navigator.pop(context);
                _carregarProfissionais();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profissional atualizado com sucesso!'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao atualizar profissional: $e')),
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
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        title: Text('Gerenciar Profissionais'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _adicionarProfissional),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _profissionais.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum profissional cadastrado',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Clique no botão + para adicionar um profissional',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _carregarProfissionais,
              child: ListView.builder(
                itemCount: _profissionais.length,
                itemBuilder: (context, index) {
                  final profissional = _profissionais[index];
                  //final usuario = profissional['usuarios'] ?? {};

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          profissional['nome']?.toString().isNotEmpty == true
                              ? profissional['nome'][0].toUpperCase()
                              : 'P',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // No ListTile
                      title: Text(
                        profissional['nome'] ?? 'Profissional',
                      ), // Nome do profissional
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profissional['email'] ?? '',
                          ), // Email do profissional
                          if (profissional['especialidade'] != null)
                            Text(
                              'Especialidade: ${profissional['especialidade']}',
                              style: TextStyle(fontSize: 12),
                            ),
                          if (profissional['registro_profissional'] != null)
                            Text(
                              'Registro: ${profissional['registro_profissional']}',
                              style: TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editarProfissional(profissional),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: const Color.fromARGB(255, 89, 68, 66),
                            ),
                            onPressed: () =>
                                _removerProfissional(profissional['id']),
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

  void _removerProfissional(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Profissional'),
        content: Text('Tem certeza que deseja remover este profissional?'),
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
        await _adminService.removerProfissional(id);
        _carregarProfissionais();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profissional removido com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover profissional: $e')),
        );
      }
    }
  }
}

class ProfissionalForm extends StatefulWidget {
  final Map<String, dynamic>? profissional;
  final Function(Map<String, dynamic>) onSave;

  const ProfissionalForm({this.profissional, required this.onSave});

  @override
  _ProfissionalFormState createState() => _ProfissionalFormState();
}

class _ProfissionalFormState extends State<ProfissionalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _especialidadeController = TextEditingController();
  final _registroController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.profissional != null) {
      // Agora busca os dados diretamente da tabela profissionais
      _nomeController.text = widget.profissional!['nome'] ?? '';
      _emailController.text = widget.profissional!['email'] ?? '';
      _especialidadeController.text =
          widget.profissional!['especialidade'] ?? '';
      _registroController.text =
          widget.profissional!['registro_profissional'] ?? '';

      // Telefone pode vir da tabela usuarios se ainda quiser mostrar
      final usuario = widget.profissional!['usuarios'] ?? {};
      _telefoneController.text = usuario['telefone'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.profissional != null;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nomeController,
            decoration: InputDecoration(labelText: 'Nome completo*'),
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'E-mail*'),
            keyboardType: TextInputType.emailAddress,
            readOnly: isEdit,
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          TextFormField(
            controller: _telefoneController,
            decoration: InputDecoration(labelText: 'Telefone'),
            keyboardType: TextInputType.phone,
          ),
          TextFormField(
            controller: _especialidadeController,
            decoration: InputDecoration(labelText: 'Especialidade*'),
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          TextFormField(
            controller: _registroController,
            decoration: InputDecoration(labelText: 'Registro Profissional'),
          ),
          if (!isEdit) ...[
            SizedBox(height: 16),
            TextFormField(
              controller: _senhaController,
              decoration: InputDecoration(labelText: 'Senha temporária*'),
              obscureText: true,
              validator: (value) =>
                  value!.length < 6 ? 'Mínimo 6 caracteres' : null,
            ),
          ],
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final dados = <String, dynamic>{
                  'nome': _nomeController.text,
                  'email': _emailController.text,
                  'telefone': _telefoneController.text,
                  'especialidade': _especialidadeController.text,
                  'registro_profissional': _registroController.text,
                };
                if (!isEdit) {
                  dados['senha'] = _senhaController.text;
                }
                widget.onSave(dados);
              }
            },
            child: Text(
              isEdit ? 'Atualizar Profissional' : 'Salvar Profissional',
            ),
          ),
        ],
      ),
    );
  }
}
