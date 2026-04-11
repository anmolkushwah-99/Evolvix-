import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

enum TransactionType { earned, spent, badge }

class RewardTransaction {
  final String id;
  final String title;
  final String subtitle;
  final int xpAmount;
  final DateTime date;
  final String category;
  final TransactionType type;

  RewardTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.xpAmount,
    required this.date,
    required this.category,
    required this.type,
  });

  factory RewardTransaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String typeStr = data['type'] ?? 'earned';
    TransactionType type = TransactionType.earned;
    if (typeStr == 'spent') type = TransactionType.spent;
    if (typeStr == 'badge') type = TransactionType.badge;

    return RewardTransaction(
      id: doc.id,
      title: data['title'] ?? 'Unknown',
      subtitle: data['subtitle'] ?? '',
      xpAmount: data['xpAmount'] ?? 0,
      date: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? 'General',
      type: type,
    );
  }
}

class RewardHistoryScreen extends StatefulWidget {
  const RewardHistoryScreen({super.key});

  @override
  State<RewardHistoryScreen> createState() => _RewardHistoryScreenState();
}

class _RewardHistoryScreenState extends State<RewardHistoryScreen> {
  String selectedFilter = 'All';

  Future<void> _exportHistoryToCSV(List<RewardTransaction> transactions) async {
    try {
      List<List<dynamic>> csvData = [
        ['Title', 'XP Amount', 'Date', 'Type'],
        ...transactions.map((t) => [
          t.title,
          t.xpAmount,
          DateFormat('yyyy-MM-dd HH:mm').format(t.date),
          t.type.toString().split('.').last,
        ]),
      ];

      String csvString = const ListToCsvConverter().convert(csvData);
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/evolvix_reward_history.csv';
      final file = File(path);
      await file.writeAsString(csvString);

      await Share.shareXFiles([XFile(path)], text: 'My Evolvix Reward History Export');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting history: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('transactions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data?.docs ?? [];
          final allTransactions = docs.map((doc) => RewardTransaction.fromFirestore(doc)).toList();

          int earned = 0;
          int spent = 0;
          int badges = 0;

          for (var t in allTransactions) {
            if (t.type == TransactionType.earned) earned += t.xpAmount;
            if (t.type == TransactionType.spent) spent += t.xpAmount.abs();
            if (t.type == TransactionType.badge) badges++;
          }

          List<RewardTransaction> filteredList = allTransactions.where((t) {
            if (selectedFilter == 'All') return true;
            if (selectedFilter == 'Earned') return t.type == TransactionType.earned;
            if (selectedFilter == 'Spent') return t.type == TransactionType.spent;
            if (selectedFilter == 'Badges') return t.type == TransactionType.badge;
            return true;
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildSummaryCards(earned, spent, badges),
                const SizedBox(height: 24),
                _buildFilterRow(),
                const SizedBox(height: 16),
                if (filteredList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Text(
                        'No transactions found.',
                        style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 16),
                      ),
                    ),
                  )
                else
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
                _buildNetBalanceSection(earned - spent),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
      floatingActionButton: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('transactions')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
          return FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF9810FA),
            onPressed: () => _exportHistoryToCSV(
              snapshot.data!.docs.map((doc) => RewardTransaction.fromFirestore(doc)).toList()
            ),
            child: const Icon(Icons.download, color: Colors.white),
          );
        }
      ),
    );
  }

  Widget _buildSummaryCards(int earned, int spent, int badges) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryCard('Earned', earned.toString(), 'XP', Colors.green, Icons.arrow_upward),
          _buildSummaryCard('Spent', spent.toString(), 'XP', Colors.red, Icons.arrow_downward),
          _buildSummaryCard('Badges', badges.toString(), 'Earned', Colors.amber, Icons.emoji_events),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
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
        prefix = '';
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
                    Text(
                      DateFormat('MMM d, yyyy').format(transaction.date),
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                    ),
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

  Widget _buildNetBalanceSection(int netBalance) {
    Color balanceColor = netBalance >= 0 ? Colors.green : Colors.red;
    String balancePrefix = netBalance >= 0 ? '+' : '';

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
                  Text('$balancePrefix$netBalance XP', style: TextStyle(color: balanceColor, fontSize: 32, fontWeight: FontWeight.bold)),
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
