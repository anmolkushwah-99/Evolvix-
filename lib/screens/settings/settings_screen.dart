import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                      _buildAccountDashboard(),
                      const SizedBox(height: 24),
                      _buildPrivacySection(),
                      const SizedBox(height: 24),
                      _buildNotificationSection(),
                      const SizedBox(height: 24),
                      _buildSupportSection(),
                      const SizedBox(height: 32),
                      _buildSaveButton(context),
                      const SizedBox(height: 24),
                      _buildSignOutButton(context),
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.chevron_left, color: Color(0xFFDAB2FF)),
            ),
          ),
          const SizedBox(width: 16),
          const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAccountDashboard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF59168B).withValues(alpha: 0.3), const Color(0xFF312C85).withValues(alpha: 0.3)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ACCOUNT DASHBOARD', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 12, letterSpacing: 0.3)),
          const SizedBox(height: 16),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
            builder: (context, snapshot) {
              return Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF9810FA), Color(0xFF4F39F6)]),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text('👤', style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 16),
                  if (snapshot.hasError)
                    const Text('Error loading profile', style: TextStyle(color: Colors.red, fontSize: 14))
                  else if (snapshot.connectionState == ConnectionState.waiting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC27AFF)),
                    )
                  else
                    Builder(builder: (context) {
                      final data = snapshot.data?.data() as Map<String, dynamic>?;
                      final String displayName = data?['name'] ?? 'Evolvix User';
                      return Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600));
                    }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return _buildSectionContainer(
      title: 'Privacy & Security',
      icon: Icons.security,
      children: [
        _buildSettingItem(Icons.lock_outline, 'Change Password', 'Update your password'),
        _buildSettingItem(Icons.visibility_off_outlined, 'Privacy Settings', 'Control who sees your profile'),
      ],
    );
  }

  Widget _buildNotificationSection() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final settings = data?['notificationSettings'] as Map<String, dynamic>? ?? {};

        return _buildSectionContainer(
          title: 'Notifications',
          icon: Icons.notifications_none,
          children: [
            _buildSwitchItem(
              'Push Notifications',
              'Receive quest and achievement alerts',
              settings['pushEnabled'] ?? true,
              (val) => _updateNotificationSetting('pushEnabled', val),
            ),
            _buildSwitchItem(
              'Study Invites',
              'Receive invitations to study rooms',
              settings['invitesEnabled'] ?? true,
              (val) => _updateNotificationSetting('invitesEnabled', val),
            ),
            _buildSwitchItem(
              'Email Digests',
              'Weekly summary of your progress',
              settings['emailDigestsEnabled'] ?? false,
              (val) => _updateNotificationSetting('emailDigestsEnabled', val),
            ),
            _buildSwitchItem(
              'Achievement Alerts',
              'Celebrate your milestones',
              settings['achievementsEnabled'] ?? true,
              (val) => _updateNotificationSetting('achievementsEnabled', val),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'notificationSettings': {key: value}
    }, SetOptions(merge: true));
  }

  Widget _buildSupportSection() {
    return Column(
      children: [
        _buildActionItem(Icons.language, 'Language', 'Currently English (US)', Icons.chevron_right),
        const SizedBox(height: 12),
        _buildActionItem(Icons.help_outline, 'Help & Support', 'Get assistance from our team', Icons.help_outline, trailingLabel: 'FAQs'),
      ],
    );
  }

  Widget _buildSectionContainer({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF59168B).withValues(alpha: 0.3), const Color(0xFF312C85).withValues(alpha: 0.3)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFC27AFF), size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF59168B).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFC27AFF)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFC27AFF)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF00C950),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, IconData trailingIcon, {String? trailingLabel}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF59168B).withValues(alpha: 0.3), const Color(0xFF312C85).withValues(alpha: 0.3)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF00C950).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF05DF72), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
              ],
            ),
          ),
          if (trailingLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF9810FA), borderRadius: BorderRadius.circular(20)),
              child: Text(trailingLabel, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          const SizedBox(width: 8),
          Icon(trailingIcon, color: const Color(0xFFC27AFF), size: 20),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF9810FA), Color(0xFF4F39F6)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFFAD46FF).withValues(alpha: 0.5), blurRadius: 10)],
        ),
        alignment: Alignment.center,
        child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFB2C36).withValues(alpha: 0.1),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: const BorderSide(color: Color(0xFFFB2C36), width: 1),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: Color(0xFFFF6467)),
          SizedBox(width: 8),
          Text('Sign out', style: TextStyle(color: Color(0xFFFF6467), fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
