import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/sale.dart';
import '../../../../core/services/mobile_money_service.dart';

/// Service d'impression thermique ESC/POS - Phase 3.3
class ThermalPrinterService {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;
  final MobileMoneyService _mobileMoneyService = MobileMoneyService();

  // Constantes pour les tailles de texte
  static const int sizeNormal = 0;
  static const int sizeMedium = 1;
  static const int sizeLarge = 2;

  // Constantes pour l'alignement
  static const int alignLeft = 0;
  static const int alignCenter = 1;
  static const int alignRight = 2;

  /// Liste des imprimantes Bluetooth disponibles
  Future<List<BluetoothDevice>> getAvailablePrinters() async {
    try {
      return await _printer.getBondedDevices();
    } catch (e) {
      return [];
    }
  }

  /// Connecter à une imprimante
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await _printer.connect(device);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Déconnecter l'imprimante
  Future<void> disconnect() async {
    try {
      await _printer.disconnect();
    } catch (_) {}
  }

  /// Vérifier si connecté
  Future<bool> get isConnected async {
    try {
      final connected = await _printer.isConnected;
      return connected ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Imprimer un reçu de vente
  /// [paperWidth] : 58 ou 80 (mm)
  Future<void> printReceipt(
    Sale sale, {
    int paperWidth = 80,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? cashierName,
  }) async {
    final connected = await isConnected;
    if (!connected) {
      throw Exception('Imprimante non connectée');
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr');
    final maxChars = paperWidth == 58 ? 32 : 48;

    try {
      // Header - Nom du magasin
      _printer.printCustom(
        storeName ?? 'Nom du Magasin',
        sizeLarge,
        alignCenter,
      );
      _printer.printNewLine();

      // Adresse et téléphone
      if (storeAddress != null) {
        _printer.printCustom(
          storeAddress,
          sizeNormal,
          alignCenter,
        );
      }
      if (storePhone != null) {
        _printer.printCustom(
          'Tel: $storePhone',
          sizeNormal,
          alignCenter,
        );
      }
      _printer.printNewLine();

      // Ligne de séparation
      _printer.printCustom(
        '=' * maxChars,
        sizeNormal,
        alignCenter,
      );
      _printer.printNewLine();

      // Informations reçu
      _printLine('Reçu N°:', sale.receiptNumber);
      _printLine('Date:', dateFormat.format(sale.createdAt));
      if (cashierName != null) {
        _printLine('Caissier:', cashierName);
      }
      _printer.printNewLine();

      // Ligne de séparation
      _printer.printCustom(
        '-' * maxChars,
        sizeNormal,
        alignCenter,
      );
      _printer.printCustom(
        'Articles',
        sizeLarge,
        alignCenter,
      );
      _printer.printCustom(
        '-' * maxChars,
        sizeNormal,
        alignCenter,
      );

      // Liste des articles
      for (final item in sale.items) {
        // Nom de l'article
        _printer.printCustom(
          item.name,
          sizeNormal,
          alignLeft,
        );

        // Quantité x Prix unitaire = Total
        final qtyLine = '  ${item.quantity} x ${_formatPrice(item.unitPrice)}';
        _printLine(qtyLine, _formatPrice(item.lineTotal));
        _printer.printNewLine();
      }

      // Ligne de séparation
      _printer.printCustom(
        '-' * maxChars,
        sizeNormal,
        alignCenter,
      );

      // Totaux
      _printLine('Sous-total', _formatPrice(sale.subtotal));

      if (sale.discountAmount > 0) {
        _printLine('Remise', '-${_formatPrice(sale.discountAmount)}');
      }

      if (sale.taxAmount > 0) {
        _printLine('Taxes', _formatPrice(sale.taxAmount));
      }

      // Ligne de séparation avant total
      _printer.printCustom(
        '-' * maxChars,
        sizeNormal,
        alignCenter,
      );

      // Total final
      _printer.printCustom(
        'TOTAL',
        sizeLarge,
        alignLeft,
      );
      _printer.printCustom(
        _formatPrice(sale.total),
        sizeLarge,
        alignRight,
      );

      // Double ligne de séparation
      _printer.printCustom(
        '=' * maxChars,
        sizeNormal,
        alignCenter,
      );
      _printer.printNewLine();

      // Paiements
      _printer.printCustom(
        sale.payments.length > 1 ? 'Paiements' : 'Paiement',
        sizeMedium,
        alignLeft,
      );

      for (final payment in sale.payments) {
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

        _printLine('  $paymentTypeLabel', _formatPrice(payment.amount));

        // Print reference if available
        if (payment.paymentReference != null &&
            payment.paymentReference!.isNotEmpty) {
          final formattedRef =
              _formatPaymentReference(payment.paymentType, payment.paymentReference!);
          _printer.printCustom(
            '    Ref: $formattedRef',
            sizeNormal,
            alignLeft,
          );
        }
      }

      _printer.printNewLine();

      // Monnaie rendue
      if (sale.changeDue > 0) {
        _printLine('Monnaie rendue', _formatPrice(sale.changeDue));
        _printer.printNewLine();
      }

      // Note (if present)
      if (sale.note != null && sale.note!.isNotEmpty) {
        _printer.printCustom(
          '-' * maxChars,
          sizeNormal,
          alignCenter,
        );
        _printer.printCustom(
          'Note',
          sizeMedium,
          alignLeft,
        );
        _printer.printCustom(
          sale.note!,
          sizeNormal,
          alignLeft,
        );
        _printer.printNewLine();
      }

      // Ligne de séparation finale
      _printer.printCustom(
        '=' * maxChars,
        sizeNormal,
        alignCenter,
      );
      _printer.printNewLine();

      // Footer
      _printer.printCustom(
        'Merci de votre visite !',
        sizeMedium,
        alignCenter,
      );
      _printer.printNewLine();
      _printer.printCustom(
        'Retrouvez-nous sur nos reseaux',
        sizeNormal,
        alignCenter,
      );
      _printer.printNewLine();
      _printer.printCustom(
        '=' * maxChars,
        sizeNormal,
        alignCenter,
      );

      // Espaces pour couper le papier
      _printer.printNewLine();
      _printer.printNewLine();
      _printer.printNewLine();

      // Coupe du papier si supporté
      _printer.paperCut();
    } catch (e) {
      throw Exception('Erreur d\'impression: $e');
    }
  }

  /// Helper pour imprimer une ligne gauche/droite
  void _printLine(String label, String value) {
    _printer.printLeftRight(label, value, sizeNormal);
  }

  /// Test d'impression
  Future<void> printTest() async {
    final connected = await isConnected;
    if (!connected) {
      throw Exception('Imprimante non connectée');
    }

    _printer.printCustom(
      'Test d\'impression',
      sizeLarge,
      alignCenter,
    );
    _printer.printNewLine();
    _printer.printCustom(
      'POS Madagascar',
      sizeNormal,
      alignCenter,
    );
    _printer.printCustom(
      'Impression reussie !',
      sizeNormal,
      alignCenter,
    );
    _printer.printNewLine();
    _printer.printNewLine();
    _printer.printNewLine();
    _printer.paperCut();
  }

  /// Formater un prix en Ariary
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
