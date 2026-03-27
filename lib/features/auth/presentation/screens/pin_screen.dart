import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  List<User> _employees = [];
  User? _selectedEmployee;
  String _pin = '';

  @override
  void initState() {
    super.initState();
    // Charger les employés
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedWithStore) {
      context.read<AuthBloc>().add(
            AuthLoadStoreEmployeesRequested(storeId: authState.storeId),
          );
    } else if (authState is AuthStoreEmployeesLoaded) {
      // Employés déjà chargés (retour depuis POS)
      _employees = authState.employees;
    } else {
      // État inattendu — rediriger vers login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
    }
  }

  void _onNumberPressed(int number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number.toString();
      });

      if (_pin.length == 4 && _selectedEmployee != null) {
        _verifyPin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _verifyPin() {
    if (_selectedEmployee != null) {
      context.read<AuthBloc>().add(
            AuthPinSignInRequested(
              userId: _selectedEmployee!.id,
              pin: _pin,
            ),
          );
    }
  }

  void _selectEmployee(User employee) {
    setState(() {
      _selectedEmployee = employee;
      _pin = '';
    });
  }

  void _backToEmployeeList() {
    setState(() {
      _selectedEmployee = null;
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthStoreEmployeesLoaded) {
            setState(() {
              _employees = state.employees;
            });
          } else if (state is AuthError) {
            // PIN incorrect
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: isDark
                    ? AppColors.dangerDark
                    : AppColors.dangerLight,
              ),
            );
            setState(() {
              _pin = '';
            });
          } else if (state is AuthPinSessionActive) {
            // Rediriger vers l'app principale
            context.go('/pos');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Titre
                Text(
                  l10n.pinTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),

                const SizedBox(height: 48),

                Expanded(
                  child: _selectedEmployee == null
                      ? _buildEmployeeGrid(isDark)
                      : _buildPinPad(l10n, isDark),
                ),

                // Lien "Connexion email"
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: Text(
                    l10n.pinEmailLogin,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.lightAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmployeeGrid(bool isDark) {
    if (_employees.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      shrinkWrap: true,
      itemCount: _employees.length,
      itemBuilder: (context, index) {
        final employee = _employees[index];
        return _buildEmployeeCard(employee, isDark);
      },
    );
  }

  Widget _buildEmployeeCard(User employee, bool isDark) {
    final initials = _getInitials(employee.name);
    final avatarColor = _getAvatarColor(employee.id);

    return InkWell(
      onTap: () => _selectEmployee(employee),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: avatarColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: avatarColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Nom
          Flexible(
            child: Text(
              employee.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinPad(AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        // Retour
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: TextButton.icon(
              onPressed: _backToEmployeeList,
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.back),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Avatar et nom de l'employé sélectionné
        if (_selectedEmployee != null) ...[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getAvatarColor(_selectedEmployee!.id).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getAvatarColor(_selectedEmployee!.id).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _getInitials(_selectedEmployee!.name),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: _getAvatarColor(_selectedEmployee!.id),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedEmployee!.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],

        const SizedBox(height: 32),

        // Titre saisie PIN
        Text(
          l10n.pinEnterCode,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),

        const SizedBox(height: 16),

        // Indicateur PIN (4 cercles)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: index < _pin.length
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  width: 2,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Pavé numérique
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _buildNumberButton('1', isDark),
              _buildNumberButton('2', isDark),
              _buildNumberButton('3', isDark),
              _buildNumberButton('4', isDark),
              _buildNumberButton('5', isDark),
              _buildNumberButton('6', isDark),
              _buildNumberButton('7', isDark),
              _buildNumberButton('8', isDark),
              _buildNumberButton('9', isDark),
              const SizedBox(), // Empty space
              _buildNumberButton('0', isDark),
              _buildBackspaceButton(isDark),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNumberButton(String number, bool isDark) {
    return InkWell(
      onTap: () => _onNumberPressed(int.parse(number)),
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(bool isDark) {
    return InkWell(
      onTap: _onBackspacePressed,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.backspace_outlined,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color _getAvatarColor(String userId) {
    // Générer une couleur basée sur l'ID de l'utilisateur
    final colors = [
      const Color(0xFFE57373), // Red
      const Color(0xFF64B5F6), // Blue
      const Color(0xFF81C784), // Green
      const Color(0xFFFFD54F), // Amber
      const Color(0xFFBA68C8), // Purple
      const Color(0xFFFF8A65), // Deep Orange
      const Color(0xFF4DD0E1), // Cyan
      const Color(0xFFA1887F), // Brown
    ];

    final index = userId.hashCode.abs() % colors.length;
    return colors[index];
  }
}
