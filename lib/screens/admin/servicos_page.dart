import 'package:flutter/material.dart';
import 'package:odonto/services/admin_service.dart';

class ServicosPage extends StatefulWidget {
  @override
  _ServicosPageState createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _servicos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    try {
      final servicos = await _adminService.getServicos();
      setState(() {
        _servicos = servicos;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar serviços: $e');
      setState(() => _isLoading = false);
    }
  }

  void _adicionarServico() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar Serviço'),
        content: SingleChildScrollView(
          child: ServicoForm(
            onSave: (dados) async {
              try {
                await _adminService.adicionarServico(dados);
                Navigator.pop(context);
                _carregarServicos();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Serviço adicionado com sucesso!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao adicionar serviço: $e')),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _editarServico(Map<String, dynamic> servico) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Serviço'),
        content: SingleChildScrollView(
          child: ServicoForm(
            servico: servico,
            onSave: (dados) async {
              try {
                await _adminService.atualizarServico(servico['id'], dados);
                Navigator.pop(context);
                _carregarServicos();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Serviço atualizado com sucesso!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao atualizar serviço: $e')),
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
        title: Text('Gerenciar Serviços'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _adicionarServico),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _servicos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum serviço cadastrado',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _carregarServicos,
              child: ListView.builder(
                itemCount: _servicos.length,
                itemBuilder: (context, index) {
                  final servico = _servicos[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Icon(
                          Icons.medical_services,
                          color: Colors.green[800],
                        ),
                      ),
                      title: Text(servico['nome']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (servico['descricao'] != null)
                            Text(servico['descricao']),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text('Duração: ${servico['duracao_minutos']}min'),
                              SizedBox(width: 16),
                              if (servico['preco'] != null)
                                Text('R\$${servico['preco']}'),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editarServico(servico),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerServico(servico['id']),
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

  void _removerServico(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Serviço'),
        content: Text('Tem certeza que deseja remover este serviço?'),
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
        await _adminService.removerServico(id);
        _carregarServicos();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Serviço removido com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao remover serviço: $e')));
      }
    }
  }
}

class ServicoForm extends StatefulWidget {
  final Map<String, dynamic>? servico;
  final Function(Map<String, dynamic>) onSave;

  const ServicoForm({this.servico, required this.onSave});

  @override
  _ServicoFormState createState() => _ServicoFormState();
}

class _ServicoFormState extends State<ServicoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _duracaoController = TextEditingController();
  final _precoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.servico != null) {
      _nomeController.text = widget.servico!['nome'] ?? '';
      _descricaoController.text = widget.servico!['descricao'] ?? '';
      _duracaoController.text =
          widget.servico!['duracao_minutos']?.toString() ?? '';
      _precoController.text = widget.servico!['preco']?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nomeController,
            decoration: InputDecoration(labelText: 'Nome do Serviço*'),
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          TextFormField(
            controller: _descricaoController,
            decoration: InputDecoration(labelText: 'Descrição'),
            maxLines: 3,
          ),
          TextFormField(
            controller: _duracaoController,
            decoration: InputDecoration(labelText: 'Duração (minutos)*'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          TextFormField(
            controller: _precoController,
            decoration: InputDecoration(labelText: 'Preço (R\$)'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final dados = <String, dynamic>{
                  'nome': _nomeController.text,
                  'descricao': _descricaoController.text,
                  'duracao_minutos': int.parse(_duracaoController.text),
                  'preco': _precoController.text.isNotEmpty
                      ? double.parse(_precoController.text)
                      : null,
                };
                widget.onSave(dados);
              }
            },
            child: Text(
              widget.servico != null ? 'Atualizar Serviço' : 'Salvar Serviço',
            ),
          ),
        ],
      ),
    );
  }
}
