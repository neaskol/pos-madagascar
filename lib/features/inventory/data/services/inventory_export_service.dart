import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../../core/data/local/app_database.dart';

/// Service d'export et d'impression d'inventaire
/// Phase 3.15 — Différenciant #10 (impossible chez Loyverse)
class InventoryExportService {
  final numberFormat = NumberFormat('#,###', 'fr');
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr');

  /// Export CSV — colonnes : Nom, SKU, Barcode, Catégorie, Prix vente, Coût, Stock, Seuil alerte, Valeur stock
  /// Séparateur `;` (standard français), encodage UTF-8 avec BOM (Excel FR)
  Future<void> exportToCsv({
    required List<Item> items,
    required Map<String, String> categoryNames,
    required String storeName,
  }) async {
    final buffer = StringBuffer();

    // UTF-8 BOM pour Excel FR
    buffer.write('\uFEFF');

    // En-tête
    buffer.writeln('Nom;SKU;Code-barres;Catégorie;Prix vente (Ar);Coût (Ar);Stock;Seuil alerte;Valeur stock (Ar)');

    // Lignes de données
    for (final item in items) {
      final categoryName = categoryNames[item.categoryId] ?? '';
      final stockValue = item.cost * item.inStock;

      buffer.writeln([
        _escapeCsv(item.name),
        _escapeCsv(item.sku ?? ''),
        _escapeCsv(item.barcode ?? ''),
        _escapeCsv(categoryName),
        item.price.toString(),
        item.cost.toString(),
        item.inStock.toString(),
        item.lowStockThreshold.toString(),
        stockValue.toString(),
      ].join(';'));
    }

    // Sauvegarder et partager
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/inventaire_$timestamp.csv');
    await file.writeAsString(buffer.toString(), encoding: utf8);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Inventaire $storeName - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
    );
  }

  /// Export PDF — format professionnel avec en-tête, tableau, et pied avec totaux
  Future<void> exportToPdf({
    required List<Item> items,
    required Map<String, String> categoryNames,
    required String storeName,
    String? logoUrl,
  }) async {
    final pdf = pw.Document();

    // Calculer les totaux
    final totalItems = items.length;
    final totalStockValue = items.fold(0, (sum, item) => sum + (item.cost * item.inStock));
    final totalRetailValue = items.fold(0, (sum, item) => sum + (item.price * item.inStock));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // En-tête
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          storeName,
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Inventaire',
                          style: const pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          dateFormat.format(DateTime.now()),
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '$totalItems produits',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 16),
              ],
            ),

            // Tableau
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3), // Nom
                1: const pw.FlexColumnWidth(1.5), // SKU
                2: const pw.FlexColumnWidth(1.5), // Catégorie
                3: const pw.FlexColumnWidth(1.5), // Prix
                4: const pw.FlexColumnWidth(1.5), // Coût
                5: const pw.FlexColumnWidth(1), // Stock
                6: const pw.FlexColumnWidth(1.5), // Valeur
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableHeader('Nom'),
                    _buildTableHeader('SKU'),
                    _buildTableHeader('Catégorie'),
                    _buildTableHeader('Prix vente'),
                    _buildTableHeader('Coût'),
                    _buildTableHeader('Stock'),
                    _buildTableHeader('Valeur'),
                  ],
                ),
                // Lignes
                ...items.map((item) {
                  final categoryName = categoryNames[item.categoryId] ?? '-';
                  final stockValue = item.cost * item.inStock;

                  return pw.TableRow(
                    children: [
                      _buildTableCell(item.name),
                      _buildTableCell(item.sku ?? '-'),
                      _buildTableCell(categoryName),
                      _buildTableCell('${numberFormat.format(item.price)} Ar', align: pw.TextAlign.right),
                      _buildTableCell('${numberFormat.format(item.cost)} Ar', align: pw.TextAlign.right),
                      _buildTableCell(item.inStock.toString(), align: pw.TextAlign.center),
                      _buildTableCell('${numberFormat.format(stockValue)} Ar', align: pw.TextAlign.right),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 24),

            // Pied — totaux
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  _buildTotalRow('Nombre total de produits', totalItems.toString()),
                  pw.SizedBox(height: 8),
                  _buildTotalRow('Valeur stock (coût)', '${numberFormat.format(totalStockValue)} Ar'),
                  pw.SizedBox(height: 8),
                  _buildTotalRow('Valeur retail', '${numberFormat.format(totalRetailValue)} Ar'),
                  pw.SizedBox(height: 8),
                  pw.Divider(),
                  pw.SizedBox(height: 8),
                  _buildTotalRow(
                    'Profit potentiel',
                    '${numberFormat.format(totalRetailValue - totalStockValue)} Ar',
                    bold: true,
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Sauvegarder et partager
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/inventaire_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Inventaire $storeName - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
    );
  }

  /// Feuille d'inventaire physique imprimable
  /// PDF avec colonnes : Nom | SKU | Stock système | Stock compté (vide) | Différence (vide)
  /// Trié par catégorie puis par nom, format A4, lignes alternées pour lisibilité
  Future<void> exportInventorySheet({
    required List<Item> items,
    required Map<String, String> categoryNames,
    required String storeName,
  }) async {
    final pdf = pw.Document();

    // Grouper par catégorie
    final itemsByCategory = <String, List<Item>>{};
    for (final item in items) {
      final categoryName = categoryNames[item.categoryId] ?? 'Sans catégorie';
      itemsByCategory.putIfAbsent(categoryName, () => []).add(item);
    }

    // Trier chaque catégorie par nom
    for (final category in itemsByCategory.values) {
      category.sort((a, b) => a.name.compareTo(b.name));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // En-tête
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Feuille de comptage physique',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  storeName,
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Date : ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 12),
              ],
            ),

            // Tableau par catégorie
            ...itemsByCategory.entries.map((entry) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Nom de catégorie
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    child: pw.Text(
                      entry.key.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),

                  // Tableau items
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3), // Nom
                      1: const pw.FlexColumnWidth(1.5), // SKU
                      2: const pw.FlexColumnWidth(1), // Stock système
                      3: const pw.FlexColumnWidth(1), // Stock compté
                      4: const pw.FlexColumnWidth(1), // Différence
                    },
                    children: [
                      // Header
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          _buildSheetHeader('Produit'),
                          _buildSheetHeader('SKU'),
                          _buildSheetHeader('Système'),
                          _buildSheetHeader('Compté'),
                          _buildSheetHeader('Écart'),
                        ],
                      ),
                      // Lignes items avec lignes alternées
                      ...entry.value.asMap().entries.map((itemEntry) {
                        final index = itemEntry.key;
                        final item = itemEntry.value;
                        final isEven = index % 2 == 0;

                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: isEven ? null : PdfColors.grey50,
                          ),
                          children: [
                            _buildSheetCell(item.name),
                            _buildSheetCell(item.sku ?? '-'),
                            _buildSheetCell(item.inStock.toString(), align: pw.TextAlign.center),
                            _buildSheetCell('', align: pw.TextAlign.center), // Vide pour comptage
                            _buildSheetCell('', align: pw.TextAlign.center), // Vide pour différence
                          ],
                        );
                      }),
                    ],
                  ),

                  pw.SizedBox(height: 16),
                ],
              );
            }),

            // Pied
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Compteur : ___________________',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Signature : ___________________',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Sauvegarder et partager
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/feuille_inventaire_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Feuille inventaire $storeName - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
    );
  }

  // Helpers PDF

  pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildSheetHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildSheetCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      constraints: const pw.BoxConstraints(minHeight: 20),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, String value, {bool bold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: bold ? 12 : 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: bold ? 12 : 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Helper CSV

  String _escapeCsv(String value) {
    if (value.contains(';') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
