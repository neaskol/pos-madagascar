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
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

/// Ecran liste des clients avec recherche et filtres
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterType = 'all'; // 'all' or 'with_credit'
  String? _currentStoreId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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
        if (_filterType == 'with_credit') {
          context.read<CustomerBloc>().add(LoadCustomersWithCreditEvent(_currentStoreId!));
        } else {
          context.read<CustomerBloc>().add(LoadCustomersEvent(_currentStoreId!));
        }
      } else {
        context.read<CustomerBloc>().add(SearchCustomersEvent(_currentStoreId!, query));
      }
    }
  }

  void _onFilterChanged(String filterType) {
    setState(() {
      _filterType = filterType;
      _searchController.clear();
    });

    if (_currentStoreId != null) {
      if (filterType == 'with_credit') {
        context.read<CustomerBloc>().add(LoadCustomersWithCreditEvent(_currentStoreId!));
      } else {
        context.read<CustomerBloc>().add(LoadCustomersEvent(_currentStoreId!));
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

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Text(
          l10n.customersTitle,
          style: AppTypography.screenTitle.copyWith(color: context.textPri),
        ),
        backgroundColor: context.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPri),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String? storeId;
          if (authState is AuthAuthenticatedWithStore) {
            storeId = authState.storeId;
          } else if (authState is AuthPinSessionActive) {
            storeId = authState.user.storeId;
          }

          if (storeId == null) {
            return Center(
              child: Text(
                'Store ID not available',
                style: AppTypography.body.copyWith(color: context.textSec),
              ),
            );
          }

          if (_currentStoreId != storeId) {
            _currentStoreId = storeId;
            final currentStore = storeId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<CustomerBloc>().add(LoadCustomersEvent(currentStore));
            });
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
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

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: l10n.customerFilterAll,
                      value: 'all',
                      selected: _filterType == 'all',
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip(
                      label: l10n.customerFilterWithCredit,
                      value: 'with_credit',
                      selected: _filterType == 'with_credit',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

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
                        child: Text(
                          customerState.message,
                          style: AppTypography.body.copyWith(color: context.danger),
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

                    return RefreshIndicator(
                      onRefresh: () async {
                        if (storeId != null) {
                          if (_filterType == 'with_credit') {
                            context.read<CustomerBloc>().add(LoadCustomersWithCreditEvent(storeId));
                          } else {
                            context.read<CustomerBloc>().add(LoadCustomersEvent(storeId));
                          }
                        }
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        itemCount: customers.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 0.5,
                          color: context.border,
                          indent: 76,
                        ),
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return _buildCustomerItem(customer, l10n, amountFormatter);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/customers/new');
        },
        backgroundColor: context.textPri,
        foregroundColor: context.bg,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool selected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (isSelected) {
        if (isSelected) {
          _onFilterChanged(value);
        }
      },
      selectedColor: context.isDark
          ? AppColors.darkTextPrimary.withValues(alpha: 0.2)
          : AppColors.lightTextPrimary.withValues(alpha: 0.1),
      checkmarkColor: context.textPri,
      labelStyle: AppTypography.bodySmall.copyWith(
        color: selected ? context.textPri : context.textSec,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: selected ? context.textPri : context.border,
          width: selected ? 1.5 : 0.5,
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
              l10n.customersEmptyDescription,
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.textPri,
                  foregroundColor: context.bg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  textStyle: AppTypography.button,
                ),
                onPressed: () {
                  context.go('/customers/new');
                },
                child: Text(l10n.customersAddCustomer),
              ),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: _buildAvatar(customer),
      title: Row(
        children: [
          Expanded(
            child: Text(
              customer.name,
              style: AppTypography.body.copyWith(color: context.textPri),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (customer.creditBalance > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3,
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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 4),
          Row(
            children: [
              // Loyalty points
              Icon(
                Icons.star_outline,
                size: 12,
                color: context.warning,
              ),
              const SizedBox(width: 4),
              Text(
                '0 pts',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSec,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Total spent
              Icon(
                Icons.trending_up,
                size: 12,
                color: context.success,
              ),
              const SizedBox(width: 4),
              Text(
                '${amountFormatter.format(customer.totalSpent)} Ar',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSec,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        context.go('/customers/${customer.id}');
      },
    );
  }

  Widget _buildAvatar(Customer customer) {
    final color = _getAvatarColor(customer.name);
    final initials = _getInitials(customer.name);

    return Container(
      width: 44,
      height: 44,
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
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
