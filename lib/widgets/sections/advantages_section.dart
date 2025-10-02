import 'package:flutter/material.dart';
import '../shared/cards.dart';

class AdvantagesSection extends StatelessWidget {
  final bool isMobile;
  final GlobalKey sectionKey;

  const AdvantagesSection({
    super.key,
    required this.isMobile,
    required this.sectionKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      // ... resto do código
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 24,
      ),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text(
            "Por que escolher a Renova?",
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: isMobile ? 30 : 60),
          isMobile ? _buildMobileAdvantages() : _buildDesktopAdvantages(),
        ],
      ),
    );
  }

  Widget _buildDesktopAdvantages() {
    return Row(
      children: const [
        Expanded(
          child: AdvantageCard(
            icon: Icons.medical_services,
            title: "Equipe Qualificada",
            description:
                "Profissionais especializados e constantemente atualizados com as mais recentes técnicas odontológicas",
          ),
        ),
        SizedBox(width: 30),
        Expanded(
          child: AdvantageCard(
            icon: Icons.health_and_safety,
            title: "Tecnologia Avançada",
            description:
                "Utilizamos equipamentos de última geração para diagnósticos precisos e tratamentos eficazes",
          ),
        ),
        SizedBox(width: 30),
        Expanded(
          child: AdvantageCard(
            icon: Icons.emergency,
            title: "Atendimento 24h",
            description:
                "Estamos disponíveis para emergências odontológicas a qualquer hora do dia ou noite",
          ),
        ),
      ],
    );
  }

  Widget _buildMobileAdvantages() {
    return Column(
      children: const [
        AdvantageCard(
          icon: Icons.medical_services,
          title: "Equipe Qualificada",
          description:
              "Profissionais especializados e constantemente atualizados",
        ),
        SizedBox(height: 20),
        AdvantageCard(
          icon: Icons.health_and_safety,
          title: "Tecnologia Avançada",
          description:
              "Equipamentos de última geração para diagnósticos precisos",
        ),
        SizedBox(height: 20),
        AdvantageCard(
          icon: Icons.emergency,
          title: "Atendimento 24h",
          description: "Disponíveis para emergências a qualquer hora",
        ),
      ],
    );
  }
}
