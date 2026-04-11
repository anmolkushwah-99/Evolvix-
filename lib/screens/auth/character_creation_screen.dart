import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String _selectedGender = 'others';
  String _selectedHairstyle = 'Short';
  String _selectedOutfit = 'Casual';
  String _selectedClass = 'Warrior';

  final List<String> _genders = ['Male', 'Female', 'others'];
  final List<String> _hairstyles = ['Short', 'Long', 'Curly', 'Spiky', 'Bald'];
  final List<String> _outfits = ['Casual', 'Formal', 'Sporty', 'Mystic', 'Tech'];

  final List<Map<String, dynamic>> _classes = [
    {'name': 'Warrior', 'icon': Icons.shield},
    {'name': 'Wizard', 'icon': Icons.auto_stories},
    {'name': 'Explorer', 'icon': Icons.explore},
  ];

  Map<String, double> _getStats() {
    switch (_selectedClass) {
      case 'Warrior':
        return {'Strength': 0.75, 'Intelligence': 0.55, 'Focus': 0.60, 'Discipline': 0.80};
      case 'Wizard':
        return {'Strength': 0.35, 'Intelligence': 0.95, 'Focus': 0.85, 'Discipline': 0.50};
      case 'Explorer':
        return {'Strength': 0.60, 'Intelligence': 0.70, 'Focus': 0.90, 'Discipline': 0.65};
      default:
        return {'Strength': 0.5, 'Intelligence': 0.5, 'Focus': 0.5, 'Discipline': 0.5};
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getStats();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0514),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.pinkAccent, Color(0xFF9810FA)],
                      ).createShader(bounds),
                      child: const Text(
                        'Create your\nCharacter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your path to greatness',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Avatar Card
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF9810FA).withOpacity(0.15),
                        const Color(0xFF9810FA).withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9810FA).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                          ),
                        ),
                        child: const Icon(Icons.person, size: 70, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_selectedGender • $_selectedHairstyle • $_selectedOutfit',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Username Field
              const Text('Username', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your username',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
              const SizedBox(height: 24),

              // Selection Chips
              _buildSelectionRow('Gender', _genders, _selectedGender, (val) => setState(() => _selectedGender = val)),
              _buildSelectionRow('Hairstyle', _hairstyles, _selectedHairstyle, (val) => setState(() => _selectedHairstyle = val)),
              _buildSelectionRow('Outfit', _outfits, _selectedOutfit, (val) => setState(() => _selectedOutfit = val)),

              // Class Selection
              const Text('Choose Your Class', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 12),
              ..._classes.map((c) => _buildClassCard(c['name'], c['icon'])),
              const SizedBox(height: 24),

              // Stats Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Starting Stats',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...stats.entries.map((e) => _buildStatRow(e.key, e.value)),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Create Button
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9D10FA), Color(0xFF4F39F6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9D10FA).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _createCharacter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Create Character',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionRow(String title, List<String> options, String selectedValue, Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 15)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: options.map((option) {
              final isSelected = option == selectedValue;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onSelected(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF9810FA) : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildClassCard(String className, IconData icon) {
    final isSelected = _selectedClass == className;
    return GestureDetector(
      onTap: () => setState(() => _selectedClass = className),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F1235) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.success : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isSelected ? AppColors.textSecondary : Colors.white24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    className,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white24,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Positioned(
                right: 0,
                top: 0,
                child: Icon(Icons.check_circle, color: AppColors.success, size: 22),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 13),
              ),
              Text(
                '${(progress * 100).toInt()}/100',
                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    height: 8,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Colors.pinkAccent, Color(0xFF9810FA)],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createCharacter() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'gender': _selectedGender,
          'hairstyle': _selectedHairstyle,
          'outfit': _selectedOutfit,
          'class': _selectedClass,
          'level': 1,
          'xp': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating character: $e')),
        );
      }
    }
  }
}
