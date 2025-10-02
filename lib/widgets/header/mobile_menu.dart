import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

void showMobileMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          final isAdmin = authService.userEmail == 'san@gmail.com';

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Se o usuário estiver logado, mostrar informações do usuário
              if (authService.isLoggedIn && authService.userEmail != null) ...[
                _UserInfoSection(
                  userEmail: authService.userEmail!,
                  onLogout: () {
                    Navigator.pop(context);
                    authService.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Menu Items
              _MobileMenuButton(
                text: "Início",
                icon: Icons.home,
                onPressed: () => _navigateTo(context, '/'),
              ),
              _MobileMenuButton(
                text: "Serviços",
                icon: Icons.medical_services,
                onPressed: () => _navigateTo(context, '/servicos'),
              ),
              _MobileMenuButton(
                text: "Profissionais",
                icon: Icons.people,
                onPressed: () => _navigateTo(context, '/profissionais'),
              ),
              _MobileMenuButton(
                text: "Sobre",
                icon: Icons.info,
                onPressed: () => _navigateTo(context, '/sobre'),
              ),
              _MobileMenuButton(
                text: "Contato",
                icon: Icons.contact_page,
                onPressed: () => _navigateTo(context, '/contato'),
              ),

              // Se o usuário estiver logado, mostrar opções adicionais
              if (authService.isLoggedIn) ...[
                const SizedBox(height: 8),
                _MobileMenuButton(
                  text: "Minha Conta",
                  icon: Icons.person,
                  onPressed: () => _navigateTo(context, '/perfil'),
                ),
                _MobileMenuButton(
                  text: "Meus Agendamentos",
                  icon: Icons.calendar_today,
                  onPressed: () => _navigateTo(context, '/meus-agendamentos'),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 16),

              // Se o usuário não estiver logado, mostrar botões de login/cadastro
              if (!authService.isLoggedIn) ...[
                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _navigateTo(context, '/login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.blue.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Login"),
                  ),
                ),

                const SizedBox(height: 8),

                // Cadastro Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _navigateTo(context, '/cadastro'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.green.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Cadastrar"),
                  ),
                ),

                const SizedBox(height: 8),
              ],

              // Botão principal (Administração ou Agendar Consulta)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateTo(
                    context,
                    isAdmin ? '/admin-home' : '/agendamento',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdmin
                        ? Colors.green.shade600
                        : Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(isAdmin ? "Administração" : "Agendar Consulta"),
                ),
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    ),
  );
}

void _navigateTo(BuildContext context, String route) {
  Navigator.pop(context); // Fecha o menu
  Navigator.pushNamed(context, route);
}

class _UserInfoSection extends StatelessWidget {
  final String userEmail;
  final VoidCallback onLogout;

  const _UserInfoSection({required this.userEmail, required this.onLogout});

  String _getUserName() {
    final emailParts = userEmail.split('@');
    final userName = emailParts[0];

    if (userName.isNotEmpty) {
      return userName[0].toUpperCase() + userName.substring(1);
    }

    return 'Usuário';
  }

  bool _isAdmin() {
    return userEmail == 'san@gmail.com';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              _getUserName()[0].toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getUserName(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
                if (_isAdmin())
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Administrador',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red.shade600),
            onPressed: onLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
    );
  }
}

class _MobileMenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _MobileMenuButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
