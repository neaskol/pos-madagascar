# Issue: APK Release Build échoue avec erreur CMake/NDK

**Date**: 2026-03-25
**Statut**: ⚠️ En attente de résolution

## Erreur
```
[CXX1429] error when building with cmake using CMakeLists.txt
Not searching for unused variables given on the command line.
```

## Cause
Incompatibilité entre :
- **NDK**: 28.2.13676358 (trop récent)
- **CMake**: 3.22.1
- **Flutter**: 3.x avec chemin contenant des espaces (`AGENTIC WORKFLOW`)

## Solutions possibles

### Solution 1: Downgrade NDK (Recommandé)
```bash
# Dans Android Studio > SDK Manager > SDK Tools
# Décocher NDK 28.x
# Installer NDK 25.x ou 26.x
```

### Solution 2: Upgrade CMake
```bash
# Dans Android Studio > SDK Manager > SDK Tools
# Installer CMake 3.28.x ou plus récent
```

### Solution 3: Renommer le dossier (Éviter espaces)
```bash
mv "/Users/neaskol/Downloads/AGENTIC WORKFLOW/POS" \
   "/Users/neaskol/Downloads/AGENTIC-WORKFLOW-POS"
```

### Solution 4: Utiliser APK Debug (Workaround temporaire)
```bash
flutter build apk --debug
# Fonctionne mais APK plus volumineux
```

### Solution 5: Build avec validation désactivée
```bash
flutter build apk --release --android-skip-build-dependency-validation
# À tester, peut contourner le problème
```

## Workaround appliqué
✅ Build APK debug en cours
❌ Build APK release à fixer plus tard

## Références
- [Flutter Issue #124031](https://github.com/flutter/flutter/issues/124031)
- [Android NDK r26 Breaking Changes](https://github.com/android/ndk/wiki/Changelog-r26)

## TODO
- [ ] Tester solution 5 (skip validation)
- [ ] Downgrade NDK si solution 5 échoue
- [ ] Ou renommer le dossier projet sans espaces
