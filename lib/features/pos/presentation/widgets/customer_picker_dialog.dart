import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';

/// Dialog pour sélectionner un client pour une vente à crédit
/// Permet recherche, affichage liste clients, navigation vers création nouveau client
class CustomerPickerDialog extends StatefulWidget {
  const CustomerPickerDialog({super.key});

  @override
  State<CustomerPickerDialog> createState() => _CustomerPickerDialogState();
}

class _CustomerPickerDialogState extends State<CustomerPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String? _currentStoreId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Charger les clients au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      String? storeId;
      if (authState is AuthAuthenticatedWithStore) {
        storeId = authState.storeId;
      } else if (authState is AuthPinSessionActive) {
        storeId = authState.user.storeId;
      }

      if (storeId != null) {
        _currentStoreId = storeId;
        context.read<CustomerBloc>().add(LoadCustomersEvent(storeId));
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (_currentStoreId != null) {
      if (query.isEmpty) {
        context.read<CustomerBloc>().add(LoadCustomersEvent(_currentStoreId!));
      } else {
        context.read<CustomerBloc>().add(SearchCustomersEvent(_currentStoreId!, query));
      }
    }
  }

  Color _getAvatarColor(String name) {
    final hash = name.hashCode;
    final colors = [
      AppColors.successLight,
      AppColors.warningLight,
      AppColors.dangerLight,
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF59E0B), // Amber
    ];
    return colors[hash.abs() % colors.length];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amountFormatter = NumberFormat('#,###', 'fr');

    return Dialog(
      backgroundColor: context.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.75,
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 700,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.border,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.selectCustomer,
                      style: AppTypography.sectionTitle.copyWith(
                        color: context.textPri,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.textSec),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                style: AppTypography.body.copyWith(color: context.textPri),
                decoration: InputDecoration(
                  hintText: l10n.customersSearch,
                  hintStyle: AppTypography.hint.copyWith(color: context.textHint),
                  prefixIcon: Icon(Icons.search, color: context.textHint),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: context.textHint),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: context.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                ),
              ),
            ),

            // Customers list
            Expanded(
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, customerState) {
                  if (customerState is CustomerLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: context.accent),
                    );
                  }

                  if (customerState is CustomerError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          customerState.message,
                          style: AppTypography.body.copyWith(color: context.danger),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (customerState is! CustomersLoaded) {
                    return const SizedBox.shrink();
                  }

                  final customers = customerState.customers;

                  if (customers.isEmpty) {
                    return _buildEmptyState(l10n);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: customers.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 0.5,
                      color: context.border,
                      indent: 56,
                    ),
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return _buildCustomerItem(customer, l10n, amountFormatter);
                    },
                  );
                },
              ),
            ),

            // Footer with "New Customer" button
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: context.border,
                    width: 0.5,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.textPri,
                    side: BorderSide(color: context.border, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    textStyle: AppTypography.button,
                  ),
                  onPressed: () {
                    // Fermer le dialog et naviguer vers la page de création
                    Navigator.pop(context);
                    context.go('/customers/new');
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.customerNewCustomer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: context.textHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.customersEmptyTitle,
              style: AppTypography.sectionTitle.copyWith(color: context.textPri),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _searchController.text.isEmpty
                  ? l10n.customersEmptyDescription
                  : 'Aucun client trouvé',
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerItem(
    Customer customer,
    AppLocalizations l10n,
    NumberFormat amountFormatter,
  ) {
    return InkWell(
      onTap: () {
        // Retourner le client sélectionné
        Navigator.pop(context, customer);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(customer),
            const SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    customer.name,
                    style: AppTypography.body.copyWith(
                      color: context.textPri,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Phone
                  if (customer.phone != null && customer.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 12,
                          color: context.textSec,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone!,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSec,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Credit badge
            if (customer.creditBalance > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: context.danger.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${amountFormatter.format(customer.creditBalance)} Ar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.danger,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Customer customer) {
    final color = _getAvatarColor(customer.name);
    final initials = _getInitials(customer.name);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTypography.body.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
