import 'package:url_launcher/url_launcher.dart';

/// Service for MVola and Orange Money mobile payment integration
/// Différenciant #4 - Aucun POS mondial ne supporte les Mobile Money malgaches
class MobileMoneyService {
  /// Launch MVola app with payment amount
  /// Returns true if app was launched successfully
  Future<bool> launchMVolaPayment({
    required String merchantNumber,
    required int amount,
  }) async {
    try {
      // Try deep link first (if MVola app is installed)
      final deepLinkUri = Uri.parse('mvola://pay?to=$merchantNumber&amount=$amount');

      if (await canLaunchUrl(deepLinkUri)) {
        return await launchUrl(deepLinkUri);
      }

      // Fallback to web link
      final webUri = Uri.parse('https://mvola.mg/pay?to=$merchantNumber&amount=$amount');
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Launch Orange Money app with payment amount
  /// Returns true if app was launched successfully
  Future<bool> launchOrangeMoneyPayment({
    required String merchantNumber,
    required int amount,
  }) async {
    try {
      // Try deep link first (if Orange Money app is installed)
      final deepLinkUri = Uri.parse('orangemoney://pay?to=$merchantNumber&amount=$amount');

      if (await canLaunchUrl(deepLinkUri)) {
        return await launchUrl(deepLinkUri);
      }

      // Fallback to USSD code (will open phone dialer)
      // Format: *144*4*1*merchantNumber*amount#
      final ussdUri = Uri.parse('tel:*144*4*1*$merchantNumber*$amount%23');
      if (await canLaunchUrl(ussdUri)) {
        return await launchUrl(ussdUri);
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Launch MVola via USSD code
  /// This is the most reliable method as it works even without the app
  /// Format: *111*1*merchantNumber*amount#
  Future<bool> launchMVolaUSSD({
    required String merchantNumber,
    required int amount,
  }) async {
    try {
      final ussdUri = Uri.parse('tel:*111*1*$merchantNumber*$amount%23');

      if (await canLaunchUrl(ussdUri)) {
        return await launchUrl(ussdUri);
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Validate MVola transaction reference format
  /// MVola references are typically 10-12 digits
  bool isValidMVolaReference(String reference) {
    if (reference.isEmpty) return false;

    // Remove spaces and check if it's numeric
    final cleaned = reference.replaceAll(RegExp(r'\s+'), '');

    // MVola references are typically 10-12 digits
    return RegExp(r'^\d{10,12}$').hasMatch(cleaned);
  }

  /// Validate Orange Money transaction reference format
  /// Orange Money references vary but are typically alphanumeric
  bool isValidOrangeMoneyReference(String reference) {
    if (reference.isEmpty) return false;

    // Remove spaces
    final cleaned = reference.replaceAll(RegExp(r'\s+'), '');

    // Orange Money references are typically 8-15 alphanumeric characters
    return RegExp(r'^[A-Z0-9]{8,15}$').hasMatch(cleaned.toUpperCase());
  }

  /// Format MVola reference for display
  /// Example: 1234567890 -> 123 456 7890
  String formatMVolaReference(String reference) {
    final cleaned = reference.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length <= 3) return cleaned;

    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  /// Format Orange Money reference for display
  /// Example: OM12345678 -> OM 1234 5678
  String formatOrangeMoneyReference(String reference) {
    final cleaned = reference.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length <= 2) return cleaned;

    // If starts with OM, keep it together
    if (cleaned.toUpperCase().startsWith('OM')) {
      final rest = cleaned.substring(2);
      final buffer = StringBuffer('OM ');
      for (int i = 0; i < rest.length; i++) {
        if (i > 0 && i % 4 == 0) {
          buffer.write(' ');
        }
        buffer.write(rest[i]);
      }
      return buffer.toString();
    }

    // Otherwise, group by 4
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  /// Get instructions for MVola payment
  String getMVolaInstructions(String merchantNumber, int amount) {
    final amountFormatted = formatAmount(amount);
    return '''
Pour payer avec MVola:

1. Composez *111*1*$merchantNumber*$amount# sur votre téléphone
   OU
   Ouvrez l'application MVola

2. Suivez les instructions pour confirmer le paiement de $amountFormatted

3. Vous recevrez un SMS avec le numéro de transaction

4. Saisissez ce numéro de transaction ci-dessous pour finaliser la vente
''';
  }

  /// Get instructions for Orange Money payment
  String getOrangeMoneyInstructions(String merchantNumber, int amount) {
    final amountFormatted = formatAmount(amount);
    return '''
Pour payer avec Orange Money:

1. Composez *144*4*1*$merchantNumber*$amount# sur votre téléphone
   OU
   Ouvrez l'application Orange Money

2. Suivez les instructions pour confirmer le paiement de $amountFormatted

3. Vous recevrez un SMS avec le code de transaction

4. Saisissez ce code de transaction ci-dessous pour finaliser la vente
''';
  }

  /// Format amount in Ariary for display
  String formatAmount(int amount) {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final amountStr = amount.toString().replaceAllMapped(formatter, (Match m) => '${m[1]} ');
    return '$amountStr Ar';
  }
}
