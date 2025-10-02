import 'package:flutter/material.dart';
import '../shared/cards.dart';

class SpecialtiesSection extends StatelessWidget {
  final bool isMobile;
  final GlobalKey sectionKey;

  const SpecialtiesSection({
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
      child: Column(
        children: [
          Text(
            "Nossas Especialidades",
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Cuidados completos para sua saúde bucal",
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: isMobile ? 30 : 40),
          isMobile ? _buildMobileSpecialties() : _buildDesktopSpecialties(),
        ],
      ),
    );
  }

  Widget _buildDesktopSpecialties() {
    return GridView.count(
      crossAxisCount: 6,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        CompactSpecialtyCard(
          title: "Clareamento Dental",
          icon: Icons.brightness_6,
          color: Colors.blue,
          imagePath: "assets/image1.png",
        ),
        CompactSpecialtyCard(
          title: "Ortodontia",
          icon: Icons.straighten,
          color: Colors.green,
          imagePath: "assets/image1.png",
        ),
        CompactSpecialtyCard(
          title: "Implantes",
          icon: Icons.anchor,
          color: Colors.orange,
          imagePath: "assets/image1.png",
        ),
        CompactSpecialtyCard(
          title: "Limpeza",
          icon: Icons.clean_hands,
          color: Colors.purple,
          imagePath: "assets/image1.png",
        ),
        CompactSpecialtyCard(
          title: "Próteses",
          icon: Icons.construction,
          color: Colors.red,
          imagePath: "assets/image1.png",
        ),
        CompactSpecialtyCard(
          title: "Clínica Geral",
          icon: Icons.medical_services,
          color: Colors.teal,
          imagePath: "assets/image1.png",
        ),
      ],
    );
  }

  Widget _buildMobileSpecialties() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        SpecialtyCard(
          title: "Clareamento Dental",
          icon: Icons.brightness_6,
          color: Colors.blue,
        ),
        SpecialtyCard(
          title: "Ortodontia",
          icon: Icons.straighten,
          color: Colors.green,
        ),
        SpecialtyCard(
          title: "Implantes",
          icon: Icons.anchor,
          color: Colors.orange,
        ),
        SpecialtyCard(
          title: "Limpeza",
          icon: Icons.clean_hands,
          color: Colors.purple,
        ),
        SpecialtyCard(
          title: "Próteses",
          icon: Icons.construction,
          color: Colors.red,
        ),
        SpecialtyCard(
          title: "Clínica Geral",
          icon: Icons.medical_services,
          color: Colors.teal,
        ),
      ],
    );
  }
}
