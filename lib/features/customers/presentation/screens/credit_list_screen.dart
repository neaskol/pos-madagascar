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
import '../bloc/credit_bloc.dart';
import '../bloc/credit_event.dart';
import '../bloc/credit_state.dart';
import '../widgets/credit_payment_dialog.dart';

class CreditListScreen extends StatefulWidget {
  const CreditListScreen({super.key});

  @override
  State<CreditListScreen> createState() => _CreditListScreenState();
}

class _CreditListScreenState extends State<CreditListScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCredits();
    });
  }

  void _loadCredits() {
    if (!mounted) return;
    final authState = context.read<AuthBloc>().state;
    String? storeId;
    if (authState is AuthAuthenticatedWithStore) {
      storeId = authState.storeId;
    } else if (authState is AuthPinSessionActive) {
      storeId = authState.user.storeId;
    }

    if (storeId != null) {
      if (_selectedFilter == 'overdue') {
        context.read<CreditBloc>().add(LoadOverdueCreditsEvent(storeId));
      } else if (_selectedFilter == 'all') {
        context.read<CreditBloc>().add(LoadCreditsEvent(storeId));
      } else {
        context.read<CreditBloc>().add(LoadCreditsByStatusEvent(storeId, _selectedFilter));
      }
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadCredits();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPri),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.creditTitle,
          style: AppTypography.screenTitle.copyWith(color: context.textPri),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.border),
        ),
      ),
      body: BlocBuilder<CreditBloc, CreditState>(
        builder: (context, state) {
          if (state is CreditLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.accent),
            );
          }

          if (state is CreditError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: context.danger),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    state.message,
                    style: AppTypography.body.copyWith(color: context.textSec),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: _loadCredits,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is CreditsLoaded) {
            final credits = state.credits;

            return Column(
              children: [
                _buildSummaryCards(credits),
                _buildFilterChips(),
                Expanded(
                  child: credits.isEmpty
                      ? _buildEmptyState()
                      : _buildCreditList(credits),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<Credit> credits) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    // Calculate total owed (all credits that aren't fully paid)
    int totalOwed = 0;
    for (final credit in credits) {
      if (credit.status != 'paid') {
        totalOwed += credit.amountRemaining;
      }
    }

    // Count overdue credits
    int overdueCount = 0;
    final nowMs = now.millisecondsSinceEpoch;
    for (final credit in credits) {
      if (credit.status != 'paid' &&
          credit.dueDate != null &&
          credit.dueDate! < nowMs) {
        overdueCount++;
      }
    }

    final amountFormat = NumberFormat('#,###', 'fr');

    return Container(
      padding: EdgeInsets.all(AppSpacing.page),
      color: context.surface,
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              label: l10n.totalDebts,
              value: '${amountFormat.format(totalOwed)} Ar',
              color: context.isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildSummaryCard(
              label: l10n.overdueDebts,
              value: overdueCount.toString(),
              color: context.danger,
              icon: Icons.warning_amber_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSec,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.sectionTitle.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.md,
      ),
      color: context.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: l10n.customerFilterAll,
              value: 'all',
              selected: _selectedFilter == 'all',
            ),
            SizedBox(width: AppSpacing.sm),
            _buildFilterChip(
              label: l10n.creditPending,
              value: 'pending',
              selected: _selectedFilter == 'pending',
            ),
            SizedBox(width: AppSpacing.sm),
            _buildFilterChip(
              label: l10n.creditPartial,
              value: 'partial',
              selected: _selectedFilter == 'partial',
            ),
            SizedBox(width: AppSpacing.sm),
            _buildFilterChip(
              label: l10n.creditPaid,
              value: 'paid',
              selected: _selectedFilter == 'paid',
            ),
            SizedBox(width: AppSpacing.sm),
            _buildFilterChip(
              label: l10n.creditOverdue,
              value: 'overdue',
              selected: _selectedFilter == 'overdue',
            ),
          ],
        ),
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

  Widget _buildCreditList(List<Credit> credits) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.page),
      itemCount: credits.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final credit = credits[index];
        return _buildCreditCard(credit);
      },
    );
  }

  Widget _buildCreditCard(Credit credit) {
    final l10n = AppLocalizations.of(context)!;
    final amountFormat = NumberFormat('#,###', 'fr');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();

    final amountRemaining = credit.amountRemaining;
    final nowMs = now.millisecondsSinceEpoch;
    final isOverdue = credit.dueDate != null &&
                      credit.dueDate! < nowMs &&
                      credit.status != 'paid';

    // Status color
    Color statusColor;
    switch (credit.status) {
      case 'paid':
        statusColor = context.success;
        break;
      case 'partial':
        statusColor = context.isDark ? Colors.blue.shade400 : Colors.blue;
        break;
      case 'pending':
        statusColor = context.warning;
        break;
      default:
        statusColor = context.textSec;
    }

    if (isOverdue) {
      statusColor = context.danger;
    }

    return Card(
      color: context.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: context.border, width: 1),
      ),
      child: InkWell(
        onTap: () => _showPaymentDialog(credit),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer name and status badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Client #${credit.customerId.substring(0, 8)}',
                      style: AppTypography.body.copyWith(
                        color: context.textPri,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm / 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      isOverdue
                          ? l10n.creditOverdue
                          : _getStatusLabel(credit.status),
                      style: AppTypography.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              // Amount details
              Row(
                children: [
                  Expanded(
                    child: _buildAmountDetail(
                      label: l10n.creditAmountTotal,
                      value: '${amountFormat.format(credit.amountTotal)} Ar',
                      color: context.textSec,
                    ),
                  ),
                  Expanded(
                    child: _buildAmountDetail(
                      label: l10n.creditAmountPaid,
                      value: '${amountFormat.format(credit.amountPaid)} Ar',
                      color: context.success,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),

              // Remaining amount (prominent)
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? context.textPri.withValues(alpha: 0.05)
                      : context.textPri.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.creditAmountRemaining,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSec,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${amountFormat.format(amountRemaining)} Ar',
                      style: AppTypography.body.copyWith(
                        color: isOverdue ? context.danger : context.textPri,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Due date or created date
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    credit.dueDate != null
                        ? Icons.event_outlined
                        : Icons.calendar_today_outlined,
                    size: 14,
                    color: isOverdue ? context.danger : context.textHint,
                  ),
                  SizedBox(width: AppSpacing.sm / 2),
                  Text(
                    credit.dueDate != null
                        ? l10n.creditDueOn(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(credit.dueDate!)))
                        : l10n.creditCreatedOn(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(credit.createdAt))),
                    style: AppTypography.hint.copyWith(
                      color: isOverdue ? context.danger : context.textHint,
                      fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountDetail({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.hint.copyWith(
            color: context.textHint,
          ),
        ),
        SizedBox(height: AppSpacing.sm / 2),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'paid':
        return l10n.creditPaid;
      case 'partial':
        return l10n.creditPartial;
      case 'pending':
        return l10n.creditPending;
      default:
        return status;
    }
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 64,
            color: context.textHint.withValues(alpha: 0.5),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            l10n.creditSalesEmpty,
            style: AppTypography.body.copyWith(
              color: context.textSec,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            l10n.creditSalesEmptyDescription,
            style: AppTypography.bodySmall.copyWith(
              color: context.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(Credit credit) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreditPaymentDialog(
        credit: credit,
      ),
    );

    // Reload credits after dialog closes if there was a payment
    if (result != null && mounted) {
      _loadCredits();
    }
  }
}
