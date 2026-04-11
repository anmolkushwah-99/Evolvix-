import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  int _estimatedDurationMinutes = 60;
  int _baseXp = 10;
  DateTime? deadline;

  final TextEditingController _taskNameController = TextEditingController();

  void _onDurationSelected(int minutes) {
    setState(() {
      _estimatedDurationMinutes = minutes;
      if (minutes <= 60) {
        _baseXp = 10;
      } else if (minutes == 120) {
        _baseXp = 25;
      } else if (minutes == 240) {
        _baseXp = 50;
      } else {
        _baseXp = 100;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: deadline ?? DateTime.now().add(const Duration(minutes: 5)),
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

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(deadline ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                surface: Color(0xFF1A0F2E),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final newDeadline = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          deadline = newDeadline;
        });
      }
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (taskName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task name')),
      );
      return;
    }

    if (deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a deadline for your task')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .add({
          'title': taskName,
          'category': selectedCategory,
          'baseXp': _baseXp,
          'estimatedDurationMinutes': _estimatedDurationMinutes,
          'dueDate': Timestamp.fromDate(deadline!),
          'status': 'Pending',
          'progress': 0.0,
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'startedAt': null, // Initialize as null
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task \"$taskName\" created successfully!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D051A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskPreview(),
                    const SizedBox(height: 32),
                    _buildInputField('Task Name', 'e.g., Study React for 2 hours'),
                    const SizedBox(height: 24),
                    _buildCategorySelection(),
                    const SizedBox(height: 24),
                    _buildDurationSelection(),
                    const SizedBox(height: 24),
                    _buildDeadlineInput(context),
                    const SizedBox(height: 32),
                    _buildCreateButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
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
          const SizedBox(width: 16),
          const Text(
            'Create New Task',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskPreview() {
    Color difficultyColor;
    List<Color> xpGradient;

    if (_baseXp <= 10) {
      difficultyColor = const Color(0xFF00C950);
      xpGradient = [const Color(0xFF00C950), const Color(0xFF008F39)];
    } else if (_baseXp == 25) {
      difficultyColor = const Color(0xFFF0B100);
      xpGradient = [const Color(0xFFF0B100), const Color(0xFFFF6900)];
    } else if (_baseXp == 50) {
      difficultyColor = const Color(0xFFFF4D4D);
      xpGradient = [const Color(0xFFFF4D4D), const Color(0xFFCC0000)];
    } else {
      difficultyColor = const Color(0xFFAD46FF);
      xpGradient = [const Color(0xFFAD46FF), const Color(0xFF7E22CE)];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taskName.isEmpty ? 'Your task Name' : taskName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _previewBadge(selectedCategory, const Color(0xFF2B7FFF).withAlpha(51), const Color(0xFF51A2FF)),
                    _previewBadge(
                      _baseXp == 100 ? 'Epic' : _baseXp >= 50 ? 'Hard' : _baseXp >= 25 ? 'Medium' : 'Easy',
                      difficultyColor.withAlpha(51),
                      difficultyColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: xpGradient),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: xpGradient[0].withAlpha(80),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text('+$_baseXp XP', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600),
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
            hintStyle: TextStyle(color: const Color(0xFFAD46FF).withAlpha(128), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF1A0F2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary.withAlpha(128)),
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
          border: isSelected ? null : Border.all(color: Colors.white.withAlpha(26)),
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

  Widget _buildDurationSelection() {
    final durations = [
      {'label': '30 min', 'minutes': 30},
      {'label': '1 hour', 'minutes': 60},
      {'label': '2 hours', 'minutes': 120},
      {'label': '4 hours', 'minutes': 240},
      {'label': '1 day+', 'minutes': 1440},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estimated Duration', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: durations.map((d) {
              bool isSelected = _estimatedDurationMinutes == d['minutes'];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(d['label'] as String),
                  selected: isSelected,
                  onSelected: (_) => _onDurationSelected(d['minutes'] as int),
                  selectedColor: AppColors.primary,
                  backgroundColor: const Color(0xFF1A0F2E),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFFDAB2FF)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  deadline == null ? 'Set task deadline' : DateFormat('MMM d, h:mm a').format(deadline!),
                  style: TextStyle(
                    color: deadline == null ? const Color(0xFFAD46FF).withAlpha(128) : Colors.white,
                    fontSize: 16,
                  ),
                ),
                const Icon(Icons.calendar_month, color: Color(0xFFC27AFF), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return InkWell(
      onTap: _createTask,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(128),
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
