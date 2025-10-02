import 'package:flutter/material.dart';
import 'desktop_hero.dart';
import 'mobile_hero.dart';

class HeroSection extends StatelessWidget {
  final bool isMobile;
  final bool isSmallMobile;
  final BuildContext context;

  const HeroSection({
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
        vertical: isMobile ? 20 : 35,
        horizontal: isSmallMobile
            ? 12
            : isMobile
            ? 16
            : 24,
      ),
      child: isMobile
          ? MobileHero(isSmallMobile: isSmallMobile, context: context)
          : DesktopHero(context: context),
    );
  }
}
