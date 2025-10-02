import 'package:flutter/material.dart';
import '../../widgets/agendamento_card.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    _AgendamentosPage(),
    _PerfilPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Agendamentos'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agendamentos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[600],
        onTap: _onItemTapped,
      ),
    );
  }
}

class _AgendamentosPage extends StatelessWidget {
  final List<Map<String, dynamic>> _agendamentos = [
    {
      'id': '1',
      'servico': 'Consulta Odontológica',
      'profissional': 'Dr. João Silva',
      'data': '15/12/2024',
      'hora': '14:30',
      'status': 'confirmado',
    },
    {
      'id': '2',
      'servico': 'Limpeza Dental',
      'profissional': 'Dra. Maria Santos',
      'data': '20/12/2024',
      'hora': '10:00',
      'status': 'pendente',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text(
                'Meus Agendamentos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),

        // Lista de Agendamentos
        Expanded(
          child: _agendamentos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum agendamento encontrado',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/agendamento');
                        },
                        child: Text('Fazer um agendamento'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _agendamentos.length,
                  itemBuilder: (context, index) {
                    final agendamento = _agendamentos[index];
                    return AgendamentoCard(
                      servico: agendamento['servico'],
                      profissional: agendamento['profissional'],
                      data: agendamento['data'],
                      hora: agendamento['hora'],
                      status: agendamento['status'],
                      onTap: () {
                        // Navegar para detalhes
                      },
                    );
                  },
                ),
        ),

        // Botão Novo Agendamento
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/agendamento');
            },
            icon: Icon(Icons.add),
            label: Text('Novo Agendamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PerfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do Perfil
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.blue[600],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'João da Silva',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'joao.silva@email.com',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '(11) 99999-9999',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Editar perfil
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Opções
          Text(
            'Configurações',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 16),

          _buildOptionItem(
            icon: Icons.notifications,
            title: 'Notificações',
            onTap: () {},
          ),
          _buildOptionItem(
            icon: Icons.security,
            title: 'Privacidade',
            onTap: () {},
          ),
          _buildOptionItem(icon: Icons.help, title: 'Ajuda', onTap: () {}),
          _buildOptionItem(icon: Icons.info, title: 'Sobre', onTap: () {}),

          Spacer(),

          // Botão Sair
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Sair'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[600]),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
