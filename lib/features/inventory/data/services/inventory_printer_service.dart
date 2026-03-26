import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import '../../../../core/data/local/app_database.dart';

/// Service d'impression thermique pour l'inventaire
/// Phase 3.15 — Format 58mm/80mm
class InventoryPrinterService {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;

  // Constantes pour les tailles de texte
  static const int sizeNormal = 0;
  static const int sizeMedium = 1;
  static const int sizeLarge = 2;

  // Constantes pour l'alignement
  static const int alignLeft = 0;
  static const int alignCenter = 1;
  static const int alignRight = 2;

  final numberFormat = NumberFormat('#,###', 'fr');
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr');

  /// Vérifier si connecté
  Future<bool> get isConnected async {
    try {
      final connected = await _printer.isConnected;
      return connected ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Imprimer résumé inventaire sur imprimante thermique
  /// Résumé : ruptures, alertes, top 10 items bas stock
  /// Format adapté 58mm/80mm
  Future<void> printInventorySummary({
    required List<Item> items,
    required Map<String, String> categoryNames,
    required String storeName,
    int paperWidth = 80,
  }) async {
    final connected = await isConnected;
    if (!connected) {
      throw Exception('Imprimante non connectée');
    }

    final maxChars = paperWidth == 58 ? 32 : 48;

    // Calculer métriques
    final outOfStockItems = items.where((item) => item.trackStock == 1 && item.inStock == 0).toList();
    final lowStockItems = items
        .where((item) =>
            item.trackStock == 1 && item.inStock > 0 && item.inStock <= item.lowStockThreshold)
        .toList();
    final totalValue = items
        .where((item) => item.trackStock == 1)
        .fold(0, (sum, item) => sum + (item.cost * item.inStock));

    // Trier par stock croissant pour top 10 bas stock
    final sortedByStock = [...items.where((item) => item.trackStock == 1)]
      ..sort((a, b) => a.inStock.compareTo(b.inStock));
    final top10LowStock = sortedByStock.take(10).toList();

    try {
      // Header
      _printer.printCustom(
        storeName,
        sizeLarge,
        alignCenter,
      );
      _printer.printNewLine();
      _printer.printCustom(
        'RESUME INVENTAIRE',
        sizeMedium,
        alignCenter,
      );
      _printer.printCustom(
        dateFormat.format(DateTime.now()),
        sizeNormal,
        alignCenter,
      );
      _printer.printNewLine();
      _printLine(maxChars);
      _printer.printNewLine();

      // Métriques
      _printer.printCustom(
        'METRIQUES',
        sizeMedium,
        alignLeft,
      );
      _printer.printNewLine();

      _printKeyValue('Produits suivis', items.where((item) => item.trackStock == 1).length.toString(), maxChars);
      _printKeyValue('Ruptures', outOfStockItems.length.toString(), maxChars);
      _printKeyValue('Alertes stock bas', lowStockItems.length.toString(), maxChars);
      if (totalValue > 0) {
        _printKeyValue('Valeur totale', '${numberFormat.format(totalValue)} Ar', maxChars);
      }

      _printer.printNewLine();
      _printLine(maxChars);
      _printer.printNewLine();

      // Ruptures de stock
      if (outOfStockItems.isNotEmpty) {
        _printer.printCustom(
          'RUPTURES (${outOfStockItems.length})',
          sizeMedium,
          alignLeft,
        );
        _printer.printNewLine();

        for (final item in outOfStockItems.take(10)) {
          _printItemLine(
            item.name,
            '0',
            maxChars,
          );
        }

        if (outOfStockItems.length > 10) {
          _printer.printCustom(
            '... et ${outOfStockItems.length - 10} autre(s)',
            sizeNormal,
            alignCenter,
          );
        }

        _printer.printNewLine();
        _printLine(maxChars);
        _printer.printNewLine();
      }

      // Top 10 stock bas
      if (top10LowStock.isNotEmpty) {
        _printer.printCustom(
          'TOP 10 STOCK BAS',
          sizeMedium,
          alignLeft,
        );
        _printer.printNewLine();

        for (final item in top10LowStock) {
          _printItemLine(
            item.name,
            '${item.inStock} / ${item.lowStockThreshold}',
            maxChars,
          );
        }

        _printer.printNewLine();
        _printLine(maxChars);
        _printer.printNewLine();
      }

      // Pied
      _printer.printCustom(
        'Genere par POS Madagascar',
        sizeNormal,
        alignCenter,
      );
      _printer.printNewLine();
      _printer.printNewLine();
      _printer.printNewLine();

      // Coupe papier (si supporté)
      _printer.paperCut();
    } catch (e) {
      throw Exception('Erreur impression: $e');
    }
  }

  // Helpers

  void _printLine(int maxChars) {
    _printer.printCustom(
      '-' * maxChars,
      sizeNormal,
      alignCenter,
    );
  }

  void _printKeyValue(String key, String value, int maxChars) {
    final availableSpace = maxChars - 2; // Marge
    final keyLength = key.length;
    final valueLength = value.length;
    final spacesNeeded = availableSpace - keyLength - valueLength;

    if (spacesNeeded > 0) {
      _printer.printCustom(
        '$key${' ' * spacesNeeded}$value',
        sizeNormal,
        alignLeft,
      );
    } else {
      // Si trop long, imprimer sur 2 lignes
      _printer.printCustom(key, sizeNormal, alignLeft);
      _printer.printCustom(value, sizeNormal, alignRight);
    }
  }

  void _printItemLine(String name, String stock, int maxChars) {
    final availableSpace = maxChars - 2;
    final stockLength = stock.length;
    final maxNameLength = availableSpace - stockLength - 1;

    String displayName = name;
    if (name.length > maxNameLength) {
      displayName = '${name.substring(0, maxNameLength - 3)}...';
    }

    final spacesNeeded = availableSpace - displayName.length - stockLength;

    if (spacesNeeded > 0) {
      _printer.printCustom(
        '$displayName${' ' * spacesNeeded}$stock',
        sizeNormal,
        alignLeft,
      );
    } else {
      _printer.printCustom(displayName, sizeNormal, alignLeft);
      _printer.printCustom(stock, sizeNormal, alignRight);
    }
  }
}
