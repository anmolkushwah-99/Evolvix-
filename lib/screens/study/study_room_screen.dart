import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StudyRoomScreen extends StatelessWidget {
  const StudyRoomScreen({super.key});

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
                  child: Column(
                    children: [
                      _buildParticipantsSection(),
                      _buildTimerSection(),
                      _buildToolsSection(),
                      _buildChatSection(),
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
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Math Study Room', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(Icons.people_outline, color: Color(0xFFC27AFF), size: 14),
                      SizedBox(width: 4),
                      Text('3 participants', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Session XP', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
              Text('+95', style: TextStyle(color: Color(0xFF05DF72), fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF59168B).withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Participants', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          _buildParticipantItem('Alex', '+45 XP', '👨', Colors.green),
          const SizedBox(height: 8),
          _buildParticipantItem('Sarah', '+30 XP', '👩', Colors.green),
          const SizedBox(height: 8),
          _buildParticipantItem('Mike', '+20 XP', '👨‍💼', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildParticipantItem(String name, String xp, String emoji, Color status) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF59168B).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(backgroundColor: Colors.purple, child: Text(emoji)),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: status, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1A0F2E), width: 2)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(xp, style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF59168B).withValues(alpha: 0.3), const Color(0xFF312C85).withValues(alpha: 0.3)]),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Column(
        children: [
          const Text('Focus Session', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
          const SizedBox(height: 8),
          const Text('23:00', style: TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFF59168B).withValues(alpha: 0.5),
                  color: const Color(0xFFAD46FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFF9810FA), shape: BoxShape.circle),
                child: const Icon(Icons.pause, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF59168B).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.coffee_outlined, color: Color(0xFFDAB2FF), size: 16),
                    SizedBox(width: 8),
                    Text('Break', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolsSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFF59168B).withValues(alpha: 0.2),
          child: Row(
            children: [
              _buildToolItem('Notes', true),
              const SizedBox(width: 8),
              _buildToolItem('Sticky Notes', false),
              const SizedBox(width: 8),
              _buildToolItem('Whiteboard', false),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF59168B).withValues(alpha: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Start typing your notes...', style: TextStyle(color: Color(0xFFAD46FF), fontFamily: 'monospace')),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 4),
                      Text('Saved automatically', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildMiniAvatar('👨'),
                      _buildMiniAvatar('👩'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolItem(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF9810FA) : const Color(0xFF59168B).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFFDAB2FF))),
    );
  }

  Widget _buildMiniAvatar(String emoji) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF9810FA), Color(0xFF4F39F6)]),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildChatSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF59168B).withValues(alpha: 0.2),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Study Chat', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 14)),
          const SizedBox(height: 12),
          _buildChatMessage('Alex', 'Let\'s solve question 5 together', '10:30'),
          _buildChatMessage('Sarah', 'Check the formula I added in notes', '10:32'),
          _buildChatMessage('Mike', 'Great explanation! 🎉', '10:35'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C0366).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Text('Type a message...', style: TextStyle(color: Color(0xFFAD46FF))),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF9810FA), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.send, color: Colors.white, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(String name, String message, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF59168B).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name, style: const TextStyle(color: Color(0xFFC27AFF), fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(color: Color(0xFFAD46FF), fontSize: 12)),
              ],
            ),
            Text(message, style: const TextStyle(color: Color(0xFFF3E8FF))),
          ],
        ),
      ),
    );
  }
}
