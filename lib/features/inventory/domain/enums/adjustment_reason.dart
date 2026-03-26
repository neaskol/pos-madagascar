/// Raisons d'ajustement de stock
/// Phase 3.14 - Stock adjustments
enum AdjustmentReason {
  /// Réception de marchandises
  receive,

  /// Perte de produits
  loss,

  /// Produits endommagés
  damage,

  /// Inventaire physique (comptage)
  count,

  /// Autre raison
  other,
}

/// Extension pour avoir les labels traduits
extension AdjustmentReasonExtension on AdjustmentReason {
  String get label {
    switch (this) {
      case AdjustmentReason.receive:
        return 'Réception';
      case AdjustmentReason.loss:
        return 'Perte';
      case AdjustmentReason.damage:
        return 'Dommage';
      case AdjustmentReason.count:
        return 'Inventaire';
      case AdjustmentReason.other:
        return 'Autre';
    }
  }
}
