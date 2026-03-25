# 🚀 PHASE 3.2 - MULTI-PAYMENT IMPLEMENTATION PLAN

**Date de début**: 2026-03-25 14:25
**Durée estimée**: 2 jours (16h)
**Status**: 📝 PLANNING
**Prérequis**: Phase 3.1 (Remises & Taxes) ✅ COMPLÈTE

---

## 🎯 Objectif

Implémenter le système de **multi-paiement** (split payment) conforme à Loyverse avec support de toutes les méthodes de paiement:
- Cash (espèces)
- Carte bancaire
- **MVola** 🇲🇬 (différenciant #4)
- **Orange Money** 🇲🇬 (différenciant #4)
- Crédit magasin (différenciant #3)

---

## 📋 Scope Phase 3.2

### Must Have ✅
1. **UI Multi-Payment**: Interface permettant de diviser un paiement
2. **Payment Methods**: Activer Carte, MVola, Orange Money
3. **Split Logic**: Validation montant total = total vente
4. **Payment Flow**: Cash + Carte + Mobile Money combinations
5. **Receipt Update**: Afficher breakdown des paiements
6. **Database**: Migration sale_payments avec references

### Nice to Have (Phase 3.8+)
- API MVola intégration complète
- API Orange Money intégration complète
- QR code pour paiements mobiles
- Statuts paiement asynchrones

---

## 🏗️ Architecture Existante

### Current State (Phase 2.3)
✅ **Fichiers existants**:
- `payment_screen.dart` - Interface paiement **Cash uniquement**
- `sale.dart` - Entity avec `List<SalePayment> payments`
- `SalePayment` - Entity avec `PaymentType`, `amount`, `paymentReference`, `status`
- `PaymentType` enum - cash, card, mvola, orangeMoney, custom
- `PaymentStatus` enum - pending, completed, failed, refunded

✅ **Database** (déjà prête):
- Table `sales` avec colonnes existantes
- Table `sale_payments` (créée Phase 2)

### What Needs to Change
🔄 **payment_screen.dart**:
- Ajouter mode "Split Payment"
- Activer toutes les méthodes de paiement
- UI pour ajouter plusieurs paiements partiels
- Validation somme = total

🔄 **SaleBloc**:
- Supporter multi-payments dans `CreateSaleEvent`
- Validation paiements multiples

🔄 **Receipt Screen**:
- Afficher breakdown multi-payments

---

## 📐 UI Design - Multi-Payment Flow

### Payment Screen - Mode Single (Existant)
```
┌──────────────────────────────────────┐
│ Total à payer                   ▼    │  ← Dropdown mode
│      15 000 Ar                       │
├──────────────────────────────────────┤
│ Type de paiement                     │
│                                      │
│ ┌────────┐  ┌────────┐              │
│ │  💵    │  │  💳    │              │
│ │ Cash   │  │ Carte  │              │
│ └────────┘  └────────┘              │
│                                      │
│ ┌────────┐  ┌────────┐              │
│ │📱MVola │  │🍊Orange│              │
│ │        │  │  Money │              │
│ └────────┘  └────────┘              │
│                                      │
│ [Montant reçu, monnaie, etc.]       │
│                                      │
│ [VALIDER LE PAIEMENT]               │
└──────────────────────────────────────┘
```

### Payment Screen - Mode Split (NOUVEAU)
```
┌──────────────────────────────────────┐
│ Total à payer    ▼ Paiement divisé   │  ← Dropdown mode
│      15 000 Ar                       │
│                                      │
│ Paiements ajoutés:                   │
│ ┌────────────────────────────────┐  │
│ │ 💵 Cash         10 000 Ar   [×]│  │
│ │ 💳 Carte         3 000 Ar   [×]│  │
│ └────────────────────────────────┘  │
│                                      │
│ Restant à payer:    2 000 Ar         │ ← En gros, rouge si > 0
│                                      │
│ [+ Ajouter un paiement]             │
│                                      │
│ [VALIDER LE PAIEMENT] (enabled if restant = 0)
└──────────────────────────────────────┘
```

### Add Payment Dialog (NOUVEAU)
```
┌──────────────────────────────────────┐
│ Ajouter un paiement                  │
├──────────────────────────────────────┤
│ Méthode                              │
│                                      │
│ ○ 💵 Espèces                         │
│ ○ 💳 Carte bancaire                  │
│ ○ 📱 MVola                           │
│ ○ 🍊 Orange Money                    │
│ ○ 🏪 Crédit magasin                  │
│                                      │
│ Montant                              │
│ ┌────────────────────────────────┐  │
│ │ 10000                      Ar  │  │
│ └────────────────────────────────┘  │
│                                      │
│ [Montant suggéré: 2 000 Ar]         │ ← Restant à payer
│                                      │
│ Référence (optionnelle)             │
│ ┌────────────────────────────────┐  │
│ │ Ex: Transaction MVola #123456  │  │
│ └────────────────────────────────┘  │
│                                      │
│ [Annuler]           [Ajouter] →     │
└──────────────────────────────────────┘
```

---

## 📂 Fichiers à Créer/Modifier

### 1. Nouveau Widget: AddPaymentDialog
**Fichier**: `lib/features/pos/presentation/widgets/add_payment_dialog.dart`
**Lignes estimées**: ~250

```dart
class AddPaymentDialog extends StatefulWidget {
  final int remainingAmount;
  final Function(PaymentType type, int amount, String? reference) onAdd;
}
```

**Fonctionnalités**:
- RadioListTile pour chaque PaymentType
- TextField montant avec validation (≤ remainingAmount)
- TextField référence optionnelle
- Bouton "Montant suggéré" = remainingAmount
- Validation: montant > 0 et ≤ remainingAmount

### 2. Modifier: PaymentScreen
**Fichier**: `lib/features/pos/presentation/screens/payment_screen.dart`
**Modifications**: ~300 lignes supplémentaires

**Nouveaux states**:
```dart
enum PaymentMode { single, split }
PaymentMode _paymentMode = PaymentMode.single;
List<PartialPayment> _partialPayments = [];
```

**Nouveaux getters**:
```dart
int get _totalPaid => _partialPayments.fold(0, (sum, p) => sum + p.amount);
int get _remainingAmount => widget.total - _totalPaid;
bool get _canValidate => _remainingAmount == 0;
```

**Nouvelles méthodes**:
```dart
void _addPartialPayment(PaymentType type, int amount, String? reference)
void _removePartialPayment(int index)
void _showAddPaymentDialog()
Widget _buildSplitPaymentUI()
Widget _buildPaymentsList()
```

### 3. Modifier: SaleBloc
**Fichier**: `lib/features/pos/presentation/bloc/sale_bloc.dart`

**Modifier Event**:
```dart
class CreateSaleEvent extends SaleEvent {
  // AVANT:
  final PaymentType paymentType;
  final int amountReceived;

  // APRÈS:
  final List<SalePayment> payments;  // Supporter multi-payments
}
```

**Handler modifications**:
```dart
Future<void> _onCreateSale(CreateSaleEvent event, Emitter<SaleState> emit) async {
  // Valider: somme des payments = total
  final totalPaid = event.payments.fold(0, (sum, p) => sum + p.amount);
  if (totalPaid != event.total) {
    emit(SaleError('Montant total des paiements incorrect'));
    return;
  }

  // Créer vente avec plusieurs payments
  // ...
}
```

### 4. Modifier: Receipt Screen
**Fichier**: `lib/features/pos/presentation/screens/receipt_screen.dart`

**Nouvelle section**:
```dart
Widget _buildPaymentDetails() {
  if (sale.payments.length == 1) {
    // Single payment (existant)
    return Text('Payé par ${_getPaymentTypeLabel(sale.payments[0].paymentType)}');
  } else {
    // Multi-payment (NOUVEAU)
    return Column(
      children: [
        Text('Paiements:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...sale.payments.map((payment) => Padding(
          padding: EdgeInsets.only(left: 16, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_getPaymentTypeIcon(payment.paymentType)} ${_getPaymentTypeLabel(payment.paymentType)}'),
              Text(_formatPrice(payment.amount)),
            ],
          ),
        )),
      ],
    );
  }
}
```

---

## 🗄️ Database - Pas de Migration Nécessaire

✅ **sale_payments table existe déjà** (créée Phase 2.3):
```sql
CREATE TABLE sale_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES sales(id),
  payment_type TEXT NOT NULL,
  amount BIGINT NOT NULL,
  payment_reference TEXT,
  status TEXT NOT NULL DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Actions Database**: AUCUNE migration nécessaire ✅

---

## 🔨 Implémentation Step-by-Step

### Session 1: Multi-Payment UI (4h)
**Tâches**:
1. ✅ Créer `AddPaymentDialog`
   - Validations
   - Layout Material 3
   - Helper text

2. ✅ Modifier `PaymentScreen`
   - Ajouter `PaymentMode` enum
   - Dropdown mode selection
   - State `_partialPayments`
   - Getters `_totalPaid`, `_remainingAmount`

3. ✅ Implémenter Split UI
   - Liste paiements partiels
   - Bouton "+ Ajouter paiement"
   - Affichage "Restant à payer"
   - Delete payment partiel

4. ✅ Tester UX
   - Flow complet
   - Validations edge cases

**Livrables**:
- `add_payment_dialog.dart` (250 lignes)
- `payment_screen.dart` modifié (+300 lignes)
- UI fonctionnelle

**Commit**: `feat: Phase 3.2a - Multi-Payment UI`

---

### Session 2: Backend Integration (3h)
**Tâches**:
1. ✅ Modifier `CreateSaleEvent`
   - Remplacer `paymentType` + `amountReceived` par `List<SalePayment> payments`

2. ✅ Modifier `_onCreateSale` handler
   - Validation somme paiements = total
   - Boucle pour insérer chaque payment dans DB

3. ✅ Modifier `PaymentScreen._processPayment()`
   - Mode single: créer 1 SalePayment
   - Mode split: utiliser `_partialPayments`

4. ✅ Tester sauvegarde DB
   - Vérifier Supabase table `sale_payments`
   - Multi-payments insérés correctement

**Livrables**:
- `sale_bloc.dart` modifié
- `sale_event.dart` modifié
- `payment_screen.dart` finalisé

**Commit**: `feat: Phase 3.2b - Multi-Payment Backend Integration`

---

### Session 3: Receipt & Payment Methods (3h)
**Tâches**:
1. ✅ Activer tous les PaymentType dans UI
   - Retirer `enabled: false` des cards
   - Ajouter labels et icônes

2. ✅ Ajouter inputs spécifiques
   - MVola: Référence transaction obligatoire
   - Orange Money: Référence transaction obligatoire
   - Carte: Référence optionnelle (4 derniers chiffres)

3. ✅ Modifier Receipt Screen
   - Section "Paiements" détaillée
   - Icônes par type
   - Support multi-payment display

4. ✅ Helpers `_getPaymentTypeIcon()`, `_getPaymentTypeLabel()`

**Livrables**:
- `payment_screen.dart` - Toutes méthodes actives
- `receipt_screen.dart` - Breakdown paiements
- Helpers payment types

**Commit**: `feat: Phase 3.2c - All Payment Methods & Receipt Update`

---

### Session 4: Validation & Edge Cases (2h)
**Tâches**:
1. ✅ Validation Split Payment
   - Empêcher paiement si restant > 0
   - Message erreur si restant < 0 (impossible normalement)

2. ✅ Edge Cases
   - Supprimer dernier paiement
   - Ajouter paiement > restant (bloqué)
   - Mode switch avec paiements existants

3. ✅ UX Polish
   - Feedback haptique sur add/remove payment
   - Animations smooth
   - Loading states

4. ✅ Tester scenarios
   - Cash seul (existant)
   - Cash + Carte
   - Cash + MVola
   - 3+ paiements combinés

**Livrables**:
- Validations robustes
- Edge cases gérés
- UX fluide

**Commit**: `feat: Phase 3.2d - Validation & UX Polish`

---

### Session 5: Tests E2E & Documentation (2h)
**Tâches**:
1. ✅ Créer `test-e2e-phase3.2.md`
   - TC-PAY-001: Single payment (Cash)
   - TC-PAY-002: Single payment (Carte)
   - TC-PAY-003: Single payment (MVola)
   - TC-PAY-004: Split payment (Cash + Carte)
   - TC-PAY-005: Split payment (Cash + MVola + Orange)
   - TC-PAY-006: Validation (montant insuffisant)
   - TC-PAY-007: Validation (montant excédent)
   - TC-PAY-008: Receipt multi-payment display

2. ✅ Tester manuellement tous les cas

3. ✅ Documenter bugs trouvés

4. ✅ Créer `PHASE3.2-DONE.md`

**Livrables**:
- `test-e2e-phase3.2.md`
- `PHASE3.2-DONE.md`

**Commit**: `docs: Phase 3.2 - Tests E2E & Completion Report`

---

## 📊 Métriques Estimées

### Code
| Composant | Fichiers | Lignes | Type |
|-----------|----------|--------|------|
| AddPaymentDialog | 1 | 250 | UI |
| PaymentScreen | 1 | +300 | UI |
| SaleBloc | 1 | +50 | State |
| SaleEvent | 1 | +20 | State |
| ReceiptScreen | 1 | +80 | UI |
| **TOTAL** | **5** | **~700** | **Full Stack** |

### Temps
| Session | Tâche | Durée |
|---------|-------|-------|
| Session 1 | Multi-Payment UI | 4h |
| Session 2 | Backend Integration | 3h |
| Session 3 | Payment Methods & Receipt | 3h |
| Session 4 | Validation & Edge Cases | 2h |
| Session 5 | Tests & Documentation | 2h |
| **TOTAL** | **Phase 3.2 Complète** | **14h** |

---

## ✅ Critères de Succès

### Must Have - Phase 3.2
- [ ] Mode Single Payment fonctionne (existant, ne pas casser)
- [ ] Mode Split Payment fonctionne
- [ ] Toutes méthodes activées (Cash, Carte, MVola, Orange Money)
- [ ] Validation: somme paiements = total vente
- [ ] UI AddPaymentDialog fonctionnelle
- [ ] Payment cards affichent paiements partiels
- [ ] Delete payment partiel fonctionne
- [ ] Receipt affiche breakdown multi-payment
- [ ] Sauvegarde DB correcte (plusieurs sale_payments)

### Nice to Have (Phase 3.8+)
- [ ] API MVola intégration réelle
- [ ] API Orange Money intégration réelle
- [ ] QR code pour paiements mobiles
- [ ] Gestion statuts asynchrones (pending, failed)
- [ ] Retry logic pour paiements échoués

---

## 🎯 Acceptance Criteria

**Phase 3.2 est validée quand**:
1. ✅ User peut payer avec 1 seule méthode (existant)
2. ✅ User peut diviser paiement en 2+ méthodes
3. ✅ Validation empêche paiement si montant incomplet
4. ✅ Receipt affiche détail de chaque paiement
5. ✅ Référence paiement sauvegardée (MVola/Orange)
6. ✅ Toutes les méthodes fonctionnent en mode single
7. ✅ Toutes les méthodes fonctionnent en mode split
8. ✅ Tests E2E passent (8 test cases)
9. ✅ No regressions (Phase 2.3 functionality intact)

---

## 🚧 Risks & Mitigations

### Risk 1: Casser paiement Cash existant
**Mitigation**: Tester rigoureusement mode single après chaque changement

### Risk 2: Validation complexe multi-payment
**Mitigation**: Créer helper method dédiée, tests unitaires

### Risk 3: UI confusing pour l'utilisateur
**Mitigation**: UX tests, helper texts clairs, mode simple par défaut

### Risk 4: Race conditions multi-payments DB
**Mitigation**: Transaction Supabase (ou sequential inserts acceptable ici)

---

## 📖 Documentation à Lire AVANT

### Obligatoire
1. **START-PHASE3.md** - Section Phase 3.2
2. **docs/loyverse-features.md** - p.49-50 (Split Payment)
3. **PHASE3.1-DONE.md** - État Phase 3.1
4. **payment_screen.dart** - Code existant

### Recommandé
- **docs/design.md** - Material 3 guidelines
- **docs/formulas.md** - Calculs (pas de formule spéciale ici, juste somme)

---

## 🎨 UI/UX Guidelines

### Dropdown Mode Selection
```dart
DropdownButton<PaymentMode>(
  value: _paymentMode,
  items: [
    DropdownMenuItem(
      value: PaymentMode.single,
      child: Text('Paiement simple'),
    ),
    DropdownMenuItem(
      value: PaymentMode.split,
      child: Text('Paiement divisé'),
    ),
  ],
  onChanged: (mode) {
    setState(() {
      _paymentMode = mode!;
      if (mode == PaymentMode.single) {
        _partialPayments.clear();
      }
    });
  },
)
```

### Payment Type Icons
```dart
Map<PaymentType, IconData> paymentIcons = {
  PaymentType.cash: Icons.payments,
  PaymentType.card: Icons.credit_card,
  PaymentType.mvola: Icons.phone_android,
  PaymentType.orangeMoney: Icons.phone_iphone,
  PaymentType.custom: Icons.payment,
};
```

### Payment Type Labels
```dart
String _getPaymentTypeLabel(PaymentType type) {
  switch (type) {
    case PaymentType.cash: return 'Espèces';
    case PaymentType.card: return 'Carte bancaire';
    case PaymentType.mvola: return 'MVola';
    case PaymentType.orangeMoney: return 'Orange Money';
    case PaymentType.custom: return 'Autre';
  }
}
```

---

## 🔗 Liens entre Phases

### Phase 3.1 → Phase 3.2
✅ **Utilise**: Calculs remises et taxes déjà implémentés
✅ **Ne touche pas**: CartBloc, DiscountService
✅ **Prérequis**: `widget.total` correct avec remises/taxes

### Phase 3.2 → Phase 3.3
🔜 **Prépare**: Clients sur vente (ajout customerId dans CreateSaleEvent)

### Phase 3.2 → Phase 3.8
🔜 **API**: MVola/Orange Money - structure SalePayment avec paymentReference prête

---

## 🚀 Commencer Maintenant

### Étape 1: Créer AddPaymentDialog
```bash
code lib/features/pos/presentation/widgets/add_payment_dialog.dart
```

### Étape 2: Modifier PaymentScreen
```bash
code lib/features/pos/presentation/screens/payment_screen.dart
```

### Étape 3: Modifier SaleBloc
```bash
code lib/features/pos/presentation/bloc/sale_bloc.dart
code lib/features/pos/presentation/bloc/sale_event.dart
```

### Étape 4: Tests
```bash
flutter run -d 00008110-001E59D43E01801E
# Tester: Cash seul, puis split Cash+Carte
```

---

## 📝 Next Steps After Phase 3.2

### Immediate (Phase 3.3)
- Clients sur vente
- Recherche client rapide
- Nouveau client depuis POS

### Soon (Phase 3.4)
- Open Tickets (tickets sauvegardés)
- Merge & Split tickets

### Later (Phase 3.8)
- API MVola intégration complète
- API Orange Money intégration complète
- Vente à crédit (Phase 3.9)

---

**READY TO START! 🚀**

**Première action**: Créer `add_payment_dialog.dart`
