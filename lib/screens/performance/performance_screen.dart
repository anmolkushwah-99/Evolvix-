import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

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
                    children: [
                      _buildWeeklyActivities(),
                      const SizedBox(height: 24),
                      _buildRewardsEarned(),
                      const SizedBox(height: 24),
                      _buildDailyFocus(),
                      const SizedBox(height: 24),
                      _buildStreakStats(),
                      const SizedBox(height: 24),
                      _buildProjectEvolution(),
                      const SizedBox(height: 24),
                      _buildNextMilestone(),
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
          RichText(
            text: const TextSpan(
              style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 14),
              children: [
                TextSpan(text: "You've completed "),
                TextSpan(text: '84%', style: TextStyle(color: Color(0xFF05DF72), fontWeight: FontWeight.bold)),
                TextSpan(text: ' more tasks than last week. Keep the momentum!'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivities() {
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
                  Text('Task completion distribution', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
                ],
              ),
              const Icon(Icons.bar_chart, color: AppColors.accentGreen),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegend('Code', const Color(0xFFAD46FF)),
              const SizedBox(width: 16),
              _buildLegend('UI/UX', const Color(0xFF00D3F3)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('MON', 0.4),
                _buildBar('TUE', 0.8),
                _buildBar('WED', 0.6),
                _buildBar('THU', 1.0),
                _buildBar('FRI', 0.4),
                _buildBar('SAT', 0.8),
                _buildBar('SUN', 0.6),
              ],
            ),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 12,
          height: 100 * heightFactor,
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

  Widget _buildRewardsEarned() {
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
              const Text('Rewards Earned', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('1,280', style: TextStyle(color: Color(0xFF05DF72), fontSize: 36, fontWeight: FontWeight.bold)),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: '+23%', style: TextStyle(color: Color(0xFF05DF72), fontWeight: FontWeight.bold)),
                TextSpan(text: ' Total coins this week', style: TextStyle(color: Color(0xFF7BF1A8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyFocus() {
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
                      value: 0.73,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      color: Colors.purpleAccent,
                    ),
                  ),
                  const Text('4.5h', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 14),
                        children: [
                          TextSpan(text: 'Your focus sessions have become '),
                          TextSpan(text: '73%', style: TextStyle(color: Color(0xFF51A2FF), fontWeight: FontWeight.bold)),
                          TextSpan(text: ' longer since last week!'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Peak: 2 PM', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStats() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatCard('Today', 'Wednesday', Icons.calendar_today, const Color(0xFFFDC700)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSmallStatCard('Streak', '12 Days', Icons.local_fire_department, const Color(0xFFC27AFF)),
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

  Widget _buildProjectEvolution() {
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
                  'Current status',
                  style: TextStyle(color: Color(0xFF99A1AF), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF00C950), borderRadius: BorderRadius.circular(20)),
            child: const Text('HIGHLY PRODUCTIVE', style: TextStyle(color: Color(0xFF101828), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNextMilestone() {
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
          RichText(
            text: const TextSpan(
              style: TextStyle(color: Color(0xFFF3E8FF), fontSize: 14),
              children: [
                TextSpan(text: 'Complete 5 more tasks to reach Level 11 and unlock '),
                TextSpan(text: 'Premium Quests', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ". You're almost there!"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(text: '15', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                        TextSpan(text: '/20', style: TextStyle(color: Color(0xFFE9D4FF), fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 75,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF05DF72), Color(0xFF00D492)]),
                        borderRadius: BorderRadius.circular(6),
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
