# Phase 3.6 — Variants & Modifiers (EN COURS)

**Date de début** : 25 mars 2026
**Statut** : Infrastructure complète, intégration UI en cours

---

## 🎯 Objectif

Implémenter variants (taille, couleur...) et modifiers (options obligatoires) pour les produits.

**Différenciant vs Loyverse** : Modifiers obligatoires (forced modifiers) — Loyverse ne les supporte pas (p.65-66).

---

## ✅ Fonctionnalités complétées

### 1. **Infrastructure base de données** ✅

#### Supabase (migration créée)
- `item_variants` — variants avec max 3 options (limitation Loyverse)
- `modifiers` — ensembles d'options avec flag `is_required`
- `modifier_options` — options avec prix additionnel
- `item_modifiers` — liaison many-to-many item <-> modifier

**Fichier** : `supabase/migrations/20260325000004_create_variants_and_modifiers.sql`

#### Drift (offline-first) ✅
- 4 tables créées avec métadonnées `synced`
- Foreign keys configurées
- Index de performance ajoutés

**Fichiers** :
- `lib/core/data/local/tables/item_variants.drift`
- `lib/core/data/local/tables/modifiers.drift`
- `lib/core/data/local/tables/modifier_options.drift`
- `lib/core/data/local/tables/item_modifiers.drift`

**Intégration** : `lib/core/data/local/app_database.dart` (mis à jour)

---

### 2. **Entités de domaine** ✅

#### ItemVariant
- Support 3 options (option1, option2, option3)
- Prix/coût optionnels (null = hérite du parent)
- Propriété `displayLabel` (ex: "Grande - Rouge")

**Fichier** : `lib/features/products/domain/entities/item_variant.dart`

#### Modifier & ModifierOption
- `Modifier.isRequired` pour forcer sélection
- `ModifierOption.priceAddition` en Ariary
- Relation 1-to-many

**Fichiers** :
- `lib/features/products/domain/entities/modifier.dart`
- `lib/features/products/domain/entities/modifier_option.dart`

---

### 3. **UI Dialogs** ✅

#### VariantSelectionDialog
- Affichage liste variants avec images
- Sélection unique
- Affichage prix variant (si différent du parent)

**Fichier** : `lib/features/products/presentation/widgets/variant_selection_dialog.dart`

#### ModifiersSelectionDialog
- Support modifiers multiples
- Badge "OBLIGATOIRE" pour forced modifiers
- Validation : bloque confirmation si modifier requis non sélectionné
- Affichage prix additionnel
- Retour `ModifiersSelectionResult` avec total

**Fichier** : `lib/features/products/presentation/widgets/modifiers_selection_dialog.dart`

---

### 4. **Compatibilité CartItem** ✅

Le `CartItem` existant supporte déjà :
- `itemVariantId` (String?)
- `modifiers` (Map<String, dynamic>?)

Aucune modification nécessaire.

**Fichier** : `lib/features/pos/domain/entities/cart_item.dart` (lignes 9, 16)

---

## ⏳ Fonctionnalités restantes

### 5. **DAOs et Repositories** (TODO)

Créer pour chaque table :
- DAO Drift (lecture/écriture offline)
- Repository (sync Supabase <-> Drift)
- Events/States BLoC si nécessaire

**Fichiers à créer** :
```
lib/core/data/local/daos/
  ├── item_variant_dao.dart
  ├── modifier_dao.dart
  └── modifier_option_dao.dart

lib/features/products/data/repositories/
  ├── variant_repository.dart
  └── modifier_repository.dart
```

**Pattern à suivre** : Voir `lib/features/products/data/repositories/item_repository.dart`

---

### 6. **Intégration POS Screen** (TODO)

Modifier `product_grid.dart` pour :
1. Détecter si produit a variants (`item.has_variants`)
2. Afficher `VariantSelectionDialog` si variants présents
3. Détecter si produit a modifiers (`item_modifiers` join)
4. Afficher `ModifiersSelectionDialog` si modifiers présents
5. Passer `itemVariantId` et `modifiers` à `AddItemToCart` event

**Flux idéal** :
```
Tap produit
  ↓
A des variants ? → OUI → VariantSelectionDialog
  ↓                       ↓ Sélection
A des modifiers ? → OUI → ModifiersSelectionDialog
  ↓                       ↓ Sélection (forced validé)
CartBloc.add(AddItemToCart(
  itemId: ...,
  itemVariantId: selectedVariant.id,
  modifiers: selectedModifiers.toJson(),
  ...
))
```

**Fichier à modifier** : `lib/features/pos/presentation/widgets/product_grid.dart` (méthode `_addItemToCart`)

---

### 7. **Affichage dans CartPanel** (TODO)

Afficher dans `cart_panel.dart` :
- Nom variant sous le nom produit (ex: "Grande - Rouge")
- Liste modifiers sélectionnés avec prix additionnels

**Exemple layout** :
```
┌────────────────────────────────┐
│ [IMG] Café                     │
│       Grande - Lait entier     │  ← variant + modifiers
│       [−] [x1] [+]    2 000 Ar │
└────────────────────────────────┘
```

**Fichier à modifier** : `lib/features/pos/presentation/widgets/cart_panel.dart` (lignes 324-345)

---

### 8. **Localisations** (TODO)

Ajouter clés FR/MG :
```json
{
  "selectVariant": "Choisir un variant",
  "selectModifiers": "Choisir les options",
  "required": "Obligatoire",
  "noVariantSelected": "Aucun variant sélectionné",
  "modifierRequired": "Option obligatoire non sélectionnée"
}
```

**Fichiers** :
- `lib/l10n/app_fr.arb`
- `lib/l10n/app_mg.arb`

Puis régénérer : `flutter gen-l10n`

---

### 9. **Tests E2E** (TODO)

#### Scénario 1 : Variant simple
1. Créer produit "T-shirt" avec 3 variants (S, M, L)
2. Tap T-shirt depuis POS
3. Dialog variants s'affiche
4. Sélectionner "M"
5. Item ajouté au panier avec `itemVariantId`

#### Scénario 2 : Modifier obligatoire
1. Créer produit "Café" avec modifier "Taille" (isRequired=true)
2. Tap Café
3. Dialog modifiers s'affiche avec badge "OBLIGATOIRE"
4. Bouton "Ajouter" désactivé
5. Sélectionner "Grande" (+500 Ar)
6. Bouton activé
7. Confirmer → Item ajouté avec modifier

#### Scénario 3 : Variant + Modifiers
1. Créer produit "Pizza" avec variants (Small, Medium, Large) + modifiers (Fromage extra, Olives)
2. Sélection en chaîne : variant → modifiers
3. Prix final = prix variant + sum(modifiers.priceAddition)

---

## 📊 État actuel

| Composant | Statut | Progression |
|-----------|--------|-------------|
| Migrations Supabase | ✅ Créées | 100% |
| Tables Drift | ✅ Créées | 100% |
| Entités domaine | ✅ Créées | 100% |
| Dialogs UI | ✅ Créés | 100% |
| DAOs/Repositories | ⏳ À faire | 0% |
| Intégration POS | ⏳ À faire | 0% |
| Affichage panier | ⏳ À faire | 0% |
| Localisations | ⏳ À faire | 0% |
| Tests E2E | ⏳ À faire | 0% |
| **TOTAL** | **40% complet** | **Infrastructure OK** |

---

## 🚧 Blocage actuel

**Connexion Supabase échouée** lors de `supabase db push` (timeout réseau).

### Solutions :
1. **Pousser migration manuellement** :
   ```bash
   # Depuis Supabase Dashboard → SQL Editor
   # Copier/coller le contenu de :
   supabase/migrations/20260325000004_create_variants_and_modifiers.sql
   ```

2. **Ou** attendre connexion réseau stable et relancer :
   ```bash
   supabase db push
   ```

---

## 🔜 Prochaines étapes immédiates

### Option A : Continuer Phase 3.6 (2-3h restantes)
1. Créer DAOs (item_variant_dao, modifier_dao)
2. Créer repositories avec sync Supabase
3. Modifier `product_grid.dart` pour intégrer dialogs
4. Modifier `cart_panel.dart` pour afficher variants/modifiers
5. Ajouter localisations
6. Tester avec données fictives

### Option B : Reporter Phase 3.6
- Marquer comme "partiellement complète"
- Continuer vers Phase 3.7 (Grille Personnalisable) ou Sprint 4
- Revenir sur Phase 3.6 plus tard avec données de test

### Option C : Créer données de test d'abord
- Script SQL pour créer variants et modifiers de test
- Tester l'UI des dialogs avec vraies données
- Puis finaliser intégration

---

## 📁 Fichiers modifiés/créés

| Fichier | Type | Lignes |
|---------|------|--------|
| `supabase/migrations/20260325000004_create_variants_and_modifiers.sql` | Nouveau | +207 |
| `lib/core/data/local/tables/item_variants.drift` | Nouveau | +49 |
| `lib/core/data/local/tables/modifiers.drift` | Nouveau | +19 |
| `lib/core/data/local/tables/modifier_options.drift` | Nouveau | +27 |
| `lib/core/data/local/tables/item_modifiers.drift` | Nouveau | +21 |
| `lib/core/data/local/app_database.dart` | Modifié | +4 |
| `lib/features/products/domain/entities/item_variant.dart` | Nouveau | +138 |
| `lib/features/products/domain/entities/modifier.dart` | Nouveau | +62 |
| `lib/features/products/domain/entities/modifier_option.dart` | Nouveau | +59 |
| `lib/features/products/presentation/widgets/variant_selection_dialog.dart` | Nouveau | +168 |
| `lib/features/products/presentation/widgets/modifiers_selection_dialog.dart` | Nouveau | +226 |
| **TOTAL** | | **+980 lignes** |

---

## 📝 Notes importantes

### Forced Modifiers (gap Loyverse)
Loyverse ne supporte QUE des modifiers optionnels (p.65-66). Notre implémentation avec `is_required=true` est un **différenciant majeur**.

Cas d'usage :
- Restaurant : "Cuisson steak" (obligatoire choisir saignant/à point/bien cuit)
- Café : "Taille" (obligatoire choisir petit/moyen/grand)
- Pizza : "Base sauce" (obligatoire choisir tomate/crème)

### Limites Loyverse reproduites
- Max 3 options de variants (option1, option2, option3)
- Max 200 combinaisons par item (non enforced dans migration, à ajouter si besoin)

### Offline-first
Toutes les tables Drift ont `synced` et `updated_at`. Le sync Supabase <-> Drift se fera dans les repositories (pattern déjà utilisé pour `ItemRepository`).

---

## 🎯 Recommandation

**Je recommande Option A** : Continuer Phase 3.6 pour terminer l'implémentation.

**Temps estimé restant** : 2-3 heures
**Impact business** : Très élevé (forced modifiers = gap majeur vs concurrence)
**Complexité restante** : Moyenne (pattern repositories déjà connu)

Dis-moi si tu veux :
1. **Continuer Phase 3.6** (je finalise DAOs, repositories, intégration)
2. **Reporter** (passe à Phase 3.7 ou Sprint 4)
3. **Créer données test d'abord** (script SQL puis tests UI)

Qu'est-ce que tu préfères ? 🚀
