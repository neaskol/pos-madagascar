# Guide de Test Manuel - Sprint 1

## Prérequis
- Simulateur iOS ou macOS lancé
- Application buildée et lancée avec `flutter run`
- Connexion Internet active (pour tests online)

---

## Test 1 : Splash Screen → Onboarding

### Actions
1. Lancer l'application
2. Observer le **Splash Screen**
   - Logo POS Madagascar
   - Tagline "Vendez depuis votre téléphone, même sans internet"
   - Transition automatique après ~2s

3. **Onboarding** doit apparaître avec 3 slides :
   - Slide 1 : "Vendez depuis votre téléphone"
   - Slide 2 : "Fonctionne sans internet"
   - Slide 3 : "MVola & Orange Money inclus"

### Vérifications
- [ ] Splash s'affiche correctement
- [ ] Transition automatique vers Onboarding
- [ ] Les 3 slides sont visibles
- [ ] Bouton "Passer" fonctionne
- [ ] Bouton "Suivant" change de slide
- [ ] Bouton "Commencer" sur la dernière slide

### Résultat
✅ **Succès** | ❌ **Échec** | ⚠️ **Problème**

**Notes** :

---

## Test 2 : Inscription (Register)

### Actions
1. Depuis Onboarding, cliquer sur "Commencer"
2. Cliquer sur "Créer un compte"
3. Remplir le formulaire :
   - Nom complet : "Test User"
   - Email : "test@example.com"
   - Mot de passe : "Test123456"
   - Confirmation : "Test123456"
   - Téléphone (optionnel) : "+261 34 12 345 67"

4. Cliquer sur "Créer mon compte"

### Vérifications
- [ ] Validation email (format correct)
- [ ] Validation mot de passe (longueur minimale)
- [ ] Confirmation mot de passe matchée
- [ ] Messages d'erreur clairs si validation échoue
- [ ] Bouton "Se connecter" redirige vers Login
- [ ] Compte créé dans Supabase

### Résultat
✅ **Succès** | ❌ **Échec** | ⚠️ **Problème**

**Notes** :

---

## Test 3 : Setup Wizard (Création Magasin)

### Actions
Après inscription réussie, le Setup Wizard doit apparaître :

#### Étape 1 : Informations du magasin
- Nom : "Boutique Test"
- Adresse (optionnel) : "Antananarivo"
- Téléphone (optionnel) : "+261 34 12 345 67"

#### Étape 2 : Devise et arrondi
- Devise : MGA (Ariary)
- Arrondi caisse : 50 Ar

#### Étape 3 : Langues
- Langue principale : Français
- Langue secondaire : Malagasy

#### Étape 4 : Type de commerce
- Sélectionner un type (ex: "Épicerie")

#### Finaliser
- Cliquer sur "Terminer la configuration"

### Vérifications
- [ ] Navigation entre les 4 étapes fonctionne
- [ ] Bouton "Précédent" et "Suivant" fonctionnels
- [ ] Validation des champs requis
- [ ] Magasin créé dans Supabase
- [ ] Magasin sauvegardé localement (Drift)
- [ ] Utilisateur devient OWNER du magasin

### Résultat
✅ **Succès** | ❌ **Échec** | ⚠️ **Problème**

**Notes** :

---

## Test 4 : Connexion (Login)

### Actions
1. Démarrer l'application (déjà inscrit)
2. Aller sur l'écran Login
3. Remplir :
   - Email : "test@example.com"
   - Mot de passe : "Test123456"
4. Cliquer sur "Se connecter"

### Vérifications
- [ ] Validation email et mot de passe
- [ ] Messages d'erreur si credentials invalides
- [ ] Toggle "Afficher/Masquer mot de passe" fonctionne
- [ ] Connexion réussie
- [ ] Données utilisateur chargées depuis Supabase
- [ ] Données utilisateur sauvegardées localement

### Résultat
✅ **Succès** | ❌ **Échec** | ⚠️ **Problème**

**Notes** :

---

## Test 5 : Écran PIN (Multi-utilisateurs)

### Actions
1. Après connexion, l'écran PIN doit apparaître
2. Observer la grille d'employés :
   - L'utilisateur OWNER doit être affiché
   - Photo, nom, rôle visible

3. Cliquer sur un employé
4. Entrer un PIN à 4 chiffres (ex: 1234)
5. Valider

### Vérifications
- [ ] Grille d'employés affichée
- [ ] Pavé numérique à 4 chiffres fonctionne
- [ ] Validation PIN
- [ ] Message d'erreur si PIN incorrect
- [ ] Connexion réussie si PIN correct
- [ ] Session PIN active

### Résultat
✅ **Succès** | ❌ **Échec** | ⚠️ **Problème**

**Notes** :

---

## Test 6 : Mode Offline

### Actions
1. Couper le WiFi/Internet
2. Relancer l'application
3. Tenter de se connecter avec PIN
4. Vérifier que les données locales sont accessibles

### Vérifications
- [ ] Application démarre offline
- [ ] Login PIN fonctionne offline
- [ ] Données locales (Drift) accessibles
- [ ] Aucune erreur de connexion réseau affichée
- [ ] Messages offline appropriés

### Résultat
✅ **Succès** | ❌ **Échec** | ⚠️ **Problème**

**Notes** :

---

## Test 7 : Synchronisation Online → Offline → Online

### Actions
1. Créer des données online (nouveau compte, magasin)
2. Vérifier que les données sont dans Drift
3. Passer offline
4. Vérifier que les données sont toujours accessibles
5. Revenir online
6. Vérifier la synchronisation

### Vérifications
- [ ] Données online → Drift sauvegardées
- [ ] Données accessibles offline
- [ ] Synchronisation au retour online
- [ ] Champ `synced` mis à jour correctement

### Résultat
✅ **Succès** | ❌ **Échec** | ⚠️ **Problème**

**Notes** :

---

## Test 8 : Localisation FR/MG

### Actions
1. Changer la langue système en Français
2. Relancer l'app, vérifier les textes en français
3. Changer la langue système en Malagasy
4. Relancer l'app, vérifier les textes en malagasy

### Vérifications
- [ ] Tous les textes en français corrects
- [ ] Tous les textes en malagasy corrects
- [ ] Aucun texte hardcodé visible
- [ ] Format des montants en Ariary (1 500 Ar)

### Résultat
✅ **Succès** | ❌ **Échec** | ⚠️ **Problème**

**Notes** :

---

## Bugs et Issues Découverts

| # | Écran | Sévérité | Description | Action |
|---|-------|----------|-------------|--------|
| 1 |  | ⚠️ / 🔴 |  |  |
| 2 |  | ⚠️ / 🔴 |  |  |

---

## Résumé Final

### Tests Réussis : __ / 8

### Sprint 1 Validation : ✅ **VALIDÉ** | ❌ **BLOQUÉ**

### Actions avant Sprint 2 :
1.
2.
3.
