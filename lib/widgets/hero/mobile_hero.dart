import 'package:flutter/material.dart';
import '../shared/widgets.dart';

class MobileHero extends StatelessWidget {
  final bool isSmallMobile;
  final BuildContext context;

  const MobileHero({
    super.key,
    required this.isSmallMobile,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: isSmallMobile ? 250 : 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            image: const DecorationImage(
              image: AssetImage("assets/images/image.png"),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Text(
            "👑 Clínica Premium",
            style: TextStyle(
              fontSize: isSmallMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Seu sorriso perfeito começa aqui",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallMobile ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Oferecemos tratamentos odontológicos de excelência com tecnologia de ponta e profissionais qualificados.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallMobile ? 14 : 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildHeroButtons(context),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            HeroFeature(
              icon: Icons.verified_user,
              text: "Profissionais Certificados",
            ),
            HeroFeature(icon: Icons.emergency, text: "Atendimento 24h"),
            HeroFeature(icon: Icons.payment, text: "Planos Flexíveis"),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/agendamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isSmallMobile ? 12 : 14,
                horizontal: isSmallMobile ? 12 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Agendar Consulta",
                style: TextStyle(
                  fontSize: isSmallMobile ? 13 : 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/servicos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade600,
              side: BorderSide(color: Colors.blue.shade600),
              padding: EdgeInsets.symmetric(
                vertical: isSmallMobile ? 12 : 14,
                horizontal: isSmallMobile ? 12 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Conhecer Serviços",
                style: TextStyle(fontSize: isSmallMobile ? 13 : 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
