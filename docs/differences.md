# Ce qu'on fait mieux que Loyverse

Charger ce fichier quand : vérifier qu'une feature corrige un gap Loyverse, valider les différenciants.

---

## Gaps confirmés par le manuel officiel (avec pages)

### 1. Mode offline 100% — notre différenciant le plus fort

| Feature | Loyverse | Notre app | Page manuel |
|---------|----------|-----------|-------------|
| Ventes | Oui | Oui | - |
| Remboursements | **NON** — bouton inactif | **Oui** | p.67, p.79 |
| Nouveau client | **NON** | **Oui** | p.81 |
| Stock visible | **NON** | **Oui** (Drift) | p.84 |
| Alertes stock négatif | **NON** | **Oui** | p.78 |
| Open tickets (sync) | Pas de sync offline | Local uniquement | p.81 |
| Email reçu | Différé | Différé + WhatsApp | p.81 |
| Recherche reçus | **NON** | **Oui** | p.79 |

**Implémentation** : Drift pour 100% des données locales. Sync Supabase asynchrone.
Tester systématiquement en coupant le wifi après chaque feature.

---

### 2. Multi-utilisateurs gratuit

| Loyverse | Notre app |
|----------|-----------|
| $25/mois pour Employee Management | **Gratuit** |
| PIN par employé | PIN par employé |
| 4 groupes par défaut | 4 groupes par défaut |
| Permissions configurables | Permissions configurables |
| + `view_stock_in_pos` manquante | **`view_stock_in_pos` ajoutée** |

Page manuel : p.263-265 (pricing add-ons).

---

### 3. Vente à crédit — inexistant partout

Aucun concurrent (Loyverse, Square, Shopify, Clover) ne gère la vente à crédit.
C'est une pratique universelle dans les commerces africains.

**Notre module crédit** :
- Enregistrer une vente à crédit depuis la caisse (bouton "À crédit" à côté de "Payer")
- Fiche client avec liste des dettes en cours
- Date limite de remboursement configurable
- Remboursements partiels ou totaux
- Statuts : `pending` → `partial` → `paid` → `overdue`
- Rappels automatiques : SMS via Twilio ou WhatsApp quand échéance approche
- Vue gérant : total des dettes en cours par magasin
- Fonctionne offline (Drift)

---

### 4. MVola & Orange Money — monopole de fait

Aucun POS mondial ne supporte les Mobile Money malgaches.

**Implémentation** :
```dart
// MVola — deep link vers l'app MVola
final mvolaUri = Uri.parse('https://mvola.mg/pay?amount=$amount');
// Ou USSD : *111*1*$merchantNumber*$amount#

// Orange Money — deep link
final omUri = Uri.parse('orangemoney://pay?amount=$amount&to=$merchantNumber');

// Après confirmation : saisir la référence de transaction manuellement
// La vente est enregistrée avec payment_status = 'confirmed' après saisie
```

**Dans les réglages magasin** : numéro MVola et Orange Money du marchand (affiché automatiquement à la caisse).

---

### 5. Interface Malagasy

Loyverse : 30+ langues, pas Malagasy.
Notre app : première app POS en Malagasy.

**Implémentation** :
- `lib/l10n/app_mg.arb` : toutes les clés en Malagasy
- Basculer depuis les réglages (FR ↔ MG) sans redémarrage
- Langue séparée possible pour les reçus (ex: interface en MG mais reçus en FR)
- Termes techniques (POS, stock, TVA) restent en français si pas de traduction naturelle

---

### 6. Prix d'achat en % — marge correcte

| Loyverse | Notre app |
|----------|-----------|
| Prix d'achat en montant fixe seulement | % ou montant fixe |
| Produits à prix variable = coût 0 | Coût correct même si variable |
| Marge incorrecte sur ces produits | Marge toujours juste |

**Implémentation** : champ `cost_is_percentage BOOL` dans la table `items`.
Voir `docs/formulas.md` pour le calcul.

---

### 7. Photos dans la liste stock

| Loyverse | Notre app |
|----------|-----------|
| Photos visibles à la caisse (p.83) | Photos partout |
| Pas de miniature dans la liste stock | Miniature dans liste stock, inventaire, rapports |

---

### 8. Forced modifiers

| Loyverse | Notre app |
|----------|-----------|
| Modifiers optionnels seulement (p.65-66) | Optionnels + obligatoires |
| Pas de blocage si pas de sélection | Dialog bloque si sélection requise |
| Pas de min/max configurables | Min/max choix configurables |

**Implémentation** : `modifiers.is_required BOOL` + `min_choices INT` + `max_choices INT`.
Dialog à la caisse ne peut pas être fermé sans sélection si `is_required = true`.

---

### 9. Inventaire avancé gratuit

| Feature | Loyverse | Notre app |
|---------|----------|-----------|
| Fournisseurs | $25/mois | **Gratuit** |
| Bons de commande | $25/mois | **Gratuit** |
| Transferts entre magasins | $25/mois | **Gratuit** |
| Ajustements de stock | $25/mois | **Gratuit** |
| Inventaire physique | $25/mois | **Gratuit** |
| Étiquettes produits | $25/mois | **Gratuit** |
| Historique mouvements | $25/mois | **Gratuit** |

Page manuel : p.265-266. Un commerce avec les 3 add-ons = **$65/mois** chez Loyverse.

---

### 10. Export et impression de l'inventaire

| Loyverse | Notre app |
|----------|-----------|
| Impossible d'imprimer/exporter la liste stock | Export PDF + CSV + Excel |
| Demandé depuis des années par les users | Feuille d'inventaire physique imprimable |

---

### 11. Sélection multiple même catégorie

| Loyverse | Notre app |
|----------|-----------|
| Sélection un par un seulement | Mode multi-sélection dans une catégorie |
| Retour à la liste après chaque item | Cocher N items → ajouter tous d'un coup |

Plainte courante des utilisateurs Loyverse : impossible de sélectionner plusieurs variants
d'un même produit sans revenir en arrière à chaque fois.

---

## Fonctionnalités uniquement chez nous

### Rappels SMS/WhatsApp pour dettes
- Twilio ou WhatsApp Business API
- Déclenchés automatiquement via Supabase Edge Functions (cron)
- Message template personnalisable par magasin

### Assistant IA (Claude API)
- Analyse les données de vente du magasin
- Suggestions actionnables : ruptures à venir, heures creuses, produits à promouvoir
- Exemple : "Tes stocks de riz sont à 3 jours, recommande-en maintenant"
- Exemple : "Tes ventes baissent le lundi matin — propose une promo"
- Disponible en FR et Malagasy

### Remboursement et crédit offline
Combinaison unique : offline 100% + vente à crédit = aucun concurrent ne propose les deux.

---

## Checklist "mieux que Loyverse" — à vérifier par feature

Avant de marquer une feature comme terminée, vérifier :

- [ ] Fonctionne offline (si Loyverse le bloque, noter comme différenciant)
- [ ] Multi-users gratuit appliqué (rôles + permissions)
- [ ] Photos visibles dans tous les contextes (pas seulement la caisse)
- [ ] Montants en Ariary entiers, formatage correct
- [ ] Forced modifiers implémentés si la feature concerne les modifiers
- [ ] Export/impression disponible si la feature génère des données
