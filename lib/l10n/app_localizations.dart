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

  /// No description provided for @loginSignUp.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get loginSignUp;

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

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre email et nous vous enverrons un lien pour réinitialiser votre mot de passe.'**
  String get forgotPasswordDescription;

  /// No description provided for @forgotPasswordSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get forgotPasswordSubmit;

  /// No description provided for @forgotPasswordEmailSent.
  ///
  /// In fr, this message translates to:
  /// **'Email envoyé ! Vérifiez votre boîte de réception.'**
  String get forgotPasswordEmailSent;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get forgotPasswordBackToLogin;

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

  /// No description provided for @setupStepIndicator.
  ///
  /// In fr, this message translates to:
  /// **'Étape {current} / {total}'**
  String setupStepIndicator(int current, int total);

  /// No description provided for @setupStoreNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer le nom du magasin'**
  String get setupStoreNameRequired;

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

  /// No description provided for @productsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get productsTitle;

  /// No description provided for @productsSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit'**
  String get productsSearch;

  /// No description provided for @productsFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get productsFilterAll;

  /// No description provided for @productsFilterLowStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock bas'**
  String get productsFilterLowStock;

  /// No description provided for @productsFilterOutOfStock.
  ///
  /// In fr, this message translates to:
  /// **'Rupture'**
  String get productsFilterOutOfStock;

  /// No description provided for @productsCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get productsCategory;

  /// No description provided for @productsAllCategories.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les catégories'**
  String get productsAllCategories;

  /// No description provided for @productsStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get productsStock;

  /// No description provided for @productsPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get productsPrice;

  /// No description provided for @productsNotAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Hors vente'**
  String get productsNotAvailable;

  /// No description provided for @productsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit'**
  String get productsEmptyTitle;

  /// No description provided for @productsEmptyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Commencez par ajouter vos premiers produits'**
  String get productsEmptyDescription;

  /// No description provided for @productsAddProduct.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un produit'**
  String get productsAddProduct;

  /// No description provided for @productsInStock.
  ///
  /// In fr, this message translates to:
  /// **'en stock'**
  String get productsInStock;

  /// No description provided for @productsLowStock.
  ///
  /// In fr, this message translates to:
  /// **'stock bas'**
  String get productsLowStock;

  /// No description provided for @productsOutOfStock.
  ///
  /// In fr, this message translates to:
  /// **'rupture'**
  String get productsOutOfStock;

  /// No description provided for @productFormNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau produit'**
  String get productFormNewTitle;

  /// No description provided for @productFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get productFormEditTitle;

  /// No description provided for @productFormSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get productFormSave;

  /// No description provided for @productFormDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get productFormDelete;

  /// No description provided for @productFormDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer ce produit ?'**
  String get productFormDeleteConfirm;

  /// No description provided for @productFormPhotoSection.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get productFormPhotoSection;

  /// No description provided for @productFormSelectPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une photo'**
  String get productFormSelectPhoto;

  /// No description provided for @productFormColorFallback.
  ///
  /// In fr, this message translates to:
  /// **'Ou choisir une couleur'**
  String get productFormColorFallback;

  /// No description provided for @productFormBasicSection.
  ///
  /// In fr, this message translates to:
  /// **'Informations de base'**
  String get productFormBasicSection;

  /// No description provided for @productFormName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du produit'**
  String get productFormName;

  /// No description provided for @productFormNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Coca-Cola 1.5L'**
  String get productFormNameHint;

  /// No description provided for @productFormNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire'**
  String get productFormNameRequired;

  /// No description provided for @productFormCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get productFormCategory;

  /// No description provided for @productFormNoCategory.
  ///
  /// In fr, this message translates to:
  /// **'Aucune catégorie'**
  String get productFormNoCategory;

  /// No description provided for @productFormDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get productFormDescription;

  /// No description provided for @productFormDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Description optionnelle du produit'**
  String get productFormDescriptionHint;

  /// No description provided for @productFormSKU.
  ///
  /// In fr, this message translates to:
  /// **'Code SKU'**
  String get productFormSKU;

  /// No description provided for @productFormSKUHint.
  ///
  /// In fr, this message translates to:
  /// **'Auto-généré si vide'**
  String get productFormSKUHint;

  /// No description provided for @productFormBarcode.
  ///
  /// In fr, this message translates to:
  /// **'Code-barre'**
  String get productFormBarcode;

  /// No description provided for @productFormBarcodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Scannez ou saisissez'**
  String get productFormBarcodeHint;

  /// No description provided for @productFormScanBarcode.
  ///
  /// In fr, this message translates to:
  /// **'Scanner'**
  String get productFormScanBarcode;

  /// No description provided for @productFormPricingSection.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get productFormPricingSection;

  /// No description provided for @productFormSalePrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente'**
  String get productFormSalePrice;

  /// No description provided for @productFormSalePriceHint.
  ///
  /// In fr, this message translates to:
  /// **'Prix en Ariary'**
  String get productFormSalePriceHint;

  /// No description provided for @productFormSalePriceRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le prix est obligatoire'**
  String get productFormSalePriceRequired;

  /// No description provided for @productFormCost.
  ///
  /// In fr, this message translates to:
  /// **'Coût d\'achat'**
  String get productFormCost;

  /// No description provided for @productFormCostHint.
  ///
  /// In fr, this message translates to:
  /// **'Coût en Ariary'**
  String get productFormCostHint;

  /// No description provided for @productFormCostPercentage.
  ///
  /// In fr, this message translates to:
  /// **'Coût en %'**
  String get productFormCostPercentage;

  /// No description provided for @productFormMargin.
  ///
  /// In fr, this message translates to:
  /// **'Marge'**
  String get productFormMargin;

  /// No description provided for @productFormMarginAmount.
  ///
  /// In fr, this message translates to:
  /// **'Marge'**
  String get productFormMarginAmount;

  /// No description provided for @productFormSalesSection.
  ///
  /// In fr, this message translates to:
  /// **'Vente'**
  String get productFormSalesSection;

  /// No description provided for @productFormAvailableForSale.
  ///
  /// In fr, this message translates to:
  /// **'Disponible à la vente'**
  String get productFormAvailableForSale;

  /// No description provided for @productFormSoldByWeight.
  ///
  /// In fr, this message translates to:
  /// **'Vendu au poids'**
  String get productFormSoldByWeight;

  /// No description provided for @productFormWeightUnit.
  ///
  /// In fr, this message translates to:
  /// **'Unité de poids'**
  String get productFormWeightUnit;

  /// No description provided for @productFormWeightUnitHint.
  ///
  /// In fr, this message translates to:
  /// **'kg, g, l, ml...'**
  String get productFormWeightUnitHint;

  /// No description provided for @productFormStockSection.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get productFormStockSection;

  /// No description provided for @productFormTrackStock.
  ///
  /// In fr, this message translates to:
  /// **'Suivre le stock'**
  String get productFormTrackStock;

  /// No description provided for @productFormCurrentStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock actuel'**
  String get productFormCurrentStock;

  /// No description provided for @productFormCurrentStockHint.
  ///
  /// In fr, this message translates to:
  /// **'Quantité en stock'**
  String get productFormCurrentStockHint;

  /// No description provided for @productFormLowStockThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Seuil d\'alerte stock bas'**
  String get productFormLowStockThreshold;

  /// No description provided for @productFormLowStockThresholdHint.
  ///
  /// In fr, this message translates to:
  /// **'Seuil par défaut : 10'**
  String get productFormLowStockThresholdHint;

  /// No description provided for @productFormTaxesSection.
  ///
  /// In fr, this message translates to:
  /// **'Taxes'**
  String get productFormTaxesSection;

  /// No description provided for @productFormNoTaxes.
  ///
  /// In fr, this message translates to:
  /// **'Aucune taxe configurée'**
  String get productFormNoTaxes;

  /// No description provided for @productFormSaved.
  ///
  /// In fr, this message translates to:
  /// **'Produit enregistré'**
  String get productFormSaved;

  /// No description provided for @productFormDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Produit supprimé'**
  String get productFormDeleted;

  /// No description provided for @posScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get posScreenTitle;

  /// No description provided for @clearTicket.
  ///
  /// In fr, this message translates to:
  /// **'Vider le ticket'**
  String get clearTicket;

  /// No description provided for @clearTicketConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vider le panier ?'**
  String get clearTicketConfirmation;

  /// No description provided for @saveTicket.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get saveTicket;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get comingSoon;

  /// No description provided for @searchProducts.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit'**
  String get searchProducts;

  /// No description provided for @allCategories.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get allCategories;

  /// No description provided for @noProducts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit disponible'**
  String get noProducts;

  /// No description provided for @addedToCart.
  ///
  /// In fr, this message translates to:
  /// **'ajouté au panier'**
  String get addedToCart;

  /// No description provided for @emptyCart.
  ///
  /// In fr, this message translates to:
  /// **'Panier vide'**
  String get emptyCart;

  /// No description provided for @subtotal.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total'**
  String get subtotal;

  /// No description provided for @total.
  ///
  /// In fr, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @pay.
  ///
  /// In fr, this message translates to:
  /// **'PAYER'**
  String get pay;

  /// No description provided for @scanBarcode.
  ///
  /// In fr, this message translates to:
  /// **'Scanner code-barres'**
  String get scanBarcode;

  /// No description provided for @scanBarcodeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un code-barres'**
  String get scanBarcodeTitle;

  /// No description provided for @scanBarcodeInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Placez le code-barres dans le cadre'**
  String get scanBarcodeInstructions;

  /// No description provided for @scanBarcodeFormats.
  ///
  /// In fr, this message translates to:
  /// **'EAN-13, EAN-8, UPC-A, Code 128, Code 39, QR'**
  String get scanBarcodeFormats;

  /// No description provided for @productsNotLoaded.
  ///
  /// In fr, this message translates to:
  /// **'Produits non chargés'**
  String get productsNotLoaded;

  /// No description provided for @productNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit trouvé avec le code: {barcode}'**
  String productNotFound(String barcode);

  /// No description provided for @selectVariant.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un variant'**
  String get selectVariant;

  /// No description provided for @selectModifiers.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les options'**
  String get selectModifiers;

  /// No description provided for @required.
  ///
  /// In fr, this message translates to:
  /// **'Obligatoire'**
  String get required;

  /// No description provided for @noVariantSelected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun variant sélectionné'**
  String get noVariantSelected;

  /// No description provided for @modifierRequired.
  ///
  /// In fr, this message translates to:
  /// **'Vous devez sélectionner une option obligatoire'**
  String get modifierRequired;

  /// No description provided for @addToCart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au panier'**
  String get addToCart;

  /// No description provided for @cartItemDiscounts.
  ///
  /// In fr, this message translates to:
  /// **'Remises items'**
  String get cartItemDiscounts;

  /// No description provided for @cartDiscount.
  ///
  /// In fr, this message translates to:
  /// **'Remise panier'**
  String get cartDiscount;

  /// No description provided for @cartTaxes.
  ///
  /// In fr, this message translates to:
  /// **'Taxes'**
  String get cartTaxes;

  /// No description provided for @cartQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get cartQuantity;

  /// No description provided for @cartItemRemoved.
  ///
  /// In fr, this message translates to:
  /// **'{name} retiré du panier'**
  String cartItemRemoved(String name);

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @paymentSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Paiement réussi'**
  String get paymentSuccess;

  /// No description provided for @receiptNumber.
  ///
  /// In fr, this message translates to:
  /// **'Reçu N° {number}'**
  String receiptNumber(String number);

  /// No description provided for @changeDue.
  ///
  /// In fr, this message translates to:
  /// **'Monnaie à rendre:'**
  String get changeDue;

  /// No description provided for @newSale.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle vente'**
  String get newSale;

  /// No description provided for @viewReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Voir reçu'**
  String get viewReceipt;

  /// No description provided for @allProducts.
  ///
  /// In fr, this message translates to:
  /// **'Tous les produits'**
  String get allProducts;

  /// No description provided for @customPages.
  ///
  /// In fr, this message translates to:
  /// **'Pages personnalisées'**
  String get customPages;

  /// No description provided for @createPage.
  ///
  /// In fr, this message translates to:
  /// **'Créer une page'**
  String get createPage;

  /// No description provided for @editPage.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la page'**
  String get editPage;

  /// No description provided for @deletePage.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la page'**
  String get deletePage;

  /// No description provided for @pageName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la page'**
  String get pageName;

  /// No description provided for @pageNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Boissons, Snacks, Promos...'**
  String get pageNameHint;

  /// No description provided for @pageCreated.
  ///
  /// In fr, this message translates to:
  /// **'Page créée'**
  String get pageCreated;

  /// No description provided for @pageUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Page mise à jour'**
  String get pageUpdated;

  /// No description provided for @pageDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Page supprimée'**
  String get pageDeleted;

  /// No description provided for @itemAlreadyOnPage.
  ///
  /// In fr, this message translates to:
  /// **'Cet item est déjà sur cette page'**
  String get itemAlreadyOnPage;

  /// No description provided for @itemAddedToPage.
  ///
  /// In fr, this message translates to:
  /// **'Item ajouté à la page'**
  String get itemAddedToPage;

  /// No description provided for @itemRemovedFromPage.
  ///
  /// In fr, this message translates to:
  /// **'Item retiré de la page'**
  String get itemRemovedFromPage;

  /// No description provided for @pageCleared.
  ///
  /// In fr, this message translates to:
  /// **'Page vidée'**
  String get pageCleared;

  /// No description provided for @confirmDeletePage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer cette page ?'**
  String get confirmDeletePage;

  /// No description provided for @cannotDeleteDefaultPage.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer la page par défaut'**
  String get cannotDeleteDefaultPage;

  /// No description provided for @customersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get customersTitle;

  /// No description provided for @customersSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un client'**
  String get customersSearch;

  /// No description provided for @customersEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client'**
  String get customersEmptyTitle;

  /// No description provided for @customersEmptyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos premiers clients pour suivre leurs achats et crédits'**
  String get customersEmptyDescription;

  /// No description provided for @customersAddCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un client'**
  String get customersAddCustomer;

  /// No description provided for @customerName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du client'**
  String get customerName;

  /// No description provided for @customerNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire'**
  String get customerNameRequired;

  /// No description provided for @customerPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get customerPhone;

  /// No description provided for @customerPhoneHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 034 12 345 67'**
  String get customerPhoneHint;

  /// No description provided for @customerEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get customerEmail;

  /// No description provided for @customerEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: client@email.com'**
  String get customerEmailHint;

  /// No description provided for @customerLoyaltyCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte de fidélité'**
  String get customerLoyaltyCard;

  /// No description provided for @customerNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get customerNotes;

  /// No description provided for @customerNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Notes sur le client'**
  String get customerNotesHint;

  /// No description provided for @customerCreated.
  ///
  /// In fr, this message translates to:
  /// **'Client créé'**
  String get customerCreated;

  /// No description provided for @customerUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Client mis à jour'**
  String get customerUpdated;

  /// No description provided for @customerDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Client supprimé'**
  String get customerDeleted;

  /// No description provided for @customerDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer ce client ?'**
  String get customerDeleteConfirm;

  /// No description provided for @customerTotalSpent.
  ///
  /// In fr, this message translates to:
  /// **'Total dépensé'**
  String get customerTotalSpent;

  /// No description provided for @customerTotalVisits.
  ///
  /// In fr, this message translates to:
  /// **'Visites'**
  String get customerTotalVisits;

  /// No description provided for @customerLoyaltyPoints.
  ///
  /// In fr, this message translates to:
  /// **'Points fidélité'**
  String get customerLoyaltyPoints;

  /// No description provided for @customerLastVisit.
  ///
  /// In fr, this message translates to:
  /// **'Dernière visite'**
  String get customerLastVisit;

  /// No description provided for @customerCreditBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde crédit'**
  String get customerCreditBalance;

  /// No description provided for @customerNewCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau client'**
  String get customerNewCustomer;

  /// No description provided for @customerEditCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le client'**
  String get customerEditCustomer;

  /// No description provided for @customerDetail.
  ///
  /// In fr, this message translates to:
  /// **'Fiche client'**
  String get customerDetail;

  /// No description provided for @customerPurchaseHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique achats'**
  String get customerPurchaseHistory;

  /// No description provided for @customerCredits.
  ///
  /// In fr, this message translates to:
  /// **'Crédits'**
  String get customerCredits;

  /// No description provided for @customerNoCredits.
  ///
  /// In fr, this message translates to:
  /// **'Aucun crédit en cours'**
  String get customerNoCredits;

  /// No description provided for @customerFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get customerFilterAll;

  /// No description provided for @customerFilterWithCredit.
  ///
  /// In fr, this message translates to:
  /// **'Avec crédit'**
  String get customerFilterWithCredit;

  /// No description provided for @creditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ventes à crédit'**
  String get creditTitle;

  /// No description provided for @creditTotalOwed.
  ///
  /// In fr, this message translates to:
  /// **'Total dû'**
  String get creditTotalOwed;

  /// No description provided for @creditOverdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get creditOverdue;

  /// No description provided for @creditPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get creditPending;

  /// No description provided for @creditPartial.
  ///
  /// In fr, this message translates to:
  /// **'Partiel'**
  String get creditPartial;

  /// No description provided for @creditPaid.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get creditPaid;

  /// No description provided for @creditAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get creditAmount;

  /// No description provided for @creditAmountTotal.
  ///
  /// In fr, this message translates to:
  /// **'Montant total'**
  String get creditAmountTotal;

  /// No description provided for @creditAmountPaid.
  ///
  /// In fr, this message translates to:
  /// **'Montant payé'**
  String get creditAmountPaid;

  /// No description provided for @creditAmountRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Reste à payer'**
  String get creditAmountRemaining;

  /// No description provided for @creditDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Date limite'**
  String get creditDueDate;

  /// No description provided for @creditNoDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Sans échéance'**
  String get creditNoDueDate;

  /// No description provided for @creditRecordPayment.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer un paiement'**
  String get creditRecordPayment;

  /// No description provided for @creditPaymentAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant du paiement'**
  String get creditPaymentAmount;

  /// No description provided for @creditPaymentAmountRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le montant est obligatoire'**
  String get creditPaymentAmountRequired;

  /// No description provided for @creditPaymentAmountExceeds.
  ///
  /// In fr, this message translates to:
  /// **'Le montant ne peut pas dépasser le reste dû'**
  String get creditPaymentAmountExceeds;

  /// No description provided for @creditPaymentType.
  ///
  /// In fr, this message translates to:
  /// **'Type de paiement'**
  String get creditPaymentType;

  /// No description provided for @creditPaymentCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get creditPaymentCash;

  /// No description provided for @creditPaymentCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get creditPaymentCard;

  /// No description provided for @creditPaymentMvola.
  ///
  /// In fr, this message translates to:
  /// **'MVola'**
  String get creditPaymentMvola;

  /// No description provided for @creditPaymentOrangeMoney.
  ///
  /// In fr, this message translates to:
  /// **'Orange Money'**
  String get creditPaymentOrangeMoney;

  /// No description provided for @creditPaymentReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence'**
  String get creditPaymentReference;

  /// No description provided for @creditPaymentReferenceHint.
  ///
  /// In fr, this message translates to:
  /// **'Référence transaction'**
  String get creditPaymentReferenceHint;

  /// No description provided for @creditPaymentRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Paiement enregistré'**
  String get creditPaymentRecorded;

  /// No description provided for @creditPaymentHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique paiements'**
  String get creditPaymentHistory;

  /// No description provided for @creditNoPayments.
  ///
  /// In fr, this message translates to:
  /// **'Aucun paiement enregistré'**
  String get creditNoPayments;

  /// No description provided for @creditWhatsAppReminder.
  ///
  /// In fr, this message translates to:
  /// **'Rappel WhatsApp'**
  String get creditWhatsAppReminder;

  /// No description provided for @creditCreatedOn.
  ///
  /// In fr, this message translates to:
  /// **'Créé le {date}'**
  String creditCreatedOn(String date);

  /// No description provided for @creditDueOn.
  ///
  /// In fr, this message translates to:
  /// **'Échéance : {date}'**
  String creditDueOn(String date);

  /// No description provided for @mobileMoneySettings.
  ///
  /// In fr, this message translates to:
  /// **'Paiements Mobile Money'**
  String get mobileMoneySettings;

  /// No description provided for @mobileMoneyEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Activer Mobile Money'**
  String get mobileMoneyEnabled;

  /// No description provided for @mobileMoneyEnabledDescription.
  ///
  /// In fr, this message translates to:
  /// **'Acceptez MVola et Orange Money à la caisse'**
  String get mobileMoneyEnabledDescription;

  /// No description provided for @mvolaMerchantNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro marchand MVola'**
  String get mvolaMerchantNumber;

  /// No description provided for @mvolaMerchantNumberHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 034 12 345 67'**
  String get mvolaMerchantNumberHint;

  /// No description provided for @orangeMoneyMerchantNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro marchand Orange Money'**
  String get orangeMoneyMerchantNumber;

  /// No description provided for @orangeMoneyMerchantNumberHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 032 12 345 67'**
  String get orangeMoneyMerchantNumberHint;

  /// No description provided for @mobileMoneySettingsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Réglages Mobile Money enregistrés'**
  String get mobileMoneySettingsSaved;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsPaymentTypes.
  ///
  /// In fr, this message translates to:
  /// **'Types de paiement'**
  String get settingsPaymentTypes;
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
