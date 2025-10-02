// mobile_footer.dart
import 'package:flutter/material.dart';
import 'package:odonto/widgets/shared/widgets.dart';
import '../shared/buttons.dart';

class MobileFooter extends StatelessWidget {
  final BuildContext context;
  final Map<String, dynamic> configuracoes;

  const MobileFooter({
    super.key,
    required this.context,
    required this.configuracoes, // Adicione este parâmetro
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "RE",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "NOVA",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade400,
                  ),
                ),
              ],
            ),
            Text(
              "Odontologia",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            Text(
              "Cuidando do seu sorriso com excelência e tecnologia.",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Links Rápidos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
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
                  onPressed: () =>
                      Navigator.pushNamed(context, '/profissionais'),
                ),
                FooterLink(
                  text: "Sobre",
                  onPressed: () => Navigator.pushNamed(context, '/sobre'),
                ),
                FooterLink(
                  text: "Contato",
                  onPressed: () => Navigator.pushNamed(context, '/contato'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Contato",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
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
                  configuracoes['footer_endereco'] ?? "Av. Paulista, 1000 - SP",
            ),
          ],
        ),
      ],
    );
  }
}
