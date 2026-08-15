import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  final _passConfirmController = TextEditingController();
  bool _loading = true;
  bool _isSetup = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAccount();
  }

  Future<void> _checkAccount() async {
    final hasAccount = await _auth.hasAccount();
    if (!mounted) return;
    setState(() {
      _isSetup = !hasAccount;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final id = _idController.text.trim();
    final pass = _passController.text;

    if (id.isEmpty || pass.isEmpty) {
      setState(() => _error = 'ID dan password wajib diisi');
      return;
    }

    if (_isSetup) {
      if (pass != _passConfirmController.text) {
        setState(() => _error = 'Konfirmasi password tidak cocok');
        return;
      }
      if (pass.length < 4) {
        setState(() => _error = 'Password minimal 4 karakter');
        return;
      }
      await _auth.createAccount(id, pass);
      await _auth.login(id, pass);
    } else {
      final ok = await _auth.login(id, pass);
      if (!ok) {
        setState(() => _error = 'ID atau password salah');
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  const Text(
                    'BRANKAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isSetup ? 'buat id dan password baru' : 'masukkan id dan password',
                    style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.1),
                        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('⛔ $_error', style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _idController,
                    style: const TextStyle(color: Colors.white),
                    decoration: AppTheme.inputDecoration('ID'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: AppTheme.inputDecoration('Password'),
                  ),
                  if (_isSetup) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passConfirmController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: AppTheme.inputDecoration('Konfirmasi Password'),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        _isSetup ? 'Buat Brankas' : 'Buka Brankas',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
