import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../providers/auth_provider.dart' as my;
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/divider_with_text.dart';
import 'package:uts_1123150013/core/routes/app_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _showPass = false;
  bool _showConfirmPass = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  /// Handler untuk register
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<my.AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (ok) {
      // Registrasi berhasil, pindah ke halaman verifikasi email
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      // Registrasi gagal, tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registrasi gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<my.AuthProvider>().isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Mendaftarkan akun...',
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const AuthHeader(
                    icon: Icons.person_add_outlined,
                    title: 'Buat Akun Baru',
                    subtitle: 'Daftar untuk mulai menggunakan aplikasi',
                  ),
                  const SizedBox(height: 32),

                  // Name field
                  CustomTextField(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                    prefixIcon: const Icon(Icons.person_outlined),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Nama wajib diisi';
                      if (v!.length < 2) return 'Nama minimal 2 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  CustomTextField(
                    label: 'Email',
                    hint: 'contoh@email.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Email wajib diisi';
                      if (!EmailValidator.validate(v!)) {
                        return 'Format email salah';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Minimal 6 karakter',
                    controller: _passCtrl,
                    obscureText: !_showPass,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPass ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _showPass = !_showPass);
                      },
                    ),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Password wajib diisi';
                      if (v!.length < 6) return 'Password minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password field
                  CustomTextField(
                    label: 'Konfirmasi Password',
                    hint: 'Ulangi password',
                    controller: _confirmPassCtrl,
                    obscureText: !_showConfirmPass,
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPass
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _showConfirmPass = !_showConfirmPass);
                      },
                    ),
                    validator: (v) {
                      if (v?.isEmpty ?? true)
                        return 'Konfirmasi password wajib diisi';
                      if (v != _passCtrl.text) return 'Password tidak cocok';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Register button
                  CustomButton(label: 'Daftar', onPressed: _register),
                  const SizedBox(height: 16),

                  // Divider
                  const DividerWithText(text: 'atau'),
                  const SizedBox(height: 16),

                  // Google Sign In button
                  GoogleSignInButton(
                    onPressed: () async {
                      final auth = context.read<my.AuthProvider>();
                      final ok = await auth.loginWithGoogle();
                      if (!mounted) return;
                      if (ok) {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRouter.dashboard,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              auth.errorMessage ?? 'Login Google gagal',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? '),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          AppRouter.login,
                        ),
                        child: const Text('Masuk'),
                      ),
                    ],
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
