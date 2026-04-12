import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'reward_history_screen.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  Future<void> _processTransaction(BuildContext context, String title, int cost) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDoc = await transaction.get(userDocRef);
        if (!userDoc.exists) throw Exception("User document does not exist!");

        final int currentXp = userDoc.get('totalXp') ?? 0;

        if (currentXp < cost) {
          throw Exception("Not enough XP! Keep grinding.");
        }

        // Deduct XP
        transaction.update(userDocRef, {'totalXp': currentXp - cost});

        // Save Receipt to history
        final historyRef = userDocRef.collection('reward_history').doc();
        transaction.set(historyRef, {
          'title': title,
          'xpChange': -cost,
          'type': 'purchase',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully redeemed $title!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showRedemptionDialog(BuildContext context, String title, int cost, int userXp) {
    // 1. Instant Synchronous Check
    if (userXp < cost) {
      // 2. Clear the SnackBar Queue (CRITICAL)
      ScaffoldMessenger.of(context).clearSnackBars();
      
      // 3. Show the Error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough XP! Keep grinding.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Stops execution
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Redemption', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to spend $cost XP to unlock $title?',
          style: const TextStyle(color: Color(0xFFDAB2FF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFC27AFF))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processTransaction(context, title, cost);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9810FA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Redeem', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, userSnapshot) {
        int currentXp = 0;
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>;
          currentXp = (data['totalXp'] ?? 0) as int;
        }

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
                  _buildHeader(context, currentXp),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildTabs(context),
                          const SizedBox(height: 24),
                          _buildRewardCatalog(context, currentXp),
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
      },
    );
  }

  Widget _buildHeader(BuildContext context, int currentXp) {
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
          const Row(
            children: [
              Text('Rewards Store', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
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
                        Text(currentXp.toString(), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
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

  Widget _buildRewardCatalog(BuildContext context, int currentXp) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('store_rewards').orderBy('cost', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFC27AFF)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No rewards available', style: TextStyle(color: Colors.white)));
        }

        // Grouping Logic
        Map<String, List<DocumentSnapshot>> groupedRewards = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          String category = data['category'] ?? 'General';
          if (!groupedRewards.containsKey(category)) {
            groupedRewards[category] = [];
          }
          groupedRewards[category]!.add(doc);
        }

        List<String> categories = groupedRewards.keys.toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            String category = categories[index];
            List<DocumentSnapshot> rewards = groupedRewards[category]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(category),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: rewards.length,
                    itemBuilder: (context, rewardIndex) {
                      final rewardData = rewards[rewardIndex].data() as Map<String, dynamic>;
                      final String title = rewardData['title'] ?? rewardData['itemName'] ?? 'Reward';
                      
                      // Safe number parsing to fix the double/int crash
                      final int cost = rewardData['cost'] != null ? (rewardData['cost'] as num).toInt() : 0;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: _buildRewardItem(
                          context,
                          title,
                          '$cost XP',
                          _getCategoryColor(category),
                          () => _showRedemptionDialog(context, title, cost, currentXp),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
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
    );
  }

  Widget _buildRewardItem(BuildContext context, String label, String xp, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: 0.6), color.withValues(alpha: 0.3)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.redeem, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
      ),
    );
  }

  Color _getCategoryColor(String category) {
    if (category.toLowerCase().contains('bgmi')) return Colors.blueGrey;
    if (category.toLowerCase().contains('google')) return Colors.orange;
    if (category.toLowerCase().contains('amazon')) return Colors.yellow.shade800;
    if (category.toLowerCase().contains('myntra')) return Colors.pink;
    return Colors.purple;
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
