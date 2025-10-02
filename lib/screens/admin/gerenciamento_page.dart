import 'package:flutter/material.dart';
import 'profissionais_page.dart';
import 'servicos_page.dart';
import 'horarios_page.dart';
//import 'configuracoes_page.dart';

class GerenciamentoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gerenciamento',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          _buildManagementOption(
            icon: Icons.people,
            title: 'Profissionais',
            subtitle: 'Gerenciar equipe médica',
            onTap: () => _navigateToProfissionais(context),
          ),
          _buildManagementOption(
            icon: Icons.medical_services,
            title: 'Serviços',
            subtitle: 'Gerenciar serviços oferecidos',
            onTap: () => _navigateToServicos(context),
          ),
          _buildManagementOption(
            icon: Icons.access_time,
            title: 'Horários',
            subtitle: 'Configurar horários de atendimento',
            onTap: () => _navigateToHorarios(context),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[600], size: 32),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _navigateToProfissionais(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfissionaisPage()),
    );
  }

  void _navigateToServicos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ServicosPage()),
    );
  }

  void _navigateToHorarios(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HorariosPage()),
    );
  }
}
