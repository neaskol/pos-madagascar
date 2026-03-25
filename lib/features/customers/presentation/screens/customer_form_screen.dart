import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

class CustomerFormScreen extends StatefulWidget {
  final String? customerId;

  const CustomerFormScreen({
    super.key,
    this.customerId,
  });

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _loyaltyCardController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.customerId != null;

    if (_isEditMode) {
      context.read<CustomerBloc>().add(
            LoadCustomerByIdEvent(widget.customerId!),
          );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _loyaltyCardController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _fillFormWithCustomerData(Customer customer) {
    _nameController.text = customer.name;
    _phoneController.text = customer.phone ?? '';
    _emailController.text = customer.email ?? '';
    _loyaltyCardController.text = customer.loyaltyCardBarcode ?? '';
    _notesController.text = customer.notes ?? '';
  }

  String? _validateName(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.customerNameRequired;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  void _saveCustomer() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    String? storeId;
    String? userId;

    if (authState is AuthPinSessionActive) {
      storeId = authState.user.storeId;
      userId = authState.user.id;
    } else if (authState is AuthAuthenticatedWithStore) {
      storeId = authState.storeId;
      userId = authState.user.id;
    }

    if (storeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Magasin non trouve')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final loyaltyCard = _loyaltyCardController.text.trim();
    final notes = _notesController.text.trim();

    if (_isEditMode) {
      context.read<CustomerBloc>().add(
            UpdateCustomerEvent(
              id: widget.customerId!,
              name: name,
              phone: phone.isEmpty ? null : phone,
              email: email.isEmpty ? null : email,
              loyaltyCardBarcode: loyaltyCard.isEmpty ? null : loyaltyCard,
              notes: notes.isEmpty ? null : notes,
            ),
          );
    } else {
      context.read<CustomerBloc>().add(
            CreateCustomerEvent(
              storeId: storeId,
              name: name,
              phone: phone.isEmpty ? null : phone,
              email: email.isEmpty ? null : email,
              loyaltyCardBarcode: loyaltyCard.isEmpty ? null : loyaltyCard,
              notes: notes.isEmpty ? null : notes,
              createdBy: userId,
            ),
          );
    }
  }

  InputDecoration _buildInputDecoration({String? hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: context.bg,
      hintText: hintText,
      hintStyle: AppTypography.hint.copyWith(color: context.textHint),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: context.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: context.danger, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerLoading) {
          setState(() => _isLoading = true);
        } else if (state is CustomerLoaded) {
          setState(() => _isLoading = false);
          _fillFormWithCustomerData(state.customer);
        } else if (state is CustomerOperationSuccess) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          );
          context.pop();
        } else if (state is CustomerError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.textPri),
            onPressed: () => context.pop(),
          ),
          title: Text(
            _isEditMode ? l10n.customerEditCustomer : l10n.customerNewCustomer,
            style: AppTypography.screenTitle.copyWith(color: context.textPri),
          ),
          actions: [
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _saveCustomer,
                child: Text(
                  l10n.save,
                  style: AppTypography.button.copyWith(
                    color: context.accent,
                  ),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              // Name field (required)
              Text(
                l10n.customerName,
                style: AppTypography.label.copyWith(color: context.textSec),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nameController,
                style: AppTypography.body.copyWith(color: context.textPri),
                decoration: _buildInputDecoration(),
                validator: _validateName,
                textCapitalization: TextCapitalization.words,
                autofocus: !_isEditMode,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Phone field (optional)
              Text(
                l10n.customerPhone,
                style: AppTypography.label.copyWith(color: context.textSec),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _phoneController,
                style: AppTypography.body.copyWith(color: context.textPri),
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration(
                  hintText: l10n.customerPhoneHint,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Email field (optional)
              Text(
                l10n.customerEmail,
                style: AppTypography.label.copyWith(color: context.textSec),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _emailController,
                style: AppTypography.body.copyWith(color: context.textPri),
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration(
                  hintText: l10n.customerEmailHint,
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Loyalty card barcode (optional)
              Text(
                l10n.customerLoyaltyCard,
                style: AppTypography.label.copyWith(color: context.textSec),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _loyaltyCardController,
                style: AppTypography.body.copyWith(color: context.textPri),
                decoration: _buildInputDecoration(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Notes field (optional)
              Text(
                l10n.customerNotes,
                style: AppTypography.label.copyWith(color: context.textSec),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _notesController,
                style: AppTypography.body.copyWith(color: context.textPri),
                maxLines: 4,
                decoration: _buildInputDecoration(
                  hintText: l10n.customerNotesHint,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
