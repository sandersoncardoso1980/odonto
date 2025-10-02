import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class DesktopHeader extends StatelessWidget {
  final BuildContext context;
  final bool isScrolled;

  const DesktopHeader({
    super.key,
    required this.context,
    this.isScrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            _buildLogo(),

            // Navigation Menu
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Menu de Navegação Principal - só aparece em telas largas
                  if (MediaQuery.of(context).size.width > 900)
                    Row(
                      children: [
                        _NavButton(
                          text: "Início",
                          route: '/',
                          context: context,
                        ),
                        _NavButton(
                          text: "Serviços",
                          route: '/servicos',
                          context: context,
                        ),
                        _NavButton(
                          text: "Sobre",
                          route: '/sobre',
                          context: context,
                        ),
                        _NavButton(
                          text: "Contato",
                          route: '/contato',
                          context: context,
                        ),
                      ],
                    ),

                  if (MediaQuery.of(context).size.width > 900)
                    const SizedBox(width: 16),

                  // Área do Usuário e Agendamento
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Exibir nome do usuário se estiver logado, caso contrário botão Login
                      if (authService.isLoggedIn &&
                          authService.userEmail != null)
                        _UserMenu(
                          userUid: authService.currentUser!.id,
                          userEmail: authService.userEmail!,
                          context: context,
                        )
                      else
                        _NavButton(
                          text: "Login",
                          route: '/login',
                          context: context,
                          isSecondary: true,
                        ),

                      const SizedBox(width: 8),

                      _AdminOrAgendarButton(
                        context: context,
                        isScrolled: isScrolled,
                        authService: authService,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogo() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isScrolled ? 40 : 50,
            height: isScrolled ? 40 : 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset("assets/images/logo3.png"),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "RE",
                    style: TextStyle(
                      fontSize: isScrolled ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "NOVA",
                    style: TextStyle(
                      fontSize: isScrolled ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
              Text(
                "Odontologia",
                style: TextStyle(
                  fontSize: isScrolled ? 8 : 9,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String text;
  final String route;
  final BuildContext context;
  final bool isSecondary;

  const _NavButton({
    required this.text,
    required this.route,
    required this.context,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: TextButton.styleFrom(
          foregroundColor: isSecondary
              ? Colors.blue.shade600
              : Colors.grey.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSecondary ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _UserMenu extends StatefulWidget {
  final String userUid;
  final String userEmail;
  final BuildContext context;

  const _UserMenu({
    required this.userUid,
    required this.userEmail,
    required this.context,
  });

  @override
  State<_UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends State<_UserMenu> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String? _userName;
  bool _isLoading = true;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _userService.getUserData(widget.userUid);
      setState(() {
        _userName = userData?['nome'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao buscar dados do usuário: $e');
      setState(() {
        _userName = _getUserNameFromEmail();
        _isLoading = false;
      });
    }
  }

  String _getUserNameFromEmail() {
    final emailParts = widget.userEmail.split('@');
    final userName = emailParts[0];

    if (userName.isNotEmpty) {
      return userName[0].toUpperCase() + userName.substring(1);
    }

    return 'Usuário';
  }

  String _getDisplayName() {
    if (_isLoading) {
      return 'Carregando...';
    }
    return _userName ?? _getUserNameFromEmail();
  }

  String _getShortName() {
    final displayName = _getDisplayName();
    if (displayName == 'Carregando...') {
      return '...';
    }

    final names = displayName.split(' ');
    if (names.isNotEmpty && displayName.length > 10) {
      return names[0];
    }

    return displayName;
  }

  String _getInitial() {
    final displayName = _getDisplayName();
    if (displayName == 'Carregando...') {
      return '...';
    }
    return displayName[0].toUpperCase();
  }

  bool _isAdmin() {
    return widget.userEmail == 'san@gmail.com';
  }

  void _toggleMenu() {
    if (_overlayEntry == null) {
      _showMenu();
    } else {
      _hideMenu();
    }
  }

  void _showMenu() {
    if (_overlayEntry != null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(widget.context).insert(_overlayEntry!);
    setState(() {});
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {});
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _logout() {
    _hideMenu();
    final authService = Provider.of<AuthService>(widget.context, listen: false);
    authService.signOut();
    Navigator.pushNamedAndRemoveUntil(widget.context, '/', (route) => false);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _hideMenu,
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: Colors.transparent,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 45),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header do usuário
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getDisplayName(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.userEmail,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_isAdmin())
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Administrador',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Itens do menu
                    _UserMenuItem(
                      text: "Minha Conta",
                      icon: Icons.person,
                      onPressed: () {
                        _hideMenu();
                        Navigator.pushNamed(widget.context, '/perfil');
                      },
                    ),

                    _UserMenuItem(
                      text: "Meus Agendamentos",
                      icon: Icons.calendar_today,
                      onPressed: () {
                        _hideMenu();
                        Navigator.pushNamed(
                          widget.context,
                          '/meus-agendamentos',
                        );
                      },
                    ),

                    // Divisor
                    Container(height: 1, color: Colors.grey.shade200),

                    // Logout
                    _UserMenuItem(
                      text: "Sair",
                      icon: Icons.logout,
                      onPressed: _logout,
                      isLogout: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: _overlayEntry != null
                ? Colors.grey.shade50
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Text(
                  _getInitial(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (screenWidth > 600) ...[
                const SizedBox(width: 6),
                SizedBox(
                  width: 70,
                  child: Text(
                    _getShortName(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 65, 65, 65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                _overlayEntry != null
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserMenuItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLogout;

  const _UserMenuItem({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isLogout ? Colors.red.shade600 : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLogout
                        ? Colors.red.shade600
                        : Colors.grey.shade700,
                    fontWeight: isLogout ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminOrAgendarButton extends StatelessWidget {
  final BuildContext context;
  final bool isScrolled;
  final AuthService authService;

  const _AdminOrAgendarButton({
    required this.context,
    required this.isScrolled,
    required this.authService,
  });

  bool _isAdmin() {
    return authService.userEmail == 'san@gmail.com';
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _isAdmin();
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(
        context,
        isAdmin ? '/admin-home' : '/agendamento',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isAdmin ? Colors.green.shade600 : Colors.blue.shade600,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth > 600 ? 16 : 12,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        isAdmin
            ? (screenWidth > 600 ? "Administração" : "Admin")
            : (screenWidth > 600 ? "Agendar Consulta" : "Agendar"),
        style: TextStyle(
          fontSize: screenWidth > 600 ? 13 : 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
