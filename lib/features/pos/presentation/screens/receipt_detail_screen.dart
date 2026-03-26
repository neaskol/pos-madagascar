import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/refund_bloc.dart';
import '../bloc/refund_event.dart';
import '../bloc/refund_state.dart';

/// Écran 13 : Détail d'un reçu avec option remboursement
class ReceiptDetailScreen extends StatefulWidget {
  final String receiptId;

  const ReceiptDetailScreen({
    super.key,
    required this.receiptId,
  });

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Vérifier si le reçu a déjà été remboursé
    context.read<RefundBloc>().add(LoadRefundsBySale(widget.receiptId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.receiptDetail,
          style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          // Menu plus d'options
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (value) {
              switch (value) {
                case 'print':
                  // TODO: Imprimer le reçu
                  break;
                case 'whatsapp':
                  // TODO: Envoyer par WhatsApp
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print, size: 20, color: AppColors.textPrimary),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(l10n.print),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'whatsapp',
                child: Row(
                  children: [
                    Icon(Icons.send, size: 20, color: AppColors.textPrimary),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(l10n.sendWhatsApp),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<RefundBloc, RefundState>(
        listener: (context, state) {
          if (state is RefundError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          final isRefunded = state is RefundLoaded && state.isSaleRefunded;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header du reçu
                      _buildReceiptHeader(l10n),
                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Liste des items
                      _buildItemsList(l10n),
                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Totaux
                      _buildTotals(l10n),
                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Modes de paiement
                      _buildPaymentMethods(l10n),

                      // Message si déjà remboursé
                      if (isRefunded) ...[
                        const SizedBox(height: AppDimensions.paddingLarge),
                        _buildRefundedMessage(l10n, state as RefundLoaded),
                      ],
                    ],
                  ),
                ),
              ),

              // Bouton remboursement en bas
              _buildRefundButton(l10n, isRefunded),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReceiptHeader(AppLocalizations l10n) {
    // TODO: Charger les vraies données depuis le BLoC
    final receiptNumber = '20260326-0001';
    final dateTime = DateTime.now();
    final employee = 'Jean Rakoto';
    final cashRegister = 'Caisse 1';

    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiptNumber,
                      style: AppTypography.heading3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${dateFormatter.format(dateTime)} • ${timeFormatter.format(dateTime)}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildInfoRow(l10n.employee, employee),
          const SizedBox(height: AppDimensions.paddingSmall),
          _buildInfoRow(l10n.cashRegister, cashRegister),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTypography.body2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(AppLocalizations l10n) {
    // TODO: Charger les vrais items depuis le BLoC
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.items,
            style: AppTypography.heading4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          // TODO: Afficher les items réels
          Text(
            l10n.noItems,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals(AppLocalizations l10n) {
    // TODO: Charger les vrais totaux depuis le BLoC
    final amountFormatter = NumberFormat('#,###', 'fr');
    final subtotal = 10000;
    final tax = 2000;
    final discount = 0;
    final total = 12000;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildTotalRow(l10n.subtotal, subtotal, amountFormatter),
          if (tax > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            _buildTotalRow(l10n.tax, tax, amountFormatter),
          ],
          if (discount > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            _buildTotalRow(l10n.discount, -discount, amountFormatter,
                color: AppColors.danger),
          ],
          const SizedBox(height: AppDimensions.paddingSmall),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.paddingSmall),
          _buildTotalRow(l10n.total, total, amountFormatter, isBold: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    int amount,
    NumberFormat formatter, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body2.copyWith(
            color: color ?? AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          '${formatter.format(amount)} Ar',
          style: (isBold ? AppTypography.heading4 : AppTypography.body2).copyWith(
            color: color ?? AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(AppLocalizations l10n) {
    // TODO: Charger les vrais paiements depuis le BLoC
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentMethod,
            style: AppTypography.heading4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          // TODO: Afficher les paiements réels
          Text(
            l10n.cash,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundedMessage(AppLocalizations l10n, RefundLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.dangerLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.danger),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.danger),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Text(
              l10n.alreadyRefunded,
              style: AppTypography.body2.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundButton(AppLocalizations l10n, bool isRefunded) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isRefunded
                ? null
                : () {
                    // Naviguer vers l'écran de remboursement
                    context.push('/pos/receipts/${widget.receiptId}/refund');
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isRefunded ? AppColors.borderLight : AppColors.danger,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMedium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.refund,
              style: AppTypography.body1.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
