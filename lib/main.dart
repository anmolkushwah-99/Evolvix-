import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/character_creation_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/tasks/create_task_screen.dart';
import 'screens/study/study_screen.dart';
import 'screens/study/study_room_screen.dart';
import 'screens/rewards/rewards_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/performance/performance_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/notifications/notifications_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EvolvixApp());
}

class EvolvixApp extends StatelessWidget {
  const EvolvixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evolvix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0514),
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/character_creation': (context) => const CharacterCreationScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/home': (context) => const DashboardScreen(),
        '/tasks': (context) => const TasksScreen(),
        '/create_task': (context) => const CreateTaskScreen(),
        '/study': (context) => const StudyScreen(),
        '/study-room': (context) {
          final roomId = ModalRoute.of(context)?.settings.arguments as String? ?? 'room_1';
          return ActiveStudyRoomScreen(roomId: roomId);
        },
        '/rewards': (context) => const RewardsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/performance': (context) => const PerformanceScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/task_details': (context) => const Scaffold(body: Center(child: Text('Task Details Screen'))),
      },
    );
  }
}
