import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

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
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Special Badges',
                        style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      _buildSpecialBadges(),
                      const SizedBox(height: 24),
                      const Text(
                        'All Rankings',
                        style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      _buildRankingsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF59168B).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Icon(Icons.chevron_left, color: Color(0xFFDAB2FF)),
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Leaderboard', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  Text('Compete with friends', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.emoji_events, color: Color(0xFFFDC700), size: 32),
            ],
          ),
          const SizedBox(height: 32),
          _buildPodium(),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumItem('Alex', 'Level 11', '3200 XP', '👨', 2, 80, const Color(0xFF99A1AF)),
        const SizedBox(width: 16),
        _buildPodiumItem('Sarah', 'Level 12', '3450 XP', '👩', 1, 100, const Color(0xFFFDC700)),
        const SizedBox(width: 16),
        _buildPodiumItem('Emma', 'Level 10', '2980 XP', '👩‍🎓', 3, 60, const Color(0xFFF54900)),
      ],
    );
  }

  Widget _buildPodiumItem(String name, String level, String xp, String emoji, int rank, double height, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: rank == 1 ? 80 : 64,
              height: rank == 1 ? 80 : 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: TextStyle(fontSize: rank == 1 ? 30 : 24)),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1A0F2E))),
              alignment: Alignment.center,
              child: Text('$rank', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color, color.withValues(alpha: 0.3)]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(level, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(xp, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBadgeCard('Top Learner', Icons.school, const Color(0xFFFDC700)),
        _buildBadgeCard('Streak Master', Icons.local_fire_department, const Color(0xFFFF8904)),
        _buildBadgeCard('Focus Champion', Icons.timer, const Color(0xFF51A2FF)),
      ],
    );
  }

  Widget _buildBadgeCard(String label, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF59168B).withValues(alpha: 0.3), const Color(0xFF312C85).withValues(alpha: 0.3)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRankingsList() {
    final rankings = [
      {'name': 'Sarah Chen', 'level': 'Level 12', 'xp': '3450', 'rank': 1, 'emoji': '👩', 'badge': 'Top Learner'},
      {'name': 'Alex Johnson', 'level': 'Level 11', 'xp': '3200', 'rank': 2, 'emoji': '👨', 'badge': 'Streak Master'},
      {'name': 'Emma Wilson', 'level': 'Level 10', 'xp': '2980', 'rank': 3, 'emoji': '👩‍🎓', 'badge': 'Focus Champion'},
      {'name': 'Mike Davis', 'level': 'Level 9', 'xp': '2650', 'rank': 4, 'emoji': '👨‍💼', 'badge': null},
      {'name': 'QuestMaster (You)', 'level': 'Level 5', 'xp': '1420', 'rank': 5, 'emoji': '👤', 'badge': null},
    ];

    return Column(
      children: rankings.map((user) => _buildRankItem(user)).toList(),
    );
  }

  Widget _buildRankItem(Map<String, dynamic> user) {
    bool isMe = user['name'] == 'QuestMaster (You)';
    Color rankColor = user['rank'] == 1 ? const Color(0xFFFDC700) : user['rank'] == 2 ? const Color(0xFF99A1AF) : user['rank'] == 3 ? const Color(0xFFF54900) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          isMe ? const Color(0xFF59168B).withValues(alpha: 0.5) : const Color(0xFF59168B).withValues(alpha: 0.2),
          isMe ? const Color(0xFF312C85).withValues(alpha: 0.5) : const Color(0xFF312C85).withValues(alpha: 0.2),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? const Color(0xFFC27AFF).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('${user['rank']}', style: TextStyle(color: user['rank'] <= 3 ? const Color(0xFF101828) : Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          CircleAvatar(backgroundColor: Colors.purple.withValues(alpha: 0.3), child: Text(user['emoji'] as String)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user['name'] as String,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user['badge'] != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFDC700).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                        child: Text(user['badge'] as String, style: const TextStyle(color: Color(0xFFFDC700), fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                Text(user['level'] as String, style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(user['xp'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Text('XP', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
