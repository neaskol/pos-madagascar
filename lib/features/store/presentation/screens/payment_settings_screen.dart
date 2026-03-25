import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/store_settings_bloc.dart';
import '../bloc/store_settings_event.dart';
import '../bloc/store_settings_state.dart';

/// Écran 47 - Types de paiement / Mobile Money Settings
/// Route: /settings/payment-types
/// Design: Obsidian/Lin naturel, Sora, Lucide Icons
class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final _mvolaController = TextEditingController();
  final _orangeMoneyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isMobileMoneyEnabled = false;
  String? _storeId;

  @override
  void initState() {
    super.initState();
    _loadStoreSettings();
  }

  void _loadStoreSettings() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthPinSessionActive) {
      _storeId = authState.user.storeId;
      if (_storeId != null) {
        context.read<StoreSettingsBloc>().add(LoadStoreSettingsEvent(_storeId!));
      }
    }
  }

  @override
  void dispose() {
    _mvolaController.dispose();
    _orangeMoneyController.dispose();
    super.dispose();
  }

  void _handleToggleMobileMoney(bool enabled) {
    if (_storeId != null) {
      context.read<StoreSettingsBloc>().add(
            ToggleMobileMoneyEvent(_storeId!, enabled),
          );
    }
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_storeId != null) {
        // Dispatch events to save merchant numbers
        context.read<StoreSettingsBloc>().add(
              UpdateMVolaMerchantNumberEvent(
                _storeId!,
                _mvolaController.text.trim().isEmpty
                    ? null
                    : _mvolaController.text.trim(),
              ),
            );
        context.read<StoreSettingsBloc>().add(
              UpdateOrangeMoneyMerchantNumberEvent(
                _storeId!,
                _orangeMoneyController.text.trim().isEmpty
                    ? null
                    : _orangeMoneyController.text.trim(),
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Text(
          l10n.settingsPaymentTypes,
          style: AppTypography.screenTitle.copyWith(color: context.textPri),
        ),
        backgroundColor: context.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPri),
      ),
      body: BlocListener<StoreSettingsBloc, StoreSettingsState>(
        listener: (context, state) {
          if (state is StoreSettingsOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            );
          } else if (state is StoreSettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.danger,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            );
          }
        },
        child: BlocBuilder<StoreSettingsBloc, StoreSettingsState>(
          builder: (context, state) {
            if (state is StoreSettingsLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: context.accent,
                ),
              );
            }

            if (state is StoreSettingsLoaded) {
              // Update controllers only when settings are loaded
              if (_mvolaController.text.isEmpty &&
                  state.settings.mvolaMerchantNumber != null) {
                _mvolaController.text = state.settings.mvolaMerchantNumber!;
              }
              if (_orangeMoneyController.text.isEmpty &&
                  state.settings.orangeMoneyMerchantNumber != null) {
                _orangeMoneyController.text =
                    state.settings.orangeMoneyMerchantNumber!;
              }
              _isMobileMoneyEnabled = state.settings.mobileMoneyEnabled == 1;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Mobile Money
                    Text(
                      'Mobile Money',
                      style: AppTypography.sectionTitle.copyWith(
                        color: context.textPri,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Toggle Mobile Money avec description
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: context.border,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.smartphone,
                                size: 20,
                                color: context.textSec,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.mobileMoneyEnabled,
                                      style: AppTypography.body.copyWith(
                                        color: context.textPri,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.mobileMoneyEnabledDescription,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: context.textSec,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isMobileMoneyEnabled,
                                onChanged: _handleToggleMobileMoney,
                                activeTrackColor: context.success,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Fields visible only when Mobile Money is enabled
                    if (_isMobileMoneyEnabled) ...[
                      const SizedBox(height: AppSpacing.xl),

                      // MVola Merchant Number
                      Text(
                        l10n.mvolaMerchantNumber,
                        style: AppTypography.label.copyWith(
                          color: context.textPri,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _mvolaController,
                        keyboardType: TextInputType.phone,
                        style: AppTypography.body.copyWith(
                          color: context.textPri,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.mvolaMerchantNumberHint,
                          hintStyle: AppTypography.hint.copyWith(
                            color: context.textHint,
                          ),
                          prefixIcon: Icon(
                            Icons.phone,
                            color: context.textSec,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: context.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            borderSide: BorderSide(
                              color: context.border,
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            borderSide: BorderSide(
                              color: context.border,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            borderSide: BorderSide(
                              color: context.textPri,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Orange Money Merchant Number
                      Text(
                        l10n.orangeMoneyMerchantNumber,
                        style: AppTypography.label.copyWith(
                          color: context.textPri,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _orangeMoneyController,
                        keyboardType: TextInputType.phone,
                        style: AppTypography.body.copyWith(
                          color: context.textPri,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.orangeMoneyMerchantNumberHint,
                          hintStyle: AppTypography.hint.copyWith(
                            color: context.textHint,
                          ),
                          prefixIcon: Icon(
                            Icons.phone,
                            color: context.textSec,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: context.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            borderSide: BorderSide(
                              color: context.border,
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            borderSide: BorderSide(
                              color: context.border,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            borderSide: BorderSide(
                              color: context.textPri,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.isDark
                                ? context.textPri
                                : context.textPri,
                            foregroundColor:
                                context.isDark ? context.bg : context.bg,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            textStyle: AppTypography.button,
                          ),
                          onPressed: _handleSave,
                          child: Text(l10n.save),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
