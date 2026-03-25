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
import 'receipt_screen.dart';

/// Écran de paiement - Phase 2.3 (Cash uniquement)
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
  PaymentType _selectedPaymentType = PaymentType.cash;
  int _amountReceived = 0;
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _changeDue => _amountReceived - widget.total;

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
                child: Column(
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
                              color: _changeDue >= 0
                                  ? Colors.green
                                  : Colors.red,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Monnaie à rendre',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: _changeDue >= 0
                                          ? Colors.green[900]
                                          : Colors.red[900],
                                    ),
                              ),
                              Text(
                                _formatPrice(_changeDue.abs()),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
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
                  ],
                ),
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
                  final canPay = _selectedPaymentType == PaymentType.cash &&
                      _amountReceived >= widget.total;

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
          enabled: false, // Phase future
        ),
        _buildPaymentTypeCard(
          type: PaymentType.mvola,
          label: 'MVola',
          icon: Icons.phone_android,
          enabled: false, // Phase future
        ),
        _buildPaymentTypeCard(
          type: PaymentType.orangeMoney,
          label: 'Orange Money',
          icon: Icons.phone_iphone,
          enabled: false, // Phase future
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

  void _processPayment(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticatedWithStore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: utilisateur non authentifié')),
      );
      return;
    }

    // Créer la vente
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
          ),
        );
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
