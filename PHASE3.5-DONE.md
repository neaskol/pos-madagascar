# Phase 3.5 — Panier Avancé ✅

**Date de complétion** : 25 mars 2026
**Durée** : ~30 minutes (optimisé car features déjà présentes)

---

## 🎯 Objectif

Améliorer l'UX du panier pour des opérations rapides et professionnelles à la caisse.

---

## ✅ Fonctionnalités implémentées

### 1. **Modifier quantité inline** (AMÉLIORÉ)
**Avant** : Long press → dialog modal
**Après** : Boutons +/- directement visibles dans chaque item

#### Contrôles
- **Bouton `-`** : Diminue quantité de 1
  - Si quantité = 1 → retire l'item du panier
- **Affichage quantité** : Cliquable pour édition manuelle (dialog)
  - Format : "x1", "x2.5", etc.
  - Bordure grise pour indiquer cliquable
- **Bouton `+`** : Augmente quantité de 1

**Avantages** :
- Modifier quantité sans ouvrir de dialog
- Actions rapides pour caissier
- Feedback immédiat

**Fichier modifié** : `lib/features/pos/presentation/widgets/cart_panel.dart` (lignes 298-408)

---

### 2. **Swipe-to-delete** ✅ (DÉJÀ PRÉSENT)
- Swipe de droite à gauche sur un item
- Fond rouge avec icône poubelle
- Feedback haptique au swipe
- SnackBar de confirmation : "Nom du produit retiré du panier"

**Implémentation** : Widget `Dismissible` avec `DismissDirection.endToStart`

---

### 3. **Vider le ticket** ✅ (DÉJÀ PRÉSENT)
- Bouton dans menu POSScreen (AppBar → 3 points)
- Dialog de confirmation :
  - Titre : "Vider le ticket"
  - Message : "Êtes-vous sûr de vouloir vider le panier ?"
  - Actions : Annuler / Confirmer
- Event BLoC : `ClearCart()`

**Fichier** : `lib/features/pos/presentation/screens/pos_screen.dart` (lignes 144-164)

---

### 4. **Édition manuelle quantité** ✅ (OPTIMISÉ)
**Accessible** : Tap sur la zone quantité (ex: "x2")
**Dialog** :
- TextField avec clavier numérique décimal
- Autofocus pour saisie rapide
- Validation : quantité > 0
- Actions : Annuler / OK

**Cas d'usage** : Saisie rapide de grandes quantités (ex: "x50")

---

## 🎨 UX Améliorée

### Layout item panier
```
┌─────────────────────────────────────────┐
│ [IMG] Nom du produit (cliquable remise) │
│       [−] [x2] [+]              1 500 Ar │
└─────────────────────────────────────────┘
  ↑swipe← pour supprimer
```

### Interactions
| Action | Résultat |
|--------|----------|
| Tap nom produit | Ouvre dialog remise item |
| Tap `[-]` | Diminue quantité (ou retire si = 1) |
| Tap quantité `[x2]` | Ouvre dialog édition manuelle |
| Tap `[+]` | Augmente quantité |
| Swipe ← | Supprime item du panier |
| Menu → Vider | Dialog confirmation vider tout |

---

## 🔧 Détails techniques

### Architecture CartPanel
```
CartPanel (BlocBuilder<CartBloc>)
  └─ ListView.separated
      └─ _CartItemTile (Dismissible)
          ├─ Swipe-to-delete
          └─ Row
              ├─ Image/Placeholder
              ├─ Column (nom + contrôles)
              │   ├─ InkWell(nom) → ItemDiscountDialog
              │   └─ Row (+/- quantity)
              └─ Prix ligne
```

### Events CartBloc utilisés
- `UpdateItemQuantity(cartItemId, quantity)` — Modifier quantité
- `RemoveItemFromCart(cartItemId)` — Retirer item
- `ClearCart()` — Vider panier complet

---

## 📊 Comparaison avec Loyverse

| Feature | Loyverse | POS Madagascar |
|---------|----------|----------------|
| Modifier quantité | Tap item → +/- buttons | ✅ Identique (inline) |
| Supprimer item | Swipe left | ✅ Identique |
| Vider panier | Menu → Clear | ✅ Identique |
| Édition manuelle | Tap quantité | ✅ Amélioré (clavier décimal auto) |
| Alert stock négatif | ✅ Configurable | 🔜 À implémenter (Phase future) |

---

## 📋 Tests recommandés

### Tests UX
- [ ] Tap `[+]` augmente quantité → affichage mis à jour ✅
- [ ] Tap `[-]` diminue quantité → affichage mis à jour ✅
- [ ] Tap `[-]` à quantité 1 → item retiré du panier ✅
- [ ] Tap quantité → dialog s'ouvre avec valeur actuelle ✅
- [ ] Saisir quantité manuelle → validation OK ✅
- [ ] Swipe item ← → item supprimé + SnackBar ✅
- [ ] Menu → Vider → Annuler → panier intact ✅
- [ ] Menu → Vider → Confirmer → panier vide ✅

### Tests edge cases
- [ ] Modifier quantité à 0 via dialog → item retiré
- [ ] Saisir quantité négative → validation échoue
- [ ] Saisir quantité texte invalide → validation échoue
- [ ] Modifier quantité puis swipe → cohérence état

---

## 🚀 Impact utilisateur

### Gain de vitesse
- **Modifier quantité** : 3 actions (long press → dialog → saisir → OK) → **1 action** (tap +/-)
- **Supprimer item** : 2 actions (long press → confirmer) → **1 action** (swipe)
- **Vider panier** : Accessible depuis menu en 2 taps

### Cas d'usage optimaux
- **Caisse rapide** : Modifier quantités à la volée sans dialog
- **Correction erreurs** : Swipe rapide pour retirer item
- **Réinitialisation** : Vider panier entre clients

---

## 📊 Fichiers modifiés

| Fichier | Lignes | Type |
|---------|--------|------|
| `lib/features/pos/presentation/widgets/cart_panel.dart` | +110, -52 | Modifié |
| **TOTAL** | **+110 lignes** | |

---

## ✅ Statut

**Phase 3.5 terminée avec succès.**

- [x] Boutons +/- inline ajoutés
- [x] Swipe-to-delete vérifié (déjà présent)
- [x] Vider ticket vérifié (déjà présent)
- [x] Édition manuelle quantité optimisée
- [x] Analyse statique : 0 erreur
- [x] Documentation complète

---

## 🔜 Prochaines étapes

### Option A : Phase 3.6 — Variants & Modifiers (complexe, ~4-6h)
- Tables Supabase + Drift
- Variants : Taille/Couleur/Options
- Modifiers obligatoires (**gap Loyverse !**)

### Option B : Phase 3.7 — Grille Caisse Personnalisable (~3-4h)
- Pages multiples
- Drag & drop items
- Toggle grille/liste

### Option C : Sprint 4 — Opérations avancées
- Open tickets
- Shifts
- Clients & Fidélité
- Remboursements offline

---

## 📝 Notes

### Alert stock négatif
Non implémenté dans cette phase (aucune validation stock dans CartBloc actuellement).
**Recommandation** : Implémenter dans Phase future avec :
- Vérification stock dans `AddItemToCart` handler
- Dialog warning si stock < 0
- Option "Forcer la vente" (permission MANAGER/ADMIN)
- Enregistrement log "Vente avec stock négatif"

Cette feature nécessite :
1. Accès au stock actuel (ItemBloc/Repository)
2. Vérification à chaque ajout/modification quantité
3. Gestion permissions (voir `docs/differences.md` p.10)
