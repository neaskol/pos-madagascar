import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/data/local/app_database.dart';

/// Repository pour l'export d'inventaire en PDF et Excel
/// Feature 3.15 — Export/impression inventaire (différenciant vs Loyverse)
class InventoryExportRepository {
  final AppDatabase _database;

  InventoryExportRepository(this._database);

  /// Génère un fichier Excel de l'inventaire
  Future<File> exportToExcel({
    required String storeId,
    required String storeName,
    String? filterType, // 'all', 'low', 'out'
  }) async {
    final items = await _database.itemDao.getItemsByStore(storeId);
    final trackedItems = items.where((item) => item.trackStock == 1).toList();

    // Filtrer selon le type
    final List<Item> filteredItems;
    switch (filterType) {
      case 'low':
        filteredItems = trackedItems
            .where((item) =>
                item.inStock > 0 && item.inStock <= item.lowStockThreshold)
            .toList();
        break;
      case 'out':
        filteredItems = trackedItems.where((item) => item.inStock == 0).toList();
        break;
      default:
        filteredItems = trackedItems;
    }

    // Trier par urgence
    filteredItems.sort((a, b) {
      if (a.inStock == 0 && b.inStock != 0) return -1;
      if (a.inStock != 0 && b.inStock == 0) return 1;
      final aIsLow = a.inStock <= a.lowStockThreshold;
      final bIsLow = b.inStock <= b.lowStockThreshold;
      if (aIsLow && !bIsLow) return -1;
      if (!aIsLow && bIsLow) return 1;
      return a.inStock.compareTo(b.inStock);
    });

    // Créer le fichier Excel
    final excel = Excel.createExcel();
    final sheet = excel['Inventaire'];

    // Header
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4A5568'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    sheet.appendRow([
      TextCellValue('Produit'),
      TextCellValue('SKU'),
      TextCellValue('Stock actuel'),
      TextCellValue('Seuil alerte'),
      TextCellValue('Statut'),
      TextCellValue('Coût unitaire (Ar)'),
      TextCellValue('Valeur totale (Ar)'),
    ]);

    // Appliquer le style au header
    for (var i = 0; i < 7; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerStyle;
    }

    // Données
    final numberFormat = NumberFormat('#,###', 'fr');
    for (final item in filteredItems) {
      final status = item.inStock == 0
          ? 'Rupture'
          : item.inStock <= item.lowStockThreshold
              ? 'Bas stock'
              : 'OK';

      final totalValue = item.cost * item.inStock;

      sheet.appendRow([
        TextCellValue(item.name),
        TextCellValue(item.sku ?? ''),
        IntCellValue(item.inStock),
        IntCellValue(item.lowStockThreshold),
        TextCellValue(status),
        IntCellValue(item.cost),
        IntCellValue(totalValue),
      ]);
    }

    // Auto-ajuster les colonnes
    for (var i = 0; i < 7; i++) {
      sheet.setColWidth(i, 20);
    }

    // Ligne de total
    final totalValue = filteredItems.fold(
        0, (sum, item) => sum + (item.cost * item.inStock));
    final outOfStockCount = filteredItems.where((item) => item.inStock == 0).length;
    final lowStockCount = filteredItems
        .where((item) =>
            item.inStock > 0 && item.inStock <= item.lowStockThreshold)
        .length;

    sheet.appendRow([]);
    sheet.appendRow([
      TextCellValue('Résumé'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    sheet.appendRow([
      TextCellValue('Total produits'),
      IntCellValue(filteredItems.length),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    sheet.appendRow([
      TextCellValue('Ruptures'),
      IntCellValue(outOfStockCount),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    sheet.appendRow([
      TextCellValue('Bas stock'),
      IntCellValue(lowStockCount),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    sheet.appendRow([
      TextCellValue('Valeur totale'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      IntCellValue(totalValue),
    ]);

    // Sauvegarder le fichier
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/inventaire_$timestamp.xlsx';
    final file = File(filePath);

    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }

    return file;
  }

  /// Génère un PDF de l'inventaire
  Future<File> exportToPdf({
    required String storeId,
    required String storeName,
    String? filterType, // 'all', 'low', 'out'
  }) async {
    final items = await _database.itemDao.getItemsByStore(storeId);
    final trackedItems = items.where((item) => item.trackStock == 1).toList();

    // Filtrer selon le type
    final List<Item> filteredItems;
    switch (filterType) {
      case 'low':
        filteredItems = trackedItems
            .where((item) =>
                item.inStock > 0 && item.inStock <= item.lowStockThreshold)
            .toList();
        break;
      case 'out':
        filteredItems = trackedItems.where((item) => item.inStock == 0).toList();
        break;
      default:
        filteredItems = trackedItems;
    }

    // Trier par urgence
    filteredItems.sort((a, b) {
      if (a.inStock == 0 && b.inStock != 0) return -1;
      if (a.inStock != 0 && b.inStock == 0) return 1;
      final aIsLow = a.inStock <= a.lowStockThreshold;
      final bIsLow = b.inStock <= b.lowStockThreshold;
      if (aIsLow && !bIsLow) return -1;
      if (!aIsLow && bIsLow) return 1;
      return a.inStock.compareTo(b.inStock);
    });

    // Créer le PDF
    final pdf = pw.Document();
    final numberFormat = NumberFormat('#,###', 'fr');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr');

    final totalValue = filteredItems.fold(
        0, (sum, item) => sum + (item.cost * item.inStock));
    final outOfStockCount = filteredItems.where((item) => item.inStock == 0).length;
    final lowStockCount = filteredItems
        .where((item) =>
            item.inStock > 0 && item.inStock <= item.lowStockThreshold)
        .length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    storeName,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Inventaire — ${dateFormat.format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Métriques
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricBox(
                  'Total produits',
                  filteredItems.length.toString(),
                  PdfColors.blue,
                ),
                _buildMetricBox(
                  'Ruptures',
                  outOfStockCount.toString(),
                  PdfColors.red,
                ),
                _buildMetricBox(
                  'Bas stock',
                  lowStockCount.toString(),
                  PdfColors.orange,
                ),
                _buildMetricBox(
                  'Valeur totale',
                  '${numberFormat.format(totalValue)} Ar',
                  PdfColors.green,
                ),
              ],
            ),

            pw.SizedBox(height: 24),

            // Table
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey800,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(8),
              headers: [
                'Produit',
                'SKU',
                'Stock',
                'Seuil',
                'Statut',
                'Coût',
                'Valeur',
              ],
              data: filteredItems.map((item) {
                final status = item.inStock == 0
                    ? 'Rupture'
                    : item.inStock <= item.lowStockThreshold
                        ? 'Bas stock'
                        : 'OK';

                final totalValue = item.cost * item.inStock;

                return [
                  item.name,
                  item.sku ?? '',
                  item.inStock.toString(),
                  item.lowStockThreshold.toString(),
                  status,
                  '${numberFormat.format(item.cost)} Ar',
                  '${numberFormat.format(totalValue)} Ar',
                ];
              }).toList(),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                ),
              ),
            ),

            pw.SizedBox(height: 24),

            // Footer
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'Document généré par POS Madagascar — ${dateFormat.format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ),
          ];
        },
      ),
    );

    // Sauvegarder le fichier
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/inventaire_$timestamp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildMetricBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
