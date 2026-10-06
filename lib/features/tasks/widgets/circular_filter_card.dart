import 'package:flutter/material.dart';

class CircularFilterCard extends StatelessWidget {
  final String filterKey;
  final String label;
  final IconData icon;
  final Color activeColor;
  final Color bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const CircularFilterCard({
    super.key,
    required this.filterKey,
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Outer Circular Card Container (Compact & Clean)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? activeColor : Colors.white,
              border: Border.all(
                color: isSelected ? activeColor : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? activeColor.withOpacity(0.25)
                      : const Color(0xFF0F172A).withOpacity(0.02),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.white.withOpacity(0.25) : bgColor,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : activeColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          // Filter Label (Compact 11px)
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? activeColor : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
