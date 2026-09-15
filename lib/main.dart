import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'package:natal_iq/core/theme/app_theme.dart';
import 'package:natal_iq/features/auth/services/auth_service.dart';
import 'package:natal_iq/features/nap/services/nap_timer_service.dart';
import 'package:natal_iq/firebase_options.dart';
import 'package:natal_iq/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService.instance.init();
  await NapTimerService.instance.init();
  runApp(const AanyaApp());
}

class AanyaApp extends StatefulWidget {
  const AanyaApp({super.key});

  @override
  State<AanyaApp> createState() => _AanyaAppState();
}

class _AanyaAppState extends State<AanyaApp> {
  StreamSubscription<Uri?>? _widgetClickSub;

  @override
  void initState() {
    super.initState();
    _handleWidgetLaunch(); // Cold start via a home-screen widget tap.
    _widgetClickSub = HomeWidget.widgetClicked.listen(_openFromWidgetUri); // Warm-start taps.
  }

  Future<void> _handleWidgetLaunch() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    _openFromWidgetUri(uri);
  }

  void _openFromWidgetUri(Uri? uri) {
    if (uri?.host == 'nap') appRouter.push('/nap');
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aanya — Pregnancy Care Companion',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
