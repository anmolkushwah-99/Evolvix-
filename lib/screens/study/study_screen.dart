import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'create_study_room_screen.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Online Friends',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      _buildOnlineFriendsStream(),
                      const SizedBox(height: 24),
                      _buildCreateRoomButton(context),
                      const SizedBox(height: 24),
                      _buildActiveRoomsSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
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
            const Color(0xFF59168B).withAlpha(102),
            const Color(0xFF312C85).withAlpha(102),
          ],
        ),
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(26))),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text('Study Party', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search study rooms...',
              hintStyle: const TextStyle(color: Color(0xFFAD46FF)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFC27AFF)),
              filled: true,
              fillColor: const Color(0xFF3C0366).withAlpha(77),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withAlpha(26)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineFriendsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(height: 100, child: Center(child: Text('No friends found', style: TextStyle(color: Color(0xFFDAB2FF)))));
        }

        final users = snapshot.data!.docs;

        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final name = user['username'] ?? user['name'] ?? 'Alex';
              final isOnline = user['isOnline'] ?? false;
              
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF9810FA), Color(0xFF4F39F6)]),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text('👤', style: TextStyle(fontSize: 24)),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF1A0F2E), width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(name, style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 14)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCreateRoomButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateStudyRoomScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF9810FA), Color(0xFF4F39F6)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: const Text('Create Study Room', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildActiveRoomsSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('studyRooms').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        
        final roomsCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Study Rooms', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                Text('$roomsCount rooms', style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              const Center(child: Text('No active rooms found', style: TextStyle(color: Color(0xFFDAB2FF))))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final room = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return _buildRoomCard(
                    context,
                    room['roomName'] ?? 'Study Room',
                    room['subject'] ?? 'General',
                    '${room['currentParticipants'] ?? 0}/${room['maxParticipants'] ?? 5}',
                    '${room['duration'] ?? 25} min',
                    room['hostName'] ?? 'Unknown',
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildRoomCard(BuildContext context, String title, String subject, String members, String time, String host) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                  Text(subject, style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, color: Color(0xFFC27AFF), size: 16),
                      const SizedBox(width: 4),
                      Text(members, style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, color: Color(0xFFC27AFF), size: 16),
                      const SizedBox(width: 4),
                      Text(time, style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/study-room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00A63E), Color(0xFF009966)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: const Text('Join', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0x33AD46FF)),
          Row(
            children: [
              const CircleAvatar(radius: 12, child: Text('👤', style: TextStyle(fontSize: 12))),
              const SizedBox(width: 8),
              Text('Hosted by $host', style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: const Color(0xFF3C0366).withAlpha(128),
            color: Colors.orange,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}
