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

/// Écran 12 : Historique des ventes (reçus)
class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterPeriod = 'all'; // 'all', 'today', 'week'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterPeriodChanged(String period) {
    setState(() {
      _filterPeriod = period;
    });
    // TODO: Recharger les ventes avec le nouveau filtre
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.watch<AuthBloc>().state;
    final storeId = authState is AuthStoreEmployeesLoaded
        ? authState.storeId
        : null;

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
          l10n.salesHistory,
          style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchReceipts,
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
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
                fillColor: AppColors.backgroundSecondary,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
              ),
              onChanged: (query) {
                // TODO: Rechercher les ventes
              },
            ),
          ),

          // Filtres en chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: l10n.all,
                    selected: _filterPeriod == 'all',
                    onTap: () => _onFilterPeriodChanged('all'),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _FilterChip(
                    label: l10n.today,
                    selected: _filterPeriod == 'today',
                    onTap: () => _onFilterPeriodChanged('today'),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _FilterChip(
                    label: l10n.thisWeek,
                    selected: _filterPeriod == 'week',
                    onTap: () => _onFilterPeriodChanged('week'),
                  ),
                  // TODO: Ajouter filtres employé et type de paiement
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          // Liste des reçus
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: Recharger les ventes
              },
              child: _buildSalesList(storeId, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList(String? storeId, AppLocalizations l10n) {
    if (storeId == null) {
      return Center(
        child: Text(
          l10n.noStoreSelected,
          style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    // TODO: Connecter au BLoC pour charger les ventes réelles
    // Pour l'instant, afficher un placeholder
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      itemCount: 0, // Sera remplacé par les vraies ventes
      itemBuilder: (context, index) {
        return const SizedBox.shrink();
        // TODO: Implémenter _SaleListItem
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? AppColors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SaleListItem extends StatelessWidget {
  final String receiptNumber;
  final DateTime createdAt;
  final int itemsCount;
  final int total;
  final String paymentMethod;
  final String employeeName;
  final bool isRefunded;
  final bool synced;

  const _SaleListItem({
    required this.receiptNumber,
    required this.createdAt,
    required this.itemsCount,
    required this.total,
    required this.paymentMethod,
    required this.employeeName,
    required this.isRefunded,
    required this.synced,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFormatter = DateFormat('HH:mm');
    final amountFormatter = NumberFormat('#,###', 'fr');

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      elevation: 0,
      color: AppColors.backgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(color: AppColors.borderLight, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        onTap: () {
          // TODO: Naviguer vers détail reçu
          // context.push('/pos/receipts/$receiptNumber');
        },
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              // Icône reçu
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isRefunded
                      ? AppColors.dangerLight.withValues(alpha: 0.2)
                      : AppColors.successLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Icon(
                  isRefunded ? Icons.receipt_long_outlined : Icons.receipt_outlined,
                  color: isRefunded ? AppColors.danger : AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),

              // Infos vente
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          receiptNumber,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isRefunded) ...[
                          const SizedBox(width: AppDimensions.paddingSmall),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusSmall),
                            ),
                            child: Text(
                              l10n.refunded,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        if (!synced) ...[
                          const SizedBox(width: AppDimensions.paddingSmall),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusSmall),
                            ),
                            child: Text(
                              l10n.notSynced,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${timeFormatter.format(createdAt)} • $itemsCount ${l10n.items} • $employeeName',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      paymentMethod,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Total
              Text(
                '${amountFormatter.format(total)} Ar',
                style: AppTypography.heading4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
