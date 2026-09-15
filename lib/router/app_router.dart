import 'package:go_router/go_router.dart';

import 'package:natal_iq/features/more/screens/caregiver_screen.dart';
import 'package:natal_iq/features/chat/screens/chat_entry_screen.dart';
import 'package:natal_iq/features/chat/screens/chat_thread_screen.dart';
import 'package:natal_iq/features/community/screens/community_screen.dart';
import 'package:natal_iq/features/community/screens/create_post_screen.dart';
import 'package:natal_iq/features/community/screens/post_detail_screen.dart';
import 'package:natal_iq/features/more/screens/doctors_screen.dart';
import 'package:natal_iq/features/home/screens/home_screen.dart';
import 'package:natal_iq/features/journal/screens/journal_entry_screen.dart';
import 'package:natal_iq/features/journal/screens/journal_screen.dart';
import 'package:natal_iq/features/more/screens/learn_screen.dart';
import 'package:natal_iq/features/auth/screens/login_screen.dart';
import 'package:natal_iq/features/more/screens/more_screen.dart';
import 'package:natal_iq/features/nap/screens/nap_screen.dart';
import 'package:natal_iq/features/auth/screens/onboarding_screen.dart';
import 'package:natal_iq/features/auth/screens/profile_screen.dart';
import 'package:natal_iq/features/more/screens/quiz_screen.dart';
import 'package:natal_iq/features/more/screens/reminders_screen.dart';
import 'package:natal_iq/features/auth/screens/signup_screen.dart';
import 'package:natal_iq/features/track/screens/track_screen.dart';
import 'package:natal_iq/features/community/screens/videos_screen.dart';
import 'package:natal_iq/features/auth/services/auth_service.dart';

const _authRoutes = {'/login', '/signup'};

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: AuthService.instance,
  redirect: (context, state) {
    final auth = AuthService.instance;
    final location = state.matchedLocation;
    final onAuthRoute = _authRoutes.contains(location);
    final onOnboarding = location == '/onboarding';

    if (!auth.isLoggedIn) {
      return onAuthRoute ? null : '/login';
    }
    if (!auth.hasOnboarded) {
      return onOnboarding ? null : '/onboarding';
    }
    if (onAuthRoute || onOnboarding) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
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
    GoRoute(path: '/community/compose', builder: (context, state) => const CreatePostScreen()),
    GoRoute(
      path: '/community/:postId',
      builder: (context, state) => PostDetailScreen(postId: state.pathParameters['postId']!),
    ),
    GoRoute(path: '/more', builder: (context, state) => const MoreScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/learn', builder: (context, state) => const LearnScreen()),
    GoRoute(path: '/quiz', builder: (context, state) => const QuizScreen()),
    GoRoute(path: '/reminders', builder: (context, state) => const RemindersScreen()),
    GoRoute(path: '/videos', builder: (context, state) => const VideosScreen()),
    GoRoute(path: '/doctors', builder: (context, state) => const DoctorsScreen()),
    GoRoute(path: '/caregiver', builder: (context, state) => const CaregiverScreen()),
    GoRoute(path: '/journal', builder: (context, state) => const JournalScreen()),
    GoRoute(
      path: '/journal/:entryId',
      builder: (context, state) {
        final id = state.pathParameters['entryId'];
        return JournalEntryScreen(entryId: id == 'new' ? null : id);
      },
    ),
    GoRoute(path: '/nap', builder: (context, state) => const NapScreen()),
  ],
);
