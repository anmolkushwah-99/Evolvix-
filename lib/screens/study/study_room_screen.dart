import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

class ActiveStudyRoomScreen extends StatefulWidget {
  final String roomId;
  const ActiveStudyRoomScreen({super.key, required this.roomId});

  @override
  State<ActiveStudyRoomScreen> createState() => _ActiveStudyRoomScreenState();
}

class _ActiveStudyRoomScreenState extends State<ActiveStudyRoomScreen> {
  // State Management (Tabs & Timer)
  int _currentTabIndex = 0;
  int _secondsElapsed = 0;
  Timer? _studyTimer;
  bool _isPlaying = false;

  // Auto-Saving Shared Notes
  final TextEditingController _notesController = TextEditingController();
  Timer? _debounce;

  // Live Study Chat
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _notesController.addListener(_onNotesChanged);
  }

  void _loadInitialData() async {
    final doc = await FirebaseFirestore.instance
        .collection('studyRooms')
        .doc(widget.roomId)
        .get();
    if (doc.exists && mounted) {
      setState(() {
        _notesController.text = doc.data()?['sharedNotes'] ?? '';
      });
    }
  }

  void _onNotesChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      FirebaseFirestore.instance
          .collection('studyRooms')
          .doc(widget.roomId)
          .update({
        'sharedNotes': _notesController.text,
      });
    });
  }

  void _toggleTimer() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _studyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _secondsElapsed++;
          });
        });
      } else {
        _studyTimer?.cancel();
      }
    });
  }

  void _pauseTimer() {
    if (_isPlaying) {
      _toggleTimer();
    }
  }

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _chatController.text.trim().isEmpty) return;

    // Fetch user name for the chat
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final senderName = userDoc.data()?['username'] ?? userDoc.data()?['name'] ?? 'User';

    final text = _chatController.text.trim();
    _chatController.clear();

    await FirebaseFirestore.instance
        .collection('studyRooms')
        .doc(widget.roomId)
        .collection('messages')
        .add({
      'senderName': senderName,
      'senderId': user.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _studyTimer?.cancel();
    _notesController.removeListener(_onNotesChanged);
    _notesController.dispose();
    _debounce?.cancel();
    _chatController.dispose();
    super.dispose();
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
                      _buildTimerSection(),
                      _buildToolsTabs(),
                      _buildWorkspaceArea(),
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
            const Color(0xFF59168B).withAlpha(102),
            const Color(0xFF312C85).withAlpha(102),
          ],
        ),
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(26))),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('studyRooms').doc(widget.roomId).snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final title = data?['roomName'] ?? 'Study Room';
          final participants = data?['currentParticipants'] ?? 0;

          return Row(
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
                        color: const Color(0xFF59168B).withAlpha(77),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha(26)),
                      ),
                      child: const Icon(Icons.chevron_left, color: Color(0xFFDAB2FF)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.people_outline, color: Color(0xFFC27AFF), size: 14),
                          const SizedBox(width: 4),
                          Text('$participants participants', style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
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
          );
        }
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF59168B).withAlpha(77), const Color(0xFF312C85).withAlpha(77)]),
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(26))),
      ),
      child: Column(
        children: [
          const Text('Focus Session', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
          const SizedBox(height: 8),
          Text(_formatTime(_secondsElapsed), style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _toggleTimer,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Color(0xFF9810FA), shape: BoxShape.circle),
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _pauseTimer, // Pauses timer
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF59168B).withAlpha(128),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(26)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.coffee_outlined, color: Color(0xFFDAB2FF), size: 16),
                      SizedBox(width: 8),
                      Text('Break', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 16)),
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

  Widget _buildToolsTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF59168B).withAlpha(51),
      child: Row(
        children: [
          _buildTabItem(0, 'Notes'),
          const SizedBox(width: 8),
          _buildTabItem(1, 'Sticky Notes'),
          const SizedBox(width: 8),
          _buildTabItem(2, 'Whiteboard'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    bool active = _currentTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF9810FA) : const Color(0xFF59168B).withAlpha(77),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFFDAB2FF))),
      ),
    );
  }

  Widget _buildWorkspaceArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF59168B).withAlpha(51),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentTabIndex == 0)
            TextField(
              controller: _notesController,
              maxLines: null,
              style: const TextStyle(color: Color(0xFFF3E8FF), fontFamily: 'monospace'),
              decoration: const InputDecoration(
                hintText: 'Start typing your notes...',
                hintStyle: TextStyle(color: Color(0xFFAD46FF)),
                border: InputBorder.none,
              ),
            )
          else
            Container(
              height: 150,
              alignment: Alignment.center,
              child: Text('Shared ${_getTabLabel(_currentTabIndex)}...', style: const TextStyle(color: Color(0xFFAD46FF))),
            ),
          const SizedBox(height: 20),
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
    );
  }

  String _getTabLabel(int index) {
    if (index == 1) return 'Sticky Notes';
    if (index == 2) return 'Whiteboard';
    return 'Notes';
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
        color: const Color(0xFF59168B).withAlpha(51),
        border: Border(top: BorderSide(color: Colors.white.withAlpha(26))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Study Chat', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 14)),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('studyRooms')
                .doc(widget.roomId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              return ListView.builder(
                shrinkWrap: true,
                reverse: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final timestamp = data['timestamp'] as Timestamp?;
                  final time = timestamp != null ? DateFormat('HH:mm').format(timestamp.toDate()) : '';
                  return _buildChatMessage(
                    data['senderName'] ?? 'User',
                    data['text'] ?? '',
                    time,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C0366).withAlpha(77),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(26)),
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
        decoration: BoxDecoration(color: const Color(0xFF59168B).withAlpha(77), borderRadius: BorderRadius.circular(12)),
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
