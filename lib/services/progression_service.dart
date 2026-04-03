import 'dart:math';

/// Service to handle user progression, XP calculation, and milestone logic.
class ProgressionService {
  // Constants for level calculation
  static const int baseXP = 100;
  static const double scalingFactor = 1.5;

  /// Adds XP to user's total.
  /// In a real app, you would call:
  /// FirebaseFirestore.instance.collection('users').doc(userId).update({
  ///   'totalXP': FieldValue.increment(xpAmount),
  /// });
  int addXP(int currentXP, int xpAmount) {
    return currentXP + xpAmount;
  }

  /// Calculates the level based on total XP using a simple power curve.
  /// Formula: Level = sqrt(XP / baseXP)
  int calculateLevel(int totalXP) {
    if (totalXP < baseXP) return 1;
    return (sqrt(totalXP / baseXP)).floor() + 1;
  }

  /// Calculates the XP required to reach the next level.
  int xpForLevel(int level) {
    if (level <= 1) return 0;
    return (pow(level - 1, 2) * baseXP).toInt();
  }

  /// Check if a specific milestone is hit and return reward ID if applicable.
  /// Milestones can be stored in Firestore and fetched as a list.
  String? checkMilestone(int totalXP, int level) {
    // Example milestone logic
    if (level == 5) return 'REWARD_LVL_5_AVATAR';
    if (totalXP >= 10000) return 'REWARD_XP_CENTURION';
    return null;
  }

  /// Firestore Integration Example:
  /// 
  /// Future<void> updateProgression(String userId, int xpGained) async {
  ///   final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  ///   
  ///   await FirebaseFirestore.instance.runTransaction((transaction) async {
  ///     final snapshot = await transaction.get(userRef);
  ///     final data = snapshot.data()!;
  ///     
  ///     int newXP = data['totalXP'] + xpGained;
  ///     int oldLevel = data['level'];
  ///     int newLevel = calculateLevel(newXP);
  ///     
  ///     transaction.update(userRef, {
  ///       'totalXP': newXP,
  ///       'level': newLevel,
  ///     });
  ///     
  ///     if (newLevel > oldLevel) {
  ///       // Trigger level up UI/Reward logic
  ///     }
  ///   });
  /// }
}
