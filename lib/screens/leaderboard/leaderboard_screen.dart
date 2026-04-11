import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('totalXp', descending: true)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF9810FA)));
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }

              final users = snapshot.data?.docs ?? [];

              if (users.isEmpty) {
                return const Center(child: Text('No users found', style: TextStyle(color: Colors.white)));
              }

              return Column(
                children: [
                  _buildHeader(context, users),
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
                          _buildRankingsList(users),
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
    );
  }

  Widget _buildHeader(BuildContext context, List<QueryDocumentSnapshot> users) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF59168B).withAlpha(102),
            const Color(0xFF312C85).withAlpha(102),
          ],
        ),
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(26))),
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
                    color: const Color(0xFF59168B).withAlpha(77),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(26)),
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
          _buildPodium(users),
        ],
      ),
    );
  }

  Widget _buildPodium(List<QueryDocumentSnapshot> users) {
    final top3 = users.take(3).toList();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (top3.length >= 2)
          _buildPodiumItemFromDoc(top3[1], 2, 80, const Color(0xFF99A1AF)),
        if (top3.isNotEmpty) ...[
          const SizedBox(width: 16),
          _buildPodiumItemFromDoc(top3[0], 1, 100, const Color(0xFFFDC700)),
        ],
        if (top3.length >= 3) ...[
          const SizedBox(width: 16),
          _buildPodiumItemFromDoc(top3[2], 3, 60, const Color(0xFFF54900)),
        ],
      ],
    );
  }

  Widget _buildPodiumItemFromDoc(QueryDocumentSnapshot doc, int rank, double height, Color color) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['username'] ?? 'Warrior';
    final xp = data['totalXp'] ?? 0;
    final level = data['level'] ?? (xp ~/ 100) + 1;
    final emoji = data['characterEmoji'] ?? (rank == 1 ? '👩' : rank == 2 ? '👨' : '👩‍🎓');

    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: rank == 1 ? 80 : 64,
              height: rank == 1 ? 80 : 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withAlpha(153)]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(26), width: 2),
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
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color, color.withAlpha(77)]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Level $level', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('$xp XP', style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 10)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(name, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10)),
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
        gradient: LinearGradient(colors: [const Color(0xFF59168B).withAlpha(77), const Color(0xFF312C85).withAlpha(77)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(26)),
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

  Widget _buildRankingsList(List<QueryDocumentSnapshot> users) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final data = users[index].data() as Map<String, dynamic>;
        final isMe = users[index].id == FirebaseAuth.instance.currentUser?.uid;
        final rank = index + 1;
        
        return _buildRankItem(data, rank, isMe);
      },
    );
  }

  Widget _buildRankItem(Map<String, dynamic> user, int rank, bool isMe) {
    Color rankColor = rank == 1 ? const Color(0xFFFDC700) : rank == 2 ? const Color(0xFF99A1AF) : rank == 3 ? const Color(0xFFF54900) : Colors.transparent;
    final name = user['username'] ?? 'Warrior';
    final xp = user['totalXp'] ?? 0;
    final level = user['level'] ?? (xp ~/ 100) + 1;
    final emoji = user['characterEmoji'] ?? '👤';
    final badge = user['currentBadge'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          isMe ? const Color(0xFF59168B).withAlpha(128) : const Color(0xFF59168B).withAlpha(51),
          isMe ? const Color(0xFF312C85).withAlpha(128) : const Color(0xFF312C85).withAlpha(51),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? const Color(0xFFC27AFF).withAlpha(128) : Colors.white.withAlpha(26)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('$rank', style: TextStyle(color: rank <= 3 ? const Color(0xFF101828) : Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          CircleAvatar(backgroundColor: Colors.purple.withAlpha(77), child: Text(emoji)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isMe ? '$name (You)' : name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFDC700).withAlpha(51), borderRadius: BorderRadius.circular(10)),
                        child: Text(badge, style: const TextStyle(color: Color(0xFFFDC700), fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                Text('Level $level', style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$xp', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Text('XP', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
