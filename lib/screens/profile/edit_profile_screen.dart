import 'package:flutter/material.dart';
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
                      _buildDangerZone(),
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
                    color: const Color(0xFF59168B).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Icon(Icons.chevron_left, color: Color(0xFFDAB2FF)),
                ),
              ),
              const SizedBox(width: 16),
              const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
                border: Border.all(color: const Color(0xFFAD46FF).withValues(alpha: 0.5), width: 4),
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
        gradient: LinearGradient(colors: [const Color(0xFF59168B).withValues(alpha: 0.3), const Color(0xFF312C85).withValues(alpha: 0.3)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFFC27AFF), size: 20),
              SizedBox(width: 8),
              Text('Personal Information', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
            hintStyle: TextStyle(color: const Color(0xFFC27AFF).withValues(alpha: 0.5)),
            filled: true,
            fillColor: const Color(0xFF59168B).withValues(alpha: 0.2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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
        gradient: LinearGradient(colors: [const Color(0xFF59168B).withValues(alpha: 0.3), const Color(0xFF312C85).withValues(alpha: 0.3)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
              hintStyle: TextStyle(color: const Color(0xFFC27AFF).withValues(alpha: 0.5)),
              filled: true,
              fillColor: const Color(0xFF59168B).withValues(alpha: 0.2),
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
          boxShadow: [BoxShadow(color: const Color(0xFFAD46FF).withValues(alpha: 0.5), blurRadius: 10)],
        ),
        alignment: Alignment.center,
        child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF82181A).withValues(alpha: 0.2), const Color(0xFF861043).withValues(alpha: 0.2)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFB2C36).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Danger Zone', style: TextStyle(color: Color(0xFFFF6467), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF82181A).withValues(alpha: 0.3),
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
}
