import 'package:flutter/material.dart';

class NewsletterSection extends StatelessWidget {
  final bool isMobile;
  final bool isSmallMobile;
  final BuildContext context;

  const NewsletterSection({
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
      child: Container(
        padding: EdgeInsets.all(
          isSmallMobile
              ? 20
              : isMobile
              ? 30
              : 60,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade300,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Fique por Dentro",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallMobile
                    ? 20
                    : isMobile
                    ? 24
                    : 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Receba dicas de saúde bucal, promoções exclusivas e novidades da clínica",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallMobile
                    ? 13
                    : isMobile
                    ? 14
                    : 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 30),
            isMobile
                ? _buildMobileNewsletterForm()
                : _buildDesktopNewsletterForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopNewsletterForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Digite seu melhor email",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Inscrever-se",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileNewsletterForm() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Digite seu melhor email",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade600,
              padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Inscrever-se",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallMobile ? 14 : 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
