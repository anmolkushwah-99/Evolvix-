import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/bottom_nav_bar.dart';

class Task {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  String status; // 'In Progress', 'Pending', 'Completed'
  final DateTime dueDate;
  final double progress;
  final int xpReward;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.status,
    required this.dueDate,
    required this.progress,
    required this.xpReward,
  });
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String selectedFilter = 'All';

  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Study 2 hours',
      category: 'Study',
      difficulty: 'Medium',
      status: 'In Progress',
      dueDate: DateTime.now().copyWith(hour: 18, minute: 0),
      progress: 0.6,
      xpReward: 50,
    ),
    Task(
      id: '2',
      title: 'Complete Workout',
      category: 'Fitness',
      difficulty: 'Easy',
      status: 'Pending',
      dueDate: DateTime.now().copyWith(hour: 20, minute: 0),
      progress: 0.0,
      xpReward: 30,
    ),
    Task(
      id: '3',
      title: 'Read 20 pages',
      category: 'Habit',
      difficulty: 'Easy',
      status: 'In Progress',
      dueDate: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 10, minute: 0),
      progress: 0.75,
      xpReward: 25,
    ),
    Task(
      id: '4',
      title: 'Practice coding',
      category: 'Study',
      difficulty: 'Medium',
      status: 'In Progress',
      dueDate: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 17, minute: 0),
      progress: 0.3,
      xpReward: 40,
    ),
    Task(
      id: '5',
      title: 'Team project meeting',
      category: 'Work',
      difficulty: 'Medium',
      status: 'Pending',
      dueDate: DateTime(2024, 3, 28, 14, 0),
      progress: 0.0,
      xpReward: 35,
    ),
    Task(
      id: '6',
      title: 'Learn React Hooks',
      category: 'Study',
      difficulty: 'Hard',
      status: 'In Progress',
      dueDate: DateTime(2024, 3, 30, 9, 0),
      progress: 0.1,
      xpReward: 60,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = selectedFilter == 'All'
        ? _tasks
        : _tasks.where((task) => task.status == selectedFilter).toList();

    int completedCount = _tasks.where((t) => t.status == 'Completed').length;
    int inProgressCount = _tasks.where((t) => t.status == 'In Progress').length;
    int pendingCount = _tasks.where((t) => t.status == 'Pending').length;

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
                      _buildFilters(),
                      const SizedBox(height: 24),
                      _buildStats(completedCount, inProgressCount, pendingCount),
                      const SizedBox(height: 24),
                      const Text(
                        'Upcoming Quests',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildTaskCard(filteredTasks[index]),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Tasks', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  Text('${_tasks.length} tasks available', style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/create_task'),
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Create New tasks', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'In Progress', 'Pending', 'Completed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          bool isActive = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF9810FA) : const Color(0xFF59168B).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: isActive ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  filter,
                  style: TextStyle(color: isActive ? Colors.white : const Color(0xFFDAB2FF), fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStats(int completed, int inProgress, int pending) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(completed.toString(), 'Completed', const Color(0xFF51A2FF), [const Color(0xFF1C398E).withValues(alpha: 0.3), const Color(0xFF312C85).withValues(alpha: 0.3)]),
        _buildStatCard(inProgress.toString(), 'In Progress', const Color(0xFFFDC700), [const Color(0xFF733E0A).withValues(alpha: 0.3), const Color(0xFF7E2A0C).withValues(alpha: 0.3)]),
        _buildStatCard(pending.toString(), 'Pending', const Color(0xFFC27AFF), [const Color(0xFF59168B).withValues(alpha: 0.3), const Color(0xFF861043).withValues(alpha: 0.3)]),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color, List<Color> gradient) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color statusColor;
    switch (task.status) {
      case 'Completed':
        statusColor = const Color(0xFF05DF72);
        break;
      case 'In Progress':
        statusColor = const Color(0xFFFDC700);
        break;
      case 'Pending':
      default:
        statusColor = const Color(0xFFC27AFF);
        break;
    }

    Color difficultyColor;
    switch (task.difficulty) {
      case 'Hard':
        difficultyColor = const Color(0xFFFB2C36);
        break;
      case 'Medium':
        difficultyColor = const Color(0xFFFDC700);
        break;
      case 'Easy':
      default:
        difficultyColor = const Color(0xFF05DF72);
        break;
    }

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildBadge(task.category, AppColors.primary.withValues(alpha: 0.2), AppColors.primary),
                      const SizedBox(width: 8),
                      _buildBadge(task.difficulty, difficultyColor.withValues(alpha: 0.2), difficultyColor),
                      const SizedBox(width: 8),
                      _buildBadge(task.status, statusColor.withValues(alpha: 0.2), statusColor),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFFDC700), size: 20),
                  Text('+${task.xpReward}', style: const TextStyle(color: Color(0xFFFDC700), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFFDAB2FF), size: 14),
              const SizedBox(width: 4),
              Text(
                'Due: ${DateFormat('MMM d, h:mm a').format(task.dueDate)}',
                style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress', style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 12)),
              Text('${(task.progress * 100).toInt()}%', style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(task.progress),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Resuming task: ${task.title}')),
                    );
                    setState(() {
                      task.status = 'In Progress';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9810FA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continue', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/task_details', arguments: task);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Details', style: TextStyle(color: Color(0xFFDAB2FF))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 12)),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF3C0366).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF0B100), Color(0xFF00C950)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
