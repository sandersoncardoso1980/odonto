import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:odonto/screens/admin/horariosdisponiveispage.dart';
import 'package:odonto/screens/landing_page/meusagendamentos.dart';
import 'package:provider/provider.dart';
import 'package:odonto/screens/admin/admin_home.dart';
import 'package:odonto/screens/landing_page/agendamento_page.dart';
import 'package:odonto/screens/landing_page/cadastro_page.dart';
import 'package:odonto/screens/landing_page/login_page.dart';
import 'package:odonto/screens/landing_page/landing_page.dart';
import 'package:odonto/services/auth_service.dart';
import 'package:odonto/services/agendamento_service.dart';
import 'package:odonto/supabase/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        Provider(create: (context) => AgendamentoService()),
      ],
      child: MaterialApp(
        title: 'Renova Odontologia',
        theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 101, 31, 255),
          fontFamily: 'Inter',
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        initialRoute: '/',
        routes: {
          '/': (context) => const LandingPage(),
          '/servicos': (context) =>
              const LandingPage(scrollToSection: 'especialidades'),
          '/profissionais': (context) =>
              const LandingPage(scrollToSection: 'vantagens'),
          '/sobre': (context) =>
              const LandingPage(scrollToSection: 'vantagens'),
          '/contato': (context) =>
              const LandingPage(scrollToSection: 'contato'),
          '/processo': (context) =>
              const LandingPage(scrollToSection: 'processo'),
          '/agendamento': (context) => const AgendamentoPage(),
          '/login': (context) => const LoginPage(),
          '/cadastro': (context) => const CadastroPage(),
          '/admin-home': (context) => const AdminHome(),
          '/user-home': (context) => const LandingPage(),
          '/perfil': (context) => const LandingPage(),
          '/meus-agendamentos': (context) =>
              const MeusAgendamentos(), // CORRIGIDO
          '/horarios-disponiveis': (context) => const HorariosDisponiveisPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isLoggedIn) {
      if (authService.isAdmin) {
        return const AdminHome();
      } else {
        return const LandingPage();
      }
    } else {
      return const LandingPage();
    }
  }
}
