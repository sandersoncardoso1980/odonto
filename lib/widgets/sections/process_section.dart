import 'package:flutter/material.dart';
import '../shared/cards.dart';

class ProcessSection extends StatelessWidget {
  final bool isMobile;

  const ProcessSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 24,
      ),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text(
            "Como Funciona",
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Três passos simples para o seu sorriso perfeito",
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: isMobile ? 40 : 60),
          isMobile ? _buildMobileProcess() : _buildDesktopProcess(),
        ],
      ),
    );
  }

  Widget _buildDesktopProcess() {
    return Row(
      children: const [
        Expanded(
          child: ProcessStep(
            number: "1",
            title: "Agendamento",
            description:
                "Escolha o melhor horário para sua consulta através do nosso sistema online",
            icon: Icons.calendar_today,
          ),
        ),
        SizedBox(width: 40),
        Expanded(
          child: ProcessStep(
            number: "2",
            title: "Consulta",
            description:
                "Atendimento personalizado com diagnóstico completo e plano de tratamento",
            icon: Icons.medical_services,
          ),
        ),
        SizedBox(width: 40),
        Expanded(
          child: ProcessStep(
            number: "3",
            title: "Resultado",
            description:
                "Sorriso transformado com acompanhamento contínuo e garantia de qualidade",
            icon: Icons.emoji_emotions,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileProcess() {
    return Column(
      children: const [
        ProcessStep(
          number: "1",
          title: "Agendamento",
          description: "Escolha o melhor horário para sua consulta",
          icon: Icons.calendar_today,
        ),
        SizedBox(height: 40),
        ProcessStep(
          number: "2",
          title: "Consulta",
          description: "Atendimento personalizado com diagnóstico completo",
          icon: Icons.medical_services,
        ),
        SizedBox(height: 40),
        ProcessStep(
          number: "3",
          title: "Resultado",
          description: "Sorriso transformado com acompanhamento",
          icon: Icons.emoji_emotions,
        ),
      ],
    );
  }
}
