import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/xp_bar.dart';
import '../../widgets/bottom_nav_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0118), Color(0xFF2A1544)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Today\'s Quests', '4 active'),
                      const SizedBox(height: 16),
                      _buildQuestList(),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
                    ],
                  ),
                ),
                const SizedBox(height: 80), 
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF59168B).withValues(alpha: 0.4),
            const Color(0xFF312C85).withValues(alpha: 0.4),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: const Center(child: Text('👤', style: TextStyle(fontSize: 24))),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '@Username',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.shield, color: AppColors.accentGold, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Level 5',
                          style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.notifications_none, color: Color(0xFFDAB2FF)),
            ],
          ),
          const SizedBox(height: 20),
          const XPBar(
            progress: 0.84,
            label: 'XP: 420 / 500',
            trailing: '80 to Level 6',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          trailing,
          style: const TextStyle(color: AppColors.primary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildQuestList() {
    return Column(
      children: [
        _QuestCard(
          title: 'Study 2 hours',
          category: 'Study',
          timeLeft: '1h 12m left',
          xp: '+50',
          progress: 0.6,
          accentColor: AppColors.accentCyan,
        ),
        const SizedBox(height: 12),
        _QuestCard(
          title: 'Complete Workout',
          category: 'Fitness',
          timeLeft: '45m',
          xp: '+30',
          progress: 0.0,
          accentColor: AppColors.accentGreen,
        ),
        const SizedBox(height: 12),
        _QuestCard(
          title: 'Read 20 pages',
          category: 'Habit',
          timeLeft: '5 pages left',
          xp: '+25',
          progress: 0.75,
          accentColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            onTap: () => Navigator.pushNamed(context, '/study'),
            title: 'Study Together',
            subtitle: '3 friends online',
            icon: Icons.people_outline,
            gradient: [
              const Color(0xFF155DFC).withValues(alpha: 0.2),
              const Color(0xFF4F39F6).withValues(alpha: 0.2),
            ],
            borderColor: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuickActionCard(
            onTap: () => Navigator.pushNamed(context, '/rewards'),
            title: 'Rewards',
            subtitle: '5 unlocked',
            icon: Icons.card_giftcard,
            gradient: [
              const Color(0xFF9810FA).withValues(alpha: 0.2),
              const Color(0xFFE60076).withValues(alpha: 0.2),
            ],
            borderColor: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}

class _QuestCard extends StatelessWidget {
  final String title;
  final String category;
  final String timeLeft;
  final String xp;
  final double progress;
  final Color accentColor;

  const _QuestCard({
    required this.title,
    required this.category,
    required this.timeLeft,
    required this.xp,
    required this.progress,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(color: accentColor, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, color: Color(0xFFDAB2FF), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        timeLeft,
                        style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.shield, color: AppColors.accentGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    xp,
                    style: const TextStyle(color: AppColors.accentGold, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 12)),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(color: AppColors.primary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: progress > 0 ? [const Color(0xFFF0B100), const Color(0xFF00C950)] : [Colors.grey, Colors.grey],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color borderColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
