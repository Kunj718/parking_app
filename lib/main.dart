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
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,   // dark icons on white bg
    systemNavigationBarColor: Colors.transparent,
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppState.instance.themeModeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: 'Society Parking QR',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        home: _resolveHome(),
      ),
    );
  }
}
