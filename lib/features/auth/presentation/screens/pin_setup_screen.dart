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
    bool shouldVerify = false;
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += number.toString();
          if (_confirmPin.length == 4) {
            shouldVerify = true;
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
    if (shouldVerify) {
      _verifyAndSavePin();
    }
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
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔵 [PIN SETUP] _verifyAndSavePin START');
    print('🔵 [PIN SETUP] Comparing: _pin="$_pin" vs _confirmPin="$_confirmPin"');
    if (_pin == _confirmPin) {
      print('✅ [PIN SETUP] PINs MATCH!');
      final authState = context.read<AuthBloc>().state;
      print('🔵 [PIN SETUP] Auth state type: ${authState.runtimeType}');
      if (authState is AuthAuthenticatedWithStore) {
        print('✅ [PIN SETUP] User ID: ${authState.user.id}');
        print('🔵 [PIN SETUP] Dispatching AuthPinSetupRequested...');
        context.read<AuthBloc>().add(
              AuthPinSetupRequested(
                userId: authState.user.id,
                pin: _pin,
              ),
            );
        print('✅ [PIN SETUP] AuthPinSetupRequested dispatched');
      } else {
        print('❌ [PIN SETUP] State is NOT AuthAuthenticatedWithStore!');
        print('❌ [PIN SETUP] Actual state: $authState');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur: état d\'authentification invalide (${authState.runtimeType})'),
            backgroundColor: AppColors.dangerLight,
          ),
        );
      }
    } else {
      print('❌ [PIN SETUP] PINs DO NOT MATCH!');
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
    print('🔵 [PIN SETUP] _verifyAndSavePin END');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;

    print('🔵 [PIN SETUP] build() called, auth state: ${authState.runtimeType}');

    String userName = 'Utilisateur';
    if (authState is AuthAuthenticatedWithStore) {
      userName = authState.user.name;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print('🔵 [PIN SETUP] BlocListener received state: ${state.runtimeType}');
          if (state is AuthError) {
            print('❌ [PIN SETUP] AuthError: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: isDark
                    ? AppColors.dangerDark
                    : AppColors.dangerLight,
              ),
            );
          } else if (state is AuthPinSessionActive) {
            print('✅ [PIN SETUP] AuthPinSessionActive! Navigating to /pos');
            context.go('/pos');
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Partie haute : avatar + nom + instruction + indicateurs PIN
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar utilisateur
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurfaceHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Nom utilisateur
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Instruction (créer ou confirmer)
                      Text(
                        _isConfirming
                            ? l10n.pinConfirmMessage
                            : l10n.pinCreateMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Indicateurs PIN (4 ronds)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (index) {
                            final currentPin =
                                _isConfirming ? _confirmPin : _pin;
                            final isFilled = index < currentPin.length;
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              width: 18,
                              height: 18,
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
                    ],
                  ),
                ),
              ),

              // Clavier numérique fixé en bas
              Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
                child: _buildNumPad(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumPad(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [1, 2, 3].map((n) => _buildNumButton(n, isDark)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [4, 5, 6].map((n) => _buildNumButton(n, isDark)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [7, 8, 9].map((n) => _buildNumButton(n, isDark)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 72, height: 72),
            _buildNumButton(0, isDark),
            _buildBackspaceButton(isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildNumButton(int number, bool isDark) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
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
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.backspace_outlined,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          size: 26,
        ),
      ),
    );
  }
}
