import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'reward_history_screen.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

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
                      _buildTabs(context),
                      const SizedBox(height: 24),
                      _buildSection('BGMI: Online Multiplayer Game', [
                        _buildRewardItem('5UC', '100 XP', Colors.blueGrey),
                        _buildRewardItem('10 UC', '200 XP', Colors.blueGrey),
                        _buildRewardItem('35UC', '700 XP', Colors.orange),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Google Play Credit', [
                        _buildRewardItem('₹5 Credit', '100 XP', Colors.red),
                        _buildRewardItem('₹10 Credit', '200 XP', Colors.orange),
                        _buildRewardItem('₹25 Credit', '500 XP', Colors.green),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('E-commerce Coupons', [
                        _buildRewardItem('\$10 Amazon', '600 XP', Colors.orange),
                        _buildRewardItem('₹500 Myntra', '1500 XP', Colors.pink),
                        _buildRewardItem('₹250 Flipkart', '900 XP', Colors.blue),
                      ]),
                      const SizedBox(height: 24),
                      _buildHowToEarn(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF59168B).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Icon(Icons.chevron_left, color: Color(0xFFDAB2FF)),
                ),
              ),
              const SizedBox(width: 16),
              const Text('Rewards Store', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [const Color(0xFF59168B).withValues(alpha: 0.5), const Color(0xFF312C85).withValues(alpha: 0.5)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Balance', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
                    Row(
                      children: [
                        const Icon(Icons.shield, color: Color(0xFFFDC700), size: 24),
                        const SizedBox(width: 8),
                        const Text('1200', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                        const Text(' XP', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x4DADD2FF)))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFC27AFF), width: 2))),
              child: const Text('Redeem Reward', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFC27AFF), fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RewardHistoryScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text('Reward History', textAlign: TextAlign.center, style: TextStyle(color: Color(0x80DAB2FF), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00BBA7), Color(0xFF00B8DB)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.card_giftcard, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items,
        ),
      ],
    );
  }

  Widget _buildRewardItem(String label, String xp, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: 0.6), color.withValues(alpha: 0.3)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.redeem, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Color(0xFFBEDBFF), size: 12),
              const SizedBox(width: 4),
              Text(xp, style: const TextStyle(color: Color(0xFFBEDBFF), fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowToEarn() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF1C398E).withValues(alpha: 0.2), const Color(0xFF312C85).withValues(alpha: 0.2)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B7FFF).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFF51A2FF), size: 20),
              SizedBox(width: 8),
              Text('How to Earn More XP', style: TextStyle(color: Color(0xFF51A2FF), fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          _buildEarnTip('Complete daily quests to earn XP rewards'),
          _buildEarnTip('Join study sessions with friends for bonus XP'),
          _buildEarnTip('Maintain your streak for multiplier bonuses'),
          _buildEarnTip('Participate in weekly challenges'),
        ],
      ),
    );
  }

  Widget _buildEarnTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text('• $tip', style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 14)),
    );
  }
}
