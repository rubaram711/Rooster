import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/SalesOrderBackend/update_sales_order.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/pending_docs_review_controller.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Controllers/sales_order_controller.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/create_product_dialog.dart';
import 'package:rooster_app/Screens/client_order/create_new_sales_order.dart';
import 'package:rooster_app/Widgets/TransferWidgets/reusable_show_info_card.dart';
import 'package:rooster_app/Widgets/dialog_drop_menu.dart';
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

import '../Client/create_client_dialog.dart';

class UpdateSalesOrderDialog extends StatefulWidget {
  const UpdateSalesOrderDialog({
    super.key,
    required this.index,
    required this.info,
    required this.fromPage,
  });
  final int index;
  final Map info;
  final String fromPage;

  @override
  State<UpdateSalesOrderDialog> createState() => _UpdateSalesOrderDialogState();
}

class _UpdateSalesOrderDialogState extends State<UpdateSalesOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  String selectedSalesPerson = '';
  int selectedSalesPersonId = 0;
  List tabsList = ['order_lines', 'other_information'];
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

  String selectedCurrency = '';

  String selectedItemCode = '';
  String selectedCustomerIds = '';

  List<String> termsList = [];

  final HomeController homeController = Get.find();
  final SalesOrderController salesOrderController = Get.find();
  final PendingDocsReviewController pendingDocsController = Get.find();
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
    salesOrderController.selectedCurrencyId =
        widget.info['currency']['id'].toString();
    selectedCurrency = widget.info['currency']['name'] ?? '';
    currencyController.text = selectedCurrency;
    int index = exchangeRatesController.currenciesNamesList.indexOf(
      selectedCurrency,
    );
    salesOrderController.selectedCurrencyId =
        exchangeRatesController.currenciesIdsList[index];
    salesOrderController.selectedCurrencyName = selectedCurrency;
    var vat = await getCompanyVatFromPref();
    salesOrderController.setCompanyVat(double.parse(vat));
    var companyCurrency = await getCompanyPrimaryCurrencyFromPref();
    salesOrderController.setCompanyPrimaryCurrency(companyCurrency);
    var result = exchangeRatesController.exchangeRatesList.firstWhere(
      (item) => item["currency"] == companyCurrency,
      orElse: () => null,
    );
    salesOrderController.setLatestRate(
      double.parse(result != null ? '${result["exchange_rate"]}' : '1'),
    );
  }

  // var isVatZero = false;
  checkVatExempt() async {
    var companySubjectToVat = await getCompanySubjectToVatFromPref();
    if (companySubjectToVat == '1') {
      vatExemptController.clear();
      salesOrderController.setIsVatExempted(false, false, false);
      salesOrderController.setIsVatExemptCheckBoxShouldAppear(true);
    } else {
      salesOrderController.setIsVatExemptCheckBoxShouldAppear(false);
      salesOrderController.setIsVatExempted(false, false, true);
      salesOrderController.setIsVatExemptChecked(true);
    }
    if ('${widget.info['printedAsPercentage'] ?? ''}' == '1') {
      salesOrderController.isPrintedAs0 = true;
      vatExemptController.text = 'Printed as "vat 0 % = 0"';
    }
    if ('${widget.info['printedAsVatExempt']}' == '1') {
      salesOrderController.isPrintedAsVatExempt = true;
      vatExemptController.text = 'Printed as "vat exempted"';
    }
    if ('${widget.info['notPrinted'] ?? ''}' == '1') {
      salesOrderController.isVatNoPrinted = true;
      vatExemptController.text = 'No printed ';
    }
    salesOrderController.isVatExemptChecked =
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
    salesOrderController.status = widget.info['status'];
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
    checkVatExempt();
    getCurrency();
    salesOrderController.orderedKeys = [];
    salesOrderController.rowsInListViewInSalesOrder = {};
    salesOrderController.salesOrderCounter = 0;
    setProgressVar();

    if (widget.info['cashingMethod'] != null) {
      cashingMethodsController.text =
          '${widget.info['cashingMethod']['title'] ?? ''}';
      salesOrderController.selectedCashingMethodId =
          '${widget.info['cashingMethod']['id']}';
    }

    if (widget.info['pricelist'] != null) {
      priceListController.text = '${widget.info['pricelist']['code'] ?? ''}';
      salesOrderController.selectedPriceListId =
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
      salesOrderController.isBeforeVatPrices = true;
    }

    if ('${widget.info['vatInclusivePrices'] ?? ''}' == '1') {
      priceConditionController.text = 'Prices are vat inclusive';
      salesOrderController.isBeforeVatPrices = false;
    }

    searchController.text = widget.info['client']['name'] ?? '';
    selectedItem = widget.info['client']['name'] ?? '';
    codeController.text = widget.info['code'] ?? '';
    selectedItemCode = widget.info['code'] ?? '';
    selectedCustomerIds = widget.info['client']['id'].toString();
    refController.text = widget.info['reference'] ?? '';
    validityController.text = widget.info['validity'] ?? '';
    inputDateController.text = widget.info['inputDate'] ?? '';
    currencyController.text = widget.info['currency']['name'] ?? '';
    // oldTermsAndConditionsString =
    //     widget.info['termsAndConditions'] ?? '[{"insert":"\n"}]';
    // termsAndConditionsController.text =
    //     widget.info['termsAndConditions'] ?? '[{"insert":"\n"}]';
    if (widget.info['termsAndConditions'] == null ||
        '${widget.info['termsAndConditions']}' == 'null' ||
        '${widget.info['termsAndConditions']}' == '') {
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
    salesOrderController.globalDisc =
        widget.info['globalDiscountAmount'] ?? '0.0';
    salesOrderController.specialDisc =
        widget.info['specialDiscountAmount'] ?? '0.0';
    salesOrderController.totalItems = double.parse(
      '${widget.info['totalBeforeVat'] ?? '0.0'}',
    );
    // print('isVatZero $isVatZero');
    salesOrderController.vat11 =
        salesOrderController.isVatExemptChecked
            ? '0'
            : '${widget.info['vat'] ?? ''}';
    salesOrderController.vatInPrimaryCurrency =
        salesOrderController.isVatExemptChecked
            ? '0'
            : '${widget.info['vatLebanese'] ?? ''}';

    // quotationController.totalQuotation = '${widget.info['total'] ?? ''}';
    salesOrderController.totalSalesOrder = ((salesOrderController.totalItems -
                double.parse(salesOrderController.globalDisc) -
                double.parse(salesOrderController.specialDisc)) +
            double.parse(salesOrderController.vat11))
        .toStringAsFixed(2);
    salesOrderController.city[selectedCustomerIds] =
        widget.info['client']['city'] ?? '';
    salesOrderController.country[selectedCustomerIds] =
        widget.info['client']['country'] ?? '';
    salesOrderController.email[selectedCustomerIds] =
        widget.info['client']['email'] ?? '';
    salesOrderController.phoneNumber[selectedCustomerIds] =
        widget.info['client']['phoneNumber'] ?? '';
    salesOrderController.selectedSalesOrderData['orderLines'] =
        widget.info['orderLines'] ?? '';
    for (
      int i = 0;
      i < salesOrderController.selectedSalesOrderData['orderLines'].length;
      i++
    ) {
      salesOrderController.rowsInListViewInSalesOrder[i + 1] =
          salesOrderController.selectedSalesOrderData['orderLines'][i];
      salesOrderController.orderedKeys.add(i + 1);
      if (salesOrderController
              .selectedSalesOrderData['orderLines'][i]['line_type_id'] ==
          2) {
        salesOrderController.unitPriceControllers[i + 1] =
            TextEditingController();
      } else if (salesOrderController
              .selectedSalesOrderData['orderLines'][i]['line_type_id'] ==
          3) {
        salesOrderController.combosPriceControllers[i + 1] =
            TextEditingController();
      }
    }
    // var keys = salesOrderController.rowsInListViewInSalesOrder.keys.toList();
    //
    // for (int i = 0; i < widget.info['orderLines'].length; i++) {
    //   if (widget.info['orderLines'][i]['line_type_id'] == 2) {
    //     salesOrderController.unitPriceControllers[i + 1] =
    //         TextEditingController();
    //     Widget p = ReusableItemRow(
    //       index: i + 1,
    //       info: salesOrderController.rowsInListViewInSalesOrder[keys[i]],
    //     );
    //
    //     salesOrderController.orderLinesSalesOrderList['${i + 1}'] = p;
    //   } else if (widget.info['orderLines'][i]['line_type_id'] == 1) {
    //     Widget p = ReusableTitleRow(
    //       index: i + 1,
    //       info: salesOrderController.rowsInListViewInSalesOrder[keys[i]],
    //     );
    //     salesOrderController.orderLinesSalesOrderList['${i + 1}'] = p;
    //   } else if (widget.info['orderLines'][i]['line_type_id'] == 5) {
    //     Widget p = ReusableNoteRow(
    //       index: i + 1,
    //       info: salesOrderController.rowsInListViewInSalesOrder[keys[i]],
    //     );
    //     salesOrderController.orderLinesSalesOrderList['${i + 1}'] = p;
    //   } else if (widget.info['orderLines'][i]['line_type_id'] == 4) {
    //     Widget p = ReusableImageRow(
    //       index: i + 1,
    //       info: salesOrderController.rowsInListViewInSalesOrder[keys[i]],
    //     );
    //     salesOrderController.orderLinesSalesOrderList['${i + 1}'] = p;
    //   } else if (widget.info['orderLines'][i]['line_type_id'] == 3) {
    //     salesOrderController.combosPriceControllers[i + 1] =
    //         TextEditingController();
    //     Widget p = ReusableComboRow(
    //       index: i + 1,
    //       info: salesOrderController.rowsInListViewInSalesOrder[keys[i]],
    //     );
    //     salesOrderController.orderLinesSalesOrderList['${i + 1}'] = p;
    //   }
    // }

    salesOrderController.salesOrderCounter =
        salesOrderController.rowsInListViewInSalesOrder.length;
    salesOrderController.listViewLengthInSalesOrder =
        salesOrderController.rowsInListViewInSalesOrder.length * 60;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesOrderController>(
      builder: (salesOrderCont) {
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
                      PageTitle(text: 'update_sales_order'.tr),
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
                  gapH32,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          UnderTitleBtn(
                            text: 'send_by_email'.tr,
                            onTap: () async {
                              setState(() {
                                progressVar = 1;
                              });
                              salesOrderCont.setStatus('sent');

                              bool hasType1WithEmptyTitle = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '1' &&
                                        (map['title']?.isEmpty ?? true);
                                  });
                              bool hasType2WithEmptyId = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '2' &&
                                        (map['item_id']?.isEmpty ?? true);
                                  });
                              bool hasType3WithEmptyId = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '3' &&
                                        (map['combo']?.isEmpty ?? true);
                                  });
                              bool hasType4WithEmptyImage = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '4' &&
                                        (map['image'] == Uint8List(0) ||
                                            map['image']?.isEmpty);
                                  });
                              bool hasType5WithEmptyNote = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '5' &&
                                        (map['note']?.isEmpty ?? true);
                                  });
                              if (salesOrderController
                                  .rowsInListViewInSalesOrder
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
                                if (_formKey.currentState!.validate()) {
                                  _saveContent();

                                  var res = await updateSalesOrder(
                                    '${widget.info['id']}',

                                    refController.text,
                                    selectedCustomerIds,
                                    validityController.text,
                                    inputDateController.text,
                                    '', //todo paymentTermsController.text,
                                    salesOrderCont.selectedPriceListId,
                                    salesOrderCont
                                        .selectedCurrencyId, //selectedCurrency
                                    termsAndConditionsController.text,
                                    selectedSalesPersonId.toString(),
                                    '',
                                    salesOrderCont.selectedCashingMethodId,
                                    commissionController.text,
                                    totalCommissionController.text,
                                    salesOrderController.totalItems
                                        .toString(), //total before vat
                                    specialDiscPercentController
                                        .text, // inserted by user
                                    salesOrderController
                                        .specialDisc, // calculated
                                    globalDiscPercentController.text,
                                    salesOrderController.globalDisc,
                                    salesOrderController.vat11.toString(), //vat
                                    salesOrderController.vatInPrimaryCurrency
                                        .toString(),
                                    salesOrderController
                                        .totalSalesOrder, // quotationController.totalQuotation

                                    salesOrderCont.isVatExemptChecked
                                        ? '1'
                                        : '0',
                                    salesOrderCont.isVatNoPrinted ? '1' : '0',
                                    salesOrderCont.isPrintedAsVatExempt
                                        ? '1'
                                        : '0',
                                    salesOrderCont.isPrintedAs0 ? '1' : '0',
                                    salesOrderCont.isBeforeVatPrices
                                        ? '0'
                                        : '1',

                                    salesOrderCont.isBeforeVatPrices
                                        ? '1'
                                        : '0',
                                    codeController.text,
                                    salesOrderCont.status, // status,
                                    salesOrderController
                                        .rowsInListViewInSalesOrder,
                                    salesOrderController.orderedKeys,
                                  );
                                  if (res['success'] == true) {
                                    Get.back();
                                    salesOrderController
                                        .getAllSalesOrderFromBackWithoutExcept();
                                    homeController.selectedTab.value =
                                        'to_invoice';
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
                              }
                            },
                          ),
                          UnderTitleBtn(
                            text: 'confirm'.tr,
                            onTap: ()
                            // {
                            //     setState(() {
                            //       progressVar = 2;
                            //     });
                            //     quotationCont.setStatus('confirmed');
                            //
                            // },
                            async {
                              setState(() {
                                progressVar = 2;
                              });
                              salesOrderCont.setStatus('confirmed');
                              bool hasType1WithEmptyTitle = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '1' &&
                                        (map['title']?.isEmpty ?? true);
                                  });
                              bool hasType2WithEmptyId = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '2' &&
                                        (map['item_id']?.isEmpty ?? true);
                                  });
                              bool hasType3WithEmptyId = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '3' &&
                                        (map['combo']?.isEmpty ?? true);
                                  });
                              bool hasType4WithEmptyImage = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '4' &&
                                        (map['image'] == Uint8List(0) ||
                                            map['image']?.isEmpty);
                                  });
                              bool hasType5WithEmptyNote = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '5' &&
                                        (map['note']?.isEmpty ?? true);
                                  });
                              if (salesOrderController
                                  .rowsInListViewInSalesOrder
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
                                if (_formKey.currentState!.validate()) {
                                  _saveContent();
                                  var res = await updateSalesOrder(
                                    '${widget.info['id']}',

                                    refController.text,
                                    selectedCustomerIds,
                                    validityController.text,
                                    inputDateController.text,
                                    '', //todo paymentTermsController.text,
                                    salesOrderCont.selectedPriceListId,
                                    salesOrderCont
                                        .selectedCurrencyId, //selectedCurrency
                                    termsAndConditionsController.text,
                                    selectedSalesPersonId.toString(),
                                    '',
                                    salesOrderCont.selectedCashingMethodId,
                                    commissionController.text,
                                    totalCommissionController.text,
                                    salesOrderController.totalItems
                                        .toString(), //total before vat
                                    specialDiscPercentController
                                        .text, // inserted by user
                                    salesOrderController
                                        .specialDisc, // calculated
                                    globalDiscPercentController.text,
                                    salesOrderController.globalDisc,
                                    salesOrderController.vat11.toString(), //vat
                                    salesOrderController.vatInPrimaryCurrency
                                        .toString(),
                                    salesOrderController
                                        .totalSalesOrder, // quotationController.totalQuotation

                                    salesOrderCont.isVatExemptChecked
                                        ? '1'
                                        : '0',
                                    salesOrderCont.isVatNoPrinted ? '1' : '0',
                                    salesOrderCont.isPrintedAsVatExempt
                                        ? '1'
                                        : '0',
                                    salesOrderCont.isPrintedAs0 ? '1' : '0',
                                    salesOrderCont.isBeforeVatPrices
                                        ? '0'
                                        : '1',

                                    salesOrderCont.isBeforeVatPrices
                                        ? '1'
                                        : '0',
                                    codeController.text,
                                    salesOrderCont.status, // status,
                                    salesOrderController
                                        .rowsInListViewInSalesOrder,
                                    salesOrderController.orderedKeys,
                                  );
                                  if (res['success'] == true) {
                                    Get.back();
                                    salesOrderController
                                        .getAllSalesOrderFromBackWithoutExcept();
                                    homeController.selectedTab.value =
                                        'to_deliver';
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
                              }
                            },
                          ),
                          UnderTitleBtn(
                            text: 'cancel'.tr,
                            onTap: ()
                            // {
                            //   setState(() {
                            //     progressVar = 0;
                            //   });
                            //   quotationCont.setStatus('cancelled');
                            // },
                            async {
                              salesOrderCont.setStatus('cancelled');
                              bool hasType1WithEmptyTitle = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '1' &&
                                        (map['title']?.isEmpty ?? true);
                                  });
                              bool hasType2WithEmptyId = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '2' &&
                                        (map['item_id']?.isEmpty ?? true);
                                  });
                              bool hasType3WithEmptyId = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '3' &&
                                        (map['combo']?.isEmpty ?? true);
                                  });
                              bool hasType4WithEmptyImage = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '4' &&
                                        (map['image'] == Uint8List(0) ||
                                            map['image']?.isEmpty);
                                  });
                              bool hasType5WithEmptyNote = salesOrderController
                                  .rowsInListViewInSalesOrder
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '5' &&
                                        (map['note']?.isEmpty ?? true);
                                  });
                              if (salesOrderController
                                  .rowsInListViewInSalesOrder
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
                                if (_formKey.currentState!.validate()) {
                                  _saveContent();
                                  var res = await updateSalesOrder(
                                    '${widget.info['id']}',

                                    refController.text,
                                    selectedCustomerIds,
                                    validityController.text,
                                    inputDateController.text,
                                    '', //todo paymentTermsController.text,
                                    salesOrderCont.selectedPriceListId,
                                    salesOrderCont
                                        .selectedCurrencyId, //selectedCurrency
                                    termsAndConditionsController.text,
                                    selectedSalesPersonId.toString(),
                                    '',
                                    salesOrderCont.selectedCashingMethodId,
                                    commissionController.text,
                                    totalCommissionController.text,
                                    salesOrderController.totalItems
                                        .toString(), //total before vat
                                    specialDiscPercentController
                                        .text, // inserted by user
                                    salesOrderController
                                        .specialDisc, // calculated
                                    globalDiscPercentController.text,
                                    salesOrderController.globalDisc,
                                    salesOrderController.vat11.toString(), //vat
                                    salesOrderController.vatInPrimaryCurrency
                                        .toString(),
                                    salesOrderController
                                        .totalSalesOrder, // quotationController.totalQuotation

                                    salesOrderCont.isVatExemptChecked
                                        ? '1'
                                        : '0',
                                    salesOrderCont.isVatNoPrinted ? '1' : '0',
                                    salesOrderCont.isPrintedAsVatExempt
                                        ? '1'
                                        : '0',
                                    salesOrderCont.isPrintedAs0 ? '1' : '0',
                                    salesOrderCont.isBeforeVatPrices
                                        ? '0'
                                        : '1',

                                    salesOrderCont.isBeforeVatPrices
                                        ? '1'
                                        : '0',
                                    codeController.text,
                                    salesOrderCont.status, // status,
                                    salesOrderController
                                        .rowsInListViewInSalesOrder,
                                    salesOrderController.orderedKeys,
                                  );
                                  if (res['success'] == true) {
                                    Get.back();
                                    salesOrderController
                                        .getAllSalesOrderFromBackWithoutExcept();
                                    homeController.selectedTab.value =
                                        'sales_order_summary';
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
                            text: 'processing'.tr,
                          ),
                          ReusableTimeLineTile(
                            id: 1,
                            progressVar: progressVar,
                            isFirst: false,
                            isLast: false,
                            isPast: false,
                            text: 'sales_order_sent'.tr,
                          ),
                          ReusableTimeLineTile(
                            id: 2,
                            progressVar: progressVar,
                            isFirst: false,
                            isLast: true,
                            isPast: false,
                            text: 'confirmed'.tr,
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
                                  '${widget.info['salesOrderNumber'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 20,
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
                              width: MediaQuery.of(context).size.width * 0.11,
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
                                            0.07,
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
                                              width: 1,
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
                                            salesOrderCont.setSelectedCurrency(
                                              cont.currenciesIdsList[index],
                                              val,
                                            );
                                            var result = cont.exchangeRatesList
                                                .firstWhere(
                                                  (item) =>
                                                      item["currency"] == val,
                                                  orElse: () => null,
                                                );
                                            salesOrderCont
                                                .setExchangeRateForSelectedCurrency(
                                                  result != null
                                                      ? '${result["exchange_rate"]}'
                                                      : '1',
                                                );
                                          });
                                          var keys =
                                              salesOrderCont
                                                  .unitPriceControllers
                                                  .keys
                                                  .toList();
                                          for (
                                            int i = 0;
                                            i <
                                                salesOrderCont
                                                    .unitPriceControllers
                                                    .length;
                                            i++
                                          ) {
                                            var selectedItemId =
                                                '${salesOrderCont.rowsInListViewInSalesOrder[keys[i]]['item_id']}';
                                            if (selectedItemId != '') {
                                              if (salesOrderCont
                                                      .itemsPricesCurrencies[selectedItemId] ==
                                                  val) {
                                                salesOrderCont
                                                    .unitPriceControllers[keys[i]]!
                                                    .text = salesOrderCont
                                                        .itemUnitPrice[selectedItemId]
                                                        .toString();
                                              } else if (val == 'USD' &&
                                                  salesOrderCont
                                                          .itemsPricesCurrencies[selectedItemId] !=
                                                      val) {
                                                var result = exchangeRatesController
                                                    .exchangeRatesList
                                                    .firstWhere(
                                                      (item) =>
                                                          item["currency"] ==
                                                          salesOrderCont
                                                              .itemsPricesCurrencies[selectedItemId],
                                                      orElse: () => null,
                                                    );
                                                var divider = '1';
                                                if (result != null) {
                                                  divider =
                                                      result["exchange_rate"]
                                                          .toString();
                                                }
                                                salesOrderCont
                                                        .unitPriceControllers[keys[i]]!
                                                        .text =
                                                    '${double.parse('${(double.parse(salesOrderCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                              } else if (salesOrderCont
                                                          .selectedCurrencyName !=
                                                      'USD' &&
                                                  salesOrderCont
                                                          .itemsPricesCurrencies[selectedItemId] ==
                                                      'USD') {
                                                salesOrderCont
                                                        .unitPriceControllers[keys[i]]!
                                                        .text =
                                                    '${double.parse('${(double.parse(salesOrderCont.itemUnitPrice[selectedItemId].toString()) * double.parse(salesOrderCont.exchangeRateForSelectedCurrency))}')}';
                                              } else {
                                                var result = exchangeRatesController
                                                    .exchangeRatesList
                                                    .firstWhere(
                                                      (item) =>
                                                          item["currency"] ==
                                                          salesOrderCont
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
                                                    '${double.parse('${(double.parse(salesOrderCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                salesOrderCont
                                                        .unitPriceControllers[keys[i]]!
                                                        .text =
                                                    '${double.parse('${(double.parse(usdPrice) * double.parse(salesOrderCont.exchangeRateForSelectedCurrency))}')}';
                                              }
                                              if (!salesOrderCont
                                                  .isBeforeVatPrices) {
                                                var taxRate =
                                                    double.parse(
                                                      salesOrderCont
                                                          .itemsVats[selectedItemId],
                                                    ) /
                                                    100.0;
                                                var taxValue =
                                                    taxRate *
                                                    double.parse(
                                                      salesOrderCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text,
                                                    );

                                                salesOrderCont
                                                        .unitPriceControllers[keys[i]]!
                                                        .text =
                                                    '${double.parse(salesOrderCont.unitPriceControllers[keys[i]]!.text) + taxValue}';
                                              }
                                              salesOrderCont
                                                  .unitPriceControllers[keys[i]]!
                                                  .text = double.parse(
                                                salesOrderCont
                                                    .unitPriceControllers[keys[i]]!
                                                    .text,
                                              ).toStringAsFixed(2);
                                              var totalLine =
                                                  '${(double.parse(salesOrderCont.rowsInListViewInSalesOrder[keys[i]]['item_quantity']) * double.parse(salesOrderCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(salesOrderCont.rowsInListViewInSalesOrder[keys[i]]['item_discount']) / 100)}';
                                              salesOrderCont
                                                  .setEnteredUnitPriceInSalesOrder(
                                                    keys[i],
                                                    salesOrderCont
                                                        .unitPriceControllers[keys[i]]!
                                                        .text,
                                                  );
                                              salesOrderCont
                                                  .setMainTotalInSalesOrder(
                                                    keys[i],
                                                    totalLine,
                                                  );
                                              salesOrderCont.getTotalItems();
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
                              width: MediaQuery.of(context).size.width * 0.14,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('validity'.tr),
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
                              width: MediaQuery.of(context).size.width * 0.24,
                              // width: MediaQuery.of(context).size.width * 0.15,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Pricelist'.tr),
                                  DropdownMenu<String>(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.15,
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
                                    // menuStyle: ,
                                    menuHeight: 250,
                                    dropdownMenuEntries:
                                        salesOrderCont.priceListsCodes
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
                                      var index = salesOrderCont.priceListsCodes
                                          .indexOf(val!);
                                      salesOrderCont.setSelectedPriceListId(
                                        salesOrderCont.priceListsIds[index],
                                      );
                                      setState(() {
                                        salesOrderCont
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
                                        0.09,
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
                              width: MediaQuery.of(context).size.width * 0.39,
                              // width: MediaQuery.of(context).size.width * 0.37,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('code'.tr),
                                  Text('    '),
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
                                    menuHeight: 250,
                                    dropdownMenuEntries:
                                        salesOrderCont.customerNumberList
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
                                        indexNum = salesOrderCont
                                            .customerNumberList
                                            .indexOf(selectedItemCode);
                                        selectedCustomerIds =
                                            salesOrderCont
                                                .customerIdsList[indexNum];
                                        searchController.text =
                                            salesOrderCont
                                                .customerNameList[indexNum];
                                      });
                                      int index = salesOrderCont
                                          .customerNumberList
                                          .indexOf(val!);
                                      if (salesOrderCont
                                          .customersPricesListsIds[index]
                                          .isNotEmpty) {
                                        salesOrderCont.setSelectedPriceListId(
                                          '${salesOrderCont.customersPricesListsIds[index]}',
                                        );

                                        priceListController.text =
                                            salesOrderCont
                                                .priceListsNames[salesOrderCont
                                                .priceListsIds
                                                .indexOf(
                                                  '${salesOrderCont.customersPricesListsIds[index]}',
                                                )];
                                        setState(() {
                                          salesOrderCont
                                              .resetItemsAfterChangePriceList();
                                        });
                                      }
                                      if (salesOrderCont
                                          .customersSalesPersonsIds[index]
                                          .isNotEmpty) {
                                        setState(() {
                                          selectedSalesPersonId = int.parse(
                                            '${salesOrderCont.customersSalesPersonsIds[index]}',
                                          );
                                          selectedSalesPerson =
                                              salesOrderCont
                                                  .salesPersonListNames[salesOrderCont
                                                  .salesPersonListId
                                                  .indexOf(
                                                    selectedSalesPersonId,
                                                  )];

                                          salesPersonController.text =
                                              selectedSalesPerson;
                                        });
                                      }
                                    },
                                  ),
                                  ReusableDropDownMenuWithSearch(
                                    list: salesOrderCont.customerNameList,
                                    text: '',
                                    hint: '${'search'.tr}...',
                                    controller: searchController,
                                    onSelected: (String? val) {
                                      setState(() {
                                        selectedItem = val!;
                                        var index = salesOrderCont
                                            .customerNameList
                                            .indexOf(selectedItem);
                                        selectedCustomerIds =
                                            salesOrderCont
                                                .customerIdsList[index];
                                        codeController.text =
                                            salesOrderCont
                                                .customerNumberList[index];

                                        // codeController =
                                        //     quotationController.codeController;
                                      });
                                      var index = salesOrderCont
                                          .customerNameList
                                          .indexOf(val!);
                                      if (salesOrderCont
                                          .customersPricesListsIds[index]
                                          .isNotEmpty) {
                                        salesOrderCont.setSelectedPriceListId(
                                          '${salesOrderCont.customersPricesListsIds[index]}',
                                        );

                                        priceListController.text =
                                            salesOrderCont
                                                .priceListsNames[salesOrderCont
                                                .priceListsIds
                                                .indexOf(
                                                  '${salesOrderCont.customersPricesListsIds[index]}',
                                                )];
                                        setState(() {
                                          salesOrderCont
                                              .resetItemsAfterChangePriceList();
                                        });
                                      }
                                      if (salesOrderCont
                                          .customersSalesPersonsIds[index]
                                          .isNotEmpty) {
                                        setState(() {
                                          selectedSalesPersonId = int.parse(
                                            '${salesOrderCont.customersSalesPersonsIds[index]}',
                                          );
                                          selectedSalesPerson =
                                              salesOrderCont
                                                  .salesPersonListNames[salesOrderCont
                                                  .salesPersonListId
                                                  .indexOf(
                                                    selectedSalesPersonId,
                                                  )];

                                          salesPersonController.text =
                                              selectedSalesPerson;
                                        });
                                      }
                                    },
                                    validationFunc: (value) {},
                                    rowWidth:
                                        MediaQuery.of(context).size.width *
                                        0.23,
                                    // rowWidth:
                                    //     MediaQuery.of(context).size.width *
                                    //     0.15,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width *
                                        0.22,
                                    // textFieldWidth:
                                    //     MediaQuery.of(context).size.width *
                                    //     0.14,
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
                                        " ${salesOrderCont.street[selectedCustomerIds] ?? ''} ",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        salesOrderCont.floorAndBuilding[selectedCustomerIds] ==
                                                    '' ||
                                                salesOrderCont
                                                        .floorAndBuilding[selectedCustomerIds] ==
                                                    null
                                            ? ''
                                            : ',',
                                      ),
                                      Text(
                                        " ${salesOrderCont.floorAndBuilding[selectedCustomerIds] ?? ''}",
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
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      gapW10,
                                      Text(
                                        "${salesOrderCont.phoneNumber[selectedCustomerIds] ?? ''}",
                                        style: const TextStyle(fontSize: 12),
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
                                        salesOrderCont.isVatExemptChecked
                                            ? TextStyle(color: Others.divider)
                                            : TextStyle(),
                                  ),
                                  GetBuilder<ExchangeRatesController>(
                                    builder: (cont) {
                                      return DropdownMenu<String>(
                                        enabled:
                                            !salesOrderCont.isVatExemptChecked,
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.15,
                                        // requestFocusOnTap: false,
                                        enableSearch: true,
                                        controller: priceConditionController,
                                        hintText: '',

                                        textStyle: const TextStyle(
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
                                              width: 1,
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
                                              salesOrderCont
                                                  .setIsBeforeVatPrices(true);
                                            } else {
                                              salesOrderCont
                                                  .setIsBeforeVatPrices(false);
                                            }
                                            var keys =
                                                salesOrderCont
                                                    .unitPriceControllers
                                                    .keys
                                                    .toList();
                                            for (
                                              int i = 0;
                                              i <
                                                  salesOrderCont
                                                      .unitPriceControllers
                                                      .length;
                                              i++
                                            ) {
                                              var selectedItemId =
                                                  '${salesOrderCont.rowsInListViewInSalesOrder[keys[i]]['item_id']}';
                                              if (selectedItemId != '') {
                                                if (salesOrderCont
                                                        .itemsPricesCurrencies[selectedItemId] ==
                                                    selectedCurrency) {
                                                  salesOrderCont
                                                      .unitPriceControllers[keys[i]]!
                                                      .text = salesOrderCont
                                                          .itemUnitPrice[selectedItemId]
                                                          .toString();
                                                } else if (salesOrderCont
                                                            .selectedCurrencyName ==
                                                        'USD' &&
                                                    salesOrderCont
                                                            .itemsPricesCurrencies[selectedItemId] !=
                                                        selectedCurrency) {
                                                  var result = exchangeRatesController
                                                      .exchangeRatesList
                                                      .firstWhere(
                                                        (item) =>
                                                            item["currency"] ==
                                                            salesOrderCont
                                                                .itemsPricesCurrencies[selectedItemId],
                                                        orElse: () => null,
                                                      );
                                                  var divider = '1';
                                                  if (result != null) {
                                                    divider =
                                                        result["exchange_rate"]
                                                            .toString();
                                                  }
                                                  salesOrderCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text =
                                                      '${double.parse('${(double.parse(salesOrderCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                } else if (salesOrderCont
                                                            .selectedCurrencyName !=
                                                        'USD' &&
                                                    salesOrderCont
                                                            .itemsPricesCurrencies[selectedItemId] ==
                                                        'USD') {
                                                  salesOrderCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text =
                                                      '${double.parse('${(double.parse(salesOrderCont.itemUnitPrice[selectedItemId].toString()) * double.parse(salesOrderCont.exchangeRateForSelectedCurrency))}')}';
                                                } else {
                                                  var result = exchangeRatesController
                                                      .exchangeRatesList
                                                      .firstWhere(
                                                        (item) =>
                                                            item["currency"] ==
                                                            salesOrderCont
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
                                                      '${double.parse('${(double.parse(salesOrderCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                  salesOrderCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text =
                                                      '${double.parse('${(double.parse(usdPrice) * double.parse(salesOrderCont.exchangeRateForSelectedCurrency))}')}';
                                                }
                                                if (!salesOrderCont
                                                    .isBeforeVatPrices) {
                                                  var taxRate =
                                                      double.parse(
                                                        salesOrderCont
                                                            .itemsVats[selectedItemId],
                                                      ) /
                                                      100.0;
                                                  var taxValue =
                                                      taxRate *
                                                      double.parse(
                                                        salesOrderCont
                                                            .unitPriceControllers[keys[i]]!
                                                            .text,
                                                      );

                                                  salesOrderCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text =
                                                      '${double.parse(salesOrderCont.unitPriceControllers[keys[i]]!.text) + taxValue}';
                                                }
                                                salesOrderCont
                                                    .unitPriceControllers[keys[i]]!
                                                    .text = double.parse(
                                                  salesOrderCont
                                                      .unitPriceControllers[keys[i]]!
                                                      .text,
                                                ).toStringAsFixed(2);
                                                var totalLine =
                                                    '${(double.parse(salesOrderCont.rowsInListViewInSalesOrder[keys[i]]['item_quantity']) * double.parse(salesOrderCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(salesOrderCont.rowsInListViewInSalesOrder[keys[i]]['item_discount']) / 100)}';

                                                salesOrderCont
                                                    .setEnteredUnitPriceInSalesOrder(
                                                      keys[i],
                                                      salesOrderCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text,
                                                    );
                                                salesOrderCont
                                                    .setMainTotalInSalesOrder(
                                                      keys[i],
                                                      totalLine,
                                                    );
                                                salesOrderCont.getTotalItems();
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
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'email'.tr,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      gapW10,
                                      GetBuilder<SalesOrderController>(
                                        builder: (cont) {
                                          return Text(
                                            "${cont.email[selectedCustomerIds] ?? ''}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  gapH6,
                                  salesOrderCont.isVatExemptCheckBoxShouldAppear
                                      ? Row(
                                        children: [
                                          Text(
                                            'vat'.tr,
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
                            gapW16,
                            //vat exempt
                            salesOrderCont.isVatExemptCheckBoxShouldAppear
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
                                              fontSize: 12,
                                            ),
                                          ),
                                          leading: Checkbox(
                                            value:
                                                salesOrderCont
                                                    .isVatExemptChecked,
                                            onChanged: (bool? value) {
                                              salesOrderCont
                                                  .setIsVatExemptChecked(
                                                    value!,
                                                  );
                                              if (value) {
                                                priceConditionController.text =
                                                    'Prices are before vat';
                                                salesOrderCont
                                                    .setIsBeforeVatPrices(true);
                                                vatExemptController.text =
                                                    vatExemptList[0];
                                                salesOrderCont.setIsVatExempted(
                                                  true,
                                                  false,
                                                  false,
                                                );
                                              } else {
                                                vatExemptController.clear();
                                                salesOrderCont.setIsVatExempted(
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
                                      salesOrderCont.isVatExemptChecked == false
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
                                              fontSize: 12,
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
                                              fontSize: 12,
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
                                                  salesOrderCont
                                                      .setIsVatExempted(
                                                        true,
                                                        false,
                                                        false,
                                                      );
                                                } else if (val ==
                                                    'Printed as "vat 0 % = 0"') {
                                                  salesOrderCont
                                                      .setIsVatExempted(
                                                        false,
                                                        true,
                                                        false,
                                                      );
                                                } else {
                                                  salesOrderCont
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
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: Primary.primary,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(6),
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
                                      MediaQuery.of(context).size.width * 0.10,
                                ),
                                TableTitle(
                                  text: 'description'.tr,
                                  width:
                                      MediaQuery.of(context).size.width * 0.23,
                                ),
                                TableTitle(
                                  text: 'quantity'.tr,
                                  width:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                TableTitle(
                                  text: 'warehouse'.tr,
                                  width:
                                      MediaQuery.of(context).size.width * 0.10,
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
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                TableTitle(
                                  text: 'more_options'.tr,
                                  width:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.01,
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
                                      salesOrderCont
                                          .listViewLengthInSalesOrder +
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
                                          salesOrderCont
                                              .rowsInListViewInSalesOrder
                                              .keys
                                              .length,
                                      buildDefaultDragHandles: false,
                                      itemBuilder: (context, index) {
                                        final key =
                                            salesOrderCont.orderedKeys[index];
                                        final row =
                                            salesOrderCont
                                                .rowsInListViewInSalesOrder[key]!;
                                        final lineType =
                                            '${row['line_type_id'] ?? ''}';
                                        return SizedBox(
                                          key: ValueKey(key),
                                          // onDismissed: (direction) {
                                          //   setState(() {
                                          //     salesOrderCont
                                          //         .decrementListViewLengthInSalesOrder(
                                          //           salesOrderCont.increment,
                                          //         );
                                          //     salesOrderCont
                                          //         .removeFromRowsInListViewInSalesOrder(
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
                                          final movedKey = salesOrderCont
                                              .orderedKeys
                                              .removeAt(oldIndex);
                                          salesOrderCont.orderedKeys.insert(
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
                      : Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04,
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
                                        salesOrderController
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
                                        var index = salesOrderController
                                            .salesPersonListNames
                                            .indexOf(val);
                                        selectedSalesPersonId =
                                            salesOrderController
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
                                        salesOrderCont.cashingMethodsNamesList,
                                    text: 'cashing_method'.tr,
                                    hint: '',
                                    rowWidth:
                                        MediaQuery.of(context).size.width * 0.3,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width *
                                        0.15,
                                    onSelected: (value) {
                                      var index = salesOrderCont
                                          .cashingMethodsNamesList
                                          .indexOf(value);
                                      salesOrderCont.setSelectedCashingMethodId(
                                        salesOrderCont
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
                      vertical: 20,
                      horizontal: 40,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'terms_conditions'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            color: TypographyColor.titleTable,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        gapH16,
                        SizedBox(
                          height: 300,
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

                                    // readOnly: false,
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

                  GetBuilder<SalesOrderController>(
                    builder: (cont) {
                      return Container(
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
                                                //     quotationController
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
                                  salesOrderCont.isVatExemptCheckBoxShouldAppear
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
                                        '${salesOrderCont.selectedCurrencyName} ${formatDoubleWithCommas(double.parse(salesOrderCont.totalSalesOrder))}',
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
                      // TextButton(
                      //   onPressed: () {
                      //     setState(() {
                      //       isVatExemptChecked =
                      //           '${widget.info['vatExempt'] ?? ''}' == '1'
                      //               ? true
                      //               : false;
                      //       isBeforeVatPrices =
                      //           '${widget.info['beforeVatPrices'] ?? ''}' == '1'
                      //               ? true
                      //               : false;
                      //       isVatInclusivePrices =
                      //           '${widget.info['vatInclusivePrices'] ?? ''}' ==
                      //                   '1'
                      //               ? true
                      //               : false;
                      //       isPrintedAsVatExempt =
                      //           '${widget.info['printedAsVatExempt'] ?? ''}' ==
                      //                   '1'
                      //               ? true
                      //               : false;
                      //       isPrintedAsPercentage =
                      //           '${widget.info['printedAsPercentage'] ?? ''}' ==
                      //                   '1'
                      //               ? true
                      //               : false;
                      //       isVatNoPrinted =
                      //           '${widget.info['notPrinted'] ?? ''}' == '1'
                      //               ? true
                      //               : false;
                      //
                      //       searchController.text =
                      //           widget.info['client']['name'] ?? '';
                      //       codeController.text = widget.info['code'] ?? '';
                      //       selectedItemCode = widget.info['code'] ?? '';
                      //       refController.text = widget.info['reference'];
                      //       validityController.text =
                      //           widget.info['validity'] ?? '';
                      //       currencyController.text =
                      //           widget.info['currency']['name'] ?? '';
                      //       termsAndConditionsController.text =
                      //           widget.info['termsAndConditions'] ?? '';
                      //       globalDiscPercentController.text =
                      //           widget.info['globalDiscount'] ??
                      //           ''; // entered by user
                      //       specialDiscPercentController.text =
                      //           widget.info['specialDiscount'] ??
                      //           ''; //entered by user
                      //       quotationController.globalDisc =
                      //           widget.info['globalDiscountAmount'] ?? '';
                      //       quotationController.specialDisc =
                      //           widget.info['specialDiscountAmount'] ?? '';
                      //
                      //       quotationController.totalItems = double.parse(
                      //         '${widget.info['totalBeforeVat']}',
                      //       );
                      //       quotationController.vat11 = '${widget.info['vat']}';
                      //       quotationController.vatInPrimaryCurrency =
                      //           '${widget.info['vatLebanese']}';
                      //       quotationController.totalQuotation =
                      //           '${widget.info['total']}';
                      //
                      //       if ('${widget.info['vatExempt'] ?? ''}' == '0' &&
                      //           '${widget.info['beforeVatPrices'] ?? ''}' ==
                      //               '1') {
                      //         vatExemptController.text =
                      //             'prices are before vat';
                      //       }
                      //       if ('${widget.info['vatExempt'] ?? ''}' == '0' &&
                      //           '${widget.info['vatInclusivePrices'] ?? ''}' ==
                      //               '1') {
                      //         vatExemptController.text =
                      //             'prices are vat inclusive';
                      //       }
                      //       if ('${widget.info['vatExempt'] ?? ''}' == '1' &&
                      //           '${widget.info['printedAsPercentage'] ?? ''}' ==
                      //               '1') {
                      //         vatExemptController.text =
                      //             'exempted from vat ,printed as "vat 0 % = 0"';
                      //       }
                      //       if ('${widget.info['vatExempt'] ?? ''}' == '1' &&
                      //           '${widget.info['printedAsVatExempt'] ?? ''}' ==
                      //               '1') {
                      //         vatExemptController.text =
                      //             'exempted from vat ,printed as "vat exempted"';
                      //       }
                      //       if ('${widget.info['vatExempt'] ?? ''}' == '1' &&
                      //           '${widget.info['notPrinted'] ?? ''}' == '1') {
                      //         vatExemptController.text =
                      //             'exempted from vat , no printed ';
                      //       }
                      //
                      //       quotationController.city[selectedCustomerIds] =
                      //           widget.info['client']['city'] ?? '';
                      //       quotationController.country[selectedCustomerIds] =
                      //           widget.info['client']['country'] ?? '';
                      //       quotationController.email[selectedCustomerIds] =
                      //           widget.info['client']['email'] ?? '';
                      //       quotationController
                      //               .phoneNumber[selectedCustomerIds] =
                      //           widget.info['client']['phoneNumber'] ?? '';
                      //     });
                      //   },
                      //   child: Text(
                      //     'discard'.tr,
                      //     style: TextStyle(
                      //       decoration: TextDecoration.underline,
                      //       color: Primary.primary,
                      //     ),
                      //   ),
                      // ),
                      // gapW24,
                      ReusableButtonWithColor(
                        btnText: 'save'.tr,
                        onTapFunction: () async {
                          bool hasType1WithEmptyTitle = salesOrderController
                              .rowsInListViewInSalesOrder
                              .values
                              .any((map) {
                                return map['line_type_id'] == '1' &&
                                    (map['title']?.isEmpty ?? true);
                              });
                          bool hasType2WithEmptyId = salesOrderController
                              .rowsInListViewInSalesOrder
                              .values
                              .any((map) {
                                return map['line_type_id'] == '2' &&
                                    (map['item_id']?.isEmpty ?? true);
                              });
                          bool hasType3WithEmptyId = salesOrderController
                              .rowsInListViewInSalesOrder
                              .values
                              .any((map) {
                                return map['line_type_id'] == '3' &&
                                    (map['combo']?.isEmpty ?? true);
                              });
                          bool hasType4WithEmptyImage = salesOrderController
                              .rowsInListViewInSalesOrder
                              .values
                              .any((map) {
                                return map['line_type_id'] == '4' &&
                                    (map['image'] == Uint8List(0) ||
                                        map['image']?.isEmpty);
                              });
                          bool hasType5WithEmptyNote = salesOrderController
                              .rowsInListViewInSalesOrder
                              .values
                              .any((map) {
                                return map['line_type_id'] == '5' &&
                                    (map['note']?.isEmpty ?? true);
                              });
                          if (salesOrderController
                              .rowsInListViewInSalesOrder
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
                            if (_formKey.currentState!.validate()) {
                              _saveContent();
                              var res = await updateSalesOrder(
                                '${widget.info['id']}',
                                refController.text,
                                selectedCustomerIds,
                                validityController.text,
                                inputDateController.text,
                                '', //todo paymentTermsController.text,
                                salesOrderCont.selectedPriceListId,
                                salesOrderCont
                                    .selectedCurrencyId, //selectedCurrency
                                termsAndConditionsController.text,
                                selectedSalesPersonId.toString(),
                                '',
                                salesOrderCont.selectedCashingMethodId,
                                commissionController.text,
                                totalCommissionController.text,
                                salesOrderController.totalItems
                                    .toString(), //total before vat
                                specialDiscPercentController
                                    .text, // inserted by user
                                salesOrderController.specialDisc, // calculated
                                globalDiscPercentController.text,
                                salesOrderController.globalDisc,
                                salesOrderController.vat11.toString(), //vat
                                salesOrderController.vatInPrimaryCurrency
                                    .toString(),
                                salesOrderController
                                    .totalSalesOrder, // quotationController.totalQuotation

                                salesOrderCont.isVatExemptChecked ? '1' : '0',
                                salesOrderCont.isVatNoPrinted ? '1' : '0',
                                salesOrderCont.isPrintedAsVatExempt ? '1' : '0',
                                salesOrderCont.isPrintedAs0 ? '1' : '0',
                                salesOrderCont.isBeforeVatPrices ? '0' : '1',

                                salesOrderCont.isBeforeVatPrices ? '1' : '0',
                                codeController.text,
                                salesOrderCont.status, // status,
                                salesOrderController.rowsInListViewInSalesOrder,
                                salesOrderController.orderedKeys,
                              );
                              if (res['success'] == true) {
                                Get.back();
                                if (widget.fromPage == 'pendingDocs') {
                                  pendingDocsController.getAllPendingDocs();
                                  homeController.selectedTab.value =
                                      'pending_docs';
                                } else {
                                  salesOrderController
                                      .getAllSalesOrderFromBackWithoutExcept();

                                  salesOrderCont.status == 'confirmed' ||
                                          salesOrderCont.status == 'cancelled'
                                      ? homeController.selectedTab.value =
                                          'sales_order_summary'
                                      : homeController.selectedTab.value =
                                          'to_invoice';
                                }
                                CommonWidgets.snackBar(
                                  'Success',
                                  res['message'],
                                );
                              } else {
                                CommonWidgets.snackBar('error', res['message']);
                              }
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
          width: name.length * 10, // MediaQuery.of(context).size.width * 0.09,
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
      salesOrderController.salesOrderCounter += 1;
    });
    salesOrderController.incrementListViewLengthInSalesOrder(
      salesOrderController.increment,
    );
    salesOrderController.addToRowsInListViewInSalesOrder(
      salesOrderController.salesOrderCounter,
      {
        'line_type_id': '1',
        'item_id': '',
        'itemName': '',
        'item_main_code': '',
        'item_discount': '0',
        'item_description': '',
        'item_quantity': '0',
        'item_warehouseId': '',
        'combo_warehouseId': '',
        'item_unit_price': '0',
        'item_total': '0',
        'title': '',
        'note': '',
      },
    );
  }
  // int salesOrderController.salesOrderCounter = 0;

  addNewItem() {
    setState(() {
      salesOrderController.salesOrderCounter += 1;
    });
    salesOrderController.incrementListViewLengthInSalesOrder(
      salesOrderController.increment,
    );
    salesOrderController.addToRowsInListViewInSalesOrder(
      salesOrderController.salesOrderCounter,
      {
        'line_type_id': '2',
        'item_id': '',
        'itemName': '',
        'item_main_code': '',
        'item_discount': '0',
        'item_description': '',
        'item_quantity': '1',
        'item_warehouseId': '',
        'combo_warehouseId': '',
        'item_unit_price': '0',
        'item_total': '0',
        'title': '',
        'note': '',
      },
    );
    salesOrderController.addToUnitPriceControllers(
      salesOrderController.salesOrderCounter,
    );
  }

  addNewCombo() {
    setState(() {
      salesOrderController.salesOrderCounter += 1;
    });
    salesOrderController.incrementListViewLengthInSalesOrder(
      salesOrderController.increment,
    );
    salesOrderController.addToRowsInListViewInSalesOrder(
      salesOrderController.salesOrderCounter,
      {
        'line_type_id': '3',
        'item_id': '',
        'itemName': '',
        'item_main_code': '',
        'item_discount': '0',
        'item_description': '',
        'item_quantity': '1',
        'item_warehouseId': '',
        'combo_warehouseId': '',
        'item_unit_price': '0',
        'item_total': '0',
        'title': '',
        'note': '',
        'combo': '',
      },
    );
    salesOrderController.addToCombosPricesControllers(
      salesOrderController.salesOrderCounter,
    );
  }

  addNewImage() {
    setState(() {
      salesOrderController.salesOrderCounter += 1;
    });
    salesOrderController.incrementListViewLengthInSalesOrder(
      salesOrderController.increment,
    );

    salesOrderController.addToRowsInListViewInSalesOrder(
      salesOrderController.salesOrderCounter,
      {
        'line_type_id': '4',
        'item_id': '',
        'itemName': '',
        'item_main_code': '',
        'item_discount': '0',
        'item_description': '',
        'item_quantity': '0',
        'item_warehouseId': '',
        'combo_warehouseId': '',
        'item_unit_price': '0',
        'item_total': '0',
        'title': '',
        'note': '',
        'image': Uint8List(0),
      },
    );
  }

  addNewNote() {
    setState(() {
      salesOrderController.salesOrderCounter += 1;
    });
    salesOrderController.incrementListViewLengthInSalesOrder(
      salesOrderController.increment,
    );

    salesOrderController.addToRowsInListViewInSalesOrder(
      salesOrderController.salesOrderCounter,
      {
        'line_type_id': '5',
        'item_id': '',
        'itemName': '',
        'item_main_code': '',
        'item_discount': '0',
        'item_description': '',
        'item_quantity': '0',
        'item_warehouseId': '',
        'combo_warehouseId': '',
        'item_unit_price': '0',
        'item_total': '0',
        'title': '',
        'note': '',
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
  TextEditingController warehouseNameController = TextEditingController();

  final ProductController productController = Get.find();
  final SalesOrderController salesOrderController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();

  String selectedItemId = '';
  String mainDescriptionVar = '';
  String mainCode = '';
  String itemName = '';
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
      (item) => item["currency"] == salesOrderController.selectedCurrencyName,
      orElse: () => null,
    );
    salesOrderController.exchangeRateForSelectedCurrency =
        result != null ? '${result["exchange_rate"]}' : '1';
    salesOrderController.unitPriceControllers[widget.index]!.text =
        '${widget.info['item_unit_price'] ?? '1'}';
    selectedItemId = widget.info['item_id'].toString();
    salesOrderController.unitPriceControllers[widget.index]!.text =
        '${double.parse(salesOrderController.unitPriceControllers[widget.index]!.text) + taxValue}';
    salesOrderController
        .unitPriceControllers[widget.index]!
        .text = double.parse(
      salesOrderController.unitPriceControllers[widget.index]!.text,
    ).toStringAsFixed(2);

    salesOrderController.rowsInListViewInSalesOrder[widget
            .index]['item_unit_price'] =
        salesOrderController.unitPriceControllers[widget.index]!.text;
    salesOrderController.rowsInListViewInSalesOrder[widget.index]['itemName'] =
        salesOrderController.itemsNames[selectedItemId];
  }

  @override
  void initState() {
    if (widget.info['item_id'] != '') {
      qtyController.text = '${widget.info['item_quantity'] ?? '1'}';
      quantity = '${widget.info['item_quantity'] ?? '1'}';
      if (widget.info['item_warehouse_id'] == null) {
        warehouseNameController.text = "";
      } else {
        warehouseNameController.text =
            salesOrderController
                .warehousesNames['${widget.info['item_warehouse_id']}'];
      }

      discountController.text = widget.info['item_discount'] ?? '0.0';
      discount = widget.info['item_discount'] ?? '0.0';

      totalLine = widget.info['item_total'] ?? '0';
      mainDescriptionVar = widget.info['item_description'] ?? '';

      descriptionController.text = widget.info['item_description'] ?? '';

      itemCodeController.text = widget.info['item_main_code'].toString();
      selectedItemId = widget.info['item_id'].toString();

      setPrice();
    } else {
      // discountController.text = '0';
      // discount = '0';
      // qtyController.text = '0';
      // quantity = '0';
      // quotationController.unitPriceControllers[widget.index]!.text = '0';

      itemCodeController.text =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_main_code'];
      qtyController.text =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_quantity'];
      discountController.text =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_discount'];
      descriptionController.text =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_description'];
      totalLine =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_total'];
      itemCodeController.text =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_main_code'];
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesOrderController>(
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
                      salesOrderController
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
                      cont.setEnteredQtyInSalesOrder(widget.index, quantity);
                      cont.setMainTotalInSalesOrder(widget.index, totalLine);
                      cont.getTotalItems();
                    });
                    cont.setEnteredUnitPriceInSalesOrder(
                      widget.index,
                      cont.unitPriceControllers[widget.index]!.text,
                    );
                    cont.setItemIdInSalesOrder(widget.index, selectedItemId);
                    cont.setItemNameInSalesOrder(
                      widget.index,
                      itemName,
                      // value.split(" | ")[0],
                    ); // set only first element as name
                    cont.setMainCodeInSalesOrder(widget.index, mainCode);
                    cont.setTypeInSalesOrder(widget.index, '2');
                    cont.setMainDescriptionInSalesOrder(
                      widget.index,
                      mainDescriptionVar,
                    );
                  },
                  validationFunc: (value) {
                    // if (value == null || value.isEmpty) {
                    //   return 'select_option'.tr;
                    // }
                    // return null;
                  },
                  rowWidth: MediaQuery.of(context).size.width * 0.10,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.10,
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
                  width: MediaQuery.of(context).size.width * 0.20,
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
                      cont.setMainDescriptionInSalesOrder(
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

                      cont.setEnteredQtyInSalesOrder(widget.index, val);
                      cont.setMainTotalInSalesOrder(widget.index, totalLine);
                      cont.getTotalItems();
                    },
                  ),
                ),

                //warehouse
                DropdownMenu<String>(
                  width: MediaQuery.of(context).size.width * 0.10,
                  // requestFocusOnTap: false,
                  enableSearch: true,
                  controller: warehouseNameController,
                  hintText: 'deliver_warehouse'.tr,
                  inputDecorationTheme: InputDecorationTheme(
                    // filled: true,
                    hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                    contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                    // outlineBorder: BorderSide(color: Colors.black,),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                        width: 2,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                  // menuStyle: ,
                  menuHeight: 250,
                  dropdownMenuEntries:
                      cont.warehousesNameList.map<DropdownMenuEntry<String>>((
                        String option,
                      ) {
                        return DropdownMenuEntry<String>(
                          value: option,
                          label: option,
                        );
                      }).toList(),
                  enableFilter: true,
                  onSelected: (String? value) {
                    warehouseNameController.text = value!;

                    var index = cont.warehousesNameList.indexOf(value);
                    var val = '${cont.warehouseIds[index]}';
                    cont.setItemWareHouseInSalesOrder(widget.index, val);
                  },
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
                      cont.setEnteredUnitPriceInSalesOrder(widget.index, val);
                      cont.setMainTotalInSalesOrder(widget.index, totalLine);
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
                        salesOrderController.salesOrderCounter += 1;
                      });
                      salesOrderController.incrementListViewLengthInSalesOrder(
                        salesOrderController.increment,
                      );
                      salesOrderController.addToRowsInListViewInSalesOrder(
                        salesOrderController.salesOrderCounter,
                        {
                          'line_type_id': '2',
                          'item_id': '',
                          'itemName': '',
                          'item_main_code': '',
                          'item_discount': '0',
                          'item_description': '',
                          'item_quantity': '1',
                          'item_warehouseId': '',
                          'combo_warehouseId': '',
                          'item_unit_price': '0',
                          'item_total': '0',
                          'title': '',
                          'note': '',
                        },
                      );
                      salesOrderController.addToUnitPriceControllers(
                        salesOrderController.salesOrderCounter,
                      );
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
                      cont.setEnteredDiscInSalesOrder(widget.index, val);
                      cont.setMainTotalInSalesOrder(widget.index, totalLine);
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
                      cont.rowsInListViewInSalesOrder[widget
                          .index]['item_total'],
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.05,
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
                      salesOrderController.decrementListViewLengthInSalesOrder(
                        salesOrderController.increment,
                      );
                      salesOrderController.removeFromRowsInListViewInSalesOrder(
                        widget.index,
                      );

                      setState(() {
                        cont.totalItems = 0.0;
                        cont.globalDisc = "0.0";
                        cont.globalDiscountPercentageValue = "0.0";
                        cont.specialDisc = "0.0";
                        cont.specialDiscountPercentageValue = "0.0";
                        cont.vat11 = "0.0";
                        cont.vatInPrimaryCurrency = "0.0";
                        cont.totalSalesOrder = "0.0";

                        cont.getTotalItems();
                      });
                      if (cont.rowsInListViewInSalesOrder != {}) {
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
  final SalesOrderController salesOrderController = Get.find();
  String titleValue = '0';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // titleController.text = widget.info['title'] ?? '';
    titleController.text =
        salesOrderController.rowsInListViewInSalesOrder[widget.index]['title'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesOrderController>(
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
                      cont.setTypeInSalesOrder(widget.index, '1');
                      cont.setTitleInSalesOrder(widget.index, val);
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
                      salesOrderController.decrementListViewLengthInSalesOrder(
                        salesOrderController.increment,
                      );
                      salesOrderController.removeFromRowsInListViewInSalesOrder(
                        widget.index,
                      );
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
  final SalesOrderController salesOrderController = Get.find();
  String noteValue = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    noteController.text =
        salesOrderController.rowsInListViewInSalesOrder[widget.index]['note'];
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
                  salesOrderController.setTypeInSalesOrder(widget.index, '5');
                  salesOrderController.setNoteInSalesOrder(widget.index, val);
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
                    salesOrderController.decrementListViewLengthInSalesOrder(
                      salesOrderController.increment,
                    );
                    salesOrderController.removeFromRowsInListViewInSalesOrder(
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
  final SalesOrderController salesOrderController = Get.find();
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
    salesOrderController.setImageInSalesOrder(widget.index, imageFile);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesOrderController>(
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
                GetBuilder<SalesOrderController>(
                  builder: (cont) {
                    return InkWell(
                      onTap: () async {
                        final image = await ImagePickerHelper.pickImage();
                        setState(() {
                          imageFile = image!;
                          cont.changeBoolVar(true);
                          cont.increaseImageSpace(30);
                        });
                        cont.setTypeInSalesOrder(widget.index, '4');
                        cont.setImageInSalesOrder(widget.index, imageFile);
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
                        salesOrderController
                            .decrementListViewLengthInSalesOrder(
                              salesOrderController.increment + 50,
                            );
                        salesOrderController
                            .removeFromRowsInListViewInSalesOrder(widget.index);
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
  TextEditingController warehouseComboController = TextEditingController();

  final SalesOrderController salesOrderController = Get.find();
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
      (item) => item["currency"] == salesOrderController.selectedCurrencyName,
      orElse: () => null,
    );

    salesOrderController.exchangeRateForSelectedCurrency =
        result != null ? '${result["exchange_rate"]}' : '1';

    salesOrderController.combosPriceControllers[widget.index]!.text =
        '${widget.info['combo_unit_price'] ?? ''}';

    selectedComboId = widget.info['combo_id'].toString();
    // var ind=quotationController.combosIdsList.indexOf(selectedComboId);

    // if (quotationController.combosPricesCurrencies[selectedComboId] ==
    //     quotationController.selectedCurrencyName) {
    //
    //   quotationController.combosPriceControllers[widget.index]!.text =
    //       quotationController.combosPricesList[ind].toString();
    //
    // } else if (quotationController.selectedCurrencyName == 'USD' &&
    //     quotationController.combosPricesCurrencies[selectedComboId] !=
    //         quotationController.selectedCurrencyName) {
    //
    //   var result = exchangeRatesController.exchangeRatesList.firstWhere(
    //         (item) =>
    //     item["currency"] ==
    //         quotationController.combosPricesCurrencies[selectedComboId],
    //     orElse: () => null,
    //   );
    //   var divider = '1';
    //   if (result != null) {
    //     divider = result["exchange_rate"].toString();
    //   }
    //   quotationController.combosPriceControllers[widget.index]!.text =
    //   '${double.parse('${(double.parse(quotationController.combosPricesList[ind].toString()) / double.parse(divider))}')}';
    //
    // } else if (quotationController.selectedCurrencyName != 'USD' &&
    //     quotationController.combosPricesCurrencies[selectedComboId] == 'USD') {
    //
    //   quotationController.combosPriceControllers[widget.index]!.text =
    //   '${double.parse('${(double.parse(quotationController.combosPricesList[ind].toString()) * double.parse(quotationController.exchangeRateForSelectedCurrency))}')}';
    //
    // } else {
    //
    //   var result = exchangeRatesController.exchangeRatesList.firstWhere(
    //         (item) =>
    //     item["currency"] ==
    //         quotationController.combosPricesCurrencies[selectedComboId],
    //     orElse: () => null,
    //   );
    //   var divider = '1';
    //   if (result != null) {
    //     divider = result["exchange_rate"].toString();
    //   }
    //   var usdPrice =
    //       '${double.parse('${(double.parse(quotationController.combosPricesList[ind].toString()) / double.parse(divider))}')}';
    //   quotationController.combosPriceControllers[widget.index]!.text =
    //   '${double.parse('${(double.parse(usdPrice) * double.parse(quotationController.exchangeRateForSelectedCurrency))}')}';
    //
    // }

    // quotationController.combosPriceControllers[widget.index]!.text =
    // '${double.parse(quotationController.combosPriceControllers[widget.index]!.text) + taxValue}';
    //
    // quotationController.combosPriceControllers[widget.index]!.text = double.parse(
    //   quotationController.combosPriceControllers[widget.index]!.text,
    // ).toStringAsFixed(2);

    // qtyController.text = '1';
    salesOrderController.rowsInListViewInSalesOrder[widget
            .index]['item_unit_price'] =
        salesOrderController.combosPriceControllers[widget.index]!.text;
    salesOrderController.rowsInListViewInSalesOrder[widget
            .index]['item_total'] =
        '${widget.info['combo_total']}';
    salesOrderController.rowsInListViewInSalesOrder[widget.index]['combo'] =
        widget.info['combo_id'].toString();
  }

  @override
  void initState() {
    if (widget.info['combo_quantity'] != null) {
      qtyController.text = '${widget.info['combo_quantity'] ?? ''}';
      quantity = '${widget.info['combo_quantity'] ?? '0.0'}';
      salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_quantity'] =
          '${widget.info['combo_quantity'] ?? '0.0'}';

      if (widget.info['combo_warehouse_id'] == null) {
        warehouseComboController.text = "";
      } else {
        warehouseComboController.text =
            salesOrderController
                .warehousesNames['${widget.info['combo_warehouse_id']}'];
      }
      discountController.text = widget.info['combo_discount'] ?? '';
      discount = widget.info['combo_discount'] ?? '0.0';
      salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_discount'] =
          widget.info['combo_discount'] ?? '0.0';

      totalLine = widget.info['combo_total'] ?? '';

      mainDescriptionVar = widget.info['combo_description'] ?? '';

      mainCode = widget.info['combo_code'] ?? '';

      descriptionController.text = widget.info['combo_description'] ?? '';

      salesOrderController.rowsInListViewInSalesOrder[widget
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
      // quotationController.combosPriceControllers[widget.index]!.text = '0';
      comboCodeController.text =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_main_code'];
      qtyController.text =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_quantity'];
      discountController.text =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_discount'];
      descriptionController.text =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_description'];
      totalLine =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_total'];
      comboCodeController.text =
          salesOrderController.rowsInListViewInSalesOrder[widget
              .index]['item_main_code'];
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesOrderController>(
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
                      salesOrderController
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
                      cont.setEnteredQtyInSalesOrder(widget.index, quantity);
                      cont.setMainTotalInSalesOrder(widget.index, totalLine);
                      cont.getTotalItems();
                    });
                    cont.setEnteredUnitPriceInSalesOrder(
                      widget.index,
                      cont.combosPriceControllers[widget.index]!.text,
                    );
                    cont.setComboInSalesOrder(widget.index, selectedComboId);
                    cont.setItemNameInSalesOrder(
                      widget.index,
                      comboName,
                      // value.split(" | ")[0],
                    ); // set only first element as name
                    cont.setMainCodeInSalesOrder(widget.index, mainCode);
                    cont.setTypeInSalesOrder(widget.index, '3');
                    cont.setMainDescriptionInSalesOrder(
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
                  rowWidth: MediaQuery.of(context).size.width * 0.10,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.10,
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
                  width: MediaQuery.of(context).size.width * 0.20,
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
                      cont.setMainDescriptionInSalesOrder(
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

                      cont.setEnteredQtyInSalesOrder(widget.index, val);
                      cont.setMainTotalInSalesOrder(widget.index, totalLine);
                      cont.getTotalItems();
                    },
                  ),
                ),
                //warehouse
                DropdownMenu<String>(
                  width: MediaQuery.of(context).size.width * 0.10,
                  // requestFocusOnTap: false,
                  enableSearch: true,
                  controller: warehouseComboController,
                  hintText: 'deliver_warehouse'.tr,
                  inputDecorationTheme: InputDecorationTheme(
                    // filled: true,
                    hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                    contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                    // outlineBorder: BorderSide(color: Colors.black,),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                        width: 2,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                  // menuStyle: ,
                  menuHeight: 250,
                  dropdownMenuEntries:
                      cont.warehousesNameList.map<DropdownMenuEntry<String>>((
                        String option,
                      ) {
                        return DropdownMenuEntry<String>(
                          value: option,
                          label: option,
                        );
                      }).toList(),
                  enableFilter: true,
                  onSelected: (String? value) {
                    warehouseComboController.text = value!;

                    var index = cont.warehousesNameList.indexOf(value);
                    var val = '${cont.warehouseIds[index]}';
                    cont.setComboWareHouseInSalesOrder(widget.index, val);
                  },
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
                      cont.setEnteredUnitPriceInSalesOrder(widget.index, val);
                      cont.setMainTotalInSalesOrder(widget.index, totalLine);
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
                        salesOrderController.salesOrderCounter += 1;
                      });
                      salesOrderController.incrementListViewLengthInSalesOrder(
                        salesOrderController.increment,
                      );
                      salesOrderController.addToRowsInListViewInSalesOrder(
                        salesOrderController.salesOrderCounter,
                        {
                          'line_type_id': '3',
                          'item_id': '',
                          'itemName': '',
                          'item_main_code': '',
                          'item_discount': '0',
                          'item_description': '',
                          'item_quantity': '1',
                          'item_warehouseId': '',
                          'combo_warehouseId': '',
                          'item_unit_price': '0',
                          'item_total': '0',
                          'title': '',
                          'note': '',
                          'combo': '',
                        },
                      );
                      salesOrderController.addToCombosPricesControllers(
                        salesOrderController.salesOrderCounter,
                      );
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
                      cont.setEnteredDiscInSalesOrder(widget.index, val);
                      cont.setMainTotalInSalesOrder(widget.index, totalLine);
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
                      cont.rowsInListViewInSalesOrder[widget
                          .index]['item_total'],
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.05,
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
                      salesOrderController.decrementListViewLengthInSalesOrder(
                        salesOrderController.increment,
                      );
                      salesOrderController.removeFromRowsInListViewInSalesOrder(
                        widget.index,
                      );
                      setState(() {
                        cont.totalItems = 0.0;
                        cont.globalDisc = "0.0";
                        cont.globalDiscountPercentageValue = "0.0";
                        cont.specialDisc = "0.0";
                        cont.specialDiscountPercentageValue = "0.0";
                        cont.vat11 = "0.0";
                        cont.vatInPrimaryCurrency = "0.0";
                        cont.totalSalesOrder = "0.0";

                        cont.getTotalItems();
                      });
                      if (cont.rowsInListViewInSalesOrder != {}) {
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
