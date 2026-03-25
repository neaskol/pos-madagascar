import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1 - Store info
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storePhoneController = TextEditingController();
  String? _logoUrl;

  // Step 2 - Currency and rounding
  String _currency = 'MGA';
  int _cashRoundingUnit = 0;

  // Step 3 - Languages
  String _interfaceLanguage = 'fr';
  String _receiptLanguage = 'fr';

  // Step 4 - Business type
  String _businessType = 'grocery';

  @override
  void dispose() {
    _pageController.dispose();
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      _finishSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  void _finishSetup() {
    if (_storeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer le nom du magasin'),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthStoreCreationRequested(
            name: _storeNameController.text.trim(),
            address: _storeAddressController.text.trim().isEmpty
                ? null
                : _storeAddressController.text.trim(),
            phone: _storePhoneController.text.trim().isEmpty
                ? null
                : _storePhoneController.text.trim(),
            logoUrl: _logoUrl,
            currency: _currency,
            timezone: 'Indian/Antananarivo',
            cashRoundingUnit: _cashRoundingUnit,
            receiptLanguage: _receiptLanguage,
            interfaceLanguage: _interfaceLanguage,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: isDark
                    ? AppColors.dangerDark
                    : AppColors.dangerLight,
              ),
            );
          } else if (state is AuthStoreCreated ||
              state is AuthAuthenticatedWithStore) {
            Navigator.of(context).pushReplacementNamed('/pin');
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                backgroundColor: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.darkAccent : AppColors.lightAccent,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Text(
                  l10n.setupTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Step indicator
              Text(
                'Étape ${_currentStep + 1} / 4',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStoreInfoStep(l10n, isDark),
                    _buildCurrencyStep(l10n, isDark),
                    _buildLanguagesStep(l10n, isDark),
                    _buildBusinessTypeStep(l10n, isDark),
                  ],
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            child: Text(l10n.setupPrevious),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: _currentStep > 0 ? 1 : 2,
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            foregroundColor: isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: Text(
                            _currentStep == 3
                                ? l10n.setupFinish
                                : l10n.setupNext,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfoStep(AppLocalizations l10n, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.setupStep1Title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _storeNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.setupStoreName,
              prefixIcon: const Icon(Icons.store_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _storeAddressController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.setupStoreAddress,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _storePhoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.setupStorePhone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implémenter upload logo
            },
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(l10n.setupUploadLogo),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyStep(AppLocalizations l10n, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.setupStep2Title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.setupCashRounding,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRoundingOption(l10n.setupCashRoundingNone, 0, isDark),
          const SizedBox(height: 8),
          _buildRoundingOption(l10n.setupCashRounding50, 50, isDark),
          const SizedBox(height: 8),
          _buildRoundingOption(l10n.setupCashRounding100, 100, isDark),
          const SizedBox(height: 8),
          _buildRoundingOption(l10n.setupCashRounding200, 200, isDark),
        ],
      ),
    );
  }

  Widget _buildRoundingOption(String label, int value, bool isDark) {
    return InkWell(
      onTap: () {
        setState(() {
          _cashRoundingUnit = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cashRoundingUnit == value
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurfaceHigh)
              : Colors.transparent,
          border: Border.all(
            color: _cashRoundingUnit == value
                ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: _cashRoundingUnit == value ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              _cashRoundingUnit == value
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: _cashRoundingUnit == value
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesStep(AppLocalizations l10n, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.setupStep3Title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.setupInterfaceLanguage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLanguageOption('Français', 'fr', true, isDark),
          const SizedBox(height: 8),
          _buildLanguageOption('Malagasy', 'mg', true, isDark),
          const SizedBox(height: 24),
          Text(
            l10n.setupReceiptLanguage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLanguageOption('Français', 'fr', false, isDark),
          const SizedBox(height: 8),
          _buildLanguageOption('Malagasy', 'mg', false, isDark),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    String label,
    String code,
    bool isInterface,
    bool isDark,
  ) {
    final isSelected = isInterface
        ? _interfaceLanguage == code
        : _receiptLanguage == code;

    return InkWell(
      onTap: () {
        setState(() {
          if (isInterface) {
            _interfaceLanguage = code;
          } else {
            _receiptLanguage = code;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurfaceHigh)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessTypeStep(AppLocalizations l10n, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.setupStep4Title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _buildBusinessTypeOption(
            l10n.setupBusinessTypeGrocery,
            'grocery',
            Icons.local_grocery_store_outlined,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildBusinessTypeOption(
            l10n.setupBusinessTypeRestaurant,
            'restaurant',
            Icons.restaurant_outlined,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildBusinessTypeOption(
            l10n.setupBusinessTypeFashion,
            'fashion',
            Icons.checkroom_outlined,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildBusinessTypeOption(
            l10n.setupBusinessTypeService,
            'service',
            Icons.content_cut_outlined,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildBusinessTypeOption(
            l10n.setupBusinessTypeOther,
            'other',
            Icons.store_outlined,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessTypeOption(
    String label,
    String type,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _businessType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _businessType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurfaceHigh)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: isDark
                    ? AppColors.darkAccent
                    : AppColors.lightAccent,
              ),
          ],
        ),
      ),
    );
  }
}
