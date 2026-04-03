import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  String taskName = '';
  String selectedCategory = 'Study';
  String selectedDifficulty = 'Medium';
  int xpReward = 25;
  DateTime? deadline;

  final TextEditingController _taskNameController = TextEditingController();

  void _updateXpReward(String difficulty) {
    setState(() {
      selectedDifficulty = difficulty;
      switch (difficulty) {
        case 'Easy':
          xpReward = 10;
          break;
        case 'Medium':
          xpReward = 25;
          break;
        case 'Hard':
          xpReward = 50;
          break;
        case 'Epic':
          xpReward = 100;
          break;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Color(0xFF1A0F2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != deadline) {
      setState(() {
        deadline = picked;
      });
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D051A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildTaskPreview(),
              const SizedBox(height: 32),
              _buildInputField('Task Name', 'e.g., Study React for 2 hours'),
              const SizedBox(height: 24),
              _buildCategorySelection(),
              const SizedBox(height: 24),
              _buildDifficultySelection(),
              const SizedBox(height: 24),
              _buildDeadlineInput(context),
              const SizedBox(height: 32),
              _buildCreateButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
        const Text(
          'Create New Task',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: AppColors.accentPink, blurRadius: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskPreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taskName.isEmpty ? 'Your task Name' : taskName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B7FFF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(selectedCategory, style: const TextStyle(color: Color(0xFF51A2FF), fontSize: 14)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF0B100), Color(0xFFFF6900)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text('+$xpReward XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _taskNameController,
          onChanged: (value) {
            setState(() {
              taskName = value;
            });
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFAD46FF), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF1A0F2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    final categories = ['Study', 'Fitness', 'Habit', 'Work', 'Personal'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((cat) => _buildCategoryChip(cat)).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFF1A0F2E),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFDAB2FF),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelection() {
    final levels = [
      {'label': 'Easy', 'xp': '+10 XP'},
      {'label': 'Medium', 'xp': '+25 XP'},
      {'label': 'Hard', 'xp': '+50 XP'},
      {'label': 'Epic', 'xp': '+100 XP'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Difficulty Level', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: levels.map((l) => _buildDifficultyCard(l['label']!, l['xp']!)).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultyCard(String label, String xp) {
    bool isSelected = selectedDifficulty == label;
    return GestureDetector(
      onTap: () => _updateXpReward(label),
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFC27AFF), fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(xp, style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Deadline', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A0F2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              deadline == null ? 'Select date and time' : DateFormat('MMM d, yyyy').format(deadline!),
              style: TextStyle(
                color: deadline == null ? const Color(0xFFAD46FF).withValues(alpha: 0.5) : Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (taskName.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a task name')),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task \"$taskName\" created successfully!')),
        );
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'Create Task',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
