// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malagasy (`mg`).
class AppLocalizationsMg extends AppLocalizations {
  AppLocalizationsMg([String locale = 'mg']) : super(locale);

  @override
  String get appName => 'POS Madagascar';

  @override
  String get appTagline =>
      'Mivarotra avy amin\'ny finday, na tsy misy internet aza';

  @override
  String get onboardingTitle1 => 'Mivarotra avy amin\'ny finday';

  @override
  String get onboardingDesc1 =>
      'Kaisa feno ao anaty paosinao. Tsy mila fitaovana lafo vidy.';

  @override
  String get onboardingTitle2 => 'Miasa na tsy misy internet aza';

  @override
  String get onboardingDesc2 =>
      'Mivarotra na dia tsy misy connexion aza. Ny zavatra rehetra dia mifanaraka ho azy rehefa misy connexion.';

  @override
  String get onboardingTitle3 => 'MVola sy Orange Money tafiditra';

  @override
  String get onboardingDesc3 =>
      'Mandray fandoavam-bola mobile mivantana ao amin\'ny kaisanao.';

  @override
  String get onboardingSkip => 'Mandingana';

  @override
  String get onboardingStart => 'Manomboka';

  @override
  String get onboardingNext => 'Manaraka';

  @override
  String get loginTitle => 'Fidirana';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Teny miafina';

  @override
  String get loginButton => 'Miditra';

  @override
  String get loginForgotPassword => 'Hadino ny teny miafina?';

  @override
  String get loginCreateAccount => 'Mamorona kaonty';

  @override
  String get loginSignUp => 'Misoratra anarana';

  @override
  String get loginShowPassword => 'Asehoy ny teny miafina';

  @override
  String get loginHidePassword => 'Afeno ny teny miafina';

  @override
  String get registerTitle => 'Fisoratana anarana';

  @override
  String get registerName => 'Anarana feno';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Teny miafina';

  @override
  String get registerPasswordConfirm => 'Hamarino ny teny miafina';

  @override
  String get registerPhone => 'Telefaonina (tsy voatery)';

  @override
  String get registerButton => 'Mamorona ny kaontiko';

  @override
  String get registerHaveAccount => 'Efa manana kaonty?';

  @override
  String get registerSignIn => 'Miditra';

  @override
  String get forgotPasswordTitle => 'Hadino ny teny miafina';

  @override
  String get forgotPasswordDescription =>
      'Ampidiro ny email-nao ary handefasanay rohy hamerenana ny teny miafinao.';

  @override
  String get forgotPasswordSubmit => 'Alefaso ny rohy';

  @override
  String get forgotPasswordEmailSent => 'Email lasa! Jereo ny boaty mailakao.';

  @override
  String get forgotPasswordBackToLogin => 'Miverina amin\'ny fidirana';

  @override
  String get setupTitle => 'Fandrindrana ny magazay';

  @override
  String get setupStep1Title => 'Fampahalalana momba ny magazay';

  @override
  String get setupStep2Title => 'Vola sy fanamboarana';

  @override
  String get setupStep3Title => 'Fiteny';

  @override
  String get setupStep4Title => 'Karazana varotra';

  @override
  String get setupStoreName => 'Anaran\'ny magazay';

  @override
  String get setupStoreAddress => 'Adiresy (tsy voatery)';

  @override
  String get setupStorePhone => 'Telefaonina (tsy voatery)';

  @override
  String get setupUploadLogo => 'Hanampy logo';

  @override
  String get setupCurrency => 'Vola';

  @override
  String get setupCashRounding => 'Fanamboarana vola';

  @override
  String get setupCashRoundingNone => 'Tsia';

  @override
  String get setupCashRounding50 => '50 Ar';

  @override
  String get setupCashRounding100 => '100 Ar';

  @override
  String get setupCashRounding200 => '200 Ar';

  @override
  String get setupInterfaceLanguage => 'Fiteny interface';

  @override
  String get setupReceiptLanguage => 'Fiteny resevoka';

  @override
  String get setupBusinessType => 'Karazana varotra';

  @override
  String get setupBusinessTypeGrocery => 'Fivarotana / Superette';

  @override
  String get setupBusinessTypeRestaurant => 'Trano fisakafoanana / Café';

  @override
  String get setupBusinessTypeFashion => 'Boutique / Mode';

  @override
  String get setupBusinessTypeService => 'Serivisy / Salon';

  @override
  String get setupBusinessTypeOther => 'Hafa';

  @override
  String setupStepIndicator(int current, int total) {
    return 'Dingana $current / $total';
  }

  @override
  String get setupStoreNameRequired => 'Ampidiro ny anaran\'ny magazay azafady';

  @override
  String get setupPrevious => 'Taloha';

  @override
  String get setupNext => 'Manaraka';

  @override
  String get setupFinish => 'Vita';

  @override
  String get pinTitle => 'Iza ianao?';

  @override
  String get pinEnterCode => 'Ampidiro ny code PIN-nao';

  @override
  String get pinEmailLogin => 'Fidirana miaraka amin\'ny email';

  @override
  String get pinIncorrect => 'Code PIN diso';

  @override
  String get errorInvalidEmail => 'Email diso';

  @override
  String get errorPasswordTooShort =>
      'Ny teny miafina dia tokony ho 8 litera farafahakeliny';

  @override
  String get errorPasswordMismatch => 'Tsy mitovy ny teny miafina';

  @override
  String get errorFieldRequired => 'Ilaina io saha io';

  @override
  String get errorNetworkFailed => 'Tsy misy connexion internet';

  @override
  String get cancel => 'Aoka ihany';

  @override
  String get confirm => 'Hamarino';

  @override
  String get save => 'Tahiry';

  @override
  String get delete => 'Fafao';

  @override
  String get edit => 'Ovay';

  @override
  String get add => 'Hanampy';

  @override
  String get search => 'Tadiavo';

  @override
  String get filter => 'Sivao';

  @override
  String get sort => 'Alamino';

  @override
  String get back => 'Miverina';

  @override
  String get close => 'Hidio';

  @override
  String get done => 'Vita';

  @override
  String get yes => 'Eny';

  @override
  String get no => 'Tsia';

  @override
  String get productsTitle => 'Vokatra';

  @override
  String get productsSearch => 'Mitady vokatra';

  @override
  String get productsFilterAll => 'Rehetra';

  @override
  String get productsFilterLowStock => 'Tahiry vitsy';

  @override
  String get productsFilterOutOfStock => 'Tsy misy';

  @override
  String get productsCategory => 'Sokajy';

  @override
  String get productsAllCategories => 'Sokajy rehetra';

  @override
  String get productsStock => 'Tahiry';

  @override
  String get productsPrice => 'Vidiny';

  @override
  String get productsNotAvailable => 'Tsy amidy';

  @override
  String get productsEmptyTitle => 'Tsy misy vokatra';

  @override
  String get productsEmptyDescription =>
      'Atombohy amin\'ny fampidirana ny vokatr\'ny voalohany';

  @override
  String get productsAddProduct => 'Hanampy vokatra';

  @override
  String get productsInStock => 'misy tahiry';

  @override
  String get productsLowStock => 'tahiry vitsy';

  @override
  String get productsOutOfStock => 'tsy misy';

  @override
  String get productFormNewTitle => 'Vokatra vaovao';

  @override
  String get productFormEditTitle => 'Ovay';

  @override
  String get productFormSave => 'Tahiry';

  @override
  String get productFormDelete => 'Fafao';

  @override
  String get productFormDeleteConfirm => 'Tena hofafanao ve io vokatra io?';

  @override
  String get productFormPhotoSection => 'Sary';

  @override
  String get productFormSelectPhoto => 'Hisafidy sary';

  @override
  String get productFormColorFallback => 'Na hisafidy loko';

  @override
  String get productFormBasicSection => 'Fampahalalana fototra';

  @override
  String get productFormName => 'Anaran\'ny vokatra';

  @override
  String get productFormNameHint => 'Ohatra: Coca-Cola 1.5L';

  @override
  String get productFormNameRequired => 'Ilaina ny anarana';

  @override
  String get productFormCategory => 'Sokajy';

  @override
  String get productFormNoCategory => 'Tsy misy sokajy';

  @override
  String get productFormDescription => 'Famaritana';

  @override
  String get productFormDescriptionHint => 'Famaritana tsy voatery';

  @override
  String get productFormSKU => 'Kaody SKU';

  @override
  String get productFormSKUHint => 'Ho voasoratra ho azy raha tsy misy';

  @override
  String get productFormBarcode => 'Barcode';

  @override
  String get productFormBarcodeHint => 'Scan na ampidiro';

  @override
  String get productFormScanBarcode => 'Scan';

  @override
  String get productFormPricingSection => 'Vidiny';

  @override
  String get productFormSalePrice => 'Vidin\'ny fivarotana';

  @override
  String get productFormSalePriceHint => 'Vidiny amin\'ny Ariary';

  @override
  String get productFormSalePriceRequired => 'Ilaina ny vidiny';

  @override
  String get productFormCost => 'Vidin\'ny fividianana';

  @override
  String get productFormCostHint => 'Vidiny amin\'ny Ariary';

  @override
  String get productFormCostPercentage => 'Vidiny amin\'ny %';

  @override
  String get productFormMargin => 'Tombom-barotra';

  @override
  String get productFormMarginAmount => 'Tombom-barotra';

  @override
  String get productFormSalesSection => 'Varotra';

  @override
  String get productFormAvailableForSale => 'Azo amidy';

  @override
  String get productFormSoldByWeight => 'Amidy amin\'ny lanjany';

  @override
  String get productFormWeightUnit => 'Singa lanja';

  @override
  String get productFormWeightUnitHint => 'kg, g, l, ml...';

  @override
  String get productFormStockSection => 'Tahiry';

  @override
  String get productFormTrackStock => 'Manaraka tahiry';

  @override
  String get productFormCurrentStock => 'Tahiry ankehitriny';

  @override
  String get productFormCurrentStockHint => 'Isa misy';

  @override
  String get productFormLowStockThreshold =>
      'Fetra fampitandremana tahiry vitsy';

  @override
  String get productFormLowStockThresholdHint => 'Default: 10';

  @override
  String get productFormTaxesSection => 'Hetra';

  @override
  String get productFormNoTaxes => 'Tsy misy hetra voaomana';

  @override
  String get productFormSaved => 'Voatahiry ny vokatra';

  @override
  String get productFormDeleted => 'Voafafa ny vokatra';

  @override
  String get posScreenTitle => 'Kaisa';

  @override
  String get clearTicket => 'Fafao ny panier';

  @override
  String get clearTicketConfirmation => 'Tena hofafanao ve ny ao anaty panier?';

  @override
  String get saveTicket => 'Tahiry';

  @override
  String get comingSoon => 'Ho avy';

  @override
  String get searchProducts => 'Mitady vokatra';

  @override
  String get allCategories => 'Rehetra';

  @override
  String get noProducts => 'Tsy misy vokatra';

  @override
  String get addedToCart => 'nampiana tao anaty panier';

  @override
  String get emptyCart => 'Panier foana';

  @override
  String get subtotal => 'Isa';

  @override
  String get total => 'TOTALIN\'NY';

  @override
  String get pay => 'MANDOAVA';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get scanBarcodeTitle => 'Scan barcode';

  @override
  String get scanBarcodeInstructions =>
      'Apetraho eo anatin\'ny efijery ny barcode';

  @override
  String get scanBarcodeFormats =>
      'EAN-13, EAN-8, UPC-A, Code 128, Code 39, QR';

  @override
  String get productsNotLoaded => 'Tsy mbola nalaina ny vokatra';

  @override
  String productNotFound(String barcode) {
    return 'Tsy nahita vokatra amin\'ny code: $barcode';
  }

  @override
  String get selectVariant => 'Hifidy variant';

  @override
  String get selectModifiers => 'Hifidy safidy';

  @override
  String get required => 'Ilaina';

  @override
  String get noVariantSelected => 'Tsy misy variant voafidy';

  @override
  String get modifierRequired => 'Mila mifidy safidy ilaina ianao';

  @override
  String get addToCart => 'Hampiana ao amin\'ny panier';

  @override
  String get cartItemDiscounts => 'Fihenam-bidy items';

  @override
  String get cartDiscount => 'Fihenam-bidy panier';

  @override
  String get cartTaxes => 'Hetra';

  @override
  String get cartQuantity => 'Isa';

  @override
  String cartItemRemoved(String name) {
    return '$name nesorina tao amin\'ny panier';
  }

  @override
  String get ok => 'OK';

  @override
  String get paymentSuccess => 'Fandoavana vita soa aman-tsara';

  @override
  String receiptNumber(String number) {
    return 'Resevoka N° $number';
  }

  @override
  String get changeDue => 'Vola averina:';

  @override
  String get newSale => 'Varotra vaovao';

  @override
  String get viewReceipt => 'Jereo resevoka';

  @override
  String get allProducts => 'Vokatra rehetra';

  @override
  String get customPages => 'Pejy manokana';

  @override
  String get createPage => 'Mamorona pejy';

  @override
  String get editPage => 'Hanova ny pejy';

  @override
  String get deletePage => 'Hamafa ny pejy';

  @override
  String get pageName => 'Anaran\'ny pejy';

  @override
  String get pageNameHint => 'Ohatra: Zava-pisotro, Sakafo maivana, Promo...';

  @override
  String get pageCreated => 'Pejy voaforona';

  @override
  String get pageUpdated => 'Pejy novaina';

  @override
  String get pageDeleted => 'Pejy voafafa';

  @override
  String get itemAlreadyOnPage => 'Efa eo amin\'ity pejy ity io vokatra io';

  @override
  String get itemAddedToPage => 'Vokatra nampidirina tao amin\'ny pejy';

  @override
  String get itemRemovedFromPage => 'Vokatra nesorina tao amin\'ny pejy';

  @override
  String get pageCleared => 'Pejy voafafa daholo';

  @override
  String get confirmDeletePage => 'Azo antoka ve fa te hamafa ity pejy ity?';

  @override
  String get cannotDeleteDefaultPage => 'Tsy afaka mamafa ny pejy default';

  @override
  String get customersTitle => 'Mpanjifa';

  @override
  String get customersSearch => 'Mitady mpanjifa';

  @override
  String get customersEmptyTitle => 'Tsy misy mpanjifa';

  @override
  String get customersEmptyDescription =>
      'Ampio ny mpanjifa voalohany mba hanaraha-maso ny fividianany sy ny trosany';

  @override
  String get customersAddCustomer => 'Hanampy mpanjifa';

  @override
  String get customerName => 'Anaran\'ny mpanjifa';

  @override
  String get customerNameRequired => 'Ilaina ny anarana';

  @override
  String get customerPhone => 'Telefaonina';

  @override
  String get customerPhoneHint => 'Ohatra: 034 12 345 67';

  @override
  String get customerEmail => 'Email';

  @override
  String get customerEmailHint => 'Ohatra: mpanjifa@email.com';

  @override
  String get customerLoyaltyCard => 'Karatra fidelite';

  @override
  String get customerNotes => 'Fanamarihana';

  @override
  String get customerNotesHint => 'Fanamarihana momba ny mpanjifa';

  @override
  String get customerCreated => 'Mpanjifa voaforona';

  @override
  String get customerUpdated => 'Mpanjifa novaina';

  @override
  String get customerDeleted => 'Mpanjifa voafafa';

  @override
  String get customerDeleteConfirm => 'Tena hofafanao ve io mpanjifa io?';

  @override
  String get customerTotalSpent => 'Totaliny lany';

  @override
  String get customerTotalVisits => 'Fitsidihana';

  @override
  String get customerLoyaltyPoints => 'Isa fidelite';

  @override
  String get customerLastVisit => 'Fitsidihana farany';

  @override
  String get customerCreditBalance => 'Solan-trosa';

  @override
  String get customerNewCustomer => 'Mpanjifa vaovao';

  @override
  String get customerEditCustomer => 'Hanova mpanjifa';

  @override
  String get customerDetail => 'Pejin\'ny mpanjifa';

  @override
  String get customerPurchaseHistory => 'Tantaran\'ny fividianana';

  @override
  String get customerCredits => 'Trosa';

  @override
  String get customerNoCredits => 'Tsy misy trosa ankehitriny';

  @override
  String get customerFilterAll => 'Rehetra';

  @override
  String get customerFilterWithCredit => 'Misy trosa';

  @override
  String get creditTitle => 'Varotra amin\'ny trosa';

  @override
  String get creditTotalOwed => 'Totaliny tokony aloa';

  @override
  String get creditOverdue => 'Tara';

  @override
  String get creditPending => 'Miandry';

  @override
  String get creditPartial => 'Ampahany';

  @override
  String get creditPaid => 'Voaloa';

  @override
  String get creditAmount => 'Vola';

  @override
  String get creditAmountTotal => 'Vola rehetra';

  @override
  String get creditAmountPaid => 'Vola efa naloa';

  @override
  String get creditAmountRemaining => 'Sisa aloa';

  @override
  String get creditDueDate => 'Fetr\'andro';

  @override
  String get creditNoDueDate => 'Tsy misy fetr\'andro';

  @override
  String get creditRecordPayment => 'Handray fandoavana';

  @override
  String get creditPaymentAmount => 'Vola aloa';

  @override
  String get creditPaymentAmountRequired => 'Ilaina ny vola';

  @override
  String get creditPaymentAmountExceeds =>
      'Ny vola tsy tokony mihoatra ny sisa aloa';

  @override
  String get creditPaymentType => 'Karazana fandoavana';

  @override
  String get creditPaymentCash => 'Vola madinika';

  @override
  String get creditPaymentCard => 'Karatra';

  @override
  String get creditPaymentMvola => 'MVola';

  @override
  String get creditPaymentOrangeMoney => 'Orange Money';

  @override
  String get creditPaymentReference => 'Referansa';

  @override
  String get creditPaymentReferenceHint => 'Referansan\'ny fandoavana';

  @override
  String get creditPaymentRecorded => 'Fandoavana voatahiry';

  @override
  String get creditPaymentHistory => 'Tantaran\'ny fandoavana';

  @override
  String get creditNoPayments => 'Tsy misy fandoavana voatahiry';

  @override
  String get creditWhatsAppReminder => 'Fampahatsiahivana WhatsApp';

  @override
  String creditCreatedOn(String date) {
    return 'Noforonina tamin\'ny $date';
  }

  @override
  String creditDueOn(String date) {
    return 'Fetr\'andro : $date';
  }

  @override
  String get mobileMoneySettings => 'Fandoavana Mobile Money';

  @override
  String get mobileMoneyEnabled => 'Hamelona Mobile Money';

  @override
  String get mobileMoneyEnabledDescription =>
      'Mandray MVola sy Orange Money amin\'ny kaisa';

  @override
  String get mvolaMerchantNumber => 'Laharan\'ny mpivarotra MVola';

  @override
  String get mvolaMerchantNumberHint => 'Ohatra: 034 12 345 67';

  @override
  String get orangeMoneyMerchantNumber => 'Laharan\'ny mpivarotra Orange Money';

  @override
  String get orangeMoneyMerchantNumberHint => 'Ohatra: 032 12 345 67';

  @override
  String get mobileMoneySettingsSaved => 'Fandaminana Mobile Money voatahiry';

  @override
  String get settingsTitle => 'Fandaminana';

  @override
  String get settingsPaymentTypes => 'Karazana fandoavana';
}
