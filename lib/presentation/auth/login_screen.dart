// lib/presentation/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_failure.dart';

/// Écran Connexion / Inscription — instanciation directe de
/// [AuthRepositoryImpl] (conception SkillUp §4–6).
///
/// Les erreurs Firebase sont déjà converties en [AuthFailure] :
/// on affiche `e.message` tel quel (jamais d'exception brute).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authRepo = AuthRepositoryImpl(remote: AuthRemoteDataSource());

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        await _authRepo.signUp(email: email, password: password);
      } else {
        await _authRepo.signIn(email: email, password: password);
      }
      // Succès : le StreamBuilder de MyApp redirige vers l'accueil.
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isSignUp ? 'Créer un compte' : 'Connexion';
    final subtitle = _isSignUp
        ? 'Rejoins SkillUp et suis tes parcours.'
        : 'Bon retour. Continue là où tu t’étais arrêté.';
    final ctaLabel = _isSignUp ? 'S’inscrire' : 'Se connecter';
    final switchLabel = _isSignUp
        ? 'Déjà un compte ? Se connecter'
        : 'Pas encore de compte ? S’inscrire';

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'SkillUp',
                      style: GoogleFonts.fraunces(
                        color: AppColors.moss,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.fraunces(
                        color: AppColors.forest,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: GoogleFonts.manrope(
                        color: AppColors.ink.withValues(alpha: 0.72),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.manrope(color: AppColors.ink),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'toi@exemple.com',
                        prefixIcon: Icon(
                          Icons.mail_outline,
                          color: AppColors.moss,
                        ),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Indique ton adresse email.';
                        }
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Adresse email invalide.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: GoogleFonts.manrope(color: AppColors.ink),
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        hintText: _isSignUp
                            ? '6 caractères minimum'
                            : 'Ton mot de passe',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.moss,
                        ),
                        suffixIcon: IconButton(
                          onPressed: _isLoading
                              ? null
                              : () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.forestMuted,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final password = value ?? '';
                        if (password.isEmpty) {
                          return 'Indique ton mot de passe.';
                        }
                        if (_isSignUp && password.length < 6) {
                          return 'Mot de passe trop faible (6 caractères minimum).';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.sand,
                              ),
                            )
                          : Text(ctaLabel),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : _toggleMode,
                      child: Text(
                        switchLabel,
                        style: GoogleFonts.manrope(
                          color: AppColors.moss,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
