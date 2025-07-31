import 'dart:async';
import 'dart:convert';
import 'dart:ui';
// import 'dart:ffi';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/SalesInvoiceBackend/update_sales_invoice.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/pending_docs_review_controller.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Controllers/sales_invoice_controller.dart';
import 'package:rooster_app/Controllers/warehouse_controller.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/create_product_dialog.dart';
import 'package:rooster_app/Screens/SalesInvoice/create_new_sales_invoice.dart';
import 'package:rooster_app/Screens/client_order/create_client_dialog.dart';
import 'package:rooster_app/Screens/SalesInvoice/print_sales_invoice.dart';
import 'package:rooster_app/Widgets/TransferWidgets/reusable_show_info_card.dart';
import 'package:rooster_app/Widgets/dialog_drop_menu.dart';
import 'package:rooster_app/Widgets/loading.dart';
import 'package:rooster_app/Widgets/reusable_add_card.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import '../../Controllers/home_controller.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../Widgets/TransferWidgets/under_item_btn.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_drop_down_menu.dart';
import '../../Widgets/reusable_more.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_title.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../../const/constants.dart';
import '../../const/functions.dart';
import '../../const/urls.dart';
import '../Combo/combo.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';



class UpdateSalesInvoiceDialog extends StatefulWidget {
  const UpdateSalesInvoiceDialog({
    super.key,
    required this.index,
    required this.info,
  });
  final int index;
  final Map info;

  @override
  State<UpdateSalesInvoiceDialog> createState() =>
      _UpdateSalesInvoiceDialogState();
}

class _UpdateSalesInvoiceDialogState extends State<UpdateSalesInvoiceDialog> {
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

  final _formKey = GlobalKey<FormState>();
  String selectedSalesPerson = '';
  int selectedSalesPersonId = 0;
  List tabsList = ['order_lines', 'sales_commission'];
  TextEditingController cashingMethodsController = TextEditingController();
  TextEditingController salesPersonController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController refController = TextEditingController();
  TextEditingController validityController = TextEditingController();
  TextEditingController inputDateController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController vatExemptController = TextEditingController();
  TextEditingController vatController = TextEditingController();
  TextEditingController termsAndConditionsController = TextEditingController();

  TextEditingController globalDiscPercentController = TextEditingController();
  TextEditingController specialDiscPercentController = TextEditingController();
  TextEditingController commissionController = TextEditingController();
  TextEditingController totalCommissionController = TextEditingController();

  TextEditingController paymentTermsController = TextEditingController();
  TextEditingController priceConditionController = TextEditingController();
  TextEditingController priceListController = TextEditingController();
  TextEditingController warehouseController = TextEditingController();

  String selectedCurrency = '';

  String selectedItemCode = '';
  String selectedCustomerIds = '';

  List<String> termsList = [];

  final HomeController homeController = Get.find();
  final SalesInvoiceController salesInvoiceController = Get.find();
  final PendingDocsReviewController pendingDocsController = Get.find();
  final WarehouseController wareHouseController = Get.find();

  String cashMethodId = '';
  String clientId = '';
  String pricelistId = '';
  String salespersonId = ' ';
  String selectedWarehouseId = ' ';
  String warehouseName = ' ';
  String commissionMethodId = '';
  String currencyId = ' ';
  bool isPendingDocsFetched = false;

  String paymentTerm = '',
      priceListSelected = '',
      selectedCountry = '',
      selectedCity = '';
  String selectedPhoneCode = '', selectedMobileCode = '';
  int selectedClientType = 1;
  int selectedTabIndex = 0;

  String selectedItem = "";
  int currentStep = 0;
  int indexNum = 0;
  String globalDiscountPercentage = ''; // user insert this value
  String specialDiscountPercentage = ''; // user insert this value

  String selectedPaymentTerm = '',
      selectedPriceList = '',
      termsAndConditions = '',
      specialDisc = '',
      globalDisc = '';
  final ExchangeRatesController exchangeRatesController = Get.find();
  Map orderLine = {};

  getCurrency() async {
    salesInvoiceController.selectedCurrencyId =
        widget.info['currency']['id'].toString();
    selectedCurrency = widget.info['currency']['name'] ?? '';
    currencyController.text = selectedCurrency;
    int index = exchangeRatesController.currenciesNamesList.indexOf(
      selectedCurrency,
    );
    salesInvoiceController.selectedCurrencyId =
    exchangeRatesController.currenciesIdsList[index];
    salesInvoiceController.selectedCurrencyName = selectedCurrency;
    var vat = await getCompanyVatFromPref();
    salesInvoiceController.setCompanyVat(double.parse(vat));
    var companyCurrency = await getCompanyPrimaryCurrencyFromPref();
    salesInvoiceController.setCompanyPrimaryCurrency(companyCurrency);
    var result = exchangeRatesController.exchangeRatesList.firstWhere(
          (item) => item["currency"] == companyCurrency,
      orElse: () => null,
    );
    salesInvoiceController.setLatestRate(
      double.parse(result != null ? '${result["exchange_rate"]}' : '1'),
    );
  }

  // var isVatZero = false;
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
    if ('${widget.info['printedAsPercentage'] ?? ''}' == '1') {
      salesInvoiceController.isPrintedAs0 = true;
      vatExemptController.text = 'Printed as "vat 0 % = 0"';
    }
    if ('${widget.info['printedAsVatExempt']}' == '1') {
      salesInvoiceController.isPrintedAsVatExempt = true;
      vatExemptController.text = 'Printed as "vat exempted"';
    }
    if ('${widget.info['notPrinted'] ?? ''}' == '1') {
      salesInvoiceController.isVatNoPrinted = true;
      vatExemptController.text = 'No printed ';
    }
    salesInvoiceController.isVatExemptChecked =
    '${widget.info['vatExempt'] ?? ''}' == '1' ? true : false;
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

  // Restore content from saved string (e.g., from API)
  void _loadContent() {
    if (_savedContent == null) return;
    if (_savedContent == '[{"insert":"\n"}]') {
      _controller = QuillController.basic();
      return;
    }
    final delta = Delta.fromJson(jsonDecode(_savedContent!));
    final doc = Document.fromDelta(delta);

    setState(() {
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    });
  }

  int progressVar = 0;

  setProgressVar() {
    salesInvoiceController.status = widget.info['status'];
    progressVar =
    widget.info['status'] == "pending"
        ? 0
        : widget.info['status'] == 'sent'
        ? 1
        : widget.info['status'] == 'confirmed'
        ? 2
        : 0;
  }

  String oldTermsAndConditionsString = '';
  @override
  void initState() {
    // print('widget.info');
    // print(widget.info);

    checkVatExempt();
    getCurrency();
    salesInvoiceController.orderedKeys = [];
    salesInvoiceController.rowsInListViewInSalesInvoice = {};
    salesInvoiceController.salesInvoiceCounter=0;
    setProgressVar();
    if (widget.info['deliveredFromWarehouse'] != null) {
      warehouseName = '${widget.info['deliveredFromWarehouse']['name'] ?? ''}';
      selectedWarehouseId =
          widget.info['deliveredFromWarehouse']['id'].toString();
      selectedWarehouseId = selectedWarehouseId.toString();
      warehouseController.text = warehouseName;
    }

    validityController.text = widget.info['valueDate'] ?? '';
    inputDateController.text = widget.info['inputDate'] ?? '';
    if (widget.info['cashingMethod'] != null) {
      cashingMethodsController.text =
      '${widget.info['cashingMethod']['title'] ?? ''}';
      salesInvoiceController.selectedCashingMethodId =
      '${widget.info['cashingMethod']['id']}';
    }

    if (widget.info['pricelist'] != null) {
      priceListController.text = '${widget.info['pricelist']['code'] ?? ''}';
      salesInvoiceController.selectedPriceListId =
      '${widget.info['pricelist']['id']}';
    } else {
      priceListController.text = 'STANDARD';
    }

    if (widget.info['salesperson'] != null) {
      selectedSalesPerson = '${widget.info['salesperson']['name'] ?? ''}';
      salesPersonController.text =
      '${widget.info['salesperson']['name'] ?? ''}';
      selectedSalesPersonId = widget.info['salesperson']['id'] ?? 0;
    }

    if ('${widget.info['beforeVatPrices'] ?? ''}' == '1') {
      priceConditionController.text = 'Prices are before vat';
      salesInvoiceController.isBeforeVatPrices = true;
    }

    if ('${widget.info['vatInclusivePrices'] ?? ''}' == '1') {
      priceConditionController.text = 'Prices are vat inclusive';
      salesInvoiceController.isBeforeVatPrices = false;
    }

    searchController.text = widget.info['client']['name'] ?? '';
    selectedItem = widget.info['client']['name'] ?? '';
    codeController.text = widget.info['code'] ?? '';
    selectedItemCode = widget.info['code'] ?? '';
    selectedCustomerIds = widget.info['client']['id'].toString();
    refController.text = widget.info['reference'] ?? '';

    currencyController.text = widget.info['currency']['name'] ?? '';

    if (widget.info['termsAndConditions'] == null ||
        '${widget.info['termsAndConditions']}' == 'null') {
      oldTermsAndConditionsString = '[{"insert":"\n"}]';
      termsAndConditionsController.text = '[{"insert":"\n"}]';
      _savedContent = '[{"insert":"\n"}]';
    } else {
      oldTermsAndConditionsString = widget.info['termsAndConditions'];
      termsAndConditionsController.text = widget.info['termsAndConditions'];
      _savedContent = widget.info['termsAndConditions'];
    }

    _loadContent();

    globalDiscPercentController.text =
        widget.info['globalDiscount'] ?? '0.0'; // entered by user
    specialDiscPercentController.text =
        widget.info['specialDiscount'] ?? '0.0'; //entered by user
    salesInvoiceController.globalDisc =
        widget.info['globalDiscountAmount'] ?? '0.0';
    salesInvoiceController.specialDisc =
        widget.info['specialDiscountAmount'] ?? '0.0';
    salesInvoiceController.totalItems = double.parse(
      '${widget.info['totalBeforeVat'] ?? '0.0'}',
    );
    // print('isVatZero $isVatZero');
    salesInvoiceController.vat11 =
    salesInvoiceController.isVatExemptChecked
        ? '0'
        : '${widget.info['vat'] ?? ''}';
    salesInvoiceController.vatInPrimaryCurrency =
    salesInvoiceController.isVatExemptChecked
        ? '0'
        : '${widget.info['vatLebanese'] ?? ''}';

    // quotationController.totalQuotation = '${widget.info['total'] ?? ''}';
    salesInvoiceController.totalSalesInvoice = ((salesInvoiceController
        .totalItems -
        double.parse(salesInvoiceController.globalDisc) -
        double.parse(salesInvoiceController.specialDisc)) +
        double.parse(salesInvoiceController.vat11))
        .toStringAsFixed(2);
    salesInvoiceController.city[selectedCustomerIds] =
        widget.info['client']['city'] ?? '';
    salesInvoiceController.country[selectedCustomerIds] =
        widget.info['client']['country'] ?? '';
    salesInvoiceController.email[selectedCustomerIds] =
        widget.info['client']['email'] ?? '';
    salesInvoiceController.phoneNumber[selectedCustomerIds] =
        widget.info['client']['phoneNumber'] ?? '';
    salesInvoiceController.selectedSalesInvoiceData['orderLines'] =
        widget.info['orderLines'] ?? '';
    for (
    int i = 0;
    i < salesInvoiceController.selectedSalesInvoiceData['orderLines'].length;
    i++
    ) {
      salesInvoiceController.rowsInListViewInSalesInvoice[i + 1] =
      salesInvoiceController.selectedSalesInvoiceData['orderLines'][i];
      salesInvoiceController.orderedKeys.add(i + 1);
      if (widget.info['orderLines'][i]['line_type_id'] == 2) {
        salesInvoiceController.unitPriceControllers[i + 1] =
            TextEditingController();
      } else if (widget.info['orderLines'][i]['line_type_id'] == 3) {
        salesInvoiceController.combosPriceControllers[i + 1] =
            TextEditingController();}
    }
    // var keys =
    // salesInvoiceController.rowsInListViewInSalesInvoice.keys.toList();
    //
    // for (int i = 0; i < widget.info['orderLines'].length; i++) {
    //   if (widget.info['orderLines'][i]['line_type_id'] == 2) {
    //     salesInvoiceController.unitPriceControllers[i + 1] =
    //         TextEditingController();
    //     Widget p = ReusableItemRow(
    //       index: i + 1,
    //       info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
    //     );
    //
    //     salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
    //   } else if (widget.info['orderLines'][i]['line_type_id'] == 1) {
    //     Widget p = ReusableTitleRow(
    //       index: i + 1,
    //       info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
    //     );
    //     salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
    //   } else if (widget.info['orderLines'][i]['line_type_id'] == 5) {
    //     Widget p = ReusableNoteRow(
    //       index: i + 1,
    //       info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
    //     );
    //     salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
    //   } else if (widget.info['orderLines'][i]['line_type_id'] == 4) {
    //     Widget p = ReusableImageRow(
    //       index: i + 1,
    //       info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
    //     );
    //     salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
    //   } else if (widget.info['orderLines'][i]['line_type_id'] == 3) {
    //     salesInvoiceController.combosPriceControllers[i + 1] =
    //         TextEditingController();
    //     Widget p = ReusableComboRow(
    //       index: i + 1,
    //       info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
    //     );
    //     salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
    //   }
    // }

    salesInvoiceController.salesInvoiceCounter =
        salesInvoiceController.rowsInListViewInSalesInvoice.length;
    salesInvoiceController.listViewLengthInSalesInvoice =
        salesInvoiceController.rowsInListViewInSalesInvoice.length * 60;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesInvoiceController>(
      builder: (salesInvoiceCont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.9,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PageTitle(text: 'update_sales_invoice'.tr),
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: CircleAvatar(
                          backgroundColor: Primary.primary,
                          radius: 15.0,
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  gapH32,
                  Row(
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

                              itemsInfoPrint = [];
                              salesInvoiceItemInfo = {};
                              totalAllItems = 0;
                              salesInvoiceCont.totalAllItems = 0;
                              totalAllItems = 0;
                              salesInvoiceCont.totalAllItems = 0;
                              totalPriceAfterDiscount = 0;
                              additionalSpecialDiscount = 0;
                              totalPriceAfterSpecialDiscount = 0;
                              totalPriceAfterSpecialDiscountBysalesInvoiceCurrency =
                              0;
                              vatBySalesInvoiceCurrency = 0;
                              vatBySalesInvoiceCurrency = 0;
                              finalPriceBySalesInvoiceCurrency = 0;
                              for (var item in widget.info['orderLines']) {
                                if ('${item['line_type_id']}' == '2') {
                                  qty = item['item_quantity'];
                                  var map =
                                  salesInvoiceCont.itemsMap[item['item_id']
                                      .toString()];
                                  itemName = map['item_name'];
                                  itemPrice = double.parse(
                                    '${item['item_unit_price'] ?? '0'}',
                                  );
                                  //     map['unitPrice'] ?? 0.0;
                                  // formatDoubleWithCommas(map['unitPrice']);
                                  itemDescription = item['item_description'];
                                  itemImage =
                                  '${map['images']}' != '[]' &&
                                      map['images'] != null
                                      ? '$baseImage${map['images'][0]['img_url']}'
                                      : '';
                                  // itemCurrencyName = map['currency']['name'];
                                  // itemCurrencySymbol = map['currency']['symbol'];
                                  // itemCurrencyLatestRate =
                                  //     map['currency']['latest_rate'];
                                  if (map['itemGroups'] != null) {
                                    var firstBrandObject = map['itemGroups']
                                        .firstWhere(
                                          (obj) =>
                                      obj["root_name"]?.toLowerCase() ==
                                          "brand".toLowerCase(),
                                      orElse: () => null,
                                    );
                                    brand =
                                    firstBrandObject == null
                                        ? ''
                                        : firstBrandObject['name'] ?? '';
                                  }
                                  itemTotal = double.parse(
                                    '${item['item_total']}',
                                  );
                                  // itemTotal = double.parse(qty) * itemPrice;
                                  totalAllItems += itemTotal;
                                  salesInvoiceItemInfo = {
                                    'line_type_id': '2',
                                    'item_name': itemName,
                                    'item_description': itemDescription,
                                    'item_quantity': qty,
                                    'item_discount':
                                    item['item_discount'] ?? '0',
                                    'item_unit_price': formatDoubleWithCommas(
                                      itemPrice,
                                    ),
                                    'item_total': formatDoubleWithCommas(
                                      itemTotal,
                                    ),
                                    'item_image': itemImage,
                                    'item_brand': brand,
                                    'title': '',
                                    'isImageList': false,
                                    'note': '',
                                    'image': '',
                                  };
                                  itemsInfoPrint.add(salesInvoiceItemInfo);
                                } else if ('${item['line_type_id']}' == '3') {
                                  var qty = item['combo_quantity'];

                                  var ind = salesInvoiceCont.combosIdsList
                                      .indexOf(item['combo_id'].toString());
                                  var itemName =
                                  salesInvoiceCont.combosNamesList[ind];
                                  var itemPrice = double.parse(
                                    '${item['combo_unit_price'] ?? 0.0}',
                                  );
                                  var itemDescription =
                                  item['combo_description'];

                                  var itemTotal = double.parse(
                                    '${item['combo_total']}',
                                  );
                                  totalAllItems += itemTotal;
                                  var quotationItemInfo = {
                                    'line_type_id': '3',
                                    'item_name': itemName,
                                    'item_description': itemDescription,
                                    'item_quantity': qty,
                                    'item_unit_price': formatDoubleWithCommas(
                                      itemPrice,
                                    ),
                                    'item_discount':
                                    item['combo_discount'] ?? '0',
                                    'item_total': formatDoubleWithCommas(
                                      itemTotal,
                                    ),
                                    'note': '',
                                    'item_image': '',
                                    'item_brand': '',
                                    'isImageList': false,
                                    'title': '',
                                    'image': '',
                                  };
                                  itemsInfoPrint.add(quotationItemInfo);
                                } else if ('${item['line_type_id']}' == '1') {
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
                                    'note': '',
                                    'isImageList': false,
                                    'title': item['title'],
                                    'image': '',
                                  };
                                  itemsInfoPrint.add(quotationItemInfo);
                                } else if ('${item['line_type_id']}' == '5') {
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
                                    'title': '',
                                    'note': item['note'],
                                    'isImageList': false,
                                    'image': '',
                                  };
                                  itemsInfoPrint.add(quotationItemInfo);
                                } else if ('${item['line_type_id']}' == '4') {
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
                                    'title': '',
                                    'note': '',
                                    'image': '$baseImage${item['image']}',
                                    'isImageList': false,
                                  };
                                  itemsInfoPrint.add(quotationItemInfo);
                                }
                              }

                              totalPriceAfterDiscount =
                                  totalAllItems - discountOnAllItem;
                              additionalSpecialDiscount =
                                  totalPriceAfterDiscount *
                                      double.parse(
                                        widget.info['specialDiscount'] ?? '0',
                                      ) /
                                      100;
                              totalPriceAfterSpecialDiscount =
                                  totalPriceAfterDiscount -
                                      additionalSpecialDiscount;
                              totalPriceAfterSpecialDiscountBysalesInvoiceCurrency =
                                  totalPriceAfterSpecialDiscount;
                              vatBySalesInvoiceCurrency =
                              '${widget.info['vatExempt']}' == '1'
                                  ? 0
                                  : (totalPriceAfterSpecialDiscountBysalesInvoiceCurrency *
                                  double.parse(
                                    await getCompanyVatFromPref(),
                                  )) /
                                  100;
                              finalPriceBySalesInvoiceCurrency =
                                  totalPriceAfterSpecialDiscountBysalesInvoiceCurrency +
                                      vatBySalesInvoiceCurrency;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    // print('widget.info[ ${widget.info['termsAndConditions']}');
                                    return PrintSalesInvoice(
                                      isPrintedAs0:
                                      '${widget.info['printedAsPercentage']}' ==
                                          '1'
                                          ? true
                                          : false,
                                      isVatNoPrinted:
                                      '${widget.info['notPrinted']}' == '1'
                                          ? true
                                          : false,
                                      isPrintedAsVatExempt:
                                      '${widget.info['printedAsVatExempt']}' ==
                                          '1'
                                          ? true
                                          : false,
                                      isInSalesInvoice: true,
                                      salesInvoiceNumber:
                                      widget.info['salesInvoiceNumber'] ??
                                          '',
                                      creationDate:
                                      widget.info['valueDate'] ?? '',
                                      ref: widget.info['reference'] ?? '',
                                      receivedUser: '',
                                      senderUser: homeController.userName,
                                      status: widget.info['status'] ?? '',
                                      totalBeforeVat:
                                      widget.info['totalBeforeVat'] ?? '',
                                      discountOnAllItem:
                                      discountOnAllItem.toString(),
                                      totalAllItems: formatDoubleWithCommas(
                                        totalAllItems,
                                      ),

                                      globalDiscount:
                                      widget.info['globalDiscount'] ?? '0',

                                      totalPriceAfterDiscount:
                                      formatDoubleWithCommas(
                                        totalPriceAfterDiscount,
                                      ),
                                      additionalSpecialDiscount:
                                      additionalSpecialDiscount
                                          .toStringAsFixed(2),
                                      totalPriceAfterSpecialDiscount:
                                      formatDoubleWithCommas(
                                        totalPriceAfterSpecialDiscount,
                                      ),

                                      totalPriceAfterSpecialDiscountBySalesInvoiceCurrency:
                                      formatDoubleWithCommas(
                                        totalPriceAfterSpecialDiscountBysalesInvoiceCurrency,
                                      ),

                                      vatBySalesInvoiceCurrency:
                                      formatDoubleWithCommas(
                                        vatBySalesInvoiceCurrency,
                                      ),
                                      finalPriceBySalesInvoiceCurrency:
                                      formatDoubleWithCommas(
                                        finalPriceBySalesInvoiceCurrency,
                                      ),
                                      specialDisc: specialDisc.toString(),
                                      specialDiscount:
                                      widget.info['specialDiscount'] ?? '0',
                                      specialDiscountAmount:
                                      widget
                                          .info['specialDiscountAmount'] ??
                                          '',
                                      salesPerson:
                                      widget.info['salesperson'] != null
                                          ? widget
                                          .info['salesperson']['name']
                                          : '---',
                                      salesInvoiceCurrency:
                                      widget.info['currency']['name'] ?? '',
                                      salesInvoiceCurrencySymbol:
                                      widget.info['currency']['symbol'] ??
                                          '',
                                      salesInvoiceCurrencyLatestRate:
                                      widget
                                          .info['currency']['latest_rate'] ??
                                          '',
                                      clientPhoneNumber:
                                      widget.info['client'] != null
                                          ? widget.info['client']['phoneNumber'] ??
                                          '---'
                                          : "---",
                                      clientName:
                                      widget.info['client']['name'] ?? '',
                                      termsAndConditions:
                                      widget.info['termsAndConditions'] ??
                                          '',
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
                              if (_formKey.currentState!.validate()) {
                                _saveContent();
                                var res = await updateSalesInvoice(
                                  '${widget.info['id']}',
                                  // termsAndConditionsController.text!=oldTermsAndConditionsString,
                                  false,
                                  refController.text,
                                  selectedCustomerIds,
                                  validityController.text,
                                  selectedWarehouseId,
                                  '', //todo paymentTermsController.text,
                                  salesInvoiceCont.selectedPriceListId,
                                  salesInvoiceCont
                                      .selectedCurrencyId, //selectedCurrency
                                  termsAndConditionsController.text,
                                  selectedSalesPersonId.toString(),
                                  '',
                                  salesInvoiceCont.selectedCashingMethodId,
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
                                  salesInvoiceController.vat11.toString(), //vat
                                  salesInvoiceController.vatInPrimaryCurrency
                                      .toString(),
                                  salesInvoiceController
                                      .totalSalesInvoice, // salesInvoiceController.totalQuotation

                                  salesInvoiceCont.isVatExemptChecked
                                      ? '1'
                                      : '0',
                                  salesInvoiceCont.isVatNoPrinted ? '1' : '0',
                                  salesInvoiceCont.isPrintedAsVatExempt
                                      ? '1'
                                      : '0',
                                  salesInvoiceCont.isPrintedAs0 ? '1' : '0',
                                  salesInvoiceCont.isBeforeVatPrices
                                      ? '0'
                                      : '1',

                                  salesInvoiceCont.isBeforeVatPrices
                                      ? '1'
                                      : '0',
                                  codeController.text,
                                  salesInvoiceCont.status,
                                  salesInvoiceController.rowsInListViewInSalesInvoice,
                                  inputDateController.text,
                                  '${widget.info['invoiceDeliveryDate'] ?? ''}',
                                  salesInvoiceCont.orderedKeys
                                );
                                if (res['success'] == true) {
                                  Get.back();
                                  salesInvoiceController
                                      .getAllSalesInvoiceFromBackWithoutExcept();

                                  homeController.selectedTab.value =
                                  'sales_invoice_summary';
                                  CommonWidgets.snackBar(
                                    'Success',
                                    res['message'],
                                  );
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
                              if (_formKey.currentState!.validate()) {
                                _saveContent();
                                var res = await updateSalesInvoice(
                                  '${widget.info['id']}',
                                  // termsAndConditionsController.text!=oldTermsAndConditionsString,
                                  false,
                                  refController.text,
                                  selectedCustomerIds,
                                  validityController.text,
                                  selectedWarehouseId,
                                  '', //todo paymentTermsController.text,
                                  salesInvoiceCont.selectedPriceListId,
                                  salesInvoiceCont
                                      .selectedCurrencyId, //selectedCurrency
                                  termsAndConditionsController.text,
                                  selectedSalesPersonId.toString(),
                                  '',
                                  salesInvoiceCont.selectedCashingMethodId,
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
                                  salesInvoiceController.vat11.toString(), //vat
                                  salesInvoiceController.vatInPrimaryCurrency
                                      .toString(),
                                  salesInvoiceController
                                      .totalSalesInvoice, // salesInvoiceController.totalQuotation

                                  salesInvoiceCont.isVatExemptChecked
                                      ? '1'
                                      : '0',
                                  salesInvoiceCont.isVatNoPrinted ? '1' : '0',
                                  salesInvoiceCont.isPrintedAsVatExempt
                                      ? '1'
                                      : '0',
                                  salesInvoiceCont.isPrintedAs0 ? '1' : '0',
                                  salesInvoiceCont.isBeforeVatPrices
                                      ? '0'
                                      : '1',

                                  salesInvoiceCont.isBeforeVatPrices
                                      ? '1'
                                      : '0',
                                  codeController.text,
                                  salesInvoiceCont.status, // status,
                                  // salesInvoiceController.rowsInListViewInSalesInvoice,
                                  salesInvoiceController.rowsInListViewInSalesInvoice,
                                  inputDateController.text,
                                  '${widget.info['invoiceDeliveryDate'] ?? ''}',
                                  salesInvoiceCont.orderedKeys
                                );
                                if (res['success'] == true) {
                                  Get.back();
                                  salesInvoiceController
                                      .getAllSalesInvoiceFromBackWithoutExcept();
                                  homeController.selectedTab.value =
                                  'sales_invoice_summary';
                                  CommonWidgets.snackBar(
                                    'Success',
                                    res['message'],
                                  );
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
                                progressVar = 0;
                              });
                              salesInvoiceCont.setStatus('cancelled');
                              if (_formKey.currentState!.validate()) {
                                _saveContent();
                                var res = await updateSalesInvoice(
                                  '${widget.info['id']}',
                                  // termsAndConditionsController.text!=oldTermsAndConditionsString,
                                  false,
                                  refController.text,
                                  selectedCustomerIds,
                                  validityController.text,
                                  selectedWarehouseId,
                                  '', //todo paymentTermsController.text,
                                  salesInvoiceCont.selectedPriceListId,
                                  salesInvoiceCont
                                      .selectedCurrencyId, //selectedCurrency
                                  termsAndConditionsController.text,
                                  selectedSalesPersonId.toString(),
                                  '',
                                  salesInvoiceCont.selectedCashingMethodId,
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
                                  salesInvoiceController.vat11.toString(), //vat
                                  salesInvoiceController.vatInPrimaryCurrency
                                      .toString(),
                                  salesInvoiceController
                                      .totalSalesInvoice, // salesInvoiceController.totalQuotation

                                  salesInvoiceCont.isVatExemptChecked
                                      ? '1'
                                      : '0',
                                  salesInvoiceCont.isVatNoPrinted ? '1' : '0',
                                  salesInvoiceCont.isPrintedAsVatExempt
                                      ? '1'
                                      : '0',
                                  salesInvoiceCont.isPrintedAs0 ? '1' : '0',
                                  salesInvoiceCont.isBeforeVatPrices
                                      ? '0'
                                      : '1',

                                  salesInvoiceCont.isBeforeVatPrices
                                      ? '1'
                                      : '0',
                                  codeController.text,
                                  salesInvoiceCont.status, // status,
                                  // salesInvoiceController.rowsInListViewInSalesInvoice,
                                  salesInvoiceController.rowsInListViewInSalesInvoice,
                                  inputDateController.text,
                                  '${widget.info['invoiceDeliveryDate'] ?? ''}',
                                    salesInvoiceController.orderedKeys

                                );
                                if (res['success'] == true) {
                                  Get.back();
                                  salesInvoiceController
                                      .getAllSalesInvoiceFromBackWithoutExcept();
                                  homeController.selectedTab.value =
                                  'sales_invoice_summary';
                                  CommonWidgets.snackBar(
                                    'Success',
                                    res['message'],
                                  );
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
                  gapH16,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Others.divider),
                      borderRadius: const BorderRadius.all(Radius.circular(9)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.info['salesInvoiceNumber'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            DialogTextField(
                              textEditingController: refController,
                              text: '${'ref'.tr}:',
                              hint: 'manual_reference'.tr,
                              rowWidth:
                              MediaQuery.of(context).size.width * 0.18,
                              textFieldWidth:
                              MediaQuery.of(context).size.width * 0.15,
                              validationFunc: (val) {},
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('currency'.tr),
                                  GetBuilder<ExchangeRatesController>(
                                    builder: (cont) {
                                      return DropdownMenu<String>(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.10,
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
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Primary.primary.withAlpha(
                                                (0.2 * 255).toInt(),
                                              ),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                            const BorderRadius.all(
                                              Radius.circular(9),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Primary.primary.withAlpha(
                                                (0.4 * 255).toInt(),
                                              ),
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                            const BorderRadius.all(
                                              Radius.circular(9),
                                            ),
                                          ),
                                        ),
                                        // menuStyle: ,
                                        menuHeight: 250.0,
                                        dropdownMenuEntries:
                                        cont.currenciesNamesList.map<
                                            DropdownMenuEntry<String>
                                        >((String option) {
                                          return DropdownMenuEntry<String>(
                                            value: option,
                                            label: option,
                                          );
                                        }).toList(),
                                        enableFilter: true,
                                        onSelected: (String? val) {
                                          setState(() {
                                            selectedCurrency = val!;
                                            var index = cont.currenciesNamesList
                                                .indexOf(val);
                                            salesInvoiceCont
                                                .setSelectedCurrency(
                                              cont.currenciesIdsList[index],
                                              val,
                                            );
                                            var result = cont.exchangeRatesList
                                                .firstWhere(
                                                  (item) =>
                                              item["currency"] == val,
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
                                              } else if (val == 'USD' &&
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
                                                  '${(double.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_quantity']) * double.parse(salesInvoiceCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_discount']) / 100)}';
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
                                              salesInvoiceCont.getTotalItems();
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
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('value_date'.tr),
                                  DialogDateTextField(
                                    textEditingController: validityController,
                                    text: '',
                                    textFieldWidth:
                                    MediaQuery.of(context).size.width *
                                        0.10,
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
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Pricelist'.tr),
                                  DropdownMenu<String>(
                                    width:
                                    MediaQuery.of(context).size.width *
                                        0.10,
                                    // requestFocusOnTap: false,
                                    enableSearch: true,
                                    controller: priceListController,
                                    hintText: '',
                                    inputDecorationTheme: InputDecorationTheme(
                                      // filled: true,
                                      hintStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        25,
                                        5,
                                      ),
                                      // outlineBorder: BorderSide(color: Colors.black,),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.2 * 255).toInt(),
                                          ),
                                          width: 1.0,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.4 * 255).toInt(),
                                          ),
                                          width: 2.0,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                    ),
                                    // menuStyle: ,
                                    menuHeight: 250,
                                    dropdownMenuEntries:
                                    salesInvoiceCont.priceListsCodes
                                        .map<DropdownMenuEntry<String>>((
                                        String option,
                                        ) {
                                      return DropdownMenuEntry<String>(
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
                                      salesInvoiceCont.setSelectedPriceListId(
                                        salesInvoiceCont.priceListsIds[index],
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
                        gapH10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('input_date'.tr),
                                  DialogDateTextField(
                                    textEditingController: inputDateController,
                                    text: '',
                                    textFieldWidth:
                                    MediaQuery.of(context).size.width *
                                        0.10,
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
                            //code
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.37,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('code'.tr),
                                  DropdownMenu<String>(
                                    width:
                                    MediaQuery.of(context).size.width *
                                        0.13,
                                    // requestFocusOnTap: false,
                                    enableSearch: true,
                                    controller: codeController,
                                    hintText: '${'search'.tr}...',
                                    inputDecorationTheme: InputDecorationTheme(
                                      // filled: true,
                                      hintStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        25,
                                        5,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.2 * 255).toInt(),
                                          ),
                                          width: 1,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.4 * 255).toInt(),
                                          ),
                                          width: 2,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                    ),
                                    menuHeight: 250.0,
                                    dropdownMenuEntries:
                                    salesInvoiceCont.customerNumberList
                                        .map<DropdownMenuEntry<String>>((
                                        option,
                                        ) {
                                      return DropdownMenuEntry<String>(
                                        value: option,
                                        label: option,
                                      );
                                    })
                                        .toList(),
                                    enableFilter: true,
                                    onSelected: (String? val) {
                                      setState(() {
                                        selectedItemCode = val!;
                                        indexNum = salesInvoiceCont
                                            .customerNumberList
                                            .indexOf(selectedItemCode);
                                        selectedCustomerIds =
                                        salesInvoiceCont
                                            .customerIdsList[indexNum];
                                        searchController.text =
                                        salesInvoiceCont
                                            .customerNameList[indexNum];
                                      });
                                    },
                                  ),
                                  ReusableDropDownMenuWithSearch(
                                    list: salesInvoiceCont.customerNameList,
                                    text: '',
                                    hint: '${'search'.tr}...',
                                    controller: searchController,
                                    onSelected: (String? val) {
                                      setState(() {
                                        selectedItem = val!;
                                        var index = salesInvoiceCont
                                            .customerNameList
                                            .indexOf(selectedItem);
                                        selectedCustomerIds =
                                        salesInvoiceCont
                                            .customerIdsList[index];
                                        codeController.text =
                                        salesInvoiceCont
                                            .customerNumberList[index];

                                        // codeController =
                                        //     salesInvoiceController.codeController;
                                      });
                                    },
                                    validationFunc: (value) {},
                                    rowWidth:
                                    MediaQuery.of(context).size.width *
                                        0.15,
                                    textFieldWidth:
                                    MediaQuery.of(context).size.width *
                                        0.14,
                                    clickableOptionText: 'create_new_client'.tr,
                                    isThereClickableOption: true,
                                    onTappedClickableOption: () {
                                      showDialog<String>(
                                        context: context,
                                        builder:
                                            (BuildContext context) =>
                                        const AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                              Radius.circular(9),
                                            ),
                                          ),
                                          elevation: 0,
                                          content: CreateClientDialog(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            DialogTextField(
                              textEditingController: paymentTermsController,
                              text: 'payment_terms'.tr,
                              hint: '',
                              rowWidth:
                              MediaQuery.of(context).size.width * 0.24,
                              textFieldWidth:
                              MediaQuery.of(context).size.width * 0.15,
                              validationFunc: (val) {},
                            ),
                            // SizedBox(
                            //   width: MediaQuery.of(context).size.width * 0.24,
                            //   child: Row(
                            //     mainAxisAlignment:
                            //         MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Text('payment_terms'.tr),
                            //       GetBuilder<ExchangeRatesController>(
                            //         builder: (cont) {
                            //           return DropdownMenu<String>(
                            //             width:
                            //                 MediaQuery.of(context).size.width *
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
                            //                   color: Primary.primary.withAlpha(
                            //                     (0.2 * 255).toInt(),
                            //                   ),
                            //                   width: 1,
                            //                 ),
                            //                 borderRadius:
                            //                     const BorderRadius.all(
                            //                       Radius.circular(9),
                            //                     ),
                            //               ),
                            //               focusedBorder: OutlineInputBorder(
                            //                 borderSide: BorderSide(
                            //                   color: Primary.primary.withAlpha(
                            //                     (0.4 * 255).toInt(),
                            //                   ),
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
                            //                 termsList.map<
                            //                   DropdownMenuEntry<String>
                            //                 >((String option) {
                            //                   return DropdownMenuEntry<String>(
                            //                     value: option,
                            //                     label: option,
                            //                   );
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
                          ],
                        ),

                        gapH10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //address
                                  Row(
                                    children: [
                                      Text(
                                        '${'Street_building_floor'.tr} ',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      gapW10,
                                      Text(
                                        " ${salesInvoiceCont.street[selectedCustomerIds] ?? ''} ",
                                        style: const TextStyle(fontSize: 12),
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
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  gapH6,
                                  //tel
                                  Row(
                                    children: [
                                      Text(
                                        'phone_number'.tr,
                                        style: const TextStyle(fontSize: 12.0),
                                      ),
                                      gapW10,
                                      Text(
                                        "${salesInvoiceCont.phoneNumber[selectedCustomerIds] ?? ''}",
                                        style: const TextStyle(fontSize: 12.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            gapW16,
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'price'.tr,
                                    style:
                                    salesInvoiceCont.isVatExemptChecked
                                        ? TextStyle(color: Others.divider)
                                        : TextStyle(),
                                  ),
                                  GetBuilder<ExchangeRatesController>(
                                    builder: (cont) {
                                      return DropdownMenu<String>(
                                        enabled:
                                        !salesInvoiceCont
                                            .isVatExemptChecked,
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.15,
                                        // requestFocusOnTap: false,
                                        enableSearch: true,
                                        controller: priceConditionController,
                                        hintText: '',

                                        textStyle: const TextStyle(
                                          fontSize: 12.0,
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
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Others.divider,
                                              width: 1,
                                            ),
                                            borderRadius:
                                            const BorderRadius.all(
                                              Radius.circular(9),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Primary.primary.withAlpha(
                                                (0.2 * 255).toInt(),
                                              ),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                            const BorderRadius.all(
                                              Radius.circular(9),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Primary.primary.withAlpha(
                                                (0.4 * 255).toInt(),
                                              ),
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                            const BorderRadius.all(
                                              Radius.circular(9.0),
                                            ),
                                          ),
                                        ),
                                        // menuStyle: ,
                                        menuHeight: 250.0,
                                        dropdownMenuEntries:
                                        pricesVatConditions.map<
                                            DropdownMenuEntry<String>
                                        >((String option) {
                                          return DropdownMenuEntry<String>(
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
                                                  .setIsBeforeVatPrices(true);
                                            } else {
                                              salesInvoiceCont
                                                  .setIsBeforeVatPrices(false);
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
                                                  '${salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_id']}';
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
                                                    '${(double.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_quantity']) * double.parse(salesInvoiceCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_discount']) / 100)}';

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
                        gapH10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.20,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //vat
                                  salesInvoiceCont
                                      .isVatExemptCheckBoxShouldAppear
                                      ? Row(
                                    children: [
                                      Text(
                                        'vat#'.tr,
                                        style: const TextStyle(
                                          fontSize: 12.0,
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
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                            'deliver_warehouse'.tr,
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
                                                  Radius.circular(
                                                    9,
                                                  ),
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
                            salesInvoiceCont.isVatExemptCheckBoxShouldAppear
                                ? SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 0.28,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        'vat_exempt'.tr,
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      leading: Checkbox(
                                        value:
                                        salesInvoiceCont
                                            .isVatExemptChecked,
                                        onChanged: (bool? value) {
                                          salesInvoiceCont
                                              .setIsVatExemptChecked(
                                            value!,
                                          );
                                          if (value) {
                                            priceConditionController.text =
                                            'Prices are before vat';
                                            salesInvoiceCont
                                                .setIsBeforeVatPrices(true);
                                            vatExemptController.text =
                                            vatExemptList[0];
                                            salesInvoiceCont
                                                .setIsVatExempted(
                                              true,
                                              false,
                                              false,
                                            );
                                          } else {
                                            vatExemptController.clear();
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
                                  salesInvoiceCont.isVatExemptChecked ==
                                      false
                                      ? DropdownMenu<String>(
                                    width:
                                    MediaQuery.of(
                                      context,
                                    ).size.width *
                                        0.15,
                                    enableSearch: true,
                                    controller: vatExemptController,
                                    hintText: '',

                                    textStyle: const TextStyle(
                                      fontSize: 12.0,
                                    ),
                                    inputDecorationTheme:
                                    InputDecorationTheme(
                                      hintStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      enabledBorder:
                                      OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary
                                              .withAlpha(
                                            (0.2 * 255)
                                                .toInt(),
                                          ),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                        const BorderRadius.all(
                                          Radius.circular(
                                            9.0,
                                          ),
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
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                        const BorderRadius.all(
                                          Radius.circular(
                                            9.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // menuStyle: ,
                                    menuHeight: 250.0,
                                    dropdownMenuEntries:
                                    termsList.map<
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
                                    controller: vatExemptController,
                                    hintText: '',

                                    textStyle: const TextStyle(
                                      fontSize: 12.0,
                                    ),
                                    inputDecorationTheme:
                                    InputDecorationTheme(
                                      // filled: true,
                                      hintStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      enabledBorder:
                                      OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary
                                              .withAlpha(
                                            (0.2 * 255)
                                                .toInt(),
                                          ),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                        const BorderRadius.all(
                                          Radius.circular(
                                            9.0,
                                          ),
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
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                        const BorderRadius.all(
                                          Radius.circular(
                                            9.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // menuStyle: ,
                                    menuHeight: 250.0,
                                    dropdownMenuEntries:
                                    vatExemptList.map<
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
                        gapH10,
                      ],
                    ),
                  ),
                  gapH10,
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

                  selectedTabIndex == 0
                      ? Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          // horizontal:
                          //     MediaQuery.of(context).size.width * 0.01,
                          vertical: 15.0,
                        ),
                        decoration: BoxDecoration(
                          color: Primary.primary,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 0.02,
                            ),
                            TableTitle(
                              text: 'item_code'.tr,
                              width:
                              MediaQuery.of(context).size.width * 0.15,
                            ),
                            TableTitle(
                              text: 'description'.tr,
                              width:
                              MediaQuery.of(context).size.width * 0.3,
                            ),
                            TableTitle(
                              text: 'quantity'.tr,
                              width:
                              MediaQuery.of(context).size.width * 0.04,
                            ),
                            TableTitle(
                              text: 'unit_price'.tr,
                              width:
                              MediaQuery.of(context).size.width * 0.05,
                            ),
                            TableTitle(
                              text: '${'disc'.tr}. %',
                              width:
                              MediaQuery.of(context).size.width * 0.05,
                            ),
                            TableTitle(
                              text: 'total'.tr,
                              width:
                              MediaQuery.of(context).size.width * 0.06,
                            ),
                            TableTitle(
                              text: 'more_options'.tr,
                              width:
                              MediaQuery.of(context).size.width * 0.07,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                          MediaQuery.of(context).size.width * 0.01,
                        ),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height:
                              salesInvoiceCont
                                  .listViewLengthInSalesInvoice +
                                  50,
                              child: ScrollConfiguration(
                                behavior: const MaterialScrollBehavior()
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
                                    salesInvoiceCont.orderedKeys[index];
                                    final row =
                                    salesInvoiceCont
                                        .rowsInListViewInSalesInvoice[key]!;
                                    final lineType =
                                        '${row['line_type_id'] ?? ''}';
                                    return Dismissible(
                                      key: ValueKey(key),
                                      onDismissed: (direction) {
                                        setState(() {
                                          salesInvoiceCont
                                              .decrementListViewLengthInSalesInvoice(
                                            salesInvoiceCont
                                                .increment,
                                          );
                                          salesInvoiceCont
                                              .removeFromRowsInListViewInSalesInvoice(
                                            key,
                                          );
                                          // quotationController
                                          //     .removeFromOrderLinesInQuotationList(
                                          //   key.toString(),
                                          // );
                                        });
                                      },
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
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child:
                                              lineType == '1'
                                                  ? ReusableTitleRow(
                                                index: key,
                                                info: row,
                                              )
                                                  : lineType == '2'
                                                  ? ReusableItemRow(
                                                index: key,
                                                info: row,
                                              )
                                                  : lineType == '3'
                                                  ? ReusableComboRow(
                                                index: key,
                                                info: row,
                                              )
                                                  : lineType == '4'
                                                  ? ReusableImageRow(
                                                index: key,
                                                info: row,
                                              )
                                                  : ReusableNoteRow(
                                                index: key,
                                                info: row,
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
                                      final movedKey = salesInvoiceCont
                                          .orderedKeys
                                          .removeAt(oldIndex);
                                      salesInvoiceCont.orderedKeys.insert(
                                        newIndex,
                                        movedKey,
                                      );
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
                                    addNewTitle();
                                  },
                                ),
                                gapW32,
                                ReusableAddCard(
                                  text: 'item'.tr,
                                  onTap: () {
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
                    ],
                  )
                  // : selectedTabIndex == 1
                  // ? Container(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: MediaQuery.of(context).size.width * 0.04,
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
                  //         height: MediaQuery.of(context).size.height * 0.85,
                  //         child: SingleChildScrollView(
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Column(
                  //                 crossAxisAlignment:
                  //                     CrossAxisAlignment.start,
                  //                 children: [
                  //                   gapH20,
                  //                   PageTitle(text: 'sales_invoices'.tr),
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
                  //                           scrollDirection: Axis.vertical,
                  //                           itemCount:
                  //                               cont
                  //                                   .salesInvoicesPendingDocs
                  //                                   .length,
                  //                           itemBuilder:
                  //                               (context, index) => Column(
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
                      horizontal: MediaQuery.of(context).size.width * 0.04,
                      vertical: 15.0,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Column(
                            children: [
                              DialogDropMenu(
                                controller: salesPersonController,
                                optionsList:
                                salesInvoiceController
                                    .salesPersonListNames,
                                text: 'sales_person'.tr,
                                hint: 'search'.tr,
                                rowWidth:
                                MediaQuery.of(context).size.width * 0.3,
                                textFieldWidth:
                                MediaQuery.of(context).size.width *
                                    0.15,
                                onSelected: (String? val) {
                                  setState(() {
                                    selectedSalesPerson = val!;
                                    var index = salesInvoiceController
                                        .salesPersonListNames
                                        .indexOf(val);
                                    selectedSalesPersonId =
                                    salesInvoiceController
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
                                MediaQuery.of(context).size.width * 0.3,
                                textFieldWidth:
                                MediaQuery.of(context).size.width *
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
                                MediaQuery.of(context).size.width * 0.3,
                                textFieldWidth:
                                MediaQuery.of(context).size.width *
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
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              DialogTextField(
                                textEditingController: commissionController,
                                text: 'commission'.tr,
                                rowWidth:
                                MediaQuery.of(context).size.width * 0.3,
                                textFieldWidth:
                                MediaQuery.of(context).size.width *
                                    0.15,
                                validationFunc: (val) {},
                              ),
                              gapH16,
                              DialogTextField(
                                textEditingController:
                                totalCommissionController,
                                text: 'total_commission'.tr,
                                rowWidth:
                                MediaQuery.of(context).size.width * 0.3,
                                textFieldWidth:
                                MediaQuery.of(context).size.width *
                                    0.15,
                                validationFunc: (val) {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  gapH10,

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 40.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'terms_conditions'.tr,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: TypographyColor.titleTable,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        gapH16,
                        SizedBox(
                          height: 300.0,
                          child: Column(
                            children: [
                              QuillSimpleToolbar(
                                controller: _controller,
                                config: QuillSimpleToolbarConfig(
                                  showFontFamily: false,
                                  showColorButton: false,
                                  showBackgroundColorButton: false,
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
                                  padding: const EdgeInsets.all(8),
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
                        // ReusableTextField(
                        //   textEditingController:
                        //       termsAndConditionsController, //todo
                        //   isPasswordField: false,
                        //   hint: 'terms_conditions'.tr,
                        //   onChangedFunc: (val) {},
                        //   validationFunc: (val) {
                        //     // setState(() {
                        //     //   termsAndConditions = val;
                        //     // });
                        //   },
                        // ),
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

                  GetBuilder<SalesInvoiceController>(
                    builder: (cont) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 40.0,
                        ),
                        decoration: BoxDecoration(
                          color: Primary.p20,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('total_before_vat'.tr),
                                      ReusableShowInfoCard(
                                        text: cont.totalItems.toStringAsFixed(
                                          2,
                                        ),
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.1,
                                      ),
                                    ],
                                  ),
                                  gapH6,
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                // totalAllItems =
                                                //     salesInvoiceController
                                                //         .totalItems ;

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
                                                cont.setGlobalDisc(
                                                  globalDiscountPercentage,
                                                );
                                                // cont.getTotalItems();
                                              },
                                              validationFunc: (val) {},
                                            ),
                                          ),
                                          gapW10,
                                          ReusableShowInfoCard(
                                            text: cont.globalDisc,
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
                                    MainAxisAlignment.spaceBetween,
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
                                                cont.setSpecialDisc(
                                                  specialDiscountPercentage,
                                                );
                                              },
                                              validationFunc: (val) {},
                                            ),
                                          ),
                                          gapW10,
                                          ReusableShowInfoCard(
                                            text: cont.specialDisc,
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
                                  salesInvoiceCont
                                      .isVatExemptCheckBoxShouldAppear
                                      ? Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('vat'.tr),
                                      Row(
                                        children: [
                                          ReusableShowInfoCard(
                                            text: cont.vatInPrimaryCurrency,
                                            // .toString(),
                                            width:
                                            MediaQuery.of(
                                              context,
                                            ).size.width *
                                                0.1,
                                          ),
                                          gapW10,
                                          ReusableShowInfoCard(
                                            text: cont.vat11,
                                            // .toString(),
                                            width:
                                            MediaQuery.of(
                                              context,
                                            ).size.width *
                                                0.1,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                      : SizedBox(),
                                  gapH10,
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        // '${'usd'.tr} 0.00',
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
                      );
                    },
                  ),
                  gapH16,

                  //discard & save button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ReusableButtonWithColor(
                        btnText: 'save'.tr,
                        onTapFunction: () async {
                          if (_formKey.currentState!.validate()) {
                            _saveContent();
                            var invoiceDeliveryDate =
                            widget.info['invoiceDeliveryDate'] == null
                                ? ''
                                : '${widget.info['invoiceDeliveryDate']}';
                            var res = await updateSalesInvoice(
                              '${widget.info['id']}',
                              false,
                              refController.text,
                              selectedCustomerIds,
                              validityController.text,
                              salesInvoiceController.selectedWarehouseId,
                              '', //todo paymentTermsController.text,
                              salesInvoiceCont.selectedPriceListId,
                              salesInvoiceController
                                  .selectedCurrencyId, //selectedCurrency
                              termsAndConditionsController.text,
                              selectedSalesPersonId.toString(),
                              '',
                              salesInvoiceCont.selectedCashingMethodId,
                              commissionController.text,
                              totalCommissionController.text,
                              salesInvoiceController.totalItems
                                  .toString(), //total before vat
                              specialDiscPercentController
                                  .text, // inserted by user
                              salesInvoiceController.specialDisc, // calculated
                              globalDiscPercentController.text,
                              salesInvoiceController.globalDisc,
                              salesInvoiceController.vat11.toString(), //vat
                              salesInvoiceController.vatInPrimaryCurrency
                                  .toString(),
                              salesInvoiceController
                                  .totalSalesInvoice, // salesInvoiceController.totalQuotation

                              salesInvoiceCont.isVatExemptChecked ? '1' : '0',
                              salesInvoiceCont.isVatNoPrinted ? '1' : '0',
                              salesInvoiceCont.isPrintedAsVatExempt ? '1' : '0',
                              salesInvoiceCont.isPrintedAs0 ? '1' : '0',
                              salesInvoiceCont.isBeforeVatPrices ? '0' : '1',

                              salesInvoiceCont.isBeforeVatPrices ? '1' : '0',
                              codeController.text,
                              salesInvoiceCont.status,
                              salesInvoiceController.rowsInListViewInSalesInvoice,
                              inputDateController.text,
                              invoiceDeliveryDate,
                              salesInvoiceCont.orderedKeys
                            );
                            if (res['success'] == true) {
                              Get.back();
                              salesInvoiceController
                                  .getAllSalesInvoiceFromBackWithoutExcept();
                              // homeController.selectedTab.value = 'new_quotation';
                              homeController.selectedTab.value =
                              'sales_invoice_summary';
                              CommonWidgets.snackBar('Success', res['message']);
                            } else {
                              CommonWidgets.snackBar('error', res['message']);
                            }
                          }
                        },
                        width: 100,
                        height: 35,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    // : const CircularProgressIndicator();
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
  String titleValue = '';

  addNewTitle() {
    setState(() {
      salesInvoiceController.salesInvoiceCounter += 1;
    });
    salesInvoiceController.incrementListViewLengthInSalesInvoice(
      salesInvoiceController.increment,
    );
    salesInvoiceController
        .addToRowsInListViewInSalesInvoice(salesInvoiceController.salesInvoiceCounter, {
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
    });
  }


  addNewItem() {
    setState(() {
      salesInvoiceController.salesInvoiceCounter += 1;
    });
    salesInvoiceController.incrementListViewLengthInSalesInvoice(
      salesInvoiceController.increment,
    );
    salesInvoiceController
        .addToRowsInListViewInSalesInvoice(salesInvoiceController.salesInvoiceCounter, {
      'line_type_id': '2',
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
    });
    salesInvoiceController.addToUnitPriceControllers(salesInvoiceController.salesInvoiceCounter);

  }

  addNewCombo() {
    setState(() {
      salesInvoiceController.salesInvoiceCounter += 1;
    });
    salesInvoiceController.incrementListViewLengthInSalesInvoice(
      salesInvoiceController.increment,
    );
    salesInvoiceController
        .addToRowsInListViewInSalesInvoice(salesInvoiceController.salesInvoiceCounter, {
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
    });
    salesInvoiceController.addToCombosPricesControllers(salesInvoiceController.salesInvoiceCounter);

  }

  addNewImage() {
    setState(() {
      salesInvoiceController.salesInvoiceCounter += 1;
    });
    salesInvoiceController.incrementListViewLengthInSalesInvoice(
      salesInvoiceController.increment,
    );

    salesInvoiceController
        .addToRowsInListViewInSalesInvoice(salesInvoiceController.salesInvoiceCounter, {
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
      'image': Uint8List(0),
    });


  }

  addNewNote() {
    setState(() {
      salesInvoiceController.salesInvoiceCounter += 1;
    });
    salesInvoiceController.incrementListViewLengthInSalesInvoice(
      salesInvoiceController.increment,
    );

    salesInvoiceController
        .addToRowsInListViewInSalesInvoice(salesInvoiceController.salesInvoiceCounter, {
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
    });

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
}

class ReusableItemRow extends StatefulWidget {
  const ReusableItemRow({super.key, required this.index, required this.info});
  final int index;
  final Map info;
  @override
  State<ReusableItemRow> createState() => _ReusableItemRowState();
}

class _ReusableItemRowState extends State<ReusableItemRow> {
  String discount = '0', result = '0', quantity = '0';
  String qty = '0';

  TextEditingController itemCodeController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final ProductController productController = Get.find();
  final SalesInvoiceController salesInvoiceController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();

  String selectedItemId = '';
  String mainDescriptionVar = '';
  String mainCode = '';
  String itemName = '';
  // String warehouseId = '';
  String totalLine = '0';
  double taxRate = 1;
  double taxValue = 0;

  final focus = FocusNode();
  final focus1 = FocusNode();
  final dropFocus = FocusNode(); //dropdown
  final quantityFocus = FocusNode(); //quantity

  final _formKey = GlobalKey<FormState>();

  setPrice() {
    var result = exchangeRatesController.exchangeRatesList.firstWhere(
          (item) => item["currency"] == salesInvoiceController.selectedCurrencyName,
      orElse: () => null,
    );
    salesInvoiceController.exchangeRateForSelectedCurrency =
    result != null ? '${result["exchange_rate"]}' : '1';
    salesInvoiceController.unitPriceControllers[widget.index]!.text =
    '${widget.info['item_unit_price'] ?? ''}';
    selectedItemId = widget.info['item_id'].toString();



    salesInvoiceController.unitPriceControllers[widget.index]!.text =
    '${double.parse(salesInvoiceController.unitPriceControllers[widget.index]!.text) + taxValue}';
    salesInvoiceController
        .unitPriceControllers[widget.index]!
        .text = double.parse(
      salesInvoiceController.unitPriceControllers[widget.index]!.text,
    ).toStringAsFixed(2);

    salesInvoiceController.rowsInListViewInSalesInvoice[widget
        .index]['item_unit_price'] =
        salesInvoiceController.unitPriceControllers[widget.index]!.text;
    salesInvoiceController.rowsInListViewInSalesInvoice[widget
        .index]['itemName'] =
    salesInvoiceController.itemsNames[selectedItemId];
  }

  @override
  void initState() {
    if (widget.info['item_id']!='') {
      qtyController.text = '${widget.info['item_quantity'] ?? ''}';
      quantity = '${widget.info['item_quantity'] ?? '0.0'}';

      discountController.text = widget.info['item_discount'] ?? '';
      discount = widget.info['item_discount'] ?? '0.0';

      totalLine = widget.info['item_total'] ?? '';
      mainDescriptionVar = widget.info['item_description'] ?? '';
      mainCode = widget.info['item_main_code'] ?? '';
      descriptionController.text = widget.info['item_description'] ?? '';

      itemCodeController.text = widget.info['item_name'].toString();
      selectedItemId = widget.info['item_id'].toString();

      setPrice();
    } else {
      // discountController.text = '0';
      // discount = '0';
      // qtyController.text = '0';
      // quantity = '0';
      // salesInvoiceController.unitPriceControllers[widget.index]!.text = '0';
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
    }

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
                ReusableDropDownMenusWithSearch(
                  list:
                  salesInvoiceController
                      .itemsMultiPartList, // Assuming multiList is List<List<String>>
                  text: ''.tr,
                  hint: 'item_code'.tr,
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
                          cont.itemsPricesCurrencies[selectedItemId] == 'USD') {
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
                      totalLine =
                      '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                      cont.setEnteredQtyInSalesInvoice(widget.index, quantity);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      cont.getTotalItems();
                    });
                    cont.setEnteredUnitPriceInSalesInvoice(
                      widget.index,
                      cont.unitPriceControllers[widget.index]!.text,
                    );
                    cont.setItemIdInSalesInvoice(widget.index, selectedItemId);
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
                    // if (value == null || value.isEmpty) {
                    //   return 'select_option'.tr;
                    // }
                    // return null;
                  },
                  rowWidth: MediaQuery.of(context).size.width * 0.15,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.15,
                  clickableOptionText: 'create_virtual_item'.tr,
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
                  nextFocusNode: quantityFocus, // Set column widths
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: TextFormField(
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      // fontWeight: FontWeight.w500,
                    ),
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    controller: descriptionController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: "".tr,
                      // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
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
                  width: MediaQuery.of(context).size.width * 0.06,
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
                      hintText: "".tr,
                      // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
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
                        '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                      });

                      _formKey.currentState!.validate();

                      cont.setEnteredQtyInSalesInvoice(widget.index, val);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      cont.getTotalItems();
                    },
                  ),
                ),
                // unitPrice
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
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
                      // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
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

                      // if (value!.isEmpty) {
                      //   return 'unit Price is required';
                      // }
                      // return null;
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
                        '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                      });
                      _formKey.currentState!.validate();
                      // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                      cont.setEnteredUnitPriceInSalesInvoice(widget.index, val);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      cont.getTotalItems();
                    },
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
                salesInvoiceController.incrementListViewLengthInSalesInvoice(
                salesInvoiceController.increment,
                );
                salesInvoiceController
                    .addToRowsInListViewInSalesInvoice(salesInvoiceController.salesInvoiceCounter, {
                'line_type_id': '2',
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
                });
                salesInvoiceController.addToUnitPriceControllers(salesInvoiceController.salesInvoiceCounter);

                },
                    controller: discountController,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "".tr,
                      // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
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

                      // if (value!.isEmpty) {
                      //   return 'unit Price is required';
                      // }
                      // return null;
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
                          discountController.text = '0';
                          discount = '0';
                        } else {
                          discount = val;
                        }
                        totalLine =
                        '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                      });
                      _formKey.currentState!.validate();

                      // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                      cont.setEnteredDiscInSalesInvoice(widget.index, val);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      cont.getTotalItems();
                    },
                  ),
                ),

                //total
                ReusableShowInfoCard(
                  // text: double.parse(totalLine).toStringAsFixed(2),
                  // text: '${double.parse(totalLine).toStringAsFixed(2)}',
                  text: formatDoubleWithCommas(
                    double.parse(
                      cont.rowsInListViewInSalesInvoice[widget
                          .index]['item_total'],
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.07,
                ),

                //more
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
                                (BuildContext context) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(9),
                                ),
                              ),
                              elevation: 0,
                              content: ShowItemQuantitiesDialog(
                                selectedItemId: selectedItemId,
                              ),
                            ),
                          );
                        },
                        child: Text('Show Quantity'),
                      ),
                    ],
                  ),
                ),

                //delete
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.03,
                  child: InkWell(
                    onTap: () {
                      salesInvoiceController
                          .decrementListViewLengthInSalesInvoice(
                        salesInvoiceController.increment,
                      );
                      salesInvoiceController
                          .removeFromRowsInListViewInSalesInvoice(widget.index);


                      setState(() {
                        cont.totalItems = 0.0;
                        cont.globalDisc = "0.0";
                        cont.globalDiscountPercentageValue = "0.0";
                        cont.specialDisc = "0.0";
                        cont.specialDiscountPercentageValue = "0.0";
                        cont.vat11 = "0.0";
                        cont.vatInPrimaryCurrency = "0.0";
                        cont.totalSalesInvoice = "0.0";

                        cont.getTotalItems();
                      });
                      if (cont.rowsInListViewInSalesInvoice != {}) {
                        cont.getTotalItems();
                      }
                    },
                    child: Icon(Icons.delete_outline, color: Primary.primary),
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

class ReusableTitleRow extends StatefulWidget {
  const ReusableTitleRow({super.key, required this.index, required this.info});

  final int index;
  final Map info;
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
    // titleController.text = widget.info['title'] ?? '';
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.73,
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
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                  child: ReusableMore(
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
                      salesInvoiceController
                          .decrementListViewLengthInSalesInvoice(
                        salesInvoiceController.increment,
                      );
                      salesInvoiceController
                          .removeFromRowsInListViewInSalesInvoice(widget.index);
                    },
                    child: Icon(Icons.delete_outline, color: Primary.primary),
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

class ReusableNoteRow extends StatefulWidget {
  const ReusableNoteRow({super.key, required this.index, required this.info});
  final int index;
  final Map info;
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
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //note
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.73,
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
            ),

            //more
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
            ), //delete
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
                        .removeFromRowsInListViewInSalesInvoice(widget.index);
                  });
                },
                child: Icon(Icons.delete_outline, color: Primary.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReusableImageRow extends StatefulWidget {
  const ReusableImageRow({super.key, required this.index, required this.info});
  final int index;
  final Map info;
  @override
  State<ReusableImageRow> createState() => _ReusableImageRowState();
}

class _ReusableImageRowState extends State<ReusableImageRow> {
  final SalesInvoiceController salesInvoiceController = Get.find();
  late Uint8List imageFile;
  bool isLoading = false; // Add loading state
  double listViewLength = Sizes.deviceHeight * 0.08;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    imageFile = Uint8List(0);
    _loadImage();
    super.initState();
  }

  Future<void> _loadImage() async {
    setState(() {
      isLoading = true;
    });

    if (widget.info['image'] != null && widget.info['image'].isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse('$baseImage${widget.info['image']}'),
        );

        if (response.statusCode == 200) {
          imageFile = response.bodyBytes;
        } else {
          imageFile = Uint8List(0); // Set to empty if loading fails
        }
      } catch (e) {
        imageFile = Uint8List(0); // Set to empty if loading fails
      }
    } else {
      imageFile = Uint8List(0); // Set to empty if no image URL
    }
    salesInvoiceController.setImageInSalesInvoice(widget.index, imageFile);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesInvoiceController>(
      builder: (cont) {
        return Container(
          height: 100,
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //image
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
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.72,
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
                          ),
                        ),
                      ),
                    );
                  },
                ),

                //more
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
        );
      },
    );
  }
}

class ReusableComboRow extends StatefulWidget {
  const ReusableComboRow({super.key, required this.index, required this.info});
  final int index;
  final Map info;
  @override
  State<ReusableComboRow> createState() => _ReusableComboRowState();
}

class _ReusableComboRowState extends State<ReusableComboRow> {
  String discount = '0', result = '0', quantity = '0';
  String qty = '0';

  TextEditingController comboCodeController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final SalesInvoiceController salesInvoiceController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();

  String selectedComboId = '';
  String mainDescriptionVar = '';
  String mainCode = '';
  String comboName = '';
  String totalLine = '0';
  double taxRate = 1;
  double taxValue = 0;

  final focus = FocusNode();
  final focus1 = FocusNode();
  final dropFocus = FocusNode(); //dropdown
  final quantityFocus = FocusNode(); //quantity

  final _formKey = GlobalKey<FormState>();

  setPrice() {
    var result = exchangeRatesController.exchangeRatesList.firstWhere(
          (item) => item["currency"] == salesInvoiceController.selectedCurrencyName,
      orElse: () => null,
    );

    salesInvoiceController.exchangeRateForSelectedCurrency =
    result != null ? '${result["exchange_rate"]}' : '1';

    salesInvoiceController.combosPriceControllers[widget.index]!.text =
    '${widget.info['combo_unit_price'] ?? ''}';

    selectedComboId = widget.info['combo_id'].toString();
    // var ind=salesInvoiceController.combosIdsList.indexOf(selectedComboId);

    // if (salesInvoiceController.combosPricesCurrencies[selectedComboId] ==
    //     salesInvoiceController.selectedCurrencyName) {
    //
    //   salesInvoiceController.combosPriceControllers[widget.index]!.text =
    //       salesInvoiceController.combosPricesList[ind].toString();
    //
    // } else if (salesInvoiceController.selectedCurrencyName == 'USD' &&
    //     salesInvoiceController.combosPricesCurrencies[selectedComboId] !=
    //         salesInvoiceController.selectedCurrencyName) {
    //
    //   var result = exchangeRatesController.exchangeRatesList.firstWhere(
    //         (item) =>
    //     item["currency"] ==
    //         salesInvoiceController.combosPricesCurrencies[selectedComboId],
    //     orElse: () => null,
    //   );
    //   var divider = '1';
    //   if (result != null) {
    //     divider = result["exchange_rate"].toString();
    //   }
    //   salesInvoiceController.combosPriceControllers[widget.index]!.text =
    //   '${double.parse('${(double.parse(salesInvoiceController.combosPricesList[ind].toString()) / double.parse(divider))}')}';
    //
    // } else if (salesInvoiceController.selectedCurrencyName != 'USD' &&
    //     salesInvoiceController.combosPricesCurrencies[selectedComboId] == 'USD') {
    //
    //   salesInvoiceController.combosPriceControllers[widget.index]!.text =
    //   '${double.parse('${(double.parse(salesInvoiceController.combosPricesList[ind].toString()) * double.parse(salesInvoiceController.exchangeRateForSelectedCurrency))}')}';
    //
    // } else {
    //
    //   var result = exchangeRatesController.exchangeRatesList.firstWhere(
    //         (item) =>
    //     item["currency"] ==
    //         salesInvoiceController.combosPricesCurrencies[selectedComboId],
    //     orElse: () => null,
    //   );
    //   var divider = '1';
    //   if (result != null) {
    //     divider = result["exchange_rate"].toString();
    //   }
    //   var usdPrice =
    //       '${double.parse('${(double.parse(salesInvoiceController.combosPricesList[ind].toString()) / double.parse(divider))}')}';
    //   salesInvoiceController.combosPriceControllers[widget.index]!.text =
    //   '${double.parse('${(double.parse(usdPrice) * double.parse(salesInvoiceController.exchangeRateForSelectedCurrency))}')}';
    //
    // }

    // salesInvoiceController.combosPriceControllers[widget.index]!.text =
    // '${double.parse(salesInvoiceController.combosPriceControllers[widget.index]!.text) + taxValue}';
    //
    // salesInvoiceController.combosPriceControllers[widget.index]!.text = double.parse(
    //   salesInvoiceController.combosPriceControllers[widget.index]!.text,
    // ).toStringAsFixed(2);

    // qtyController.text = '1';
    salesInvoiceController.rowsInListViewInSalesInvoice[widget
        .index]['item_unit_price'] =
        salesInvoiceController.combosPriceControllers[widget.index]!.text;
    salesInvoiceController.rowsInListViewInSalesInvoice[widget
        .index]['item_total'] =
    '${widget.info['combo_total']}';
    salesInvoiceController.rowsInListViewInSalesInvoice[widget.index]['combo'] =
        widget.info['combo_id'].toString();
  }

  @override
  void initState() {
    if (widget.info['combo_quantity']!=null) {
      qtyController.text = '${widget.info['combo_quantity'] ?? ''}';
      quantity = '${widget.info['combo_quantity'] ?? '0.0'}';
      salesInvoiceController.rowsInListViewInSalesInvoice[widget
          .index]['item_quantity'] =
      '${widget.info['combo_quantity'] ?? '0.0'}';

      discountController.text = widget.info['combo_discount'] ?? '';
      discount = widget.info['combo_discount'] ?? '0.0';
      salesInvoiceController.rowsInListViewInSalesInvoice[widget
          .index]['item_discount'] =
          widget.info['combo_discount'] ?? '0.0';

      totalLine = widget.info['combo_total'] ?? '';
      mainDescriptionVar = widget.info['combo_description'] ?? '';

      mainCode = widget.info['combo_code'] ?? '';
      descriptionController.text = widget.info['combo_description'] ?? '';

      salesInvoiceController.rowsInListViewInSalesInvoice[widget
          .index]['item_description'] =
          widget.info['combo_description'] ?? '';

      comboCodeController.text = widget.info['combo_code'].toString();
      selectedComboId = widget.info['combo_id'].toString();

      setPrice();
    } else {
      // discountController.text = '0';
      // discount = '0';
      // qtyController.text = '0';
      // quantity = '0';
      // salesInvoiceController.combosPriceControllers[widget.index]!.text = '0';
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
    }

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
                ReusableDropDownMenusWithSearch(
                  list:
                  salesInvoiceController
                      .combosMultiPartList, // Assuming multiList is List<List<String>>
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
                      mainDescriptionVar = cont.combosDescriptionList[ind];
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
                      totalLine =
                      '${(double.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                      cont.setEnteredQtyInSalesInvoice(widget.index, quantity);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      cont.getTotalItems();
                    });
                    cont.setEnteredUnitPriceInSalesInvoice(
                      widget.index,
                      cont.combosPriceControllers[widget.index]!.text,
                    );
                    cont.setComboInSalesInvoice(widget.index, selectedComboId);
                    cont.setItemNameInSalesInvoice(
                      widget.index,
                      comboName,
                      // value.split(" | ")[0],
                    ); // set only first element as name
                    cont.setMainCodeInSalesInvoice(widget.index, mainCode);
                    cont.setTypeInSalesInvoice(widget.index, '3');
                    cont.setMainDescriptionInSalesInvoice(
                      widget.index,
                      mainDescriptionVar,
                    );
                  },
                  validationFunc: (value) {
                    // if ((value == null || value.isEmpty)&& selectedComboId.isEmpty ) {
                    //   return 'select_option'.tr;
                    // }
                    return null;
                  },
                  rowWidth: MediaQuery.of(context).size.width * 0.15,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.15,
                  clickableOptionText: 'create_virtual_item'.tr,
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
                  nextFocusNode: quantityFocus, // Set column widths
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: TextFormField(
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      // fontWeight: FontWeight.w500,
                    ),
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    controller: descriptionController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: "".tr,
                      // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
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
                  width: MediaQuery.of(context).size.width * 0.06,
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
                      hintText: "".tr,
                      // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
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
                        '${(double.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                      });

                      _formKey.currentState!.validate();

                      cont.setEnteredQtyInSalesInvoice(widget.index, val);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      cont.getTotalItems();
                    },
                  ),
                ),
                // unitPrice
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
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
                      // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
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

                      // if (value!.isEmpty) {
                      //   return 'unit Price is required';
                      // }
                      // return null;
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
                          cont.combosPriceControllers[widget.index]!.text = '0';
                        } else {
                          // cont.combosPriceControllers[widget.index]!.text = val;
                        }
                        // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';
                        totalLine =
                        '${(double.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                      });
                      _formKey.currentState!.validate();
                      // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                      cont.setEnteredUnitPriceInSalesInvoice(widget.index, val);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      cont.getTotalItems();
                    },
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
                salesInvoiceController.incrementListViewLengthInSalesInvoice(
                salesInvoiceController.increment,
                );
                salesInvoiceController
                    .addToRowsInListViewInSalesInvoice(salesInvoiceController.salesInvoiceCounter, {
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
                });
                salesInvoiceController.addToCombosPricesControllers(salesInvoiceController.salesInvoiceCounter);

                },
                    controller: discountController,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "".tr,
                      // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
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

                      // if (value!.isEmpty) {
                      //   return 'unit Price is required';
                      // }
                      // return null;
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
                          discountController.text = '0';
                          discount = '0';
                        } else {
                          discount = val;
                        }
                        totalLine =
                        '${(double.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                      });
                      _formKey.currentState!.validate();

                      // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                      cont.setEnteredDiscInSalesInvoice(widget.index, val);
                      cont.setMainTotalInSalesInvoice(widget.index, totalLine);
                      cont.getTotalItems();
                    },
                  ),
                ),

                //total
                ReusableShowInfoCard(
                  // text: double.parse(totalLine).toStringAsFixed(2),
                  // text: '${double.parse(totalLine).toStringAsFixed(2)}',
                  text: formatDoubleWithCommas(
                    double.parse(
                      cont.rowsInListViewInSalesInvoice[widget
                          .index]['item_total'],
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.07,
                ),

                //more
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                  child: ReusableMore(
                    itemsList:
                    selectedComboId.isEmpty
                        ? []
                        : [
                      // PopupMenuItem<String>(
                      //   value: '1',
                      //   onTap: () async {
                      //     showDialog<String>(
                      //       context: context,
                      //       builder:
                      //           (BuildContext context) => AlertDialog(
                      //         backgroundColor: Colors.white,
                      //         shape: const RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(9),
                      //           ),
                      //         ),
                      //         elevation: 0,
                      //         content: ShowItemQuantitiesDialog(
                      //           selectedItemId: selectedComboId,
                      //         ),
                      //       ),
                      //     );
                      //   },
                      //   child: Text('Show Quantity'),
                      // ),
                    ],
                  ),
                ),

                //delete
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.03,
                  child: InkWell(
                    onTap: () {
                      salesInvoiceController
                          .decrementListViewLengthInSalesInvoice(
                        salesInvoiceController.increment,
                      );
                      salesInvoiceController
                          .removeFromRowsInListViewInSalesInvoice(widget.index);


                      setState(() {
                        cont.totalItems = 0.0;
                        cont.globalDisc = "0.0";
                        cont.globalDiscountPercentageValue = "0.0";
                        cont.specialDisc = "0.0";
                        cont.specialDiscountPercentageValue = "0.0";
                        cont.vat11 = "0.0";
                        cont.vatInPrimaryCurrency = "0.0";
                        cont.totalSalesInvoice = "0.0";

                        cont.getTotalItems();
                      });
                      if (cont.rowsInListViewInSalesInvoice != {}) {
                        cont.getTotalItems();
                      }
                    },
                    child: Icon(Icons.delete_outline, color: Primary.primary),
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
