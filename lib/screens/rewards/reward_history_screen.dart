import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum TransactionType { earned, spent, badge }

class RewardTransaction {
  final String title;
  final String subtitle;
  final int xpAmount;
  final String date;
  final String category;
  final TransactionType type;

  RewardTransaction({
    required this.title,
    required this.subtitle,
    required this.xpAmount,
    required this.date,
    required this.category,
    required this.type,
  });
}

class RewardHistoryScreen extends StatefulWidget {
  const RewardHistoryScreen({super.key});

  @override
  State<RewardHistoryScreen> createState() => _RewardHistoryScreenState();
}

class _RewardHistoryScreenState extends State<RewardHistoryScreen> {
  String selectedFilter = 'All';

  final List<RewardTransaction> transactions = [
    RewardTransaction(
      title: 'Quest Completed',
      subtitle: 'Math Calculus Assignment',
      xpAmount: 150,
      date: 'Yesterday',
      category: 'Quest',
      type: TransactionType.earned,
    ),
    RewardTransaction(
      title: 'Avatar Unlocked',
      subtitle: 'Dark Knight Avatar',
      xpAmount: -500,
      date: 'Mar 30',
      category: 'Store',
      type: TransactionType.spent,
    ),
    RewardTransaction(
      title: 'Achievement Unlocked',
      subtitle: 'Study Streak Master - 7 Days',
      xpAmount: 0,
      date: 'Mar 29',
      category: 'Achievement',
      type: TransactionType.badge,
    ),
    RewardTransaction(
      title: 'Study Room Completed',
      subtitle: 'Calculus',
      xpAmount: 200,
      date: 'Mar 28',
      category: 'Study',
      type: TransactionType.earned,
    ),
    RewardTransaction(
      title: 'Daily Login Bonus',
      subtitle: 'Consecutive login day 15',
      xpAmount: 50,
      date: 'Mar 28',
      category: 'Bonus',
      type: TransactionType.earned,
    ),
    RewardTransaction(
      title: 'Theme Purchased',
      subtitle: 'Deep Galaxy Theme',
      xpAmount: -300,
      date: 'Mar 27',
      category: 'Store',
      type: TransactionType.spent,
    ),
    RewardTransaction(
      title: 'Quest Completed',
      subtitle: '3 Chapters of Chemistry',
      xpAmount: 120,
      date: 'Mar 26',
      category: 'Quest',
      type: TransactionType.earned,
    ),
    RewardTransaction(
      title: 'Leaderboard Reward',
      subtitle: 'Weekly Top 10 Bonus',
      xpAmount: 300,
      date: 'Mar 25',
      category: 'Leaderboard',
      type: TransactionType.earned,
    ),
    RewardTransaction(
      title: 'Power-Up Purchased',
      subtitle: 'XP Booster (2x for 1 hour)',
      xpAmount: -200,
      date: 'Mar 23',
      category: 'Store',
      type: TransactionType.spent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<RewardTransaction> filteredList = transactions.where((t) {
      if (selectedFilter == 'All') return true;
      if (selectedFilter == 'Earned') return t.type == TransactionType.earned;
      if (selectedFilter == 'Spent') return t.type == TransactionType.spent;
      if (selectedFilter == 'Badges') return t.type == TransactionType.badge;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D051A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reward History', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Track your XP journey', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildSummaryCards(),
            const SizedBox(height: 24),
            _buildFilterRow(),
            const SizedBox(height: 16),
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return _buildTransactionCard(filteredList[index]);
              },
            ),
            const SizedBox(height: 24),
            _buildNetBalanceSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryCard('Earned', '820', 'XP', Colors.green, Icons.arrow_upward),
          _buildSummaryCard('Spent', '1000', 'XP', Colors.red, Icons.arrow_downward),
          _buildSummaryCard('Badges', '2', 'Earned', Colors.amber, Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String unit, Color color, IconData icon) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(unit, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = ['All', 'Earned', 'Spent', 'Badges'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Color(0xFFC27AFF), size: 20),
          const SizedBox(width: 12),
          ...filters.map((filter) {
            bool isSelected = selectedFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => selectedFilter = filter),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF9810FA) : const Color(0xFF1A0F2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(RewardTransaction transaction) {
    IconData icon;
    Color iconColor;
    String prefix = '';
    Color amountColor;

    switch (transaction.type) {
      case TransactionType.earned:
        icon = Icons.add_circle_outline;
        iconColor = Colors.green;
        prefix = '+';
        amountColor = Colors.green;
        break;
      case TransactionType.spent:
        icon = Icons.remove_circle_outline;
        iconColor = Colors.red;
        prefix = ''; // xpAmount is already negative
        amountColor = Colors.red;
        break;
      case TransactionType.badge:
        icon = Icons.emoji_events_outlined;
        iconColor = Colors.amber;
        prefix = '';
        amountColor = Colors.amber;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        transaction.title,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      transaction.type == TransactionType.badge ? 'EARNED' : '$prefix${transaction.xpAmount} XP',
                      style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.3), size: 12),
                    const SizedBox(width: 4),
                    Text(transaction.date, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9810FA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.category,
                        style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildNetBalanceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Net Balance Change', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  const Text('-180 XP', style: TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF9810FA).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF9810FA).withOpacity(0.3)),
                ),
                child: const Icon(Icons.bolt, color: Color(0xFFC27AFF), size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Spent', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              const Spacer(),
              Text('Earned', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.45, // Earned ratio
              minHeight: 12,
              backgroundColor: Colors.red.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B7FFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2B7FFF).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFF51A2FF), size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Track Your Progress: Review your history to identify your most productive habits and optimize your XP earning strategy!',
                    style: TextStyle(color: const Color(0xFFDAB2FF).withOpacity(0.8), fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
