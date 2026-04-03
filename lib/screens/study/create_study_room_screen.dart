import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CreateStudyRoomScreen extends StatefulWidget {
  const CreateStudyRoomScreen({super.key});

  @override
  State<CreateStudyRoomScreen> createState() => _CreateStudyRoomScreenState();
}

class _CreateStudyRoomScreenState extends State<CreateStudyRoomScreen> {
  final _roomNameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();
  final _maxUsersController = TextEditingController(text: '5');

  bool isPublic = true;
  double studyDuration = 60.0;
  String selectedTheme = 'Cosmic Purple';
  List<String> tags = [];

  final Map<String, Color> themes = {
    'Cosmic Purple': const Color(0xFF9810FA),
    'Ocean Blue': const Color(0xFF00D3F3),
    'Forest Green': const Color(0xFF05DF72),
    'Sunset Orange': const Color(0xFFFF6900),
    'Midnight Black': const Color(0xFF101828),
  };

  @override
  void dispose() {
    _roomNameController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _maxUsersController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty && tags.length < 5) {
      setState(() {
        tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D051A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Study Room',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Set up your collaborative space',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined, color: Color(0xFFC27AFF)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInputCard(
                label: 'Room Name *',
                icon: Icons.description_outlined,
                child: TextField(
                  controller: _roomNameController,
                  maxLength: 50,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('e.g., Calculus Study Session'),
                  onChanged: (val) => setState(() {}),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                label: 'Subject *',
                icon: Icons.book_outlined,
                child: TextField(
                  controller: _subjectController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Select subject or enter custom'),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                label: 'Description',
                child: Column(
                  children: [
                    TextField(
                      controller: _descriptionController,
                      maxLength: 200,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('What will you be studying? Add any specific topics or goals...'),
                      onChanged: (val) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputCard(
                      label: 'Privacy',
                      icon: Icons.public,
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D051A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                _buildToggleButton('Public', isPublic, Colors.green, () => setState(() => isPublic = true)),
                                _buildToggleButton('Private', !isPublic, const Color(0xFF59168B), () => setState(() => isPublic = false)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPublic ? 'Anyone can join this room' : 'Only invited can join',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputCard(
                      label: 'Max Users',
                      icon: Icons.people_outline,
                      child: Column(
                        children: [
                          TextField(
                            controller: _maxUsersController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: _inputDecoration('5'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '2-20 participants',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                label: 'Study Duration: ${studyDuration.toInt()} minutes',
                icon: Icons.access_time,
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                        thumbColor: Colors.white,
                        overlayColor: AppColors.primary.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: studyDuration,
                        min: 15,
                        max: 240,
                        onChanged: (val) => setState(() => studyDuration = val),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['15 min', '1 hour', '2 hours', '4 hours']
                            .map((e) => Text(e, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                label: 'Room Theme',
                icon: Icons.palette_outlined,
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: themes.entries.map((entry) {
                    bool isSelected = selectedTheme == entry.key;
                    return GestureDetector(
                      onTap: () => setState(() => selectedTheme = entry.key),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: entry.value,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.key.split(' ').first,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                label: 'Tags (Optional)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Add a tag...'),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _addTag,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${tags.length}/5 tags',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: tags
                          .map((tag) => Chip(
                                label: Text(tag, style: const TextStyle(fontSize: 12)),
                                onDeleted: () => setState(() => tags.remove(tag)),
                                backgroundColor: const Color(0xFF59168B).withValues(alpha: 0.3),
                                labelStyle: const TextStyle(color: Color(0xFFC27AFF)),
                                deleteIconColor: const Color(0xFFC27AFF),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Study Room created successfully!')),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.people_outline, color: Colors.white),
                  label: const Text(
                    'Create Study Room',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C398E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Pro Tip: Study rooms with clear descriptions and tags get 3x more participants!',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required String label, IconData? icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF59168B).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFFC27AFF), size: 16),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(color: Color(0xFFC27AFF), fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF0D051A).withValues(alpha: 0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      counterStyle: const TextStyle(color: Colors.white24, fontSize: 10),
    );
  }

  Widget _buildToggleButton(String text, bool active, Color activeColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.white24,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
