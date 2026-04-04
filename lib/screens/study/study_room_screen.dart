import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StudyRoomScreen extends StatefulWidget {
  const StudyRoomScreen({super.key});

  @override
  State<StudyRoomScreen> createState() => _StudyRoomScreenState();
}

class _StudyRoomScreenState extends State<StudyRoomScreen> {
  // Timer state
  late Timer _timer;
  int _secondsRemaining = 25 * 60; // 25 minutes default
  bool _isActive = false;
  bool _isBreak = false;

  // Tools state
  String _activeTool = 'Notes';

  // Chat state
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'name': 'Alex', 'message': 'Let\'s solve question 5 together', 'time': '10:30'},
    {'name': 'Sarah', 'message': 'Check the formula I added in notes', 'time': '10:32'},
    {'name': 'Mike', 'message': 'Great explanation! 🎉', 'time': '10:35'},
  ];

  @override
  void initState() {
    super.initState();
    _startTimerLogic();
  }

  void _startTimerLogic() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isActive && _secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else if (_secondsRemaining == 0) {
        _toggleTimer();
        // Play sound or show notification here
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _chatController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isActive = !_isActive;
    });
  }

  void _switchMode() {
    setState(() {
      _isBreak = !_isBreak;
      _secondsRemaining = _isBreak ? 5 * 60 : 25 * 60;
      _isActive = false;
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'name': 'You',
          'message': _chatController.text.trim(),
          'time': TimeOfDay.now().format(context),
        });
        _chatController.clear();
      });
    }
  }

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
    double progress = _secondsRemaining / (_isBreak ? 5 * 60 : 25 * 60);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF59168B).withValues(alpha: 0.3), const Color(0xFF312C85).withValues(alpha: 0.3)]),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Column(
        children: [
          Text(_isBreak ? 'Break' : 'Focus Session', style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
          const SizedBox(height: 8),
          Text(_formatTime(_secondsRemaining), style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFF59168B).withValues(alpha: 0.5),
                  color: _isBreak ? Colors.green : const Color(0xFFAD46FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _toggleTimer,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Color(0xFF9810FA), shape: BoxShape.circle),
                  child: Icon(_isActive ? Icons.pause : Icons.play_arrow, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _switchMode,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF59168B).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(_isBreak ? Icons.school_outlined : Icons.coffee_outlined, color: const Color(0xFFDAB2FF), size: 16),
                      const SizedBox(width: 8),
                      Text(_isBreak ? 'Focus' : 'Break', style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 16)),
                    ],
                  ),
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
              _buildToolItem('Notes'),
              const SizedBox(width: 8),
              _buildToolItem('Sticky Notes'),
              const SizedBox(width: 8),
              _buildToolItem('Whiteboard'),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF59168B).withValues(alpha: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_activeTool == 'Notes' ? 'Start typing your notes...' : 'Shared $_activeTool...', style: const TextStyle(color: Color(0xFFAD46FF), fontFamily: 'monospace')),
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

  Widget _buildToolItem(String label) {
    bool active = _activeTool == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTool = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF9810FA) : const Color(0xFF59168B).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFFDAB2FF))),
      ),
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
          ..._messages.map((msg) => _buildChatMessage(msg['name']!, msg['message']!, msg['time']!)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C0366).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _chatController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Color(0xFFAD46FF)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF9810FA), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.send, color: Colors.white, size: 16),
                ),
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
        width: double.infinity,
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
