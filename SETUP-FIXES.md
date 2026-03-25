# Correctifs à appliquer — POS Madagascar

## Résumé des problèmes identifiés

1. ✅ **Bouton "S'inscrire" grisé** → Corrigé (texte + état)
2. ✅ **Lien "Mot de passe oublié" non fonctionnel** → Corrigé (écran + navigation)
3. 🔴 **Erreur PostgreSQL RLS** → Nécessite action manuelle dans Supabase
4. 🔴 **Email de confirmation vers localhost** → Nécessite config Supabase
5. ⚠️ **Upload logo non implémenté** → Feature à venir

---

## 1. ✅ Bouton "S'inscrire" - CORRIGÉ

**Problème**: Le bouton dans l'écran de login affichait "Se connecter" au lieu de "S'inscrire"

**Solution appliquée**:
- Ajout de la clé de traduction `loginSignUp` dans `app_fr.arb` et `app_mg.arb`
- Modification de [login_screen.dart:266](lib/features/auth/presentation/screens/login_screen.dart#L266) pour utiliser `l10n.loginSignUp`
- Localisations régénérées

---

## 2. ✅ Lien "Mot de passe oublié" - CORRIGÉ

**Problème**: Le lien "Mot de passe oublié ?" ne faisait rien (TODO vide)

**Solution appliquée**:
- Création de [forgot_password_screen.dart](lib/features/auth/presentation/screens/forgot_password_screen.dart)
- Ajout de la route `/forgot-password` dans [app_router.dart](lib/core/router/app_router.dart)
- Navigation configurée dans [login_screen.dart:186](lib/features/auth/presentation/screens/login_screen.dart#L186)
- Traductions ajoutées (FR + MG):
  - `forgotPasswordTitle`: "Mot de passe oublié"
  - `forgotPasswordDescription`: Instructions
  - `forgotPasswordSubmit`: "Envoyer le lien"
  - `forgotPasswordEmailSent`: Message de confirmation
  - `forgotPasswordBackToLogin`: "Retour à la connexion"

**Fonctionnement**:
1. L'utilisateur clique sur "Mot de passe oublié ?"
2. Il entre son email
3. Supabase envoie un email avec un lien de réinitialisation
4. Message de confirmation affiché pendant 5 secondes
5. Retour automatique à l'écran de login

---

## 3. 🔴 Erreur PostgreSQL RLS - ACTION REQUISE

**Problème**:
```
PostgrestException(message: new row violates row-level security policy
for table "stores", code: 42501)
```

**Cause**: La policy RLS actuelle (`store_insert_service_role`) n'autorise QUE le service role à insérer des stores, mais l'app Flutter utilise un utilisateur authentifié normal lors du setup wizard.

**Solution**: Exécuter la migration SQL dans le dashboard Supabase

### ⚠️ ACTION MANUELLE REQUISE

1. Ouvrir le SQL Editor: https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls/sql/new

2. Coller et exécuter ce SQL:

```sql
-- ============================================================================
-- POS Madagascar — Fix Stores INSERT Policy
-- Migration: 20260325000008_fix_stores_insert_policy.sql
-- ============================================================================

-- Drop the old restrictive insert policy
DROP POLICY IF EXISTS "store_insert_service_role" ON stores;

-- Create new policy: authenticated users can insert stores
CREATE POLICY "store_insert_authenticated" ON stores
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() IS NOT NULL
  );

-- Automatically set created_by on INSERT
CREATE OR REPLACE FUNCTION set_store_created_by()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.created_by IS NULL THEN
    NEW.created_by := auth.uid();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply the trigger
DROP TRIGGER IF EXISTS trigger_set_store_created_by ON stores;
CREATE TRIGGER trigger_set_store_created_by
  BEFORE INSERT ON stores
  FOR EACH ROW
  EXECUTE FUNCTION set_store_created_by();

-- Comments
COMMENT ON POLICY "store_insert_authenticated" ON stores IS
  'Allows authenticated users to create a store during registration';
```

3. Cliquer sur **RUN** (ou Ctrl+Enter)

4. Vérifier le message de succès

**Fichier local**: La migration est aussi sauvegardée dans:
`supabase/migrations/20260325000008_fix_stores_insert_policy.sql`

---

## 4. 🔴 Email de confirmation vers localhost - ACTION REQUISE

**Problème**: Les emails de réinitialisation de mot de passe et de confirmation contiennent des liens vers `http://localhost:...`

**Cause**: Configuration par défaut de Supabase Auth pointe vers localhost

**Solution**: Configurer les URL de redirection dans le dashboard Supabase

### ⚠️ ACTION MANUELLE REQUISE

1. Ouvrir Auth URL Configuration: https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls/auth/url-configuration

2. **Site URL** - Choisir selon votre contexte:
   - **Mobile app uniquement**: `com.posmadagascar.app://`
   - **Web + Mobile**: `https://votre-domaine.com`
   - **Dev local temporaire**: `http://localhost:3000`

3. **Redirect URLs** - Ajouter ces lignes (une par ligne):
   ```
   com.posmadagascar.app://**
   http://localhost:3000/**
   ```

4. **Email Templates** (optionnel mais recommandé):
   - Aller dans Authentication > Email Templates
   - Template "Confirm signup":
     - Remplacer `{{ .ConfirmationURL }}` par un deep link mobile
     - Exemple: `com.posmadagascar.app://auth/confirm?token={{ .TokenHash }}&type=signup`

   - Template "Reset Password":
     - Remplacer `{{ .ConfirmationURL }}` par:
     - Exemple: `com.posmadagascar.app://auth/reset?token={{ .TokenHash }}&type=recovery`

5. Cliquer sur **Save**

### 📱 Deep Linking Flutter (à configurer plus tard)

Pour que les liens d'email ouvrent l'app:

**Android** - Modifier `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="com.posmadagascar.app" />
</intent-filter>
```

**iOS** - Modifier `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.posmadagascar.app</string>
    </array>
  </dict>
</array>
```

---

## 5. ⚠️ Logo upload non implémenté - FEATURE À VENIR

**Status**: TODO (ligne 296-298 de [setup_wizard_screen.dart](lib/features/auth/presentation/screens/setup_wizard_screen.dart#L296-L298))

**Prochaines étapes**:

1. **Créer le bucket Supabase Storage**:
   - Dashboard > Storage > Create bucket
   - Nom: `store-logos`
   - Public: Oui

2. **Configurer les policies RLS**:
   ```sql
   -- Permettre aux utilisateurs authentifiés d'uploader leur logo
   CREATE POLICY "Users can upload their store logo"
   ON storage.objects FOR INSERT
   TO authenticated
   WITH CHECK (
     bucket_id = 'store-logos' AND
     auth.uid()::text = (storage.foldername(name))[1]
   );

   -- Permettre la lecture publique des logos
   CREATE POLICY "Public can view store logos"
   ON storage.objects FOR SELECT
   TO public
   USING (bucket_id = 'store-logos');
   ```

3. **Ajouter le package Flutter**:
   ```yaml
   dependencies:
     image_picker: ^1.0.7
   ```

4. **Implémenter l'upload** dans setup_wizard_screen.dart

---

## ✅ Checklist des actions

### Corrections automatiques (déjà faites)
- [x] Bouton "S'inscrire" - texte corrigé
- [x] Écran "Mot de passe oublié" créé
- [x] Route `/forgot-password` ajoutée
- [x] Traductions FR + MG ajoutées
- [x] Migration RLS créée (fichier local)

### Actions manuelles requises AVANT le rebuild
- [ ] **CRITIQUE**: Exécuter la migration RLS dans Supabase SQL Editor (3 min)
- [ ] **IMPORTANT**: Configurer les URL de redirection dans Auth settings (5 min)

### Features futures (pas bloquant)
- [ ] Configurer deep linking Flutter (Android + iOS)
- [ ] Implémenter upload de logo avec Supabase Storage

---

## 🚀 Rebuild de l'APK

**Une fois les 2 actions manuelles terminées**, reconstruire l'APK:

```bash
cd "/Users/neaskol/Downloads/AGENTIC WORKFLOW/POS"

# Nettoyer
flutter clean

# Restaurer les dépendances
flutter pub get

# Générer les fichiers Drift
dart run build_runner build --delete-conflicting-outputs

# Build APK release
flutter build apk --release
```

**APK final**: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📋 Test du flow complet après rebuild

1. **Inscription**:
   - Cliquer sur "S'inscrire" (doit afficher le bon texte)
   - Remplir le formulaire
   - Vérifier l'email de confirmation (doit pointer vers la bonne URL)

2. **Mot de passe oublié**:
   - Cliquer sur "Mot de passe oublié ?"
   - Entrer un email
   - Vérifier l'email de reset (doit pointer vers la bonne URL)

3. **Setup wizard**:
   - Remplir les 4 étapes
   - Cliquer sur "Terminer"
   - **Ne doit PLUS avoir l'erreur PostgreSQL RLS**
   - Doit créer le magasin et rediriger vers l'écran PIN

4. **Connexion**:
   - Se déconnecter
   - Se reconnecter avec email/password
   - Doit rediriger vers l'écran PIN
   - Entrer le PIN
   - Doit accéder à l'écran POS

---

## 🐛 En cas de problème

**Erreur RLS persiste après migration**:
- Vérifier que la migration a bien été exécutée dans le SQL Editor
- Vérifier les policies avec: `SELECT * FROM pg_policies WHERE tablename = 'stores';`

**Emails pointent toujours vers localhost**:
- Vérifier Auth > URL Configuration dans le dashboard
- Attendre 1-2 minutes pour la propagation des changements
- Tester en créant un nouveau compte

**Bouton "S'inscrire" toujours grisé**:
- Vérifier que `flutter gen-l10n` a été exécuté
- Rebuild complet avec `flutter clean && flutter pub get`
