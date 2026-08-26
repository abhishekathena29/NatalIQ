import 'package:go_router/go_router.dart';

import '../screens/caregiver_screen.dart';
import '../screens/chat_entry_screen.dart';
import '../screens/chat_thread_screen.dart';
import '../screens/community_screen.dart';
import '../screens/doctors_screen.dart';
import '../screens/home_screen.dart';
import '../screens/learn_screen.dart';
import '../screens/more_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/reminders_screen.dart';
import '../screens/track_screen.dart';
import '../screens/videos_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/chat', builder: (context, state) => const ChatEntryScreen()),
    GoRoute(
      path: '/chat/:threadId',
      builder: (context, state) => ChatThreadScreen(
        threadId: state.pathParameters['threadId']!,
        seedQuestion: state.uri.queryParameters['q'],
      ),
    ),
    GoRoute(path: '/track', builder: (context, state) => const TrackScreen()),
    GoRoute(path: '/community', builder: (context, state) => const CommunityScreen()),
    GoRoute(path: '/more', builder: (context, state) => const MoreScreen()),
    GoRoute(path: '/learn', builder: (context, state) => const LearnScreen()),
    GoRoute(path: '/quiz', builder: (context, state) => const QuizScreen()),
    GoRoute(path: '/reminders', builder: (context, state) => const RemindersScreen()),
    GoRoute(path: '/videos', builder: (context, state) => const VideosScreen()),
    GoRoute(path: '/doctors', builder: (context, state) => const DoctorsScreen()),
    GoRoute(path: '/caregiver', builder: (context, state) => const CaregiverScreen()),
  ],
);
