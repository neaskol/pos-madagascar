import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/mobile_money_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Dialog for completing MVola or Orange Money payment
/// Shows instructions and captures transaction reference
class MobileMoneyPaymentDialog extends StatefulWidget {
  final String paymentType; // 'mvola' or 'orange_money'
  final String merchantNumber;
  final int amount;

  const MobileMoneyPaymentDialog({
    super.key,
    required this.paymentType,
    required this.merchantNumber,
    required this.amount,
  });

  @override
  State<MobileMoneyPaymentDialog> createState() =>
      _MobileMoneyPaymentDialogState();
}

class _MobileMoneyPaymentDialogState extends State<MobileMoneyPaymentDialog> {
  final _referenceController = TextEditingController();
  final _mobileMoneyService = MobileMoneyService();
  bool _isLaunching = false;
  bool _referenceEntered = false;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  bool get _isMVola => widget.paymentType == 'mvola';

  String get _title => _isMVola ? 'Paiement MVola' : 'Paiement Orange Money';

  String get _icon => _isMVola ? '📱' : '🍊';

  Color get _color => _isMVola ? Colors.blue : Colors.orange;

  Future<void> _launchMobileMoneyApp() async {
    setState(() => _isLaunching = true);

    bool success = false;

    if (_isMVola) {
      // Try USSD first (most reliable)
      success = await _mobileMoneyService.launchMVolaUSSD(
        merchantNumber: widget.merchantNumber,
        amount: widget.amount,
      );

      // If USSD failed, try app
      if (!success) {
        success = await _mobileMoneyService.launchMVolaPayment(
          merchantNumber: widget.merchantNumber,
          amount: widget.amount,
        );
      }
    } else {
      success = await _mobileMoneyService.launchOrangeMoneyPayment(
        merchantNumber: widget.merchantNumber,
        amount: widget.amount,
      );
    }

    setState(() => _isLaunching = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isMVola
                ? 'Impossible d\'ouvrir MVola. Veuillez composer *111*1*${widget.merchantNumber}*${widget.amount}# manuellement.'
                : 'Impossible d\'ouvrir Orange Money. Veuillez composer *144*4*1*${widget.merchantNumber}*${widget.amount}# manuellement.',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  bool _validateReference() {
    final reference = _referenceController.text.trim();

    if (_isMVola) {
      return _mobileMoneyService.isValidMVolaReference(reference);
    } else {
      return _mobileMoneyService.isValidOrangeMoneyReference(reference);
    }
  }

  void _confirmPayment() {
    if (!_validateReference()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isMVola
                ? 'Numéro de transaction MVola invalide (10-12 chiffres requis)'
                : 'Code de transaction Orange Money invalide',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop(_referenceController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Text(_icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _title,
                    style: AppTypography.sectionTitle.copyWith(
                      color: _color,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount to pay
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _color),
              ),
              child: Column(
                children: [
                  Text(
                    'Montant à payer',
                    style: AppTypography.bodySmall.copyWith(color: _color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _mobileMoneyService.formatAmount(widget.amount),
                    style: AppTypography.amountLarge.copyWith(
                      color: _color,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Launch app button
            FilledButton.icon(
              onPressed: _isLaunching ? null : _launchMobileMoneyApp,
              style: FilledButton.styleFrom(
                backgroundColor: _color,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _isLaunching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.phone_android),
              label: Text(
                _isLaunching
                    ? 'Lancement en cours...'
                    : _isMVola
                        ? 'Ouvrir MVola'
                        : 'Ouvrir Orange Money',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightSurfaceHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isMVola
                    ? _mobileMoneyService.getMVolaInstructions(
                        widget.merchantNumber,
                        widget.amount,
                      )
                    : _mobileMoneyService.getOrangeMoneyInstructions(
                        widget.merchantNumber,
                        widget.amount,
                      ),
                style: AppTypography.bodySmall.copyWith(
                  height: 1.5,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Transaction reference input
            Text(
              _isMVola
                  ? 'Numéro de transaction MVola'
                  : 'Code de transaction Orange Money',
              style: AppTypography.label.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                hintText: _isMVola ? '1234567890' : 'OM12345678',
                prefixIcon: Icon(Icons.receipt_long, color: _color),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _color, width: 2),
                ),
              ),
              keyboardType: _isMVola
                  ? TextInputType.number
                  : TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: _isMVola
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : [FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]'))],
              onChanged: (value) {
                setState(() {
                  _referenceEntered = value.trim().isNotEmpty;
                });
              },
              autofocus: false,
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _referenceEntered ? _confirmPayment : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Confirmer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
