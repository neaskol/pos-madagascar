import 'package:intl/intl.dart';

class AriaryFormatter {
  AriaryFormatter._();

  /// Formate un montant en Ariary (toujours int, jamais double)
  /// Ex: 1500000 → "1 500 000 Ar"
  static String format(int amount) {
    return '${NumberFormat('#,###', 'fr').format(amount)} Ar';
  }

  /// Arrondi de caisse selon l'unité configurée
  /// Ex: roundCash(1347, 50) → 1350
  /// Ex: roundCash(1320, 50) → 1300
  static int roundCash(int amount, int roundingUnit) {
    if (roundingUnit == 0) return amount;
    return ((amount / roundingUnit).round() * roundingUnit);
  }
}
