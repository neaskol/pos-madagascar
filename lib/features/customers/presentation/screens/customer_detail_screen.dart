import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../bloc/credit_bloc.dart';
import '../bloc/credit_event.dart';
import '../bloc/credit_state.dart';
import '../widgets/credit_payment_dialog.dart';

/// Ecran 33 — Profil client (avec onglets Historique et Credits)
/// Route: /customers/:id
class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load customer data
    context.read<CustomerBloc>().add(LoadCustomerByIdEvent(widget.customerId));

    // Load credits for this customer
    context.read<CreditBloc>().add(
          LoadCreditsByCustomerEvent(widget.customerId),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPri),
        title: Text(
          l10n.customerDetail,
          style: AppTypography.screenTitle.copyWith(color: context.textPri),
        ),
        actions: [
          // WhatsApp button
          BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoaded && state.customer.phone != null) {
                return IconButton(
                  icon: Icon(Icons.chat_outlined, color: context.textPri),
                  tooltip: 'WhatsApp',
                  onPressed: () => _launchWhatsApp(state.customer.phone!),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Edit button
          IconButton(
            icon: Icon(Icons.edit_outlined, color: context.textPri),
            onPressed: () => context.go('/customers/${widget.customerId}/edit'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.accent),
            );
          }

          if (state is CustomerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: context.danger),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    state.message,
                    style: AppTypography.body.copyWith(color: context.textSec),
                  ),
                ],
              ),
            );
          }

          if (state is CustomerLoaded) {
            return Column(
              children: [
                // Header with avatar and info
                _buildHeader(context, state.customer),

                // Metrics cards
                _buildMetricsRow(context, state.customer),

                const SizedBox(height: AppSpacing.lg),

                // TabBar
                Container(
                  color: context.surface,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: context.textPri,
                    unselectedLabelColor: context.textHint,
                    indicatorColor: context.accent,
                    labelStyle: AppTypography.sectionTitle,
                    tabs: [
                      Tab(text: l10n.customerPurchaseHistory),
                      Tab(text: l10n.customerCredits),
                    ],
                  ),
                ),

                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPurchaseHistoryTab(context),
                      _buildCreditsTab(context, state.customer),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Customer customer) {
    return Container(
      color: context.surface,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // Avatar with initials
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(customer.name),
                style: AppTypography.amountLarge.copyWith(
                  color: context.accent,
                  fontSize: 32,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Name
          Text(
            customer.name,
            style: AppTypography.screenTitle.copyWith(
              fontSize: 20,
              color: context.textPri,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Phone and email
          if (customer.phone != null)
            Text(
              customer.phone!,
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
            ),
          if (customer.email != null)
            Text(
              customer.email!,
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
            ),

          // Credit balance warning if > 0
          if (customer.creditBalance > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: context.warningBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: context.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Credit en cours : ${_formatAmount(customer.creditBalance)}',
                    style: AppTypography.label.copyWith(
                      color: context.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, Customer customer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              context,
              label: 'TOTAL DEPENSE',
              value: _formatAmount(customer.totalSpent),
              icon: Icons.trending_up,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildMetricCard(
              context,
              label: 'VISITES',
              value: customer.totalVisits.toString(),
              icon: Icons.people_outline,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildMetricCard(
              context,
              label: 'POINTS',
              value: '0',
              icon: Icons.star_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkSurface : AppColors.lightSurfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: context.textHint),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.sectionLabel.copyWith(
                    color: context.textHint,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.amount.copyWith(
              fontSize: 18,
              color: context.textPri,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseHistoryTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 48, color: context.textHint),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Historique des achats',
              style: AppTypography.sectionTitle.copyWith(color: context.textPri),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Disponible prochainement',
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsTab(BuildContext context, Customer customer) {
    return BlocBuilder<CreditBloc, CreditState>(
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
                const SizedBox(height: AppSpacing.lg),
                Text(
                  state.message,
                  style: AppTypography.body.copyWith(color: context.textSec),
                ),
              ],
            ),
          );
        }

        if (state is CreditsLoaded) {
          final credits = state.credits;

          if (credits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: context.success),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Aucun credit',
                      style: AppTypography.sectionTitle.copyWith(color: context.textPri),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Ce client n\'a pas de credit en cours',
                      style: AppTypography.bodySmall.copyWith(color: context.textSec),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.page),
            itemCount: credits.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final credit = credits[index];
              return _buildCreditCard(context, credit);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCreditCard(BuildContext context, Credit credit) {
    final statusColor = _getStatusColor(context, credit.status);
    final statusBgColor = _getStatusBgColor(context, credit.status);
    final statusLabel = _getStatusLabel(credit.status);

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.border, width: 0.5),
      ),
      child: InkWell(
        onTap: () => _showCreditPaymentDialog(context, credit),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge and date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (credit.dueDate != null)
                    Text(
                      'Echeance: ${_formatDate(credit.dueDate!)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: _isOverdue(credit.dueDate!)
                            ? context.danger
                            : context.textSec,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Amount total
              Row(
                children: [
                  Text(
                    'Montant total:',
                    style: AppTypography.bodySmall.copyWith(color: context.textSec),
                  ),
                  const Spacer(),
                  Text(
                    _formatAmount(credit.amountTotal),
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textPri,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              // Amount paid
              Row(
                children: [
                  Text(
                    'Paye:',
                    style: AppTypography.bodySmall.copyWith(color: context.textSec),
                  ),
                  const Spacer(),
                  Text(
                    _formatAmount(credit.amountPaid),
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              // Amount remaining
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? AppColors.darkSurfaceHigh
                      : AppColors.lightSurfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Text(
                      'Restant:',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textPri,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatAmount(credit.amountRemaining),
                      style: AppTypography.amount.copyWith(
                        fontSize: 18,
                        color: context.accent,
                      ),
                    ),
                  ],
                ),
              ),

              // Notes if any
              if (credit.notes != null && credit.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  credit.notes!,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSec,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // Tap to pay hint
              if (credit.amountRemaining > 0) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 14,
                      color: context.textHint,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Appuyez pour enregistrer un paiement',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  String _formatAmount(int amount) {
    return '${NumberFormat('#,###', 'fr').format(amount)} Ar';
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  bool _isOverdue(int timestamp) {
    final dueDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return dueDate.isBefore(DateTime.now());
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'paid':
        return context.success;
      case 'partial':
        return context.warning;
      case 'overdue':
        return context.danger;
      default: // pending
        return context.textHint;
    }
  }

  Color _getStatusBgColor(BuildContext context, String status) {
    switch (status) {
      case 'paid':
        return context.successBg;
      case 'partial':
        return context.warningBg;
      case 'overdue':
        return context.dangerBg;
      default: // pending
        return context.surface;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'paid':
        return 'PAYE';
      case 'partial':
        return 'PARTIEL';
      case 'overdue':
        return 'EN RETARD';
      default: // pending
        return 'EN ATTENTE';
    }
  }

  void _showCreditPaymentDialog(BuildContext context, Credit credit) {
    if (credit.amountRemaining <= 0) return;

    CreditPaymentDialog.show(context, credit);
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Impossible d\'ouvrir WhatsApp'),
            backgroundColor: context.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    }
  }
}
