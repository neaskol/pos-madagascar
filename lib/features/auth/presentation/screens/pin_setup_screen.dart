import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Écran de configuration INITIALE du PIN après le setup wizard
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;

  void _onNumberPressed(int number) {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += number.toString();
          if (_confirmPin.length == 4) {
            _verifyAndSavePin();
          }
        }
      } else {
        if (_pin.length < 4) {
          _pin += number.toString();
          if (_pin.length == 4) {
            _isConfirming = true;
          }
        }
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirming = false;
          _pin = '';
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  void _verifyAndSavePin() {
    if (_pin == _confirmPin) {
      // PINs correspondent — enregistrer
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticatedWithStore) {
        context.read<AuthBloc>().add(
              AuthPinSetupRequested(
                userId: authState.user.id,
                pin: _pin,
              ),
            );
      }
    } else {
      // PINs ne correspondent pas
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pinMismatch),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.dangerDark
              : AppColors.dangerLight,
        ),
      );
      setState(() {
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;

    // Récupérer le nom de l'utilisateur
    String userName = 'Utilisateur';
    if (authState is AuthAuthenticatedWithStore) {
      userName = authState.user.name;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
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
          } else if (state is AuthPinSessionActive) {
            // PIN configuré avec succès → rediriger vers POS
            context.go('/pos');
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Titre
              Text(
                l10n.pinSetupTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),

              const SizedBox(height: 48),

              // Avatar utilisateur
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurfaceHigh,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Nom utilisateur
              Text(
                userName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),

              const SizedBox(height: 48),

              // Instruction
              Text(
                _isConfirming ? l10n.pinConfirmMessage : l10n.pinCreateMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Indicateurs PIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) {
                    final currentPin = _isConfirming ? _confirmPin : _pin;
                    final isFilled = index < currentPin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled
                            ? (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary)
                            : Colors.transparent,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),

              // Clavier numérique
              _buildNumPad(isDark),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumPad(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Ligne 1-2-3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3].map((n) => _buildNumButton(n, isDark)).toList(),
          ),
          const SizedBox(height: 16),
          // Ligne 4-5-6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [4, 5, 6].map((n) => _buildNumButton(n, isDark)).toList(),
          ),
          const SizedBox(height: 16),
          // Ligne 7-8-9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [7, 8, 9].map((n) => _buildNumButton(n, isDark)).toList(),
          ),
          const SizedBox(height: 16),
          // Ligne vide-0-backspace
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80, height: 80), // Espacement
              _buildNumButton(0, isDark),
              _buildBackspaceButton(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumButton(int number, bool isDark) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceHigh,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(bool isDark) {
    return InkWell(
      onTap: _onBackspacePressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.backspace_outlined,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          size: 28,
        ),
      ),
    );
  }
}
