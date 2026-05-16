import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/phone_auth_screen.dart';
import 'navigation/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Initial system UI overlay (light mode default).
  // Each AppBarTheme.systemOverlayStyle takes over once MaterialApp renders.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const ParkingApp());
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  Widget _resolveHome() {
    final state = AppState.instance;

    // Already logged in this session → go straight to app
    if (state.isLoggedIn && state.currentUser != null) {
      return MainNavigation(role: state.selectedRole);
    }

    // Seen onboarding before but not logged in → phone auth
    if (state.hasSeenOnboarding) {
      return PhoneAuthScreen(role: state.selectedRole);
    }

    // Fresh install → show onboarding
    return const OnboardingScreen();
  }

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder rebuilds only the MaterialApp subtree when
    // ThemeMode changes — zero extra dependencies, zero boilerplate.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppState.instance.themeModeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: 'Society Parking QR',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),       // white lightweight theme
        darkTheme: AppTheme.dark(),    // premium #0F172A midnight theme
        themeMode: mode,               // driven by AppState.instance.themeMode
        home: _resolveHome(),
      ),
    );
  }
}
