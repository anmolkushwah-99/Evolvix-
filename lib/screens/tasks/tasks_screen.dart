import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'task_details_screen.dart';

class Task {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  final String status; // 'In Progress', 'Pending', 'Completed'
  final DateTime dueDate;
  final double progress;
  final int baseXp;
  final int estimatedDurationMinutes;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.status,
    required this.dueDate,
    required this.progress,
    required this.baseXp,
    required this.estimatedDurationMinutes,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'General',
      difficulty: data['difficulty'] ?? 'Medium',
      status: data['status'] ?? 'Pending',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      progress: (data['progress'] ?? 0.0).toDouble(),
      baseXp: data['baseXp'] ?? 0,
      estimatedDurationMinutes: data['estimatedDurationMinutes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String selectedFilter = 'All';

  Future<void> _updateTaskProgress(DocumentSnapshot taskDoc) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = taskDoc.data() as Map<String, dynamic>;
    String taskTitle = data['title'] ?? '';

    _showProgressSheet(taskDoc, taskTitle);
  }

  Future<void> _completeTaskAndAwardXP(
    DocumentSnapshot taskDoc, {
    required String progressText,
    required bool hasImageProof,
    ImageSource? source,
    bool isAIValidated = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = taskDoc.data() as Map<String, dynamic>;
    final String title = data['title'] ?? 'Task';
    final String category = data['category'] ?? 'General';
    final int estimatedDurationMinutes = data['estimatedDurationMinutes'] ?? 0;
    final int baseXp = data['baseXp'] ?? 0;
    final Timestamp createdAtTs = data['createdAt'] as Timestamp;
    
    // 1. Bulletproof Data Parsing
    double currentProgress = double.tryParse(data['progress']?.toString() ?? '0.0') ?? 0.0;

    // 2. Determine increment amount based on estimated duration
    double incrementAmount = 1.0;
    if (estimatedDurationMinutes <= 30) {
      incrementAmount = 0.50; // Takes 2 submissions
    } else if (estimatedDurationMinutes <= 120) {
      incrementAmount = 0.34; // Takes 3 submissions
    } else if (estimatedDurationMinutes <= 240) {
      incrementAmount = 0.25; // Takes 4 submissions
    } else if (estimatedDurationMinutes >= 1440) {
      incrementAmount = 0.20; // Takes 5 submissions
    }

    // 3. Floating-Point Safe Math
    double newProgress = currentProgress + incrementAmount;
    String newStatus = 'In Progress';
    bool isNewlyCompleted = false;

    if (newProgress >= 0.98) { // Safely catches 0.999999 math errors
      newProgress = 1.0;
      newStatus = 'Completed';
      isNewlyCompleted = true;
    }

    // 4. Add the Math Debugger
    debugPrint('Math Check -> Old: $currentProgress + Increment: $incrementAmount = New: $newProgress | Status: $newStatus');

    final DateTime now = DateTime.now();
    final DateTime createdAt = createdAtTs.toDate();
    final int actualTimeMinutes = now.difference(createdAt).inMinutes;

    double multiplier = 1.0;
    bool isTooFast = false;

    // Anti-Cheat Logic only for final completion
    if (isNewlyCompleted) {
      if (actualTimeMinutes < (estimatedDurationMinutes * 0.5)) {
        multiplier = 0.0;
        isTooFast = true;
      }

      final oneHourAgo = now.subtract(const Duration(hours: 1));
      final recentTasksQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .where('status', isEqualTo: 'Completed')
          .where('completedAt', isGreaterThan: Timestamp.fromDate(oneHourAgo))
          .get();
      
      if (recentTasksQuery.docs.length >= 5) {
        multiplier *= 0.5;
      }
    }

    final todayStart = DateTime(now.year, now.month, now.day);
    final sameTitleQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .where('status', isEqualTo: 'Completed')
        .where('title', isEqualTo: title)
        .where('completedAt', isGreaterThan: Timestamp.fromDate(todayStart))
        .get();
    
    bool isSpam = sameTitleQuery.docs.isNotEmpty;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDoc = await transaction.get(userDocRef);
        final userData = userDoc.data() as Map<String, dynamic>?;

        int currentStreak = userData?['currentStreak'] ?? 0;
        Timestamp? lastTaskDateTs = userData?['lastTaskDate'];
        
        if (lastTaskDateTs == null) {
          currentStreak = 1;
        } else {
          final lastDate = lastTaskDateTs.toDate();
          final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
          final todayDateOnly = DateTime(now.year, now.month, now.day);
          final difference = todayDateOnly.difference(lastDateOnly).inDays;

          if (difference == 1) {
            currentStreak += 1;
          } else if (difference > 1) {
            currentStreak = 1;
          }
        }

        double streakBonus = 1.0;
        if (currentStreak >= 7) {
          streakBonus = 1.2;
        } else if (currentStreak >= 3) {
          streakBonus = 1.1;
        }

        int calculatedXp = 0;
        if (isNewlyCompleted) {
          calculatedXp = (baseXp * multiplier * streakBonus).toInt();
          if (isSpam && calculatedXp > 10) calculatedXp = 10;
        }

        // Mandatory Proof Bonus
        calculatedXp += 5;

        int currentTotalXp = userData?['totalXp'] ?? 0;
        
        // Prepare User Updates
        Map<String, dynamic> userUpdates = {
          'totalXp': currentTotalXp + calculatedXp,
          'currentStreak': currentStreak,
          'lastTaskDate': FieldValue.serverTimestamp(),
        };

        if (isNewlyCompleted) {
          userUpdates['tasksCompleted'] = FieldValue.increment(1);
        }

        transaction.update(userDocRef, userUpdates);

        transaction.update(taskDoc.reference, {
          'status': newStatus,
          'progress': newProgress,
          'xpAwarded': calculatedXp,
          'completedAt': isNewlyCompleted ? FieldValue.serverTimestamp() : null,
          'progressText': progressText,
          'hasImageProof': hasImageProof,
          'imageSource': source?.toString(),
          'isAIValidated': isAIValidated,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (calculatedXp > 0) {
          final transactionRef = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .doc();
          
          transaction.set(transactionRef, {
            'title': (isNewlyCompleted && isTooFast) ? 'Quest Completed (Fast)' : 'Quest Progress/Completion',
            'subtitle': title,
            'xpAmount': calculatedXp,
            'timestamp': FieldValue.serverTimestamp(),
            'category': category,
            'type': 'earned',
          });
        }
      });

      if (mounted) {
        String message = isNewlyCompleted ? 'Task Completed!' : 'Progress Updated!';
        if (isTooFast && isNewlyCompleted) message += ' (No base XP for fast completion)';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$message +$baseXp XP Potential Awarded!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }

  void _showProgressSheet(DocumentSnapshot taskDoc, String taskTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0F2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ProgressProofSheet(
          taskTitle: taskTitle,
          onConfirm: (text, hasImage, source, isAI) {
            _completeTaskAndAwardXP(
              taskDoc,
              progressText: text,
              hasImageProof: hasImage,
              source: source,
              isAIValidated: isAI,
            );
          },
        );
      },
    );
  }

  void _showTaskHistory() {
    final user = FirebaseAuth.instance.currentUser;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0118),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task History',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .collection('tasks')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    
                    final docs = snapshot.data?.docs ?? [];
                    debugPrint('Total docs fetched (History): ${docs.length}');

                    final completedTasks = docs.map((doc) => Task.fromFirestore(doc)).where((task) {
                      return task.progress >= 1.0 || task.status == 'Completed';
                    }).toList();

                    completedTasks.sort((a, b) => (b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));

                    if (completedTasks.isEmpty) {
                      return const Center(
                        child: Text(
                          'No completed tasks today yet. Get to work!',
                          style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: completedTasks.length,
                      itemBuilder: (context, index) {
                        return _buildCondensedTaskCard(completedTasks[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCondensedTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00C950).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Color(0xFF00C950), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  task.category,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${task.baseXp} XP',
                style: const TextStyle(color: Color(0xFFFDC700), fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('MMM d').format(task.dueDate),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .collection('tasks')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              final docs = snapshot.data?.docs ?? [];
              debugPrint('Total docs fetched: ${docs.length}');
              
              if (docs.isEmpty) {
                return _buildEmptyState(context);
              }

              final allTasks = docs.map((doc) => Task.fromFirestore(doc)).toList();

              int completedCount = allTasks.where((t) => t.status == 'Completed').length;
              int inProgressCount = allTasks.where((t) => t.status == 'In Progress').length;
              int pendingCount = allTasks.where((t) => t.status == 'Pending').length;

              final activeTasks = allTasks.where((task) {
                return task.status != 'Completed' && task.progress < 1.0;
              }).toList();

              List<Task> filteredTasks = selectedFilter == 'All'
                  ? activeTasks
                  : activeTasks.where((task) => task.status == selectedFilter).toList();

              return Column(
                children: [
                  _buildHeader(context, activeTasks.length),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Upcoming Tasks',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              TextButton(
                                onPressed: _showTaskHistory,
                                child: const Text(
                                  'Task History',
                                  style: TextStyle(color: Color(0xFFC27AFF), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (filteredTasks.isEmpty)
                             Center(child: Padding(
                               padding: const EdgeInsets.symmetric(vertical: 40),
                               child: Text(
                                 selectedFilter == 'All' ? 'No active tasks here yet!' : 'No tasks match this filter!',
                                 style: const TextStyle(color: Color(0xFFDAB2FF)),
                               ),
                             ))
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                final doc = docs.firstWhere((d) => d.id == filteredTasks[index].id);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildTaskCard(filteredTasks[index], doc),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context, 0),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No tasks here yet!',
                  style: TextStyle(color: Color(0xFFDAB2FF), fontSize: 18),
                ),
                TextButton(
                  onPressed: _showTaskHistory,
                  child: const Text('View Task History', style: TextStyle(color: Color(0xFFC27AFF))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, int taskCount) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Tasks', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  Text('$taskCount active tasks', style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
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
                    const Text('Create New Task', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
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
    final filters = ['All', 'In Progress', 'Pending'];
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
                  color: isActive ? const Color(0xFF9810FA) : const Color(0xFF59168B).withAlpha(77),
                  borderRadius: BorderRadius.circular(12),
                  border: isActive ? null : Border.all(color: Colors.white.withAlpha(26)),
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
        _buildStatCard(completed.toString(), 'Completed', const Color(0xFF51A2FF), [const Color(0xFF1C398E).withAlpha(77), const Color(0xFF312C85).withAlpha(77)]),
        _buildStatCard(inProgress.toString(), 'In Progress', const Color(0xFFFDC700), [const Color(0xFF733E0A).withAlpha(77), const Color(0xFF7E2A0C).withAlpha(77)]),
        _buildStatCard(pending.toString(), 'Pending', const Color(0xFFC27AFF), [const Color(0xFF59168B).withAlpha(77), const Color(0xFF861043).withAlpha(77)]),
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
        border: Border.all(color: color.withAlpha(77)),
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

  Widget _buildTaskCard(Task task, DocumentSnapshot doc) {
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
    if (task.baseXp >= 100) {
      difficultyColor = const Color(0xFFAD46FF);
    } else if (task.baseXp >= 50) {
      difficultyColor = const Color(0xFFFB2C36);
    } else if (task.baseXp >= 25) {
      difficultyColor = const Color(0xFFFDC700);
    } else {
      difficultyColor = const Color(0xFF05DF72);
    }

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(task.category, AppColors.primary.withAlpha(51), AppColors.primary),
                        _buildBadge(task.difficulty, difficultyColor.withAlpha(51), difficultyColor),
                        _buildBadge(task.status, statusColor.withAlpha(51), statusColor),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFFDC700), size: 20),
                  Text('+${task.baseXp}', style: const TextStyle(color: Color(0xFFFDC700), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer, color: Color(0xFFDAB2FF), size: 14),
              const SizedBox(width: 4),
              Text(
                'Est: ${task.estimatedDurationMinutes < 60 ? '${task.estimatedDurationMinutes}m' : '${task.estimatedDurationMinutes ~/ 60}h'}',
                style: const TextStyle(color: Color(0xFFDAB2FF), fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today, color: Color(0xFFDAB2FF), size: 14),
              const SizedBox(width: 4),
              Text(
                'Due: ${DateFormat('MMM d').format(task.dueDate)}',
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
                  onPressed: task.status == 'Completed'
                      ? null
                      : () {
                          _updateTaskProgress(doc);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9810FA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(task.status == 'Completed' ? 'Done' : 'Continue',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsScreen(taskId: doc.id),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withAlpha(26)),
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
      child: Text(label, style: TextStyle(color: textColor, fontSize: 11)),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF3C0366).withAlpha(128),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
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

class ProgressProofSheet extends StatefulWidget {
  final String taskTitle;
  final Function(String text, bool hasImage, ImageSource? source, bool isAI) onConfirm;

  const ProgressProofSheet({
    super.key,
    required this.taskTitle,
    required this.onConfirm,
  });

  @override
  State<ProgressProofSheet> createState() => _ProgressProofSheetState();
}

class _ProgressProofSheetState extends State<ProgressProofSheet> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String _progressText = '';

  bool _isImageContentValid(XFile? image) {
    if (image == null) return false;
    return true; 
  }

  bool _isValidSubmission() {
    bool hasImage = _selectedImage != null && _isImageContentValid(_selectedImage);
    final trimmedText = _progressText.trim().toLowerCase();
    bool isLongEnough = trimmedText.length >= 10;
    final words = widget.taskTitle.toLowerCase().split(' ');
    bool containsKeyword = words.any((word) => word.length > 2 && trimmedText.contains(word));
    return hasImage && isLongEnough && containsKeyword;
  }

  String _getValidationMessage() {
    if (_selectedImage == null) {
      return '📷 Please take a photo of your work.';
    }
    if (_progressText.trim().length < 10) {
      return '✍️ Description is too short (${_progressText.trim().length}/10 characters).';
    }
    final words = widget.taskTitle.toLowerCase().split(' ');
    bool containsKeyword = words.any((word) => word.length > 2 && _progressText.toLowerCase().contains(word));
    if (!containsKeyword) {
      return '🔑 Description must include a keyword from the task title.';
    }
    return '✅ Ready to submit!';
  }

  Future<void> _captureImage() async {
    try {
      // Clear stale memory before opening heavy camera process
      setState(() { _selectedImage = null; });

      // FORCE light image compression to prevent OOM crash
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (!mounted) return;
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _isValidSubmission();
    final String validationMsg = _getValidationMessage();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Proof of Work',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              onChanged: (value) => setState(() {
                _progressText = value;
              }),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Progress Text (What did you do?)',
                hintStyle: const TextStyle(color: Color(0xFF99A1AF)),
                filled: true,
                fillColor: const Color(0xFF0D051A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Image Submission (Camera Only)', style: TextStyle(color: Color(0xFFC27AFF), fontSize: 14)),
            const SizedBox(height: 12),
            if (_selectedImage == null)
              ElevatedButton.icon(
                onPressed: _captureImage,
                icon: const Icon(Icons.camera_alt, size: 20),
                label: const Text('Open Camera', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A0F2E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFFC27AFF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_selectedImage!.path),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Photo Captured!', style: TextStyle(color: Color(0xFF00C950), fontSize: 14)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() { _selectedImage = null; }),
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isValid
                  ? () {
                      Navigator.pop(context);
                      widget.onConfirm(_progressText, true, ImageSource.camera, false);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9810FA),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Text('Submit Progress', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                validationMsg,
                style: TextStyle(
                  color: isValid ? const Color(0xFF00C950) : const Color(0xFF99A1AF),
                  fontSize: 12,
                  fontWeight: isValid ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
