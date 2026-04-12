import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
            stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
              final int xp = userData?['totalXp'] ?? userData?['xp'] ?? 0;
              final int streak = userData?['currentStreak'] ?? 0;
              final int level = userData?['level'] ?? 1;
              final int focusMinutes = userData?['focusMinutes'] ?? 0;

              return Column(
                children: [
                  _buildHeader(context, user?.uid),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildWeeklyActivities(user?.uid),
                          const SizedBox(height: 24),
                          _buildRewardsEarned(xp),
                          const SizedBox(height: 24),
                          _buildDailyFocus(focusMinutes),
                          const SizedBox(height: 24),
                          _buildStreakStats(streak),
                          const SizedBox(height: 24),
                          _buildProjectEvolution(user?.uid),
                          const SizedBox(height: 24),
                          _buildNextMilestone(xp, level),
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

  Widget _buildHeader(BuildContext context, String? uid) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              const Spacer(),
              const Text('Evolvix', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(flex: 2),
            ],
          ),
          const SizedBox(height: 24),
          const Text('PERFORMANCE HUB', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 14, letterSpacing: 0.7)),
          const Text('Your Performance', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('tasks')
                .where('status', isEqualTo: 'Completed')
                .snapshots(),
            builder: (context, snapshot) {
              int totalCompleted = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return RichText(
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 14),
                  children: [
                    const TextSpan(text: "You've completed "),
                    TextSpan(text: '$totalCompleted', style: const TextStyle(color: Color(0xFF05DF72), fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' tasks in total. Keep the momentum!'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivities(String? uid) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF59168B).withValues(alpha: 0.3), const Color(0xFF312C85).withValues(alpha: 0.3)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Activities', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Tasks completed recently', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
                ],
              ),
              const Icon(Icons.bar_chart, color: AppColors.accentGreen),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegend('Completed', const Color(0xFFAD46FF)),
              const SizedBox(width: 16),
              _buildLegend('Goal', const Color(0xFF00D3F3).withOpacity(0.3)),
            ],
          ),
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('tasks')
                .where('status', isEqualTo: 'Completed')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
              }

              final docs = snapshot.data?.docs ?? [];
              
              Map<int, int> dayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
              final now = DateTime.now();
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = data['completedAt'] as Timestamp?;
                if (timestamp != null) {
                  final date = timestamp.toDate();
                  if (now.difference(date).inDays < 7) {
                    dayCounts[date.weekday] = (dayCounts[date.weekday] ?? 0) + 1;
                  }
                }
              }

              return SizedBox(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar('MON', (dayCounts[1] ?? 0) / 5),
                    _buildBar('TUE', (dayCounts[2] ?? 0) / 5),
                    _buildBar('WED', (dayCounts[3] ?? 0) / 5),
                    _buildBar('THU', (dayCounts[4] ?? 0) / 5),
                    _buildBar('FRI', (dayCounts[5] ?? 0) / 5),
                    _buildBar('SAT', (dayCounts[6] ?? 0) / 5),
                    _buildBar('SUN', (dayCounts[7] ?? 0) / 5),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 14)),
      ],
    );
  }

  Widget _buildBar(String day, double heightFactor) {
    final double displayFactor = heightFactor.clamp(0.05, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 12,
          height: 100 * displayFactor,
          decoration: BoxDecoration(
            color: const Color(0xFFAD46FF),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 10)),
      ],
    );
  }

  Widget _buildRewardsEarned(int xp) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF0D542B).withValues(alpha: 0.2), const Color(0xFF004F3B).withValues(alpha: 0.2)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF05DF72).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF05DF72).withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(Icons.shield, color: Color(0xFF05DF72), size: 20),
              ),
              const SizedBox(width: 12),
              const Text('XP Accumulated', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text('$xp', style: const TextStyle(color: Color(0xFF05DF72), fontSize: 36, fontWeight: FontWeight.bold)),
          const Text('Total experience points earned', style: TextStyle(color: Color(0xFF7BF1A8), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDailyFocus(int focusMinutes) {
    final String displayHours = (focusMinutes / 60.0).toStringAsFixed(1);
    final double progressValue = (focusMinutes / 240.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF1C398E).withValues(alpha: 0.3), const Color(0xFF312C85).withValues(alpha: 0.3)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2B7FFF).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Focus', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progressValue,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      color: Colors.purpleAccent,
                    ),
                  ),
                  Text('${displayHours}h', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 24),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your focus sessions are consistent. Maintain your flow!',
                      style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text('Goal: 4.0h', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStats(int streak) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatCard('Status', 'Active', Icons.bolt, const Color(0xFFFDC700)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSmallStatCard('Streak', '$streak Days', Icons.local_fire_department, const Color(0xFFC27AFF)),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProjectEvolution(String? uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .where('status', isEqualTo: 'Completed')
          .snapshots(),
      builder: (context, snapshot) {
        int totalCompleted = snapshot.hasData ? snapshot.data!.docs.length : 0;
        
        String statusText = 'GETTING STARTED';
        Color statusColor = Colors.grey;
        if (totalCompleted > 50) {
          statusText = 'MASTER PRODUCER';
          statusColor = const Color(0xFFAD46FF);
        } else if (totalCompleted > 20) {
          statusText = 'HIGHLY PRODUCTIVE';
          statusColor = const Color(0xFF00C950);
        } else if (totalCompleted > 5) {
          statusText = 'CONSISTENT';
          statusColor = const Color(0xFF00D3F3);
        }

        return Container(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF101828).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF4A5565).withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Project Evolution',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Overall productivity rank',
                      style: TextStyle(color: Color(0xFF99A1AF), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(statusText, style: const TextStyle(color: Color(0xFF101828), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNextMilestone(int currentXp, int level) {
    final int targetXp = level * 100;
    final double progress = (currentXp / targetXp).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF9810FA), Color(0xFF4F39F6)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFFAD46FF).withValues(alpha: 0.5), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag, color: Colors.white),
              SizedBox(width: 12),
              Text('Next Milestone', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Reach ${level + 1} to unlock new specialized tasks and premium rewards.',
            style: const TextStyle(color: Color(0xFFF3E8FF), fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '$currentXp', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                        TextSpan(text: '/$targetXp', style: const TextStyle(color: Color(0xFFE9D4FF), fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF05DF72), Color(0xFF00D492)]),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF05DF72), borderRadius: BorderRadius.circular(20)),
                child: const Text('Level Up', style: TextStyle(color: Color(0xFF101828), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
