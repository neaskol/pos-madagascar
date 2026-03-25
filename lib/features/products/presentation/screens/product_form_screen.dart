import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/services/storage_service.dart';
import '../bloc/item_bloc.dart';
import '../bloc/item_event.dart';
import '../bloc/item_state.dart';
import '../../data/repositories/category_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Écran de création/édition d'un produit
/// Suit exactement les spécifications de Sprint 2
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({
    super.key,
    this.itemId,
  });

  /// ID de l'item à éditer (null = création)
  final String? itemId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  final _weightUnitController = TextEditingController();

  String? _selectedCategoryId;
  bool _costIsPercentage = false;
  bool _availableForSale = true;
  bool _soldByWeight = false;
  bool _trackStock = true;
  String? _imageUrl;
  Item? _existingItem;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _lowStockThresholdController.text = '10'; // Valeur par défaut
    if (widget.itemId != null) {
      _loadExistingItem();
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    _weightUnitController.dispose();
    super.dispose();
  }

  /// Charger un produit existant pour édition
  Future<void> _loadExistingItem() async {
    if (widget.itemId == null) return;

    final itemBloc = context.read<ItemBloc>();
    itemBloc.add(LoadItemByIdEvent(widget.itemId!));
  }

  /// Calculer la marge en Ariary
  int _calculateMarginAmount() {
    final price = int.tryParse(_priceController.text) ?? 0;
    final cost = int.tryParse(_costController.text) ?? 0;

    if (price == 0) return 0;

    if (_costIsPercentage) {
      // Coût en % du prix de vente
      final costAmount = (price * cost / 100).round();
      return price - costAmount;
    } else {
      // Coût en montant fixe
      return price - cost;
    }
  }

  /// Calculer la marge en pourcentage
  double _calculateMarginPercent() {
    final price = int.tryParse(_priceController.text) ?? 0;
    if (price == 0) return 0;

    final marginAmount = _calculateMarginAmount();
    return (marginAmount / price * 100);
  }

  /// Sauvegarder le produit
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final itemBloc = context.read<ItemBloc>();

    // Valeurs du formulaire
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    String? sku = _skuController.text.trim();
    final barcode = _barcodeController.text.trim();
    final price = int.tryParse(_priceController.text) ?? 0;
    final cost = int.tryParse(_costController.text) ?? 0;
    final inStock = int.tryParse(_stockController.text) ?? 0;
    final lowStockThreshold = int.tryParse(_lowStockThresholdController.text) ?? 10;

    // Auto-générer SKU si vide
    if (sku.isEmpty) {
      sku = 'SKU-${DateTime.now().millisecondsSinceEpoch}';
    }

    // ID du magasin depuis l'état d'authentification
    final authState = context.read<AuthBloc>().state;
    final storeId = authState is AuthAuthenticatedWithStore
        ? authState.storeId
        : '';
    if (storeId.isEmpty) return;

    if (widget.itemId == null) {
      // Création
      final id = const Uuid().v4();
      itemBloc.add(CreateItemEvent(
        id: id,
        storeId: storeId,
        name: name,
        description: description.isEmpty ? null : description,
        sku: sku,
        barcode: barcode.isEmpty ? null : barcode,
        categoryId: _selectedCategoryId,
        price: price,
        cost: cost,
        costIsPercentage: _costIsPercentage,
        soldBy: _soldByWeight ? 'weight' : 'piece',
        availableForSale: _availableForSale,
        trackStock: _trackStock,
        inStock: inStock,
        lowStockThreshold: lowStockThreshold,
        imageUrl: _imageUrl,
      ));
    } else {
      // Mise à jour
      itemBloc.add(UpdateItemEvent(
        id: widget.itemId!,
        name: name,
        description: description.isEmpty ? null : description,
        sku: sku,
        barcode: barcode.isEmpty ? null : barcode,
        categoryId: _selectedCategoryId,
        price: price,
        cost: cost,
        costIsPercentage: _costIsPercentage,
        soldBy: _soldByWeight ? 'weight' : 'piece',
        availableForSale: _availableForSale,
        trackStock: _trackStock,
        inStock: inStock,
        lowStockThreshold: lowStockThreshold,
        imageUrl: _imageUrl,
      ));
    }
  }

  /// Sélectionner et uploader une photo
  Future<void> _selectAndUploadPhoto() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Sélectionner une image depuis la galerie
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Afficher un indicateur de chargement
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload en cours...')),
      );

      // Récupérer le storeId depuis AuthBloc
      final authState = context.read<AuthBloc>().state;

      String? storeId;
      if (authState is AuthPinSessionActive) {
        storeId = authState.user.storeId;
      } else if (authState is AuthAuthenticatedWithStore) {
        storeId = authState.storeId;
      }

      if (storeId == null) {
        throw Exception('Store ID not available');
      }

      // Uploader l'image
      final storageService = context.read<StorageService>();
      final imageUrl = await storageService.uploadProductImage(
        storeId: storeId,
        file: File(pickedFile.path),
        itemId: widget.itemId,
      );

      // Mettre à jour l'état local
      setState(() {
        _imageUrl = imageUrl;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.productFormSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur upload photo: $e'),
          backgroundColor: context.danger,
        ),
      );
    }
  }

  /// Supprimer le produit
  Future<void> _deleteProduct() async {
    if (widget.itemId == null) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.productFormDelete),
        content: Text(l10n.productFormDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: context.danger,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ItemBloc>().add(DeleteItemEvent(widget.itemId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ItemBloc, ItemState>(
      listener: (context, state) {
        if (state is ItemLoaded && widget.itemId != null) {
          // Charger les données du produit existant
          setState(() {
            _existingItem = state.item;
            _nameController.text = state.item.name;
            _descriptionController.text = state.item.description ?? '';
            _skuController.text = state.item.sku ?? '';
            _barcodeController.text = state.item.barcode ?? '';
            _priceController.text = state.item.price.toString();
            _costController.text = state.item.cost.toString();
            _costIsPercentage = state.item.costIsPercentage == 1;
            _availableForSale = state.item.availableForSale == 1;
            _soldByWeight = state.item.soldBy == 'weight';
            _trackStock = state.item.trackStock == 1;
            _stockController.text = state.item.inStock.toString();
            _lowStockThresholdController.text = state.item.lowStockThreshold.toString();
            _selectedCategoryId = state.item.categoryId;
            _imageUrl = state.item.imageUrl;
            _isLoading = false;
          });
        } else if (state is ItemOperationSuccess) {
          // Succès de l'opération
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.pop();
        } else if (state is ItemError) {
          // Erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.danger,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          title: Text(
            widget.itemId == null
                ? l10n.productFormNewTitle
                : '${l10n.productFormEditTitle} ${_existingItem?.name ?? ''}',
            style: AppTypography.screenTitle.copyWith(color: context.textPri),
          ),
          actions: [
            if (widget.itemId != null)
              IconButton(
                icon: Icon(Icons.delete_outline, color: context.danger),
                onPressed: _deleteProduct,
                tooltip: l10n.productFormDelete,
              ),
            TextButton(
              onPressed: _saveProduct,
              child: Text(
                l10n.productFormSave,
                style: AppTypography.button.copyWith(color: context.accent),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: context.accent))
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  children: [
                    _buildPhotoSection(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildBasicInfoSection(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildPricingSection(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSalesSection(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildStockSection(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildTaxesSection(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
      ),
    );
  }

  /// Section Photo
  Widget _buildPhotoSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          l10n.productFormPhotoSection,
          style: AppTypography.sectionLabel.copyWith(
            color: context.textHint,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: GestureDetector(
            onTap: _selectAndUploadPhoto,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: context.border, width: 1),
              ),
              child: _imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 40, color: context.textHint),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.productFormSelectPhoto,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSec,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Section Informations de base
  Widget _buildBasicInfoSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productFormBasicSection.toUpperCase(),
          style: AppTypography.sectionLabel.copyWith(
            color: context.textHint,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Nom
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.productFormName,
            hintText: l10n.productFormNameHint,
          ),
          style: AppTypography.body.copyWith(color: context.textPri),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.productFormNameRequired;
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Catégorie
        StreamBuilder<List<Category>>(
          stream: context.read<CategoryRepository>()
              .watchStoreCategories(
                (context.read<AuthBloc>().state is AuthAuthenticatedWithStore)
                    ? (context.read<AuthBloc>().state as AuthAuthenticatedWithStore).storeId
                    : '',
              ),
          builder: (context, snapshot) {
            final categories = snapshot.data ?? [];
            return DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.productFormCategory,
              ),
              initialValue: _selectedCategoryId,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    l10n.productFormNoCategory,
                    style: AppTypography.body.copyWith(color: context.textHint),
                  ),
                ),
                ...categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(
                      category.name,
                      style: AppTypography.body.copyWith(color: context.textPri),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedCategoryId = value);
              },
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Description
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: l10n.productFormDescription,
            hintText: l10n.productFormDescriptionHint,
            alignLabelWithHint: true,
          ),
          style: AppTypography.body.copyWith(color: context.textPri),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: AppSpacing.lg),

        // SKU
        TextFormField(
          controller: _skuController,
          decoration: InputDecoration(
            labelText: l10n.productFormSKU,
            hintText: l10n.productFormSKUHint,
          ),
          style: AppTypography.body.copyWith(color: context.textPri),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Code-barre
        TextFormField(
          controller: _barcodeController,
          decoration: InputDecoration(
            labelText: l10n.productFormBarcode,
            hintText: l10n.productFormBarcodeHint,
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                // TODO: Implémenter scan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scan barcode - À implémenter')),
                );
              },
            ),
          ),
          style: AppTypography.body.copyWith(color: context.textPri),
        ),
      ],
    );
  }

  /// Section Prix avec calcul de marge en live
  Widget _buildPricingSection() {
    final l10n = AppLocalizations.of(context)!;
    final marginAmount = _calculateMarginAmount();
    final marginPercent = _calculateMarginPercent();
    final isPositiveMargin = marginAmount >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productFormPricingSection.toUpperCase(),
          style: AppTypography.sectionLabel.copyWith(
            color: context.textHint,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Prix de vente
        TextFormField(
          controller: _priceController,
          decoration: InputDecoration(
            labelText: l10n.productFormSalePrice,
            hintText: l10n.productFormSalePriceHint,
            suffixText: 'Ar',
          ),
          style: AppTypography.body.copyWith(color: context.textPri),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.productFormSalePriceRequired;
            }
            final price = int.tryParse(value);
            if (price == null || price <= 0) {
              return l10n.productFormSalePriceRequired;
            }
            return null;
          },
          onChanged: (value) => setState(() {}), // Recalculer marge
        ),
        const SizedBox(height: AppSpacing.lg),

        // Coût d'achat
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _costController,
                decoration: InputDecoration(
                  labelText: l10n.productFormCost,
                  hintText: l10n.productFormCostHint,
                  suffixText: _costIsPercentage ? '%' : 'Ar',
                ),
                style: AppTypography.body.copyWith(color: context.textPri),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => setState(() {}), // Recalculer marge
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: context.border, width: 1),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => _costIsPercentage = false),
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(AppRadius.md),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: !_costIsPercentage
                            ? context.accent.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Ar',
                        style: AppTypography.label.copyWith(
                          color: !_costIsPercentage
                              ? context.accent
                              : context.textSec,
                          fontWeight: !_costIsPercentage
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: context.border,
                  ),
                  InkWell(
                    onTap: () => setState(() => _costIsPercentage = true),
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(AppRadius.md),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: _costIsPercentage
                            ? context.accent.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        '%',
                        style: AppTypography.label.copyWith(
                          color: _costIsPercentage
                              ? context.accent
                              : context.textSec,
                          fontWeight: _costIsPercentage
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Marge calculée
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isPositiveMargin
                ? (context.isDark
                    ? AppColors.successBgDark
                    : AppColors.successBgLight)
                : (context.isDark
                    ? AppColors.dangerBgDark
                    : AppColors.dangerBgLight),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isPositiveMargin ? context.success : context.danger,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.productFormMargin,
                style: AppTypography.label.copyWith(
                  color: isPositiveMargin ? context.success : context.danger,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${NumberFormat('#,###', 'fr').format(marginAmount)} Ar',
                    style: AppTypography.sectionTitle.copyWith(
                      color: isPositiveMargin ? context.success : context.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${marginPercent.toStringAsFixed(1)} %',
                    style: AppTypography.bodySmall.copyWith(
                      color: isPositiveMargin ? context.success : context.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section Vente
  Widget _buildSalesSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productFormSalesSection.toUpperCase(),
          style: AppTypography.sectionLabel.copyWith(
            color: context.textHint,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Disponible à la vente
        SwitchListTile(
          title: Text(
            l10n.productFormAvailableForSale,
            style: AppTypography.body.copyWith(color: context.textPri),
          ),
          value: _availableForSale,
          onChanged: (value) => setState(() => _availableForSale = value),
          activeTrackColor: context.accent.withValues(alpha: 0.5),
          activeThumbColor: context.accent,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(height: 1),

        // Vendu au poids
        SwitchListTile(
          title: Text(
            l10n.productFormSoldByWeight,
            style: AppTypography.body.copyWith(color: context.textPri),
          ),
          value: _soldByWeight,
          onChanged: (value) => setState(() => _soldByWeight = value),
          activeTrackColor: context.accent.withValues(alpha: 0.5),
          activeThumbColor: context.accent,
          contentPadding: EdgeInsets.zero,
        ),

        if (_soldByWeight) ...[
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _weightUnitController,
            decoration: InputDecoration(
              labelText: l10n.productFormWeightUnit,
              hintText: l10n.productFormWeightUnitHint,
            ),
            style: AppTypography.body.copyWith(color: context.textPri),
          ),
        ],
      ],
    );
  }

  /// Section Stock
  Widget _buildStockSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productFormStockSection.toUpperCase(),
          style: AppTypography.sectionLabel.copyWith(
            color: context.textHint,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Suivre le stock
        SwitchListTile(
          title: Text(
            l10n.productFormTrackStock,
            style: AppTypography.body.copyWith(color: context.textPri),
          ),
          value: _trackStock,
          onChanged: (value) => setState(() => _trackStock = value),
          activeTrackColor: context.accent.withValues(alpha: 0.5),
          activeThumbColor: context.accent,
          contentPadding: EdgeInsets.zero,
        ),

        if (_trackStock) ...[
          const SizedBox(height: AppSpacing.lg),

          // Stock actuel
          TextFormField(
            controller: _stockController,
            decoration: InputDecoration(
              labelText: l10n.productFormCurrentStock,
              hintText: l10n.productFormCurrentStockHint,
            ),
            style: AppTypography.body.copyWith(color: context.textPri),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Seuil d'alerte
          TextFormField(
            controller: _lowStockThresholdController,
            decoration: InputDecoration(
              labelText: l10n.productFormLowStockThreshold,
              hintText: l10n.productFormLowStockThresholdHint,
            ),
            style: AppTypography.body.copyWith(color: context.textPri),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ],
    );
  }

  /// Section Taxes
  Widget _buildTaxesSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productFormTaxesSection.toUpperCase(),
          style: AppTypography.sectionLabel.copyWith(
            color: context.textHint,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: context.textHint),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.productFormNoTaxes,
                  style: AppTypography.bodySmall.copyWith(color: context.textSec),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
