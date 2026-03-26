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
  String get total => 'Total';

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

  @override
  String get creditSale => 'Vente à crédit';

  @override
  String get selectCustomerForCredit =>
      'Sélectionnez un client pour la vente à crédit';

  @override
  String get selectCustomer => 'Sélectionner un client';

  @override
  String get noCustomerSelected => 'Aucun client sélectionné';

  @override
  String get creditDueDateTitle => 'Date d\'échéance';

  @override
  String get creditDueDateNone => 'Sans échéance';

  @override
  String get creditDueDate7d => '7 jours';

  @override
  String get creditDueDate15d => '15 jours';

  @override
  String get creditDueDate30d => '30 jours';

  @override
  String get creditDueDateCustom => 'Choisir une date';

  @override
  String get creditNoteHint => 'Note sur le crédit (optionnel)';

  @override
  String creditSaleConfirmation(String amount, String customer) {
    return 'Confirmer la vente à crédit de $amount Ar pour $customer ?';
  }

  @override
  String get creditSaleSuccess => 'Vente à crédit enregistrée';

  @override
  String get creditSaleCustomerRequired =>
      'Un client est requis pour une vente à crédit';

  @override
  String get totalDebts => 'Total dettes';

  @override
  String get overdueDebts => 'En retard';

  @override
  String get creditSalesEmpty => 'Aucune vente à crédit';

  @override
  String get creditSalesEmptyDescription =>
      'Les ventes à crédit apparaîtront ici';

  @override
  String get payment => 'Paiement';

  @override
  String get paymentTitle => 'Paiement';

  @override
  String get paymentSingle => 'Paiement unique';

  @override
  String get paymentSplit => 'Multi-paiement';

  @override
  String get paymentType => 'Type de paiement';

  @override
  String get paymentCash => 'Espèces';

  @override
  String get paymentCard => 'Carte bancaire';

  @override
  String get paymentMvola => 'MVola';

  @override
  String get paymentOrangeMoney => 'Orange Money';

  @override
  String get paymentCredit => 'Crédit';

  @override
  String get paymentTotalToPay => 'Total à payer';

  @override
  String get paymentAmountReceived => 'Montant reçu';

  @override
  String get paymentCustomAmount => 'Ou montant personnalisé';

  @override
  String get paymentCustomAmountHint => 'Montant en Ariary';

  @override
  String get paymentChangeDue => 'Monnaie à rendre';

  @override
  String get paymentInsufficient => 'Montant insuffisant';

  @override
  String get paymentNoteOptional => 'Note (optionnel)';

  @override
  String get paymentNoteHint => 'Ajouter une note à cette vente...';

  @override
  String get paymentNoteHelper => 'Cette note apparaîtra sur le reçu';

  @override
  String get paymentValidate => 'VALIDER LE PAIEMENT';

  @override
  String get paymentRemainingAmount => 'Montant restant';

  @override
  String get paymentComplete => 'Paiement complet';

  @override
  String get paymentPaid => 'Payé';

  @override
  String get paymentAdded => 'Paiements ajoutés';

  @override
  String get paymentAddPayment => 'Ajouter un paiement';

  @override
  String get paymentSplitDescription =>
      'Divisez le paiement en plusieurs méthodes';

  @override
  String get paymentSplitMethods => 'Espèces, Carte, MVola, Orange Money';

  @override
  String get paymentErrorNotAuthenticated =>
      'Erreur: utilisateur non authentifié';

  @override
  String get paymentErrorStoreSettings =>
      'Erreur: impossible de charger les réglages du magasin';

  @override
  String get paymentErrorMvolaMerchant =>
      'Erreur: numéro marchand MVola non configuré';

  @override
  String get paymentErrorOrangeMoneyMerchant =>
      'Erreur: numéro marchand Orange Money non configuré';

  @override
  String get paymentConfigure => 'Configurer';

  @override
  String get inventoryTitle => 'Vue d\'ensemble stock';

  @override
  String get inventoryMetrics => 'Indicateurs';

  @override
  String get inventoryOutOfStock => 'Ruptures';

  @override
  String get inventoryLowStock => 'Alertes stock';

  @override
  String get inventoryTotalValue => 'Valeur stock';

  @override
  String get inventoryFilterAll => 'Tous';

  @override
  String get inventoryFilterLow => 'Bas stock';

  @override
  String get inventoryFilterOut => 'Rupture';

  @override
  String get inventoryEmpty => 'Aucun article en stock';

  @override
  String get inventoryEmptyDescription =>
      'Ajoutez vos produits avec suivi de stock activé';

  @override
  String inventoryItemsCount(int count) {
    return '$count articles';
  }

  @override
  String get inventoryQuickEdit => 'Modifier le stock';

  @override
  String get inventoryCurrentStock => 'Stock actuel';

  @override
  String get inventoryNewStock => 'Nouveau stock';

  @override
  String get inventoryAdjustmentReason => 'Raison';

  @override
  String get inventoryReasonReceive => 'Réception';

  @override
  String get inventoryReasonLoss => 'Perte';

  @override
  String get inventoryReasonDamage => 'Dommage';

  @override
  String get inventoryReasonCount => 'Inventaire';

  @override
  String get inventoryReasonOther => 'Autre';

  @override
  String get inventoryAdjustmentNote => 'Note (optionnel)';

  @override
  String get inventoryAdjustmentSuccess => 'Stock mis à jour';

  @override
  String inventoryStockUpdated(String name) {
    return 'Stock de $name mis à jour';
  }

  @override
  String get inventoryAlertThreshold => 'Seuil d\'alerte';

  @override
  String get inventoryAlertSet => 'Définir une alerte';

  @override
  String get inventoryAlertUpdated => 'Alerte stock mise à jour';

  @override
  String inventoryUnitsRemaining(int count) {
    return '$count en stock';
  }

  @override
  String get inventoryExportPdf => 'Exporter en PDF';

  @override
  String get inventoryExportExcel => 'Exporter en Excel';

  @override
  String get inventoryExportShare => 'Partager';

  @override
  String get inventoryExportPdfSuccess => 'Inventaire exporté en PDF';

  @override
  String get inventoryExportExcelSuccess => 'Inventaire exporté en Excel';

  @override
  String get inventoryExportPdfLoading => 'Génération du PDF...';

  @override
  String get inventoryExportExcelLoading => 'Génération du fichier Excel...';

  @override
  String get inventoryExportPdfSubject => 'Inventaire - Export PDF';

  @override
  String get inventoryExportExcelSubject => 'Inventaire - Export Excel';

  @override
  String get inventoryExportStoreError =>
      'Impossible d\'exporter : magasin non identifié';

  @override
  String get exportCsv => 'Exporter CSV';

  @override
  String get exportPdf => 'Exporter PDF';

  @override
  String get inventorySheet => 'Feuille d\'inventaire';

  @override
  String get printInventory => 'Imprimer résumé';

  @override
  String get exportSuccess => 'Export réussi';

  @override
  String get totalItems => 'Total produits';

  @override
  String get totalStockValue => 'Valeur stock (coût)';

  @override
  String get totalRetailValue => 'Valeur retail';

  @override
  String get profitPotential => 'Profit potentiel';

  @override
  String get exportingInventory => 'Export en cours...';

  @override
  String get printingInventory => 'Impression en cours...';

  @override
  String get printerNotConnected => 'Imprimante non connectée';

  @override
  String get exportError => 'Erreur d\'export';

  @override
  String get printError => 'Erreur d\'impression';

  @override
  String get salesHistory => 'Historique des ventes';

  @override
  String get searchReceipts => 'Rechercher un reçu';

  @override
  String get receiptDetail => 'Détail du reçu';

  @override
  String get refund => 'Rembourser';

  @override
  String get refundAll => 'Tout rembourser';

  @override
  String get refundReason => 'Raison du remboursement';

  @override
  String get reasonDefective => 'Produit défectueux';

  @override
  String get reasonError => 'Erreur de caisse';

  @override
  String get reasonDissatisfied => 'Client insatisfait';

  @override
  String get reasonOther => 'Autre';

  @override
  String get confirmRefund => 'Confirmer le remboursement';

  @override
  String get confirmRefundMessage =>
      'Êtes-vous sûr de vouloir rembourser ces articles ? Cette action est irréversible.';

  @override
  String get refundSuccess => 'Remboursement effectué avec succès';

  @override
  String get alreadyRefunded => 'Cette vente a déjà été remboursée';

  @override
  String get notSynced => 'Non synchronisé';

  @override
  String get refunded => 'Remboursé';

  @override
  String get noStoreSelected => 'Aucun magasin sélectionné';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get all => 'Tous';

  @override
  String get items => 'Articles';

  @override
  String get noItems => 'Aucun article';

  @override
  String get employee => 'Employé';

  @override
  String get cashRegister => 'Caisse';

  @override
  String get tax => 'Taxes';

  @override
  String get discount => 'Remise';

  @override
  String get paymentMethod => 'Mode de paiement';

  @override
  String get cash => 'Espèces';

  @override
  String get print => 'Imprimer';

  @override
  String get sendWhatsApp => 'Envoyer par WhatsApp';

  @override
  String get originalItems => 'Articles originaux';

  @override
  String get itemsToRefund => 'Articles à rembourser';

  @override
  String get selectItemsToRefund => 'Sélectionnez les articles à rembourser';

  @override
  String get noItemsSelected => 'Aucun article sélectionné';

  @override
  String get noteOptional => 'Note (optionnel)';

  @override
  String get totalToRefund => 'Total à rembourser';

  @override
  String get changeDueLabel => 'Monnaie à rendre :';

  @override
  String get changeCustomer => 'Changer';

  @override
  String get paymentOther => 'Autre';

  @override
  String get importItems => 'Importer des produits';

  @override
  String get importItemsDescription =>
      'Importez vos produits depuis un fichier CSV ou Excel.\nTéléchargez d\'abord le template pour voir le format attendu.';

  @override
  String get selectFile => 'Choisir un fichier';

  @override
  String get downloadTemplate => 'Télécharger le template';

  @override
  String get fileFormat => 'Format du fichier';

  @override
  String get fileFormatDescription =>
      'Le fichier doit contenir les colonnes suivantes : Nom, SKU, Code-barres, Catégorie, Prix, Coût, Stock, Seuil d\'alerte, Description.\nSeuls le Nom et le Prix sont obligatoires.';

  @override
  String get parsingFile => 'Analyse du fichier en cours...';

  @override
  String get valid => 'Valides';

  @override
  String get errors => 'Erreurs';

  @override
  String importValidRows(int count) {
    return 'Importer $count produits valides';
  }

  @override
  String get importing => 'Import en cours...';

  @override
  String get importComplete => 'Import terminé';

  @override
  String importSuccessMessage(int count) {
    return '$count produits importés avec succès';
  }

  @override
  String importErrorsMessage(int count) {
    return '$count erreurs rencontrées';
  }

  @override
  String get help => 'Aide';

  @override
  String get importHelpText =>
      'Importez vos produits depuis un fichier CSV ou Excel. Téléchargez le modèle pour voir le format attendu.';

  @override
  String get adjustmentNewTitle => 'Nouvel ajustement';

  @override
  String get adjustmentListTitle => 'Ajustements de stock';

  @override
  String get adjustmentSelectReason => 'Raison de l\'ajustement';

  @override
  String get adjustmentSearchItems => 'Rechercher un produit';

  @override
  String get adjustmentAddItems => 'Ajouter des produits';

  @override
  String get adjustmentNoItems => 'Aucun article ajouté';

  @override
  String get adjustmentNoItemsHint =>
      'Recherchez et ajoutez des produits à ajuster';

  @override
  String get adjustmentCurrentStock => 'Stock actuel';

  @override
  String get adjustmentVariation => 'Variation';

  @override
  String get adjustmentStockAfter => 'Stock après';

  @override
  String get adjustmentValidate => 'Valider l\'ajustement';

  @override
  String get adjustmentCreated => 'Ajustement créé avec succès';

  @override
  String get adjustmentEmptyList => 'Aucun ajustement';

  @override
  String get adjustmentEmptyDescription =>
      'Les ajustements de stock apparaîtront ici';

  @override
  String get adjustmentFilterAll => 'Tous';

  @override
  String adjustmentItemsCount(int count) {
    return '$count articles';
  }

  @override
  String get adjustmentTotalVariation => 'Variation totale';

  @override
  String adjustmentBy(String employee) {
    return 'Par $employee';
  }

  @override
  String get historyTitle => 'Historique';

  @override
  String get historyEmpty => 'Aucun mouvement';

  @override
  String get historyEmptyDescription =>
      'L\'historique des mouvements de stock apparaîtra ici';

  @override
  String get historyFilterPeriod => 'Période';

  @override
  String get historyFilterLast7Days => '7 derniers jours';

  @override
  String get historyFilterLast30Days => '30 derniers jours';

  @override
  String get historyFilterThisMonth => 'Ce mois';

  @override
  String get historyFilterCustom => 'Personnalisé';

  @override
  String historyOn(String date) {
    return 'Le $date';
  }

  @override
  String get inventoryCountsTitle => 'Inventaires';

  @override
  String get inventoryCountsEmpty => 'Aucun inventaire';

  @override
  String get inventoryCountsEmptyDescription =>
      'Les inventaires physiques apparaîtront ici';

  @override
  String get inventoryCountsFilterAll => 'Tous';

  @override
  String get inventoryCountsFilterPending => 'En attente';

  @override
  String get inventoryCountsFilterInProgress => 'En cours';

  @override
  String get inventoryCountsFilterCompleted => 'Terminés';

  @override
  String get inventoryCountTypeFull => 'Complet';

  @override
  String get inventoryCountTypePartial => 'Partiel';

  @override
  String get inventoryCountStatusPending => 'En attente';

  @override
  String get inventoryCountStatusInProgress => 'En cours';

  @override
  String get inventoryCountStatusCompleted => 'Terminé';

  @override
  String inventoryCountItemsCount(int count) {
    return '$count articles';
  }

  @override
  String inventoryCountCreatedBy(String employee) {
    return 'Par $employee';
  }

  @override
  String get newInventoryCountTitle => 'Nouvel inventaire';

  @override
  String get newInventoryCountTypeLabel => 'Type d\'inventaire';

  @override
  String get newInventoryCountTypeFullTitle => 'Inventaire complet';

  @override
  String get newInventoryCountTypeFullDescription =>
      'Compter tous les produits du magasin';

  @override
  String get newInventoryCountTypePartialTitle => 'Inventaire partiel';

  @override
  String get newInventoryCountTypePartialDescription =>
      'Compter seulement certains produits';

  @override
  String get newInventoryCountNotes => 'Notes (optionnel)';

  @override
  String get newInventoryCountNotesHint =>
      'Ajouter des remarques sur cet inventaire';

  @override
  String get newInventoryCountSelectItems =>
      'Sélectionner les produits à compter';

  @override
  String get newInventoryCountSearchItems => 'Rechercher un produit';

  @override
  String get newInventoryCountNoItemsSelected => 'Aucun produit sélectionné';

  @override
  String newInventoryCountItemsSelected(int count) {
    return '$count produits sélectionnés';
  }

  @override
  String get newInventoryCountStartCounting => 'Commencer le comptage';

  @override
  String newInventoryCountCurrentStock(String stock) {
    return 'Stock actuel : $stock';
  }

  @override
  String get inventoryCountingTitle => 'Comptage en cours';

  @override
  String inventoryCountingProgress(int counted, int total) {
    return '$counted / $total comptés';
  }

  @override
  String get inventoryCountingTotalItems => 'Total articles';

  @override
  String get inventoryCountingCounted => 'Comptés';

  @override
  String get inventoryCountingDiscrepancies => 'Écarts';

  @override
  String get inventoryCountingSearchItems => 'Rechercher un produit';

  @override
  String get inventoryCountingScanBarcode => 'Scanner un code-barres';

  @override
  String get inventoryCountingExpectedStock => 'Stock attendu';

  @override
  String get inventoryCountingCountedStock => 'Stock compté';

  @override
  String get inventoryCountingDifference => 'Écart';

  @override
  String get inventoryCountingEnterQuantity => 'Saisir la quantité';

  @override
  String get inventoryCountingComplete => 'Terminer l\'inventaire';

  @override
  String get inventoryCountingConfirmTitle => 'Terminer l\'inventaire ?';

  @override
  String inventoryCountingConfirmMessage(
    int total,
    int counted,
    int discrepancies,
    String difference,
  ) {
    return 'Résumé de l\'inventaire :\n\n• Total articles : $total\n• Articles comptés : $counted\n• Écarts détectés : $discrepancies\n• Écart total : $difference\n\nVoulez-vous finaliser cet inventaire ?';
  }

  @override
  String get inventoryCountingConfirmYes => 'Terminer';

  @override
  String get inventoryCountingCompleted => 'Inventaire terminé avec succès';

  @override
  String get inventoryCountingNotAllCounted =>
      'Tous les articles doivent être comptés avant de terminer';

  @override
  String get inventoryCompleteTitle => 'Terminer l\'inventaire';

  @override
  String get inventoryTotalItems => 'Total articles';

  @override
  String get inventoryCounted => 'Articles comptés';

  @override
  String get inventoryDiscrepancies => 'Écarts détectés';

  @override
  String get inventoryNotAllCounted => 'Tous les articles doivent être comptés';

  @override
  String get inventoryComplete => 'Terminer';

  @override
  String get inventoryCompletedSuccess => 'Inventaire terminé avec succès';

  @override
  String get inventoryItemsCounted => 'articles comptés';

  @override
  String get inventoryCompleted => 'Terminé';

  @override
  String get inventoryExpected => 'Attendu';

  @override
  String get inventoryExpectedStock => 'Stock attendu';

  @override
  String get inventoryCountedStock => 'Stock compté';

  @override
  String get inventoryEnterCount => 'Entrer le comptage';

  @override
  String get inventoryDifference => 'Différence';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get tryDifferentSearch => 'Essayez une recherche différente';

  @override
  String get inventoryStatusPending => 'En attente';

  @override
  String get inventoryStatusInProgress => 'En cours';

  @override
  String get inventoryStatusCompleted => 'Terminé';

  @override
  String get inventoryTypeFull => 'Complet';

  @override
  String get inventoryTypePartial => 'Partiel';

  @override
  String inventoryCreatedBy(String name) {
    return 'Créé par $name';
  }

  @override
  String get inventoryCountsEmptyHint =>
      'Aucun inventaire. Appuyez sur + pour commencer.';

  @override
  String get inventoryNewCountTitle => 'Nouvel inventaire';

  @override
  String get inventoryCountType => 'Type d\'inventaire';

  @override
  String get inventoryTypeFullDesc => 'Compter tous les articles en stock';

  @override
  String get inventoryTypePartialDesc =>
      'Compter uniquement les articles sélectionnés';

  @override
  String get inventorySelectProducts => 'Sélectionner les produits';

  @override
  String get inventorySelectItems => 'Sélectionner les articles à compter';

  @override
  String get inventoryNotesHint => 'Notes (optionnel)';

  @override
  String get inventoryStartCounting => 'Commencer l\'inventaire';

  @override
  String inventoryItemsSelected(int count) {
    return '$count articles sélectionnés';
  }

  @override
  String get inventoryOverview => 'Vue d\'ensemble';

  @override
  String get inventoryHistory => 'Historique';
}
