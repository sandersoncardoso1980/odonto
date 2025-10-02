import 'package:flutter/material.dart';

class CTASection extends StatelessWidget {
  final bool isMobile;
  final bool isSmallMobile;
  final BuildContext context;

  const CTASection({
    super.key,
    required this.isMobile,
    required this.isSmallMobile,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isSmallMobile
            ? 12
            : isMobile
            ? 16
            : 24,
      ),
      child: Column(
        children: [
          Text(
            "Pronto para transformar seu sorriso?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallMobile
                  ? 20
                  : isMobile
                  ? 24
                  : 36,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Agende sua avaliação gratuita e dê o primeiro passo para um sorriso saudável",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallMobile
                  ? 13
                  : isMobile
                  ? 14
                  : 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),
          isMobile ? _buildMobileCTAButtons() : _buildDesktopCTAButtons(),
        ],
      ),
    );
  }

  Widget _buildDesktopCTAButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/agendamento'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Agendar Avaliação Grátis",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 20),
        OutlinedButton(
          onPressed: () => Navigator.pushNamed(context, '/contato'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue.shade600,
            side: BorderSide(color: Colors.blue.shade600),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Falar com Especialista",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCTAButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/agendamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Agendar Avaliação Grátis",
              style: TextStyle(
                fontSize: isSmallMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/contato'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade600,
              side: BorderSide(color: Colors.blue.shade600),
              padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Falar com Especialista",
              style: TextStyle(
                fontSize: isSmallMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
