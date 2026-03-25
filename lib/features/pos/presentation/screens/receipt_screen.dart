import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../domain/entities/sale.dart';
import '../../domain/entities/discount.dart';
import '../../data/services/receipt_pdf_service.dart';
import '../../data/services/thermal_printer_service.dart';
import '../widgets/printer_selection_dialog.dart';

/// Écran d'affichage du reçu - Phase 2.4 / Phase 3.3
class ReceiptScreen extends StatefulWidget {
  final Sale sale;

  const ReceiptScreen({
    super.key,
    required this.sale,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final ThermalPrinterService _thermalPrinterService =
      ThermalPrinterService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Reçu ${widget.sale.receiptNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReceipt(context),
            tooltip: 'Partager',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.print),
            tooltip: 'Imprimer',
            onSelected: (value) {
              if (value == 'pdf') {
                _printReceipt(context);
              } else if (value == 'thermal') {
                _printThermalReceipt(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 12),
                    Text('Imprimer PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'thermal',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long),
                    SizedBox(width: 12),
                    Text('Imprimante thermique'),
                  ],
                ),
              ),
            ],
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

                    if (widget.sale.changeDue > 0) ...[
                      const SizedBox(height: 16),
                      _buildChange(context),
                    ],

                    // Note (if present)
                    if (widget.sale.note != null && widget.sale.note!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildNote(context),
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
        _buildInfoRow('Reçu N°', widget.sale.receiptNumber),
        _buildInfoRow('Date', dateFormat.format(widget.sale.createdAt)),
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
        ...widget.sale.items.map((item) => _buildItemRow(item)),
      ],
    );
  }

  Widget _buildItemRow(dynamic item) {
    // CartItem structure: name, quantity, unitPrice, lineTotal, discounts, taxes
    final name = item.name;
    final quantity = item.quantity;
    final unitPrice = item.unitPrice;
    final subtotal = item.subtotal;
    final discountAmount = item.totalDiscountAmount;
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
          // Show item discounts if any
          if (item.discounts != null && item.discounts.isNotEmpty)
            ...item.discounts.map((discount) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '  🏷️ ${discount.name ?? "Remise"} (${discount.type == DiscountType.percentage ? "${discount.value.toStringAsFixed(0)}%" : _formatPrice(discount.value.toInt())})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                        ),
                      ),
                      Text(
                        '-${_formatPrice(discount.calculateAmount(subtotal))}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                )),
          // Show item taxes if any
          if (item.taxes != null && item.taxes.isNotEmpty)
            ...item.taxes.map((tax) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '  ${tax.name} (${tax.rate.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        '+${_formatPrice(tax.calculateTaxAmount(unitPrice, subtotal - discountAmount))}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildTotals(BuildContext context) {
    // Calculate detailed breakdown
    final grossSubtotal =
        widget.sale.items.fold(0, (sum, item) => sum + item.subtotal);
    final itemDiscountsTotal =
        widget.sale.items.fold(0, (sum, item) => sum + item.totalDiscountAmount);
    final cartDiscountAmount = widget.sale.discountAmount - itemDiscountsTotal;

    return Column(
      children: [
        // Gross subtotal
        _buildTotalRow('Sous-total', grossSubtotal, false),

        // Item discounts (if any)
        if (itemDiscountsTotal > 0)
          _buildTotalRow(
            'Remises articles',
            -itemDiscountsTotal,
            false,
            color: Colors.red[700],
          ),

        // Cart discount (if any)
        if (cartDiscountAmount > 0)
          _buildTotalRow(
            'Remise panier',
            -cartDiscountAmount,
            false,
            color: Colors.red[700],
          ),

        // Taxes
        if (widget.sale.taxAmount > 0)
          _buildTotalRow('Taxes', widget.sale.taxAmount, false),

        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),

        // Final total
        _buildTotalRow('TOTAL', widget.sale.total, true),
      ],
    );
  }

  Widget _buildTotalRow(String label, int amount, bool isTotal,
      {Color? color}) {
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
              color: color,
            ),
          ),
          Text(
            _formatPrice(amount),
            style: TextStyle(
              fontSize: isTotal ? 20 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: color ?? (isTotal ? Colors.green[900] : Colors.black87),
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
          widget.sale.payments.length > 1 ? 'Paiements' : 'Paiement',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...widget.sale.payments.map((payment) {
          String paymentTypeLabel;
          IconData? paymentIcon;

          switch (payment.paymentType) {
            case PaymentType.cash:
              paymentTypeLabel = 'Espèces';
              paymentIcon = Icons.payments;
              break;
            case PaymentType.card:
              paymentTypeLabel = 'Carte bancaire';
              paymentIcon = Icons.credit_card;
              break;
            case PaymentType.mvola:
              paymentTypeLabel = 'MVola';
              paymentIcon = Icons.phone_android;
              break;
            case PaymentType.orangeMoney:
              paymentTypeLabel = 'Orange Money';
              paymentIcon = Icons.phone_iphone;
              break;
            case PaymentType.custom:
              paymentTypeLabel = 'Autre';
              paymentIcon = Icons.payment;
              break;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (widget.sale.payments.length > 1) ...[
                          Icon(
                            paymentIcon,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          paymentTypeLabel,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
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
                // Show reference if available (for MVola, Orange Money, Card)
                if (payment.paymentReference != null &&
                    payment.paymentReference!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 2),
                    child: Text(
                      'Réf: ${payment.paymentReference}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        // Show total if multiple payments
        if (widget.sale.payments.length > 1) ...[
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total payé',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatPrice(
                  widget.sale.payments.fold(0, (sum, p) => sum + p.amount),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
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
            _formatPrice(widget.sale.changeDue),
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

  Widget _buildNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                size: 18,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Note',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.sale.note!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[900],
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

  Future<void> _printThermalReceipt(BuildContext context) async {
    try {
      // Vérifier si déjà connecté
      final isConnected = await _thermalPrinterService.isConnected;

      if (!isConnected && context.mounted) {
        // Afficher le dialogue de sélection
        final device = await showDialog(
          context: context,
          builder: (context) => PrinterSelectionDialog(
            printerService: _thermalPrinterService,
          ),
        );

        if (device == null) return; // Utilisateur a annulé
      }

      // Imprimer le reçu
      await _thermalPrinterService.printReceipt(
        widget.sale,
        paperWidth: 80, // TODO: Récupérer depuis les réglages
        storeName: 'Nom du Magasin', // TODO: Récupérer depuis StoreSettings
        storeAddress: 'Adresse du magasin',
        storePhone: 'Téléphone',
        cashierName: 'Employé', // TODO: Récupérer nom réel
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reçu imprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'impression thermique: $e')),
        );
      }
    }
  }

  Future<void> _shareReceipt(BuildContext context) async {
    try {
      final pdfService = ReceiptPdfService();
      final pdfBytes = await pdfService.generateReceiptPdf(widget.sale);

      // Sauvegarder le PDF temporairement
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/receipt_${widget.sale.receiptNumber}.pdf');
      await file.writeAsBytes(pdfBytes);

      // Partager via share_plus
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Reçu ${widget.sale.receiptNumber}',
        text: 'Reçu de vente ${widget.sale.receiptNumber} - Total: ${_formatPrice(widget.sale.total)}',
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
      final pdfBytes = await pdfService.generateReceiptPdf(widget.sale);

      // Ouvrir le dialogue d'impression natif
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'receipt_${widget.sale.receiptNumber}.pdf',
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
🧾 *Reçu ${widget.sale.receiptNumber}*
📅 ${dateFormat.format(widget.sale.createdAt)}

*Articles:*
${widget.sale.items.map((item) => '• ${item.name} x${item.quantity} = ${_formatPrice(item.lineTotal)}').join('\n')}

*Sous-total:* ${_formatPrice(widget.sale.subtotal)}
${widget.sale.taxAmount > 0 ? '*Taxes:* ${_formatPrice(widget.sale.taxAmount)}\n' : ''}${widget.sale.discountAmount > 0 ? '*Remise:* -${_formatPrice(widget.sale.discountAmount)}\n' : ''}
*TOTAL:* ${_formatPrice(widget.sale.total)}

${widget.sale.payments.map((p) {
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
${widget.sale.changeDue > 0 ? '\n💵 *Monnaie rendue:* ${_formatPrice(widget.sale.changeDue)}' : ''}
${widget.sale.note != null && widget.sale.note!.isNotEmpty ? '\n📝 *Note:* ${widget.sale.note}' : ''}

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
