import 'package:flutter/material.dart';

class ServicesDropdown extends StatefulWidget {
  const ServicesDropdown({super.key});

  @override
  State<ServicesDropdown> createState() => _ServicesDropdownState();
}

class _ServicesDropdownState extends State<ServicesDropdown> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        children: [
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Row(
              children: [
                Text(
                  "Serviços",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  _isHovered ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_isHovered)
            Positioned(
              top: 40,
              left: 0,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DropdownItem(text: "Clareamento Dental"),
                    _DropdownItem(text: "Ortodontia"),
                    _DropdownItem(text: "Implantes Dentários"),
                    _DropdownItem(text: "Limpeza Profissional"),
                    _DropdownItem(text: "Próteses"),
                    _DropdownItem(text: "Clínica Geral"),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  final String text;

  const _DropdownItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
        ),
        child: Text(text),
      ),
    );
  }
}
