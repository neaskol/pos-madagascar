# Formules de calcul — POS Madagascar

Charger ce fichier quand : taxes, coût moyen pondéré, marges, arrondi caisse, bons de commande.

---

## Ariary — règles absolues

```dart
// TOUJOURS int, jamais double
// TOUJOURS formater avec :
String formatAriary(int amount) =>
    '${NumberFormat('#,###', 'fr').format(amount)} Ar';
// Résultat : "1 500 000 Ar"

// Arrondi de caisse (configurable dans StoreSettings.cashRoundingUnit)
int roundCash(int amount, int roundingUnit) {
  if (roundingUnit == 0) return amount;
  return ((amount / roundingUnit).round() * roundingUnit);
}
// Ex: roundCash(1347, 50) → 1350
// Ex: roundCash(1320, 50) → 1300
```

---

## Calcul des taxes (manuel Loyverse p.207-210)

```dart
// Type 1 — Taxe AJOUTÉE au prix
// Ex: article 1000 Ar + TVA 20% → client paie 1200 Ar, taxe = 200 Ar
int taxAddedAmount(int basePrice, double ratePercent) =>
    (basePrice * ratePercent / 100).round();

int totalWithAddedTax(int basePrice, double ratePercent) =>
    basePrice + taxAddedAmount(basePrice, ratePercent);

// Type 2 — Taxe INCLUSE dans le prix
// Ex: article affiché 1200 Ar TTC avec TVA 20% → taxe = 200 Ar, HT = 1000 Ar
int taxIncludedAmount(int priceWithTax, double ratePercent) =>
    (priceWithTax * ratePercent / (100 + ratePercent)).round();

int priceExcludingTax(int priceWithTax, double ratePercent) =>
    priceWithTax - taxIncludedAmount(priceWithTax, ratePercent);

// Plusieurs taxes sur un même item :
// Chaque taxe s'applique au PRIX DE BASE (jamais l'une sur l'autre)
int totalTaxAmount(int basePrice, List<Tax> taxes) {
  return taxes.fold(0, (sum, tax) {
    if (tax.type == TaxType.added) {
      return sum + taxAddedAmount(basePrice, tax.rate);
    } else {
      return sum + taxIncludedAmount(basePrice, tax.rate);
    }
  });
}
```

---

## Coût moyen pondéré (manuel Loyverse p.103)

Recalculer à **chaque réception** de stock via bon de commande.

```dart
// Formule : NewCost = (StockBefore × CostBefore + StockAdded × CostAdded)
//                   / (StockBefore + StockAdded)
int newAverageCost({
  required int stockBefore,
  required int costBefore,
  required int stockAdded,
  required int costAdded,
}) {
  final totalStock = stockBefore + stockAdded;
  if (totalStock == 0) return 0;
  return ((stockBefore * costBefore + stockAdded * costAdded) / totalStock)
      .round();
}

// Avec coûts additionnels (frais de port, douane — manuel p.111-113)
// Les coûts additionnels sont répartis proportionnellement par item
int costWithAdditionalCosts({
  required int itemPurchaseCost,
  required int itemSubtotal,    // coût total de cet item dans la commande
  required int orderSubtotal,   // coût total de tous les items de la commande
  required int additionalCosts, // total des frais additionnels
}) {
  if (orderSubtotal == 0) return itemPurchaseCost;
  final share = additionalCosts * itemSubtotal ~/ orderSubtotal;
  return itemPurchaseCost + share;
}
```

---

## Calcul de marge (notre différenciant vs Loyverse)

```dart
// Loyverse : prix d'achat en % impossible → marge incorrecte
// Notre app : coût en montant OU en % du prix de vente

int costAmount(int sellingPrice, int cost, bool costIsPercentage) {
  if (costIsPercentage) {
    return (sellingPrice * cost / 100).round();
  }
  return cost;
}

// Marge brute en Ariary
int grossMargin(int sellingPrice, int cost, bool costIsPercentage) =>
    sellingPrice - costAmount(sellingPrice, cost, costIsPercentage);

// Marge brute en %
double grossMarginPercent(int sellingPrice, int cost, bool costIsPercentage) {
  if (sellingPrice == 0) return 0;
  return grossMargin(sellingPrice, cost, costIsPercentage) / sellingPrice * 100;
}

// Alerte si vente à perte
bool isSoldAtLoss(int sellingPrice, int cost, bool costIsPercentage) =>
    grossMargin(sellingPrice, cost, costIsPercentage) < 0;
```

---

## Autofill bons de commande (manuel Loyverse p.110)

```dart
// Quantité à commander = Stock optimal - Stock actuel - En commande
int autofillQuantity({
  required int optimalStock,
  required int currentStock,
  required int incoming,  // qté en attente dans d'autres BdC non reçus
}) => max(0, optimalStock - currentStock - incoming);
```

---

## Rapport de valorisation inventaire (manuel Loyverse p.134)

```dart
class InventoryValuation {
  // Valeur totale inventaire = Σ (coût moyen × stock) par item
  static int totalInventoryValue(List<ItemStock> items) =>
      items.fold(0, (sum, i) => sum + (i.averageCost * i.inStock));

  // Valeur retail totale = Σ (prix de vente × stock) par item
  static int totalRetailValue(List<ItemStock> items) =>
      items.fold(0, (sum, i) => sum + (i.sellingPrice * i.inStock));

  // Profit potentiel = Valeur retail - Valeur inventaire
  static int potentialProfit(List<ItemStock> items) =>
      totalRetailValue(items) - totalInventoryValue(items);

  // Marge = Profit potentiel / Valeur retail × 100
  static double margin(List<ItemStock> items) {
    final retail = totalRetailValue(items);
    if (retail == 0) return 0;
    return potentialProfit(items) / retail * 100;
  }
  // Note : items à stock négatif exclus du calcul (comme Loyverse)
}
```

---

## Barcodes avec poids intégré (manuel Loyverse p.41-42)

```dart
// Format EAN-13 : YYCCCCCWWWWWX
// YY = préfixe "20" ou "02"
// CCCCC = SKU sur 5 chiffres
// WWWWW = poids en grammes (ex: 01750 = 1.750 kg)
// X = checksum

WeightBarcode? parseWeightBarcode(String barcode) {
  if (barcode.length != 13) return null;
  final prefix = barcode.substring(0, 2);
  if (prefix != '20' && prefix != '02') return null;

  final sku = barcode.substring(2, 7);
  final weightGrams = int.tryParse(barcode.substring(7, 12));
  if (weightGrams == null) return null;

  return WeightBarcode(
    sku: sku,
    weightKg: weightGrams / 1000,
  );
}
```

---

## Remises — ordre d'application (manuel Loyverse p.39)

```dart
// Plusieurs remises cumulées : appliquées de la plus petite à la plus grande valeur
// Une remise en % et une en montant fixe sur le même ticket :
// 1. Calculer la valeur effective de chaque remise
// 2. Trier par valeur croissante
// 3. Appliquer dans cet ordre

List<AppliedDiscount> sortDiscounts(int ticketTotal, List<Discount> discounts) {
  return discounts
      .map((d) => AppliedDiscount(
            discount: d,
            effectiveAmount: d.type == DiscountType.percentage
                ? (ticketTotal * d.value / 100).round()
                : d.value,
          ))
      .sorted((a, b) => a.effectiveAmount.compareTo(b.effectiveAmount));
}
```
