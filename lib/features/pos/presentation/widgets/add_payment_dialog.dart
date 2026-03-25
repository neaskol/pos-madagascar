import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sale.dart';
import '../../../store/presentation/bloc/store_settings_bloc.dart';
import '../../../store/presentation/bloc/store_settings_state.dart';
import 'mobile_money_payment_dialog.dart';

/// Dialog pour ajouter un paiement partiel dans le mode multi-paiement
class AddPaymentDialog extends StatefulWidget {
  final int remainingAmount;
  final Function(PaymentType type, int amount, String? reference) onAdd;

  const AddPaymentDialog({
    super.key,
    required this.remainingAmount,
    required this.onAdd,
  });

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  PaymentType _selectedType = PaymentType.cash;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  int _amount = 0;

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec le montant restant
    _amount = widget.remainingAmount;
    _amountController.text = widget.remainingAmount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  bool get _canAdd =>
      _amount > 0 && _amount <= widget.remainingAmount && _isReferenceValid();

  bool _isReferenceValid() {
    // MVola et Orange Money nécessitent une référence
    if (_selectedType == PaymentType.mvola ||
        _selectedType == PaymentType.orangeMoney) {
      return _referenceController.text.trim().isNotEmpty;
    }
    return true;
  }

  String _getPaymentTypeLabel(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return 'Espèces';
      case PaymentType.card:
        return 'Carte bancaire';
      case PaymentType.mvola:
        return 'MVola';
      case PaymentType.orangeMoney:
        return 'Orange Money';
      case PaymentType.credit:
        return 'Crédit';
      case PaymentType.custom:
        return 'Autre';
    }
  }

  IconData _getPaymentTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Icons.payments;
      case PaymentType.card:
        return Icons.credit_card;
      case PaymentType.mvola:
        return Icons.phone_android;
      case PaymentType.orangeMoney:
        return Icons.phone_iphone;
      case PaymentType.credit:
        return Icons.account_balance_wallet;
      case PaymentType.custom:
        return Icons.payment;
    }
  }

  String? _getReferenceHint(PaymentType type) {
    switch (type) {
      case PaymentType.mvola:
        return 'Ex: Transaction #12345';
      case PaymentType.orangeMoney:
        return 'Ex: Référence OM #67890';
      case PaymentType.card:
        return 'Ex: 4 derniers chiffres (optionnel)';
      default:
        return null;
    }
  }

  bool _requiresReference(PaymentType type) {
    return type == PaymentType.mvola || type == PaymentType.orangeMoney;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.add_card,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ajouter un paiement',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Méthode de paiement
              Text(
                'Méthode de paiement',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildPaymentTypesList(),

              const SizedBox(height: 24),

              // Montant
              Text(
                'Montant',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Montant en Ariary',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixText: 'Ar',
                  errorText: _amount > widget.remainingAmount
                      ? 'Montant supérieur au restant'
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _amount = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 8),

              // Bouton montant suggéré
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _amount = widget.remainingAmount;
                      _amountController.text = widget.remainingAmount.toString();
                    });
                  },
                  icon: const Icon(Icons.auto_fix_high, size: 16),
                  label: Text(
                    'Montant suggéré: ${_formatPrice(widget.remainingAmount)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),

              // Référence (si nécessaire)
              if (_getReferenceHint(_selectedType) != null) ...[
                const SizedBox(height: 16),
                Text(
                  _requiresReference(_selectedType)
                      ? 'Référence *'
                      : 'Référence (optionnelle)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    hintText: _getReferenceHint(_selectedType),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.receipt_long),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Force rebuild pour validation
                    });
                  },
                ),
                if (_requiresReference(_selectedType) &&
                    _referenceController.text.trim().isEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Référence obligatoire pour ${_getPaymentTypeLabel(_selectedType)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _canAdd
                        ? () async {
                            HapticFeedback.mediumImpact();

                            // Si c'est MVola ou Orange Money, utiliser le dialog dédié
                            if (_selectedType == PaymentType.mvola ||
                                _selectedType == PaymentType.orangeMoney) {
                              final settingsState = context.read<StoreSettingsBloc>().state;

                              if (settingsState is! StoreSettingsLoaded) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Erreur: impossible de charger les réglages'),
                                    ),
                                  );
                                }
                                return;
                              }

                              final merchantNumber = _selectedType == PaymentType.mvola
                                  ? settingsState.settings.mvolaMerchantNumber
                                  : settingsState.settings.orangeMoneyMerchantNumber;

                              if (merchantNumber == null || merchantNumber.isEmpty) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _selectedType == PaymentType.mvola
                                            ? 'Numéro marchand MVola non configuré'
                                            : 'Numéro marchand Orange Money non configuré',
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }

                              // Afficher le dialog mobile money
                              final reference = await showDialog<String>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => MobileMoneyPaymentDialog(
                                  paymentType: _selectedType == PaymentType.mvola
                                      ? 'mvola'
                                      : 'orange_money',
                                  merchantNumber: merchantNumber,
                                  amount: _amount,
                                ),
                              );

                              if (reference != null && mounted) {
                                widget.onAdd(_selectedType, _amount, reference);
                                Navigator.of(context).pop();
                              }
                            } else {
                              // Autres types de paiement
                              final reference = _referenceController.text.trim();
                              widget.onAdd(
                                _selectedType,
                                _amount,
                                reference.isEmpty ? null : reference,
                              );
                              Navigator.of(context).pop();
                            }
                          }
                        : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTypesList() {
    return Column(
      children: PaymentType.values.map((type) {
        // Exclure "custom" de la liste
        if (type == PaymentType.custom) return const SizedBox.shrink();

        return RadioListTile<PaymentType>(
          value: type,
          groupValue: _selectedType,
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
              _referenceController.clear(); // Clear reference on type change
            });
          },
          title: Row(
            children: [
              Icon(
                _getPaymentTypeIcon(type),
                size: 20,
                color: _selectedType == type
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Text(_getPaymentTypeLabel(type)),
            ],
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  String _formatPrice(int amount) {
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        );
    return '$formatted Ar';
  }
}
