# Checklist de Tests End-to-End — Sprint 3 (Phases 3.11 à 3.17)

**Projet** : POS Madagascar
**Créé le** : 2026-03-26
**Objectif** : Valider les 7 phases d'inventaire avancé
**Durée estimée** : 50-60 minutes

---

## Préparation Globale (10 min)

### Environnement de test

- [ ] Créer un store de test "Boutique Test"
- [ ] Se connecter en rôle ADMIN
- [ ] Vérifier que WiFi est activé (tests online d'abord)
- [ ] Vider le cache de l'app si nécessaire

### Données de test

#### Produits
- [ ] Créer **Produit A** : Nom "Riz Basmati", Prix 15000 Ar, Coût 10000 Ar, Stock initial 100, SKU "RICE001"
- [ ] Créer **Produit B** : Nom "Huile Tournesol", Prix 12000 Ar, Coût 8000 Ar, Stock initial 50, SKU "OIL001"
- [ ] Créer **Produit C** : Nom "Sucre Blanc", Prix 5000 Ar, Coût 3000 Ar, Stock initial 25, SKU "SUGAR001"
- [ ] Créer **Produit D** : Nom "Farine T55", Prix 8000 Ar, Coût 5000 Ar, Stock initial 10, SKU "FLOUR001"
- [ ] Créer **Produit E** : Nom "Sel Iodé", Prix 2000 Ar, Coût 1000 Ar, Stock initial 5, SKU "SALT001"

#### Clients
- [ ] Créer **Client 1** : Nom "Jean Rakoto", Téléphone "034 12 345 67"
- [ ] Créer **Client 2** : Nom "Marie Rasoa", Téléphone "033 98 765 43"

#### Employés
- [ ] Créer **Employé CASHIER** : Nom "Caissier Test", PIN "1234", Rôle CASHIER
- [ ] Vérifier que cet employé a bien les permissions de base

#### Catégorie test (pour comptage partiel)
- [ ] Créer catégorie "Épicerie" contenant Produit A, B, C
- [ ] Créer catégorie "Condiments" contenant Produit D, E

---

## Phase 3.11 — Vente à Crédit

### Scénario 1 : Créer une vente à crédit online (5 min)

**Préconditions** : WiFi ON, connecté en ADMIN, Stock Produit A = 100

**Étapes** :
1. [ ] Naviguer vers `/pos` (Écran Caisse)
2. [ ] Ajouter **Produit A** au panier (quantité : 10)
3. [ ] Vérifier le total affiché : **150 000 Ar** (format avec espaces, pas de décimales)
4. [ ] Cliquer sur bouton **"À Crédit"** ou **"Crédit"**
5. [ ] Sélectionner **Client 1** (Jean Rakoto)
6. [ ] Date d'échéance : **+7 jours** (calculé automatiquement ou saisir manuellement)
7. [ ] Note : "Test crédit online"
8. [ ] Confirmer la transaction

**Vérifications** :
- [ ] Sale créée avec `payment_status = 'unpaid'` (vérifier dans logs ou DB)
- [ ] Credit créé avec montant **150 000 Ar**
- [ ] Stock Produit A réduit : 100 → **90**
- [ ] Naviguer vers `/customers/credits` (Liste des Crédits)
- [ ] Vérifier que Client 1 apparaît avec crédit de **150 000 Ar**
- [ ] Statut du crédit : **"En attente"** ou **"Pending"**
- [ ] Total dû affiché correctement : **150 000 Ar**

### Scénario 2 : Créer une vente à crédit offline (5 min)

**Préconditions** : **WiFi OFF**, Stock Produit B = 50

**Étapes** :
1. [ ] **Couper le WiFi** (mode Avion ou désactiver WiFi)
2. [ ] Naviguer vers `/pos`
3. [ ] Ajouter **Produit B** au panier (quantité : 5)
4. [ ] Vérifier le total : **60 000 Ar**
5. [ ] Cliquer **"À Crédit"**
6. [ ] Sélectionner **Client 2** (Marie Rasoa)
7. [ ] Date d'échéance : **+14 jours**
8. [ ] Note : "Test crédit offline"
9. [ ] Confirmer

**Vérifications** :
- [ ] Sale créée avec `synced = false` (vérifier badge "Non synchronisé" si visible)
- [ ] Credit créé avec `synced = false`
- [ ] Stock Produit B réduit **localement** : 50 → **45**
- [ ] Montant affiché : **60 000 Ar** (pas "60000.0" ni "60,000.00")
- [ ] **Réactiver WiFi**
- [ ] Attendre 10-30 secondes
- [ ] Vérifier que le crédit se synchronise automatiquement
- [ ] Badge "Non synchronisé" disparaît

### Scénario 3 : Payer un crédit partiellement (3 min)

**Préconditions** : Crédit de 150 000 Ar existe pour Client 1

**Étapes** :
1. [ ] Naviguer vers `/customers/credits`
2. [ ] Tap sur le crédit de **Client 1** (150 000 Ar)
3. [ ] Cliquer bouton **"Payer"** ou **"Enregistrer paiement"**
4. [ ] Saisir montant : **60 000 Ar**
5. [ ] Sélectionner mode de paiement : **Cash**
6. [ ] Note (optionnelle) : "Premier versement"
7. [ ] Confirmer

**Vérifications** :
- [ ] CreditPayment créé avec montant **60 000 Ar**
- [ ] Solde restant affiché : **90 000 Ar** (150 000 - 60 000)
- [ ] Statut crédit passe à **"Partiel"** ou **"Partial"** (PAS "Payé")
- [ ] Historique des paiements visible avec 1 ligne (60 000 Ar)
- [ ] Date de paiement enregistrée

### Scénario 4 : Payer un crédit totalement (2 min)

**Préconditions** : Crédit de Client 1 a un solde restant de 90 000 Ar

**Étapes** :
1. [ ] Naviguer vers `/customers/credits`
2. [ ] Tap sur crédit de **Client 1**
3. [ ] Cliquer **"Payer"**
4. [ ] Saisir montant : **90 000 Ar** (ou bouton "Payer le solde complet")
5. [ ] Mode de paiement : **MVola** (ou Cash)
6. [ ] Confirmer

**Vérifications** :
- [ ] Solde restant : **0 Ar**
- [ ] Statut crédit : **"Payé"** ou **"Paid"**
- [ ] Badge vert ou icône validée visible
- [ ] Historique montre 2 paiements (60 000 Ar + 90 000 Ar)
- [ ] Crédit n'apparaît plus dans la liste "En attente" (filtre actif)

---

## Phase 3.12 — Remboursements

### Scénario 5 : Remboursement total online (5 min)

**Préconditions** :
- WiFi ON
- Créer une vente complète : Produit A x 10 = 150 000 Ar, paiement Cash
- Stock Produit A après vente : **80** (initial 90 - 10 vendus)

**Étapes** :
1. [ ] Naviguer vers `/pos/receipts` (Liste des reçus)
2. [ ] Localiser la vente de 150 000 Ar (Produit A x10)
3. [ ] Tap sur le reçu pour ouvrir les détails
4. [ ] Cliquer bouton **"Rembourser"**
5. [ ] Sélectionner **TOUS les items** (10 unités de Produit A)
6. [ ] Raison : "Défaut produit"
7. [ ] Confirmer le remboursement

**Vérifications** :
- [ ] Refund créé avec montant total **150 000 Ar**
- [ ] Stock Produit A restauré : 80 → **90**
- [ ] Sale status passe à **"Remboursé"** ou **"Refunded"**
- [ ] Badge rouge "Remboursé" visible sur le reçu dans la liste
- [ ] `inventory_history` enregistre un mouvement +10 avec raison "refund"
- [ ] Montant remboursé affiché : **150 000 Ar** (pas "150000.0")

### Scénario 6 : Remboursement partiel offline (5 min)

**Préconditions** :
- Créer une vente : Produit B x 5 = 60 000 Ar, paiement Cash
- Stock Produit B après vente : **40** (initial 45 - 5 vendus)
- **WiFi OFF**

**Étapes** :
1. [ ] **Couper WiFi**
2. [ ] Naviguer vers `/pos/receipts`
3. [ ] Localiser la vente de 60 000 Ar (Produit B x5)
4. [ ] Tap sur le reçu
5. [ ] Cliquer **"Rembourser"**
6. [ ] Sélectionner **2 unités sur 5** (quantité partielle)
7. [ ] Raison : "Erreur caisse"
8. [ ] Confirmer

**Vérifications** :
- [ ] Refund créé avec `synced = false`
- [ ] Montant calculé correctement : **(60 000 / 5) × 2 = 24 000 Ar**
- [ ] Stock Produit B restauré **localement** : 40 → **42**
- [ ] Sale status : **"Partiellement remboursé"** ou **"Partially refunded"**
- [ ] Badge orange ou bleu sur le reçu
- [ ] `inventory_history` enregistre +2 (raison "refund")
- [ ] **Réactiver WiFi**
- [ ] Vérifier que refund se synchronise (badge "Non synchronisé" disparaît)

### Scénario 7 : Empêcher double remboursement (2 min)

**Préconditions** : Vente de 150 000 Ar déjà remboursée totalement (Scénario 5)

**Étapes** :
1. [ ] Naviguer vers `/pos/receipts`
2. [ ] Localiser le reçu déjà remboursé (badge "Remboursé")
3. [ ] Tap sur ce reçu
4. [ ] Tenter de cliquer **"Rembourser"**

**Vérifications** :
- [ ] Bouton "Rembourser" **désactivé** (grisé) OU absent
- [ ] Si bouton présent, message d'erreur affiché : "Ce reçu a déjà été remboursé"
- [ ] Impossible de créer un second Refund
- [ ] Stock ne change pas

---

## Phase 3.13 — Vue d'ensemble Stock

### Scénario 8 : Visualiser stock global (3 min)

**Préconditions** : 5 produits créés avec stocks variés (A:90, B:42, C:25, D:10, E:5)

**Étapes** :
1. [ ] Naviguer vers `/inventory` (Vue d'ensemble stock)
2. [ ] Observer les métriques en haut de l'écran

**Vérifications** :
- [ ] Métrique **"Ruptures de stock"** affichée (compteur rouge ou 0)
- [ ] Métrique **"Alertes stock bas"** affichée (compteur orange ou 0)
- [ ] Métrique **"Valeur totale stock"** affichée si coûts renseignés
  - Calcul attendu : (90×10000 + 42×8000 + 25×3000 + 10×5000 + 5×1000) = **1 387 000 Ar**
- [ ] Liste des produits triée par **urgence** : ruptures → alertes → OK
- [ ] **Produits E et D** en haut (stocks bas : 5 et 10)
- [ ] Indicateurs colorés : vert (OK), orange (alerte), rouge (rupture)

### Scénario 9 : Filtrer stock (2 min)

**Préconditions** : Même état que Scénario 8

**Étapes** :
1. [ ] Sur `/inventory`, utiliser le filtre **"Stock bas"**
2. [ ] Vérifier que seuls Produit D et E apparaissent
3. [ ] Utiliser le filtre **"Rupture"**
4. [ ] Si aucune rupture, créer une vente pour vider Produit E (vendre 5 unités)
5. [ ] Revenir à `/inventory` et appliquer filtre "Rupture"

**Vérifications** :
- [ ] Filtre "Stock bas" montre uniquement produits avec stock ≤ seuil d'alerte
- [ ] Filtre "Rupture" montre uniquement produits avec stock = 0
- [ ] Badge rouge visible sur items en rupture

### Scénario 10 : Quick edit stock (2 min)

**Préconditions** : Produit C stock = 25

**Étapes** :
1. [ ] Sur `/inventory`, tap sur **Produit C**
2. [ ] Dialog ou écran de quick edit s'ouvre
3. [ ] Modifier stock : saisir **30** (ajout de 5 unités)
4. [ ] Confirmer

**Vérifications** :
- [ ] Stock Produit C mis à jour : 25 → **30**
- [ ] Changement persisté (rafraîchir `/inventory` pour vérifier)
- [ ] `inventory_history` enregistre le mouvement +5 (raison "adjustment")

---

## Phase 3.14 — Ajustements de Stock

### Scénario 11 : Ajustement positif (Réception) online (4 min)

**Préconditions** : WiFi ON, Produit C stock = 30

**Étapes** :
1. [ ] Naviguer vers `/inventory/adjustments/new` (Nouvel ajustement)
2. [ ] Sélectionner raison : **"Réception"** ou **"receive"**
3. [ ] Ajouter **Produit C** à la liste
4. [ ] Saisir variation : **+50 unités**
5. [ ] Note : "Livraison fournisseur XYZ"
6. [ ] Confirmer

**Vérifications** :
- [ ] `StockAdjustment` créé avec raison "receive"
- [ ] `StockAdjustmentItem` créé avec :
  - `quantity_before = 30`
  - `quantity_change = +50`
  - `quantity_after = 80`
- [ ] Stock Produit C mis à jour : 30 → **80**
- [ ] `inventory_history` enregistre +50 avec raison "adjustment"
- [ ] Ajustement visible dans `/inventory/adjustments` (liste)

### Scénario 12 : Ajustement négatif (Perte) offline (4 min)

**Préconditions** : WiFi OFF, Produit D stock = 10

**Étapes** :
1. [ ] **Couper WiFi**
2. [ ] Naviguer vers `/inventory/adjustments/new`
3. [ ] Raison : **"Perte"** ou **"loss"**
4. [ ] Ajouter **Produit D**
5. [ ] Saisir variation : **-3 unités** (ou saisir "3" avec signe négatif)
6. [ ] Note : "Casse magasin"
7. [ ] Confirmer

**Vérifications** :
- [ ] `StockAdjustment` créé avec `synced = false`
- [ ] `StockAdjustmentItem` :
  - `quantity_before = 10`
  - `quantity_change = -3`
  - `quantity_after = 7`
- [ ] Stock Produit D mis à jour **localement** : 10 → **7**
- [ ] Badge "Non synchronisé" visible dans la liste
- [ ] **Réactiver WiFi**
- [ ] Vérifier sync automatique (badge disparaît)

### Scénario 13 : Historique des mouvements (2 min)

**Préconditions** : Plusieurs mouvements effectués sur Produit C (vente, refund, ajustement)

**Étapes** :
1. [ ] Naviguer vers `/products` ou `/inventory`
2. [ ] Tap sur **Produit C**
3. [ ] Onglet ou section **"Historique"**

**Vérifications** :
- [ ] Liste chronologique des mouvements affichée
- [ ] Colonnes visibles : Date, Raison (sale/refund/adjustment), Quantité (+/-), Solde après
- [ ] Mouvements triés par date décroissante (plus récents en premier)
- [ ] Icônes ou badges colorés par type de mouvement

---

## Phase 3.15 — Export Inventaire

### Scénario 14 : Export Excel (3 min)

**Préconditions** : 5 produits créés avec stocks et coûts

**Étapes** :
1. [ ] Naviguer vers `/inventory`
2. [ ] Ouvrir le menu (icône ⋮ ou bouton "Options")
3. [ ] Cliquer **"Exporter"** → **"Excel"**
4. [ ] Fichier `.xlsx` téléchargé ou partagé
5. [ ] Ouvrir le fichier avec Excel/Google Sheets

**Vérifications** :
- [ ] Fichier contient les colonnes : **Nom, SKU, Catégorie, Stock, Prix, Coût, Valeur**
- [ ] Montants affichés en **Ariary** (int, pas double : "15 000" pas "15000.0")
- [ ] Résumé en haut du fichier :
  - **Total items** : 5
  - **Valeur totale** : 1 387 000 Ar (ou valeur calculée)
- [ ] Données correctes pour chaque produit
- [ ] Pas de caractères corrompus (encodage UTF-8 correct pour noms malgaches)

### Scénario 15 : Export PDF (3 min)

**Préconditions** : Même état que Scénario 14

**Étapes** :
1. [ ] Sur `/inventory`, menu → **"Exporter"** → **"PDF"**
2. [ ] Fichier `.pdf` téléchargé ou partagé
3. [ ] Ouvrir le fichier PDF

**Vérifications** :
- [ ] PDF formaté proprement avec :
  - Logo du magasin (si configuré)
  - Nom du magasin
  - Date d'export
- [ ] Tableau lisible avec colonnes : Nom, SKU, Stock, Prix, Valeur
- [ ] Métriques en haut : Nombre items, Valeur totale
- [ ] Pas de texte coupé ou tronqué
- [ ] Police professionnelle (Sora ou équivalent)

---

## Phase 3.16 — Import CSV/Excel

### Scénario 16 : Import CSV valide (5 min)

**Préconditions** : Créer un fichier `import-test.csv` :
```csv
name,sku,category,cost,price,stock,track_stock
Café Moulu,COFFEE001,Boissons,8000,12000,40,true
Thé Vert,TEA001,Boissons,3000,5000,60,true
Lait UHT,MILK001,Produits Laitiers,4000,6000,80,true
```

**Étapes** :
1. [ ] Naviguer vers `/products/import` (ou `/inventory/import`)
2. [ ] Cliquer **"Choisir fichier"** ou zone de dépôt
3. [ ] Sélectionner `import-test.csv`
4. [ ] Vérifier l'aperçu : **3 lignes** affichées
5. [ ] Vérifier que les colonnes sont bien détectées
6. [ ] Cliquer **"Confirmer import"**

**Vérifications** :
- [ ] Message de succès affiché : **"3 produits importés avec succès"**
- [ ] 3 nouveaux items créés dans Drift (local)
- [ ] Stocks corrects : Café (40), Thé (60), Lait (80)
- [ ] Catégories **créées automatiquement** si inexistantes :
  - "Boissons"
  - "Produits Laitiers"
- [ ] Prix et coûts corrects (format Ariary int)
- [ ] SKUs uniques et corrects
- [ ] `track_stock = true` pour tous

### Scénario 17 : Import avec erreurs (4 min)

**Préconditions** : Créer un fichier `import-invalid.csv` avec erreurs :
```csv
name,sku,category,cost,price,stock,track_stock
,INVALID001,Épicerie,abc,xyz,50,true
Produit Sans Prix,PROD001,Épicerie,5000,,30,true
```

**Étapes** :
1. [ ] Sur `/products/import`, sélectionner `import-invalid.csv`
2. [ ] Aperçu chargé
3. [ ] Cliquer **"Confirmer import"**

**Vérifications** :
- [ ] Import **échoue** (aucun produit créé)
- [ ] Message d'erreur clair affiché :
  - "Ligne 2 : Nom manquant (obligatoire)"
  - "Ligne 2 : Coût invalide (abc)"
  - "Ligne 2 : Prix invalide (xyz)"
  - "Ligne 3 : Prix manquant (obligatoire)"
- [ ] Possibilité de **corriger le fichier** et ré-essayer
- [ ] Aucun produit partiellement créé (atomicité)

### Scénario 18 : Import avec SKU dupliqué (2 min)

**Préconditions** : Produit A existe déjà avec SKU "RICE001"

**Étapes** :
1. [ ] Créer fichier `import-duplicate.csv` :
```csv
name,sku,category,cost,price,stock,track_stock
Riz Duplicate,RICE001,Épicerie,9000,14000,20,true
```
2. [ ] Importer ce fichier

**Vérifications** :
- [ ] Import échoue OU ligne ignorée avec warning
- [ ] Message : "Ligne 2 : SKU 'RICE001' existe déjà"
- [ ] Produit existant **non modifié** (stock reste à 90, prix 15 000 Ar)

---

## Phase 3.17 — Comptage Physique (Inventaire)

### Scénario 19 : Comptage complet (Full count) online (8 min)

**Préconditions** :
- WiFi ON
- 5 produits avec stocks connus (A:90, B:42, C:80, D:7, E:0)

**Étapes** :
1. [ ] Naviguer vers `/inventory/counts/new` (Nouveau comptage)
2. [ ] Type : **"Inventaire complet"** ou **"full"**
3. [ ] Note : "Comptage mensuel mars 2026"
4. [ ] Cliquer **"Démarrer"** ou **"Suivant"**
5. [ ] **Étape comptage** : saisir quantités comptées
   - Produit A : saisir **88** (attendu 90, écart **-2**)
   - Produit B : saisir **42** (attendu 42, écart **0**)
   - Produit C : saisir **82** (attendu 80, écart **+2**)
   - Produit D : saisir **7** (attendu 7, écart **0**)
   - Produit E : saisir **4** (attendu 0, écart **+4**)
6. [ ] Cliquer **"Finaliser"** ou **"Terminer"**

**Vérifications** :
- [ ] `InventoryCount` créé avec :
  - `type = 'full'`
  - `status = 'completed'`
  - `notes = "Comptage mensuel mars 2026"`
- [ ] 5 `InventoryCountItems` créés avec différences calculées
- [ ] Écran de résumé affiche :
  - Produit A : attendu 90, compté **88**, différence **-2** (texte rouge ou icône ↓)
  - Produit B : attendu 42, compté **42**, différence **0** (neutre)
  - Produit C : attendu 80, compté **82**, différence **+2** (texte vert ou icône ↑)
  - Produit D : attendu 7, compté **7**, différence **0**
  - Produit E : attendu 0, compté **4**, différence **+4** (vert)
- [ ] Stocks mis à jour automatiquement :
  - Produit A : 90 → **88**
  - Produit C : 80 → **82**
  - Produit E : 0 → **4**
- [ ] `inventory_history` enregistre **3 mouvements** (raison "inventory_count") :
  - Produit A : -2
  - Produit C : +2
  - Produit E : +4
- [ ] Comptage visible dans `/inventory/counts` avec statut "Terminé"

### Scénario 20 : Comptage partiel (par catégorie) offline (6 min)

**Préconditions** :
- WiFi OFF
- Catégorie "Condiments" contient Produit D (stock 7) et Produit E (stock 4)

**Étapes** :
1. [ ] **Couper WiFi**
2. [ ] Naviguer vers `/inventory/counts/new`
3. [ ] Type : **"Inventaire partiel"** ou **"partial"**
4. [ ] Sélectionner catégorie : **"Condiments"**
5. [ ] Note : "Comptage offline catégorie Condiments"
6. [ ] Démarrer
7. [ ] Compter :
   - Produit D : saisir **5** (attendu 7, écart **-2**)
   - Produit E : saisir **4** (attendu 4, écart **0**)
8. [ ] Finaliser

**Vérifications** :
- [ ] `InventoryCount` créé avec `synced = false`
- [ ] `type = 'partial'`
- [ ] Seuls **2 items** comptés (Produit D et E)
- [ ] Stocks mis à jour **localement** :
  - Produit D : 7 → **5**
  - Produit E : reste **4** (pas de changement)
- [ ] **Produits A, B, C non affectés** (pas dans catégorie Condiments)
- [ ] Badge "Non synchronisé" visible
- [ ] **Réactiver WiFi**
- [ ] Vérifier sync du comptage (peut prendre 30s)

### Scénario 21 : Scan barcode pendant comptage (3 min)

**Préconditions** : Comptage "full" démarré (statut "in_progress")

**Étapes** :
1. [ ] Sur l'écran de comptage en cours
2. [ ] Cliquer icône **"Scanner"** ou bouton scan barcode
3. [ ] Scanner le code-barres de **Produit A** (ou saisir manuellement "RICE001")
4. [ ] Ligne Produit A automatiquement **sélectionnée** ou **focus**
5. [ ] Saisir quantité comptée : **88**
6. [ ] Appuyer Entrée ou passer au suivant

**Vérifications** :
- [ ] Barcode détecté et ligne correspondante trouvée
- [ ] Focus automatique sur le champ quantité
- [ ] Pas d'erreur si barcode invalide (message "Produit non trouvé")
- [ ] Scan rapide et fluide (latence < 1s)

### Scénario 22 : Sauvegarder et reprendre comptage (4 min)

**Préconditions** : Comptage "full" démarré

**Étapes** :
1. [ ] Démarrer un nouveau comptage "full"
2. [ ] Compter seulement **2 produits sur 5** (Produit A et B)
3. [ ] Quitter l'écran (bouton Retour ou naviguer ailleurs)
4. [ ] Revenir à `/inventory/counts`
5. [ ] Localiser le comptage avec statut **"En cours"** ou **"in_progress"**
6. [ ] Tap sur ce comptage
7. [ ] Vérifier que les quantités déjà saisies sont **conservées**
8. [ ] Compléter les 3 produits restants
9. [ ] Finaliser

**Vérifications** :
- [ ] Comptage sauvegardé automatiquement (auto-save toutes les 30s mentionné dans docs)
- [ ] Quantités précédentes **persistées** (Produit A et B affichent les valeurs saisies)
- [ ] Pas de perte de données
- [ ] Statut passe de "in_progress" à "completed" après finalisation

### Scénario 23 : Terminer et ajuster stock (3 min)

**Préconditions** : Comptage terminé avec écarts (Scénario 19)

**Étapes** :
1. [ ] Sur l'écran de résumé du comptage terminé
2. [ ] Observer le bouton **"Appliquer les ajustements"** ou **"Ajuster stock"**
3. [ ] Cliquer ce bouton

**Vérifications** :
- [ ] `StockAdjustment` créé automatiquement avec raison "inventory_count"
- [ ] `StockAdjustmentItems` créés pour chaque écart non nul :
  - Produit A : -2
  - Produit C : +2
  - Produit E : +4
- [ ] Stocks déjà mis à jour (cela a été fait à la finalisation)
- [ ] Ajustement visible dans `/inventory/adjustments`
- [ ] Lien entre comptage et ajustement (navigation bidirectionnelle possible)

---

## Tests Cross-Feature (Atomicité & Cohérence) (10 min)

### Scénario 24 : Vente → Stock → Historique (3 min)

**Préconditions** : Produit A stock = 88

**Étapes** :
1. [ ] Créer une vente : Produit A x 5 = 75 000 Ar, Cash
2. [ ] Vérifier stock Produit A : 88 → **83**
3. [ ] Naviguer vers historique Produit A

**Vérifications** :
- [ ] `inventory_history` contient une ligne :
  - Raison : **"sale"**
  - Quantité : **-5**
  - Solde après : **83**
- [ ] Reference_id pointe vers la Sale créée
- [ ] Timestamp correct

### Scénario 25 : Refund → Stock restauré → Historique (3 min)

**Préconditions** : Vente de Scénario 24 existe (Produit A x5)

**Étapes** :
1. [ ] Rembourser totalement cette vente (5 unités)
2. [ ] Vérifier stock Produit A : 83 → **88**
3. [ ] Consulter historique Produit A

**Vérifications** :
- [ ] Nouvelle ligne dans `inventory_history` :
  - Raison : **"refund"**
  - Quantité : **+5**
  - Solde après : **88**
- [ ] Reference_id pointe vers le Refund
- [ ] Chronologie correcte (refund après sale)

### Scénario 26 : Rollback si erreur (4 min)

**Préconditions** : Produit A stock = 88, WiFi OFF

**Étapes** :
1. [ ] Couper WiFi
2. [ ] Créer un ajustement : Produit A +100 unités
3. [ ] **Simuler une erreur** (par ex: forcer fermeture app juste après confirmation)
4. [ ] Rouvrir l'app
5. [ ] Vérifier stock Produit A

**Vérifications** :
- [ ] Si ajustement pas sauvegardé (transaction incomplète), stock reste **88** (rollback)
- [ ] OU si ajustement sauvegardé, stock = **188** et `synced = false`
- [ ] Aucun état incohérent (stock modifié mais pas d'historique)
- [ ] Atomicité garantie (tout ou rien)

---

## Tests Permissions & Rôles (5 min)

### Scénario 27 : CASHIER ne peut pas ajuster stock (2 min)

**Préconditions** : Se connecter en tant qu'employé CASHIER (PIN 1234)

**Étapes** :
1. [ ] Naviguer vers `/inventory`
2. [ ] Tenter d'accéder à `/inventory/adjustments/new`

**Vérifications** :
- [ ] Route **bloquée** par GoRouter guard
- [ ] Redirection vers `/pos` ou message "Accès refusé"
- [ ] Bouton "Nouveau" invisible ou désactivé pour CASHIER

### Scénario 28 : CASHIER peut voir stock (si permission activée) (2 min)

**Préconditions** :
- Connecté en CASHIER
- Permission "Voir stock depuis caisse" activée (docs/differences.md gap Loyverse)

**Étapes** :
1. [ ] Depuis `/pos` (écran caisse)
2. [ ] Tap sur un produit (Produit A)
3. [ ] Observer le badge ou icône stock

**Vérifications** :
- [ ] Stock **affiché** : "88 en stock" ou badge "Stock: 88"
- [ ] CASHIER peut voir mais **pas modifier**
- [ ] Si permission désactivée, stock **masqué** ou affiche "—"

### Scénario 29 : ADMIN peut tout faire (1 min)

**Préconditions** : Connecté en ADMIN

**Étapes** :
1. [ ] Accéder à `/inventory/adjustments/new` → ✅ OK
2. [ ] Accéder à `/inventory/counts/new` → ✅ OK
3. [ ] Exporter inventaire → ✅ OK
4. [ ] Importer CSV → ✅ OK

**Vérifications** :
- [ ] Tous les écrans accessibles
- [ ] Aucun bouton désactivé
- [ ] Routes non bloquées

---

## Tests de Performance & Limites (Optionnel — 5 min)

### Scénario 30 : Import de 100+ produits (3 min)

**Préconditions** : Créer un fichier `import-large.csv` avec 150 lignes

**Étapes** :
1. [ ] Importer le fichier (150 produits)
2. [ ] Observer la durée

**Vérifications** :
- [ ] Import réussi en < 10 secondes
- [ ] Aucun freeze de l'UI
- [ ] Tous les 150 produits créés
- [ ] Pas de crash ou timeout

### Scénario 31 : Liste inventaire avec 200+ items (2 min)

**Préconditions** : 200 produits en base

**Étapes** :
1. [ ] Naviguer vers `/inventory`
2. [ ] Scroller la liste

**Vérifications** :
- [ ] Scroll fluide (pas de lag)
- [ ] Lazy loading ou pagination active
- [ ] Recherche rapide (< 500ms)

---

## Résumé Final

### Statistiques de Tests

| Phase | Scénarios | Durée estimée | Statut |
|-------|-----------|---------------|--------|
| **3.11 — Crédit** | 4 scénarios | 15 min | ☐ |
| **3.12 — Remboursements** | 3 scénarios | 12 min | ☐ |
| **3.13 — Vue Stock** | 3 scénarios | 7 min | ☐ |
| **3.14 — Ajustements** | 3 scénarios | 10 min | ☐ |
| **3.15 — Export** | 2 scénarios | 6 min | ☐ |
| **3.16 — Import** | 3 scénarios | 11 min | ☐ |
| **3.17 — Comptage** | 5 scénarios | 24 min | ☐ |
| **Cross-Feature** | 3 scénarios | 10 min | ☐ |
| **Permissions** | 3 scénarios | 5 min | ☐ |
| **Performance** (opt.) | 2 scénarios | 5 min | ☐ |
| **TOTAL** | **31 scénarios** | **~105 min** (1h45) | ☐ |

### Tests Critiques (DOIT passer) — 50 min

- [ ] **Offline-first** : Scénarios 2, 6, 12, 20 (créer/modifier sans WiFi)
- [ ] **Montants Ariary** : Tous scénarios affichent montants en `int` avec espaces (ex: "150 000 Ar")
- [ ] **Atomicité** : Scénario 26 (rollback si erreur)
- [ ] **Permissions** : Scénarios 27-29 (CASHIER vs ADMIN)
- [ ] **Stock cohérent** : Scénarios 24-25 (vente/refund → stock + historique)
- [ ] **Sync automatique** : Scénarios 2, 6, 12, 20 (badge "Non synchronisé" disparaît après 30s)

### Tests Optionnels (Nice to have) — 20 min

- [ ] Localisation FR/MG : vérifier tous les textes traduits
- [ ] Performance : Scénarios 30-31 (listes 100+ items fluides)
- [ ] Scan barcode : Scénario 21 (détection rapide < 1s)
- [ ] Auto-save : Scénario 22 (reprendre comptage interrompu)

### Bugs à Surveiller

1. **Montants décimaux** : Si "150000.0" apparaît au lieu de "150 000 Ar" → BUG CRITIQUE
2. **Sync infinie** : Si badge "Non synchronisé" reste après 2 min WiFi → vérifier logs Supabase
3. **Stock négatif** : Si stock passe en négatif sans alerte → BUG (sauf si `negative_stock_alerts = false`)
4. **Double sync** : Si même ligne envoyée 2x à Supabase → conflit UUID
5. **Permissions leak** : Si CASHIER accède à `/settings` → guard GoRouter défaillant

---

## Post-Tests

### Actions après tests réussis

- [ ] Marquer phases 3.11 à 3.17 comme ✅ **100% COMPLET** dans `tasks/todo.md`
- [ ] Mettre à jour `phases-completed.md` avec détails d'implémentation
- [ ] Ajouter leçons dans `tasks/lessons.md` si bugs trouvés
- [ ] Créer release notes : "Sprint 3 — Inventaire Avancé"

### Actions si échecs

- [ ] Logger chaque bug trouvé avec :
  - Scénario reproduisant le bug
  - Logs d'erreur (si disponibles)
  - Screenshots ou vidéo
- [ ] Corriger les bugs CRITIQUES (offline, montants, atomicité)
- [ ] Ré-exécuter la checklist après corrections

---

**Checklist créée le** : 2026-03-26
**Dernière mise à jour** : 2026-03-26
**Version** : 1.0
**Testeur** : _________________
**Date d'exécution** : _________________
**Résultat global** : ☐ PASS | ☐ FAIL (avec X bugs critiques)
