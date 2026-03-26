import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/repositories/refund_repository.dart';
import '../bloc/refund_bloc.dart';
import '../bloc/refund_event.dart';
import '../bloc/refund_state.dart';

/// Écran 14 : Écran de remboursement avec sélection des items
class RefundScreen extends StatefulWidget {
  final String receiptId;

  const RefundScreen({
    super.key,
    required this.receiptId,
  });

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  final Map<String, int> _selectedQuantities = {};
  String _selectedReason = 'defective';
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleItemSelection(String itemId, int maxQuantity) {
    setState(() {
      if (_selectedQuantities.containsKey(itemId)) {
        // Déjà sélectionné, retirer
        _selectedQuantities.remove(itemId);
      } else {
        // Sélectionner avec quantité = 1
        _selectedQuantities[itemId] = 1;
      }
    });
  }

  void _updateQuantity(String itemId, int newQuantity, int maxQuantity) {
    if (newQuantity < 1 || newQuantity > maxQuantity) return;
    setState(() {
      _selectedQuantities[itemId] = newQuantity;
    });
  }

  void _selectAll() {
    // TODO: Sélectionner tous les items avec leur quantité complète
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.refundAll),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _confirmRefund() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedQuantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectItemsToRefund),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        title: Text(
          l10n.confirmRefund,
          style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          l10n.confirmRefundMessage,
          style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
              elevation: 0,
            ),
            child: Text(
              l10n.confirm,
              style: AppTypography.body2.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Créer le remboursement
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthStoreEmployeesLoaded) return;

    final storeId = authState.selectedStore.id;
    final employeeId = authState.selectedEmployee.id;

    // TODO: Construire la liste des RefundItemData depuis _selectedQuantities
    // Pour l'instant, utiliser des données de placeholder
    final items = <RefundItemData>[];

    context.read<RefundBloc>().add(
          CreateRefund(
            saleId: widget.receiptId,
            storeId: storeId,
            employeeId: employeeId,
            items: items,
            reason: _selectedReason,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amountFormatter = NumberFormat('#,###', 'fr');

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
          l10n.refund,
          style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _selectAll,
            child: Text(
              l10n.refundAll,
              style: AppTypography.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<RefundBloc, RefundState>(
        listener: (context, state) {
          if (state is RefundCreated) {
            // Succès, retour à l'écran précédent
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.refundSuccess),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
            context.pop(); // Retourner aussi de l'écran de détail
          } else if (state is RefundError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;

            return Column(
              children: [
                Expanded(
                  child: isTablet
                      ? _buildTabletLayout(l10n, amountFormatter)
                      : _buildMobileLayout(l10n, amountFormatter),
                ),
                _buildBottomBar(l10n),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabletLayout(AppLocalizations l10n, NumberFormat formatter) {
    return Row(
      children: [
        // Colonne gauche : items originaux
        Expanded(
          child: _buildOriginalItems(l10n, formatter),
        ),
        Container(
          width: 1,
          color: AppColors.borderLight,
        ),
        // Colonne droite : items à rembourser
        Expanded(
          child: _buildRefundItems(l10n, formatter),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AppLocalizations l10n, NumberFormat formatter) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOriginalItems(l10n, formatter),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildRefundItems(l10n, formatter),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildReasonSelector(l10n),
        ],
      ),
    );
  }

  Widget _buildOriginalItems(AppLocalizations l10n, NumberFormat formatter) {
    // TODO: Charger les vrais items depuis le BLoC
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.originalItems,
            style: AppTypography.heading4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            l10n.selectItemsToRefund,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          // TODO: Afficher la liste des items réels
        ],
      ),
    );
  }

  Widget _buildRefundItems(AppLocalizations l10n, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.itemsToRefund,
            style: AppTypography.heading4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          if (_selectedQuantities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Text(
                  l10n.noItemsSelected,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            // TODO: Afficher les items sélectionnés
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildReasonSelector(AppLocalizations l10n) {
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
            l10n.refundReason,
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildReasonOption('defective', l10n.reasonDefective),
          _buildReasonOption('error', l10n.reasonError),
          _buildReasonOption('dissatisfied', l10n.reasonDissatisfied),
          _buildReasonOption('other', l10n.reasonOther),
          const SizedBox(height: AppDimensions.paddingMedium),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.noteOptional,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.backgroundPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonOption(String value, String label) {
    final isSelected = _selectedReason == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.backgroundPrimary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Text(
              label,
              style: AppTypography.body2.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    // TODO: Calculer le total réel à rembourser
    final totalToRefund = 0;
    final amountFormatter = NumberFormat('#,###', 'fr');

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.totalToRefund,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${amountFormatter.format(totalToRefund)} Ar',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedQuantities.isEmpty ? null : _confirmRefund,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
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
                  l10n.confirmRefund,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
