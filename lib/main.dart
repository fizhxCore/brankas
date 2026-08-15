import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BrankasApp());
}

class BrankasApp extends StatelessWidget {
  const BrankasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brankas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _SplashRouter(),
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final loggedIn = await _auth.isLoggedIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => loggedIn ? const HomeScreen() : const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
    );
  }
}
