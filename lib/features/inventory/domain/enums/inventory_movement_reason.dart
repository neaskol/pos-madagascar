/// Raisons des mouvements de stock dans l'historique
/// Phase 3.14 - Inventory history tracking
enum InventoryMovementReason {
  /// Vente
  sale,

  /// Remboursement
  refund,

  /// Ajustement manuel
  adjustment,

  /// Bon de commande (réception)
  purchaseOrder,

  /// Transfert entre magasins
  transfer,

  /// Autre raison
  other,
}

/// Extension pour avoir les labels traduits
extension InventoryMovementReasonExtension on InventoryMovementReason {
  String get label {
    switch (this) {
      case InventoryMovementReason.sale:
        return 'Vente';
      case InventoryMovementReason.refund:
        return 'Remboursement';
      case InventoryMovementReason.adjustment:
        return 'Ajustement';
      case InventoryMovementReason.purchaseOrder:
        return 'Réception';
      case InventoryMovementReason.transfer:
        return 'Transfert';
      case InventoryMovementReason.other:
        return 'Autre';
    }
  }

  String get icon {
    switch (this) {
      case InventoryMovementReason.sale:
        return '→';
      case InventoryMovementReason.refund:
        return '←';
      case InventoryMovementReason.adjustment:
        return '⟳';
      case InventoryMovementReason.purchaseOrder:
        return '↓';
      case InventoryMovementReason.transfer:
        return '↔';
      case InventoryMovementReason.other:
        return '•';
    }
  }
}
