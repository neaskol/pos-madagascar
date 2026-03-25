import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';
import 'app_localizations_mg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('mg'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'POS Madagascar'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Vendez depuis votre téléphone, même sans internet'**
  String get appTagline;

  /// No description provided for @onboardingTitle1.
  ///
  /// In fr, this message translates to:
  /// **'Vendez depuis votre téléphone'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In fr, this message translates to:
  /// **'Une caisse complète dans votre poche. Pas besoin d\'équipement coûteux.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionne sans internet'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In fr, this message translates to:
  /// **'Vendez même hors ligne. Tout se synchronise automatiquement quand vous êtes connecté.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In fr, this message translates to:
  /// **'MVola & Orange Money inclus'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In fr, this message translates to:
  /// **'Acceptez les paiements mobiles directement dans votre caisse.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// No description provided for @onboardingStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingStart;

  /// No description provided for @onboardingNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboardingNext;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @loginEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @loginForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get loginForgotPassword;

  /// No description provided for @loginCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get loginCreateAccount;

  /// No description provided for @loginShowPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get loginHidePassword;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get registerTitle;

  /// No description provided for @registerName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get registerName;

  /// No description provided for @registerEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get registerPassword;

  /// No description provided for @registerPasswordConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get registerPasswordConfirm;

  /// No description provided for @registerPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone (optionnel)'**
  String get registerPhone;

  /// No description provided for @registerButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get registerHaveAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get registerSignIn;

  /// No description provided for @setupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Configuration du magasin'**
  String get setupTitle;

  /// No description provided for @setupStep1Title.
  ///
  /// In fr, this message translates to:
  /// **'Informations du magasin'**
  String get setupStep1Title;

  /// No description provided for @setupStep2Title.
  ///
  /// In fr, this message translates to:
  /// **'Devise et arrondi'**
  String get setupStep2Title;

  /// No description provided for @setupStep3Title.
  ///
  /// In fr, this message translates to:
  /// **'Langues'**
  String get setupStep3Title;

  /// No description provided for @setupStep4Title.
  ///
  /// In fr, this message translates to:
  /// **'Type de commerce'**
  String get setupStep4Title;

  /// No description provided for @setupStoreName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du magasin'**
  String get setupStoreName;

  /// No description provided for @setupStoreAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse (optionnel)'**
  String get setupStoreAddress;

  /// No description provided for @setupStorePhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone (optionnel)'**
  String get setupStorePhone;

  /// No description provided for @setupUploadLogo.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un logo'**
  String get setupUploadLogo;

  /// No description provided for @setupCurrency.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get setupCurrency;

  /// No description provided for @setupCashRounding.
  ///
  /// In fr, this message translates to:
  /// **'Arrondi de caisse'**
  String get setupCashRounding;

  /// No description provided for @setupCashRoundingNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get setupCashRoundingNone;

  /// No description provided for @setupCashRounding50.
  ///
  /// In fr, this message translates to:
  /// **'50 Ar'**
  String get setupCashRounding50;

  /// No description provided for @setupCashRounding100.
  ///
  /// In fr, this message translates to:
  /// **'100 Ar'**
  String get setupCashRounding100;

  /// No description provided for @setupCashRounding200.
  ///
  /// In fr, this message translates to:
  /// **'200 Ar'**
  String get setupCashRounding200;

  /// No description provided for @setupInterfaceLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'interface'**
  String get setupInterfaceLanguage;

  /// No description provided for @setupReceiptLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue des reçus'**
  String get setupReceiptLanguage;

  /// No description provided for @setupBusinessType.
  ///
  /// In fr, this message translates to:
  /// **'Type de commerce'**
  String get setupBusinessType;

  /// No description provided for @setupBusinessTypeGrocery.
  ///
  /// In fr, this message translates to:
  /// **'Épicerie / Superette'**
  String get setupBusinessTypeGrocery;

  /// No description provided for @setupBusinessTypeRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Restaurant / Café'**
  String get setupBusinessTypeRestaurant;

  /// No description provided for @setupBusinessTypeFashion.
  ///
  /// In fr, this message translates to:
  /// **'Boutique / Mode'**
  String get setupBusinessTypeFashion;

  /// No description provided for @setupBusinessTypeService.
  ///
  /// In fr, this message translates to:
  /// **'Service / Salon'**
  String get setupBusinessTypeService;

  /// No description provided for @setupBusinessTypeOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get setupBusinessTypeOther;

  /// No description provided for @setupPrevious.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get setupPrevious;

  /// No description provided for @setupNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get setupNext;

  /// No description provided for @setupFinish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get setupFinish;

  /// No description provided for @pinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Qui êtes-vous ?'**
  String get pinTitle;

  /// No description provided for @pinEnterCode.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre code PIN'**
  String get pinEnterCode;

  /// No description provided for @pinEmailLogin.
  ///
  /// In fr, this message translates to:
  /// **'Connexion avec email'**
  String get pinEmailLogin;

  /// No description provided for @pinIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN incorrect'**
  String get pinIncorrect;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get errorPasswordMismatch;

  /// No description provided for @errorFieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire'**
  String get errorFieldRequired;

  /// No description provided for @errorNetworkFailed.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet'**
  String get errorNetworkFailed;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sort;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @done.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get done;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr', 'mg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
    case 'mg':
      return AppLocalizationsMg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
