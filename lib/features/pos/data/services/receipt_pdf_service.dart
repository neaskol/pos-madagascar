import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../domain/entities/sale.dart';
import '../../../../core/services/mobile_money_service.dart';

/// Service pour générer des PDF de reçus - Phase 2.4
class ReceiptPdfService {
  final MobileMoneyService _mobileMoneyService = MobileMoneyService();
  /// Génère un PDF pour un reçu de vente
  Future<Uint8List> generateReceiptPdf(Sale sale) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Receipt info
              _buildReceiptInfo(sale, dateFormat),
              pw.SizedBox(height: 24),

              // Items list
              _buildItemsTable(sale),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Totals
              _buildTotals(sale),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Payments
              _buildPayments(sale),

              if (sale.changeDue > 0) ...[
                pw.SizedBox(height: 16),
                _buildChange(sale),
              ],

              // Note (if present)
              if (sale.note != null && sale.note!.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.SizedBox(height: 16),
                _buildNote(sale),
              ],

              pw.Spacer(),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Footer
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader() {
    return pw.Column(
      children: [
        pw.Text(
          'Nom du Magasin',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Adresse du magasin',
          style: const pw.TextStyle(fontSize: 12),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Téléphone',
          style: const pw.TextStyle(fontSize: 12),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.Widget _buildReceiptInfo(Sale sale, DateFormat dateFormat) {
    return pw.Column(
      children: [
        _buildInfoRow('Reçu N°', sale.receiptNumber),
        pw.SizedBox(height: 4),
        _buildInfoRow('Date', dateFormat.format(sale.createdAt)),
        pw.SizedBox(height: 4),
        _buildInfoRow('Caissier', 'Employé'), // TODO: Nom réel
      ],
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable(Sale sale) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          'Articles',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('Article', isHeader: true),
                _buildTableCell('Qté', isHeader: true, align: pw.TextAlign.center),
                _buildTableCell('Prix U.', isHeader: true, align: pw.TextAlign.right),
                _buildTableCell('Total', isHeader: true, align: pw.TextAlign.right),
              ],
            ),
            // Items
            ...sale.items.map((item) {
              return pw.TableRow(
                children: [
                  _buildTableCell(item.name),
                  _buildTableCell(
                    '${item.quantity}',
                    align: pw.TextAlign.center,
                  ),
                  _buildTableCell(
                    _formatPrice(item.unitPrice),
                    align: pw.TextAlign.right,
                  ),
                  _buildTableCell(
                    _formatPrice(item.lineTotal),
                    align: pw.TextAlign.right,
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildTotals(Sale sale) {
    return pw.Column(
      children: [
        _buildTotalRow('Sous-total', sale.subtotal),
        if (sale.taxAmount > 0) ...[
          pw.SizedBox(height: 4),
          _buildTotalRow('Taxes', sale.taxAmount),
        ],
        if (sale.discountAmount > 0) ...[
          pw.SizedBox(height: 4),
          _buildTotalRow('Remise', -sale.discountAmount),
        ],
        pw.SizedBox(height: 8),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'TOTAL',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              _formatPrice(sale.total),
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTotalRow(String label, int amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.Text(
          _formatPrice(amount),
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPayments(Sale sale) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          'Paiement',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        ...sale.payments.map((payment) {
          String paymentTypeLabel;
          switch (payment.paymentType) {
            case PaymentType.cash:
              paymentTypeLabel = 'Espèces';
              break;
            case PaymentType.card:
              paymentTypeLabel = 'Carte bancaire';
              break;
            case PaymentType.mvola:
              paymentTypeLabel = 'MVola';
              break;
            case PaymentType.orangeMoney:
              paymentTypeLabel = 'Orange Money';
              break;
            case PaymentType.credit:
              paymentTypeLabel = 'Crédit';
              break;
            case PaymentType.custom:
              paymentTypeLabel = 'Autre';
              break;
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      paymentTypeLabel,
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                    pw.Text(
                      _formatPrice(payment.amount),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (payment.paymentReference != null &&
                  payment.paymentReference!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
                  child: pw.Text(
                    'Réf: ${_formatPaymentReference(payment.paymentType, payment.paymentReference!)}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildChange(Sale sale) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green700, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Monnaie rendue',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            _formatPrice(sale.changeDue),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildNote(Sale sale) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Note',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            sale.note!,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Text(
          'Merci de votre visite !',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Retrouvez-nous sur nos réseaux sociaux',
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  String _formatPrice(int amount) {
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        );
    return '$formatted Ar';
  }

  String _formatPaymentReference(PaymentType paymentType, String reference) {
    switch (paymentType) {
      case PaymentType.mvola:
        return _mobileMoneyService.formatMVolaReference(reference);
      case PaymentType.orangeMoney:
        return _mobileMoneyService.formatOrangeMoneyReference(reference);
      default:
        return reference;
    }
  }
}
