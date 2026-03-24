# Features Loyverse — Comportement exact à reproduire

Charger ce fichier quand : implémentation d'une feature POS, besoin de savoir exactement comment Loyverse se comporte.
Source : Manuel officiel Loyverse (338 pages, mars 2024).

---

## Caisse — Sale Screen (p.26-50)

### Grille de produits (p.31-36)
- Page par défaut (icône grille) : tous les items par ordre alphabétique, non modifiable
- Pages personnalisées : l'utilisateur crée des pages, y place les items en drag & drop
- Grilles et catégories peuvent être ajoutées aux pages personnalisées
- Tablette : vue grille par défaut. Smartphone : vue liste par défaut. Les deux changeable dans les réglages.
- Pages sans items ne sont pas sauvegardées

### Ajout au panier
- Tap sur l'item = ajouter au panier
- Tap sur l'item dans le panier = modifier la quantité
- Swipe gauche sur l'item dans le panier = supprimer
- Menu 3 points → "Clear ticket" = vider tout le panier

### Remises (p.37-39)
- Remise % : applicable sur ticket entier OU par article
- Remise montant fixe : applicable sur ticket entier seulement
- Appliquer sur ticket entier : dropdown "All items" → "Discounts"
- Appliquer sur un article : tap l'article dans le panier → section Discounts
- Plusieurs remises cumulées : de la plus petite à la plus grande valeur effective
- Remise "Restricted access" : seuls les employés avec la permission peuvent appliquer

### Paiement (p.26-29)
- Bouton "Charge" en bas à droite
- Fenêtre de paiement : choisir le type
- Cash : montants suggérés pré-calculés + saisie montant custom → calcul monnaie
- Après paiement : résumé (total + monnaie) → option email reçu → nouveau ticket

### Split Payment (p.49-50)
- Bouton "Split" dans la fenêtre de paiement
- + / - pour définir le nombre de parts
- Par défaut : montant divisé équitablement
- Chaque part peut avoir un type de paiement différent
- Chaque part peut avoir un montant custom
- Reçus séparés générés pour chaque paiement
- Bouton "Done" pour finaliser après tous les paiements

---

## Open Tickets (p.51-63)

### Création
- Ticket formé → bouton "Save"
- Fenêtre : modifier le nom (généré auto avec heure) + ajouter un commentaire
- Si tickets prédéfinis activés : choisir dans la liste (ex: Table 1, Table 2)
- Ticket sauvegardé → colonne claire pour nouveau client

### Gestion
- Bouton "Open tickets" → liste triable par nom, montant, heure, employé
- Recherche dans la liste
- Tap sur un ticket → modifier ou fermer (payer)
- Menu 3 points sur ticket → "Edit ticket" (modifier nom/commentaire)
- Employés avec permission "Manage all open tickets" → assigner des tickets entre collègues

### Fusion (Merge) (p.54-56)
- Depuis la liste : cocher plusieurs tickets → icône Merge → choisir un nom
- Depuis l'écran vente : menu 3 points → "Merge ticket" → sélectionner les tickets à fusionner
- Items + modifiers + remises + taxes de chaque ticket suivent
- Remises % appliquées sur le ticket entier s'appliquent au ticket fusionné

### Division (Split) (p.57-58)
- Menu 3 points → "Split ticket"
- Écran : ticket original à gauche, nouveau ticket à droite
- Tap sur items pour les déplacer → "Move here"
- Bouton ⊕ pour ajouter un 3ème ticket (jusqu'à 20 tickets)
- Items + modifiers individuels suivent
- Remises % du ticket original → appliquées à tous les nouveaux tickets
- Remises montant fixe → déplaçables comme les items

### Sync entre appareils (p.59)
- Open tickets visibles sur tous les appareils du même magasin
- Un ticket peut être ouvert sur l'appareil A et payé sur l'appareil B

---

## Remboursements (p.67-68)

- Menu POS → "Receipts" → trouver le reçu → bouton "Refund"
- Écran : liste des items à gauche, sélectionner ce qu'on rembourse → apparaît à droite
- Bouton "Refund" → le stock des items remboursés est réintégré automatiquement
- Dans la liste des reçus : reçus remboursés en rouge
- **Loyverse : remboursement impossible offline** (bouton Refund inactif)
- **Notre app : remboursement offline complet** — différenciant #1

---

## Shifts (p.69-73)

- Activer dans Back Office → Settings → Features → "Shifts"
- Ouverture shift : saisir le montant initial en caisse → "Open shift"
- Cash management : "Pay In" (argent entré sans vente) / "Pay Out" (argent sorti)
- Fermeture : "Close shift" → saisir le montant réel → voir l'écart
- Permission "View shift report" : si désactivée, le caissier ne voit pas le montant attendu
- Rapport shifts : dans le Back Office, historique avec tous les détails

---

## Items — comportement de la caisse

### Modifiers (p.65-66)
- Tap sur un item avec modifiers → dialog s'ouvre automatiquement
- Choisir les options → "Save"
- Prix des options s'ajoutent au prix de l'item
- **Loyverse : modifiers optionnels seulement**
- **Notre app : modifiers obligatoires configurables** (dialog bloque si pas de sélection)

### Vente au poids (p.45-46)
- Item configuré "Sold by weight" → pavé numérique s'ouvre à l'ajout au panier
- Saisir le poids → prix = prix/unité × poids
- L'item s'ajoute au panier avec le poids saisi

### Variants (p.86-89)
- Tap sur item avec variants → dialog s'ouvre
- Choisir la combinaison souhaitée → "Save"
- L'item apparaît dans le panier avec la variant sélectionnée

### Alerte stock négatif (p.77-78)
- Activable dans Settings → Features → "Negative stock alerts"
- Alerte apparaît quand quantité dans panier > stock disponible
- Affiche le stock disponible
- Le caissier peut forcer la vente malgré l'alerte
- **Désactivé en mode offline dans Loyverse** — notre app : actif offline (Drift)

---

## Clients & Fidélité (p.159-183)

### Programme de fidélité (p.159, 162-163)
- Configuration dans Back Office : points par transaction, valeur en Ariary
- À la caisse : ajouter le client au ticket → ses points s'accumulent automatiquement
- Rachat de points : tap sur les points du client dans le ticket → choisir le montant à racheter
- Remise équivalente déduite du total
- Cartes fidélité avec barcode : scan pour identifier le client instantanément

### Identification client (p.160, 168, 176)
- Par téléphone : saisir le numéro → recherche dans la base
- Par barcode : scanner la carte fidélité du client
- **Loyverse : enregistrement nouveau client bloqué offline** (p.81)
- **Notre app : tout fonctionne offline**

---

## Gestion des taxes — réglages (p.19-23)

- Créer une taxe : nom + taux % + type (incluse / ajoutée)
- Assigner aux items : par item individuellement, ou "Select all"
- Taxes créées dans le POS : disponibles dans le magasin de cette caisse seulement
- Taxes créées dans le Back Office : disponibles dans tous les magasins
- Si taxe supprimée dans le POS → supprimée du Back Office aussi

---

## Gestion des discounts — réglages (p.24-26)

- Discount % : applicable sur ticket entier OU par article
- Discount montant fixe : applicable sur ticket entier seulement
- Si champ "Value" laissé vide → le caissier saisit le montant à la caisse
- Un discount vide peut seulement s'appliquer au ticket entier
- "Restricted access" : seuls les employés avec la permission peuvent l'utiliser

---

## Receipts — liste des reçus (p.78-79)

- Reçus de tous les appareils du même magasin visibles
- Pull-to-refresh pour actualiser
- Reçus non synchronisés (mode offline) marqués "Unsynced"
- Permission "View all receipts" : si désactivée → 5 reçus les plus récents seulement
- Actions sur un reçu : voir le détail, rembourser, imprimer, envoyer par email
- Envoi email offline → envoyé au retour de la connexion
- Pas de barre de recherche en mode offline

---

## Import/Export CSV items (p.95-100)

### Structure du CSV
```
Handle, SKU, Name, Category, Cost, Price, Default Price, Available for sale,
Sold by weight, Option 1 name, Option 1 value, Option 2 name, Option 2 value,
Option 3 name, Option 3 value, Barcode, SKU of included item, Quantity of included item,
Use production, Supplier, Purchase cost, Track stock, In stock, Low stock,
Modifier - [nom], Tax - [nom]
```

### Règles
- Items normaux : laisser "Handle" vide → généré auto
- Items avec variants : "Handle" obligatoire, même valeur pour tous les variants du même item
- Items composites : "SKU of included item" sur des lignes séparées
- Max 10 000 items, max 5 MB
- Pas de virgules dans les données (format CSV)
- Prix et coûts : chiffres uniquement, pas de symbole de devise

---

## Réglages — types de paiement (p.233)

- Types par défaut : Cash, Card
- Ajouter des types custom (ex: "Chèque", "Virement")
- Chaque type : nom + actif/inactif
- MVola et Orange Money = types custom dans notre app

---

## Dining Options (p.74-76)

- Activer dans Settings → Features → "Dining options"
- 3 options par défaut : Dine in, Takeout, Delivery
- Créer des options custom + changer l'ordre (drag & drop)
- Premier de la liste = option par défaut
- L'option choisie apparaît : sur le reçu imprimé, le reçu email, l'écran cuisine, le CDS
- Si plusieurs magasins : dining options configurables par magasin
