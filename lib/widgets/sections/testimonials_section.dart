import 'package:flutter/material.dart';
import '../shared/cards.dart';

class TestimonialsSection extends StatelessWidget {
  final bool isMobile;
  final GlobalKey sectionKey;

  const TestimonialsSection({
    super.key,
    required this.isMobile,
    required this.sectionKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 24,
      ),
      child: Column(
        children: [
          Text(
            "O que nossos pacientes dizem",
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: isMobile ? 30 : 60),
          isMobile ? _buildMobileTestimonials() : _buildDesktopTestimonials(),
        ],
      ),
    );
  }

  Widget _buildDesktopTestimonials() {
    return Row(
      children: const [
        Expanded(
          child: TestimonialCard(
            text:
                "Atendimento excepcional! A equipe é muito qualificada e o tratamento superou minhas expectativas. Recomendo!",
            author: "Maria Silva",
            rating: 5,
            profession: "Arquiteta",
          ),
        ),
        SizedBox(width: 30),
        Expanded(
          child: TestimonialCard(
            text:
                "Finalmente encontrei uma clínica que entende minhas necessidades. O plano de tratamento foi perfeito para mim.",
            author: "João Santos",
            rating: 5,
            profession: "Engenheiro",
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTestimonials() {
    return Column(
      children: const [
        TestimonialCard(
          text:
              "Atendimento excepcional! A equipe é muito qualificada e o tratamento superou minhas expectativas. Recomendo!",
          author: "Maria Silva",
          rating: 5,
          profession: "Arquiteta",
        ),
        SizedBox(height: 20),
        TestimonialCard(
          text:
              "Finalmente encontrei uma clínica que entende minhas necessidades. O plano de tratamento foi perfeito para mim.",
          author: "João Santos",
          rating: 5,
          profession: "Engenheiro",
        ),
      ],
    );
  }
}
