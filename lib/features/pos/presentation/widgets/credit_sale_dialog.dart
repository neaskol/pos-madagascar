import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';

class CreditSaleResult {
  final DateTime? dueDate;
  final String? notes;

  const CreditSaleResult({this.dueDate, this.notes});
}

class CreditSaleDialog extends StatefulWidget {
  final String customerName;
  final int totalAmount;

  const CreditSaleDialog({
    super.key,
    required this.customerName,
    required this.totalAmount,
  });

  @override
  State<CreditSaleDialog> createState() => _CreditSaleDialogState();
}

class _CreditSaleDialogState extends State<CreditSaleDialog> {
  _DueDateOption _selectedOption = _DueDateOption.none;
  DateTime? _customDate;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  DateTime? get _effectiveDueDate {
    final now = DateTime.now();
    switch (_selectedOption) {
      case _DueDateOption.none:
        return null;
      case _DueDateOption.days7:
        return now.add(const Duration(days: 7));
      case _DueDateOption.days15:
        return now.add(const Duration(days: 15));
      case _DueDateOption.days30:
        return now.add(const Duration(days: 30));
      case _DueDateOption.custom:
        return _customDate;
    }
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.accent,
              onPrimary: context.bg,
              surface: context.surface,
              onSurface: context.textPri,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDate = picked;
        _selectedOption = _DueDateOption.custom;
      });
    }
  }

  void _confirm() {
    final result = CreditSaleResult(
      dueDate: _effectiveDueDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amountFormatted = NumberFormat('#,###', 'fr').format(widget.totalAmount);

    return AlertDialog(
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      title: Text(
        l10n.creditSale,
        style: AppTypography.sectionTitle.copyWith(color: context.textPri),
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Confirmation message
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.bg,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: context.border),
                ),
                child: Text(
                  l10n.creditSaleConfirmation(
                    '$amountFormatted Ar',
                    widget.customerName,
                  ),
                  style: AppTypography.body.copyWith(color: context.textPri),
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // Due date section
              Text(
                l10n.creditDueDateTitle,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSec,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: AppSpacing.sm),

              // Due date options
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _buildDateChip(
                    label: l10n.creditDueDateNone,
                    option: _DueDateOption.none,
                  ),
                  _buildDateChip(
                    label: l10n.creditDueDate7d,
                    option: _DueDateOption.days7,
                  ),
                  _buildDateChip(
                    label: l10n.creditDueDate15d,
                    option: _DueDateOption.days15,
                  ),
                  _buildDateChip(
                    label: l10n.creditDueDate30d,
                    option: _DueDateOption.days30,
                  ),
                  _buildDateChip(
                    label: l10n.creditDueDateCustom,
                    option: _DueDateOption.custom,
                    onTap: _pickCustomDate,
                  ),
                ],
              ),

              // Display selected date
              if (_effectiveDueDate != null) ...[
                SizedBox(height: AppSpacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: context.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    border: Border.all(
                      color: context.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event,
                        size: 16,
                        color: context.accent,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormat('EEEE d MMMM yyyy', 'fr')
                            .format(_effectiveDueDate!),
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textPri,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: AppSpacing.lg),

              // Notes field
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: AppTypography.body.copyWith(color: context.textPri),
                decoration: InputDecoration(
                  hintText: l10n.creditNoteHint,
                  hintStyle: AppTypography.hint.copyWith(color: context.textHint),
                  filled: true,
                  fillColor: context.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: BorderSide(color: context.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: BorderSide(color: context.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: BorderSide(color: context.accent, width: 2),
                  ),
                  contentPadding: EdgeInsets.all(AppSpacing.md),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: context.textSec,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          child: Text(
            l10n.cancel,
            style: AppTypography.button,
          ),
        ),

        SizedBox(width: AppSpacing.sm),

        // Confirm button
        FilledButton(
          onPressed: _confirm,
          style: FilledButton.styleFrom(
            backgroundColor: context.textPri,
            foregroundColor: context.bg,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
          ),
          child: Text(
            l10n.confirm,
            style: AppTypography.button,
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip({
    required String label,
    required _DueDateOption option,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedOption == option;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          if (onTap != null) {
            onTap();
          } else {
            setState(() => _selectedOption = option);
          }
        }
      },
      labelStyle: AppTypography.bodySmall.copyWith(
        color: isSelected ? context.bg : context.textPri,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: context.bg,
      selectedColor: context.accent,
      checkmarkColor: context.bg,
      side: BorderSide(
        color: isSelected ? context.accent : context.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }
}

enum _DueDateOption {
  none,
  days7,
  days15,
  days30,
  custom,
}
