import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';
import '../widgets/add_payment_dialog.dart';
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
          title: const Text('Paiement'),
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
                items: const [
                  DropdownMenuItem(
                    value: PaymentMode.single,
                    child: Row(
                      children: [
                        Icon(Icons.payment, size: 20),
                        SizedBox(width: 8),
                        Text('Paiement unique'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: PaymentMode.split,
                    child: Row(
                      children: [
                        Icon(Icons.splitscreen, size: 20),
                        SizedBox(width: 8),
                        Text('Multi-paiement'),
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
                    'Total à payer',
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
                  final canPay = _paymentMode == PaymentMode.single
                      ? _selectedPaymentType == PaymentType.cash &&
                          _amountReceived >= widget.total
                      : _isSplitPaymentComplete;

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
                        : const Text(
                            'VALIDER LE PAIEMENT',
                            style: TextStyle(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section type de paiement
        Text(
          'Type de paiement',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildPaymentTypeGrid(),
        const SizedBox(height: 24),

        // Section Cash (si sélectionné)
        if (_selectedPaymentType == PaymentType.cash) ...[
          Text(
            'Montant reçu',
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
                    'Monnaie à rendre',
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
                  'Montant insuffisant',
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
          'Note (optionnel)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Ajouter une note à cette vente...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            helperText: 'Cette note apparaîtra sur le reçu',
          ),
        ),
      ],
    );
  }

  // UI pour mode split (multi-paiement)
  Widget _buildSplitPaymentUI() {
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
                _remainingAmount > 0 ? 'Montant restant' : 'Paiement complet',
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
                'Paiements ajoutés',
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
            label: const Text('Ajouter un paiement'),
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
                  'Divisez le paiement en plusieurs méthodes',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Espèces, Carte, MVola, Orange Money',
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
          'Note (optionnel)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Ajouter une note à cette vente...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            helperText: 'Cette note apparaîtra sur le reçu',
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
          label: 'Espèces',
          icon: Icons.payments,
        ),
        _buildPaymentTypeCard(
          type: PaymentType.card,
          label: 'Carte bancaire',
          icon: Icons.credit_card,
          enabled: true, // Phase 3.2 - Activé
        ),
        _buildPaymentTypeCard(
          type: PaymentType.mvola,
          label: 'MVola',
          icon: Icons.phone_android,
          enabled: true, // Phase 3.2 - Activé
        ),
        _buildPaymentTypeCard(
          type: PaymentType.orangeMoney,
          label: 'Orange Money',
          icon: Icons.phone_iphone,
          enabled: true, // Phase 3.2 - Activé
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
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Ou montant personnalisé',
        hintText: 'Montant en Ariary',
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
    switch (type) {
      case PaymentType.cash:
        return 'Espèces';
      case PaymentType.card:
        return 'Carte bancaire';
      case PaymentType.mvola:
        return 'MVola';
      case PaymentType.orangeMoney:
        return 'Orange Money';
      case PaymentType.custom:
        return 'Autre';
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
      case PaymentType.custom:
        return Icons.payment;
    }
  }

  void _processPayment(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticatedWithStore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: utilisateur non authentifié')),
      );
      return;
    }

    // Récupérer la note (vide si non renseignée)
    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    if (_paymentMode == PaymentMode.single) {
      // Mode single payment (comportement original)
      context.read<SaleBloc>().add(
            CreateSaleEvent(
              storeId: authState.storeId,
              employeeId: authState.user.id,
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
    } else {
      // Mode multi-payment (nouveau)
      final paymentDataList = _partialPayments
          .map((p) => PaymentData(
                type: p.type,
                amount: p.amount,
                reference: p.reference,
              ))
          .toList();

      context.read<SaleBloc>().add(
            CreateSaleEvent(
              storeId: authState.storeId,
              employeeId: authState.user.id,
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

  void _showPaymentSuccessDialog(BuildContext context, Sale sale) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        title: const Text('Paiement réussi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reçu N° ${sale.receiptNumber}'),
            const SizedBox(height: 16),
            if (sale.changeDue > 0) ...[
              const Text('Monnaie à rendre:'),
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
            child: const Text('Nouvelle vente'),
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
            child: const Text('Voir reçu'),
          ),
        ],
      ),
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
