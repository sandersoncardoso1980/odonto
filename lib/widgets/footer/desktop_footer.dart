// desktop_footer.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:odonto/widgets/shared/widgets.dart';
import '../shared/buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopFooter extends StatelessWidget {
  final BuildContext context;
  final Map<String, dynamic> configuracoes;

  const DesktopFooter({
    super.key,
    required this.context,
    required this.configuracoes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "RE",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "NOVA",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Odontologia",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 20),
              Text(
                "Cuidando do seu sorriso com excelência e tecnologia de ponta.",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),
              const SizedBox(height: 20),
              // ADICIONE ESTE BLOCO PARA O INSTAGRAM
              GestureDetector(
                onTap: _launchInstagram,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/instagram.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        Colors.grey.shade400,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "@renovaodontolafaiete",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                "Links Rápidos",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              FooterLink(
                text: "Início",
                onPressed: () => Navigator.pushNamed(context, '/'),
              ),
              FooterLink(
                text: "Serviços",
                onPressed: () => Navigator.pushNamed(context, '/servicos'),
              ),
              FooterLink(
                text: "Profissionais",
                onPressed: () => Navigator.pushNamed(context, '/profissionais'),
              ),
              FooterLink(
                text: "Sobre Nós",
                onPressed: () => Navigator.pushNamed(context, '/sobre'),
              ),
              FooterLink(
                text: "Contato",
                onPressed: () => Navigator.pushNamed(context, '/contato'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contato",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              FooterContact(
                icon: Icons.phone,
                text: configuracoes['footer_telefone'] ?? "(11) 9999-9999",
              ),
              FooterContact(
                icon: Icons.email,
                text: configuracoes['footer_email'] ?? "contato@renova.com",
              ),
              FooterContact(
                icon: Icons.location_on,
                text:
                    configuracoes['footer_endereco'] ??
                    "Av. Paulista, 1000\nSão Paulo - SP",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ADICIONE ESTE MÉTODO PARA ABRIR O INSTAGRAM
  void _launchInstagram() async {
    const String instagramUrl =
        "https://www.instagram.com/renovaodontolafaiete";
    // Você precisará do pacote url_launcher para isso
    // Adicione no pubspec.yaml: url_launcher: ^6.1.0
    // E importe: import 'package:url_launcher/url_launcher.dart';

    if (await canLaunchUrl(Uri.parse(instagramUrl))) {
      await launchUrl(Uri.parse(instagramUrl));
    }

    // Por enquanto, vamos usar um print para teste
    print("Abrindo Instagram: $instagramUrl");
  }
}
