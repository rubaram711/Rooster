import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rooster_app/Backend/TermsAndConditions/get_terms_and_conditions.dart';
import 'package:rooster_app/Backend/SalesInvoiceBackend/store_sales_invoice.dart';
import 'package:rooster_app/Controllers/payment_terms_controller.dart';
import 'package:rooster_app/Controllers/pending_docs_review_controller.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Controllers/sales_invoice_controller.dart';
import 'package:rooster_app/Controllers/warehouse_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/Screens/Combo/combo.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/create_product_dialog.dart';
import 'package:rooster_app/Screens/SalesInvoice/print_sales_invoice.dart';
import 'package:rooster_app/Widgets/dialog_title.dart';
import 'package:rooster_app/Widgets/loading.dart';
import 'package:rooster_app/const/functions.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Screens/Client/create_client_dialog.dart';
import 'package:rooster_app/Widgets/reusable_drop_down_menu.dart';
import 'package:rooster_app/Widgets/table_item.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Widgets/HomeWidgets/home_app_bar.dart';
import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../Widgets/TransferWidgets/under_item_btn.dart';
import '../../Widgets/dialog_drop_menu.dart';
import '../../Widgets/reusable_radio_btns.dart';
import '../../Widgets/reusable_reference_text_field.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_more.dart';
import '../../Widgets/table_title.dart';
import '../../Widgets/TransferWidgets/reusable_show_info_card.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../../const/constants.dart';
import 'package:flutter_quill/quill_delta.dart';

class CreateNewSalesInvoice extends StatefulWidget {
  const CreateNewSalesInvoice({super.key});

  @override
  State<CreateNewSalesInvoice> createState() => _CreateNewSalesInvoiceState();
}

class _CreateNewSalesInvoiceState extends State<CreateNewSalesInvoice> {
  String itemName = '';
  double itemPrice = 0;
  double itemTotal = 0;
  double totalAllItems = 0;
  String itemBrand = '';
  String itemImage = '';
  String itemDescription = '';
  String qty = '0.0';
  double discountOnAllItem = 0.0;
  double totalPriceAfterDiscount = 0.0;
  double additionalSpecialDiscount = 0.0;
  double totalPriceAfterSpecialDiscount = 0.0;
  double totalPriceAfterSpecialDiscountBysalesInvoiceCurrency = 0.0;
  double vatBySalesInvoiceCurrency = 0.0;
  double finalPriceBySalesInvoiceCurrency = 0.0;
  List itemsInfoPrint = [];
  Map salesInvoiceItemInfo = {};

  String brand = '';

  String selectedSalesPerson = '';
  int selectedSalesPersonId = 0;
  TextEditingController globalDiscPercentController = TextEditingController();
  TextEditingController specialDiscPercentController = TextEditingController();
  TextEditingController controller = TextEditingController();
  TextEditingController salesPersonController = TextEditingController();
  TextEditingController commissionController = TextEditingController();
  TextEditingController currencyController = TextEditingController();

  TextEditingController totalCommissionController = TextEditingController();
  TextEditingController refController = TextEditingController();
  TextEditingController validityController = TextEditingController();
  TextEditingController inputDateController = TextEditingController();
  TextEditingController clientNameController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  TextEditingController vatExemptController = TextEditingController();

  TextEditingController paymentTermsController = TextEditingController();
  TextEditingController priceConditionController = TextEditingController();
  TextEditingController priceListController = TextEditingController();

  TextEditingController termsAndConditionsController = TextEditingController();
  TextEditingController cashingMethodsController = TextEditingController();
  TextEditingController deliverFromWarehouse = TextEditingController();

  // 'exempted from vat ,printed as "vat exempted"',
  // 'exempted from vat ,printed as "vat 0 % = 0"',
  // 'exempted from vat , no printed ',
  // bool isVatExemptChecked = false;

  // String selectedVatExemptListTrue = '';
  String globalDiscountPercentage = ''; // user insert this value
  String specialDiscountPercentage = ''; // user insert this value

  String selectedPaymentTerm = '',
      selectedCurrency = '',
      termsAndConditions = '',
      specialDisc = '',
      globalDisc = '';

  int currentStep = 0;
  int selectedTabIndex = 0;
  List tabsList = ['order_lines', 'sales_commissions'];

  String selectedTab = 'order_lines'.tr;

  double listViewLength = Sizes.deviceHeight * 0.08;
  double increment = Sizes.deviceHeight * 0.08;

  bool isActiveVatChecked = false;
  bool isActiveDeliveredChecked = false;
  final SalesInvoiceController salesInvoiceController = Get.find();
  bool isNumberOrderedUp = true;
  bool isCreationOrderedUp = true;
  bool isCustomerOrderedUp = true;
  bool isSalespersonOrderedUp = true;
  String cashMethodId = '';
  String clientId = '';
  String pricelistId = '';
  String salespersonId = ' ';
  String commissionMethodId = '';
  String currencyId = ' ';
  bool isPendingDocsFetched = false;
  final PendingDocsReviewController pendingDocsController = Get.find();
  final HomeController homeController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();
  WarehouseController warehouseController = Get.find();
  PaymentTermsController paymentController = Get.find();

  int progressVar = 0;
  String selectedCustomerIds = '';

  setVars() async {
    setState(() {
      selectedPaymentTerm = '';
      selectedCurrency = '';
      termsAndConditions = '';
      specialDisc = '';
      globalDisc = '';
      currentStep = 0;
      selectedTabIndex = 0;
      progressVar = 0;
      selectedCustomerIds = '';
      currencyController.text = '';
    });
  }

  getCurrency() async {
    await exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();
    currencyController.text = 'USD';
    int index = exchangeRatesController.currenciesNamesList.indexOf('USD');
    salesInvoiceController.selectedCurrencyId =
        exchangeRatesController.currenciesIdsList[index];
    salesInvoiceController.selectedCurrencySymbol =
        exchangeRatesController.currenciesSymbolsList[index];
    salesInvoiceController.selectedCurrencyName = 'USD';
    var vat = await getCompanyVatFromPref();
    salesInvoiceController.setCompanyVat(double.parse(vat));
    var companyCurrency = await getCompanyPrimaryCurrencyFromPref();
    var companyCurrencyLatestRate =
        await getPrimaryCurrencyLatestRateFromPref();
    salesInvoiceController.setCompanyPrimaryCurrency(companyCurrency);
    salesInvoiceController.setLatestRate(
      double.parse(companyCurrencyLatestRate),
    );
  }

  checkVatExempt() async {
    var companySubjectToVat = await getCompanySubjectToVatFromPref();
    if (companySubjectToVat == '1') {
      vatExemptController.clear();
      salesInvoiceController.setIsVatExempted(false, false, false);
      salesInvoiceController.setIsVatExemptCheckBoxShouldAppear(true);
    } else {
      salesInvoiceController.setIsVatExemptCheckBoxShouldAppear(false);
      salesInvoiceController.setIsVatExempted(false, false, true);
      salesInvoiceController.setIsVatExemptChecked(true);
    }
  }

  Future<void> generatePdfFromImageUrl() async {
    String companyLogo = await getCompanyLogoFromPref();

    // 1. Download image
    final response = await http.get(Uri.parse(companyLogo));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    final Uint8List imageBytes = response.bodyBytes;
    salesInvoiceController.setLogo(imageBytes);
  }

  late QuillController _controller;
  String? _savedContent;

  void _saveContent() {
    final deltaJson = _controller.document.toDelta().toJson();
    final jsonString = jsonEncode(deltaJson);

    setState(() {
      _savedContent = jsonString;
    });

    // You can now send `jsonString` to your backend
    termsAndConditionsController.text = jsonString;
  }



  List termsAndConditionsList = [];
  int currentIndex = 0;
  getAllTermsAndConditions() async {
    var res = await getTermsAndConditions();
    if (res['success'] == true) {
      termsAndConditionsList = res['data'];
      termsAndConditionsList = termsAndConditionsList.reversed.toList();
    }
  }

  void _loadContent() {
    if (_savedContent == null) return;

    final delta = Delta.fromJson(jsonDecode(_savedContent!));
    final doc = Document.fromDelta(delta);

    setState(() {
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    });
  }

  showLastTermsAndConditionsList() {
    setState(() {
      if (currentIndex < termsAndConditionsList.length) {
        _savedContent =
            '${termsAndConditionsList[currentIndex]['terms_and_conditions']}'
                    .startsWith('[{')
                ? termsAndConditionsList[currentIndex]['terms_and_conditions']
                : '[{"insert":"\n"}]';
        _loadContent();
        currentIndex++;
      } else {
        CommonWidgets.snackBar('error', 'The list is over');
      }
    });
  }

  @override
  void initState() {
    salesInvoiceController
        .rowsInListViewInSalesInvoice={};
    salesInvoiceController.orderedKeys=[];
    _controller = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    generatePdfFromImageUrl();
    checkVatExempt();
    salesInvoiceController.isVatExemptChecked = false;
    salesInvoiceController.itemsMultiPartList = [];
    salesInvoiceController.salesPersonListNames = [];
    salesInvoiceController.salesPersonListId = [];
    salesInvoiceController.isBeforeVatPrices = true;
    priceConditionController.text = 'Prices are before vat';
    warehouseController.getWarehousesFromBack();
    warehouseController.resetWarehouse();

    salesInvoiceController.getAllUsersSalesPersonFromBack();
    salesInvoiceController.getAllTaxationGroupsFromBack();
    setVars();
    salesInvoiceController.getFieldsForCreateSalesInvoiceFromBack();
    getCurrency();
    salesInvoiceController.resetSalesInvoice();
    warehouseController.resetWarehouse();
    salesInvoiceController.warehouseMenuController.text = '';
    salesInvoiceController.listViewLengthInSalesInvoice = 50;
    validityController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    inputDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    priceListController.text = 'STANDARD';
    getAllTermsAndConditions();
    pendingDocsController.getAllPendingDocs();
    paymentController.getPaymentTermsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesInvoiceController>(
      builder: (salesInvoiceCont) {
        return salesInvoiceCont.isSalesInvoiceInfoFetched
            ? Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              height: MediaQuery.of(context).size.height * 0.85,
              child: SingleChildScrollView(
                child: GetBuilder<HomeController>(
                  builder: (homeCont) {
                    double referenceRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.16
                            : MediaQuery.of(context).size.width * 0.20;
                    double referenceFieldWidth =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.13
                            : MediaQuery.of(context).size.width * 0.17;
                    double currencyRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.12
                            : MediaQuery.of(context).size.width * 0.15;
                    double currencyFieldWidth =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.07
                            : MediaQuery.of(context).size.width * 0.11;
                    double validityRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width * 0.18;
                    double validityFieldWidth =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.10
                            : MediaQuery.of(context).size.width * 0.12;
                    double priceListRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width * 0.24;
                    double priceListFieldWidth =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.10
                            : MediaQuery.of(context).size.width * 0.15;
                    double inputDateRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width * 0.20;
                    double inputDateFieldWidth =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.10
                            : MediaQuery.of(context).size.width * 0.15;
                    double codeRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.30
                            : MediaQuery.of(context).size.width * 0.42;
                    double codeInnerRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width * 0.19;
                    double codeFieldWidth =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.12
                            : MediaQuery.of(context).size.width * 0.16;
                    double searchRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width * 0.23;
                    double searchFieldWidth =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.14
                            : MediaQuery.of(context).size.width * 0.22;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [PageTitle(text: 'create_invoice'.tr)],
                        ),
                        gapH16,
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.05,

                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    UnderTitleBtn(
                                      text: 'preview'.tr,
                                      onTap: () async {
                                        setState(() {
                                          progressVar = 1;
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              List itemsInfoPrint = [];
                                              for (var item
                                                  in salesInvoiceCont
                                                      .rowsInListViewInSalesInvoice
                                                      .values) {
                                                if ('${item['line_type_id']}' ==
                                                    '2') {
                                                  var qty =
                                                      item['item_quantity'];
                                                  var map =
                                                      salesInvoiceCont
                                                          .itemsMap[item['item_id']
                                                          .toString()];
                                                  var itemName =
                                                      map['item_name'];
                                                  var itemPrice = double.parse(
                                                    '${item['item_unit_price'] ?? 0.0}',
                                                  );
                                                  var itemDescription =
                                                      item['item_description'];

                                                  var itemImage =
                                                      '${map['images']}' != '[]'
                                                          ? map['images'][0]
                                                          : '';
                                                  var firstBrandObject =
                                                      map['itemGroups'].firstWhere(
                                                        (obj) =>
                                                            obj["root_name"]
                                                                ?.toLowerCase() ==
                                                            "brand"
                                                                .toLowerCase(),
                                                        orElse: () => null,
                                                      );
                                                  var brand =
                                                      firstBrandObject == null
                                                          ? ''
                                                          : firstBrandObject['name'] ??
                                                              '';
                                                  var itemTotal = double.parse(
                                                    '${item['item_total']}',
                                                  );
                                                  // double.parse(qty) * itemPrice;
                                                  var quotationItemInfo = {
                                                    'line_type_id': '2',
                                                    'item_name': itemName,
                                                    'item_description':
                                                        itemDescription,
                                                    'item_quantity': qty,
                                                    'item_unit_price':
                                                        formatDoubleWithCommas(
                                                          itemPrice,
                                                        ),
                                                    'item_discount':
                                                        item['item_discount'] ??
                                                        '0',
                                                    'item_total':
                                                        formatDoubleWithCommas(
                                                          itemTotal,
                                                        ),
                                                    'item_image': itemImage,
                                                    'item_brand': brand,

                                                    'combo_image': '',
                                                    'combo_brand': '',
                                                    'title': '',
                                                    'isImageList': true,
                                                    'note': '',
                                                    'image': '',
                                                  };
                                                  itemsInfoPrint.add(
                                                    quotationItemInfo,
                                                  );
                                                } else if ('${item['line_type_id']}' ==
                                                    '3') {
                                                  var qty =
                                                      item['item_quantity'];
                                                  // var map =
                                                  //     quotationCont
                                                  //         .combosMap[item['combo']
                                                  //         .toString()];
                                                  var ind = salesInvoiceCont
                                                      .combosIdsList
                                                      .indexOf(
                                                        item['combo']
                                                            .toString(),
                                                      );
                                                  var itemName =
                                                      salesInvoiceCont
                                                          .combosNamesList[ind];
                                                  var itemPrice = double.parse(
                                                    '${item['item_unit_price'] ?? 0.0}',
                                                  );
                                                  var itemDescription =
                                                      item['item_description'];

                                                  var itemTotal = double.parse(
                                                    '${item['item_total']}',
                                                  );
                                                  var combosmap =
                                                      salesInvoiceCont
                                                          .combosMap[item['combo']
                                                          .toString()];
                                                  var comboImage =
                                                      '${combosmap['image']}' !=
                                                                  '' &&
                                                              combosmap['image'] !=
                                                                  null &&
                                                              combosmap['image']
                                                                  .isNotEmpty
                                                          ? '${combosmap['image']}'
                                                          : '';
                                                  var combobrand =
                                                      combosmap['brand'] ??
                                                      '---';
                                                  totalAllItems += itemTotal;
                                                  // double.parse(qty) * itemPrice;
                                                  var quotationItemInfo = {
                                                    'line_type_id': '3',
                                                    'item_name': itemName,
                                                    'item_description':
                                                        itemDescription,
                                                    'item_quantity': qty,
                                                    'item_unit_price':
                                                        formatDoubleWithCommas(
                                                          itemPrice,
                                                        ),
                                                    'item_discount':
                                                        item['item_discount'] ??
                                                        '0',
                                                    'item_total':
                                                        formatDoubleWithCommas(
                                                          itemTotal,
                                                        ),
                                                    'note': '',
                                                    'item_image': '',
                                                    'item_brand': '',
                                                    'combo_image': comboImage,
                                                    'combo_brand': combobrand,
                                                    'isImageList': true,
                                                    'title': '',
                                                    'image': '',
                                                  };
                                                  itemsInfoPrint.add(
                                                    quotationItemInfo,
                                                  );
                                                } else if ('${item['line_type_id']}' ==
                                                    '1') {
                                                  var quotationItemInfo = {
                                                    'line_type_id': '1',
                                                    'item_name': '',
                                                    'item_description': '',
                                                    'item_quantity': '',
                                                    'item_unit_price': '',
                                                    'item_discount': '0',
                                                    'item_total': '',
                                                    'item_image': '',
                                                    'item_brand': '',
                                                    'combo_image': '',
                                                    'combo_brand': '',
                                                    'note': '',
                                                    'isImageList': true,
                                                    'title': item['title'],
                                                    'image': '',
                                                  };
                                                  itemsInfoPrint.add(
                                                    quotationItemInfo,
                                                  );
                                                } else if ('${item['line_type_id']}' ==
                                                    '5') {
                                                  var quotationItemInfo = {
                                                    'line_type_id': '5',
                                                    'item_name': '',
                                                    'item_description': '',
                                                    'item_quantity': '',
                                                    'item_unit_price': '',
                                                    'item_discount': '0',
                                                    'item_total': '',
                                                    'item_image': '',
                                                    'item_brand': '',
                                                    'combo_image': '',
                                                    'combo_brand': '',
                                                    'title': '',
                                                    'note': item['note'],
                                                    'image': '',
                                                    'isImageList': true,
                                                  };
                                                  itemsInfoPrint.add(
                                                    quotationItemInfo,
                                                  );
                                                } else if ('${item['line_type_id']}' ==
                                                    '4') {
                                                  var quotationItemInfo = {
                                                    'line_type_id': '4',
                                                    'item_name': '',
                                                    'item_description': '',
                                                    'item_quantity': '',
                                                    'item_unit_price': '',
                                                    'item_discount': '0',
                                                    'item_total': '',
                                                    'item_image': '',
                                                    'item_brand': '',
                                                    'combo_image': '',
                                                    'combo_brand': '',
                                                    'title': '',
                                                    'note': '',
                                                    'image': item['image'],
                                                    'isImageList': true,
                                                  };
                                                  itemsInfoPrint.add(
                                                    quotationItemInfo,
                                                  );
                                                }
                                              }

                                              return PrintSalesInvoice(
                                                vat: salesInvoiceCont.vat11,
                                                fromPage: 'createSi',

                                                quotationNumber: '',
                                                salesOrderNumber: '',
                                                isPrintedAs0:
                                                    salesInvoiceCont
                                                        .isPrintedAs0,
                                                isVatNoPrinted:
                                                    salesInvoiceCont
                                                        .isVatNoPrinted,
                                                isPrintedAsVatExempt:
                                                    salesInvoiceCont
                                                        .isPrintedAsVatExempt,
                                                isInSalesInvoice: false,
                                                salesInvoiceNumber:
                                                    salesInvoiceCont
                                                        .salesInvoiceNumber,
                                                creationDate:
                                                    validityController.text,
                                                ref: refController.text,
                                                receivedUser: '',
                                                senderUser:
                                                    homeController.userName,
                                                status: '',
                                                totalBeforeVat:
                                                    salesInvoiceCont.totalItems
                                                        .toString(),
                                                discountOnAllItem:
                                                    salesInvoiceCont
                                                        .preGlobalDisc
                                                        .toString(),
                                                totalAllItems:
                                                    formatDoubleWithCommas(
                                                      salesInvoiceCont
                                                          .totalItems,
                                                    ),
                                                globalDiscount:
                                                    globalDiscPercentController
                                                        .text,
                                                //widget.info['globalDiscount'] ?? '0',
                                                totalPriceAfterDiscount:
                                                    salesInvoiceCont
                                                                .preGlobalDisc ==
                                                            0.0
                                                        ? formatDoubleWithCommas(
                                                          salesInvoiceCont
                                                              .totalItems,
                                                        )
                                                        : formatDoubleWithCommas(
                                                          salesInvoiceCont
                                                              .totalAfterGlobalDis,
                                                        ),
                                                additionalSpecialDiscount:
                                                    salesInvoiceCont
                                                        .preSpecialDisc
                                                        .toStringAsFixed(2),
                                                totalPriceAfterSpecialDiscount:
                                                    salesInvoiceCont
                                                                .preSpecialDisc ==
                                                            0
                                                        ? formatDoubleWithCommas(
                                                          salesInvoiceCont
                                                              .totalItems,
                                                        )
                                                        : formatDoubleWithCommas(
                                                          salesInvoiceCont
                                                              .totalAfterGlobalSpecialDis,
                                                        ),
                                                totalPriceAfterSpecialDiscountBySalesInvoiceCurrency:
                                                    salesInvoiceCont
                                                                .preSpecialDisc ==
                                                            0
                                                        ? formatDoubleWithCommas(
                                                          salesInvoiceCont
                                                              .totalItems,
                                                        )
                                                        : formatDoubleWithCommas(
                                                          salesInvoiceCont
                                                              .totalAfterGlobalSpecialDis,
                                                        ),

                                                vatBySalesInvoiceCurrency:
                                                    formatDoubleWithCommas(
                                                      double.parse(
                                                        salesInvoiceCont.vat11,
                                                      ),
                                                    ),
                                                finalPriceBySalesInvoiceCurrency:
                                                    formatDoubleWithCommas(
                                                      double.parse(
                                                        salesInvoiceCont
                                                            .totalSalesInvoice,
                                                      ),
                                                    ),
                                                specialDisc:
                                                    specialDisc.toString(),
                                                specialDiscount:
                                                    specialDiscPercentController
                                                        .text,
                                                specialDiscountAmount:
                                                    salesInvoiceCont
                                                        .specialDisc,
                                                salesPerson:
                                                    selectedSalesPerson,
                                                salesInvoiceCurrency:
                                                    salesInvoiceCont
                                                        .selectedCurrencyName,
                                                salesInvoiceCurrencySymbol:
                                                    salesInvoiceCont
                                                        .selectedCurrencySymbol,
                                                salesInvoiceCurrencyLatestRate:
                                                    salesInvoiceCont
                                                        .exchangeRateForSelectedCurrency,
                                                clientPhoneNumber:
                                                    salesInvoiceCont
                                                        .phoneNumber[selectedCustomerIds] ??
                                                    '---',
                                                clientName:
                                                    clientNameController.text,
                                                termsAndConditions:
                                                    termsAndConditionsController
                                                        .text,
                                                itemsInfoPrint: itemsInfoPrint,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    UnderTitleBtn(
                                      text: 'send_proforma_inv'.tr,
                                      onTap: () async {
                                        setState(() {
                                          progressVar = 2;
                                        });
                                        salesInvoiceCont.setStatus('sent');
                                        bool hasType1WithEmptyTitle =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '1' &&
                                                      (map['title']?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType2WithEmptyId =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '2' &&
                                                      (map['item_id']
                                                              ?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType3WithEmptyId =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '3' &&
                                                      (map['combo']?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType4WithEmptyImage =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '4' &&
                                                      (map['image'] ==
                                                              Uint8List(0) ||
                                                          map['image']
                                                              ?.isEmpty);
                                                });
                                        bool hasType5WithEmptyNote =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '5' &&
                                                      (map['note']?.isEmpty ??
                                                          true);
                                                });
                                        if (salesInvoiceController
                                            .rowsInListViewInSalesInvoice
                                            .isEmpty) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'Order lines is Empty',
                                          );
                                        } else if (hasType2WithEmptyId) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty item',
                                          );
                                        } else if (hasType3WithEmptyId) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty combo',
                                          );
                                        } else if (hasType1WithEmptyTitle) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty title',
                                          );
                                        } else if (hasType4WithEmptyImage) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty image',
                                          );
                                        } else if (hasType5WithEmptyNote) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty note',
                                          );
                                        } else {
                                          var res = await storeSalesInvoice(
                                            refController.text,
                                            selectedCustomerIds,
                                            validityController.text,
                                            inputDateController.text,
                                            salesInvoiceCont
                                                .selectedWarehouseId,
                                            salesInvoiceCont.selectedPaymentTermId,
                                            salesInvoiceCont.salesInvoiceNumber,
                                            salesInvoiceCont
                                                .selectedPriceListId,
                                            salesInvoiceCont
                                                .selectedCurrencyId, //selectedCurrency
                                            termsAndConditionsController.text,
                                            selectedSalesPersonId.toString(),
                                            '', // commission method id
                                            salesInvoiceCont
                                                .selectedCashingMethodId,
                                            commissionController.text,
                                            totalCommissionController.text,
                                            salesInvoiceController.totalItems
                                                .toString(), //total before vat
                                            specialDiscPercentController
                                                .text, // inserted by user
                                            salesInvoiceController
                                                .specialDisc, // calculated
                                            globalDiscPercentController.text,
                                            salesInvoiceController.globalDisc,
                                            salesInvoiceController.vat11
                                                .toString(), //vat
                                            salesInvoiceController
                                                .vatInPrimaryCurrency
                                                .toString(), //vatLebanese
                                            salesInvoiceController
                                                .totalSalesInvoice, //total

                                            salesInvoiceCont.isVatExemptChecked
                                                ? '1'
                                                : '0',
                                            salesInvoiceCont.isVatNoPrinted
                                                ? '1'
                                                : '0', //not printed
                                            salesInvoiceCont
                                                    .isPrintedAsVatExempt
                                                ? '1'
                                                : '0', //printedAsVatExempt
                                            salesInvoiceCont.isPrintedAs0
                                                ? '1'
                                                : '0', //printedAsPercentage
                                            salesInvoiceCont.isBeforeVatPrices
                                                ? '0'
                                                : '1', //vatInclusivePrices
                                            salesInvoiceCont.isBeforeVatPrices
                                                ? '1'
                                                : '0', //beforeVatPrices
                                            codeController.text, //code
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice,
                                            salesInvoiceController.orderedKeys,
                                            salesInvoiceController.selectedInvoiceType,
                                              '${salesInvoiceCont.selectedHeader['id']}'
                                          );
                                          if (res['success'] == true) {
                                            CommonWidgets.snackBar(
                                              'Success',
                                              res['message'],
                                            );
                                            homeController.selectedTab.value =
                                                'to_deliver';
                                          } else {
                                            CommonWidgets.snackBar(
                                              'error',
                                              res['message'],
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    UnderTitleBtn(
                                      text: 'send_invoice'.tr,
                                      onTap: () async {
                                        setState(() {
                                          progressVar = 3;
                                        });
                                        salesInvoiceCont.setStatus('sent');
                                        bool hasType1WithEmptyTitle =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '1' &&
                                                      (map['title']?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType2WithEmptyId =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '2' &&
                                                      (map['item_id']
                                                              ?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType3WithEmptyId =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '3' &&
                                                      (map['combo']?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType4WithEmptyImage =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '4' &&
                                                      (map['image'] ==
                                                              Uint8List(0) ||
                                                          map['image']
                                                              ?.isEmpty);
                                                });
                                        bool hasType5WithEmptyNote =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '5' &&
                                                      (map['note']?.isEmpty ??
                                                          true);
                                                });
                                        if (salesInvoiceController
                                            .rowsInListViewInSalesInvoice
                                            .isEmpty) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'Order lines is Empty',
                                          );
                                        } else if (hasType2WithEmptyId) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty item',
                                          );
                                        } else if (hasType3WithEmptyId) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty combo',
                                          );
                                        } else if (hasType1WithEmptyTitle) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty title',
                                          );
                                        } else if (hasType4WithEmptyImage) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty image',
                                          );
                                        } else if (hasType5WithEmptyNote) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty note',
                                          );
                                        } else {
                                          var res = await storeSalesInvoice(
                                            refController.text,
                                            selectedCustomerIds,
                                            validityController.text,
                                            inputDateController.text,
                                            salesInvoiceCont
                                                .selectedWarehouseId,
                                            salesInvoiceCont.selectedPaymentTermId,
                                            salesInvoiceCont.salesInvoiceNumber,
                                            salesInvoiceCont
                                                .selectedPriceListId,
                                            salesInvoiceCont
                                                .selectedCurrencyId, //selectedCurrency
                                            termsAndConditionsController.text,
                                            selectedSalesPersonId.toString(),
                                            '', // commission method id
                                            salesInvoiceCont
                                                .selectedCashingMethodId,
                                            commissionController.text,
                                            totalCommissionController.text,
                                            salesInvoiceController.totalItems
                                                .toString(), //total before vat
                                            specialDiscPercentController
                                                .text, // inserted by user
                                            salesInvoiceController
                                                .specialDisc, // calculated
                                            globalDiscPercentController.text,
                                            salesInvoiceController.globalDisc,
                                            salesInvoiceController.vat11
                                                .toString(), //vat
                                            salesInvoiceController
                                                .vatInPrimaryCurrency
                                                .toString(), //vatLebanese
                                            salesInvoiceController
                                                .totalSalesInvoice, //total

                                            salesInvoiceCont.isVatExemptChecked
                                                ? '1'
                                                : '0', //vat
                                            salesInvoiceCont.isVatNoPrinted
                                                ? '1'
                                                : '0', //not printed
                                            salesInvoiceCont
                                                    .isPrintedAsVatExempt
                                                ? '1'
                                                : '0', //printedAsVatExempt
                                            salesInvoiceCont.isPrintedAs0
                                                ? '1'
                                                : '0', //printedAsPercentage
                                            salesInvoiceCont.isBeforeVatPrices
                                                ? '0'
                                                : '1', //vatInclusivePrices
                                            salesInvoiceCont.isBeforeVatPrices
                                                ? '1'
                                                : '0', //beforeVatPrices
                                            codeController.text, //code
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice,
                                            salesInvoiceController.orderedKeys,
                                            salesInvoiceController.selectedInvoiceType,
                                              '${salesInvoiceCont.selectedHeader['id']}'
                                          );
                                          if (res['success'] == true) {
                                            CommonWidgets.snackBar(
                                              'Success',
                                              res['message'],
                                            );
                                            homeController.selectedTab.value =
                                                'to_deliver';
                                          } else {
                                            CommonWidgets.snackBar(
                                              'error',
                                              res['message'],
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    UnderTitleBtn(
                                      text: 'cancel'.tr,
                                      onTap: () async {
                                        setState(() {
                                          progressVar = 1;
                                        });
                                        salesInvoiceCont.setStatus('cancelled');
                                        bool hasType1WithEmptyTitle =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '1' &&
                                                      (map['title']?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType2WithEmptyId =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '2' &&
                                                      (map['item_id']
                                                              ?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType3WithEmptyId =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '3' &&
                                                      (map['combo']?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType4WithEmptyImage =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '4' &&
                                                      (map['image'] ==
                                                              Uint8List(0) ||
                                                          map['image']
                                                              ?.isEmpty);
                                                });
                                        bool hasType5WithEmptyNote =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '5' &&
                                                      (map['note']?.isEmpty ??
                                                          true);
                                                });
                                        if (salesInvoiceController
                                            .rowsInListViewInSalesInvoice
                                            .isEmpty) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'Order lines is Empty',
                                          );
                                        } else if (hasType2WithEmptyId) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty item',
                                          );
                                        } else if (hasType3WithEmptyId) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty combo',
                                          );
                                        } else if (hasType1WithEmptyTitle) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty title',
                                          );
                                        } else if (hasType4WithEmptyImage) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty image',
                                          );
                                        } else if (hasType5WithEmptyNote) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty note',
                                          );
                                        } else {
                                          var res = await storeSalesInvoice(
                                            refController.text,
                                            selectedCustomerIds,
                                            validityController.text,
                                            inputDateController.text,
                                            salesInvoiceCont
                                                .selectedWarehouseId,
                                            salesInvoiceCont.selectedPaymentTermId,
                                            salesInvoiceCont.salesInvoiceNumber,
                                            salesInvoiceCont
                                                .selectedPriceListId,
                                            salesInvoiceCont
                                                .selectedCurrencyId, //selectedCurrency
                                            termsAndConditionsController.text,
                                            selectedSalesPersonId.toString(),
                                            '', // commission method id
                                            salesInvoiceCont
                                                .selectedCashingMethodId,
                                            commissionController.text,
                                            totalCommissionController.text,
                                            salesInvoiceController.totalItems
                                                .toString(), //total before vat
                                            specialDiscPercentController
                                                .text, // inserted by user
                                            salesInvoiceController
                                                .specialDisc, // calculated
                                            globalDiscPercentController.text,
                                            salesInvoiceController.globalDisc,
                                            salesInvoiceController.vat11
                                                .toString(), //vat
                                            salesInvoiceController
                                                .vatInPrimaryCurrency
                                                .toString(), //vatLebanese
                                            salesInvoiceController
                                                .totalSalesInvoice, //total

                                            salesInvoiceCont.isVatExemptChecked
                                                ? '1'
                                                : '0',
                                            salesInvoiceCont.isVatNoPrinted
                                                ? '1'
                                                : '0', //not printed
                                            salesInvoiceCont
                                                    .isPrintedAsVatExempt
                                                ? '1'
                                                : '0', //printedAsVatExempt
                                            salesInvoiceCont.isPrintedAs0
                                                ? '1'
                                                : '0', //printedAsPercentage
                                            salesInvoiceCont.isBeforeVatPrices
                                                ? '0'
                                                : '1', //vatInclusivePrices
                                            salesInvoiceCont.isBeforeVatPrices
                                                ? '1'
                                                : '0', //beforeVatPrices
                                            codeController.text, //code
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice,
                                            salesInvoiceController.orderedKeys,
                                            salesInvoiceController.selectedInvoiceType,
                                              '${salesInvoiceCont.selectedHeader['id']}'
                                          );
                                          if (res['success'] == true) {
                                            CommonWidgets.snackBar(
                                              'Success',
                                              res['message'],
                                            );
                                            homeController.selectedTab.value =
                                                'sales_invoice_summary';
                                          } else {
                                            CommonWidgets.snackBar(
                                              'error',
                                              res['message'],
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    ReusableTimeLineTile(
                                      id: 0,
                                      progressVar: progressVar,
                                      isFirst: true,
                                      isLast: false,
                                      isPast: true,
                                      text: 'sales_order'.tr,
                                    ),
                                    ReusableTimeLineTile(
                                      id: 1,
                                      progressVar: progressVar,
                                      isFirst: false,
                                      isLast: false,
                                      isPast: true,
                                      text: 'delivered'.tr,
                                    ),
                                    ReusableTimeLineTile(
                                      id: 2,
                                      progressVar: progressVar,
                                      isFirst: false,
                                      isLast: false,
                                      isPast: true,
                                      text: 'proforma'.tr,
                                    ),
                                    ReusableTimeLineTile(
                                      id: 3,
                                      progressVar: progressVar,
                                      isFirst: false,
                                      isLast: true,
                                      isPast: false,
                                      text: 'posted'.tr,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        gapH16,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Others.divider),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(9),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    salesInvoiceCont.salesInvoiceNumber,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: TypographyColor.titleTable,
                                    ),
                                  ),
                                  ReusableReferenceTextField(
                                    type: 'salesInvoices',
                                    textEditingController: refController,
                                    rowWidth: referenceRow,
                                    textFieldWidth: referenceFieldWidth,
                                  ),
                                  // DialogTextField(
                                  //   textEditingController: refController,
                                  //   text: '${'ref'.tr}:',
                                  //   hint: 'manual_reference'.tr,
                                  //   rowWidth: referenceRow,
                                  //   textFieldWidth: referenceFieldWidth,
                                  //   // rowWidth:
                                  //   //     MediaQuery.of(context).size.width * 0.18,
                                  //   // textFieldWidth:
                                  //   //     MediaQuery.of(context).size.width * 0.15,
                                  //   validationFunc: (val) {},
                                  // ),
                                  SizedBox(
                                    width: currencyRow,
                                    // width: MediaQuery.of(context).size.width * 0.11,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('currency'.tr),
                                        GetBuilder<ExchangeRatesController>(
                                          builder: (cont) {
                                            return DropdownMenu<String>(
                                              width: currencyFieldWidth,
                                              // width:
                                              //     MediaQuery.of(
                                              //       context,
                                              //     ).size.width *
                                              //     0.07,
                                              // requestFocusOnTap: false,
                                              enableSearch: true,
                                              controller: currencyController,
                                              hintText: '',
                                              inputDecorationTheme: InputDecorationTheme(
                                                // filled: true,
                                                hintStyle: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                      20,
                                                      0,
                                                      25,
                                                      5,
                                                    ),
                                                // outlineBorder: BorderSide(color: Colors.black,),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Primary.primary
                                                            .withAlpha(
                                                              (0.2 * 255)
                                                                  .toInt(),
                                                            ),
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(9),
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Primary.primary
                                                            .withAlpha(
                                                              (0.4 * 255)
                                                                  .toInt(),
                                                            ),
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(9),
                                                          ),
                                                    ),
                                              ),
                                              // menuStyle: ,
                                              menuHeight: 250,
                                              dropdownMenuEntries:
                                                  cont.currenciesNamesList.map<
                                                    DropdownMenuEntry<String>
                                                  >((String option) {
                                                    return DropdownMenuEntry<
                                                      String
                                                    >(
                                                      value: option,
                                                      label: option,
                                                    );
                                                  }).toList(),
                                              enableFilter: true,
                                              onSelected: (String? val) {
                                                setState(() {
                                                  selectedCurrency = val!;
                                                  var index = cont
                                                      .currenciesNamesList
                                                      .indexOf(val);
                                                  salesInvoiceCont
                                                      .setSelectedCurrency(
                                                        cont.currenciesIdsList[index],
                                                        val,
                                                      );
                                                  salesInvoiceCont
                                                      .setSelectedCurrencySymbol(
                                                        cont.currenciesSymbolsList[index],
                                                      );
                                                  var result = cont
                                                      .exchangeRatesList
                                                      .firstWhere(
                                                        (item) =>
                                                            item["currency"] ==
                                                            val,
                                                        orElse: () => null,
                                                      );
                                                  salesInvoiceCont
                                                      .setExchangeRateForSelectedCurrency(
                                                        result != null
                                                            ? '${result["exchange_rate"]}'
                                                            : '1',
                                                      );
                                                });
                                                var keys =
                                                    salesInvoiceCont
                                                        .unitPriceControllers
                                                        .keys
                                                        .toList();
                                                for (
                                                  int i = 0;
                                                  i <
                                                      salesInvoiceCont
                                                          .unitPriceControllers
                                                          .length;
                                                  i++
                                                ) {
                                                  var selectedItemId =
                                                      '${salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_id']}';
                                                  if (selectedItemId != '') {
                                                    if (salesInvoiceCont
                                                            .itemsPricesCurrencies[selectedItemId] ==
                                                        val) {
                                                      salesInvoiceCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text = salesInvoiceCont
                                                              .itemUnitPrice[selectedItemId]
                                                              .toString();
                                                    } else if (salesInvoiceCont
                                                                .selectedCurrencyName ==
                                                            'USD' &&
                                                        salesInvoiceCont
                                                                .itemsPricesCurrencies[selectedItemId] !=
                                                            val) {
                                                      var result = exchangeRatesController
                                                          .exchangeRatesList
                                                          .firstWhere(
                                                            (item) =>
                                                                item["currency"] ==
                                                                salesInvoiceCont
                                                                    .itemsPricesCurrencies[selectedItemId],
                                                            orElse: () => null,
                                                          );
                                                      var divider = '1';
                                                      if (result != null) {
                                                        divider =
                                                            result["exchange_rate"]
                                                                .toString();
                                                      }
                                                      salesInvoiceCont
                                                              .unitPriceControllers[keys[i]]!
                                                              .text =
                                                          '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                    } else if (salesInvoiceCont
                                                                .selectedCurrencyName !=
                                                            'USD' &&
                                                        salesInvoiceCont
                                                                .itemsPricesCurrencies[selectedItemId] ==
                                                            'USD') {
                                                      salesInvoiceCont
                                                              .unitPriceControllers[keys[i]]!
                                                              .text =
                                                          '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) * double.parse(salesInvoiceCont.exchangeRateForSelectedCurrency))}')}';
                                                    } else {
                                                      var result = exchangeRatesController
                                                          .exchangeRatesList
                                                          .firstWhere(
                                                            (item) =>
                                                                item["currency"] ==
                                                                salesInvoiceCont
                                                                    .itemsPricesCurrencies[selectedItemId],
                                                            orElse: () => null,
                                                          );
                                                      var divider = '1';
                                                      if (result != null) {
                                                        divider =
                                                            result["exchange_rate"]
                                                                .toString();
                                                      }
                                                      var usdPrice =
                                                          '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                      salesInvoiceCont
                                                              .unitPriceControllers[keys[i]]!
                                                              .text =
                                                          '${double.parse('${(double.parse(usdPrice) * double.parse(salesInvoiceCont.exchangeRateForSelectedCurrency))}')}';
                                                    }
                                                    if (!salesInvoiceCont
                                                        .isBeforeVatPrices) {
                                                      var taxRate =
                                                          double.parse(
                                                            salesInvoiceCont
                                                                .itemsVats[selectedItemId],
                                                          ) /
                                                          100.0;
                                                      var taxValue =
                                                          taxRate *
                                                          double.parse(
                                                            salesInvoiceCont
                                                                .unitPriceControllers[keys[i]]!
                                                                .text,
                                                          );

                                                      salesInvoiceCont
                                                              .unitPriceControllers[keys[i]]!
                                                              .text =
                                                          '${double.parse(salesInvoiceCont.unitPriceControllers[keys[i]]!.text) + taxValue}';
                                                    }
                                                    salesInvoiceCont
                                                        .unitPriceControllers[keys[i]]!
                                                        .text = double.parse(
                                                      salesInvoiceCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text,
                                                    ).toStringAsFixed(2);
                                                    var totalLine =
                                                        '${(int.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_quantity']) * double.parse(salesInvoiceCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_discount']) / 100)}';

                                                    salesInvoiceCont
                                                        .setEnteredUnitPriceInSalesInvoice(
                                                          keys[i],
                                                          salesInvoiceCont
                                                              .unitPriceControllers[keys[i]]!
                                                              .text,
                                                        );
                                                    salesInvoiceCont
                                                        .setMainTotalInSalesInvoice(
                                                          keys[i],
                                                          totalLine,
                                                        );
                                                    salesInvoiceCont
                                                        .getTotalItems();
                                                  }
                                                }
                                                var comboKeys =
                                                    salesInvoiceCont
                                                        .combosPriceControllers
                                                        .keys
                                                        .toList();
                                                for (
                                                  int i = 0;
                                                  i <
                                                      salesInvoiceCont
                                                          .combosPriceControllers
                                                          .length;
                                                  i++
                                                ) {
                                                  var selectedComboId =
                                                      '${salesInvoiceCont.rowsInListViewInSalesInvoice[comboKeys[i]]['combo']}';
                                                  if (selectedComboId != '') {
                                                    var ind = salesInvoiceCont
                                                        .combosIdsList
                                                        .indexOf(
                                                          selectedComboId,
                                                        );
                                                    if (salesInvoiceCont
                                                            .combosPricesCurrencies[selectedComboId] ==
                                                        salesInvoiceCont
                                                            .selectedCurrencyName) {
                                                      salesInvoiceCont
                                                          .combosPriceControllers[comboKeys[i]]!
                                                          .text = salesInvoiceCont
                                                              .combosPricesList[ind]
                                                              .toString();
                                                    } else if (salesInvoiceCont
                                                                .selectedCurrencyName ==
                                                            'USD' &&
                                                        salesInvoiceCont
                                                                .combosPricesCurrencies[selectedComboId] !=
                                                            salesInvoiceCont
                                                                .selectedCurrencyName) {
                                                      var result = exchangeRatesController
                                                          .exchangeRatesList
                                                          .firstWhere(
                                                            (item) =>
                                                                item["currency"] ==
                                                                salesInvoiceCont
                                                                    .combosPricesCurrencies[selectedComboId],
                                                            orElse: () => null,
                                                          );
                                                      var divider = '1';
                                                      if (result != null) {
                                                        divider =
                                                            result["exchange_rate"]
                                                                .toString();
                                                      }
                                                      salesInvoiceCont
                                                              .combosPriceControllers[comboKeys[i]]!
                                                              .text =
                                                          '${double.parse('${(double.parse(salesInvoiceCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                    } else if (salesInvoiceCont
                                                                .selectedCurrencyName !=
                                                            'USD' &&
                                                        salesInvoiceCont
                                                                .combosPricesCurrencies[selectedComboId] ==
                                                            'USD') {
                                                      salesInvoiceCont
                                                              .combosPriceControllers[comboKeys[i]]!
                                                              .text =
                                                          '${double.parse('${(double.parse(salesInvoiceCont.combosPricesList[ind].toString()) * double.parse(salesInvoiceCont.exchangeRateForSelectedCurrency))}')}';
                                                    } else {
                                                      var result = exchangeRatesController
                                                          .exchangeRatesList
                                                          .firstWhere(
                                                            (item) =>
                                                                item["currency"] ==
                                                                salesInvoiceCont
                                                                    .combosPricesCurrencies[selectedComboId],
                                                            orElse: () => null,
                                                          );
                                                      var divider = '1';
                                                      if (result != null) {
                                                        divider =
                                                            result["exchange_rate"]
                                                                .toString();
                                                      }
                                                      var usdPrice =
                                                          '${double.parse('${(double.parse(salesInvoiceCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                      salesInvoiceCont
                                                              .combosPriceControllers[comboKeys[i]]!
                                                              .text =
                                                          '${double.parse('${(double.parse(usdPrice) * double.parse(salesInvoiceCont.exchangeRateForSelectedCurrency))}')}';
                                                    }
                                                    salesInvoiceCont
                                                            .combosPriceControllers[comboKeys[i]]!
                                                            .text =
                                                        '${double.parse(salesInvoiceCont.combosPriceControllers[comboKeys[i]]!.text)}';

                                                    salesInvoiceCont
                                                        .combosPriceControllers[comboKeys[i]]!
                                                        .text = double.parse(
                                                      salesInvoiceCont
                                                          .combosPriceControllers[comboKeys[i]]!
                                                          .text,
                                                    ).toStringAsFixed(2);
                                                    var totalLine =
                                                        '${(int.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[comboKeys[i]]['item_quantity']) * double.parse(salesInvoiceCont.combosPriceControllers[comboKeys[i]]!.text)) * (1 - double.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_discount']) / 100)}';
                                                    salesInvoiceCont
                                                        .setEnteredQtyInSalesInvoice(
                                                          comboKeys[i],
                                                          salesInvoiceCont
                                                              .rowsInListViewInSalesInvoice[comboKeys[i]]['item_quantity'],
                                                        );
                                                    salesInvoiceCont
                                                        .setMainTotalInSalesInvoice(
                                                          comboKeys[i],
                                                          totalLine,
                                                        );
                                                    salesInvoiceCont
                                                        .getTotalItems();

                                                    salesInvoiceCont
                                                        .setEnteredUnitPriceInSalesInvoice(
                                                          comboKeys[i],
                                                          salesInvoiceCont
                                                              .combosPriceControllers[comboKeys[i]]!
                                                              .text,
                                                        );
                                                    salesInvoiceCont
                                                        .setMainTotalInSalesInvoice(
                                                          comboKeys[i],
                                                          totalLine,
                                                        );
                                                    salesInvoiceCont
                                                        .getTotalItems();
                                                  }
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    width: validityRow,
                                    // width: MediaQuery.of(context).size.width * 0.15,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('value_date'.tr),
                                        // Text('     '),
                                        DialogDateTextField(
                                          textEditingController:
                                              validityController,
                                          text: '',
                                          textFieldWidth: validityFieldWidth,
                                          // textFieldWidth:
                                          //     MediaQuery.of(context).size.width *
                                          //     0.10,
                                          // MediaQuery.of(context).size.width * 0.25,
                                          validationFunc: (val) {},
                                          onChangedFunc: (val) {
                                            validityController.text = val;
                                          },
                                          onDateSelected: (value) {
                                            validityController.text = value;
                                            setState(() {
                                              // LocalDate a=LocalDate.today();
                                              // LocalDate b = LocalDate.dateTime(value);
                                              // Period diff = b.periodSince(a);
                                              // print("years: ${diff.years}; months: ${diff.months}; days: ${diff.days}");
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: priceListRow,
                                    // width: MediaQuery.of(context).size.width * 0.15,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('pricelist'.tr),
                                        DropdownMenu<String>(
                                          width: priceListFieldWidth,
                                          // width:
                                          //     MediaQuery.of(context).size.width *
                                          //     0.10,
                                          // requestFocusOnTap: false,
                                          enableSearch: true,
                                          controller: priceListController,
                                          hintText: '',
                                          inputDecorationTheme: InputDecorationTheme(
                                            // filled: true,
                                            hintStyle: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                  20,
                                                  0,
                                                  25,
                                                  5,
                                                ),
                                            // outlineBorder: BorderSide(color: Colors.black,),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Primary.primary
                                                    .withAlpha(
                                                      (0.2 * 255).toInt(),
                                                    ),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                    Radius.circular(9),
                                                  ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Primary.primary
                                                    .withAlpha(
                                                      (0.4 * 255).toInt(),
                                                    ),
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                    Radius.circular(9),
                                                  ),
                                            ),
                                          ),
                                          // menuStyle: ,
                                          menuHeight: 250,
                                          dropdownMenuEntries:
                                              salesInvoiceController
                                                  .priceListsCodes
                                                  .map<
                                                    DropdownMenuEntry<String>
                                                  >((String option) {
                                                    return DropdownMenuEntry<
                                                      String
                                                    >(
                                                      value: option,
                                                      label: option,
                                                    );
                                                  })
                                                  .toList(),
                                          enableFilter: true,
                                          onSelected: (String? val) {
                                            var index = salesInvoiceCont
                                                .priceListsCodes
                                                .indexOf(val!);
                                            salesInvoiceCont
                                                .setSelectedPriceListId(
                                                  salesInvoiceCont
                                                      .priceListsIds[index],
                                                );
                                            setState(() {
                                              salesInvoiceCont
                                                  .resetItemsAfterChangePriceList();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              gapH16,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: inputDateRow,
                                    // width: MediaQuery.of(context).size.width * 0.15,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('input_date'.tr),
                                        DialogDateTextField(
                                          textEditingController:
                                              inputDateController,
                                          text: '',
                                          textFieldWidth: inputDateFieldWidth,
                                          // textFieldWidth:
                                          //     MediaQuery.of(context).size.width *
                                          //     0.10,
                                          // MediaQuery.of(context).size.width * 0.25,
                                          validationFunc: (val) {},
                                          onChangedFunc: (val) {
                                            inputDateController.text = val;
                                          },
                                          onDateSelected: (value) {
                                            inputDateController.text = value;
                                            setState(() {
                                              // LocalDate a=LocalDate.today();
                                              // LocalDate b = LocalDate.dateTime(value);
                                              // Period diff = b.periodSince(a);
                                              // print("years: ${diff.years}; months: ${diff.months}; days: ${diff.days}");
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: codeRow,
                                    // width: MediaQuery.of(context).size.width * 0.30,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ReusableDropDownMenusWithSearchCode(
                                          list:
                                              salesInvoiceCont
                                                  .customersMultiPartList,
                                          text: 'code'.tr,
                                          hint: '${'search'.tr}...',
                                          controller: codeController,
                                          onSelected: (String? value) {
                                            codeController.text = value!;
                                            int index = salesInvoiceCont
                                                .customerNumberList
                                                .indexOf(value);
                                            clientNameController.text =
                                                salesInvoiceCont
                                                    .customerNameList[index];
                                            setState(() {
                                              selectedCustomerIds =
                                                  salesInvoiceCont
                                                      .customerIdsList[salesInvoiceCont
                                                      .customerNumberList
                                                      .indexOf(value)];
                                              if (salesInvoiceCont
                                                      .customersPricesListsIds[index]
                                                      .isNotEmpty &&
                                                  salesInvoiceCont
                                                          .customersPricesListsIds[index] !=
                                                      null) {
                                                salesInvoiceCont
                                                    .setSelectedPriceListId(
                                                      '${salesInvoiceCont.customersPricesListsIds[index]}',
                                                    );

                                                priceListController.text =
                                                    salesInvoiceCont
                                                        .priceListsNames[salesInvoiceCont
                                                        .priceListsIds
                                                        .indexOf(
                                                          '${salesInvoiceCont.customersPricesListsIds[index]}',
                                                        )];
                                                setState(() {
                                                  salesInvoiceCont
                                                      .resetItemsAfterChangePriceList();
                                                });
                                              }
                                              if (salesInvoiceCont
                                                      .customersSalesPersonsIds[index]
                                                      .isNotEmpty &&
                                                  salesInvoiceCont
                                                          .customersSalesPersonsIds[index] !=
                                                      null) {
                                                setState(() {
                                                  selectedSalesPersonId = int.parse(
                                                    '${salesInvoiceCont.customersSalesPersonsIds[index]}',
                                                  );
                                                  selectedSalesPerson =
                                                      salesInvoiceCont
                                                          .salesPersonListNames[salesInvoiceCont
                                                          .salesPersonListId
                                                          .indexOf(
                                                            selectedSalesPersonId,
                                                          )];

                                                  salesPersonController.text =
                                                      selectedSalesPerson;
                                                });
                                              }
                                            });
                                          },
                                          validationFunc: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'select_option'.tr;
                                            }
                                            return null;
                                          },
                                          rowWidth: codeInnerRow,
                                          textFieldWidth: codeFieldWidth,
                                          // rowWidth:
                                          //     MediaQuery.of(context).size.width *
                                          //     0.15,
                                          // textFieldWidth:
                                          //     MediaQuery.of(context).size.width *
                                          //     0.12,
                                          clickableOptionText:
                                              'create_new_client'.tr,
                                          isThereClickableOption: true,
                                          onTappedClickableOption: () {
                                            showDialog<String>(
                                              context: context,
                                              builder:
                                                  (
                                                    BuildContext context,
                                                  ) => const AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  9,
                                                                ),
                                                              ),
                                                        ),
                                                    elevation: 0,
                                                    content:
                                                        CreateClientDialog(),
                                                  ),
                                            );
                                          },
                                          columnWidths: [175.0, 230.0],
                                        ),
                                        ReusableDropDownMenuWithSearch(
                                          list:
                                              salesInvoiceCont.customerNameList,
                                          text: '',
                                          hint: '${'search'.tr}...',
                                          controller: clientNameController,
                                          onSelected: (String? val) {
                                            setState(() {
                                              var index = salesInvoiceCont
                                                  .customerNameList
                                                  .indexOf(val!);
                                              codeController.text =
                                                  salesInvoiceCont
                                                      .customerNumberList[index];
                                              selectedCustomerIds =
                                                  salesInvoiceCont
                                                      .customerIdsList[index];
                                              if (salesInvoiceCont
                                                  .customersPricesListsIds[index]
                                                  .isNotEmpty) {
                                                salesInvoiceCont
                                                    .setSelectedPriceListId(
                                                      '${salesInvoiceCont.customersPricesListsIds[index]}',
                                                    );

                                                priceListController.text =
                                                    salesInvoiceCont
                                                        .priceListsNames[salesInvoiceCont
                                                        .priceListsIds
                                                        .indexOf(
                                                          '${salesInvoiceCont.customersPricesListsIds[index]}',
                                                        )];
                                                setState(() {
                                                  salesInvoiceCont
                                                      .resetItemsAfterChangePriceList();
                                                });
                                              }
                                              if (salesInvoiceCont
                                                  .customersSalesPersonsIds[index]
                                                  .isNotEmpty) {
                                                setState(() {
                                                  selectedSalesPersonId = int.parse(
                                                    '${salesInvoiceCont.customersSalesPersonsIds[index]}',
                                                  );
                                                  selectedSalesPerson =
                                                      salesInvoiceCont
                                                          .salesPersonListNames[salesInvoiceCont
                                                          .salesPersonListId
                                                          .indexOf(
                                                            selectedSalesPersonId,
                                                          )];

                                                  salesPersonController.text =
                                                      selectedSalesPerson;
                                                });
                                              }
                                            });
                                          },
                                          validationFunc: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'select_option'.tr;
                                            }
                                            return null;
                                          },
                                          rowWidth: searchRow,
                                          textFieldWidth: searchFieldWidth,
                                          // rowWidth:
                                          //     MediaQuery.of(context).size.width *
                                          //     0.15,
                                          // textFieldWidth:
                                          //     MediaQuery.of(context).size.width *
                                          //     0.14,
                                          clickableOptionText:
                                              'create_new_client'.tr,
                                          isThereClickableOption: true,
                                          onTappedClickableOption: () {
                                            showDialog<String>(
                                              context: context,
                                              builder:
                                                  (
                                                    BuildContext context,
                                                  ) => const AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  9,
                                                                ),
                                                              ),
                                                        ),
                                                    elevation: 0,
                                                    content:
                                                        CreateClientDialog(),
                                                  ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  // DialogTextField(
                                  //   textEditingController:
                                  //       paymentTermsController,
                                  //   text: 'payment_terms'.tr,
                                  //   hint: '',
                                  //   rowWidth: paymentTermsRow,
                                  //   textFieldWidth: paymentTermsFieldWidth,
                                  //   // rowWidth:
                                  //   //     MediaQuery.of(context).size.width * 0.24,
                                  //   // textFieldWidth:
                                  //   //     MediaQuery.of(context).size.width * 0.15,
                                  //   validationFunc: (val) {},
                                  // ),
                                  // GetBuilder<PaymentTermsController>(
                                  //   builder: (cont) {
                                  //     return ReusableDropDownMenuWithSearch(
                                  //       list: cont.paymentTermsNamesList,
                                  //       text: 'payment_terms'.tr,
                                  //       hint: '',
                                  //       onSelected: (value) {},
                                  //       controller: controller,
                                  //       validationFunc: (value) {},
                                  //         rowWidth: paymentTermsRow,
                                  //         textFieldWidth: paymentTermsFieldWidth,
                                  //       // rowWidth:
                                  //       //     MediaQuery.of(context).size.width * 0.24,
                                  //       // textFieldWidth:
                                  //       //     MediaQuery.of(context).size.width * 0.15,
                                  //       clickableOptionText:
                                  //           'create_new_payment_terms'.tr,
                                  //       isThereClickableOption: true,
                                  //       onTappedClickableOption: () {
                                  //         // showDialog<String>(
                                  //         //   context: context,
                                  //         //   builder:
                                  //         //       (
                                  //         //       BuildContext context,
                                  //         //       ) => const AlertDialog(
                                  //         //     backgroundColor: Colors.white,
                                  //         //     shape: RoundedRectangleBorder(
                                  //         //       borderRadius:
                                  //         //       BorderRadius.all(
                                  //         //         Radius.circular(9),
                                  //         //       ),
                                  //         //     ),
                                  //         //     elevation: 0,
                                  //         //     content: CreateClientDialog(),
                                  //         //   ),
                                  //         // );
                                  //       },
                                  //     );
                                  //   }
                                  // ),
                                  // SizedBox(
                                  //   width: MediaQuery.of(context).size.width * 0.24,
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       Text('payment_terms'.tr),
                                  //
                                  //       GetBuilder<PaymentTermsController>(
                                  //         builder: (cont) {
                                  //           return DropdownMenu<String>(
                                  //             width:
                                  //                 MediaQuery.of(
                                  //                   context,
                                  //                 ).size.width *
                                  //                 0.15,
                                  //             // requestFocusOnTap: false,
                                  //             enableSearch: true,
                                  //             controller: paymentTermsController,
                                  //             hintText: '',
                                  //             inputDecorationTheme: InputDecorationTheme(
                                  //               // filled: true,
                                  //               hintStyle: const TextStyle(
                                  //                 fontStyle: FontStyle.italic,
                                  //               ),
                                  //               contentPadding:
                                  //                   const EdgeInsets.fromLTRB(
                                  //                     20,
                                  //                     0,
                                  //                     25,
                                  //                     5,
                                  //                   ),
                                  //               // outlineBorder: BorderSide(color: Colors.black,),
                                  //               enabledBorder: OutlineInputBorder(
                                  //                 borderSide: BorderSide(
                                  //                   color: Primary.primary
                                  //                       .withAlpha(
                                  //                         (0.2 * 255).toInt(),
                                  //                       ),
                                  //                   width: 1,
                                  //                 ),
                                  //                 borderRadius:
                                  //                     const BorderRadius.all(
                                  //                       Radius.circular(9),
                                  //                     ),
                                  //               ),
                                  //               focusedBorder: OutlineInputBorder(
                                  //                 borderSide: BorderSide(
                                  //                   color: Primary.primary
                                  //                       .withAlpha(
                                  //                         (0.4 * 255).toInt(),
                                  //                       ),
                                  //                   width: 2,
                                  //                 ),
                                  //                 borderRadius:
                                  //                     const BorderRadius.all(
                                  //                       Radius.circular(9),
                                  //                     ),
                                  //               ),
                                  //             ),
                                  //             // menuStyle: ,
                                  //             menuHeight: 250,
                                  //             dropdownMenuEntries:
                                  //                 cont.paymentTermsNamesList.map<
                                  //                   DropdownMenuEntry<String>
                                  //                 >((String option) {
                                  //                   return DropdownMenuEntry<
                                  //                     String
                                  //                   >(value: option, label: option);
                                  //                 }).toList(),
                                  //             enableFilter: true,
                                  //             onSelected: (String? val) {
                                  //               setState(() {
                                  //                 // selectedCurrency = val!;
                                  //                 // var index = cont.currenciesNamesList
                                  //                 //     .indexOf(val);
                                  //                 // selectedCurrencyId =
                                  //                 // cont.currenciesIdsList[index];
                                  //               });
                                  //             },
                                  //           );
                                  //         },
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  GetBuilder<PaymentTermsController>(
                                    builder: (cont) {
                                      return ReusableDropDownMenuWithSearch(
                                        list: cont.paymentTermsNamesList,
                                        text: 'payment_terms'.tr,
                                        hint: '${'search'.tr}...',
                                        controller: paymentTermsController,
                                        onSelected: (String? val) {
                                          int index=cont.paymentTermsNamesList.indexOf(val!);
                                          salesInvoiceCont.setSelectedPaymentTermId(cont.paymentTermsIdsList[index]);
                                        },
                                        validationFunc: (value) {
                                          // if (value == null || value.isEmpty) {
                                          //   return 'select_option'.tr;
                                          // }
                                          // return null;
                                        },
                                        rowWidth:
                                        MediaQuery.of(context).size.width * 0.24,
                                        textFieldWidth:
                                        MediaQuery.of(context).size.width * 0.15,
                                        clickableOptionText:
                                        'or_create_new_payment_term'.tr,
                                        isThereClickableOption: true,
                                        onTappedClickableOption: () {
                                          showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) => AlertDialog(
                                                backgroundColor: Colors.white,
                                                contentPadding: const EdgeInsets.all(0),
                                                titlePadding: const EdgeInsets.all(0),
                                                actionsPadding: const EdgeInsets.all(0),
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.all(Radius.circular(9)),
                                                ),
                                                elevation: 0,
                                                content: configDialogs['payment_terms'],
                                              ));
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),

                              gapH16,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //address
                                        Row(
                                          children: [
                                            Text(
                                              '${'Street_building_floor'.tr} ',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            gapW10,
                                            Text(
                                              " ${salesInvoiceCont.street[selectedCustomerIds] ?? ''} ",
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              salesInvoiceCont.floorAndBuilding[selectedCustomerIds] ==
                                                          '' ||
                                                      salesInvoiceCont
                                                              .floorAndBuilding[selectedCustomerIds] ==
                                                          null
                                                  ? ''
                                                  : ',',
                                            ),
                                            Text(
                                              " ${salesInvoiceCont.floorAndBuilding[selectedCustomerIds] ?? ''}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        gapH6,
                                        //tel
                                        Row(
                                          children: [
                                            Text(
                                              'Phone Number'.tr,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            gapW10,
                                            Text(
                                              "${salesInvoiceCont.phoneNumber[selectedCustomerIds] ?? ''}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  gapW16,
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.24,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'price_condition'.tr,
                                          style:
                                              salesInvoiceCont
                                                      .isVatExemptChecked
                                                  ? TextStyle(
                                                    color: Others.divider,
                                                  )
                                                  : TextStyle(),
                                        ),
                                        GetBuilder<ExchangeRatesController>(
                                          builder: (cont) {
                                            return DropdownMenu<String>(
                                              enabled:
                                                  !salesInvoiceCont
                                                      .isVatExemptChecked,
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.15,
                                              // requestFocusOnTap: false,
                                              enableSearch: true,
                                              controller:
                                                  priceConditionController,
                                              hintText: '',
                                              textStyle: TextStyle(
                                                fontSize: 12,
                                              ),
                                              inputDecorationTheme: InputDecorationTheme(
                                                // filled: true,
                                                hintStyle: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                      20,
                                                      0,
                                                      25,
                                                      5,
                                                    ),
                                                // outlineBorder: BorderSide(color: Colors.black,),
                                                disabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Others.divider,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(9),
                                                          ),
                                                    ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Primary.primary
                                                            .withAlpha(
                                                              (0.2 * 255)
                                                                  .toInt(),
                                                            ),
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(9),
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Primary.primary
                                                            .withAlpha(
                                                              (0.4 * 255)
                                                                  .toInt(),
                                                            ),
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(9),
                                                          ),
                                                    ),
                                              ),
                                              // menuStyle: ,
                                              menuHeight: 250,
                                              dropdownMenuEntries:
                                                  pricesVatConditions.map<
                                                    DropdownMenuEntry<String>
                                                  >((String option) {
                                                    return DropdownMenuEntry<
                                                      String
                                                    >(
                                                      value: option,
                                                      label: option,
                                                    );
                                                  }).toList(),
                                              enableFilter: true,
                                              onSelected: (String? value) {
                                                setState(() {
                                                  if (value ==
                                                      'Prices are before vat') {
                                                    salesInvoiceCont
                                                        .setIsBeforeVatPrices(
                                                          true,
                                                        );
                                                    // ch
                                                  } else {
                                                    salesInvoiceCont
                                                        .setIsBeforeVatPrices(
                                                          false,
                                                        );
                                                  }
                                                  var keys =
                                                      salesInvoiceCont
                                                          .unitPriceControllers
                                                          .keys
                                                          .toList();
                                                  for (
                                                    int i = 0;
                                                    i <
                                                        salesInvoiceCont
                                                            .unitPriceControllers
                                                            .length;
                                                    i++
                                                  ) {
                                                    var selectedItemId =
                                                        salesInvoiceCont
                                                            .rowsInListViewInSalesInvoice[keys[i]]['item_id'];
                                                    if (selectedItemId != '') {
                                                      if (salesInvoiceCont
                                                              .itemsPricesCurrencies[selectedItemId] ==
                                                          selectedCurrency) {
                                                        salesInvoiceCont
                                                            .unitPriceControllers[keys[i]]!
                                                            .text = salesInvoiceCont
                                                                .itemUnitPrice[selectedItemId]
                                                                .toString();
                                                      } else if (salesInvoiceCont
                                                                  .selectedCurrencyName ==
                                                              'USD' &&
                                                          salesInvoiceCont
                                                                  .itemsPricesCurrencies[selectedItemId] !=
                                                              selectedCurrency) {
                                                        var result = exchangeRatesController
                                                            .exchangeRatesList
                                                            .firstWhere(
                                                              (item) =>
                                                                  item["currency"] ==
                                                                  salesInvoiceCont
                                                                      .itemsPricesCurrencies[selectedItemId],
                                                              orElse:
                                                                  () => null,
                                                            );
                                                        var divider = '1';
                                                        if (result != null) {
                                                          divider =
                                                              result["exchange_rate"]
                                                                  .toString();
                                                        }
                                                        salesInvoiceCont
                                                                .unitPriceControllers[keys[i]]!
                                                                .text =
                                                            '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                      } else if (salesInvoiceCont
                                                                  .selectedCurrencyName !=
                                                              'USD' &&
                                                          salesInvoiceCont
                                                                  .itemsPricesCurrencies[selectedItemId] ==
                                                              'USD') {
                                                        salesInvoiceCont
                                                                .unitPriceControllers[keys[i]]!
                                                                .text =
                                                            '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) * double.parse(salesInvoiceCont.exchangeRateForSelectedCurrency))}')}';
                                                      } else {
                                                        var result = exchangeRatesController
                                                            .exchangeRatesList
                                                            .firstWhere(
                                                              (item) =>
                                                                  item["currency"] ==
                                                                  salesInvoiceCont
                                                                      .itemsPricesCurrencies[selectedItemId],
                                                              orElse:
                                                                  () => null,
                                                            );
                                                        var divider = '1';
                                                        if (result != null) {
                                                          divider =
                                                              result["exchange_rate"]
                                                                  .toString();
                                                        }
                                                        var usdPrice =
                                                            '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                        salesInvoiceCont
                                                                .unitPriceControllers[keys[i]]!
                                                                .text =
                                                            '${double.parse('${(double.parse(usdPrice) * double.parse(salesInvoiceCont.exchangeRateForSelectedCurrency))}')}';
                                                      }
                                                      if (!salesInvoiceCont
                                                          .isBeforeVatPrices) {
                                                        var taxRate =
                                                            double.parse(
                                                              salesInvoiceCont
                                                                  .itemsVats[selectedItemId],
                                                            ) /
                                                            100.0;
                                                        var taxValue =
                                                            taxRate *
                                                            double.parse(
                                                              salesInvoiceCont
                                                                  .unitPriceControllers[keys[i]]!
                                                                  .text,
                                                            );

                                                        salesInvoiceCont
                                                                .unitPriceControllers[keys[i]]!
                                                                .text =
                                                            '${double.parse(salesInvoiceCont.unitPriceControllers[keys[i]]!.text) + taxValue}';
                                                      }
                                                      salesInvoiceCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text = double.parse(
                                                        salesInvoiceCont
                                                            .unitPriceControllers[keys[i]]!
                                                            .text,
                                                      ).toStringAsFixed(2);
                                                      var totalLine =
                                                          '${(int.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_quantity']) * double.parse(salesInvoiceCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_discount']) / 100)}';

                                                      salesInvoiceCont
                                                          .setEnteredUnitPriceInSalesInvoice(
                                                            keys[i],
                                                            salesInvoiceCont
                                                                .unitPriceControllers[keys[i]]!
                                                                .text,
                                                          );
                                                      salesInvoiceCont
                                                          .setMainTotalInSalesInvoice(
                                                            keys[i],
                                                            totalLine,
                                                          );
                                                      salesInvoiceCont
                                                          .getTotalItems();
                                                    }
                                                  }
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              gapH16,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.18,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //vat
                                        salesInvoiceCont
                                                .isVatExemptCheckBoxShouldAppear
                                            ? Row(
                                              children: [
                                                Text(
                                                  'vat#'.tr,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                gapW10,
                                              ],
                                            )
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),

                                  //delivered from
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.24,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('delivered_from'.tr),
                                            GetBuilder<WarehouseController>(
                                              builder: (cont) {
                                                return cont.isWarehousesFetched
                                                    ? DropdownMenu<String>(
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.16,
                                                      // requestFocusOnTap: false,
                                                      enableSearch: true,
                                                      controller:
                                                          salesInvoiceCont
                                                              .warehouseMenuController,
                                                      hintText:
                                                          'deliver_warehouse'
                                                              .tr,
                                                      inputDecorationTheme: InputDecorationTheme(
                                                        // filled: true,
                                                        hintStyle:
                                                            const TextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                        contentPadding:
                                                            const EdgeInsets.fromLTRB(
                                                              20,
                                                              0,
                                                              25,
                                                              5,
                                                            ),
                                                        // outlineBorder: BorderSide(color: Colors.black,),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Primary
                                                                .primary
                                                                .withAlpha(
                                                                  (0.2 * 255)
                                                                      .toInt(),
                                                                ),
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                Radius.circular(
                                                                  9,
                                                                ),
                                                              ),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Primary
                                                                .primary
                                                                .withAlpha(
                                                                  (0.4 * 255)
                                                                      .toInt(),
                                                                ),
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                Radius.circular(
                                                                  9,
                                                                ),
                                                              ),
                                                        ),
                                                      ),
                                                      // menuStyle: ,
                                                      menuHeight: 250,
                                                      dropdownMenuEntries:
                                                          cont.warehousesNameList.map<
                                                            DropdownMenuEntry<
                                                              String
                                                            >
                                                          >((String option) {
                                                            return DropdownMenuEntry<
                                                              String
                                                            >(
                                                              value: option,
                                                              label: option,
                                                            );
                                                          }).toList(),
                                                      enableFilter: true,
                                                      onSelected: (
                                                        String? val,
                                                      ) {
                                                        var index = cont
                                                            .warehousesNameList
                                                            .indexOf(val!);
                                                        salesInvoiceCont
                                                            .setSelectedWarehouseId(
                                                              '${cont.warehouseIdsList[index]}',
                                                            );
                                                      },
                                                    )
                                                    : loading();
                                              },
                                            ),
                                          ],
                                        ),
                                        Text('for_direct_invoice'.tr),
                                      ],
                                    ),
                                  ),
                                  //vat exempt
                                  salesInvoiceCont
                                          .isVatExemptCheckBoxShouldAppear
                                      ? SizedBox(
                                        // width: paymentTermsRow,

                                        // width:
                                        //     MediaQuery.of(context).size.width *
                                        //     0.26,
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.28,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: ListTile(
                                                title: Text(
                                                  'vat_exempt'.tr,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                                leading: Checkbox(
                                                  // checkColor: Colors.white,
                                                  // fillColor: MaterialStateProperty.resolveWith(getColor),
                                                  value:
                                                      salesInvoiceCont
                                                          .isVatExemptChecked,
                                                  onChanged: (bool? value) {
                                                    salesInvoiceCont
                                                        .setIsVatExemptChecked(
                                                          value!,
                                                        );
                                                    if (value) {
                                                      // priceConditionController.clear();
                                                      priceConditionController
                                                              .text =
                                                          'Prices are before vat';
                                                      salesInvoiceCont
                                                          .setIsBeforeVatPrices(
                                                            true,
                                                          );
                                                      vatExemptController.text =
                                                          vatExemptList[0];
                                                      salesInvoiceCont
                                                          .setIsVatExempted(
                                                            true,
                                                            false,
                                                            false,
                                                          );
                                                    } else {
                                                      // priceConditionController.text='Prices are before vat';
                                                      vatExemptController
                                                          .clear();
                                                      salesInvoiceCont
                                                          .setIsVatExempted(
                                                            false,
                                                            false,
                                                            false,
                                                          );
                                                    }
                                                    // setState(() {
                                                    //   isVatExemptChecked = value!;
                                                    // });
                                                  },
                                                ),
                                              ),
                                            ),
                                            salesInvoiceCont
                                                        .isVatExemptChecked ==
                                                    false
                                                ? DropdownMenu<String>(
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.15,
                                                  // width: paymentTermsFieldWidth,
                                                  // width:
                                                  //     MediaQuery.of(
                                                  //       context,
                                                  //     ).size.width *
                                                  //     0.13,
                                                  // requestFocusOnTap: false,
                                                  enableSearch: true,
                                                  controller:
                                                      vatExemptController,
                                                  hintText: '',
                                                  textStyle: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                  inputDecorationTheme: InputDecorationTheme(
                                                    hintStyle: const TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets.fromLTRB(
                                                          20,
                                                          0,
                                                          25,
                                                          5,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Primary
                                                                .primary
                                                                .withAlpha(
                                                                  (0.2 * 255)
                                                                      .toInt(),
                                                                ),
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                Radius.circular(
                                                                  9,
                                                                ),
                                                              ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Primary
                                                                .primary
                                                                .withAlpha(
                                                                  (0.4 * 255)
                                                                      .toInt(),
                                                                ),
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                Radius.circular(
                                                                  9,
                                                                ),
                                                              ),
                                                        ),
                                                  ),
                                                  menuHeight: 250,
                                                  dropdownMenuEntries:
                                                      vatExemptList.map<
                                                        DropdownMenuEntry<
                                                          String
                                                        >
                                                      >((String option) {
                                                        return DropdownMenuEntry<
                                                          String
                                                        >(
                                                          value: option,
                                                          label: option,
                                                        );
                                                      }).toList(),
                                                  enableFilter: false,
                                                  onSelected: (String? val) {},
                                                )
                                                : DropdownMenu<String>(
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.15,
                                                  // requestFocusOnTap: false,
                                                  enableSearch: true,
                                                  controller:
                                                      vatExemptController,
                                                  hintText: '',
                                                  textStyle: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                  inputDecorationTheme: InputDecorationTheme(
                                                    // filled: true,
                                                    hintStyle: const TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets.fromLTRB(
                                                          20,
                                                          0,
                                                          25,
                                                          5,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Primary
                                                                .primary
                                                                .withAlpha(
                                                                  (0.2 * 255)
                                                                      .toInt(),
                                                                ),
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                Radius.circular(
                                                                  9,
                                                                ),
                                                              ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Primary
                                                                .primary
                                                                .withAlpha(
                                                                  (0.4 * 255)
                                                                      .toInt(),
                                                                ),
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                Radius.circular(
                                                                  9,
                                                                ),
                                                              ),
                                                        ),
                                                  ),
                                                  menuHeight: 250,
                                                  dropdownMenuEntries:
                                                      vatExemptList.map<
                                                        DropdownMenuEntry<
                                                          String
                                                        >
                                                      >((String option) {
                                                        return DropdownMenuEntry<
                                                          String
                                                        >(
                                                          value: option,
                                                          label: option,
                                                        );
                                                      }).toList(),
                                                  enableFilter: false,
                                                  onSelected: (String? val) {
                                                    setState(() {
                                                      if (val ==
                                                          'Printed as "vat exempted"') {
                                                        salesInvoiceCont
                                                            .setIsVatExempted(
                                                              true,
                                                              false,
                                                              false,
                                                            );
                                                      } else if (val ==
                                                          'Printed as "vat 0 % = 0"') {
                                                        salesInvoiceCont
                                                            .setIsVatExempted(
                                                              false,
                                                              true,
                                                              false,
                                                            );
                                                      } else {
                                                        salesInvoiceCont
                                                            .setIsVatExempted(
                                                              false,
                                                              false,
                                                              true,
                                                            );
                                                      }
                                                    });
                                                  },
                                                ),
                                          ],
                                        ),
                                      )
                                      : SizedBox(),
                                ],
                              ),
                              homeController.companyName == 'CASALAGO' ||
                                  homeController.companyName == 'AMAZON'
                                  ? Column(
                                children: [
                                  gapH16,
                                  Row(
                                    children: [
                                      Text('header'.tr),
                                      gapW64,
                                      ReusableRadioBtns(
                                        isRow: true,
                                        groupVal: salesInvoiceCont
                                            .selectedHeaderIndex,
                                        title1: salesInvoiceCont
                                            .headersList[0]['header_name'],
                                        title2: salesInvoiceCont
                                            .headersList[1]['header_name'],
                                        func: (value) {
                                          if(value==1){
                                            salesInvoiceCont.setSelectedHeaderIndex(1);
                                            salesInvoiceCont.setSelectedHeader( salesInvoiceCont
                                                .headersList[0]);
                                          }else{
                                            salesInvoiceCont.setSelectedHeaderIndex(2);
                                            salesInvoiceCont.setSelectedHeader( salesInvoiceCont
                                                .headersList[1]);
                                          }
                                        },
                                        width1: MediaQuery.of(context).size.width * 0.15,
                                        width2: MediaQuery.of(context).size.width * 0.15,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                                  : SizedBox.shrink(),
                              Row(
                                children: [
                                  Text('invoice'.tr),
                                  gapW64,
                                  ReusableRadioBtns(
                                    isRow: true,
                                    groupVal: salesInvoiceCont
                                        .selectedTypeIndex,
                                    title1: 'real'.tr,
                                    title2: 'estimate'.tr,
                                    func: (value) {
                                    if(value==1){
                                      salesInvoiceCont.setSelectedTypeIndex(1);
                                      salesInvoiceCont.setSelectedType('real');
                                    }else{
                                      salesInvoiceCont.setSelectedTypeIndex(2);
                                      salesInvoiceCont.setSelectedType('estimate');
                                    }
                                    },
                                    width1: MediaQuery.of(context).size.width * 0.15,
                                    width2: MediaQuery.of(context).size.width * 0.15,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        gapH16,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 0.0,
                              direction: Axis.horizontal,
                              children:
                                  tabsList
                                      .map(
                                        (element) => _buildTabChipItem(
                                          element,
                                          // element['id'],
                                          // element['name'],
                                          tabsList.indexOf(element),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                        // tabsContent[selectedTabIndex],
                        selectedTabIndex == 0
                            ? Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    // horizontal:
                                    //     MediaQuery.of(context).size.width * 0.01,
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Primary.primary,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(6),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left:
                                          MediaQuery.of(context).size.width *
                                          0.02,
                                    ),
                                    child: Obx(
                                      () => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TableTitle(
                                            text: 'item_code'.tr,
                                            width:
                                                homeController.isOpened.value
                                                    ? MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.13
                                                    : MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.16,
                                          ),
                                          TableTitle(
                                            text: 'description'.tr,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.28,
                                          ),
                                          TableTitle(
                                            text: 'quantity'.tr,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.04,
                                          ),
                                          TableTitle(
                                            text: 'unit_price'.tr,
                                            width:
                                                homeController.isOpened.value
                                                    ? MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.05
                                                    : MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.1,
                                          ),
                                          TableTitle(
                                            text: '${'disc'.tr}. %',
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.05,
                                          ),
                                          TableTitle(
                                            text: 'total'.tr,
                                            width:
                                                homeController.isOpened.value
                                                    ? MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.07
                                                    : MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.1,
                                          ),
                                          TableTitle(
                                            text: 'more_options'.tr,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.07,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                        0.01,
                                  ),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6),
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height:
                                            salesInvoiceCont
                                                .listViewLengthInSalesInvoice,
                                        child: ScrollConfiguration(
                                          behavior:
                                              const MaterialScrollBehavior()
                                                  .copyWith(
                                                    dragDevices: {
                                                      PointerDeviceKind.touch,
                                                      PointerDeviceKind.mouse,
                                                    },
                                                  ),
                                          child: ReorderableListView.builder(
                                            itemCount:
                                                salesInvoiceCont
                                                    .rowsInListViewInSalesInvoice
                                                    .keys
                                                    .length,
                                            buildDefaultDragHandles: false,
                                            itemBuilder: (context, index) {
                                              final key =
                                                  salesInvoiceCont
                                                      .orderedKeys[index];
                                              final row =
                                                  salesInvoiceCont
                                                      .rowsInListViewInSalesInvoice[key]!;
                                              final lineType =
                                                  row['line_type_id'] ?? '';

                                              return SizedBox(
                                                key: ValueKey(key),
                                                // onDismissed: (direction) {
                                                //   setState(() {
                                                //     salesInvoiceCont
                                                //         .decrementListViewLengthInSalesInvoice(
                                                //           salesInvoiceCont
                                                //               .increment,
                                                //         );
                                                //     salesInvoiceCont
                                                //         .removeFromRowsInListViewInSalesInvoice(
                                                //           key,
                                                //         );
                                                //   });
                                                // },
                                                child: SizedBox(
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width,
                                                  child: Row(
                                                    children: [
                                                      ReorderableDragStartListener(
                                                        index: index,
                                                        child: Container(
                                                          width:
                                                              MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.02,
                                                          height: 20,
                                                          margin:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 15,
                                                              ),
                                                          decoration: const BoxDecoration(
                                                            image: DecorationImage(
                                                              image: AssetImage(
                                                                'assets/images/newRow.png',
                                                              ),
                                                              fit:
                                                                  BoxFit
                                                                      .contain,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child:
                                                            lineType == '1'
                                                                ? ReusableTitleRow(
                                                                  index: key,
                                                                )
                                                                : lineType ==
                                                                    '2'
                                                                ? ReusableItemRow(
                                                                  index: key,
                                                                )
                                                                : lineType ==
                                                                    '3'
                                                                ? ReusableComboRow(
                                                                  index: key,
                                                                )
                                                                : lineType ==
                                                                    '4'
                                                                ? ReusableImageRow(
                                                                  index: key,
                                                                )
                                                                : ReusableNoteRow(
                                                                  index: key,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            onReorder: (oldIndex, newIndex) {
                                              setState(() {
                                                if (newIndex > oldIndex) {
                                                  newIndex -= 1;
                                                }
                                                final movedKey =
                                                    salesInvoiceCont.orderedKeys
                                                        .removeAt(oldIndex);
                                                salesInvoiceCont.orderedKeys
                                                    .insert(newIndex, movedKey);
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ReusableAddCard(
                                            text: 'title'.tr,
                                            onTap: () {
                                              setState(() {
                                                addTitle = true;
                                                addItem = false;
                                              });
                                              addNewTitle();
                                            },
                                          ),
                                          gapW32,
                                          ReusableAddCard(
                                            text: 'item'.tr,
                                            onTap: () {
                                              setState(() {
                                                addItem = true;
                                              });
                                              addNewItem();
                                            },
                                          ),
                                          gapW32,
                                          ReusableAddCard(
                                            text: 'combo'.tr,
                                            onTap: () {
                                              addNewCombo();
                                            },
                                          ),
                                          gapW32,
                                          ReusableAddCard(
                                            text: 'image'.tr,
                                            onTap: () {
                                              addNewImage();
                                            },
                                          ),
                                          gapW32,
                                          ReusableAddCard(
                                            text: 'note'.tr,
                                            onTap: () {
                                              addNewNote();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                gapH24,
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 40,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'note'.tr,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: TypographyColor.titleTable,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      gapH16,
                                      // ReusableTextField(
                                      //   textEditingController:
                                      //       termsAndConditionsController, //todo
                                      //   isPasswordField: false,
                                      //   hint: 'terms_conditions'.tr,
                                      //   onChangedFunc: (val) {},
                                      //   validationFunc: (val) {
                                      //     setState(() {
                                      //       termsAndConditions = val;
                                      //     });
                                      //   },
                                      // ),
                                      SizedBox(
                                        height: 200,
                                        child: Column(
                                          children: [
                                            QuillSimpleToolbar(
                                              controller: _controller,
                                              config: QuillSimpleToolbarConfig(
                                                showFontFamily: false,
                                                showColorButton: false,
                                                showBackgroundColorButton:
                                                    false,
                                                showSearchButton: false,
                                                showDirection: false,
                                                showLink: false,
                                                showAlignmentButtons: false,
                                                showLeftAlignment: false,
                                                showRightAlignment: false,
                                                showListCheck: false,
                                                showIndent: false,
                                                showQuote: false,
                                                showCodeBlock: false,
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                color: Colors.grey[100],
                                                child: QuillEditor.basic(
                                                  controller: _controller,

                                                  // readOnly: false, // اجعلها true إذا كنت تريد وضع القراءة فقط
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // gapH16,
                                      // Text(
                                      //   'or_create_new_terms_conditions'.tr,
                                      //   style: TextStyle(
                                      //     fontSize: 16,
                                      //     color: Primary.primary,
                                      //     decoration: TextDecoration.underline,
                                      //     fontStyle: FontStyle.italic,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                gapH16,
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 40,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Primary.p20,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.4,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('total_before_vat'.tr),
                                                ReusableShowInfoCard(
                                                  text: formatDoubleWithCommas(
                                                    salesInvoiceController
                                                        .totalItems,
                                                  ),
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.1,
                                                ),
                                              ],
                                            ),
                                            gapH6,
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('global_disc'.tr),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.1,
                                                      child: ReusableNumberField(
                                                        textEditingController:
                                                            globalDiscPercentController,
                                                        isPasswordField: false,
                                                        isCentered: true,
                                                        hint: '0',
                                                        onChangedFunc: (val) {
                                                          setState(() {
                                                            if (val == '') {
                                                              globalDiscPercentController
                                                                  .text = '0';
                                                              globalDiscountPercentage =
                                                                  '0';
                                                            } else {
                                                              globalDiscountPercentage =
                                                                  val;
                                                            }
                                                          });
                                                          salesInvoiceCont
                                                              .setGlobalDisc(
                                                                globalDiscountPercentage,
                                                              );
                                                        },
                                                        validationFunc:
                                                            (val) {},
                                                      ),
                                                    ),
                                                    gapW10,
                                                    ReusableShowInfoCard(
                                                      text: formatDoubleWithCommas(
                                                        double.parse(
                                                          salesInvoiceController
                                                              .globalDisc,
                                                        ),
                                                      ),
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.1,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            gapH6,
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('special_disc'.tr),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.1,
                                                      child: ReusableNumberField(
                                                        textEditingController:
                                                            specialDiscPercentController,
                                                        isPasswordField: false,
                                                        isCentered: true,
                                                        hint: '0',
                                                        onChangedFunc: (val) {
                                                          setState(() {
                                                            if (val == '') {
                                                              specialDiscPercentController
                                                                  .text = '0';
                                                              specialDiscountPercentage =
                                                                  '0';
                                                            } else {
                                                              specialDiscountPercentage =
                                                                  val;
                                                            }
                                                          });
                                                          salesInvoiceCont
                                                              .setSpecialDisc(
                                                                specialDiscountPercentage,
                                                              );
                                                        },
                                                        validationFunc:
                                                            (val) {},
                                                      ),
                                                    ),
                                                    gapW10,
                                                    ReusableShowInfoCard(
                                                      text: formatDoubleWithCommas(
                                                        double.parse(
                                                          salesInvoiceController
                                                              .specialDisc,
                                                        ),
                                                      ),

                                                      // salesInvoiceCont.specialDisc,
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.1,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            gapH6,
                                            salesInvoiceCont.isVatNoPrinted
                                                ? SizedBox()
                                                : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      salesInvoiceCont
                                                              .isPrintedAsVatExempt
                                                          ? 'vat_exempt'.tr
                                                              .toUpperCase()
                                                          : salesInvoiceCont
                                                              .isPrintedAs0
                                                          ? '${'vat'.tr} 0%'
                                                          : 'vat'.tr,
                                                    ),
                                                    Row(
                                                      children: [
                                                        ReusableShowInfoCard(
                                                          text: formatDoubleWithCommas(
                                                            double.parse(
                                                              salesInvoiceCont
                                                                  .vatInPrimaryCurrency,
                                                            ),
                                                          ),
                                                          width:
                                                              MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.1,
                                                        ),
                                                        gapW10,
                                                        ReusableShowInfoCard(
                                                          text: formatDoubleWithCommas(
                                                            double.parse(
                                                              salesInvoiceCont
                                                                  .vat11,
                                                            ),
                                                          ),
                                                          width:
                                                              MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.1,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                            gapH10,
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'total_amount'.tr,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Primary.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '${salesInvoiceCont.selectedCurrencyName} ${formatDoubleWithCommas(double.parse(salesInvoiceCont.totalSalesInvoice))}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Primary.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                gapH28,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ReusableButtonWithColor(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                      height: 45,
                                      onTapFunction: () async {
                                        _saveContent();
                                        bool hasType1WithEmptyTitle =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '1' &&
                                                      (map['title']?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType2WithEmptyId =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '2' &&
                                                      (map['item_id']
                                                              ?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType3WithEmptyId =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '3' &&
                                                      (map['combo']?.isEmpty ??
                                                          true);
                                                });
                                        bool hasType4WithEmptyImage =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '4' &&
                                                      (map['image'] ==
                                                              Uint8List(0) ||
                                                          map['image']
                                                              ?.isEmpty);
                                                });
                                        bool hasType5WithEmptyNote =
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice
                                                .values
                                                .any((map) {
                                                  return map['line_type_id'] ==
                                                          '5' &&
                                                      (map['note']?.isEmpty ??
                                                          true);
                                                });
                                        if (salesInvoiceController
                                            .rowsInListViewInSalesInvoice
                                            .isEmpty) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'Order lines is Empty',
                                          );
                                        } else if (hasType2WithEmptyId) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty item',
                                          );
                                        } else if (hasType3WithEmptyId) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty combo',
                                          );
                                        } else if (hasType1WithEmptyTitle) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty title',
                                          );
                                        } else if (hasType4WithEmptyImage) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty image',
                                          );
                                        } else if (hasType5WithEmptyNote) {
                                          CommonWidgets.snackBar(
                                            'error',
                                            'You have an empty note',
                                          );
                                        } else {
                                          var res = await storeSalesInvoice(
                                            refController.text,
                                            selectedCustomerIds,
                                            validityController.text,
                                            inputDateController.text,
                                            salesInvoiceCont
                                                .selectedWarehouseId,
                                            salesInvoiceCont.selectedPaymentTermId,
                                            salesInvoiceCont.salesInvoiceNumber,
                                            salesInvoiceCont
                                                .selectedPriceListId,
                                            salesInvoiceCont
                                                .selectedCurrencyId, //selectedCurrency
                                            termsAndConditionsController.text,
                                            selectedSalesPersonId.toString(),
                                            '', // commission method id
                                            salesInvoiceCont
                                                .selectedCashingMethodId,
                                            commissionController.text,
                                            totalCommissionController.text,
                                            salesInvoiceController.totalItems
                                                .toString(), //total before vat
                                            specialDiscPercentController
                                                .text, // inserted by user
                                            salesInvoiceController
                                                .specialDisc, // calculated
                                            globalDiscPercentController.text,
                                            salesInvoiceController.globalDisc,
                                            salesInvoiceController.vat11
                                                .toString(), //vat
                                            salesInvoiceController
                                                .vatInPrimaryCurrency
                                                .toString(), //vatLebanese
                                            salesInvoiceController
                                                .totalSalesInvoice, //total

                                            salesInvoiceCont.isVatExemptChecked
                                                ? '1'
                                                : '0',
                                            salesInvoiceCont.isVatNoPrinted
                                                ? '1'
                                                : '0', //not printed
                                            salesInvoiceCont
                                                    .isPrintedAsVatExempt
                                                ? '1'
                                                : '0', //printedAsVatExempt
                                            salesInvoiceCont.isPrintedAs0
                                                ? '1'
                                                : '0', //printedAsPercentage
                                            salesInvoiceCont.isBeforeVatPrices
                                                ? '0'
                                                : '1', //vatInclusivePrices
                                            salesInvoiceCont.isBeforeVatPrices
                                                ? '1'
                                                : '0', //beforeVatPrices
                                            codeController.text, //code
                                            salesInvoiceController
                                                .rowsInListViewInSalesInvoice,
                                            salesInvoiceController.orderedKeys,
                                            salesInvoiceController.selectedInvoiceType,
                                              '${salesInvoiceCont.selectedHeader['id']}'
                                          );
                                          if (res['success'] == true) {
                                            CommonWidgets.snackBar(
                                              'Success',
                                              res['message'],
                                            );
                                            homeController.selectedTab.value =
                                                'sales_invoice_summary';
                                          } else {
                                            CommonWidgets.snackBar(
                                              'error',
                                              res['message'],
                                            );
                                          }
                                        }
                                      },
                                      btnText: 'create_sales_invoice'.tr,
                                    ),
                                  ],
                                ),
                              ],
                            )
                            // : selectedTabIndex == 1
                            // ? Container(
                            //   padding: EdgeInsets.symmetric(
                            //     horizontal:
                            //         MediaQuery.of(context).size.width * 0.04,
                            //     vertical: 15,
                            //   ),
                            //   decoration: const BoxDecoration(
                            //     borderRadius: BorderRadius.only(
                            //       bottomLeft: Radius.circular(6),
                            //       bottomRight: Radius.circular(6),
                            //     ),
                            //     color: Colors.white,
                            //   ),
                            //   child: GetBuilder<PendingDocsReviewController>(
                            //     builder: (cont) {
                            //       return Container(
                            //         height:
                            //             MediaQuery.of(context).size.height * 0.85,
                            //         child: SingleChildScrollView(
                            //           child: Column(
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.start,
                            //             children: [
                            //               Column(
                            //                 crossAxisAlignment:
                            //                     CrossAxisAlignment.start,
                            //                 children: [
                            //                   gapH20,
                            //                   PageTitle(
                            //                     text: 'sales_invoices_:'.tr,
                            //                   ),
                            //                   cont.isPendingDocsFetched
                            //                       ? Container(
                            //                         color: Colors.white,
                            //                         // height: listViewLength,
                            //                         height:
                            //                             MediaQuery.of(
                            //                               context,
                            //                             ).size.height *
                            //                             0.80, //listViewLength
                            //                         child: ListView.builder(
                            //                           scrollDirection:
                            //                               Axis.vertical,
                            //                           itemCount:
                            //                               cont
                            //                                   .salesInvoicesPendingDocs
                            //                                   .length,
                            //                           itemBuilder:
                            //                               (
                            //                                 context,
                            //                                 index,
                            //                               ) => Column(
                            //                                 crossAxisAlignment:
                            //                                     CrossAxisAlignment
                            //                                         .start,
                            //                                 children: [
                            //                                   PendingAsRowInTableLinks(
                            //                                     info:
                            //                                         cont.salesInvoicesPendingDocs[index],
                            //                                     index: index,
                            //                                   ),
                            //                                   const Divider(),
                            //                                 ],
                            //                               ),
                            //                         ),
                            //                       )
                            //                       : const CircularProgressIndicator(),
                            //                 ],
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // )
                            : Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.04,
                                vertical: 15,
                              ),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                ),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.35,
                                    child: Column(
                                      children: [
                                        DialogDropMenu(
                                          controller: salesPersonController,
                                          optionsList:
                                              salesInvoiceCont
                                                  .salesPersonListNames,
                                          text: 'sales_person'.tr,
                                          hint: 'search'.tr,
                                          rowWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.3,
                                          textFieldWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.15,
                                          onSelected: (String? val) {
                                            setState(() {
                                              selectedSalesPerson = val!;
                                              var index = salesInvoiceCont
                                                  .salesPersonListNames
                                                  .indexOf(val);
                                              selectedSalesPersonId =
                                                  salesInvoiceCont
                                                      .salesPersonListId[index];
                                            });
                                          },
                                        ),
                                        gapH16,
                                        DialogDropMenu(
                                          optionsList: const [''],
                                          text: 'commission_method'.tr,
                                          hint: '',
                                          rowWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.3,
                                          textFieldWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.15,
                                          onSelected: () {},
                                        ),
                                        gapH16,
                                        DialogDropMenu(
                                          controller: cashingMethodsController,
                                          optionsList:
                                              salesInvoiceCont
                                                  .cashingMethodsNamesList,
                                          text: 'cashing_method'.tr,
                                          hint: '',
                                          rowWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.3,
                                          textFieldWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.15,
                                          onSelected: (value) {
                                            var index = salesInvoiceCont
                                                .cashingMethodsNamesList
                                                .indexOf(value);
                                            salesInvoiceCont
                                                .setSelectedCashingMethodId(
                                                  salesInvoiceCont
                                                      .cashingMethodsIdsList[index],
                                                );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        DialogTextField(
                                          textEditingController:
                                              commissionController,
                                          text: 'commission'.tr,
                                          rowWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.3,
                                          textFieldWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.15,
                                          validationFunc: (val) {},
                                        ),
                                        gapH16,
                                        DialogTextField(
                                          textEditingController:
                                              totalCommissionController,
                                          text: 'total_commission'.tr,
                                          rowWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.3,
                                          textFieldWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.15,
                                          validationFunc: (val) {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        gapH40,
                      ],
                    );
                  },
                ),
              ),
            )
            : loading();
      },
    );
  }

  Widget _buildTabChipItem(String name, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: ClipPath(
        clipper: const ShapeBorderClipper(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(9),
              topRight: Radius.circular(9),
            ),
          ),
        ),
        child: Container(
          width: MediaQuery.of(context).size.height * 0.18,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            color: selectedTabIndex == index ? Primary.p20 : Colors.white,
            border:
                selectedTabIndex == index
                    ? Border(top: BorderSide(color: Primary.primary, width: 3))
                    : null,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                spreadRadius: 9,
                blurRadius: 9,
                // offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Primary.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool addTitle = false;
  bool addItem = false;
  TextEditingController titleController = TextEditingController();
  String titleValue = '';
  addNewTitle() {
    setState(() {
      salesInvoiceController.salesInvoiceCounter += 1;
    });
    salesInvoiceController.incrementListViewLengthInSalesInvoice(
      salesInvoiceController.increment,
    );
    salesInvoiceController.addToRowsInListViewInSalesInvoice(
      salesInvoiceController.salesInvoiceCounter,
      {
        'line_type_id': '1',
        'item_id': '',
        'itemName': '',
        'item_main_code': '',
        'item_discount': '0',
        'item_description': '',
        'item_quantity': '0',
        'item_unit_price': '0',
        'item_total': '0',
        'title': '',
        'note': '',
        'combo': '',
      },
    );
    // Widget p = ReusableTitleRow(index: salesInvoiceController.salesInvoiceCounter);
  }

  addNewItem() {
    setState(() {
      salesInvoiceController.salesInvoiceCounter += 1;
    });
    salesInvoiceController.incrementListViewLengthInSalesInvoice(
      salesInvoiceController.increment,
    );

    salesInvoiceController.addToRowsInListViewInSalesInvoice(
      salesInvoiceController.salesInvoiceCounter,
      {
        'line_type_id': '2',
        'item_id': '',
        'itemName': '',
        // 'item_WarehouseId': '',
        'item_main_code': '',
        'item_discount': '0',
        'item_description': '',
        'item_quantity': '0',
        'item_unit_price': '0',
        'item_total': '0',
        'title': '',
        'note': '',
        'combo': '',
      },
    );
    salesInvoiceController.addToUnitPriceControllers(
      salesInvoiceController.salesInvoiceCounter,
    );
    // Widget p = ReusableItemRow(index: salesInvoiceController.salesInvoiceCounter);
  }

  addNewCombo() {
    setState(() {
      salesInvoiceController.salesInvoiceCounter += 1;
    });
    salesInvoiceController.incrementListViewLengthInSalesInvoice(
      salesInvoiceController.increment,
    );

    salesInvoiceController.addToRowsInListViewInSalesInvoice(
      salesInvoiceController.salesInvoiceCounter,
      {
        'line_type_id': '3',
        'item_id': '',
        'itemName': '',
        'item_main_code': '',
        'item_discount': '0',
        'item_description': '',
        'item_quantity': '0',
        'item_unit_price': '0',
        'item_total': '0',
        'title': '',
        'note': '',
        'combo': '',
      },
    );
    salesInvoiceController.addToCombosPricesControllers(
      salesInvoiceController.salesInvoiceCounter,
    );
  }

  addNewImage() {
    setState(() {
      salesInvoiceController.salesInvoiceCounter += 1;
    });
    salesInvoiceController.incrementListViewLengthInSalesInvoice(
      salesInvoiceController.increment + 50,
    );

    salesInvoiceController.addToRowsInListViewInSalesInvoice(
      salesInvoiceController.salesInvoiceCounter,
      {
        'line_type_id': '4',
        'item_id': '',
        'itemName': '',
        'item_main_code': '',
        'item_discount': '0',
        'item_description': '',
        'item_quantity': '0',
        'item_unit_price': '0',
        'item_total': '0',
        'title': '',
        'note': '',
        'combo': '',
        'image': Uint8List(0),
      },
    );
    // Widget p = ReusableImageRow(index: salesInvoiceController.salesInvoiceCounter);
  }

  addNewNote() {
    setState(() {
      salesInvoiceController.salesInvoiceCounter += 1;
    });
    salesInvoiceController.incrementListViewLengthInSalesInvoice(
      salesInvoiceController.increment,
    );

    salesInvoiceController.addToRowsInListViewInSalesInvoice(
      salesInvoiceController.salesInvoiceCounter,
      {
        'line_type_id': '5',
        'item_id': '',
        'itemName': '',
        'item_main_code': '',
        'item_discount': '0',
        'item_description': '',
        'item_quantity': '0',
        'item_unit_price': '0',
        'item_total': '0',
        'title': '',
        'note': '',
        'combo': '',
      },
    );
  }

  List<Step> getSteps() => [
    Step(
      title: const Text(''),
      content: Container(
        //page
      ),
      isActive: currentStep >= 0,
    ),
    Step(
      title: const Text(''),
      content: Container(),
      isActive: currentStep >= 1,
    ),
    Step(
      title: const Text(''),
      content: Container(),
      isActive: currentStep >= 2,
    ),
  ];

  String hoverTitle = '';
  String clickedTitle = '';
  bool isClicked = false;
  tableTitleWithOrderArrow(String text, double width, Function onClickedFunc) {
    return SizedBox(
      width: width,
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() {
              clickedTitle = text;
              hoverTitle = '';
              isClicked = !isClicked;
              onClickedFunc();
            });
          },
          onHover: (val) {
            if (val) {
              setState(() {
                hoverTitle = text;
              });
            } else {
              setState(() {
                hoverTitle = '';
              });
            }
          },
          child:
              clickedTitle == text
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text.length > 8 ? '${text.substring(0, 8)}...' : text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      isClicked
                          ? const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          )
                          : const Icon(
                            Icons.arrow_drop_up,
                            color: Colors.white,
                          ),
                    ],
                  )
                  : hoverTitle == text
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${text.length > 7 ? text.substring(0, 6) : text}...',
                        style: TextStyle(
                          color: Colors.white.withAlpha((0.5 * 255).toInt()),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white.withAlpha((0.5 * 255).toInt()),
                      ),
                    ],
                  )
                  : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}

//item
class ReusableItemRow extends StatefulWidget {
  const ReusableItemRow({super.key, required this.index});

  final int index;
  // final Map info;
  @override
  State<ReusableItemRow> createState() => _ReusableItemRowState();
}

class _ReusableItemRowState extends State<ReusableItemRow> {
  String discount = '0', result = '0', quantity = '0';

  String qty = '0';

  final ProductController productController = Get.find();
  final HomeController homeController = Get.find();

  TextEditingController itemCodeController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final SalesInvoiceController salesInvoiceController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();
  List<String> itemsList = [];
  String selectedItemId = '';
  int selectedItem = 0;
  bool isDataFetched = false;

  List items = [];
  String mainDescriptionVar = '';
  String mainCode = '';
  String itemName = '';
  // String warehouseId = '';
  String totalLine = '0';
  bool isSelected = false;
  String? selectedValue;
  final focus = FocusNode(); //price
  final focus1 = FocusNode(); //disc
  final dropFocus = FocusNode(); //dropdown
  final quantityFocus = FocusNode(); //quantity
  double taxRate = 1;
  double taxValue = 0;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // discountController.text = '0';
    // qtyController.text = '0';
    // discount = '0';
    // quantity = '0';
    itemCodeController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_main_code'];
    qtyController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_quantity'];
    discountController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_discount'];
    descriptionController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_description'];
    totalLine =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_total'];
    itemCodeController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_main_code'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesInvoiceController>(
      builder: (cont) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => ReusableDropDownMenusWithSearch(
                    list:
                        cont.itemsMultiPartList, // Assuming multiList is List<List<String>>
                    text: ''.tr,
                    hint: 'Item Code'.tr,
                    controller: itemCodeController,
                    onSelected: (String? value) async {
                      itemCodeController.text = value!;
                      setState(() {
                        selectedItemId =
                            '${cont.itemsIds[cont.itemsCode.indexOf(value.split(" | ")[0])]}'; //get the id by the first element of the list.
                        mainDescriptionVar =
                            cont.itemsDescription[selectedItemId];
                        mainCode = cont.itemsCodes[selectedItemId];
                        itemName = cont.itemsNames[selectedItemId];
                        // Map warehouseMapId = {};
                        // warehouseMapId['w'] = cont.warehousesInfo[selectedItemId];

                        // warehouseId = warehouseMapId['w'][0]['id'].toString();

                        descriptionController.text =
                            cont.itemsDescription[selectedItemId]!;

                        if (cont.itemsPricesCurrencies[selectedItemId] ==
                            cont.selectedCurrencyName) {
                          cont.unitPriceControllers[widget.index]!.text =
                              cont.itemUnitPrice[selectedItemId].toString();
                        } else if (cont.selectedCurrencyName == 'USD' &&
                            cont.itemsPricesCurrencies[selectedItemId] !=
                                cont.selectedCurrencyName) {
                          var result = exchangeRatesController.exchangeRatesList
                              .firstWhere(
                                (item) =>
                                    item["currency"] ==
                                    cont.itemsPricesCurrencies[selectedItemId],
                                orElse: () => null,
                              );
                          var divider = '1';
                          if (result != null) {
                            divider = result["exchange_rate"].toString();
                          }
                          cont.unitPriceControllers[widget.index]!.text =
                              '${double.parse('${(double.parse(cont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                        } else if (cont.selectedCurrencyName != 'USD' &&
                            cont.itemsPricesCurrencies[selectedItemId] ==
                                'USD') {
                          cont.unitPriceControllers[widget.index]!.text =
                              '${double.parse('${(double.parse(cont.itemUnitPrice[selectedItemId].toString()) * double.parse(cont.exchangeRateForSelectedCurrency))}')}';
                        } else {
                          var result = exchangeRatesController.exchangeRatesList
                              .firstWhere(
                                (item) =>
                                    item["currency"] ==
                                    cont.itemsPricesCurrencies[selectedItemId],
                                orElse: () => null,
                              );
                          var divider = '1';
                          if (result != null) {
                            divider = result["exchange_rate"].toString();
                          }
                          var usdPrice =
                              '${double.parse('${(double.parse(cont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                          cont.unitPriceControllers[widget.index]!.text =
                              '${double.parse('${(double.parse(usdPrice) * double.parse(cont.exchangeRateForSelectedCurrency))}')}';
                        }
                        if (cont.isBeforeVatPrices) {
                          taxRate = 1;
                          taxValue = 0;
                        } else {
                          taxRate =
                              double.parse(cont.itemsVats[selectedItemId]) /
                              100.0;
                          taxValue =
                              taxRate *
                              double.parse(
                                cont.unitPriceControllers[widget.index]!.text,
                              );
                        }
                        cont.unitPriceControllers[widget.index]!.text =
                            '${double.parse(cont.unitPriceControllers[widget.index]!.text) + taxValue}';
                        qtyController.text = '1';
                        quantity = '1';
                        discountController.text = '0';
                        discount = '0';
                        cont
                            .unitPriceControllers[widget.index]!
                            .text = double.parse(
                          cont.unitPriceControllers[widget.index]!.text,
                        ).toStringAsFixed(2);
                        totalLine =
                            '${(int.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                        cont.setEnteredQtyInSalesInvoice(
                          widget.index,
                          quantity,
                        );
                        cont.setMainTotalInSalesInvoice(
                          widget.index,
                          totalLine,
                        );
                        cont.getTotalItems();
                      });
                      cont.setEnteredUnitPriceInSalesInvoice(
                        widget.index,
                        cont.unitPriceControllers[widget.index]!.text,
                      );
                      cont.setItemIdInSalesInvoice(
                        widget.index,
                        selectedItemId,
                      );
                      cont.setItemNameInSalesInvoice(
                        widget.index,
                        itemName,
                        // value.split(" | ")[0],
                      ); // set only first element as name
                      cont.setMainCodeInSalesInvoice(widget.index, mainCode);
                      cont.setTypeInSalesInvoice(widget.index, '2');
                      cont.setMainDescriptionInSalesInvoice(
                        widget.index,
                        mainDescriptionVar,
                      );
                      // cont.setItemWareHouseInSalesInvoice(
                      //   widget.index,
                      //   warehouseId,
                      // );
                    },
                    validationFunc: (value) {
                      if (value == null || value.isEmpty) {
                        return 'select_option'.tr;
                      }
                      return null;
                    },
                    rowWidth:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.13
                            : MediaQuery.of(context).size.width * 0.16,
                    textFieldWidth:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.13
                            : MediaQuery.of(context).size.width * 0.16,
                    clickableOptionText: 'create_item'.tr,
                    isThereClickableOption: true,
                    onTappedClickableOption: () {
                      productController.clearData();
                      productController.getFieldsForCreateProductFromBack();
                      productController.setIsItUpdateProduct(false);
                      showDialog<String>(
                        context: context,
                        builder:
                            (BuildContext context) => const AlertDialog(
                              backgroundColor: Colors.white,
                              contentPadding: EdgeInsets.all(0),
                              titlePadding: EdgeInsets.all(0),
                              actionsPadding: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(9),
                                ),
                              ),
                              elevation: 0,
                              content: CreateProductDialogContent(),
                            ),
                      );
                    },
                    columnWidths: [
                      100.0,
                      200.0,
                      550.0,
                      100.0,
                    ], // Set column widths
                    focusNode: dropFocus,
                    nextFocusNode: quantityFocus,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.27,
                  child: TextFormField(
                    style: GoogleFonts.openSans(fontSize: 12),
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    controller: descriptionController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      errorStyle: const TextStyle(fontSize: 10.0),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        borderSide: BorderSide(width: 1, color: Colors.red),
                      ),
                    ),
                    validator: (String? value) {
                      return null;
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        mainDescriptionVar = val;
                      });
                      _formKey.currentState!.validate();
                      cont.setMainDescriptionInSalesInvoice(
                        widget.index,
                        mainDescriptionVar,
                      );
                    },
                  ),
                ),

                //quantity
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                  child: TextFormField(
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      // fontWeight: FontWeight.w500,
                    ),
                    focusNode: quantityFocus,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    textAlign: TextAlign.center,
                    controller: qtyController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      errorStyle: const TextStyle(fontSize: 10.0),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        borderSide: BorderSide(width: 1, color: Colors.red),
                      ),
                    ),
                    validator: (String? value) {
                      if (value!.isEmpty || double.parse(value) <= 0) {
                        return 'must be >0';
                      }
                      return null;
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                      // WhitelistingTextInputFormatter.digitsOnly
                    ],
                    onChanged: (val) {
                      setState(() {
                        quantity = val;
                        totalLine =
                            '${(int.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                        // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';
                      });

                      _formKey.currentState!.validate();
                      // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));

                      cont.setEnteredQtyInSalesInvoice(widget.index, val);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      cont.getTotalItems();
                    },
                  ),
                ),
                // unitPrice
                Obx(
                  () => SizedBox(
                    width:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.05
                            : MediaQuery.of(context).size.width * 0.1,
                    child: TextFormField(
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        // fontWeight: FontWeight.w500,
                      ),
                      focusNode: focus,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(focus1);
                      },
                      textAlign: TextAlign.center,
                      controller: cont.unitPriceControllers[widget.index],
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: "".tr,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black.withAlpha((0.1 * 255).toInt()),
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black.withAlpha((0.1 * 255).toInt()),
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        errorStyle: const TextStyle(fontSize: 10.0),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                      ),
                      validator: (String? value) {
                        return null;
                      },
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                        signed: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                        // WhitelistingTextInputFormatter.digitsOnly
                      ],
                      onChanged: (val) {
                        setState(() {
                          if (val == '') {
                            cont.unitPriceControllers[widget.index]!.text = '0';
                          } else {
                            // cont.unitPriceControllers[widget.index]!.text = val;
                          }
                          // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';
                          totalLine =
                              '${(int.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                        });
                        _formKey.currentState!.validate();
                        // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                        cont.setEnteredUnitPriceInSalesInvoice(
                          widget.index,
                          val,
                        );
                        cont.setMainTotalInSalesInvoice(
                          widget.index,
                          totalLine,
                        );
                        cont.getTotalItems();
                      },
                    ),
                  ),
                ),
                //discount
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                  child: TextFormField(
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      // fontWeight: FontWeight.w500,
                    ),
                    focusNode: focus1,
                    onFieldSubmitted: (value) {
                      setState(() {
                        salesInvoiceController.salesInvoiceCounter += 1;
                      });
                      salesInvoiceController
                          .incrementListViewLengthInSalesInvoice(
                            salesInvoiceController.increment,
                          );

                      salesInvoiceController.addToRowsInListViewInSalesInvoice(
                        salesInvoiceController.salesInvoiceCounter,
                        {
                          'line_type_id': '2',
                          'item_id': '',
                          'itemName': '',
                          // 'item_WarehouseId': '',
                          'item_main_code': '',
                          'item_discount': '0',
                          'item_description': '',
                          'item_quantity': '0',
                          'item_unit_price': '0',
                          'item_total': '0',
                          'title': '',
                          'note': '',
                          'combo': '',
                        },
                      );
                      salesInvoiceController.addToUnitPriceControllers(
                        salesInvoiceController.salesInvoiceCounter,
                      );
                      // Widget p = ReusableItemRow(index: salesInvoiceController.salesInvoiceCounter);
                    },
                    controller: discountController,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "".tr,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      errorStyle: const TextStyle(fontSize: 10.0),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        borderSide: BorderSide(width: 1, color: Colors.red),
                      ),
                    ),
                    validator: (String? value) {
                      return null;
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                      // WhitelistingTextInputFormatter.digitsOnly
                    ],
                    onChanged: (val) async {
                      setState(() {
                        if (val == '') {
                          discountController.text = '0';
                          discount = '0';
                        } else {
                          discount = val;
                        }

                        // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';

                        totalLine =
                            '${(int.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                      });
                      _formKey.currentState!.validate();

                      // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                      cont.setEnteredDiscInSalesInvoice(widget.index, val);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      await cont.getTotalItems();
                    },
                  ),
                ),

                //total
                Obx(
                  () => ReusableShowInfoCard(
                    text: formatDoubleWithCommas(
                      double.parse(
                        cont.rowsInListViewInSalesInvoice[widget
                            .index]['item_total'],
                      ),
                    ),
                    width:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.07
                            : MediaQuery.of(context).size.width * 0.1,
                  ),
                ),
                //more
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                        child: ReusableMore(
                          itemsList:
                              selectedItemId.isEmpty
                                  ? []
                                  : [
                                    PopupMenuItem<String>(
                                      value: '1',
                                      onTap: () async {
                                        showDialog<String>(
                                          context: context,
                                          builder:
                                              (
                                                BuildContext context,
                                              ) => AlertDialog(
                                                backgroundColor: Colors.white,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                            Radius.circular(9),
                                                          ),
                                                    ),
                                                elevation: 0,
                                                content:
                                                    ShowItemQuantitiesDialog(
                                                      selectedItemId:
                                                          selectedItemId,
                                                    ),
                                              ),
                                        );
                                      },
                                      child: const Text('Show Quantity'),
                                    ),
                                  ],
                        ),
                      ),

                      //delete
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.03,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              salesInvoiceController
                                  .decrementListViewLengthInSalesInvoice(
                                    salesInvoiceController.increment,
                                  );
                              salesInvoiceController
                                  .removeFromRowsInListViewInSalesInvoice(
                                    widget.index,
                                  );
                            });
                            setState(() {
                              cont.totalItems = 0.0;
                              cont.globalDisc = "0.0";
                              cont.globalDiscountPercentageValue = "0.0";
                              cont.specialDisc = "0.0";
                              cont.specialDiscountPercentageValue = "0.0";
                              cont.vat11 = "0.0";
                              cont.vatInPrimaryCurrency = "0.0";
                              cont.totalSalesInvoice = "0.0";
                            });
                            if (cont.rowsInListViewInSalesInvoice != {}) {
                              cont.getTotalItems();
                            }
                          },
                          child: Icon(
                            Icons.delete_outline,
                            color: Primary.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// title
class ReusableTitleRow extends StatefulWidget {
  const ReusableTitleRow({super.key, required this.index});
  final int index;
  // final Map info;
  @override
  State<ReusableTitleRow> createState() => _ReusableTitleRowState();
}

class _ReusableTitleRowState extends State<ReusableTitleRow> {
  TextEditingController titleController = TextEditingController();
  final SalesInvoiceController salesInvoiceController = Get.find();
  String titleValue = '0';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    titleController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['title'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesInvoiceController>(
      builder: (cont) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GetBuilder<HomeController>(
                  builder: (homeCont) {
                    double titleRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.63
                            : MediaQuery.of(context).size.width * 0.80;
                    return SizedBox(
                      width: titleRow,
                      // width: MediaQuery.of(context).size.width * 0.63,
                      child: ReusableTextField(
                        textEditingController: titleController,
                        isPasswordField: false,
                        hint: 'title'.tr,
                        onChangedFunc: (val) {
                          setState(() {
                            titleValue = val;
                          });
                          cont.setTypeInSalesInvoice(widget.index, '1');
                          cont.setTitleInSalesInvoice(widget.index, val);
                        },
                        validationFunc: (val) {},
                      ),
                    );
                  },
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                        child: const ReusableMore(
                          itemsList: [
                            // PopupMenuItem<String>(
                            //   value: '1',
                            //   onTap: () async {},
                            //   child: Row(
                            //     children: [
                            //       Text(''),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.03,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              salesInvoiceController
                                  .decrementListViewLengthInSalesInvoice(
                                    salesInvoiceController.increment,
                                  );
                              salesInvoiceController
                                  .removeFromRowsInListViewInSalesInvoice(
                                    widget.index,
                                  );
                            });
                          },
                          child: Icon(
                            Icons.delete_outline,
                            color: Primary.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// note
class ReusableNoteRow extends StatefulWidget {
  const ReusableNoteRow({super.key, required this.index});
  final int index;
  // final Map info;
  @override
  State<ReusableNoteRow> createState() => _ReusableNoteRowState();
}

class _ReusableNoteRowState extends State<ReusableNoteRow> {
  TextEditingController noteController = TextEditingController();
  final SalesInvoiceController salesInvoiceController = Get.find();
  String noteValue = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    noteController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['note'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GetBuilder<HomeController>(
              builder: (homeCont) {
                double noteRow =
                    homeCont.isMenuOpened
                        ? MediaQuery.of(context).size.width * 0.63
                        : MediaQuery.of(context).size.width * 0.80;
                return SizedBox(
                  width: noteRow,
                  // width: MediaQuery.of(context).size.width * 0.63,
                  child: ReusableTextField(
                    textEditingController: noteController,
                    isPasswordField: false,
                    hint: 'note'.tr,
                    onChangedFunc: (val) {
                      setState(() {
                        noteValue = val;
                      });
                      salesInvoiceController.setTypeInSalesInvoice(
                        widget.index,
                        '5',
                      );
                      salesInvoiceController.setNoteInSalesInvoice(
                        widget.index,
                        val,
                      );
                    },
                    validationFunc: (val) {},
                  ),
                );
              },
            ),
            //delete
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.07,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                    child: ReusableMore(
                      itemsList: [
                        // PopupMenuItem<String>(
                        //   value: '1',
                        //   onTap: () async {
                        //     showDialog<String>(
                        //         context: context,
                        //         builder: (BuildContext context) => AlertDialog(
                        //           backgroundColor: Colors.white,
                        //           shape: const RoundedRectangleBorder(
                        //             borderRadius:
                        //             BorderRadius.all(Radius.circular(9)),
                        //           ),
                        //           elevation: 0,
                        //           content: Column(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: [
                        //
                        //             ],
                        //           ),
                        //         ));
                        //   },
                        //   child: const Text('Show Quantity'),
                        // ),
                      ],
                    ),
                  ),
                  //delete
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          salesInvoiceController
                              .decrementListViewLengthInSalesInvoice(
                                salesInvoiceController.increment,
                              );
                          salesInvoiceController
                              .removeFromRowsInListViewInSalesInvoice(
                                widget.index,
                              );
                        });
                      },
                      child: Icon(Icons.delete_outline, color: Primary.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// image
class ReusableImageRow extends StatefulWidget {
  const ReusableImageRow({super.key, required this.index});
  final int index;
  @override
  State<ReusableImageRow> createState() => _ReusableImageRowState();
}

class _ReusableImageRowState extends State<ReusableImageRow> {
  final SalesInvoiceController salesInvoiceController = Get.find();
  late Uint8List imageFile;

  double listViewLength = Sizes.deviceHeight * 0.08;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    imageFile =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['image'];
    super.initState();
  }

  Future<Uint8List> imageToUint8List(String imagePath) async {
    final imagePath = 'assets/images/browse.png';
    File data = File(imagePath);
    Uint8List images = await data.readAsBytes();
    return images;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GetBuilder<SalesInvoiceController>(
              builder: (cont) {
                return InkWell(
                  onTap: () async {
                    final image = await ImagePickerHelper.pickImage();
                    setState(() {
                      imageFile = image!;
                      cont.changeBoolVar(true);
                      cont.increaseImageSpace(30);
                    });
                    cont.setTypeInSalesInvoice(widget.index, '4');
                    cont.setImageInSalesInvoice(widget.index, imageFile);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 5,
                    ),
                    child: DottedBorder(
                      dashPattern: const [10, 10],
                      color: Others.borderColor,
                      radius: const Radius.circular(9),
                      child: GetBuilder<HomeController>(
                        builder: (homeCont) {
                          double imageRow =
                              homeCont.isMenuOpened
                                  ? MediaQuery.of(context).size.width * 0.62
                                  : MediaQuery.of(context).size.width * 0.79;
                          return SizedBox(
                            width: imageRow,
                            // width: MediaQuery.of(context).size.width * 0.62,
                            height: cont.imageSpaceHeight,
                            child:
                                imageFile.isNotEmpty
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.memory(
                                          imageFile,
                                          height: cont.imageSpaceHeight,
                                        ),
                                      ],
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        gapW20,
                                        Icon(
                                          Icons.cloud_upload_outlined,
                                          color: Others.iconColor,
                                          size: 32,
                                        ),
                                        gapW20,
                                        Text(
                                          'drag_drop_image'.tr,
                                          style: TextStyle(
                                            color: TypographyColor.textTable,
                                          ),
                                        ),
                                        Text(
                                          'browse'.tr,
                                          style: TextStyle(
                                            color: Primary.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            //more
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.07,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                    child: ReusableMore(
                      itemsList: [
                        // PopupMenuItem<String>(
                        //   value: '1',
                        //   onTap: () async {
                        //     showDialog<String>(
                        //         context: context,
                        //         builder: (BuildContext context) => AlertDialog(
                        //           backgroundColor: Colors.white,
                        //           shape: const RoundedRectangleBorder(
                        //             borderRadius:
                        //             BorderRadius.all(Radius.circular(9)),
                        //           ),
                        //           elevation: 0,
                        //           content: Column(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: [
                        //
                        //             ],
                        //           ),
                        //         ));
                        //   },
                        //   child: const Text('Show Quantity'),
                        // ),
                      ],
                    ),
                  ),
                  //delete
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          salesInvoiceController
                              .decrementListViewLengthInSalesInvoice(
                                salesInvoiceController.increment + 50,
                              );
                          salesInvoiceController
                              .removeFromRowsInListViewInSalesInvoice(
                                widget.index,
                              );
                        });
                      },
                      child: Icon(Icons.delete_outline, color: Primary.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//combo
class ReusableComboRow extends StatefulWidget {
  const ReusableComboRow({super.key, required this.index});
  final int index;

  @override
  State<ReusableComboRow> createState() => _ReusableComboRowState();
}

class _ReusableComboRowState extends State<ReusableComboRow> {
  String discount = '0', result = '0', quantity = '0';

  String qty = '0';
  final ProductController productController = Get.find();
  final HomeController homeController = Get.find();

  TextEditingController comboCodeController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final SalesInvoiceController salesInvoiceController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();
  List<String> itemsList = [];
  String selectedComboId = '';
  int selectedItem = 0;
  bool isDataFetched = false;

  String descriptionVar = '';
  String mainCode = '';
  String comboName = '';
  String totalLine = '0';
  bool isSelected = false;
  String? selectedValue;
  final focus = FocusNode(); //price
  final focus1 = FocusNode(); //disc
  final dropFocus = FocusNode(); //dropdown
  final quantityFocus = FocusNode(); //quantity
  double taxRate = 1;
  double taxValue = 0;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    comboCodeController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_main_code'];
    qtyController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_quantity'];
    discountController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_discount'];
    descriptionController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_description'];
    totalLine =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_total'];
    comboCodeController.text =
        salesInvoiceController.rowsInListViewInSalesInvoice[widget
            .index]['item_main_code'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesInvoiceController>(
      builder: (cont) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => ReusableDropDownMenusWithSearch(
                    list:
                        cont.combosMultiPartList, // Assuming multiList is List<List<String>>
                    text: ''.tr,
                    hint: 'combo'.tr,
                    controller: comboCodeController,
                    onSelected: (String? value) async {
                      comboCodeController.text = value!;
                      setState(() {
                        var ind = cont.combosCodesList.indexOf(
                          value.split(" | ")[0],
                        );
                        selectedComboId = cont.combosIdsList[ind];
                        descriptionVar = cont.combosDescriptionList[ind];
                        mainCode = cont.combosCodesList[ind];
                        comboName = cont.combosNamesList[ind];
                        descriptionController.text =
                            cont.combosDescriptionList[ind];

                        if (cont.combosPricesCurrencies[selectedComboId] ==
                            cont.selectedCurrencyName) {
                          cont.combosPriceControllers[widget.index]!.text =
                              cont.combosPricesList[ind].toString();
                        } else if (cont.selectedCurrencyName == 'USD' &&
                            cont.combosPricesCurrencies[selectedComboId] !=
                                cont.selectedCurrencyName) {
                          var result = exchangeRatesController.exchangeRatesList
                              .firstWhere(
                                (item) =>
                                    item["currency"] ==
                                    cont.combosPricesCurrencies[selectedComboId],
                                orElse: () => null,
                              );
                          var divider = '1';
                          if (result != null) {
                            divider = result["exchange_rate"].toString();
                          }
                          cont.combosPriceControllers[widget.index]!.text =
                              '${double.parse('${(double.parse(cont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                        } else if (cont.selectedCurrencyName != 'USD' &&
                            cont.combosPricesCurrencies[selectedComboId] ==
                                'USD') {
                          cont.combosPriceControllers[widget.index]!.text =
                              '${double.parse('${(double.parse(cont.combosPricesList[ind].toString()) * double.parse(cont.exchangeRateForSelectedCurrency))}')}';
                        } else {
                          var result = exchangeRatesController.exchangeRatesList
                              .firstWhere(
                                (item) =>
                                    item["currency"] ==
                                    cont.combosPricesCurrencies[selectedComboId],
                                orElse: () => null,
                              );
                          var divider = '1';
                          if (result != null) {
                            divider = result["exchange_rate"].toString();
                          }
                          var usdPrice =
                              '${double.parse('${(double.parse(cont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                          cont.combosPriceControllers[widget.index]!.text =
                              '${double.parse('${(double.parse(usdPrice) * double.parse(cont.exchangeRateForSelectedCurrency))}')}';
                        }
                        cont.combosPriceControllers[widget.index]!.text =
                            '${double.parse(cont.combosPriceControllers[widget.index]!.text) + taxValue}';
                        qtyController.text = '1';
                        quantity = '1';
                        discountController.text = '0';
                        discount = '0';
                        cont
                            .combosPriceControllers[widget.index]!
                            .text = double.parse(
                          cont.combosPriceControllers[widget.index]!.text,
                        ).toStringAsFixed(2);
                        totalLine =
                            '${(int.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                        cont.setEnteredQtyInSalesInvoice(
                          widget.index,
                          quantity,
                        );
                        cont.setMainTotalInSalesInvoice(
                          widget.index,
                          totalLine,
                        );
                        cont.getTotalItems();
                      });
                      cont.setEnteredUnitPriceInSalesInvoice(
                        widget.index,
                        cont.combosPriceControllers[widget.index]!.text,
                      );
                      cont.setComboInSalesInvoice(
                        widget.index,
                        selectedComboId,
                      );
                      cont.setItemNameInSalesInvoice(
                        widget.index,
                        comboName,
                        // value.split(" | ")[0],
                      ); // set only first element as name
                      cont.setMainCodeInSalesInvoice(widget.index, mainCode);
                      cont.setTypeInSalesInvoice(widget.index, '3');
                      cont.setMainDescriptionInSalesInvoice(
                        widget.index,
                        descriptionVar,
                      );
                    },
                    validationFunc: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return 'select_option'.tr;
                      // }
                      // return null;
                    },
                    rowWidth:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.13
                            : MediaQuery.of(context).size.width * 0.16,
                    textFieldWidth:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.13
                            : MediaQuery.of(context).size.width * 0.16,
                    clickableOptionText: 'create_virtual_combo'.tr,
                    isThereClickableOption: true,
                    onTappedClickableOption: () {
                      showDialog<String>(
                        context: context,
                        builder:
                            (BuildContext context) => const AlertDialog(
                              backgroundColor: Colors.white,
                              contentPadding: EdgeInsets.all(0),
                              titlePadding: EdgeInsets.all(0),
                              actionsPadding: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(9),
                                ),
                              ),
                              elevation: 0,
                              content: Combo(),
                            ),
                      );
                    },
                    columnWidths: [
                      100.0,
                      200.0,
                      550.0,
                      100.0,
                    ], // Set column widths
                    focusNode: dropFocus,
                    nextFocusNode: quantityFocus,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.27,
                  child: TextFormField(
                    style: GoogleFonts.openSans(fontSize: 12),
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    controller: descriptionController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      errorStyle: const TextStyle(fontSize: 10.0),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        borderSide: BorderSide(width: 1, color: Colors.red),
                      ),
                    ),
                    validator: (String? value) {
                      return null;
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        descriptionVar = val;
                      });
                      _formKey.currentState!.validate();
                      cont.setMainDescriptionInSalesInvoice(
                        widget.index,
                        descriptionVar,
                      );
                    },
                  ),
                ),

                //quantity
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,

                  child: TextFormField(
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      // fontWeight: FontWeight.w500,
                    ),
                    focusNode: quantityFocus,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    textAlign: TextAlign.center,
                    controller: qtyController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      errorStyle: const TextStyle(fontSize: 10.0),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        borderSide: BorderSide(width: 1, color: Colors.red),
                      ),
                    ),
                    validator: (String? value) {
                      if (value!.isEmpty || double.parse(value) <= 0) {
                        return 'must be >0';
                      }
                      return null;
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                      // WhitelistingTextInputFormatter.digitsOnly
                    ],
                    onChanged: (val) {
                      setState(() {
                        quantity = val;
                        totalLine =
                            '${(int.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                        // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';
                      });

                      _formKey.currentState!.validate();
                      // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));

                      cont.setEnteredQtyInSalesInvoice(widget.index, val);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      cont.getTotalItems();
                    },
                  ),

                  // ReusableNumberField(
                  //   textEditingController: qtyController,
                  //   isPasswordField: false,
                  //   isCentered: true,
                  //   hint: '0',
                  //   onChangedFunc: (val) {
                  //     setState(() {
                  //       quantity = val;
                  //       myTotal =
                  //           '${int.parse(quantity) * (int.parse(unitPrice) - int.parse(discount))}';
                  //       // myTotal='${int.parse(cont.quantity) * (int.parse(cont.unitPrice) - int.parse(cont.discount))}';
                  //     });
                  //     _formKey.currentState!.validate();
                  //     cont.setEnteredQtyInQuotation(widget.index, val);
                  //
                  //     cont.setMainTotalInQuotation(widget.index, myTotal);
                  //     cont.getTotalItems();
                  //   },
                  //   validationFunc: (String? value) {
                  //     if (value!.isEmpty || double.parse(value) <= 0) {
                  //       return 'must be >0';
                  //     }
                  //     return null;
                  //   },
                  // )
                ),
                // unitPrice
                Obx(
                  () => SizedBox(
                    width:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.05
                            : MediaQuery.of(context).size.width * 0.1,
                    child: TextFormField(
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        // fontWeight: FontWeight.w500,
                      ),
                      focusNode: focus,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(focus1);
                      },
                      textAlign: TextAlign.center,
                      controller: cont.combosPriceControllers[widget.index],
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: "".tr,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black.withAlpha((0.1 * 255).toInt()),
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black.withAlpha((0.1 * 255).toInt()),
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        errorStyle: const TextStyle(fontSize: 10.0),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          borderSide: BorderSide(width: 1, color: Colors.red),
                        ),
                      ),
                      validator: (String? value) {
                        return null;
                      },
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                        signed: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                        // WhitelistingTextInputFormatter.digitsOnly
                      ],
                      onChanged: (val) {
                        setState(() {
                          if (val == '') {
                            cont.combosPriceControllers[widget.index]!.text =
                                '0';
                          } else {
                            // cont.unitPriceControllers[widget.index]!.text = val;
                          }
                          // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';
                          totalLine =
                              '${(int.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                        });
                        _formKey.currentState!.validate();
                        // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                        cont.setEnteredUnitPriceInSalesInvoice(
                          widget.index,
                          val,
                        );
                        cont.setMainTotalInSalesInvoice(
                          widget.index,
                          totalLine,
                        );
                        cont.getTotalItems();
                      },
                    ),
                  ),
                ),
                //discount
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                  child: TextFormField(
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      // fontWeight: FontWeight.w500,
                    ),
                    focusNode: focus1,
                    onFieldSubmitted: (value) {
                      setState(() {
                        salesInvoiceController.salesInvoiceCounter += 1;
                      });
                      salesInvoiceController
                          .incrementListViewLengthInSalesInvoice(
                            salesInvoiceController.increment,
                          );

                      salesInvoiceController.addToRowsInListViewInSalesInvoice(
                        salesInvoiceController.salesInvoiceCounter,
                        {
                          'line_type_id': '3',
                          'item_id': '',
                          'itemName': '',
                          'item_main_code': '',
                          'item_discount': '0',
                          'item_description': '',
                          'item_quantity': '0',
                          'item_unit_price': '0',
                          'item_total': '0',
                          'title': '',
                          'note': '',
                          'combo': '',
                        },
                      );
                      salesInvoiceController.addToCombosPricesControllers(
                        salesInvoiceController.salesInvoiceCounter,
                      );
                    },
                    controller: discountController,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "".tr,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      errorStyle: const TextStyle(fontSize: 10.0),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        borderSide: BorderSide(width: 1, color: Colors.red),
                      ),
                    ),
                    validator: (String? value) {
                      return null;
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                      // WhitelistingTextInputFormatter.digitsOnly
                    ],
                    onChanged: (val) async {
                      setState(() {
                        if (val == '') {
                          discountController.text = '0';
                          discount = '0';
                        } else {
                          discount = val;
                        }

                        // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';

                        totalLine =
                            '${(int.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                      });
                      _formKey.currentState!.validate();

                      // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                      cont.setEnteredDiscInSalesInvoice(widget.index, val);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      await cont.getTotalItems();
                    },
                  ),
                ),

                //total
                Obx(
                  () => ReusableShowInfoCard(
                    text: formatDoubleWithCommas(
                      double.parse(
                        cont.rowsInListViewInSalesInvoice[widget
                            .index]['item_total'],
                      ),
                    ),
                    width:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.07
                            : MediaQuery.of(context).size.width * 0.1,
                  ),
                ),

                //more
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                        child: ReusableMore(itemsList: []),
                      ),

                      //delete
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.03,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              salesInvoiceController
                                  .decrementListViewLengthInSalesInvoice(
                                    salesInvoiceController.increment,
                                  );
                              salesInvoiceController
                                  .removeFromRowsInListViewInSalesInvoice(
                                    widget.index,
                                  );
                            });
                            setState(() {
                              cont.totalItems = 0.0;
                              cont.globalDisc = "0.0";
                              cont.globalDiscountPercentageValue = "0.0";
                              cont.specialDisc = "0.0";
                              cont.specialDiscountPercentageValue = "0.0";
                              cont.vat11 = "0.0";
                              cont.vatInPrimaryCurrency = "0.0";
                              cont.totalSalesInvoice = "0.0";
                            });
                            if (cont.rowsInListViewInSalesInvoice != {}) {
                              cont.getTotalItems();
                            }
                          },
                          child: Icon(
                            Icons.delete_outline,
                            color: Primary.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WarehouseAsRow extends StatelessWidget {
  const WarehouseAsRow({
    super.key,
    required this.info,
    required this.index,
    this.isDesktop = true,
  });
  final Map info;
  final int index;
  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TableItem(
            isCentered: false,
            text: '${info['name'] ?? ''}',
            width: isDesktop ? MediaQuery.of(context).size.width * 0.15 : 150,
          ),
          TableItem(
            isCentered: false,
            text:
                '${info['qty_on_hand'] ?? ''}${info['qty_in_default_packaging']['unitName']}',
            width: isDesktop ? MediaQuery.of(context).size.width * 0.15 : 150,
          ),
        ],
      ),
    );
  }
}

class ShowItemQuantitiesDialog extends StatelessWidget {
  const ShowItemQuantitiesDialog({super.key, required this.selectedItemId});
  final String selectedItemId;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesInvoiceController>(
      builder:
          (cont) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //table
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DialogTitle(
                      text: 'Quantities of ${cont.itemsNames[selectedItemId]}',
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: CircleAvatar(
                        backgroundColor: Primary.primary,
                        radius: 15,
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                gapH20,
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Primary.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TableTitle(
                        isCentered: false,
                        text: 'name'.tr,
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                      TableTitle(
                        isCentered: false,
                        text: 'quantity'.tr,
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        cont
                            .warehousesInfo[selectedItemId]
                            .length, // data from back
                    itemBuilder: (context, index) {
                      var info = cont.warehousesInfo[selectedItemId];
                      return WarehouseAsRow(info: info[index], index: index);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class PendingAsRowInTableLinks extends StatefulWidget {
  const PendingAsRowInTableLinks({
    super.key,
    required this.info,
    required this.index,
    this.isDesktop = true,
  });
  final Map info;
  final int index;
  final bool isDesktop;

  @override
  State<PendingAsRowInTableLinks> createState() =>
      _PendingAsRowInTableLinksState();
}

class _PendingAsRowInTableLinksState extends State<PendingAsRowInTableLinks> {
  final HomeController homeController = Get.find();
  final QuotationController quotationController = Get.find();
  final SalesInvoiceController salesInvoiceController = Get.find();
  final PendingDocsReviewController pendingDocsController = Get.find();

  bool isClicked = false;
  bool isClicked2 = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gapH20,
        InkWell(
          onTap: () {
            setState(() {
              isClicked = !isClicked;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
            child: SizedBox(
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.09
                      : 150,
              child: Text(
                '${widget.info['salesInvoiceNumber']}',
                style: TextStyle(
                  fontSize: 14,
                  color: TypographyColor.titleTable,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        isClicked == true
            ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                gapH16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    widget.info['salesOrder'] == null
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width:
                                  widget.isDesktop
                                      ? MediaQuery.of(context).size.width *
                                          0.005
                                      : 150,
                              child: Text(""),
                            ),
                            SizedBox(
                              width:
                                  widget.isDesktop
                                      ? MediaQuery.of(context).size.width * 0.07
                                      : 150,
                              child: Text(
                                widget.info['salesInvoiceNumber'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: TypographyColor.titleTable,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            gapW10,
                            SizedBox(
                              width:
                                  widget.isDesktop
                                      ? MediaQuery.of(context).size.width * 0.10
                                      : 150,
                              child: Text(
                                'is_new_sales_invoice'.tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: TypographyColor.titleTable,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width:
                                  widget.isDesktop
                                      ? MediaQuery.of(context).size.width *
                                          0.005
                                      : 150,
                            ),
                            SizedBox(
                              width:
                                  widget.isDesktop
                                      ? MediaQuery.of(context).size.width * 0.07
                                      : 150,
                              child: Text(
                                widget.info['salesInvoiceNumber'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: TypographyColor.titleTable,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            gapW10,
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isClicked2 = !isClicked2;
                                });
                              },
                              child: SizedBox(
                                width:
                                    widget.isDesktop
                                        ? MediaQuery.of(context).size.width *
                                            0.12
                                        : 150,
                                child: Text(
                                  'is : Sales Order [${widget.info['salesOrder']['salesOrderNumber']}]',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: TypographyColor.titleTable,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    gapW10,
                    isClicked2 == true
                        ? widget.info['salesOrder']['quotation'] == null
                            ? SizedBox(
                              width:
                                  widget.isDesktop
                                      ? MediaQuery.of(context).size.width * 0.10
                                      : 150,
                              child: Text(
                                'is_new_sales_order'.tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: TypographyColor.titleTable,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            )
                            : SizedBox(
                              width:
                                  widget.isDesktop
                                      ? MediaQuery.of(context).size.width * 0.13
                                      : 150,
                              child: Text(
                                'is : Quotation [${widget.info['salesOrder']['quotation']['quotationNumber']}]',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: TypographyColor.titleTable,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            )
                        : Text(""),

                    //---------------------------------------------
                  ],
                ),
                gapH16,
              ],
            )
            : Text(""),
      ],
    );
  }
}
