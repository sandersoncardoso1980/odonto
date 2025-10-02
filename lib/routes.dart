import 'package:flutter/material.dart';
import 'screens/landing_page/landing_page.dart';
import 'screens/landing_page/cadastro_page.dart';
import 'screens/landing_page/login_page.dart';
import 'screens/landing_page/agendamento_page.dart';
import 'screens/user_dashboard/user_home.dart';
import 'screens/admin/admin_home.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LandingPage());
      case '/cadastro':
        return MaterialPageRoute(builder: (_) => CadastroPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/agendamento':
        return MaterialPageRoute(builder: (_) => AgendamentoPage());
      case '/user-home':
        return MaterialPageRoute(builder: (_) => UserHome());
      case '/admin-home':
        return MaterialPageRoute(builder: (_) => AdminHome());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: Text('Erro')),
          body: Center(child: Text('Página não encontrada!')),
        );
      },
    );
  }
}
