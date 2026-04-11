import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please log in to see notifications')));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0118),
              Color(0xFF2A1544),
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFAD46FF)));
              }

              final List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
              final int unreadCount = docs.where((doc) => (doc.data() as Map<String, dynamic>)['isUnread'] == true).length;

              return Column(
                children: [
                  _buildCustomAppBar(context, unreadCount),
                  Expanded(
                    child: docs.isEmpty
                        ? const Center(
                            child: Text(
                              'You are all caught up! No new notifications.',
                              style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data = docs[index].data() as Map<String, dynamic>;
                              return _buildNotificationCard(data);
                            },
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

  Widget _buildCustomAppBar(BuildContext context, int unreadCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF59168B).withAlpha(77),
            const Color(0xFF312C85).withAlpha(77),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFAD46FF).withAlpha(51),
            width: 1.4,
          ),
        ),
      ),
      child: Row(
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
                border: Border.all(
                  color: const Color(0xFFAD46FF).withAlpha(77),
                  width: 1.4,
                ),
              ),
              child: const Icon(Icons.chevron_left, color: Color(0xFFDAB2FF)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '$unreadCount new',
                style: const TextStyle(
                  color: Color(0xFFC27AFF),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> data) {
    final String title = data['title'] ?? 'No Title';
    final String description = data['description'] ?? '';
    final bool isUnread = data['isUnread'] ?? false;
    final Timestamp? timestamp = data['timestamp'] as Timestamp?;
    
    String timeAgoStr = 'just now';
    if (timestamp != null) {
      timeAgoStr = timeago.format(timestamp.toDate(), locale: 'en_short');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF59168B).withAlpha(51),
            const Color(0xFF312C85).withAlpha(51),
          ],
        ),
        border: Border.all(
          color: isUnread
              ? const Color(0xFFAD46FF).withAlpha(102)
              : const Color(0xFFAD46FF).withAlpha(26),
          width: 1.4,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUnread)
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 12),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFAD46FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAD46FF).withAlpha(128),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFFC27AFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeAgoStr,
                  style: const TextStyle(
                    color: Color(0xFF9810FA),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
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
