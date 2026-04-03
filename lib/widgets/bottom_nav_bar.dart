import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F2E),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, 'Home', currentIndex == 0, '/dashboard'),
          _buildNavItem(context, Icons.assignment_outlined, 'Tasks', currentIndex == 1, '/tasks'),
          _buildNavItem(context, Icons.group_outlined, 'Study', currentIndex == 2, '/study'),
          _buildNavItem(context, Icons.emoji_events_outlined, 'Rewards', currentIndex == 3, '/rewards'),
          _buildNavItem(context, Icons.person_outline, 'Profile', currentIndex == 4, '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, String route) {
    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isActive)
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          const SizedBox(height: 4),
          Icon(icon, color: isActive ? AppColors.primary : Colors.white24),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.white24,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
