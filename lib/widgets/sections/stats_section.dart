import 'package:flutter/material.dart';
import '../shared/cards.dart';

class StatsSection extends StatelessWidget {
  final bool isMobile;

  const StatsSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 60,
        horizontal: isMobile ? 16 : 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: isMobile ? _buildMobileStats() : _buildDesktopStats(),
    );
  }

  Widget _buildDesktopStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        StatCard(number: "5.000+", label: "Pacientes Satisfeitos"),
        StatCard(number: "15+", label: "Anos de Experiência"),
        StatCard(number: "50+", label: "Profissionais"),
        StatCard(number: "98%", label: "Avaliação Positiva"),
      ],
    );
  }

  Widget _buildMobileStats() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            StatCard(number: "5.000+", label: "Pacientes"),
            StatCard(number: "15+", label: "Anos Exp."),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            StatCard(number: "50+", label: "Profissionais"),
            StatCard(number: "98%", label: "Avaliação"),
          ],
        ),
      ],
    );
  }
}
