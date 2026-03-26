import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/app_database.dart';
import 'item_repository.dart';

/// Modèle représentant une ligne d'import avec validation
class ImportItemRow {
  final int lineNumber;
  final String? name;
  final String? sku;
  final String? barcode;
  final String? category;
  final String? price;
  final String? cost;
  final String? inStock;
  final String? lowStockThreshold;
  final String? description;

  // Validation
  final List<String> errors;

  ImportItemRow({
    required this.lineNumber,
    this.name,
    this.sku,
    this.barcode,
    this.category,
    this.price,
    this.cost,
    this.inStock,
    this.lowStockThreshold,
    this.description,
    this.errors = const [],
  });

  bool get isValid => errors.isEmpty;

  /// Valide une ligne et retourne les erreurs
  static ImportItemRow validate(int lineNumber, List<String> row) {
    final errors = <String>[];

    // Colonnes attendues : Name, SKU, Barcode, Category, Price, Cost, InStock, LowStockThreshold, Description
    final name = row.length > 0 ? row[0].trim() : null;
    final sku = row.length > 1 ? row[1].trim() : null;
    final barcode = row.length > 2 ? row[2].trim() : null;
    final category = row.length > 3 ? row[3].trim() : null;
    final price = row.length > 4 ? row[4].trim() : null;
    final cost = row.length > 5 ? row[5].trim() : null;
    final inStock = row.length > 6 ? row[6].trim() : null;
    final lowStockThreshold = row.length > 7 ? row[7].trim() : null;
    final description = row.length > 8 ? row[8].trim() : null;

    // Validation obligatoire : nom et prix
    if (name == null || name.isEmpty) {
      errors.add('Le nom est obligatoire');
    }

    if (price == null || price.isEmpty) {
      errors.add('Le prix est obligatoire');
    } else {
      final priceInt = int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), ''));
      if (priceInt == null || priceInt < 0) {
        errors.add('Prix invalide (doit être un nombre entier positif en Ariary)');
      }
    }

    // Validation optionnelle : coût
    if (cost != null && cost.isNotEmpty) {
      final costInt = int.tryParse(cost.replaceAll(RegExp(r'[^0-9]'), ''));
      if (costInt == null || costInt < 0) {
        errors.add('Coût invalide (doit être un nombre entier positif)');
      }
    }

    // Validation optionnelle : stock
    if (inStock != null && inStock.isNotEmpty) {
      final stockInt = int.tryParse(inStock.replaceAll(RegExp(r'[^0-9]'), ''));
      if (stockInt == null || stockInt < 0) {
        errors.add('Stock invalide (doit être un nombre entier positif)');
      }
    }

    // Validation optionnelle : seuil d'alerte
    if (lowStockThreshold != null && lowStockThreshold.isNotEmpty) {
      final thresholdInt = int.tryParse(lowStockThreshold.replaceAll(RegExp(r'[^0-9]'), ''));
      if (thresholdInt == null || thresholdInt < 0) {
        errors.add('Seuil d\'alerte invalide (doit être un nombre entier positif)');
      }
    }

    return ImportItemRow(
      lineNumber: lineNumber,
      name: name,
      sku: sku,
      barcode: barcode,
      category: category,
      price: price,
      cost: cost,
      inStock: inStock,
      lowStockThreshold: lowStockThreshold,
      description: description,
      errors: errors,
    );
  }
}

/// Résultat d'un import
class ImportResult {
  final int totalRows;
  final int successCount;
  final int errorCount;
  final List<ImportItemRow> errorRows;

  ImportResult({
    required this.totalRows,
    required this.successCount,
    required this.errorCount,
    required this.errorRows,
  });
}

/// Repository pour l'import de produits CSV/Excel
class ItemImportRepository {
  final ItemRepository _itemRepository;
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  ItemImportRepository(this._itemRepository, this._database);

  /// Sélectionner et lire un fichier CSV/Excel
  Future<List<ImportItemRow>?> pickAndParseFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final path = file.path;

      if (path == null) {
        throw Exception('Impossible de lire le fichier');
      }

      final extension = file.extension?.toLowerCase();

      if (extension == 'csv') {
        return _parseCSV(path);
      } else if (extension == 'xlsx' || extension == 'xls') {
        return _parseExcel(path);
      } else {
        throw Exception('Format de fichier non supporté');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Parser un fichier CSV
  Future<List<ImportItemRow>> _parseCSV(String path) async {
    final file = File(path);
    final content = await file.readAsString();

    final rows = const CsvToListConverter().convert(
      content,
      eol: '\n',
      fieldDelimiter: ',',
      textDelimiter: '"',
    );

    if (rows.isEmpty) {
      throw Exception('Le fichier est vide');
    }

    // Ignorer la ligne d'en-tête (ligne 1)
    final dataRows = rows.skip(1).toList();

    return _validateRows(dataRows);
  }

  /// Parser un fichier Excel
  Future<List<ImportItemRow>> _parseExcel(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) {
      throw Exception('Le fichier Excel ne contient aucune feuille');
    }

    // Prendre la première feuille
    final sheet = excel.tables[excel.tables.keys.first];

    if (sheet == null || sheet.rows.isEmpty) {
      throw Exception('La feuille est vide');
    }

    // Ignorer la ligne d'en-tête (ligne 1)
    final dataRows = sheet.rows.skip(1).map((row) {
      return row.map((cell) => cell?.value?.toString() ?? '').toList();
    }).toList();

    return _validateRows(dataRows);
  }

  /// Valider toutes les lignes
  List<ImportItemRow> _validateRows(List<List<dynamic>> rows) {
    final validatedRows = <ImportItemRow>[];

    for (var i = 0; i < rows.length; i++) {
      final lineNumber = i + 2; // +2 car ligne 1 = en-tête, ligne 2 = première data
      final row = rows[i].map((cell) => cell.toString()).toList();

      // Ignorer les lignes vides
      if (row.every((cell) => cell.trim().isEmpty)) {
        continue;
      }

      final validated = ImportItemRow.validate(lineNumber, row);
      validatedRows.add(validated);
    }

    return validatedRows;
  }

  /// Importer les items validés dans la base de données
  Future<ImportResult> importItems({
    required String storeId,
    required List<ImportItemRow> rows,
    required Map<String, String> categoryMapping, // category name -> category id
  }) async {
    final errorRows = <ImportItemRow>[];
    var successCount = 0;

    for (final row in rows) {
      if (!row.isValid) {
        errorRows.add(row);
        continue;
      }

      try {
        // Récupérer l'ID de la catégorie si elle existe
        String? categoryId;
        if (row.category != null && row.category!.isNotEmpty) {
          categoryId = categoryMapping[row.category];
        }

        // Générer un SKU unique si non fourni
        final sku = row.sku?.isNotEmpty == true ? row.sku : 'SKU-${_uuid.v4().substring(0, 8).toUpperCase()}';

        // Parser les valeurs numériques
        final price = int.parse(row.price!.replaceAll(RegExp(r'[^0-9]'), ''));
        final cost = row.cost != null && row.cost!.isNotEmpty
            ? int.parse(row.cost!.replaceAll(RegExp(r'[^0-9]'), ''))
            : 0;
        final inStock = row.inStock != null && row.inStock!.isNotEmpty
            ? int.parse(row.inStock!.replaceAll(RegExp(r'[^0-9]'), ''))
            : 0;
        final lowStockThreshold = row.lowStockThreshold != null && row.lowStockThreshold!.isNotEmpty
            ? int.parse(row.lowStockThreshold!.replaceAll(RegExp(r'[^0-9]'), ''))
            : 0;

        // Créer l'item
        await _itemRepository.createItem(
          id: _uuid.v4(),
          storeId: storeId,
          name: row.name!,
          description: row.description?.isNotEmpty == true ? row.description : null,
          sku: sku,
          barcode: row.barcode?.isNotEmpty == true ? row.barcode : null,
          categoryId: categoryId,
          price: price,
          cost: cost,
          costIsPercentage: false,
          soldBy: 'piece',
          availableForSale: true,
          trackStock: inStock > 0 || lowStockThreshold > 0,
          inStock: inStock,
          lowStockThreshold: lowStockThreshold,
          isComposite: false,
          useProduction: false,
          imageUrl: null,
          averageCost: cost,
        );

        successCount++;
      } catch (e) {
        // Ajouter l'erreur à la ligne
        final errorRow = ImportItemRow(
          lineNumber: row.lineNumber,
          name: row.name,
          sku: row.sku,
          barcode: row.barcode,
          category: row.category,
          price: row.price,
          cost: row.cost,
          inStock: row.inStock,
          lowStockThreshold: row.lowStockThreshold,
          description: row.description,
          errors: [...row.errors, 'Erreur lors de l\'import: ${e.toString()}'],
        );
        errorRows.add(errorRow);
      }
    }

    return ImportResult(
      totalRows: rows.length,
      successCount: successCount,
      errorCount: errorRows.length,
      errorRows: errorRows,
    );
  }

  /// Récupérer toutes les catégories du magasin pour le mapping
  Future<Map<String, String>> getCategoryMapping(String storeId) async {
    final categories = await _database.categoryDao.getCategoriesByStore(storeId).get();
    final mapping = <String, String>{};

    for (final category in categories) {
      mapping[category.name] = category.id;
    }

    return mapping;
  }

  /// Générer un template CSV pour l'import
  String generateCSVTemplate() {
    return 'Name,SKU,Barcode,Category,Price,Cost,InStock,LowStockThreshold,Description\n'
        'Exemple Produit 1,SKU-001,1234567890123,Alimentation,5000,3000,100,10,Description du produit\n'
        'Exemple Produit 2,SKU-002,9876543210987,Boisson,2500,1500,50,5,Autre description';
  }
}
