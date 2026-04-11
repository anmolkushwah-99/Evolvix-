/// Model class representing the user's progression data.
class UserProgress {
  final String userId;
  int totalXp;
  int currentLevel;
  List<String> unlockedRewards;

  UserProgress({
    required this.userId,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.unlockedRewards = const [],
  });

  /// Converts the UserProgress object into a Map for storage (e.g., Firestore).
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalXp': totalXp,
      'currentLevel': currentLevel,
      'unlockedRewards': unlockedRewards,
    };
  }

  /// Creates a UserProgress object from a Map (e.g., data from Firestore).
  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] ?? '',
      totalXp: map['totalXp'] ?? 0,
      currentLevel: map['currentLevel'] ?? 1,
      unlockedRewards: List<String>.from(map['unlockedRewards'] ?? []),
    );
  }
}
