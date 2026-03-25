import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';

class CreditPaymentDialog extends StatefulWidget {
  final Credit credit;

  const CreditPaymentDialog({
    super.key,
    required this.credit,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context,
    Credit credit,
  ) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreditPaymentDialog(credit: credit),
    );
  }

  @override
  State<CreditPaymentDialog> createState() => _CreditPaymentDialogState();
}

class _CreditPaymentDialogState extends State<CreditPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  String _paymentType = 'Especes';
  final List<String> _paymentTypes = [
    'Especes',
    'Carte',
    'MVola',
    'Orange Money',
  ];

  final _numberFormat = NumberFormat('#,###', 'fr');

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setQuickAmount(int amount) {
    _amountController.text = amount.toString();
  }

  void _handleConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^\d]'), ''));
      if (amount == null || amount <= 0) return;

      Navigator.pop(
        context,
        {
          'amount': amount,
          'paymentType': _paymentType,
          'reference': _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim(),
          'notes': _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        },
      );
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir un montant';
    }

    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    final amount = int.tryParse(cleanValue);

    if (amount == null || amount <= 0) {
      return 'Montant invalide';
    }

    if (amount > widget.credit.amountRemaining) {
      return 'Montant superieur au reste du';
    }

    return null;
  }

  InputDecoration _buildInputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTypography.hint.copyWith(color: context.textHint),
      filled: true,
      fillColor: context.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: context.border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: context.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: context.textPri, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: context.danger),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.payments_outlined,
                      color: context.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Enregistrer un paiement',
                      style: AppTypography.sectionTitle.copyWith(
                        color: context.textPri,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.textSec),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Credit Info
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.bg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: context.border, width: 0.5),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Montant total',
                      '${_numberFormat.format(widget.credit.amountTotal)} Ar',
                      highlight: false,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoRow(
                      'Deja paye',
                      '${_numberFormat.format(widget.credit.amountPaid)} Ar',
                      highlight: false,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Divider(color: context.border),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoRow(
                      'Reste a payer',
                      '${_numberFormat.format(widget.credit.amountRemaining)} Ar',
                      highlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Payment Amount
              Text(
                'Montant du paiement',
                style: AppTypography.label.copyWith(
                  color: context.textPri,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: _buildInputDecoration(hintText: '0').copyWith(
                  suffixText: 'Ar',
                ),
                style: AppTypography.body.copyWith(color: context.textPri),
                validator: _validateAmount,
              ),
              const SizedBox(height: AppSpacing.md),

              // Quick Amount Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAmountButton(
                      '100%',
                      widget.credit.amountRemaining,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildQuickAmountButton(
                      '50%',
                      (widget.credit.amountRemaining * 0.5).round(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildQuickAmountButton(
                      '25%',
                      (widget.credit.amountRemaining * 0.25).round(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Payment Type
              Text(
                'Mode de paiement',
                style: AppTypography.label.copyWith(
                  color: context.textPri,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                value: _paymentType,
                decoration: _buildInputDecoration(),
                style: AppTypography.body.copyWith(color: context.textPri),
                dropdownColor: context.surface,
                items: _paymentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _paymentType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Payment Reference (for mobile money)
              if (_paymentType == 'MVola' || _paymentType == 'Orange Money') ...[
                Text(
                  'Reference de paiement',
                  style: AppTypography.label.copyWith(
                    color: context.textPri,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _referenceController,
                  decoration: _buildInputDecoration(
                    hintText: 'Numero de transaction (optionnel)',
                  ),
                  style: AppTypography.body.copyWith(color: context.textPri),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Notes
              Text(
                'Notes',
                style: AppTypography.label.copyWith(
                  color: context.textPri,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  hintText: 'Remarques (optionnel)',
                ),
                style: AppTypography.body.copyWith(color: context.textPri),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                    child: Text(
                      'Annuler',
                      style: AppTypography.body.copyWith(
                        color: context.textSec,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ElevatedButton(
                    onPressed: _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.textPri,
                      foregroundColor: context.bg,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Confirmer',
                      style: AppTypography.button,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: highlight ? context.textPri : context.textSec,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppTypography.body.copyWith(
            color: highlight ? context.accent : context.textPri,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountButton(
    String label,
    int amount,
  ) {
    return OutlinedButton(
      onPressed: () => _setQuickAmount(amount),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: context.border),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: context.textPri,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${_numberFormat.format(amount)} Ar',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSec,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
