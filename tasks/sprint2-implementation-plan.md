# Sprint 2 - Plan d'Implémentation Détaillé
**Date de création** : 2026-03-25
**Objectif** : Écran de caisse fonctionnel + Gestion complète des produits

---

## ✅ État Actuel (Déjà fait)

### Backend Complet
- ✅ Tables Drift : `categories` et `items` avec tous les champs nécessaires
- ✅ DAOs : `CategoryDao` et `ItemDao` avec toutes les méthodes CRUD
- ✅ Repositories : `CategoryRepository` et `ItemRepository`
- ✅ BLoCs : `CategoryBloc` et `ItemBloc` avec Events et States

### Ce qui manque
- ⏳ **Écrans UI** (0/8 écrans créés)
- ⏳ **Intégration dans le router**
- ⏳ **Intégration des BLoCs dans main.dart**
- ⏳ **Upload photo vers Supabase Storage**

---

## 📋 Plan d'Implémentation par Phases

### **Phase 1 : Fondations Produits** (Priorité Haute)
*Durée estimée : 2-3h*

#### 1.1 - Créer le dossier screens
```bash
mkdir -p lib/features/products/presentation/screens
```

#### 1.2 - Écran Liste des Produits (Lecture seule d'abord)
**Fichier** : `lib/features/products/presentation/screens/products_list_screen.dart`

**Spécifications** :
- Barre de recherche
- Filtre catégorie (dropdown)
- Filtre stock (Tous / Bas / Rupture)
- Liste des items avec :
  - Photo/couleur 44px (placeholder si pas de photo)
  - Nom (Sora 16px medium)
  - SKU (Sora 12px secondary)
  - Prix (Sora 14px, formaté en Ariary)
  - Stock coloré (vert si > seuil, orange si <= seuil, rouge si 0)
  - Badge "Hors vente" si `available_for_sale = 0`
- FAB "+" en bas à droite
- Tap sur item → navigate vers édition
- Pull-to-refresh
- Pagination (charger 50 items à la fois)

**BLoC Events nécessaires** :
- `ItemsLoadRequested(storeId)`
- `ItemsSearched(query)`
- `ItemsFilteredByCategory(categoryId)`
- `ItemsFilteredByStock(filter)` // 'all', 'low', 'out'

**État** : ⏳ À faire

---

#### 1.3 - Écran Création/Édition Produit (Formulaire complet)
**Fichier** : `lib/features/products/presentation/screens/product_form_screen.dart`

**Spécifications** :
- AppBar avec titre "Nouveau produit" ou "Modifier [nom]"
- Bouton Sauvegarder (sticky en haut à droite)
- Bouton Supprimer (si édition, avec confirmation)

**Sections du formulaire** :

1. **Photo** (en haut, centré)
   - Zone de dépôt/sélection photo 120x120px
   - Bouton "Sélectionner une photo"
   - Ou sélecteur de couleur + icône (fallback)

2. **Informations de base**
   - Nom* (TextField, required)
   - Catégorie (Dropdown des catégories)
   - Description (TextField multiline, optionnel, 3 lignes)
   - SKU (TextField, auto-généré par défaut, éditable)
   - Code-barre (TextField + bouton scan)

3. **Prix**
   - Prix de vente* (TextField numérique, Ariary)
   - Coût d'achat (TextField numérique OU %)
   - Toggle "Coût en %" → change le champ
   - **Marge calculée en live** (% et Ar) en vert si > 0, rouge si < 0

4. **Vente**
   - Toggle "Disponible à la vente" (par défaut ON)
   - Toggle "Vendu au poids"
   - Si poids : TextField unité de poids (kg, g, l, etc.)

5. **Stock**
   - Toggle "Suivre le stock" (par défaut ON)
   - Si ON :
     - Stock actuel (TextField numérique)
     - Seuil d'alerte stock bas (TextField numérique, défaut 10)

6. **Taxes**
   - Liste checkboxes des taxes disponibles
   - (Pour l'instant, juste afficher "Aucune taxe configurée" si vide)

**Validation** :
- Nom requis
- Prix requis et > 0
- Si SKU fourni, vérifier qu'il n'existe pas déjà (appel `itemRepository.skuExists()`)

**BLoC Events nécessaires** :
- `ItemCreateRequested(ItemsCompanion)`
- `ItemUpdateRequested(itemId, ItemsCompanion)`
- `ItemDeleteRequested(itemId)`

**État** : ⏳ À faire

---

#### 1.4 - Upload Photo vers Supabase Storage
**Fichier** : `lib/core/services/storage_service.dart`

**Fonctionnalités** :
- Upload image vers bucket Supabase `items-photos`
- Génération nom de fichier unique : `{storeId}/{itemId}_{timestamp}.jpg`
- Compression automatique (max 800x800px, quality 85%)
- Retour de l'URL publique
- Suppression de l'ancienne photo si remplacement

**Package** : `image_picker` (déjà dans pubspec.yaml)

**État** : ⏳ À faire

---

#### 1.5 - Intégration Router
**Fichier** : `lib/core/router/app_router.dart`

**Routes à ajouter** :
```dart
// Liste des produits
GoRoute(
  path: '/products',
  builder: (context, state) => const ProductsListScreen(),
),

// Créer un produit
GoRoute(
  path: '/products/new',
  builder: (context, state) => const ProductFormScreen(),
),

// Éditer un produit
GoRoute(
  path: '/products/:id/edit',
  builder: (context, state) {
    final itemId = state.pathParameters['id']!;
    return ProductFormScreen(itemId: itemId);
  },
),
```

**État** : ⏳ À faire

---

#### 1.6 - Intégration BLoCs dans main.dart
**Fichier** : `lib/main.dart`

**Ajouter les repositories** :
```dart
RepositoryProvider<CategoryRepository>(
  create: (context) => CategoryRepository(
    supabase: Supabase.instance.client,
    categoryDao: database.categoryDao,
  ),
),
RepositoryProvider<ItemRepository>(
  create: (context) => ItemRepository(
    supabase: Supabase.instance.client,
    itemDao: database.itemDao,
  ),
),
```

**Ajouter les BLoCs** :
```dart
BlocProvider<CategoryBloc>(
  create: (context) => CategoryBloc(
    categoryRepository: context.read<CategoryRepository>(),
  ),
),
BlocProvider<ItemBloc>(
  create: (context) => ItemBloc(
    itemRepository: context.read<ItemRepository>(),
  ),
),
```

**État** : ⏳ À faire

---

### **Phase 2 : Caisse Basique** (Priorité Haute)
*Durée estimée : 3-4h*

#### 2.1 - Layout Écran POS
**Fichier** : `lib/features/pos/presentation/screens/pos_screen.dart`

**Layout tablette (>600px)** :
- Row avec 2 colonnes :
  - Gauche 58% : Grille produits
  - Droite 42% : Panier

**Layout smartphone** :
- Plein écran : Grille produits
- Bottom sheet : Panier (250px fixe)

**Grille produits** :
- AppBar : Titre magasin + icône scan + menu
- Barre de recherche
- Onglets catégories horizontaux (scrollable)
- GridView produits (3 colonnes tablette, 2 colonnes phone)
- Chaque item : photo, nom, prix

**Panier** :
- Liste des items ajoutés
- Totaux (sous-total, taxes, total)
- Bouton PAYER (vert, 56px)

**État** : ⏳ À faire

---

#### 2.2 - Ajout au Panier
**Fichier** : Créer `lib/features/pos/presentation/bloc/cart_bloc.dart`

**Events** :
- `CartItemAdded(itemId, quantity)`
- `CartItemRemoved(itemId)`
- `CartItemQuantityChanged(itemId, newQuantity)`
- `CartCleared()`

**State** :
- `CartState` avec `List<CartItem>`, `subtotal`, `tax`, `total`

**État** : ⏳ À faire

---

#### 2.3 - Écran Paiement (Cash uniquement)
**Fichier** : `lib/features/pos/presentation/screens/payment_screen.dart`

**Contenu** :
- Total à payer (gros, vert)
- Bouton "Cash" (actif)
- Boutons autres paiements (désactivés pour l'instant)
- Si Cash : montants suggérés + saisie custom
- Calcul monnaie rendue en live
- Bouton "Valider le paiement"

**État** : ⏳ À faire

---

### **Phase 3 : Features Avancées** (Priorité Moyenne)
*À planifier après Phase 1 et 2*

- Variants
- Modifiers (obligatoires et optionnels)
- Scanner code-barre
- Paiements MVola/Orange Money

---

### **Phase 4 : Inventaire** (Priorité Basse)
*À planifier après Phase 3*

- Vue stock avec filtres
- Ajustements stock
- Export/Impression

---

## 🎯 Ordre d'Exécution Recommandé

1. **Phase 1.1 → 1.2** : Créer dossier + écran liste produits
2. **Phase 1.6** : Intégrer BLoCs dans main.dart (pour tester liste)
3. **Phase 1.5** : Ajouter routes
4. **Tester** : Vérifier que la liste s'affiche
5. **Phase 1.3** : Créer formulaire produit
6. **Phase 1.4** : Upload photo
7. **Tester** : Créer/éditer des produits
8. **Phase 2.1 → 2.3** : Écran POS + panier + paiement
9. **Tester** : Vendre un produit end-to-end

---

## 📝 Notes Importantes

### Conventions à Respecter
- **Montants** : toujours `int` en Ariary (jamais `double`)
- **Format** : `NumberFormat('#,###', 'fr')` → "1 500 Ar"
- **Strings** : ZÉRO hardcodé, tout dans `l10n/app_fr.arb` et `app_mg.arb`
- **Photos** : Placeholder si `image_url` null
- **Offline-first** : Écrire dans Drift EN PREMIER, sync Supabase après

### Couleurs (design.md)
- Texte principal : `AppColors.lightTextPrimary` / `darkTextPrimary`
- Texte secondaire : `AppColors.lightTextSecondary` / `darkTextSecondary`
- Accent (totaux, CTA) : `AppColors.lightAccent` / `darkAccent`
- Success (stock OK) : `AppColors.successLight` / `successDark`
- Warning (stock bas) : `AppColors.warningLight` / `warningDark`
- Danger (rupture) : `AppColors.dangerLight` / `dangerDark`

### Police (design.md)
- Sora (Google Fonts)
- Titres : 600 (semibold)
- Corps : 400 (regular)
- Labels : 500 (medium)

---

## ✅ Checklist avant commit

- [ ] Fonctionne online
- [ ] Fonctionne offline
- [ ] Montants formatés en Ariary
- [ ] Zéro string hardcodée
- [ ] Photos avec placeholder si null
- [ ] Logs d'activité si action importante
- [ ] `flutter analyze` sans erreur
- [ ] Commit avec message descriptif

---

## 📚 Fichiers de Référence

- **Spéc écrans** : `docs/screens.md`
- **Design system** : `docs/design.md`
- **Formules calculs** : `docs/formulas.md`
- **Features Loyverse** : `docs/loyverse-features.md`
- **Différenciants** : `docs/differences.md`
