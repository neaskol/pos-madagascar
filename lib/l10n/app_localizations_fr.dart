// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'POS Madagascar';

  @override
  String get appTagline => 'Vendez depuis votre téléphone, même sans internet';

  @override
  String get onboardingTitle1 => 'Vendez depuis votre téléphone';

  @override
  String get onboardingDesc1 =>
      'Une caisse complète dans votre poche. Pas besoin d\'équipement coûteux.';

  @override
  String get onboardingTitle2 => 'Fonctionne sans internet';

  @override
  String get onboardingDesc2 =>
      'Vendez même hors ligne. Tout se synchronise automatiquement quand vous êtes connecté.';

  @override
  String get onboardingTitle3 => 'MVola & Orange Money inclus';

  @override
  String get onboardingDesc3 =>
      'Acceptez les paiements mobiles directement dans votre caisse.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginCreateAccount => 'Créer un compte';

  @override
  String get loginSignUp => 'S\'inscrire';

  @override
  String get loginShowPassword => 'Afficher le mot de passe';

  @override
  String get loginHidePassword => 'Masquer le mot de passe';

  @override
  String get registerTitle => 'Inscription';

  @override
  String get registerName => 'Nom complet';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Mot de passe';

  @override
  String get registerPasswordConfirm => 'Confirmer le mot de passe';

  @override
  String get registerPhone => 'Téléphone (optionnel)';

  @override
  String get registerButton => 'Créer mon compte';

  @override
  String get registerHaveAccount => 'Déjà un compte ?';

  @override
  String get registerSignIn => 'Se connecter';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotPasswordDescription =>
      'Entrez votre email et nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get forgotPasswordSubmit => 'Envoyer le lien';

  @override
  String get forgotPasswordEmailSent =>
      'Email envoyé ! Vérifiez votre boîte de réception.';

  @override
  String get forgotPasswordBackToLogin => 'Retour à la connexion';

  @override
  String get setupTitle => 'Configuration du magasin';

  @override
  String get setupStep1Title => 'Informations du magasin';

  @override
  String get setupStep2Title => 'Devise et arrondi';

  @override
  String get setupStep3Title => 'Langues';

  @override
  String get setupStep4Title => 'Type de commerce';

  @override
  String get setupStoreName => 'Nom du magasin';

  @override
  String get setupStoreAddress => 'Adresse (optionnel)';

  @override
  String get setupStorePhone => 'Téléphone (optionnel)';

  @override
  String get setupUploadLogo => 'Ajouter un logo';

  @override
  String get setupCurrency => 'Devise';

  @override
  String get setupCashRounding => 'Arrondi de caisse';

  @override
  String get setupCashRoundingNone => 'Aucun';

  @override
  String get setupCashRounding50 => '50 Ar';

  @override
  String get setupCashRounding100 => '100 Ar';

  @override
  String get setupCashRounding200 => '200 Ar';

  @override
  String get setupInterfaceLanguage => 'Langue de l\'interface';

  @override
  String get setupReceiptLanguage => 'Langue des reçus';

  @override
  String get setupBusinessType => 'Type de commerce';

  @override
  String get setupBusinessTypeGrocery => 'Épicerie / Superette';

  @override
  String get setupBusinessTypeRestaurant => 'Restaurant / Café';

  @override
  String get setupBusinessTypeFashion => 'Boutique / Mode';

  @override
  String get setupBusinessTypeService => 'Service / Salon';

  @override
  String get setupBusinessTypeOther => 'Autre';

  @override
  String setupStepIndicator(int current, int total) {
    return 'Étape $current / $total';
  }

  @override
  String get setupStoreNameRequired => 'Veuillez entrer le nom du magasin';

  @override
  String get setupPrevious => 'Précédent';

  @override
  String get setupNext => 'Suivant';

  @override
  String get setupFinish => 'Terminer';

  @override
  String get pinTitle => 'Qui êtes-vous ?';

  @override
  String get pinEnterCode => 'Entrez votre code PIN';

  @override
  String get pinEmailLogin => 'Connexion avec email';

  @override
  String get pinIncorrect => 'Code PIN incorrect';

  @override
  String get errorInvalidEmail => 'Email invalide';

  @override
  String get errorPasswordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get errorPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get errorFieldRequired => 'Ce champ est obligatoire';

  @override
  String get errorNetworkFailed => 'Pas de connexion internet';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sort => 'Trier';

  @override
  String get back => 'Retour';

  @override
  String get close => 'Fermer';

  @override
  String get done => 'Terminé';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get productsTitle => 'Produits';

  @override
  String get productsSearch => 'Rechercher un produit';

  @override
  String get productsFilterAll => 'Tous';

  @override
  String get productsFilterLowStock => 'Stock bas';

  @override
  String get productsFilterOutOfStock => 'Rupture';

  @override
  String get productsCategory => 'Catégorie';

  @override
  String get productsAllCategories => 'Toutes les catégories';

  @override
  String get productsStock => 'Stock';

  @override
  String get productsPrice => 'Prix';

  @override
  String get productsNotAvailable => 'Hors vente';

  @override
  String get productsEmptyTitle => 'Aucun produit';

  @override
  String get productsEmptyDescription =>
      'Commencez par ajouter vos premiers produits';

  @override
  String get productsAddProduct => 'Ajouter un produit';

  @override
  String get productsInStock => 'en stock';

  @override
  String get productsLowStock => 'stock bas';

  @override
  String get productsOutOfStock => 'rupture';

  @override
  String get productFormNewTitle => 'Nouveau produit';

  @override
  String get productFormEditTitle => 'Modifier';

  @override
  String get productFormSave => 'Enregistrer';

  @override
  String get productFormDelete => 'Supprimer';

  @override
  String get productFormDeleteConfirm =>
      'Voulez-vous vraiment supprimer ce produit ?';

  @override
  String get productFormPhotoSection => 'Photo';

  @override
  String get productFormSelectPhoto => 'Sélectionner une photo';

  @override
  String get productFormColorFallback => 'Ou choisir une couleur';

  @override
  String get productFormBasicSection => 'Informations de base';

  @override
  String get productFormName => 'Nom du produit';

  @override
  String get productFormNameHint => 'Ex: Coca-Cola 1.5L';

  @override
  String get productFormNameRequired => 'Le nom est obligatoire';

  @override
  String get productFormCategory => 'Catégorie';

  @override
  String get productFormNoCategory => 'Aucune catégorie';

  @override
  String get productFormDescription => 'Description';

  @override
  String get productFormDescriptionHint => 'Description optionnelle du produit';

  @override
  String get productFormSKU => 'Code SKU';

  @override
  String get productFormSKUHint => 'Auto-généré si vide';

  @override
  String get productFormBarcode => 'Code-barre';

  @override
  String get productFormBarcodeHint => 'Scannez ou saisissez';

  @override
  String get productFormScanBarcode => 'Scanner';

  @override
  String get productFormPricingSection => 'Prix';

  @override
  String get productFormSalePrice => 'Prix de vente';

  @override
  String get productFormSalePriceHint => 'Prix en Ariary';

  @override
  String get productFormSalePriceRequired => 'Le prix est obligatoire';

  @override
  String get productFormCost => 'Coût d\'achat';

  @override
  String get productFormCostHint => 'Coût en Ariary';

  @override
  String get productFormCostPercentage => 'Coût en %';

  @override
  String get productFormMargin => 'Marge';

  @override
  String get productFormMarginAmount => 'Marge';

  @override
  String get productFormSalesSection => 'Vente';

  @override
  String get productFormAvailableForSale => 'Disponible à la vente';

  @override
  String get productFormSoldByWeight => 'Vendu au poids';

  @override
  String get productFormWeightUnit => 'Unité de poids';

  @override
  String get productFormWeightUnitHint => 'kg, g, l, ml...';

  @override
  String get productFormStockSection => 'Stock';

  @override
  String get productFormTrackStock => 'Suivre le stock';

  @override
  String get productFormCurrentStock => 'Stock actuel';

  @override
  String get productFormCurrentStockHint => 'Quantité en stock';

  @override
  String get productFormLowStockThreshold => 'Seuil d\'alerte stock bas';

  @override
  String get productFormLowStockThresholdHint => 'Seuil par défaut : 10';

  @override
  String get productFormTaxesSection => 'Taxes';

  @override
  String get productFormNoTaxes => 'Aucune taxe configurée';

  @override
  String get productFormSaved => 'Produit enregistré';

  @override
  String get productFormDeleted => 'Produit supprimé';

  @override
  String get posScreenTitle => 'Caisse';

  @override
  String get clearTicket => 'Vider le ticket';

  @override
  String get clearTicketConfirmation =>
      'Êtes-vous sûr de vouloir vider le panier ?';

  @override
  String get saveTicket => 'Sauvegarder';

  @override
  String get comingSoon => 'À venir';

  @override
  String get searchProducts => 'Rechercher un produit';

  @override
  String get allCategories => 'Toutes';

  @override
  String get noProducts => 'Aucun produit disponible';

  @override
  String get addedToCart => 'ajouté au panier';

  @override
  String get emptyCart => 'Panier vide';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get total => 'TOTAL';

  @override
  String get pay => 'PAYER';

  @override
  String get scanBarcode => 'Scanner code-barres';

  @override
  String get scanBarcodeTitle => 'Scanner un code-barres';

  @override
  String get scanBarcodeInstructions => 'Placez le code-barres dans le cadre';

  @override
  String get scanBarcodeFormats =>
      'EAN-13, EAN-8, UPC-A, Code 128, Code 39, QR';

  @override
  String get productsNotLoaded => 'Produits non chargés';

  @override
  String productNotFound(String barcode) {
    return 'Aucun produit trouvé avec le code: $barcode';
  }

  @override
  String get selectVariant => 'Choisir un variant';

  @override
  String get selectModifiers => 'Choisir les options';

  @override
  String get required => 'Obligatoire';

  @override
  String get noVariantSelected => 'Aucun variant sélectionné';

  @override
  String get modifierRequired =>
      'Vous devez sélectionner une option obligatoire';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String get cartItemDiscounts => 'Remises items';

  @override
  String get cartDiscount => 'Remise panier';

  @override
  String get cartTaxes => 'Taxes';

  @override
  String get cartQuantity => 'Quantité';

  @override
  String cartItemRemoved(String name) {
    return '$name retiré du panier';
  }

  @override
  String get ok => 'OK';

  @override
  String get paymentSuccess => 'Paiement réussi';

  @override
  String receiptNumber(String number) {
    return 'Reçu N° $number';
  }

  @override
  String get changeDue => 'Monnaie à rendre:';

  @override
  String get newSale => 'Nouvelle vente';

  @override
  String get viewReceipt => 'Voir reçu';

  @override
  String get allProducts => 'Tous les produits';

  @override
  String get customPages => 'Pages personnalisées';

  @override
  String get createPage => 'Créer une page';

  @override
  String get editPage => 'Modifier la page';

  @override
  String get deletePage => 'Supprimer la page';

  @override
  String get pageName => 'Nom de la page';

  @override
  String get pageNameHint => 'Ex: Boissons, Snacks, Promos...';

  @override
  String get pageCreated => 'Page créée';

  @override
  String get pageUpdated => 'Page mise à jour';

  @override
  String get pageDeleted => 'Page supprimée';

  @override
  String get itemAlreadyOnPage => 'Cet item est déjà sur cette page';

  @override
  String get itemAddedToPage => 'Item ajouté à la page';

  @override
  String get itemRemovedFromPage => 'Item retiré de la page';

  @override
  String get pageCleared => 'Page vidée';

  @override
  String get confirmDeletePage =>
      'Êtes-vous sûr de vouloir supprimer cette page ?';

  @override
  String get cannotDeleteDefaultPage =>
      'Impossible de supprimer la page par défaut';

  @override
  String get customersTitle => 'Clients';

  @override
  String get customersSearch => 'Rechercher un client';

  @override
  String get customersEmptyTitle => 'Aucun client';

  @override
  String get customersEmptyDescription =>
      'Ajoutez vos premiers clients pour suivre leurs achats et crédits';

  @override
  String get customersAddCustomer => 'Ajouter un client';

  @override
  String get customerName => 'Nom du client';

  @override
  String get customerNameRequired => 'Le nom est obligatoire';

  @override
  String get customerPhone => 'Téléphone';

  @override
  String get customerPhoneHint => 'Ex: 034 12 345 67';

  @override
  String get customerEmail => 'Email';

  @override
  String get customerEmailHint => 'Ex: client@email.com';

  @override
  String get customerLoyaltyCard => 'Carte de fidélité';

  @override
  String get customerNotes => 'Notes';

  @override
  String get customerNotesHint => 'Notes sur le client';

  @override
  String get customerCreated => 'Client créé';

  @override
  String get customerUpdated => 'Client mis à jour';

  @override
  String get customerDeleted => 'Client supprimé';

  @override
  String get customerDeleteConfirm =>
      'Voulez-vous vraiment supprimer ce client ?';

  @override
  String get customerTotalSpent => 'Total dépensé';

  @override
  String get customerTotalVisits => 'Visites';

  @override
  String get customerLoyaltyPoints => 'Points fidélité';

  @override
  String get customerLastVisit => 'Dernière visite';

  @override
  String get customerCreditBalance => 'Solde crédit';

  @override
  String get customerNewCustomer => 'Nouveau client';

  @override
  String get customerEditCustomer => 'Modifier le client';

  @override
  String get customerDetail => 'Fiche client';

  @override
  String get customerPurchaseHistory => 'Historique achats';

  @override
  String get customerCredits => 'Crédits';

  @override
  String get customerNoCredits => 'Aucun crédit en cours';

  @override
  String get customerFilterAll => 'Tous';

  @override
  String get customerFilterWithCredit => 'Avec crédit';

  @override
  String get creditTitle => 'Ventes à crédit';

  @override
  String get creditTotalOwed => 'Total dû';

  @override
  String get creditOverdue => 'En retard';

  @override
  String get creditPending => 'En attente';

  @override
  String get creditPartial => 'Partiel';

  @override
  String get creditPaid => 'Payé';

  @override
  String get creditAmount => 'Montant';

  @override
  String get creditAmountTotal => 'Montant total';

  @override
  String get creditAmountPaid => 'Montant payé';

  @override
  String get creditAmountRemaining => 'Reste à payer';

  @override
  String get creditDueDate => 'Date limite';

  @override
  String get creditNoDueDate => 'Sans échéance';

  @override
  String get creditRecordPayment => 'Enregistrer un paiement';

  @override
  String get creditPaymentAmount => 'Montant du paiement';

  @override
  String get creditPaymentAmountRequired => 'Le montant est obligatoire';

  @override
  String get creditPaymentAmountExceeds =>
      'Le montant ne peut pas dépasser le reste dû';

  @override
  String get creditPaymentType => 'Type de paiement';

  @override
  String get creditPaymentCash => 'Espèces';

  @override
  String get creditPaymentCard => 'Carte';

  @override
  String get creditPaymentMvola => 'MVola';

  @override
  String get creditPaymentOrangeMoney => 'Orange Money';

  @override
  String get creditPaymentReference => 'Référence';

  @override
  String get creditPaymentReferenceHint => 'Référence transaction';

  @override
  String get creditPaymentRecorded => 'Paiement enregistré';

  @override
  String get creditPaymentHistory => 'Historique paiements';

  @override
  String get creditNoPayments => 'Aucun paiement enregistré';

  @override
  String get creditWhatsAppReminder => 'Rappel WhatsApp';

  @override
  String creditCreatedOn(String date) {
    return 'Créé le $date';
  }

  @override
  String creditDueOn(String date) {
    return 'Échéance : $date';
  }

  @override
  String get mobileMoneySettings => 'Paiements Mobile Money';

  @override
  String get mobileMoneyEnabled => 'Activer Mobile Money';

  @override
  String get mobileMoneyEnabledDescription =>
      'Acceptez MVola et Orange Money à la caisse';

  @override
  String get mvolaMerchantNumber => 'Numéro marchand MVola';

  @override
  String get mvolaMerchantNumberHint => 'Ex: 034 12 345 67';

  @override
  String get orangeMoneyMerchantNumber => 'Numéro marchand Orange Money';

  @override
  String get orangeMoneyMerchantNumberHint => 'Ex: 032 12 345 67';

  @override
  String get mobileMoneySettingsSaved => 'Réglages Mobile Money enregistrés';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsPaymentTypes => 'Types de paiement';
}
