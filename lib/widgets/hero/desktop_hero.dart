import 'package:flutter/material.dart';
import '../shared/widgets.dart';

class DesktopHero extends StatelessWidget {
  final BuildContext context;

  const DesktopHero({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1000;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      "👑 Clínica Premium",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Seu sorriso perfeito começa aqui",
                    style: TextStyle(
                      fontSize: isCompact ? 36 : 48, // Responsivo
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Oferecemos tratamentos odontológicos de excelência com tecnologia de ponta e profissionais altamente qualificados. Sua saúde bucal em boas mãos.",
                    style: TextStyle(
                      fontSize: isCompact ? 16 : 18, // Responsivo
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildHeroButtons(context),
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      HeroFeature(
                        icon: Icons.verified_user,
                        text: "Profissionais certificados",
                      ),
                      HeroFeature(
                        icon: Icons.emergency,
                        text: "Atendimento 24h",
                      ),
                      HeroFeature(
                        icon: Icons.payment,
                        text: "Planos Flexíveis",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isCompact) const SizedBox(width: 40),
            if (!isCompact)
              Expanded(
                child: Container(
                  height: 500, // Reduzido
                  width: 260,
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    image: const DecorationImage(
                      image: AssetImage("assets/images/image.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeroButtons(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/agendamento'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Agendar Consulta",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pushNamed(context, '/servicos'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue.shade600,
            side: BorderSide(color: Colors.blue.shade600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Conhecer Serviços",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
