
import 'package:flutter/material.dart';

import 'screens/main_shell_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/watchx_database_service.dart';
import 'theme/watchx_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WatchXApp());
}

class WatchXApp extends StatelessWidget {
  const WatchXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WATCHX Luxury',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: WatchXColors.bgBlack,
        colorScheme: const ColorScheme.dark(
          primary: WatchXColors.goldPrimary,
          surface: WatchXColors.surfaceDark,
        ),
      ),
      home: const WatchXAuthGate(),
    );
  }
}

class WatchXAuthGate extends StatefulWidget {
  const WatchXAuthGate({super.key});

  @override
  State<WatchXAuthGate> createState() => _WatchXAuthGateState();
}

class _WatchXAuthGateState extends State<WatchXAuthGate> {
  late Future<UserProfile?> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = WatchXDatabaseService.getActiveUser();
  }

  void _retrySessionCheck() {
    setState(() {
      _sessionFuture = WatchXDatabaseService.getActiveUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: WatchXColors.bgBlack,
            body: Center(
              child: CircularProgressIndicator(
                color: WatchXColors.goldPrimary,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: WatchXColors.bgBlack,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: WatchXColors.errorRed,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load your account.',
                      style: TextStyle(
                        color: WatchXColors.textWhite,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retrySessionCheck,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          return WatchXMainShell(user: user);
        }

        return const OnboardingScreen();
      },
    );
  }
}
