import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// الصفحات
import 'package:app_spynaly/views/splash/splash_screen.dart';
import 'package:app_spynaly/views/home/home_page.dart';
import 'package:app_spynaly/views/auth/login_page.dart';
import 'package:app_spynaly/views/auth/register_page.dart';
import 'package:app_spynaly/views/auth/AuthChoicePage.dart';
import 'package:app_spynaly/views/auth/forgot_password_page.dart';
import 'package:app_spynaly/views/profile/profile_page.dart';
import 'package:app_spynaly/views/welcome/welcome_screen.dart';
import 'package:app_spynaly/views/devices/connected_devices_page.dart';
import 'package:app_spynaly/views/settings/settings_page.dart';
import 'package:app_spynaly/apps_analysis/apps_analysis_page.dart';

import 'routes/app_routes.dart';
import 'Themes/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SpyNaly(),
    ),
  );
}

class SpyNaly extends StatelessWidget {
  const SpyNaly({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'SpyNaly',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF185278),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF185278),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.welcom,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.welcom: (context) => const WelcomeScreen(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.register: (context) => const RegisterPage(),
        AppRoutes.authChoice: (context) => const AuthChoicePage(),
        AppRoutes.home: (context) => HomePage(),
        AppRoutes.profile: (context) => const ProfilePage(),
        AppRoutes.connecteddevices: (context) => ConnectedDevicesPage(),
        AppRoutes.settings: (context) => const SettingsPage(),
        AppRoutes.forgot_password: (context) => const ForgotPasswordPage (),
        AppRoutes.apps_analysis: (context) => const AppsAnalysisPage(),
      },
    );
  }
}