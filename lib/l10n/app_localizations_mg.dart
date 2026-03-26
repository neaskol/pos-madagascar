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
  String get subtotal => 'Totalin\'ny ambany';

  @override
  String get total => 'Totaliny';

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

  @override
  String get creditSale => 'Varotra amin\'ny trosa';

  @override
  String get selectCustomerForCredit =>
      'Safidio ny mpanjifa ho an\'ny varotra amin\'ny trosa';

  @override
  String get selectCustomer => 'Hifidy mpanjifa';

  @override
  String get noCustomerSelected => 'Tsy misy mpanjifa voafidy';

  @override
  String get creditDueDateTitle => 'Fetr\'andro fandoavana';

  @override
  String get creditDueDateNone => 'Tsy misy fetr\'andro';

  @override
  String get creditDueDate7d => '7 andro';

  @override
  String get creditDueDate15d => '15 andro';

  @override
  String get creditDueDate30d => '30 andro';

  @override
  String get creditDueDateCustom => 'Hifidy daty';

  @override
  String get creditNoteHint => 'Fanamarihana momba ny trosa (tsy voatery)';

  @override
  String creditSaleConfirmation(String amount, String customer) {
    return 'Hamarino ny varotra amin\'ny trosa $amount Ar ho an\'i $customer ?';
  }

  @override
  String get creditSaleSuccess => 'Varotra amin\'ny trosa voatahiry';

  @override
  String get creditSaleCustomerRequired =>
      'Ilaina ny mpanjifa ho an\'ny varotra amin\'ny trosa';

  @override
  String get totalDebts => 'Totalin\'ny trosa';

  @override
  String get overdueDebts => 'Tara';

  @override
  String get creditSalesEmpty => 'Tsy misy varotra amin\'ny trosa';

  @override
  String get creditSalesEmptyDescription =>
      'Ny varotra amin\'ny trosa dia hiseho eto';

  @override
  String get payment => 'Fandoavana';

  @override
  String get paymentTitle => 'Fandoavana';

  @override
  String get paymentSingle => 'Fandoavana tokana';

  @override
  String get paymentSplit => 'Fandoavana maro';

  @override
  String get paymentType => 'Karazana fandoavana';

  @override
  String get paymentCash => 'Vola madinika';

  @override
  String get paymentCard => 'Karatra';

  @override
  String get paymentMvola => 'MVola';

  @override
  String get paymentOrangeMoney => 'Orange Money';

  @override
  String get paymentCredit => 'Trosa';

  @override
  String get paymentTotalToPay => 'Totaliny aloa';

  @override
  String get paymentAmountReceived => 'Vola voaray';

  @override
  String get paymentCustomAmount => 'Na vola manokana';

  @override
  String get paymentCustomAmountHint => 'Vola amin\'ny Ariary';

  @override
  String get paymentChangeDue => 'Vola averina';

  @override
  String get paymentInsufficient => 'Tsy ampy ny vola';

  @override
  String get paymentNoteOptional => 'Fanamarihana (tsy voatery)';

  @override
  String get paymentNoteHint => 'Hanampy fanamarihana amin\'ity varotra ity...';

  @override
  String get paymentNoteHelper =>
      'Ity fanamarihana ity dia hiseho ao amin\'ny resevoka';

  @override
  String get paymentValidate => 'HAMARINO NY FANDOAVANA';

  @override
  String get paymentRemainingAmount => 'Sisa aloa';

  @override
  String get paymentComplete => 'Fandoavana vita';

  @override
  String get paymentPaid => 'Voaloa';

  @override
  String get paymentAdded => 'Fandoavana nampiana';

  @override
  String get paymentAddPayment => 'Hanampy fandoavana';

  @override
  String get paymentSplitDescription => 'Zareo amin\'ny fomba fandoavana maro';

  @override
  String get paymentSplitMethods =>
      'Vola madinika, Karatra, MVola, Orange Money';

  @override
  String get paymentErrorNotAuthenticated =>
      'Hadisoana: tsy voamarina ny mpampiasa';

  @override
  String get paymentErrorStoreSettings =>
      'Hadisoana: tsy afaka nalaina ny fandaminana';

  @override
  String get paymentErrorMvolaMerchant =>
      'Hadisoana: tsy voaomana ny laharan\'ny mpivarotra MVola';

  @override
  String get paymentErrorOrangeMoneyMerchant =>
      'Hadisoana: tsy voaomana ny laharan\'ny mpivarotra Orange Money';

  @override
  String get paymentConfigure => 'Amboary';

  @override
  String get inventoryTitle => 'Fijerin\'ny stock';

  @override
  String get inventoryMetrics => 'Fifehezan-dalàna';

  @override
  String get inventoryOutOfStock => 'Tapaka stock';

  @override
  String get inventoryLowStock => 'Stock ambany';

  @override
  String get inventoryTotalValue => 'Sandan\'ny stock';

  @override
  String get inventoryFilterAll => 'Rehetra';

  @override
  String get inventoryFilterLow => 'Stock ambany';

  @override
  String get inventoryFilterOut => 'Tapaka';

  @override
  String get inventoryEmpty => 'Tsy misy entana ao amin\'ny stock';

  @override
  String get inventoryEmptyDescription =>
      'Ampio ny vokatra miaraka amin\'ny fanaraha-maso stock';

  @override
  String inventoryItemsCount(int count) {
    return '$count entana';
  }

  @override
  String get inventoryQuickEdit => 'Hanova ny stock';

  @override
  String get inventoryCurrentStock => 'Stock ankehitriny';

  @override
  String get inventoryNewStock => 'Stock vaovao';

  @override
  String get inventoryAdjustmentReason => 'Antony';

  @override
  String get inventoryReasonReceive => 'Fandraisana';

  @override
  String get inventoryReasonLoss => 'Very';

  @override
  String get inventoryReasonDamage => 'Simba';

  @override
  String get inventoryReasonCount => 'Fanisana';

  @override
  String get inventoryReasonOther => 'Hafa';

  @override
  String get inventoryAdjustmentNote => 'Fanamarihana (tsy voatery)';

  @override
  String get inventoryAdjustmentSuccess => 'Stock novaina';

  @override
  String inventoryStockUpdated(String name) {
    return 'Stock ny $name novaina';
  }

  @override
  String get inventoryAlertThreshold => 'Fetra fanairana';

  @override
  String get inventoryAlertSet => 'Hamaritra fanairana';

  @override
  String get inventoryAlertUpdated => 'Fanairana stock novaina';

  @override
  String inventoryUnitsRemaining(int count) {
    return '$count sisa';
  }

  @override
  String get inventoryExportPdf => 'Avoaka PDF';

  @override
  String get inventoryExportExcel => 'Avoaka Excel';

  @override
  String get inventoryExportShare => 'Zarao';

  @override
  String get inventoryExportPdfSuccess => 'Inventaire navoaka PDF';

  @override
  String get inventoryExportExcelSuccess => 'Inventaire navoaka Excel';

  @override
  String get inventoryExportPdfLoading => 'Mamorona PDF...';

  @override
  String get inventoryExportExcelLoading => 'Mamorona rakitra Excel...';

  @override
  String get inventoryExportPdfSubject => 'Inventaire - Famoahana PDF';

  @override
  String get inventoryExportExcelSubject => 'Inventaire - Famoahana Excel';

  @override
  String get inventoryExportStoreError =>
      'Tsy afaka navoaka: tsy fantatra ny magazay';

  @override
  String get exportCsv => 'Avoaka CSV';

  @override
  String get exportPdf => 'Avoaka PDF';

  @override
  String get inventorySheet => 'Taratasy fanisana';

  @override
  String get printInventory => 'Printy famintinana';

  @override
  String get exportSuccess => 'Avoaka soa aman-tsara';

  @override
  String get totalItems => 'Vokatra rehetra';

  @override
  String get totalStockValue => 'Sandan\'ny stock (vidiny)';

  @override
  String get totalRetailValue => 'Sandan\'ny fivarotana';

  @override
  String get profitPotential => 'Tombony azo';

  @override
  String get exportingInventory => 'Mamoaka...';

  @override
  String get printingInventory => 'Manonta printy...';

  @override
  String get printerNotConnected => 'Tsy misy printy mifandray';

  @override
  String get exportError => 'Tsy nahomby ny famoahana';

  @override
  String get printError => 'Tsy nahomby ny printy';

  @override
  String get salesHistory => 'Tantaran\'ny varotra';

  @override
  String get searchReceipts => 'Mitady tapakila';

  @override
  String get receiptDetail => 'Antsipiriany momba ny tapakila';

  @override
  String get refund => 'Hamerina vola';

  @override
  String get refundAll => 'Hamerina vola rehetra';

  @override
  String get refundReason => 'Antony ny famerenana vola';

  @override
  String get reasonDefective => 'Vokatra simba';

  @override
  String get reasonError => 'Hadisoana amin\'ny kaonty';

  @override
  String get reasonDissatisfied => 'Mpanjifa tsy afa-po';

  @override
  String get reasonOther => 'Hafa';

  @override
  String get confirmRefund => 'Hamafiso ny famerenana vola';

  @override
  String get confirmRefundMessage =>
      'Azo antoka ve fa te hamerina vola ireo entana ireo? Tsy azo ovana ity hetsika ity.';

  @override
  String get refundSuccess => 'Vita soa aman-tsara ny famerenana vola';

  @override
  String get alreadyRefunded => 'Efa namerina vola ity varotra ity';

  @override
  String get notSynced => 'Tsy synchroniser';

  @override
  String get refunded => 'Namerina vola';

  @override
  String get noStoreSelected => 'Tsy misy fivarotana voafidy';

  @override
  String get today => 'Anio';

  @override
  String get thisWeek => 'Ity herinandro ity';

  @override
  String get all => 'Rehetra';

  @override
  String get items => 'Entana';

  @override
  String get noItems => 'Tsy misy entana';

  @override
  String get employee => 'Mpiasa';

  @override
  String get cashRegister => 'Kaonty';

  @override
  String get tax => 'Hetra';

  @override
  String get discount => 'Fihenam-bidy';

  @override
  String get paymentMethod => 'Fomba fandoavana';

  @override
  String get cash => 'Vola madinika';

  @override
  String get print => 'Manonta';

  @override
  String get sendWhatsApp => 'Alefa amin\'ny WhatsApp';

  @override
  String get originalItems => 'Entana tany am-boalohany';

  @override
  String get itemsToRefund => 'Entana haverina vola';

  @override
  String get selectItemsToRefund => 'Safidio ny entana haverina vola';

  @override
  String get noItemsSelected => 'Tsy misy entana voafidy';

  @override
  String get noteOptional => 'Fanamarihana (tsy voatery)';

  @override
  String get totalToRefund => 'Totalin\'ny haverina vola';

  @override
  String get changeDueLabel => 'Ambim-bola averina :';

  @override
  String get changeCustomer => 'Hanova';

  @override
  String get paymentOther => 'Hafa';

  @override
  String get importItems => 'Hampiditra vokatra';

  @override
  String get importItemsDescription =>
      'Ampidiro ny vokatra avy amin\'ny rakitra CSV na Excel.\nAlao aloha ny template mba hahitana ny endrika takiana.';

  @override
  String get selectFile => 'Hisafidy rakitra';

  @override
  String get downloadTemplate => 'Hisintona ny template';

  @override
  String get fileFormat => 'Endrika ny rakitra';

  @override
  String get fileFormatDescription =>
      'Ny rakitra dia tokony ahitana ireto tsanganana ireto: Anarana, SKU, Barcode, Sokajy, Vidiny, Vidin\'ny fividianana, Stock, Fetra fanairana, Famaritana.\nNy Anarana sy ny Vidiny ihany no tsy maintsy.';

  @override
  String get parsingFile => 'Mandinika ny rakitra...';

  @override
  String get valid => 'Marina';

  @override
  String get errors => 'Fahadisoana';

  @override
  String importValidRows(int count) {
    return 'Hampiditra vokatra $count marina';
  }

  @override
  String get importing => 'Fampidirana...';

  @override
  String get importComplete => 'Vita ny fampidirana';

  @override
  String importSuccessMessage(int success, int total) {
    return 'Vokatra $success nampidirina tamin\'ny $total';
  }

  @override
  String importErrorsMessage(int count) {
    return 'Andalana $count misy fahadisoana tsy nampidirina';
  }

  @override
  String get help => 'Fanampiana';

  @override
  String get importHelpText =>
      'Torolalana fampidirana:\n\n1. Alao ny template CSV\n2. Fenoy ny vokatra (Anarana sy Vidiny tsy maintsy)\n3. Tehirizo ny rakitra amin\'ny endrika CSV na Excel\n4. Ampidiro ny rakitra ao amin\'ny application\n5. Jereo ny angon-drakitra alohan\'ny hanamafisana\n\nEndrika raisina: CSV, XLSX, XLS\n\nTorohevitra:\n- Ny SKU dia tokony tsy misy mitovy\n- Ny vidiny sy ny vidin\'ny fividianana dia amin\'ny Ariary (isa integer)\n- Ny sokajy dia tokony efa misy ao amin\'ny application\n- Ny andalana tsy marina dia ho ambara alohan\'ny fampidirana';

  @override
  String get adjustmentNewTitle => 'Fanitsiana vaovao';

  @override
  String get adjustmentListTitle => 'Fanitsiana ny tahiry';

  @override
  String get adjustmentSelectReason => 'Antony fanitsiana';

  @override
  String get adjustmentSearchItems => 'Tadiavo vokatra';

  @override
  String get adjustmentAddItems => 'Ampio vokatra';

  @override
  String get adjustmentNoItems => 'Tsy misy vokatra nampiana';

  @override
  String get adjustmentNoItemsHint =>
      'Tadiavo sy ampio vokatra hanaovana fanitsiana';

  @override
  String get adjustmentCurrentStock => 'Tahiry ankehitriny';

  @override
  String get adjustmentVariation => 'Fiovana';

  @override
  String get adjustmentStockAfter => 'Tahiry aorian\'ny';

  @override
  String get adjustmentValidate => 'Hamarino ny fanitsiana';

  @override
  String get adjustmentCreated => 'Fanitsiana noforonina soa aman-tsara';

  @override
  String get adjustmentEmptyList => 'Tsy misy fanitsiana';

  @override
  String get adjustmentEmptyDescription =>
      'Ny fanitsiana tahiry dia hiseho eto';

  @override
  String get adjustmentFilterAll => 'Rehetra';

  @override
  String adjustmentItemsCount(int count) {
    return '$count vokatra';
  }

  @override
  String get adjustmentTotalVariation => 'Fiovana tanteraka';

  @override
  String adjustmentBy(String employee) {
    return 'Nataon\'i $employee';
  }

  @override
  String get historyTitle => 'Tantara';

  @override
  String get historyEmpty => 'Tsy misy fihetsiketsehana';

  @override
  String get historyEmptyDescription =>
      'Ny tantaran\'ny fihetsiketsehana tahiry dia hiseho eto';

  @override
  String get historyFilterPeriod => 'Vanim-potoana';

  @override
  String get historyFilterLast7Days => '7 andro farany';

  @override
  String get historyFilterLast30Days => '30 andro farany';

  @override
  String get historyFilterThisMonth => 'Ity volana ity';

  @override
  String get historyFilterCustom => 'Safidy manokana';

  @override
  String historyOn(String date) {
    return 'Ny $date';
  }

  @override
  String get inventoryCountsTitle => 'Fanisana tahiry';

  @override
  String get inventoryCountsEmpty => 'Tsy misy fanisana';

  @override
  String get inventoryCountsEmptyDescription =>
      'Ny fanisana ara-batana dia hiseho eto';

  @override
  String get inventoryCountsFilterAll => 'Rehetra';

  @override
  String get inventoryCountsFilterPending => 'Miandry';

  @override
  String get inventoryCountsFilterInProgress => 'Mandeha';

  @override
  String get inventoryCountsFilterCompleted => 'Vita';

  @override
  String get inventoryCountTypeFull => 'Feno';

  @override
  String get inventoryCountTypePartial => 'Ampahany';

  @override
  String get inventoryCountStatusPending => 'Miandry';

  @override
  String get inventoryCountStatusInProgress => 'Mandeha';

  @override
  String get inventoryCountStatusCompleted => 'Vita';

  @override
  String inventoryCountItemsCount(int count) {
    return '$count vokatra';
  }

  @override
  String inventoryCountCreatedBy(String employee) {
    return 'Nataon\'i $employee';
  }

  @override
  String get newInventoryCountTitle => 'Fanisana vaovao';

  @override
  String get newInventoryCountTypeLabel => 'Karazana fanisana';

  @override
  String get newInventoryCountTypeFullTitle => 'Fanisana feno';

  @override
  String get newInventoryCountTypeFullDescription =>
      'Hanisa ny vokatra rehetra ao an-trano fivarotana';

  @override
  String get newInventoryCountTypePartialTitle => 'Fanisana ampahany';

  @override
  String get newInventoryCountTypePartialDescription =>
      'Hanisa vokatra sasany ihany';

  @override
  String get newInventoryCountNotes => 'Fanamarihana (tsy voatery)';

  @override
  String get newInventoryCountNotesHint =>
      'Ampio fanamarihana momba ity fanisana ity';

  @override
  String get newInventoryCountSelectItems => 'Safidio ny vokatra hisaina';

  @override
  String get newInventoryCountSearchItems => 'Tadiavo vokatra';

  @override
  String get newInventoryCountNoItemsSelected => 'Tsy misy vokatra voafidy';

  @override
  String newInventoryCountItemsSelected(int count) {
    return '$count vokatra voafidy';
  }

  @override
  String get newInventoryCountStartCounting => 'Atombohy ny fanisana';

  @override
  String newInventoryCountCurrentStock(String stock) {
    return 'Tahiry ankehitriny : $stock';
  }

  @override
  String get inventoryCountingTitle => 'Fanisana mandeha';

  @override
  String inventoryCountingProgress(int counted, int total) {
    return '$counted / $total voaisa';
  }

  @override
  String get inventoryCountingTotalItems => 'Vokatra rehetra';

  @override
  String get inventoryCountingCounted => 'Voaisa';

  @override
  String get inventoryCountingDiscrepancies => 'Tsy mitovy';

  @override
  String get inventoryCountingSearchItems => 'Tadiavo vokatra';

  @override
  String get inventoryCountingScanBarcode => 'Zahao ny barcode';

  @override
  String get inventoryCountingExpectedStock => 'Tahiry andrasana';

  @override
  String get inventoryCountingCountedStock => 'Tahiry voaisa';

  @override
  String get inventoryCountingDifference => 'Tsy mitovy';

  @override
  String get inventoryCountingEnterQuantity => 'Ampidiro ny isa';

  @override
  String get inventoryCountingComplete => 'Vita ny fanisana';

  @override
  String get inventoryCountingConfirmTitle => 'Vita ny fanisana?';

  @override
  String inventoryCountingConfirmMessage(
    int total,
    int counted,
    int discrepancies,
    String difference,
  ) {
    return 'Famintinana ny fanisana:\n\n• Vokatra rehetra : $total\n• Vokatra voaisa : $counted\n• Tsy mitovy hita : $discrepancies\n• Tsy mitovy tanteraka : $difference\n\nTe hamita ity fanisana ity ve ianao?';
  }

  @override
  String get inventoryCountingConfirmYes => 'Vita';

  @override
  String get inventoryCountingCompleted => 'Vita soa aman-tsara ny fanisana';

  @override
  String get inventoryCountingNotAllCounted =>
      'Ny vokatra rehetra dia tokony voaisa alohan\'ny hamitana';

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
}
