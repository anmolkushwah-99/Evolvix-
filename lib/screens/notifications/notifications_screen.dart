import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NotificationItem {
  final String title;
  final String description;
  final String timeAgo;
  final bool isUnread;

  NotificationItem({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.isUnread,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'New Achievement Unlocked!',
      description: 'You\'ve earned the \'Study Streak Master\' badge',
      timeAgo: '2m ago',
      isUnread: true,
    ),
    NotificationItem(
      title: 'Study Room Invitation',
      description: 'Alex invited you to \'Physics Problems\' session',
      timeAgo: '10m ago',
      isUnread: true,
    ),
    NotificationItem(
      title: 'Quest Completed!',
      description: 'Completed \'Calculus Assignment\' +150 XP',
      timeAgo: '1h ago',
      isUnread: true,
    ),
    NotificationItem(
      title: 'Daily Login Bonus',
      description: '+50 XP for logging in today',
      timeAgo: '3h ago',
      isUnread: false,
    ),
    NotificationItem(
      title: 'New Friend Request',
      description: 'Sarah wants to connect with you',
      timeAgo: '5h ago',
      isUnread: false,
    ),
    NotificationItem(
      title: 'Quest Reminder',
      description: '\'Chemistry Reading\' due tomorrow at 6:00 PM',
      timeAgo: '1d ago',
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int unreadCount = _notifications.where((n) => n.isUnread).length;

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
          child: Column(
            children: [
              _buildCustomAppBar(context, unreadCount),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(_notifications[index]);
                  },
                ),
              ),
            ],
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
            const Color(0xFF59168B).withValues(alpha: 0.3),
            const Color(0xFF312C85).withValues(alpha: 0.3),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFAD46FF).withValues(alpha: 0.2),
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
                color: const Color(0xFF59168B).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFAD46FF).withValues(alpha: 0.3),
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

  Widget _buildNotificationCard(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF59168B).withValues(alpha: 0.2),
            const Color(0xFF312C85).withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(
          color: item.isUnread
              ? const Color(0xFFAD46FF).withValues(alpha: 0.4)
              : const Color(0xFFAD46FF).withValues(alpha: 0.1),
          width: 1.4,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.isUnread)
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
                      color: const Color(0xFFAD46FF).withValues(alpha: 0.5),
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
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Color(0xFFC27AFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.timeAgo,
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
