// footer.dart
import 'package:flutter/material.dart';
import 'desktop_footer.dart';
import 'mobile_footer.dart';

class Footer extends StatelessWidget {
  final bool isMobile;
  final BuildContext context;
  final GlobalKey sectionKey;
  final Map<String, dynamic> configuracoes;

  const Footer({
    super.key,
    required this.isMobile,
    required this.context,
    required this.sectionKey,
    required this.configuracoes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 30 : 50,
        horizontal: isMobile ? 16 : 24,
      ),
      color: Colors.grey.shade900,
      child: Column(
        children: [
          isMobile
              ? MobileFooter(context: context, configuracoes: configuracoes)
              : DesktopFooter(context: context, configuracoes: configuracoes),
          const SizedBox(height: 30),
          const Divider(color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "© 2025 Renova Odontologia. Todos os direitos reservados.",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
