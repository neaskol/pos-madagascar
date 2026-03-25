import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../domain/entities/sale.dart';
import '../../data/services/receipt_pdf_service.dart';

/// Écran d'affichage du reçu - Phase 2.4
class ReceiptScreen extends StatelessWidget {
  final Sale sale;

  const ReceiptScreen({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Reçu ${sale.receiptNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReceipt(context),
            tooltip: 'Partager',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReceipt(context),
            tooltip: 'Imprimer',
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header - Logo et nom magasin
                    _buildHeader(context),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Informations reçu
                    _buildReceiptInfo(context),

                    const SizedBox(height: 24),

                    // Liste des items
                    _buildItemsList(context),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Totaux
                    _buildTotals(context),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Paiements
                    _buildPayments(context),

                    if (sale.changeDue > 0) ...[
                      const SizedBox(height: 16),
                      _buildChange(context),
                    ],

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Footer
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildActions(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Logo placeholder (à remplacer par le vrai logo du magasin)
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.store,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nom du Magasin', // TODO: Récupérer depuis StoreSettings
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Adresse du magasin\nTéléphone',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReceiptInfo(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr');

    return Column(
      children: [
        _buildInfoRow('Reçu N°', sale.receiptNumber),
        _buildInfoRow('Date', dateFormat.format(sale.createdAt)),
        _buildInfoRow('Caissier', 'Employé'), // TODO: Récupérer nom employé
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Articles',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...sale.items.map((item) => _buildItemRow(item)),
      ],
    );
  }

  Widget _buildItemRow(dynamic item) {
    // CartItem structure: name, quantity, unitPrice, lineTotal
    final name = item.name;
    final quantity = item.quantity;
    final unitPrice = item.unitPrice;
    final total = item.lineTotal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _formatPrice(total),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$quantity x ${_formatPrice(unitPrice)}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals(BuildContext context) {
    return Column(
      children: [
        _buildTotalRow('Sous-total', sale.subtotal, false),
        if (sale.taxAmount > 0)
          _buildTotalRow('Taxes', sale.taxAmount, false),
        if (sale.discountAmount > 0)
          _buildTotalRow('Remise', -sale.discountAmount, false),
        const SizedBox(height: 8),
        _buildTotalRow('TOTAL', sale.total, true),
      ],
    );
  }

  Widget _buildTotalRow(String label, int amount, bool isTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _formatPrice(amount),
            style: TextStyle(
              fontSize: isTotal ? 20 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green[900] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Paiement',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
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
            case PaymentType.custom:
              paymentTypeLabel = 'Autre';
              break;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  paymentTypeLabel,
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  _formatPrice(payment.amount),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChange(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Monnaie rendue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
          Text(
            _formatPrice(sale.changeDue),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          'Merci de votre visite !',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Retrouvez-nous sur nos réseaux sociaux',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _shareWhatsApp(context),
              icon: const Icon(Icons.message),
              label: const Text('WhatsApp'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check),
              label: const Text('Terminer'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareReceipt(BuildContext context) async {
    try {
      final pdfService = ReceiptPdfService();
      final pdfBytes = await pdfService.generateReceiptPdf(sale);

      // Sauvegarder le PDF temporairement
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/receipt_${sale.receiptNumber}.pdf');
      await file.writeAsBytes(pdfBytes);

      // Partager via share_plus
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Reçu ${sale.receiptNumber}',
        text: 'Reçu de vente ${sale.receiptNumber} - Total: ${_formatPrice(sale.total)}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du partage: $e')),
        );
      }
    }
  }

  Future<void> _printReceipt(BuildContext context) async {
    try {
      final pdfService = ReceiptPdfService();
      final pdfBytes = await pdfService.generateReceiptPdf(sale);

      // Ouvrir le dialogue d'impression natif
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'receipt_${sale.receiptNumber}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'impression: $e')),
        );
      }
    }
  }

  Future<void> _shareWhatsApp(BuildContext context) async {
    try {
      // Générer le texte du reçu pour WhatsApp
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr');
      final message = '''
🧾 *Reçu ${sale.receiptNumber}*
📅 ${dateFormat.format(sale.createdAt)}

*Articles:*
${sale.items.map((item) => '• ${item.name} x${item.quantity} = ${_formatPrice(item.lineTotal)}').join('\n')}

*Sous-total:* ${_formatPrice(sale.subtotal)}
${sale.taxAmount > 0 ? '*Taxes:* ${_formatPrice(sale.taxAmount)}\n' : ''}${sale.discountAmount > 0 ? '*Remise:* -${_formatPrice(sale.discountAmount)}\n' : ''}
*TOTAL:* ${_formatPrice(sale.total)}

${sale.payments.map((p) {
        String type;
        switch (p.paymentType) {
          case PaymentType.cash:
            type = 'Espèces';
            break;
          case PaymentType.card:
            type = 'Carte';
            break;
          case PaymentType.mvola:
            type = 'MVola';
            break;
          case PaymentType.orangeMoney:
            type = 'Orange Money';
            break;
          case PaymentType.custom:
            type = 'Autre';
            break;
        }
        return '*$type:* ${_formatPrice(p.amount)}';
      }).join('\n')}
${sale.changeDue > 0 ? '\n💵 *Monnaie rendue:* ${_formatPrice(sale.changeDue)}' : ''}

Merci de votre visite ! 🙏
''';

      // URL encoder le message
      final encodedMessage = Uri.encodeComponent(message);

      // Ouvrir WhatsApp avec le message pré-rempli
      final whatsappUrl = Uri.parse('https://wa.me/?text=$encodedMessage');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Impossible d\'ouvrir WhatsApp');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du partage WhatsApp: $e')),
        );
      }
    }
  }

  String _formatPrice(int amount) {
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        );
    return '$formatted Ar';
  }
}
