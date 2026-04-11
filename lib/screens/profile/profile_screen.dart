import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

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
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong. Please try again later.',
                      style: TextStyle(color: Colors.white)),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF9810FA)),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text('User profile not found.',
                      style: TextStyle(color: Colors.white)),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildProfileInfo(context, userData),
                          const SizedBox(height: 32),
                          _buildStatsGrid(userData),
                          const SizedBox(height: 32),
                          _buildRecentBadges(),
                          const SizedBox(height: 32),
                          _buildSettingsSection(context),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF59168B).withOpacity(0.4),
            const Color(0xFF312C85).withOpacity(0.4),
          ],
        ),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Evolvix',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/notifications'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF59168B).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child:
                  const Icon(Icons.notifications_none, color: Color(0xFFDAB2FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, Map<String, dynamic> userData) {
    final String name = userData['username'] ?? userData['name'] ?? 'Adventurer';
    final String email = userData['email'] ?? 'No email available';
    final int level = userData['level'] ?? 1;
    final Timestamp? joinedAt = userData['createdAt'] as Timestamp?;
    final String joinedDate = joinedAt != null
        ? DateFormat('MMMM yyyy').format(joinedAt.toDate()).toUpperCase()
        : 'MARCH 2024';

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF9810FA), Color(0xFF4F39F6)]),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.1), width: 4),
              ),
              alignment: Alignment.center,
              child: const Text('👤', style: TextStyle(fontSize: 48)),
            ),
            Transform.translate(
              offset: const Offset(0, 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF05DF72), Color(0xFF00D492)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1A0F2E), width: 4),
                ),
                child: Text('LVL $level',
                    style: const TextStyle(
                        color: Color(0xFF101828), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(name,
            style: const TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        Text(email,
            style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFFC27AFF), size: 16),
            const SizedBox(width: 8),
            Text('JOINED $joinedDate',
                style: const TextStyle(
                    color: Color(0xFFC27AFF), fontSize: 14, letterSpacing: 0.7)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildProfileButton('Edit Profile',
                  () => Navigator.pushNamed(context, '/edit-profile')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProfileButton('View Analytics',
                  () => Navigator.pushNamed(context, '/performance')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildProfileButton(
            'View Leaderboard', () => Navigator.pushNamed(context, '/leaderboard'),
            isPrimary: true),
      ],
    );
  }

  Widget _buildProfileButton(String label, VoidCallback onPressed,
      {bool isPrimary = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        shadowColor: isPrimary ? const Color(0x809810FA) : Colors.transparent,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(colors: [Color(0xFF9810FA), Color(0xFF4F39F6)])
              : LinearGradient(colors: [
                  const Color(0xFF9810FA).withOpacity(0.3),
                  const Color(0xFF4F39F6).withOpacity(0.3)
                ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFAD46FF).withOpacity(0.3)),
        ),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> userData) {
    final String tasksCompleted = (userData['tasksCompleted'] ?? 0).toString();
    final String levelsUnlocked = (userData['level'] ?? 1).toString();
    final String xpEarned = (userData['xp'] ?? 0).toString();
    final String streak = (userData['streak'] ?? 0).toString();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildStatCard(tasksCompleted, 'Tasks Completed', const Color(0xFFC27AFF),
            Icons.check_circle_outline),
        _buildStatCard(levelsUnlocked, 'Levels Unlocked', const Color(0xFF51A2FF),
            Icons.trending_up),
        _buildStatCard(xpEarned, 'XP Earned', const Color(0xFF05DF72),
            Icons.monetization_on_outlined),
        _buildStatCard(streak, 'Productivity Streak', const Color(0xFFFF6467),
            Icons.local_fire_department_outlined),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          FittedBox(
            child: Text(value,
                style: TextStyle(
                    color: color, fontSize: 28, fontWeight: FontWeight.bold)),
          ),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFDAB2FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildRecentBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Badges',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildBadgeRow('Early Adopter', 'Joined Beta Season 1', Icons.verified_user,
            const Color(0xFF51A2FF)),
        const SizedBox(height: 12),
        _buildBadgeRow('Light Speed', 'Completed 10 tasks in 1 hour', Icons.bolt,
            const Color(0xFFC27AFF)),
        const SizedBox(height: 12),
        _buildBadgeRow('Night Owl', 'Unlocked | not yet earned',
            Icons.nights_stay, const Color(0xFF6A7282)),
      ],
    );
  }

  Widget _buildBadgeRow(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFAD46FF).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: const Color(0xFF59168B).withOpacity(0.3),
                shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFFDAB2FF), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      children: [
        _buildProfileButton('Settings',
            () => Navigator.pushNamed(context, '/settings'),
            isPrimary: false),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFF59168B).withOpacity(0.3),
              const Color(0xFF312C85).withOpacity(0.3)
            ]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFAD46FF).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Text('Version 2.4.1 Build Release',
                  style: TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7000B).withOpacity(0.2),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Color(0xFFFB2C36), width: 1),
                ),
                child: const Text('Logout',
                    style: TextStyle(
                        color: Color(0xFFFF6467),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
