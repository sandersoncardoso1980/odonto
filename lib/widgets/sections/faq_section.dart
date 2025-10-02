import 'package:flutter/material.dart';
import '../shared/cards.dart';

class FAQSection extends StatelessWidget {
  final bool isMobile;
  final GlobalKey sectionKey;

  const FAQSection({
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
            "Perguntas Frequentes",
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: isMobile ? 30 : 60),
          Column(
            children: const [
              FAQItem(
                question: "Como agendar uma consulta?",
                answer:
                    "Você pode agendar através do nosso site, aplicativo ou telefone. Oferecemos agendamento online 24 horas por dia.",
              ),
              FAQItem(
                question: "Aceitam quais planos odontológicos?",
                answer:
                    "Aceitamos a maioria dos planos odontológicos do mercado. Entre em contato para confirmar a cobertura do seu plano.",
              ),
              FAQItem(
                question: "Oferecem tratamento para crianças?",
                answer:
                    "Sim! Temos odontopediatras especializados no atendimento infantil, com ambiente adequado e abordagem lúdica.",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
