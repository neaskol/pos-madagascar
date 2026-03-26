import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthEmailSignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: isDark
                    ? AppColors.dangerDark
                    : AppColors.dangerLight,
              ),
            );
          } else if (state is AuthAuthenticatedNoStore) {
            context.go('/setup');
          } else if (state is AuthAuthenticatedWithStore) {
            // Vérifier si l'user a déjà un PIN configuré
            if (state.user.pinHash == null || state.user.pinHash!.isEmpty) {
              context.go('/pin-setup');
            } else {
              context.go('/pin');
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // Logo
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurfaceHigh,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.store,
                          size: 32,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      l10n.loginTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: l10n.loginEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.errorFieldRequired;
                        }
                        if (!value.contains('@')) {
                          return l10n.errorInvalidEmail;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        labelText: l10n.loginPassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          tooltip: _obscurePassword
                              ? l10n.loginShowPassword
                              : l10n.loginHidePassword,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.errorFieldRequired;
                        }
                        if (value.length < 8) {
                          return l10n.errorPasswordTooShort;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.push('/forgot-password');
                              },
                        child: Text(
                          l10n.loginForgotPassword,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkAccent
                                : AppColors.lightAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          foregroundColor: isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark
                                        ? AppColors.darkBackground
                                        : AppColors.lightBackground,
                                  ),
                                ),
                              )
                            : Text(
                                l10n.loginButton,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Create account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.loginCreateAccount,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.push('/register');
                                },
                          child: Text(
                            l10n.loginSignUp,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkAccent
                                  : AppColors.lightAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
