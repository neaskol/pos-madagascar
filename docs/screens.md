# Les 63 écrans — POS Madagascar

Charger ce fichier quand : création ou modification d'un écran Flutter.
Pour chaque écran : voir aussi `docs/design.md` pour les règles de design.

---

## Navigation principale

Bottom navigation bar à 5 onglets (toujours visible sauf écrans PIN et onboarding) :
1. **Caisse** (icône: shopping-cart)
2. **Produits** (icône: package)
3. **Clients** (icône: users)
4. **Rapports** (icône: bar-chart)
5. **Réglages** (icône: settings)

Route protégée par rôle : CASHIER n'a accès qu'à Caisse + Clients basique.

---

## MODULE AUTH (6 écrans)

### Écran 1 — Splash
**Route** : `/splash`
**Contenu** : Logo centré (96px), nom app, tagline en FR ou MG selon langue système
**Comportement** : 1.5s → redirect vers `/pin` si déjà connecté, `/login` sinon
**Design** : fond blanc, pas de boutons, pas d'AppBar

### Écran 2 — Onboarding (3 slides)
**Route** : `/onboarding` (premier lancement uniquement)
**Slides** :
- Slide 1 : "Vendez depuis votre téléphone" + illustration caisse mobile
- Slide 2 : "Fonctionne sans internet" + illustration offline (nuage barré)
- Slide 3 : "MVola & Orange Money inclus" + illustration paiement mobile
**Navigation** : PageView, dots en bas, bouton "Commencer" sur dernier slide, "Passer" en haut à droite

### Écran 3 — Login
**Route** : `/login`
**Contenu** :
- Logo app (64px)
- Champ email + champ mot de passe (toggle afficher/masquer)
- Bouton "Se connecter" (primaire, pleine largeur)
- Lien "Mot de passe oublié"
- Lien "Créer un compte"
- Sélecteur langue FR / MG (icône drapeau, persistant)
**Validation** : email valide, mot de passe ≥ 8 chars

### Écran 4 — Inscription
**Route** : `/register`
**Contenu** :
- Nom complet, email, mot de passe (+ confirmation), téléphone (optionnel)
- Bouton "Créer mon compte"
- Lien "Déjà un compte ? Se connecter"

### Écran 5 — Setup Wizard magasin
**Route** : `/setup`
**Étapes** :
1. Nom du magasin + upload logo (photo ou crop)
2. Devise (Ariary MGA par défaut) + arrondi de caisse (0, 50, 100, 200 Ar)
3. Langue interface (FR/MG) + langue des reçus
4. Type de commerce → active les modules correspondants :
   - Épicerie / Superette → stock + alertes + barcodes
   - Restaurant / Café → open tickets + dining options + cuisine
   - Boutique / Mode → variants + photos
   - Service / Salon → customers focus
   - Autre → modules de base
**Design** : stepper 4 étapes, barre de progression, pas d'AppBar, boutons Précédent/Suivant

### Écran 6 — PIN Caisse
**Route** : `/pin`
**Contenu** :
- Titre "Qui êtes-vous ?"
- Grille d'avatars des employés (initiales colorées, nom dessous)
- Tap sur employé → pavé numérique 4 chiffres (custom, pas natif)
- 4 cercles de progression (● ● ○ ○)
- Lien "Connexion email" pour admins
**Design** : plein écran, fond blanc, avatars en grille 3 colonnes, pavé large et bien espacé

---

## MODULE CAISSE (9 écrans)

### Écran 7 — Caisse principale (POS)
**Route** : `/pos`
**C'est l'écran le plus important de l'app. Voir règles absolues dans `docs/design.md`.**

**Layout tablette (>600px)** :
- Colonne gauche 58% : grille produits + navigation pages
- Colonne droite 42% : panier + total + bouton Payer

**Layout smartphone** :
- Plein écran : grille produits
- Bottom panel fixe (250px) : panier condensé + bouton Payer
- Ou : drawer de droite pour le panier

**Zone produits** :
- AppBar : titre magasin + icône scan + icône open tickets + menu (...)
- Barre de recherche + dropdown filtre catégorie
- Onglets de pages personnalisées (grille ou liste)
- Items : photo 60px ou couleur, nom, prix

**Zone panier** :
- Liste des items : nom, qté, prix ligne (swipe gauche = supprimer)
- Tap sur item = modifier quantité / remise / modifier
- Séparateur fin entre items
- Total en bas : sous-total + taxes + remises + **TOTAL en vert 24px**
- Bouton **PAYER** vert pleine largeur 56px

**Menu (...)** : Clear ticket, Save ticket, Merge, Split, Dining option, Print bill

### Écran 8 — Paiement
**Route** : `/pos/payment`
**Contenu** :
- Total à payer (32px, gras, vert) en haut
- Grille des types de paiement (2 colonnes) : Cash, Carte, MVola, Orange Money, custom
- Si Cash sélectionné : montants suggérés (2000, 5000, 10000, 20000, 50000 Ar) + saisie custom → monnaie calculée live
- Si MVola/Orange Money : numéro marchand affiché + bouton deep link + champ référence transaction
- Bouton "Valider le paiement" en bas
- Bouton "Paiement fractionné" (Split)
**Après paiement** : écran résumé (total + monnaie rendue + options reçu)

### Écran 9 — Split Payment
**Route** : `/pos/payment/split`
**Contenu** :
- Contrôle +/- nombre de parts (2 à 10)
- Liste des parts : montant (modifiable) + type de paiement (picker)
- Répartition équitable par défaut, ajustable
- Indicateur "Payé X / Reste Y Ar" en haut
- Chaque part : bouton "Payer cette part" → marquée "✓ Payé" en vert
- Bouton "Terminer" actif quand tout est payé

### Écran 10 — Configuration grille caisse
**Route** : `/pos/layout`
**Contenu** :
- Mode édition : tap et hold sur la grille depuis l'écran caisse
- Grille avec cases : items placés + cases vides (+)
- Tap case vide → bottom sheet picker (items / catégories / remises)
- Drag & drop pour réorganiser
- Onglets de pages en haut (renommables par long press)
- Bouton "Ajouter une page" + "Terminer"

### Écran 11 — Liste des tickets ouverts
**Route** : `/pos/tickets`
**Contenu** :
- AppBar : "Tickets ouverts" + bouton "Nouveau ticket"
- Tri par : nom, montant, heure, employé (chips de tri)
- Barre de recherche
- Chaque ticket : nom, heure, nb items, montant, employé, badge dining option
- Tickets prédéfinis (tables) groupés en haut avec badge de couleur
- Long press → sélection multiple → merge / assigner / supprimer
- Tap → ouvrir le ticket dans l'écran caisse

### Écran 12 — Liste des reçus
**Route** : `/pos/receipts`
**Contenu** :
- Filtres : Tous / Aujourd'hui / Cette semaine + filtre employé + filtre paiement
- Chaque reçu : numéro, heure, items (résumé), total, mode paiement, employé
- Reçus remboursés : texte en rouge + badge "Remboursé"
- Badge "Non synchronisé" en orange si offline
- Pull-to-refresh, pagination infinie
- Barre de recherche (désactivée offline)

### Écran 13 — Détail d'un reçu
**Route** : `/pos/receipts/:id`
**Contenu** :
- Header : numéro reçu, date/heure, employé, caisse, option service
- Liste items : photo miniature, nom, qté, prix unitaire, remise, total ligne
- Pied : sous-total, détail taxes, remises, **TOTAL**
- Modes de paiement avec montants
- Boutons : "Rembourser" (si permission + online) · "Imprimer" · "WhatsApp" · "Email"

### Écran 14 — Remboursement
**Route** : `/pos/receipts/:id/refund`
**Contenu** :
- Deux colonnes : reçu original (gauche) | reçu remboursement (droite)
- Tap sur item gauche → passe à droite avec qté sélectionnable
- Total à rembourser mis à jour en temps réel
- Bouton "Confirmer le remboursement" en bas
- **Fonctionne offline** (différenciant vs Loyverse p.67)

### Écran 15 — Gestion du shift
**Route** : `/pos/shift`
**Si shift fermé** :
- Champ "Montant initial en caisse"
- Bouton "Ouvrir la caisse"

**Si shift ouvert** :
- Résumé : CA depuis ouverture, nb ventes, montant cash estimé
- Boutons : "Entrée caisse (Pay In)" · "Sortie caisse (Pay Out)"
- Historique des mouvements cash du shift
- Bouton "Fermer la caisse" → saisir montant réel → afficher écart

---

## MODULE PRODUITS (8 écrans)

### Écran 16 — Liste des produits
**Route** : `/products`
**Contenu** :
- Barre de recherche + filtre catégorie + filtre stock (Tous / Bas / Rupture)
- Chaque item : photo/couleur (44px), nom, SKU, prix, stock coloré (vert/orange/rouge)
- Badge "Hors vente" si available_for_sale = false
- FAB "+" en bas à droite
- Tap → éditer. Long press → sélection multiple (export, supprimer)
- **Photos visibles ici** (gap Loyverse corrigé)

### Écran 17 — Créer / Modifier un produit
**Route** : `/products/new` et `/products/:id/edit`
**Sections** :
1. **Photo** : upload (crop carré auto) ou sélectionner couleur + icône
2. **Infos de base** : Nom, Catégorie, Description (optionnel), SKU (auto/manuel), Barcode
3. **Prix** : Prix de vente + Coût (montant ou %) → Marge calculée live en vert/rouge
4. **Vente** : toggle "Disponible à la vente" + "Vendu au poids" (si oui: unité de poids)
5. **Stock** : toggle "Suivre le stock" → saisir stock actuel + seuil d'alerte
6. **Taxes** : checkboxes des taxes configurées
7. **Modifiers** : checkboxes des modifiers configurés
8. **Variants** : bouton "Ajouter des variants" → écran variants
9. **Item composite** : toggle → ajouter des composants
**Bouton Sauvegarder** en bas (sticky)

### Écran 18 — Variants
**Route** : `/products/:id/variants`
**Contenu** :
- Jusqu'à 3 options (ex: Taille, Couleur)
- Chaque option : nom + chips de valeurs (éditables, supprimables, + ajouter)
- Tableau des combinaisons générées : Prix / Coût / SKU / Barcode / Stock par ligne
- Édition inline dans le tableau
- Max 200 combinaisons (avertissement au-delà)

### Écran 19 — Catégories
**Route** : `/products/categories`
**Contenu** :
- Liste des catégories : puce couleur, nom, nb produits
- Drag & drop pour réordonner
- Tap → éditer (nom + sélecteur couleur palette)
- FAB "+" pour ajouter
- Swipe → supprimer (avec confirmation si catégorie non vide)

### Écran 20 — Modifiers
**Route** : `/products/modifiers`
**Contenu** :
- Liste des modifiers : nom, nb options, badge "Obligatoire" si is_required
- Tap → éditer
- Formulaire modifier : nom + toggle "Obligatoire" + min/max choix + liste d'options (nom + prix)
- Drag & drop options pour réordonner

### Écran 21 — Taxes
**Route** : `/products/taxes`
**Contenu** :
- Liste : nom, taux %, type (badge "Incluse" ou "Ajoutée"), actif/inactif
- TVA Madagascar 20% pré-configurée par défaut
- Formulaire : nom + taux + type + actif

### Écran 22 — Remises
**Route** : `/products/discounts`
**Contenu** :
- Liste : nom, type (% ou Ar), valeur, badge "Restreint" si applicable, actif/inactif
- Formulaire : nom + type + valeur (peut être vide = saisie libre) + toggle restreint

### Écran 23 — Import / Export CSV
**Route** : `/products/import-export`
**Contenu** :
- Onglets Import / Export
- Import : zone de dépôt fichier + bouton choisir + aperçu lignes (5 premières) + validation + confirmation
- Erreurs : tableau avec numéro de ligne + message explicatif
- Export : checkboxes (items / clients / reçus) + bouton Télécharger

---

## MODULE STOCKS (8 écrans)

### Écran 24 — Vue d'ensemble stock
**Route** : `/inventory`
**Contenu** :
- Métriques : nb ruptures (rouge) + nb alertes (amber) + valeur stock total (si coût renseigné)
- Liste items triée par urgence : ruptures d'abord, puis alertes, puis ok
- Filtre : Tous / Bas stock / Rupture
- Tap item → quick edit du stock

### Écran 25 — Ajustement de stock
**Route** : `/inventory/adjustments/new`
**Contenu** :
- Sélecteur de raison : Réception / Perte / Dommage / Inventaire / Autre
- Sélecteur magasin (si multi-magasins)
- Note optionnelle
- Recherche + ajout d'items à la liste
- Pour chaque item : stock actuel (lecture seule) + champ "Variation" (+ ou -)
- Bouton "Valider"

### Écran 26 — Liste des ajustements
**Route** : `/inventory/adjustments`
**Contenu** :
- Liste : date, raison, nb articles, employé, total variation
- Tap → détail avec tous les articles ajustés

### Écran 27 — Inventaire physique
**Route** : `/inventory/counts`
**Contenu** :
- Liste des inventaires : date, type, statut, nb articles
- Créer : type (Complet/Partiel) + note
- Mode comptage : scan barcode + saisie quantité comptée
- Tableau : attendu / compté / différence (différence colorée)
- Sauvegarde auto toutes les 30s
- Bouton "Terminer" → aperçu écarts → confirmer

### Écran 28 — Fournisseurs
**Route** : `/inventory/suppliers`
**Contenu** :
- Liste : nom, email, téléphone, nb commandes actives
- Formulaire : nom (unique), email, téléphone, adresse, notes

### Écran 29 — Bons de commande
**Route** : `/inventory/purchase-orders`
**Contenu** :
- Filtres par statut : Draft / En attente / Partiel / Fermé
- Chaque BdC : numéro, fournisseur, date, statut coloré, total
- Créer BdC : fournisseur + date + date attendue + items (recherche + qté + prix achat)
- Bouton "Autofill items bas stock" → remplit automatiquement
- Actions : Envoyer par email, Réceptionner, Modifier
- Réception : qté reçue par item → MAJ stock + coût moyen pondéré

### Écran 30 — Transferts entre magasins
**Route** : `/inventory/transfers`
**Contenu** :
- Liste par statut : Draft / En transit / Transféré
- Créer : source + destination + items + quantités
- Stock affiché dans les deux magasins pour chaque item
- Statuts et transitions visuelles claires

### Écran 31 — Impression d'étiquettes
**Route** : `/inventory/labels`
**Contenu** :
- Sélecteur d'items (par recherche ou catégorie)
- Quantité d'étiquettes par item
- Options : Nom / SKU / Prix / Barcode (Code-128)
- Aperçu de l'étiquette (miniature)
- Bouton "Imprimer" → envoi Bluetooth

---

## MODULE CLIENTS (4 écrans)

### Écran 32 — Liste des clients
**Route** : `/customers`
**Contenu** :
- Recherche par nom / téléphone / email
- Chaque client : avatar initiales coloré, nom, téléphone, points fidélité, dernière visite
- FAB "+"

### Écran 33 — Profil client
**Route** : `/customers/:id`
**Contenu** :
- Header : avatar, nom, téléphone, email
- Métriques : total dépensé, nb visites, points actuels
- Onglets : Historique achats | Dettes (crédits en cours)
- Bouton WhatsApp pour contact direct

### Écran 34 — Ventes à crédit
**Route** : `/customers/credits`
**Contenu** :
- Résumé : total dettes en cours + nb en retard (en rouge)
- Filtre : En attente / Partiel / Payé / En retard
- Chaque crédit : client, montant total, payé, restant, date limite, statut coloré
- Tap → enregistrer un paiement (partiel ou total)
- Bouton WhatsApp pour rappel en 1 tap
- **Feature unique vs tous les concurrents**

### Écran 35 — Programme de fidélité (réglages)
**Route** : `/customers/loyalty/settings`
**Contenu** :
- Toggle activer/désactiver
- Règle : X Ariary = Y points (ex: 1000 Ar = 1 point)
- Règle : Z points = W Ariary de remise (ex: 100 points = 1000 Ar)
- Bouton "Imprimer cartes de fidélité" avec barcode

---

## MODULE EMPLOYÉS (4 écrans)

### Écran 36 — Liste des employés
**Route** : `/employees`
**Contenu** :
- Chaque employé : avatar initiales, nom, rôle (badge coloré), magasins, actif/inactif
- FAB "+"

### Écran 37 — Créer / Modifier employé
**Route** : `/employees/new` et `/employees/:id/edit`
**Contenu** :
- Nom, email (optionnel), téléphone
- Sélecteur de rôle (Owner/Admin/Manager/Cashier + rôles custom)
- PIN 4 chiffres (saisie sécurisée avec confirmation)
- Magasins assignés (checkboxes si multi-magasins)
- Toggle Actif / Inactif

### Écran 38 — Droits d'accès
**Route** : `/employees/roles`
**Contenu** :
- 4 groupes par défaut + bouton "Créer un rôle"
- Owner : verrouillé (toutes les permissions)
- Autres : liste de toggles organisés en sections POS / Back Office
- Toutes les permissions listées dans `CLAUDE.md` section Rôles

### Écran 39 — Pointage (Time Clock)
**Route** : `/employees/timeclock`
**Contenu** :
- Pour l'employé connecté : état actuel (Arrivé / Parti) + heure
- Bouton "Arrivée" / "Départ" (gros, bien visible)
- Historique de la semaine : tableau heure arrivée / départ / durée par jour
- Vue manager : tableau de tous les employés du jour

---

## MODULE ANALYTICS (5 écrans)

### Écran 40 — Dashboard principal
**Route** : `/reports`
**Contenu** :
- Sélecteur de magasin (si multi)
- 4 métriques : CA aujourd'hui / Nb ventes / Ticket moyen / Profit
- Courbe des ventes (fl_chart) : onglets Aujourd'hui / 7j / 30j / 12 mois
- Top 5 produits (barres horizontales)
- Camembert modes de paiement
- Section alertes : ruptures de stock, crédits en retard, shift ouvert

### Écran 41 — Rapport des ventes
**Route** : `/reports/sales`
**Contenu** :
- Sélecteur de période (date picker range)
- Résumé : CA, nb transactions, ticket moyen, profit, taxes collectées
- Ventilation par mode de paiement
- Ventilation par employé
- Boutons : Export PDF / Export Excel

### Écran 42 — Rapport par produit
**Route** : `/reports/products`
**Contenu** :
- Tableau : produit, qté vendue, CA, coût, marge Ar, marge %
- Tri par n'importe quelle colonne (tap header)
- Filtre par catégorie
- Alerte rouge si marge négative (vente à perte)
- Export Excel

### Écran 43 — Rapport des shifts
**Route** : `/reports/shifts`
**Contenu** :
- Liste : caisse, employé, ouverture, fermeture, attendu, réel, écart (coloré)
- Tap → détail avec tous les mouvements cash du shift

### Écran 44 — Valorisation inventaire
**Route** : `/reports/inventory-valuation`
**Contenu** :
- Résumé : valeur inventaire (coût total), valeur retail, profit potentiel, marge %
- Tableau : produit, coût moyen, stock, valeur coût, valeur retail, marge
- Filtre par catégorie
- Export

---

## MODULE RÉGLAGES (5 écrans)

### Écran 45 — Menu des réglages
**Route** : `/settings`
**Structure** :
```
Magasin
  ├── Informations du magasin
  ├── Fonctionnalités (modules)
  ├── Types de paiement
  ├── Configuration des reçus
  └── Options de service (Dining)

Appareils
  ├── Caisses POS
  └── Hardware (imprimantes, scanners)

Utilisateurs
  ├── Employés
  └── Droits d'accès

Multi-magasins
  └── Gérer les magasins

Mon compte
  ├── Informations personnelles
  ├── Changer le mot de passe
  └── Langue de l'interface

Danger
  └── Supprimer le compte
```

### Écran 46 — Fonctionnalités (modules)
**Route** : `/settings/features`
**Contenu** :
- Liste de toggles avec description courte de chaque module
- Voir `CLAUDE.md` section Architecture modulaire pour la liste complète
- Certains toggles ouvrent des sous-réglages (ex: Tickets prédéfinis → gérer les tables)

### Écran 47 — Types de paiement
**Route** : `/settings/payment-types`
**Contenu** :
- Cash : toujours actif, non supprimable
- Carte bancaire : toggle + (futur) paramètres processeur
- MVola : toggle + champ numéro marchand (requis si activé)
- Orange Money : toggle + champ numéro marchand
- Bouton "Ajouter un type" → nom custom (ex: "Chèque", "Virement")
- Drag & drop pour réordonner l'affichage à la caisse

### Écran 48 — Hardware
**Route** : `/settings/hardware`
**Contenu** :
- Imprimante reçus : bouton "Rechercher" → liste appareils Bluetooth → appairer → test impression
- Imprimante cuisine : même flow, puis assigner à une station (si activée)
- Tiroir-caisse : toggle ouverture automatique à chaque vente cash
- Scanner externe : toggle détection Bluetooth

### Écran 49 — Multi-magasins
**Route** : `/settings/stores`
**Contenu** :
- Liste des magasins avec CA du jour, nb appareils
- Tap → réglages du magasin spécifique
- Bouton "Ajouter un magasin"
- Sélecteur de magasin actif (pour filtrer les rapports)

---

## MODALS ET DIALOGS RÉCURRENTS (8)

Ces éléments apparaissent en overlay, pas comme écrans à part entière.

1. **Dialog modifier** : sélection des options lors de l'ajout au panier
2. **Dialog variants** : sélection du variant lors de l'ajout au panier
3. **Dialog quantité** : pavé numérique pour modifier la quantité d'un item
4. **Dialog poids** : pavé numérique pour saisir le poids (items vendus au poids)
5. **Bottom sheet sauvegarder ticket** : nom + commentaire + liste prédéfinie
6. **Dialog confirmation** : pour les actions destructives (supprimer, annuler, rembourser)
7. **Écran résumé post-paiement** : total, monnaie, options reçu (WhatsApp, email, imprimer)
8. **Dialog enregistrement crédit** : à la caisse, bouton "À crédit" → saisir date limite

---

## Récapitulatif

| Module | Nb écrans |
|--------|-----------|
| Auth (onboarding, login, PIN) | 6 |
| Caisse (POS, paiement, tickets, reçus, shift) | 9 |
| Produits (items, catégories, modifiers, taxes) | 8 |
| Stocks & inventaire avancé | 8 |
| Clients & fidélité & crédits | 4 |
| Employés & pointage | 4 |
| Analytics & rapports | 5 |
| Réglages & configuration | 5 |
| Modals / dialogs | 8 |
| **TOTAL** | **57 + 8 dialogs = 65** |
