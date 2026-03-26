import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/local/app_database.dart' hide Sale;
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../customers/presentation/bloc/credit_bloc.dart';
import '../../../customers/presentation/bloc/credit_event.dart';
import '../../../store/presentation/bloc/store_settings_bloc.dart';
import '../../../store/presentation/bloc/store_settings_state.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';
import '../widgets/add_payment_dialog.dart';
import '../widgets/credit_sale_dialog.dart';
import '../widgets/customer_picker_dialog.dart';
import '../widgets/mobile_money_payment_dialog.dart';
import 'receipt_screen.dart';

/// Mode de paiement
enum PaymentMode {
  single, // Paiement unique (comportement par défaut)
  split,  // Multi-paiement (division en plusieurs méthodes)
}

/// Représente un paiement partiel dans le mode split
class PartialPayment {
  final PaymentType type;
  final int amount;
  final String? reference;

  const PartialPayment({
    required this.type,
    required this.amount,
    this.reference,
  });
}

/// Écran de paiement - Phase 3.2 (Multi-paiement)
class PaymentScreen extends StatefulWidget {
  final List<CartItem> items;
  final int subtotal;
  final int taxAmount;
  final int discountAmount;
  final int total;

  const PaymentScreen({
    super.key,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Mode de paiement (single/split)
  PaymentMode _paymentMode = PaymentMode.single;

  // État pour mode single (paiement unique)
  PaymentType _selectedPaymentType = PaymentType.cash;
  int _amountReceived = 0;
  final TextEditingController _amountController = TextEditingController();

  // État pour mode split (multi-paiement)
  final List<PartialPayment> _partialPayments = [];

  // Client sélectionné (pour vente à crédit)
  Customer? _selectedCustomer;

  // Note optionnelle pour la vente
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Calculs pour mode single
  int get _changeDue => _amountReceived - widget.total;

  // Calculs pour mode split
  int get _totalPaid => _partialPayments.fold(
        0,
        (sum, payment) => sum + payment.amount,
      );

  int get _remainingAmount => widget.total - _totalPaid;

  bool get _isSplitPaymentComplete => _remainingAmount == 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleBloc, SaleState>(
      listener: (context, state) {
        if (state is SaleCreated) {
          // Paiement réussi - afficher confirmation et retourner à la caisse
          _showPaymentSuccessDialog(context, state.sale);
        } else if (state is SaleError) {
          // Erreur - afficher message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.paymentTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            // Dropdown pour choisir le mode de paiement
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: DropdownButton<PaymentMode>(
                value: _paymentMode,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: PaymentMode.single,
                    child: Row(
                      children: [
                        const Icon(Icons.payment, size: 20),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.paymentSingle),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: PaymentMode.split,
                    child: Row(
                      children: [
                        const Icon(Icons.splitscreen, size: 20),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.paymentSplit),
                      ],
                    ),
                  ),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    setState(() {
                      _paymentMode = mode;
                      // Reset state when switching modes
                      _amountReceived = 0;
                      _amountController.clear();
                      _partialPayments.clear();
                    });
                  }
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Total à payer (grand, en haut)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.paymentTotalToPay,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(widget.total),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _paymentMode == PaymentMode.single
                    ? _buildSinglePaymentUI()
                    : _buildSplitPaymentUI(),
              ),
            ),

            // Bouton valider paiement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BlocBuilder<SaleBloc, SaleState>(
                builder: (context, state) {
                  final isProcessing = state is SaleCreating;

                  // Validation différente selon le mode
                  bool canPay;
                  if (_paymentMode == PaymentMode.split) {
                    canPay = _isSplitPaymentComplete;
                  } else if (_selectedPaymentType == PaymentType.cash) {
                    canPay = _amountReceived >= widget.total;
                  } else if (_selectedPaymentType == PaymentType.credit) {
                    canPay = true; // Credit flow handles its own validation via dialogs
                  } else {
                    canPay = true; // Card, MVola, Orange Money validated via their dialogs
                  }

                  return FilledButton(
                    onPressed: canPay && !isProcessing
                        ? () => _processPayment(context)
                        : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.paymentValidate,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI pour mode single (paiement unique)
  Widget _buildSinglePaymentUI() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section type de paiement
        Text(
          l10n.paymentType,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildPaymentTypeGrid(),
        const SizedBox(height: 24),

        // Section Crédit — afficher client sélectionné ou bouton sélectionner
        if (_selectedPaymentType == PaymentType.credit) ...[
          _buildCreditCustomerSection(l10n),
          const SizedBox(height: 24),
        ],

        // Section Cash (si sélectionné)
        if (_selectedPaymentType == PaymentType.cash) ...[
          Text(
            l10n.paymentAmountReceived,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildCashSuggestedAmounts(),
          const SizedBox(height: 12),
          _buildCustomAmountInput(),
          const SizedBox(height: 24),

          // Monnaie à rendre
          if (_amountReceived > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _changeDue >= 0
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _changeDue >= 0 ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.changeDue,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _changeDue >= 0
                              ? Colors.green[900]
                              : Colors.red[900],
                        ),
                  ),
                  Text(
                    _formatPrice(_changeDue.abs()),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _changeDue >= 0
                              ? Colors.green[900]
                              : Colors.red[900],
                        ),
                  ),
                ],
              ),
            ),
            if (_changeDue < 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.paymentInsufficient,
                  style: TextStyle(
                    color: Colors.red[900],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ],

        // Note optionnelle (en bas, pour tous types de paiement)
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          l10n.noteOptional,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: l10n.paymentNoteHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            helperText: l10n.paymentNoteHelper,
          ),
        ),
      ],
    );
  }

  // UI pour mode split (multi-paiement)
  Widget _buildSplitPaymentUI() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Montant restant (grand, visible)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _remainingAmount > 0
                ? Colors.orange.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _remainingAmount > 0 ? Colors.orange : Colors.green,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                _remainingAmount > 0 ? l10n.paymentRemainingAmount : l10n.paymentComplete,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _formatPrice(_remainingAmount),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _remainingAmount > 0
                          ? Colors.orange[900]
                          : Colors.green[900],
                    ),
              ),
              if (_totalPaid > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Payé: ${_formatPrice(_totalPaid)} / ${_formatPrice(widget.total)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Liste des paiements partiels
        if (_partialPayments.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.paymentAdded,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${_partialPayments.length} paiement${_partialPayments.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._partialPayments.asMap().entries.map((entry) {
            final index = entry.key;
            final payment = entry.value;
            return _buildPartialPaymentCard(payment, index);
          }),
          const SizedBox(height: 24),
        ],

        // Bouton ajouter paiement
        if (_remainingAmount > 0)
          OutlinedButton.icon(
            onPressed: () => _showAddPaymentDialog(),
            icon: const Icon(Icons.add),
            label: Text(l10n.paymentAddPayment),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

        // Message si aucun paiement
        if (_partialPayments.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.splitscreen,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.paymentSplitDescription,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.paymentSplitMethods,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

        // Note optionnelle (en bas, pour tous modes)
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          l10n.noteOptional,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: l10n.paymentNoteHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            helperText: l10n.paymentNoteHelper,
          ),
        ),
      ],
    );
  }

  // Card pour afficher un paiement partiel
  Widget _buildPartialPaymentCard(PartialPayment payment, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getPaymentTypeIcon(payment.type),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(_getPaymentTypeLabel(payment.type)),
        subtitle: payment.reference != null
            ? Text(
                'Réf: ${payment.reference}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatPrice(payment.amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => _removePartialPayment(index),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTypeGrid() {
    final l10n = AppLocalizations.of(context)!;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildPaymentTypeCard(
          type: PaymentType.cash,
          label: l10n.paymentCash,
          icon: Icons.payments,
        ),
        _buildPaymentTypeCard(
          type: PaymentType.card,
          label: l10n.paymentCard,
          icon: Icons.credit_card,
        ),
        _buildPaymentTypeCard(
          type: PaymentType.mvola,
          label: l10n.paymentMvola,
          icon: Icons.phone_android,
        ),
        _buildPaymentTypeCard(
          type: PaymentType.orangeMoney,
          label: l10n.paymentOrangeMoney,
          icon: Icons.phone_iphone,
        ),
        _buildPaymentTypeCard(
          type: PaymentType.credit,
          label: l10n.creditSale,
          icon: Icons.account_balance_wallet,
        ),
      ],
    );
  }

  Widget _buildPaymentTypeCard({
    required PaymentType type,
    required String label,
    required IconData icon,
    bool enabled = true,
  }) {
    final isSelected = _selectedPaymentType == type;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Colors.white,
      child: InkWell(
        onTap: enabled
            ? () {
                setState(() {
                  _selectedPaymentType = type;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black87,
                        ),
                      ),
                      if (!enabled)
                        Text(
                          'À venir',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCashSuggestedAmounts() {
    final suggestions = [
      widget.total, // montant exact
      if (widget.total < 2000) 2000,
      if (widget.total < 5000) 5000,
      if (widget.total < 10000) 10000,
      if (widget.total < 20000) 20000,
      if (widget.total < 50000) 50000,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((amount) {
        final isSelected = _amountReceived == amount;
        return FilterChip(
          label: Text(_formatPrice(amount)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _amountReceived = amount;
              _amountController.text = amount.toString();
            });
          },
          backgroundColor: Colors.grey[100],
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildCustomAmountInput() {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: l10n.paymentCustomAmount,
        hintText: l10n.paymentCustomAmountHint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixText: 'Ar',
      ),
      onChanged: (value) {
        setState(() {
          _amountReceived = int.tryParse(value) ?? 0;
        });
      },
    );
  }

  // Section crédit : afficher le client sélectionné ou inviter à en choisir un
  Widget _buildCreditCustomerSection(AppLocalizations l10n) {
    if (_selectedCustomer != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: Text(
                _selectedCustomer!.name.isNotEmpty
                    ? _selectedCustomer!.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCustomer!.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (_selectedCustomer!.phone != null)
                    Text(
                      _selectedCustomer!.phone!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                final customer = await showDialog<Customer>(
                  context: context,
                  builder: (context) => const CustomerPickerDialog(),
                );
                if (customer != null) {
                  setState(() {
                    _selectedCustomer = customer;
                  });
                }
              },
              child: Text(l10n.changeCustomer),
            ),
          ],
        ),
      );
    }

    // Aucun client sélectionné
    return OutlinedButton.icon(
      onPressed: () async {
        final customer = await showDialog<Customer>(
          context: context,
          builder: (context) => const CustomerPickerDialog(),
        );
        if (customer != null) {
          setState(() {
            _selectedCustomer = customer;
          });
        }
      },
      icon: const Icon(Icons.person_add),
      label: Text(l10n.selectCustomerForCredit),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        foregroundColor: Colors.blue,
        side: const BorderSide(color: Colors.blue),
      ),
    );
  }

  // Afficher le dialog pour ajouter un paiement partiel
  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AddPaymentDialog(
        remainingAmount: _remainingAmount,
        onAdd: (type, amount, reference) {
          setState(() {
            _partialPayments.add(
              PartialPayment(
                type: type,
                amount: amount,
                reference: reference,
              ),
            );
          });
        },
      ),
    );
  }

  // Retirer un paiement partiel
  void _removePartialPayment(int index) {
    setState(() {
      _partialPayments.removeAt(index);
    });
  }

  // Obtenir le label d'un type de paiement
  String _getPaymentTypeLabel(PaymentType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case PaymentType.cash:
        return l10n.paymentCash;
      case PaymentType.card:
        return l10n.paymentCard;
      case PaymentType.mvola:
        return l10n.paymentMvola;
      case PaymentType.orangeMoney:
        return l10n.paymentOrangeMoney;
      case PaymentType.credit:
        return l10n.creditSale;
      case PaymentType.custom:
        return l10n.paymentOther;
    }
  }

  // Obtenir l'icône d'un type de paiement
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

  Future<void> _processPayment(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;

    String? storeId;
    String? employeeId;
    if (authState is AuthAuthenticatedWithStore) {
      storeId = authState.storeId;
      employeeId = authState.user.id;
    } else if (authState is AuthPinSessionActive) {
      storeId = authState.user.storeId;
      employeeId = authState.user.id;
    }

    if (storeId == null || employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.paymentErrorNotAuthenticated)),
      );
      return;
    }

    // Récupérer la note (vide si non renseignée)
    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    if (_paymentMode == PaymentMode.single) {
      // --- CREDIT SALE FLOW ---
      if (_selectedPaymentType == PaymentType.credit) {
        await _processCreditPayment(context, storeId, employeeId, note);
        return;
      }

      // --- MOBILE MONEY FLOW ---
      if (_selectedPaymentType == PaymentType.mvola ||
          _selectedPaymentType == PaymentType.orangeMoney) {
        final settingsState = context.read<StoreSettingsBloc>().state;

        if (settingsState is! StoreSettingsLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.paymentErrorStoreSettings)),
          );
          return;
        }

        final merchantNumber = _selectedPaymentType == PaymentType.mvola
            ? settingsState.settings.mvolaMerchantNumber
            : settingsState.settings.orangeMoneyMerchantNumber;

        if (merchantNumber == null || merchantNumber.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedPaymentType == PaymentType.mvola
                    ? l10n.paymentErrorMvolaMerchant
                    : l10n.paymentErrorOrangeMoneyMerchant,
              ),
              action: SnackBarAction(
                label: l10n.paymentConfigure,
                onPressed: () {
                  context.go('/settings/payment-types');
                },
              ),
            ),
          );
          return;
        }

        final reference = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => MobileMoneyPaymentDialog(
            paymentType: _selectedPaymentType == PaymentType.mvola ? 'mvola' : 'orange_money',
            merchantNumber: merchantNumber,
            amount: widget.total,
          ),
        );

        if (reference == null) return;

        if (context.mounted) {
          context.read<SaleBloc>().add(
                CreateSaleEvent(
                  storeId: storeId,
                  employeeId: employeeId,
                  items: widget.items,
                  subtotal: widget.subtotal,
                  taxAmount: widget.taxAmount,
                  discountAmount: widget.discountAmount,
                  total: widget.total,
                  paymentType: _selectedPaymentType,
                  amountReceived: widget.total,
                  paymentReference: reference,
                  note: note,
                ),
              );
        }
      } else {
        // --- CASH / CARD FLOW ---
        context.read<SaleBloc>().add(
              CreateSaleEvent(
                storeId: storeId,
                employeeId: employeeId,
                items: widget.items,
                subtotal: widget.subtotal,
                taxAmount: widget.taxAmount,
                discountAmount: widget.discountAmount,
                total: widget.total,
                paymentType: _selectedPaymentType,
                amountReceived: _amountReceived,
                note: note,
              ),
            );
      }
    } else {
      // --- MULTI-PAYMENT FLOW ---
      final paymentDataList = _partialPayments
          .map((p) => PaymentData(
                type: p.type,
                amount: p.amount,
                reference: p.reference,
              ))
          .toList();

      context.read<SaleBloc>().add(
            CreateSaleEvent(
              storeId: storeId,
              employeeId: employeeId,
              items: widget.items,
              subtotal: widget.subtotal,
              taxAmount: widget.taxAmount,
              discountAmount: widget.discountAmount,
              total: widget.total,
              payments: paymentDataList,
              note: note,
            ),
          );
    }
  }

  /// Process credit sale: customer picker → credit sale dialog → create sale + credit
  Future<void> _processCreditPayment(
    BuildContext context,
    String storeId,
    String employeeId,
    String? note,
  ) async {
    // Step 1: Select customer (or use already selected)
    Customer? customer = _selectedCustomer;
    if (customer == null) {
      customer = await showDialog<Customer>(
        context: context,
        builder: (context) => const CustomerPickerDialog(),
      );

      if (customer == null || !context.mounted) return;

      setState(() {
        _selectedCustomer = customer;
      });
    }

    // Step 2: Show credit sale dialog (due date + notes)
    if (!context.mounted) return;
    final creditResult = await showDialog<CreditSaleResult>(
      context: context,
      builder: (context) => CreditSaleDialog(
        customerName: customer!.name,
        totalAmount: widget.total,
      ),
    );

    if (creditResult == null || !context.mounted) return;

    // Step 3: Create the sale with credit payment type
    context.read<SaleBloc>().add(
          CreateSaleEvent(
            storeId: storeId,
            employeeId: employeeId,
            items: widget.items,
            subtotal: widget.subtotal,
            taxAmount: widget.taxAmount,
            discountAmount: widget.discountAmount,
            total: widget.total,
            paymentType: PaymentType.credit,
            amountReceived: 0, // No cash received for credit
            customerId: customer.id,
            note: note ?? creditResult.notes,
          ),
        );

    // Step 4: Create the credit record
    context.read<CreditBloc>().add(
          CreateCreditEvent(
            storeId: storeId,
            customerId: customer.id,
            amountTotal: widget.total,
            dueDate: creditResult.dueDate,
            notes: creditResult.notes,
            createdBy: employeeId,
          ),
        );
  }

  void _showPaymentSuccessDialog(BuildContext context, Sale sale) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        title: Text(l10n.paymentSuccess),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.receiptNumber(sale.receiptNumber)),
            const SizedBox(height: 16),
            if (sale.changeDue > 0) ...[
              Text(l10n.changeDueLabel),
              Text(
                _formatPrice(sale.changeDue),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Fermer dialog et retourner à la caisse
              Navigator.of(dialogContext).pop();
              context.go('/pos');
            },
            child: Text(l10n.newSale),
          ),
          FilledButton(
            onPressed: () {
              // Fermer le dialog et afficher le reçu
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ReceiptScreen(sale: sale),
                ),
              );
            },
            child: Text(l10n.viewReceipt),
          ),
        ],
      );
      },
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
