# Tests Manuels — POS Madagascar (Sprint 1-2-3)

**Date** : 26 mars 2026
**Version** : Debug APK
**Testeur** : _______________

**Legende** :
- [ ] = A tester
- [x] = OK
- [!] = Bug trouve (decrire en commentaire)
- N/A = Non applicable

---

## Donnees de test recommandees

### Produits a creer
| Nom | Prix (Ar) | Cout (Ar) | Stock | SKU | Categorie |
|-----|-----------|-----------|-------|-----|-----------|
| Riz Basmati | 15 000 | 10 000 | 100 | RICE001 | Epicerie |
| Huile Tournesol | 12 000 | 8 000 | 50 | OIL001 | Epicerie |
| Sucre Blanc | 5 000 | 3 000 | 25 | SUGAR001 | Epicerie |
| Farine T55 | 8 000 | 5 000 | 10 | FLOUR001 | Condiments |
| Sel Iode | 2 000 | 1 000 | 5 | SALT001 | Condiments |

### Clients
| Nom | Telephone |
|-----|-----------|
| Jean Rakoto | 034 12 345 67 |
| Marie Rasoa | 033 98 765 43 |

---

# SPRINT 1 — Fondation

## S1-01 : Onboarding (premier lancement)

- [ ] L'app s'ouvre sur le splash screen (logo + nom)
- [ ] Apres ~1.5s, redirige vers onboarding (3 slides)
- [ ] Slide 1 : "Vendez depuis votre telephone" visible
- [ ] Slide 2 : "Fonctionne sans internet" visible
- [ ] Slide 3 : "MVola & Orange Money inclus" visible
- [ ] Bouton "Passer" visible en haut a droite
- [ ] Bouton "Commencer" visible sur le dernier slide
- [ ] Tap "Commencer" → ecran inscription

**Commentaire** : _____________________________

## S1-02 : Inscription nouveau compte

- [ ] Champs visibles : Nom complet, Email, Mot de passe, Confirmer MDP, Telephone
- [ ] Validation : email invalide → message d'erreur
- [ ] Validation : MDP < 8 caracteres → message d'erreur
- [ ] Validation : MDP et confirmation differents → message d'erreur
- [ ] Inscription reussie → redirige vers Setup Wizard
- [ ] Lien "Deja un compte ? Se connecter" fonctionne

**Commentaire** : _____________________________

## S1-03 : Setup Wizard (configuration magasin)

- [ ] Etape 1 : Nom du magasin (obligatoire) + adresse + telephone
- [ ] Etape 2 : Devise (Ariary MGA par defaut) + arrondi de caisse
- [ ] Etape 3 : Langue (FR/MG)
- [ ] Etape 4 : Type de commerce (Epicerie, Restaurant, Boutique, Service, Autre)
- [ ] Barre de progression visible (4 etapes)
- [ ] Boutons Precedent/Suivant fonctionnent
- [ ] Tap "Terminer" → cree le magasin → redirige vers PIN setup

**Commentaire** : _____________________________

## S1-04 : Configuration PIN (premier lancement)

- [ ] Ecran affiche avatar + nom de l'utilisateur
- [ ] Message "Creez votre code PIN" visible
- [ ] Clavier numerique (0-9) fonctionnel
- [ ] 4 indicateurs ronds (se remplissent en tapant)
- [ ] Apres 4 chiffres → passe a "Confirmez votre code PIN"
- [ ] PIN confirme identique → redirige vers ecran Caisse (POS)
- [ ] PIN confirme different → message d'erreur + reset
- [ ] Bouton backspace fonctionne

**Commentaire** : _____________________________

## S1-05 : Connexion existante (email)

- [ ] Ecran login visible : email + mot de passe
- [ ] Connexion reussie → redirige vers ecran PIN
- [ ] Email invalide → message d'erreur
- [ ] MDP incorrect → message d'erreur
- [ ] Lien "Mot de passe oublie" visible et cliquable

**Commentaire** : _____________________________

## S1-06 : Ecran PIN (reconnexion)

- [ ] Affiche la liste des employes du magasin (avatars + noms)
- [ ] Tap sur employe → clavier PIN apparait
- [ ] PIN correct → acces a la Caisse
- [ ] PIN incorrect → message d'erreur
- [ ] Lien "Connexion email" visible pour les admins

**Commentaire** : _____________________________

## S1-07 : Navigation principale (Bottom Navigation)

- [ ] 5 onglets visibles en bas : Caisse, Produits, Clients, Rapports, Reglages
- [ ] Tap "Caisse" → ecran POS
- [ ] Tap "Produits" → liste des produits
- [ ] Tap "Clients" → liste des clients
- [ ] Tap "Rapports" → placeholder "Les rapports arrivent bientot"
- [ ] Tap "Reglages" → ecran reglages avec "Types de paiement"
- [ ] L'onglet actif est visuellement distinct (icone remplie)
- [ ] Navigation conserve l'etat de chaque onglet (ex: scroll position)

**Commentaire** : _____________________________

## S1-08 : Mot de passe oublie

- [ ] Champ email visible
- [ ] Tap "Envoyer le lien" → message de confirmation
- [ ] Email invalide → message d'erreur
- [ ] Lien "Retour a la connexion" fonctionne

**Commentaire** : _____________________________

---

# SPRINT 2 — POS & Produits

## S2-01 : Gestion produits — Creer un produit simple

- [ ] Onglet "Produits" → liste vide → message "Aucun produit"
- [ ] Bouton "+" (FAB) visible en bas a droite
- [ ] Tap "+" → formulaire creation produit
- [ ] Champs : Nom, Prix, Cout, SKU, Code-barres, Categorie
- [ ] Creer "Riz Basmati" : prix 15 000, cout 10 000, stock 100
- [ ] Sauvegarder → retour a la liste → produit visible
- [ ] Photo du produit : test upload (optionnel)
- [ ] Prix en Ariary (int, pas de decimales)

**Commentaire** : _____________________________

## S2-02 : Gestion produits — Modifier un produit

- [ ] Tap sur "Riz Basmati" dans la liste → formulaire d'edition
- [ ] Modifier le prix de 15 000 → 16 000
- [ ] Sauvegarder → retour a la liste → prix mis a jour
- [ ] Verifier que le stock n'a pas change (toujours 100)

**Commentaire** : _____________________________

## S2-03 : Gestion produits — Recherche et filtres

- [ ] Barre de recherche visible
- [ ] Taper "riz" → seul "Riz Basmati" apparait
- [ ] Effacer → tous les produits reapparaissent
- [ ] Filtre par categorie → fonctionne
- [ ] Filtre par stock (Tous / Stock bas / Rupture) → fonctionne

**Commentaire** : _____________________________

## S2-04 : Gestion categories

- [ ] Creer categorie "Epicerie" (couleur verte)
- [ ] Creer categorie "Condiments" (couleur ambre)
- [ ] Assigner produits aux categories
- [ ] Verifier le nombre de produits par categorie

**Commentaire** : _____________________________

## S2-05 : Import produits CSV

- [ ] Onglet Produits → bouton Import visible
- [ ] Tap → ecran import
- [ ] Telecharger le template CSV
- [ ] Importer un CSV valide (3 produits) → tous crees
- [ ] Importer un CSV avec erreurs → messages d'erreurs visibles
- [ ] Importer CSV avec SKU en double → avertissement

**Commentaire** : _____________________________

## S2-06 : Ecran Caisse — Affichage produits

- [ ] Onglet "Caisse" → grille de produits visible
- [ ] Si aucun produit : message "Chargement des produits..." puis liste vide
- [ ] Si produits crees : grille avec photo, nom, prix
- [ ] Barre de recherche fonctionne
- [ ] Filtre par categorie (dropdown "Toutes") fonctionne

**Commentaire** : _____________________________

## S2-07 : Ecran Caisse — Panier

- [ ] Tap sur un produit → ajoute au panier
- [ ] Panier affiche : nom, qte, prix unitaire, total ligne
- [ ] Boutons +/- pour modifier la quantite
- [ ] Swipe pour supprimer un article
- [ ] Total se recalcule en temps reel
- [ ] Bouton "Payer" visible avec le montant total

**Commentaire** : _____________________________

## S2-08 : Ecran Caisse — Remise

- [ ] Appliquer remise sur un article (% ou montant fixe)
- [ ] Appliquer remise sur tout le panier
- [ ] Total recalcule correctement apres remise
- [ ] Remise visible dans le detail du panier

**Commentaire** : _____________________________

## S2-09 : Ecran Caisse — Scanner barcode

- [ ] Bouton scan (icone QR) dans l'AppBar
- [ ] Tap → camera s'ouvre pour scanner
- [ ] Scanner un code-barres → produit ajoute automatiquement au panier
- [ ] Code-barres inconnu → message "Produit non trouve"

**Commentaire** : _____________________________

## S2-10 : Paiement — Especes

- [ ] Panier avec 3 produits → tap "Payer"
- [ ] Ecran de paiement : montant total affiche
- [ ] Boutons montants suggeres (2000, 5000, 10000, 20000, 50000 Ar)
- [ ] Tap 50 000 Ar pour un total de 35 000 Ar → monnaie = 15 000 Ar
- [ ] Saisie manuelle du montant → monnaie recalculee
- [ ] Confirmer → vente enregistree → retour Caisse

**Commentaire** : _____________________________

## S2-11 : Paiement — Mobile Money (MVola)

- [ ] Selectionner MVola comme moyen de paiement
- [ ] Verification deep link (ouvre app MVola si installee)
- [ ] Si pas d'app → fallback USSD (*812#)
- [ ] Saisir reference transaction → validation format
- [ ] Confirmer → vente enregistree

**Commentaire** : _____________________________

## S2-12 : Paiement — Mobile Money (Orange Money)

- [ ] Selectionner Orange Money
- [ ] Verification deep link
- [ ] Si pas d'app → fallback USSD (#144#)
- [ ] Saisir reference → confirmer → vente enregistree

**Commentaire** : _____________________________

## S2-13 : Paiement — Split (multi-methodes)

- [ ] Total 75 000 Ar
- [ ] Payer 50 000 en Especes + 25 000 en Carte
- [ ] Affichage "Paye / Restant" en temps reel
- [ ] Impossible de confirmer si montant total < total du
- [ ] Confirmer → vente enregistree avec 2 paiements

**Commentaire** : _____________________________

## S2-14 : Recu / Ticket de caisse

- [ ] Apres paiement → option "Imprimer" / "WhatsApp" / "PDF"
- [ ] PDF : logo, nom magasin, N recu, date, articles, total, paiement, monnaie
- [ ] WhatsApp : texte formate lisible
- [ ] Numero de recu unique et sequentiel (format YYYYMMDD-0001)
- [ ] 3 ventes le meme jour → numeros 0001, 0002, 0003

**Commentaire** : _____________________________

## S2-15 : Historique des ventes

- [ ] Menu "..." → "Historique" (depuis ecran Caisse)
- [ ] Liste des ventes : numero, heure, articles, total, moyen de paiement
- [ ] Filtres : Aujourd'hui / Cette semaine / Tout
- [ ] Tap sur une vente → detail du recu
- [ ] Recherche par numero de recu fonctionne

**Commentaire** : _____________________________

## S2-16 : Vente hors-ligne (offline-first)

- [ ] Couper le WiFi sur le telephone
- [ ] Creer une vente complete (produit + paiement especes)
- [ ] Vente enregistree localement (pas d'erreur)
- [ ] Verifier dans l'historique : badge "Non synchronise"
- [ ] Reactiver le WiFi → attendre quelques secondes
- [ ] Badge disparait (synchronisation effectuee)
- [ ] Verifier sur Supabase que la vente est presente

**Commentaire** : _____________________________

## S2-17 : Stock decremente apres vente

- [ ] Verifier stock "Riz Basmati" = 100
- [ ] Vendre 5 unites de Riz Basmati
- [ ] Retour onglet Produits → stock = 95
- [ ] Verifier dans l'historique inventaire : mouvement "-5, raison: sale"

**Commentaire** : _____________________________

---

# SPRINT 3 — Inventaire & Remboursements

## S3-01 : Clients — Creer un client

- [ ] Onglet "Clients" → liste vide → "Aucun client"
- [ ] Bouton "+" → formulaire client
- [ ] Creer "Jean Rakoto" (034 12 345 67)
- [ ] Creer "Marie Rasoa" (033 98 765 43)
- [ ] Retour liste → 2 clients visibles
- [ ] Recherche "Jean" → seul Jean apparait

**Commentaire** : _____________________________

## S3-02 : Clients — Detail client

- [ ] Tap sur "Jean Rakoto" → ecran detail
- [ ] Onglets : Historique achats + Credits
- [ ] Info : nom, telephone, email
- [ ] Si aucun achat : message vide

**Commentaire** : _____________________________

## S3-03 : Vente a credit

- [ ] Ecran Caisse → ajouter produits au panier
- [ ] Tap "Payer" → selectionner "Credit" comme moyen de paiement
- [ ] Selectionner client "Jean Rakoto"
- [ ] Choisir echeance : 7 jours
- [ ] Confirmer → vente enregistree en credit
- [ ] Onglet Clients → Jean → onglet Credits → credit visible (statut "En attente")

**Commentaire** : _____________________________

## S3-04 : Paiement credit partiel

- [ ] Aller dans Credits (Clients → Credits)
- [ ] Tap sur le credit de Jean (150 000 Ar)
- [ ] Payer partiellement : 60 000 Ar
- [ ] Statut passe a "Partiel"
- [ ] Restant : 90 000 Ar affiche correctement

**Commentaire** : _____________________________

## S3-05 : Paiement credit total

- [ ] Tap sur le credit de Jean (restant 90 000 Ar)
- [ ] Payer le solde : 90 000 Ar
- [ ] Statut passe a "Paye"
- [ ] Restant : 0 Ar

**Commentaire** : _____________________________

## S3-06 : Liste des credits

- [ ] Route Clients → Credits
- [ ] Cartes resume : total impaye, nombre en retard
- [ ] Filtres : Tous / En attente / Partiel / Paye / En retard
- [ ] Chaque credit montre : client, total, paye, restant, echeance, statut

**Commentaire** : _____________________________

## S3-07 : Remboursement complet

- [ ] Creer une vente : Riz x10 = 150 000 Ar (stock 95 → 85)
- [ ] Historique → tap sur la vente → tap "Rembourser"
- [ ] "Tout rembourser" → selectionne tous les articles
- [ ] Raison : "Defectueux" → Confirmer
- [ ] Vente marquee "Remboursee" (badge rouge)
- [ ] Stock restaure : 85 → 95
- [ ] Impossible de rembourser a nouveau (bouton desactive)

**Commentaire** : _____________________________

## S3-08 : Remboursement partiel

- [ ] Creer une vente : Riz x5 + Huile x3 = 111 000 Ar
- [ ] Historique → tap vente → tap "Rembourser"
- [ ] Selectionner seulement Riz x3 → montant = 45 000 Ar
- [ ] Raison : "Erreur" → Confirmer
- [ ] Badge "Partiellement rembourse" (orange)
- [ ] Stock Riz restaure de 3 unites

**Commentaire** : _____________________________

## S3-09 : Remboursement hors-ligne

- [ ] Couper le WiFi
- [ ] Rembourser une vente existante
- [ ] Pas d'erreur → badge "Non synchronise"
- [ ] Reactiver WiFi → synchronisation auto

**Commentaire** : _____________________________

## S3-10 : Vue d'ensemble stock (inventaire)

- [ ] Onglet Produits → naviguer vers Inventaire (si lien disponible)
- [ ] OU route `/inventory`
- [ ] Metriques : ruptures (rouge), stock bas (ambre), valeur totale
- [ ] Liste triee par urgence : rupture → stock bas → OK
- [ ] Couleurs : rouge (0), ambre (< seuil), vert (OK)
- [ ] Filtre "Stock bas" → seuls les produits a seuil bas apparaissent

**Commentaire** : _____________________________

## S3-11 : Ajustement de stock

- [ ] Inventaire → Ajustements → Nouveau
- [ ] Raison : "Reception" (livraison fournisseur)
- [ ] Ajouter "Sucre Blanc" → +50 unites
- [ ] Stock affiche : avant 25, apres 75
- [ ] Confirmer → stock mis a jour
- [ ] Historique inventaire : mouvement "+50, raison: adjustment"

**Commentaire** : _____________________________

## S3-12 : Ajustement de stock — Perte

- [ ] Nouveau ajustement → raison "Perte"
- [ ] Ajouter "Farine T55" → -3 unites
- [ ] Stock : avant 10, apres 7
- [ ] Confirmer → stock decremente

**Commentaire** : _____________________________

## S3-13 : Liste des ajustements

- [ ] Inventaire → Ajustements → liste visible
- [ ] Chaque ajustement : date, raison (badge), nb articles, employe
- [ ] Filtre par raison → fonctionne
- [ ] Tap sur un ajustement → detail des articles ajustes

**Commentaire** : _____________________________

## S3-14 : Comptage physique (inventaire complet)

- [ ] Inventaire → Comptages → Nouveau
- [ ] Type : "Comptage complet"
- [ ] Tous les produits avec suivi stock listes
- [ ] Compter Riz : attendu 95, compte 93 → difference -2 (rouge)
- [ ] Compter Sucre : attendu 75, compte 77 → difference +2 (vert)
- [ ] Barre de progression "X / Y articles comptes"
- [ ] Terminer → resume des differences
- [ ] "Appliquer les ajustements" → stock corrige

**Commentaire** : _____________________________

## S3-15 : Comptage physique — Reprise

- [ ] Demarrer un comptage
- [ ] Compter 2 articles sur 5
- [ ] Quitter l'ecran (retour)
- [ ] Revenir dans Comptages → statut "En cours"
- [ ] Tap → reprendre avec les valeurs sauvegardees

**Commentaire** : _____________________________

## S3-16 : Comptage partiel (par categorie)

- [ ] Nouveau comptage → Type "Partiel"
- [ ] Selectionner categorie "Condiments"
- [ ] Seuls Farine et Sel listes
- [ ] Compter → Terminer → Ajuster

**Commentaire** : _____________________________

## S3-17 : Export inventaire Excel

- [ ] Inventaire → bouton Export
- [ ] Choisir "Excel"
- [ ] Fichier genere : colonnes Nom, SKU, Categorie, Stock, Seuil, Cout, Valeur
- [ ] Resume en bas : total produits, ruptures, stock bas, valeur totale
- [ ] Partager via Share sheet du telephone
- [ ] Ouvrir dans Google Sheets → pas de probleme d'encodage

**Commentaire** : _____________________________

## S3-18 : Export inventaire PDF

- [ ] Inventaire → bouton Export → "PDF"
- [ ] PDF formate : en-tete magasin, metriques colorees, tableau
- [ ] Footer "Generated by POS Madagascar"
- [ ] Partager via Share sheet

**Commentaire** : _____________________________

## S3-19 : Export hors-ligne

- [ ] Couper le WiFi
- [ ] Exporter Excel → fonctionne (donnees locales)
- [ ] Exporter PDF → fonctionne

**Commentaire** : _____________________________

---

# TESTS TRANSVERSAUX

## TX-01 : Persistance des donnees

- [ ] Creer des donnees (produits, ventes, clients)
- [ ] Fermer completement l'app (force close)
- [ ] Rouvrir → toutes les donnees presentes
- [ ] Redemarrer le telephone → toutes les donnees presentes

**Commentaire** : _____________________________

## TX-02 : Mode hors-ligne complet

- [ ] Couper le WiFi
- [ ] Creer un produit → OK
- [ ] Creer une vente → OK
- [ ] Creer un client → OK
- [ ] Faire un remboursement → OK
- [ ] Faire un ajustement stock → OK
- [ ] Reactiver WiFi → tout se synchronise

**Commentaire** : _____________________________

## TX-03 : Montants en Ariary

- [ ] Tous les prix affiches en nombres entiers (pas de decimales)
- [ ] Format : separateur de milliers (15 000 pas 15000)
- [ ] Symbole "Ar" present la ou attendu
- [ ] Pas de centimes nulle part

**Commentaire** : _____________________________

## TX-04 : Localisation FR / MG

- [ ] App en Francais : tous les textes en FR
- [ ] Changer langue en Malagasy (si toggle disponible)
- [ ] Verifier que les textes changent en MG
- [ ] Aucune string hardcodee en Francais dans l'UI

**Commentaire** : _____________________________

## TX-05 : Roles et permissions

- [ ] Connexion en tant qu'OWNER → acces a tout
- [ ] Connexion en tant que CASHIER → acces limite a la Caisse
- [ ] CASHIER ne peut PAS acceder aux Reglages
- [ ] CASHIER ne peut PAS supprimer de produits (si permission desactivee)

**Commentaire** : _____________________________

---

# RESUME DES RESULTATS

| Sprint | Tests OK | Tests KO | Bugs trouves |
|--------|----------|----------|--------------|
| Sprint 1 (S1-01 a S1-08) | /8 | /8 | |
| Sprint 2 (S2-01 a S2-17) | /17 | /17 | |
| Sprint 3 (S3-01 a S3-19) | /19 | /19 | |
| Transversaux (TX-01 a TX-05) | /5 | /5 | |
| **TOTAL** | **/49** | **/49** | |

## Bugs trouves

| # | Severite | Sprint | Test | Description |
|---|----------|--------|------|-------------|
| 1 | P0/P1/P2 | | | |
| 2 | | | | |
| 3 | | | | |

## Notes generales

_____________________________
_____________________________
_____________________________

---

*Genere le 26 mars 2026 — POS Madagascar v0.3*
