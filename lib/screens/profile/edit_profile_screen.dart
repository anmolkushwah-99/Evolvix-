import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
                    children: [
                      _buildAvatarSection(),
                      const SizedBox(height: 32),
                      _buildInfoSection(),
                      const SizedBox(height: 24),
                      _buildBioSection(),
                      const SizedBox(height: 32),
                      _buildSaveButton(context),
                      const SizedBox(height: 24),
                      _buildDangerZone(context),
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
            const Color(0xFF59168B).withAlpha(102),
            const Color(0xFF312C85).withAlpha(102),
          ],
        ),
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(26))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF59168B).withAlpha(77),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(26)),
                  ),
                  child: const Icon(Icons.chevron_left, color: Color(0xFFDAB2FF)),
                ),
              ),
              const SizedBox(width: 16),
              const Text('Edit Profile',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Customize your warrior profile', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF9810FA), Color(0xFF4F39F6)]),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFAD46FF).withAlpha(128), width: 4),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.person, size: 64, color: Colors.white70),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF9810FA), Color(0xFF4F39F6)]),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1A0F2E), width: 4),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Tap to change avatar', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 14)),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [const Color(0xFF59168B).withAlpha(77), const Color(0xFF312C85).withAlpha(77)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFFC27AFF), size: 20),
              SizedBox(width: 8),
              Text('Personal Information',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField('Username', 'DragonSlayer'),
          const SizedBox(height: 16),
          _buildTextField('Email', 'dragon@evolvix.com'),
          const SizedBox(height: 16),
          _buildTextField('Phone', '+91 9876543211'),
          const SizedBox(height: 16),
          _buildTextField('Location', 'Ujjain, Madhya Pradesh'),
          const SizedBox(height: 16),
          _buildTextField('Birthdate', 'Select your birthday'),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: value,
            hintStyle: TextStyle(color: const Color(0xFFC27AFF).withAlpha(128)),
            filled: true,
            fillColor: const Color(0xFF59168B).withAlpha(51),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withAlpha(26)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [const Color(0xFF59168B).withAlpha(77), const Color(0xFF312C85).withAlpha(77)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bio', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tell others about yourself...',
              hintStyle: TextStyle(color: const Color(0xFFC27AFF).withAlpha(128)),
              filled: true,
              fillColor: const Color(0xFF59168B).withAlpha(51),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('108/250', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
          ),
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
          boxShadow: [BoxShadow(color: const Color(0xFFAD46FF).withAlpha(128), blurRadius: 10)],
        ),
        alignment: Alignment.center,
        child:
            const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [const Color(0xFF82181A).withAlpha(51), const Color(0xFF861043).withAlpha(51)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFB2C36).withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Danger Zone',
              style: TextStyle(color: Color(0xFFFF6467), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showDeleteConfirmationDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF82181A).withAlpha(77),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Color(0xFFFB2C36), width: 1),
            ),
            child: const Text('Delete Account', style: TextStyle(color: Color(0xFFFF6467), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A0F2E),
          title: const Text('Delete Account?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'This action is permanent and cannot be undone. All your data will be lost.',
            style: TextStyle(color: Color(0xFFDAB2FF)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFFC27AFF))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount(context);
              },
              child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6467))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    // Show Loading: Show a CircularProgressIndicator while the deletion is processing.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF9810FA)),
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;

      if (uid != null) {
        // Delete Firestore Data: First, get the current user's UID.
        // Delete their specific document from the users collection in Cloud Firestore so we don't leave orphaned data behind.
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

        // Delete Auth Record: Call FirebaseAuth.instance.currentUser?.delete() to permanently remove their account from Firebase Authentication.
        await user?.delete();
      }

      // Route on Success: If the deletion is successful, pop the dialog and use Navigator.pushAndRemoveUntil to send them all the way back to the LoginScreen, clearing the entire navigation history.
      if (context.mounted) {
        Navigator.pop(context); // Pop loading dialog
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Pop loading dialog
        // Handle Security Errors (Crucial): Catch FirebaseAuthException specifically. If the error code is requires-recent-login, show a SnackBar telling the user: 'For security reasons, please log out and log back in before deleting your account.'
        if (e.code == 'requires-recent-login') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('For security reasons, please log out and log back in before deleting your account.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Pop loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
