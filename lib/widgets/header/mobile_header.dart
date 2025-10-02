import 'package:flutter/material.dart';
import 'mobile_menu.dart';

class MobileHeader extends StatelessWidget {
  final bool isSmallMobile;
  final BuildContext context;
  final bool isScrolled;

  const MobileHeader({
    super.key,
    required this.isSmallMobile,
    required this.context,
    this.isScrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/'),
          child: _buildLogo(),
        ),

        // Menu Button
        IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.grey.shade700,
            size: isSmallMobile ? 20 : 24,
          ),
          onPressed: () {
            showMobileMenu(context);
          },
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: isScrolled ? 35 : 40,
          height: isScrolled ? 35 : 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset("assets/images/logo3.png"),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "RE",
                  style: TextStyle(
                    fontSize: isScrolled ? 14 : (isSmallMobile ? 16 : 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "NOVA",
                  style: TextStyle(
                    fontSize: isScrolled ? 14 : (isSmallMobile ? 16 : 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
            Text(
              "Odonto",
              style: TextStyle(
                fontSize: isScrolled ? 8 : (isSmallMobile ? 9 : 10),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
