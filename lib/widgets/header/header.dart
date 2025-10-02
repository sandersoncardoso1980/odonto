import 'package:flutter/material.dart';
import 'desktop_header.dart';
import 'mobile_header.dart';

class Header extends StatelessWidget {
  final bool isMobile;
  final bool isSmallMobile;
  final BuildContext context;
  final GlobalKey sectionKey;
  final bool isScrolled;

  const Header({
    super.key,
    required this.isMobile,
    required this.isSmallMobile,
    required this.context,
    required this.sectionKey,
    this.isScrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile
            ? 12
            : isMobile
            ? 16
            : 24,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isScrolled
            ? [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: isMobile
          ? MobileHeader(
              isSmallMobile: isSmallMobile,
              context: context,
              isScrolled: isScrolled,
            )
          : DesktopHeader(context: context, isScrolled: isScrolled),
    );
  }
}
