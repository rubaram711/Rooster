import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/Quotations/send_by_email.dart';
import 'package:rooster_app/Backend/Quotations/update_quotation.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/pending_docs_review_controller.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/create_product_dialog.dart';
import 'package:rooster_app/Screens/Client/create_client_dialog.dart';
import 'package:rooster_app/Widgets/TransferWidgets/reusable_show_info_card.dart';
import 'package:rooster_app/Widgets/dialog_drop_menu.dart';
import 'package:rooster_app/Widgets/reusable_add_card.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import '../../Controllers/home_controller.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../Widgets/TransferWidgets/under_item_btn.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_title.dart';
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
import 'add_cancelled_reason_dialog.dart';
import 'create_new_quotation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

class UpdateQuotationDialog extends StatefulWidget {
  const UpdateQuotationDialog({
    super.key,
    required this.index,
    required this.info,
    required this.fromPage,
  });
  final int index;
  final Map info;
  final String fromPage;

  @override
  State<UpdateQuotationDialog> createState() => _UpdateQuotationDialogState();
}

class _UpdateQuotationDialogState extends State<UpdateQuotationDialog> {
  final _formKey = GlobalKey<FormState>();
  String selectedSalesPerson = '';
  int selectedSalesPersonId = 0;
  List tabsList = ['order_lines', 'other_information'];
  TextEditingController cashingMethodsController = TextEditingController();
  TextEditingController salesPersonController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController refController = TextEditingController();
  TextEditingController validityController = TextEditingController();
  TextEditingController chanceController = TextEditingController();
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
  TextEditingController deliveryTermsController = TextEditingController();
  TextEditingController cancelledReasonController = TextEditingController();

  String selectedCurrency = '';

  String selectedItemCode = '';
  String selectedCustomerIds = '';

  List<String> termsList = [];

  final HomeController homeController = Get.find();
  final QuotationController quotationController = Get.find();
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
    quotationController.selectedCurrencyId =
        widget.info['currency']['id'].toString();
    selectedCurrency = widget.info['currency']['name'] ?? '';
    currencyController.text = selectedCurrency;
    int index = exchangeRatesController.currenciesNamesList.indexOf(
      selectedCurrency,
    );
    quotationController.selectedCurrencyId =
        exchangeRatesController.currenciesIdsList[index];
    quotationController.selectedCurrencyName = selectedCurrency;
    var vat = await getCompanyVatFromPref();
    quotationController.setCompanyVat(double.parse(vat));
    var companyCurrency = await getCompanyPrimaryCurrencyFromPref();
    quotationController.setCompanyPrimaryCurrency(companyCurrency);
    var result = exchangeRatesController.exchangeRatesList.firstWhere(
      (item) => item["currency"] == companyCurrency,
      orElse: () => null,
    );
    quotationController.setLatestRate(
      double.parse(result != null ? '${result["exchange_rate"]}' : '1'),
    );
  }

  // var isVatZero = false;
  checkVatExempt() async {
    var companySubjectToVat = await getCompanySubjectToVatFromPref();
    if (companySubjectToVat == '1') {
      vatExemptController.clear();
      quotationController.setIsVatExempted(false, false, false);
      quotationController.setIsVatExemptCheckBoxShouldAppear(true);
    } else {
      quotationController.setIsVatExemptCheckBoxShouldAppear(false);
      quotationController.setIsVatExempted(false, false, true);
      quotationController.setIsVatExemptChecked(true);
    }
    if ('${widget.info['printedAsPercentage'] ?? ''}' == '1') {
      quotationController.isPrintedAs0 = true;
      vatExemptController.text = 'Printed as "vat 0 % = 0"';
    }
    if ('${widget.info['printedAsVatExempt']}' == '1') {
      quotationController.isPrintedAsVatExempt = true;
      vatExemptController.text = 'Printed as "vat exempted"';
    }
    if ('${widget.info['notPrinted'] ?? ''}' == '1') {
      quotationController.isVatNoPrinted = true;
      vatExemptController.text = 'No printed ';
    }
    quotationController.isVatExemptChecked =
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
    quotationController.status = widget.info['status'];
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
    quotationController.rowsInListViewInQuotation = {};
    quotationController.orderedKeys = [];
    // print('widget.info');
    // print(widget.info);
    quotationController.quotationCounter = 0;
    checkVatExempt();
    getCurrency();
    setProgressVar();

    chanceController.text = widget.info['chance'] ?? '';
    deliveryTermsController.text = widget.info['deliveryTerms'] ?? '';
    print('widget.info[ ${widget.info['cancellationReason']}');
    cancelledReasonController.text = widget.info['cancellationReason'] ?? '';
    if (widget.info['cashingMethod'] != null) {
      cashingMethodsController.text =
          '${widget.info['cashingMethod']['title'] ?? ''}';
      quotationController.selectedCashingMethodId =
          '${widget.info['cashingMethod']['id']}';
    }

    if (widget.info['pricelist'] != null) {
      priceListController.text = '${widget.info['pricelist']['code'] ?? ''}';
      quotationController.selectedPriceListId =
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
      quotationController.isBeforeVatPrices = true;
    }

    if ('${widget.info['vatInclusivePrices'] ?? ''}' == '1') {
      priceConditionController.text = 'Prices are vat inclusive';
      quotationController.isBeforeVatPrices = false;
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
    quotationController.globalDisc =
        widget.info['globalDiscountAmount'] ?? '0.0';
    quotationController.specialDisc =
        widget.info['specialDiscountAmount'] ?? '0.0';
    quotationController.totalItems = double.parse(
      '${widget.info['totalBeforeVat'] ?? '0.0'}',
    );
    // print('isVatZero $isVatZero');
    quotationController.vat11 =
        quotationController.isVatExemptChecked
            ? '0'
            : '${widget.info['vat'] ?? ''}';
    quotationController.vatInPrimaryCurrency =
        quotationController.isVatExemptChecked
            ? '0'
            : '${widget.info['vatLebanese'] ?? ''}';

    // quotationController.totalQuotation = '${widget.info['total'] ?? ''}';
    quotationController.totalQuotation = ((quotationController.totalItems -
                double.parse(quotationController.globalDisc) -
                double.parse(quotationController.specialDisc)) +
            double.parse(quotationController.vat11))
        .toStringAsFixed(2);
    quotationController.city[selectedCustomerIds] =
        widget.info['client']['city'] ?? '';
    quotationController.country[selectedCustomerIds] =
        widget.info['client']['country'] ?? '';
    quotationController.email[selectedCustomerIds] =
        widget.info['client']['email'] ?? '';
    quotationController.phoneNumber[selectedCustomerIds] =
        widget.info['client']['phoneNumber'] ?? '';
    quotationController.selectedQuotationData['orderLines'] =
        widget.info['orderLines'] ?? '';
    for (
      int i = 0;
      i < quotationController.selectedQuotationData['orderLines'].length;
      i++
    ) {
      quotationController.rowsInListViewInQuotation[i + 1] =
          quotationController.selectedQuotationData['orderLines'][i];
      quotationController.orderedKeys.add(i + 1);
      if (quotationController
              .selectedQuotationData['orderLines'][i]['line_type_id'] ==
          2) {
        quotationController.unitPriceControllers[i + 1] =
            TextEditingController();
      } else if (quotationController
              .selectedQuotationData['orderLines'][i]['line_type_id'] ==
          3) {
        quotationController.combosPriceControllers[i + 1] =
            TextEditingController();
      }
    }
    //
    // for (int i = 0; i < widget.info['orderLines'].length; i++) {
    //   quotationController.orderedKeys.add(i + 1);
    //   if (widget.info['orderLines'][i]['line_type_id'] == 2) {
    //     quotationController.unitPriceControllers[i + 1] =
    //         TextEditingController();
    //     //   Widget p = ReusableItemRow(
    //     //     index: i + 1,
    //     //     info: quotationController.rowsInListViewInQuotation[keys[i]],
    //     //   );
    //     //
    //     //   quotationController.orderLinesQuotationList['${i + 1}'] = p;
    //     // } else if (widget.info['orderLines'][i]['line_type_id'] == 1) {
    //     //   Widget p = ReusableTitleRow(
    //     //     index: i + 1,
    //     //     info: quotationController.rowsInListViewInQuotation[keys[i]],
    //     //   );
    //     //   quotationController.orderLinesQuotationList['${i + 1}'] = p;
    //     // } else if (widget.info['orderLines'][i]['line_type_id'] == 5) {
    //     //   Widget p = ReusableNoteRow(
    //     //     index: i + 1,
    //     //     info: quotationController.rowsInListViewInQuotation[keys[i]],
    //     //   );
    //     //   quotationController.orderLinesQuotationList['${i + 1}'] = p;
    //     // } else if (widget.info['orderLines'][i]['line_type_id'] == 4) {
    //     //   Widget p = ReusableImageRow(
    //     //     index: i + 1,
    //     //     info: quotationController.rowsInListViewInQuotation[keys[i]],
    //     //   );
    //     //   quotationController.orderLinesQuotationList['${i + 1}'] = p;
    //   } else if (widget.info['orderLines'][i]['line_type_id'] == 3) {
    //     quotationController.combosPriceControllers[i + 1] =
    //         TextEditingController();
    //     // Widget p = ReusableComboRow(
    //     //   index: i + 1,
    //     //   info: quotationController.rowsInListViewInQuotation[keys[i]],
    //     // );
    //     // quotationController.orderLinesQuotationList['${i + 1}'] = p;
    //   }
    // }
    quotationController.quotationCounter =
        quotationController.rowsInListViewInQuotation.length;
    quotationController.listViewLengthInQuotation =
        quotationController.rowsInListViewInQuotation.length * 60;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuotationController>(
      builder: (quotationCont) {
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
                      PageTitle(text: 'update_quotation'.tr),
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
                              bool hasType1WithEmptyTitle = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '1' &&
                                        (map['title']?.isEmpty ?? true);
                                  });
                              bool hasType2WithEmptyId = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '2' &&
                                        (map['item_id']?.isEmpty ?? true);
                                  });
                              bool hasType3WithEmptyId = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '3' &&
                                        (map['combo']?.isEmpty ?? true);
                                  });
                              bool hasType4WithEmptyImage = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '4' &&
                                        (map['image'] == Uint8List(0) ||
                                            map['image']?.isEmpty);
                                  });
                              bool hasType5WithEmptyNote = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '5' &&
                                        (map['note']?.isEmpty ?? true);
                                  });
                              if (quotationController
                                  .rowsInListViewInQuotation
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
                                setState(() {
                                  progressVar = 1;
                                });
                                var res = await sendByEmail(
                                  '${widget.info['id']}',
                                );
                                if ('${res['success']}' == 'true') {
                                  Get.back();
                                  quotationController
                                      .getAllQuotationsWithoutPendingFromBack();
                                  // homeController.selectedTab.value = 'new_quotation';
                                  homeController.selectedTab.value =
                                      'pending_quotation';
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
                            text: 'confirm'.tr,
                            onTap: () async {
                              quotationCont.setStatus('confirmed');
                              var oldKeys =
                                  quotationController
                                      .rowsInListViewInQuotation
                                      .keys
                                      .toList()
                                    ..sort();
                              for (int i = 0; i < oldKeys.length; i++) {
                                quotationController
                                        .rowsInListViewInQuotation[i + 1] =
                                    quotationController
                                        .rowsInListViewInQuotation[oldKeys[i]]!;
                              }
                              bool hasType1WithEmptyTitle = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '1' &&
                                        (map['title']?.isEmpty ?? true);
                                  });
                              bool hasType2WithEmptyId = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '2' &&
                                        (map['item_id']?.isEmpty ?? true);
                                  });
                              bool hasType3WithEmptyId = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '3' &&
                                        (map['combo']?.isEmpty ?? true);
                                  });
                              bool hasType4WithEmptyImage = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '4' &&
                                        (map['image'] == Uint8List(0) ||
                                            map['image']?.isEmpty);
                                  });
                              bool hasType5WithEmptyNote = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '5' &&
                                        (map['note']?.isEmpty ?? true);
                                  });
                              if (quotationController
                                  .rowsInListViewInQuotation
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
                                  var res = await updateQuotation(
                                    '${widget.info['id']}',
                                    // termsAndConditionsController.text!=oldTermsAndConditionsString,
                                    refController.text,
                                    selectedCustomerIds,
                                    validityController.text,
                                    inputDateController.text,
                                    '', //todo paymentTermsController.text,
                                    quotationCont.selectedPriceListId,
                                    quotationCont
                                        .selectedCurrencyId, //selectedCurrency
                                    termsAndConditionsController.text,
                                    selectedSalesPersonId.toString(),
                                    '',
                                    quotationCont.selectedCashingMethodId,
                                    commissionController.text,
                                    totalCommissionController.text,
                                    quotationController.totalItems
                                        .toString(), //total before vat
                                    specialDiscPercentController
                                        .text, // inserted by user
                                    quotationController
                                        .specialDisc, // calculated
                                    globalDiscPercentController.text,
                                    quotationController.globalDisc,
                                    quotationController.vat11.toString(), //vat
                                    quotationController.vatInPrimaryCurrency
                                        .toString(),
                                    quotationController
                                        .totalQuotation, // quotationController.totalQuotation

                                    quotationCont.isVatExemptChecked
                                        ? '1'
                                        : '0',
                                    quotationCont.isVatNoPrinted ? '1' : '0',
                                    quotationCont.isPrintedAsVatExempt
                                        ? '1'
                                        : '0',
                                    quotationCont.isPrintedAs0 ? '1' : '0',
                                    quotationCont.isBeforeVatPrices ? '0' : '1',

                                    quotationCont.isBeforeVatPrices ? '1' : '0',
                                    codeController.text,
                                    quotationCont.status,
                                    quotationController
                                        .rowsInListViewInQuotation,
                                    quotationCont.orderedKeys,
                                    cancelledReasonController.text,
                                    deliveryTermsController.text,
                                    chanceController.text,
                                  );
                                  if (res['success'] == true) {
                                    setState(() {
                                      progressVar = 2;
                                    });
                                    Get.back();
                                    quotationController
                                        .getAllQuotationsWithoutPendingFromBack();
                                    // homeController.selectedTab.value = 'new_quotation';
                                    homeController.selectedTab.value =
                                        'to_sales_order';
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
                              quotationCont.setStatus('cancelled');
                              bool hasType1WithEmptyTitle = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '1' &&
                                        (map['title']?.isEmpty ?? true);
                                  });
                              bool hasType2WithEmptyId = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '2' &&
                                        (map['item_id']?.isEmpty ?? true);
                                  });
                              bool hasType3WithEmptyId = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '3' &&
                                        (map['combo']?.isEmpty ?? true);
                                  });
                              bool hasType4WithEmptyImage = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '4' &&
                                        (map['image'] == Uint8List(0) ||
                                            map['image']?.isEmpty);
                                  });
                              bool hasType5WithEmptyNote = quotationController
                                  .rowsInListViewInQuotation
                                  .values
                                  .any((map) {
                                    return map['line_type_id'] == '5' &&
                                        (map['note']?.isEmpty ?? true);
                                  });
                              if (quotationController
                                  .rowsInListViewInQuotation
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
                                  showDialog<String>(
                                    context: context,
                                    builder:
                                        (BuildContext context) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(9),
                                            ),
                                          ),
                                          elevation: 0,
                                          content: AddCancelledReasonDialog(
                                            func: (cancelledReason) async {
                                              var res = await updateQuotation(
                                                '${widget.info['id']}',
                                                // termsAndConditionsController.text!=oldTermsAndConditionsString,
                                                refController.text,
                                                selectedCustomerIds,
                                                validityController.text,
                                                inputDateController.text,
                                                '', //todo paymentTermsController.text,
                                                quotationCont
                                                    .selectedPriceListId,
                                                quotationCont
                                                    .selectedCurrencyId, //selectedCurrency
                                                termsAndConditionsController
                                                    .text,
                                                selectedSalesPersonId
                                                    .toString(),
                                                '',
                                                quotationCont
                                                    .selectedCashingMethodId,
                                                commissionController.text,
                                                totalCommissionController.text,
                                                quotationController.totalItems
                                                    .toString(), //total before vat
                                                specialDiscPercentController
                                                    .text, // inserted by user
                                                quotationController
                                                    .specialDisc, // calculated
                                                globalDiscPercentController
                                                    .text,
                                                quotationController.globalDisc,
                                                quotationController.vat11
                                                    .toString(), //vat
                                                quotationController
                                                    .vatInPrimaryCurrency
                                                    .toString(),
                                                quotationController
                                                    .totalQuotation, // quotationController.totalQuotation

                                                quotationCont.isVatExemptChecked
                                                    ? '1'
                                                    : '0',
                                                quotationCont.isVatNoPrinted
                                                    ? '1'
                                                    : '0',
                                                quotationCont
                                                        .isPrintedAsVatExempt
                                                    ? '1'
                                                    : '0',
                                                quotationCont.isPrintedAs0
                                                    ? '1'
                                                    : '0',
                                                quotationCont.isBeforeVatPrices
                                                    ? '0'
                                                    : '1',

                                                quotationCont.isBeforeVatPrices
                                                    ? '1'
                                                    : '0',
                                                codeController.text,
                                                quotationCont.status, // status,
                                                // quotationController.rowsInListViewInQuotation,
                                                quotationController
                                                    .rowsInListViewInQuotation,
                                                quotationController.orderedKeys,
                                                cancelledReason,
                                                deliveryTermsController.text,
                                                chanceController.text,
                                              );
                                              if (res['success'] == true) {
                                                Get.back();
                                                Get.back();
                                                quotationController
                                                    .getAllQuotationsWithoutPendingFromBack();
                                                // homeController.selectedTab.value = 'new_quotation';
                                                homeController
                                                        .selectedTab
                                                        .value =
                                                    'quotation_summary';
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
                                            },
                                          ),
                                        ),
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
                            text: 'processing'.tr,
                          ),
                          ReusableTimeLineTile(
                            id: 1,
                            progressVar: progressVar,
                            isFirst: false,
                            isLast: false,
                            isPast: false,
                            text: 'quotation_sent'.tr,
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
                                  '${widget.info['quotationNumber'] ?? ''}',
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
                                            quotationCont.setSelectedCurrency(
                                              cont.currenciesIdsList[index],
                                              val,
                                            );
                                            var result = cont.exchangeRatesList
                                                .firstWhere(
                                                  (item) =>
                                                      item["currency"] == val,
                                                  orElse: () => null,
                                                );
                                            quotationCont
                                                .setExchangeRateForSelectedCurrency(
                                                  result != null
                                                      ? '${result["exchange_rate"]}'
                                                      : '1',
                                                );
                                          });
                                          var keys =
                                              quotationCont
                                                  .unitPriceControllers
                                                  .keys
                                                  .toList();
                                          for (
                                            int i = 0;
                                            i <
                                                quotationCont
                                                    .unitPriceControllers
                                                    .length;
                                            i++
                                          ) {
                                            var selectedItemId =
                                                '${quotationCont.rowsInListViewInQuotation[keys[i]]['item_id']}';
                                            if (selectedItemId != '') {
                                              if (quotationCont
                                                      .itemsPricesCurrencies[selectedItemId] ==
                                                  val) {
                                                quotationCont
                                                    .unitPriceControllers[keys[i]]!
                                                    .text = quotationCont
                                                        .itemUnitPrice[selectedItemId]
                                                        .toString();
                                              } else if (val == 'USD' &&
                                                  quotationCont
                                                          .itemsPricesCurrencies[selectedItemId] !=
                                                      val) {
                                                var result = exchangeRatesController
                                                    .exchangeRatesList
                                                    .firstWhere(
                                                      (item) =>
                                                          item["currency"] ==
                                                          quotationCont
                                                              .itemsPricesCurrencies[selectedItemId],
                                                      orElse: () => null,
                                                    );
                                                var divider = '1';
                                                if (result != null) {
                                                  divider =
                                                      result["exchange_rate"]
                                                          .toString();
                                                }
                                                quotationCont
                                                        .unitPriceControllers[keys[i]]!
                                                        .text =
                                                    '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                              } else if (quotationCont
                                                          .selectedCurrencyName !=
                                                      'USD' &&
                                                  quotationCont
                                                          .itemsPricesCurrencies[selectedItemId] ==
                                                      'USD') {
                                                quotationCont
                                                        .unitPriceControllers[keys[i]]!
                                                        .text =
                                                    '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                              } else {
                                                var result = exchangeRatesController
                                                    .exchangeRatesList
                                                    .firstWhere(
                                                      (item) =>
                                                          item["currency"] ==
                                                          quotationCont
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
                                                    '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                quotationCont
                                                        .unitPriceControllers[keys[i]]!
                                                        .text =
                                                    '${double.parse('${(double.parse(usdPrice) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                              }
                                              if (!quotationCont
                                                  .isBeforeVatPrices) {
                                                var taxRate =
                                                    double.parse(
                                                      quotationCont
                                                          .itemsVats[selectedItemId],
                                                    ) /
                                                    100.0;
                                                var taxValue =
                                                    taxRate *
                                                    double.parse(
                                                      quotationCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text,
                                                    );

                                                quotationCont
                                                        .unitPriceControllers[keys[i]]!
                                                        .text =
                                                    '${double.parse(quotationCont.unitPriceControllers[keys[i]]!.text) + taxValue}';
                                              }
                                              quotationCont
                                                  .unitPriceControllers[keys[i]]!
                                                  .text = double.parse(
                                                quotationCont
                                                    .unitPriceControllers[keys[i]]!
                                                    .text,
                                              ).toStringAsFixed(2);
                                              var totalLine =
                                                  '${(double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_quantity']) * double.parse(quotationCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';
                                              quotationCont
                                                  .setEnteredUnitPriceInQuotation(
                                                    keys[i],
                                                    quotationCont
                                                        .unitPriceControllers[keys[i]]!
                                                        .text,
                                                  );
                                              quotationCont
                                                  .setMainTotalInQuotation(
                                                    keys[i],
                                                    totalLine,
                                                  );
                                              quotationCont.getTotalItems();
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
                              width:
                                  homeController.isOpened.value
                                      ? MediaQuery.of(context).size.width * 0.10
                                      : MediaQuery.of(context).size.width *
                                          0.14,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('chance'.tr),
                                  DropdownMenu<String>(
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
                                    // requestFocusOnTap: false,
                                    enableSearch: true,
                                    controller: chanceController,
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
                                        chanceLevels
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
                                      //   var index = quotationCont
                                      //       .priceListsCodes
                                      //       .indexOf(val!);
                                      //   quotationCont.setSelectedPriceListId(
                                      //     quotationCont.priceListsIds[index],
                                      //   );
                                      //   setState(() {
                                      //     quotationCont
                                      //         .resetItemsAfterChangePriceList();
                                      //   });
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
                                        quotationCont.priceListsCodes
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
                                      var index = quotationCont.priceListsCodes
                                          .indexOf(val!);
                                      quotationCont.setSelectedPriceListId(
                                        quotationCont.priceListsIds[index],
                                      );
                                      setState(() {
                                        quotationCont
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
                              width: MediaQuery.of(context).size.width * 0.37,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('code'.tr),
                                  DropdownMenu<String>(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.15,
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
                                        quotationCont.customerNumberList
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
                                        indexNum = quotationCont
                                            .customerNumberList
                                            .indexOf(selectedItemCode);
                                        selectedCustomerIds =
                                            quotationCont
                                                .customerIdsList[indexNum];
                                        searchController.text =
                                            quotationCont
                                                .customerNameList[indexNum];
                                      });
                                      int index = quotationCont
                                          .customerNumberList
                                          .indexOf(val!);
                                      if (quotationCont
                                          .customersPricesListsIds[index]
                                          .isNotEmpty) {
                                        quotationCont.setSelectedPriceListId(
                                          '${quotationCont.customersPricesListsIds[index]}',
                                        );

                                        priceListController.text =
                                            quotationCont
                                                .priceListsNames[quotationCont
                                                .priceListsIds
                                                .indexOf(
                                                  '${quotationCont.customersPricesListsIds[index]}',
                                                )];
                                        setState(() {
                                          quotationCont
                                              .resetItemsAfterChangePriceList();
                                        });
                                      }
                                      if (quotationCont
                                          .customersSalesPersonsIds[index]
                                          .isNotEmpty) {
                                        setState(() {
                                          selectedSalesPersonId = int.parse(
                                            '${quotationCont.customersSalesPersonsIds[index]}',
                                          );
                                          selectedSalesPerson =
                                              quotationCont
                                                  .salesPersonListNames[quotationCont
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
                                    list: quotationCont.customerNameList,
                                    text: '',
                                    hint: '${'search'.tr}...',
                                    controller: searchController,
                                    onSelected: (String? val) {
                                      setState(() {
                                        selectedItem = val!;
                                        var index = quotationCont
                                            .customerNameList
                                            .indexOf(selectedItem);
                                        selectedCustomerIds =
                                            quotationCont
                                                .customerIdsList[index];
                                        codeController.text =
                                            quotationCont
                                                .customerNumberList[index];

                                        // codeController =
                                        //     quotationController.codeController;
                                      });
                                      var index = quotationCont.customerNameList
                                          .indexOf(val!);
                                      if (quotationCont
                                          .customersPricesListsIds[index]
                                          .isNotEmpty) {
                                        quotationCont.setSelectedPriceListId(
                                          '${quotationCont.customersPricesListsIds[index]}',
                                        );

                                        priceListController.text =
                                            quotationCont
                                                .priceListsNames[quotationCont
                                                .priceListsIds
                                                .indexOf(
                                                  '${quotationCont.customersPricesListsIds[index]}',
                                                )];
                                        setState(() {
                                          quotationCont
                                              .resetItemsAfterChangePriceList();
                                        });
                                      }
                                      if (quotationCont
                                          .customersSalesPersonsIds[index]
                                          .isNotEmpty) {
                                        setState(() {
                                          selectedSalesPersonId = int.parse(
                                            '${quotationCont.customersSalesPersonsIds[index]}',
                                          );
                                          selectedSalesPerson =
                                              quotationCont
                                                  .salesPersonListNames[quotationCont
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
                                        0.18,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width *
                                        0.17,
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
                                        " ${quotationCont.street[selectedCustomerIds] ?? ''} ",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        quotationCont.floorAndBuilding[selectedCustomerIds] ==
                                                    '' ||
                                                quotationCont
                                                        .floorAndBuilding[selectedCustomerIds] ==
                                                    null
                                            ? ''
                                            : ',',
                                      ),
                                      Text(
                                        " ${quotationCont.floorAndBuilding[selectedCustomerIds] ?? ''}",
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
                                        "${quotationCont.phoneNumber[selectedCustomerIds] ?? ''}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            gapW16,
                            DialogTextField(
                              textEditingController: deliveryTermsController,
                              text: '${'delivery_terms'.tr}:',
                              hint: '',
                              rowWidth:
                                  MediaQuery.of(context).size.width * 0.24,
                              textFieldWidth:
                                  MediaQuery.of(context).size.width * 0.15,
                              validationFunc: (val) {},
                            ),
                          ],
                        ),
                        gapH10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
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
                                      GetBuilder<QuotationController>(
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
                                  quotationCont.isVatExemptCheckBoxShouldAppear
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'price'.tr,
                                    style:
                                        quotationCont.isVatExemptChecked
                                            ? TextStyle(color: Others.divider)
                                            : TextStyle(),
                                  ),
                                  GetBuilder<ExchangeRatesController>(
                                    builder: (cont) {
                                      return DropdownMenu<String>(
                                        enabled:
                                            !quotationCont.isVatExemptChecked,
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
                                              quotationCont
                                                  .setIsBeforeVatPrices(true);
                                            } else {
                                              quotationCont
                                                  .setIsBeforeVatPrices(false);
                                            }
                                            var keys =
                                                quotationCont
                                                    .unitPriceControllers
                                                    .keys
                                                    .toList();
                                            for (
                                              int i = 0;
                                              i <
                                                  quotationCont
                                                      .unitPriceControllers
                                                      .length;
                                              i++
                                            ) {
                                              var selectedItemId =
                                                  '${quotationCont.rowsInListViewInQuotation[keys[i]]['item_id']}';
                                              if (selectedItemId != '') {
                                                if (quotationCont
                                                        .itemsPricesCurrencies[selectedItemId] ==
                                                    selectedCurrency) {
                                                  quotationCont
                                                      .unitPriceControllers[keys[i]]!
                                                      .text = quotationCont
                                                          .itemUnitPrice[selectedItemId]
                                                          .toString();
                                                } else if (quotationCont
                                                            .selectedCurrencyName ==
                                                        'USD' &&
                                                    quotationCont
                                                            .itemsPricesCurrencies[selectedItemId] !=
                                                        selectedCurrency) {
                                                  var result = exchangeRatesController
                                                      .exchangeRatesList
                                                      .firstWhere(
                                                        (item) =>
                                                            item["currency"] ==
                                                            quotationCont
                                                                .itemsPricesCurrencies[selectedItemId],
                                                        orElse: () => null,
                                                      );
                                                  var divider = '1';
                                                  if (result != null) {
                                                    divider =
                                                        result["exchange_rate"]
                                                            .toString();
                                                  }
                                                  quotationCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text =
                                                      '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                } else if (quotationCont
                                                            .selectedCurrencyName !=
                                                        'USD' &&
                                                    quotationCont
                                                            .itemsPricesCurrencies[selectedItemId] ==
                                                        'USD') {
                                                  quotationCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text =
                                                      '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                } else {
                                                  var result = exchangeRatesController
                                                      .exchangeRatesList
                                                      .firstWhere(
                                                        (item) =>
                                                            item["currency"] ==
                                                            quotationCont
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
                                                      '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                  quotationCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text =
                                                      '${double.parse('${(double.parse(usdPrice) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                }
                                                if (!quotationCont
                                                    .isBeforeVatPrices) {
                                                  var taxRate =
                                                      double.parse(
                                                        quotationCont
                                                            .itemsVats[selectedItemId],
                                                      ) /
                                                      100.0;
                                                  var taxValue =
                                                      taxRate *
                                                      double.parse(
                                                        quotationCont
                                                            .unitPriceControllers[keys[i]]!
                                                            .text,
                                                      );

                                                  quotationCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text =
                                                      '${double.parse(quotationCont.unitPriceControllers[keys[i]]!.text) + taxValue}';
                                                }
                                                quotationCont
                                                    .unitPriceControllers[keys[i]]!
                                                    .text = double.parse(
                                                  quotationCont
                                                      .unitPriceControllers[keys[i]]!
                                                      .text,
                                                ).toStringAsFixed(2);
                                                var totalLine =
                                                    '${(double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_quantity']) * double.parse(quotationCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';

                                                quotationCont
                                                    .setEnteredUnitPriceInQuotation(
                                                      keys[i],
                                                      quotationCont
                                                          .unitPriceControllers[keys[i]]!
                                                          .text,
                                                    );
                                                quotationCont
                                                    .setMainTotalInQuotation(
                                                      keys[i],
                                                      totalLine,
                                                    );
                                                quotationCont.getTotalItems();
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
                            gapW16,
                            //vat exempt
                            quotationCont.isVatExemptCheckBoxShouldAppear
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
                                                quotationCont
                                                    .isVatExemptChecked,
                                            onChanged: (bool? value) {
                                              quotationCont
                                                  .setIsVatExemptChecked(
                                                    value!,
                                                  );
                                              if (value) {
                                                priceConditionController.text =
                                                    'Prices are before vat';
                                                quotationCont
                                                    .setIsBeforeVatPrices(true);
                                                vatExemptController.text =
                                                    vatExemptList[0];
                                                quotationCont.setIsVatExempted(
                                                  true,
                                                  false,
                                                  false,
                                                );
                                              } else {
                                                vatExemptController.clear();
                                                quotationCont.setIsVatExempted(
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
                                      quotationCont.isVatExemptChecked == false
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
                                                  quotationCont
                                                      .setIsVatExempted(
                                                        true,
                                                        false,
                                                        false,
                                                      );
                                                } else if (val ==
                                                    'Printed as "vat 0 % = 0"') {
                                                  quotationCont
                                                      .setIsVatExempted(
                                                        false,
                                                        true,
                                                        false,
                                                      );
                                                } else {
                                                  quotationCont
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
                                      MediaQuery.of(context).size.width * 0.07,
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
                                      quotationCont.listViewLengthInQuotation +
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
                                          quotationCont
                                              .rowsInListViewInQuotation
                                              .keys
                                              .length,
                                      buildDefaultDragHandles: false,
                                      itemBuilder: (context, index) {
                                        final key =
                                            quotationCont.orderedKeys[index];
                                        final row =
                                            quotationCont
                                                .rowsInListViewInQuotation[key]!;
                                        final lineType =
                                            '${row['line_type_id'] ?? ''}';
                                        return SizedBox(
                                          key: ValueKey(key),
                                          // onDismissed: (direction) {
                                          //   setState(() {
                                          //     quotationController
                                          //         .decrementListViewLengthInQuotation(
                                          //           quotationController
                                          //               .increment,
                                          //         );
                                          //     quotationController
                                          //         .removeFromRowsInListViewInQuotation(
                                          //           key,
                                          //         );
                                          //     // quotationController
                                          //     //     .removeFromOrderLinesInQuotationList(
                                          //     //   key.toString(),
                                          //     // );
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
                                          final movedKey = quotationCont
                                              .orderedKeys
                                              .removeAt(oldIndex);
                                          quotationCont.orderedKeys.insert(
                                            newIndex,
                                            movedKey,
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                ),

                                // SizedBox(
                                //   height:
                                //   quotationCont.listViewLengthInQuotation +
                                //       50,
                                //   child: ListView(
                                //     children:
                                //     keysList.map((key) {
                                //       return SizedBox(
                                //         key: Key(
                                //           key,
                                //         ), // Ensure each widget has a unique key
                                //         onDismissed:
                                //             (direction) => quotationCont
                                //             .removeFromOrderLinesInQuotationList(
                                //           key.toString(),
                                //         ),
                                //         child:
                                //         quotationCont
                                //             .orderLinesQuotationList[key] ??
                                //             const SizedBox(),
                                //       );
                                //     }).toList(),
                                //   ),
                                // ),
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
                                        quotationController
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
                                        var index = quotationController
                                            .salesPersonListNames
                                            .indexOf(val);
                                        selectedSalesPersonId =
                                            quotationController
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
                                        quotationCont.cashingMethodsNamesList,
                                    text: 'cashing_method'.tr,
                                    hint: '',
                                    rowWidth:
                                        MediaQuery.of(context).size.width * 0.3,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width *
                                        0.15,
                                    onSelected: (value) {
                                      var index = quotationCont
                                          .cashingMethodsNamesList
                                          .indexOf(value);
                                      quotationCont.setSelectedCashingMethodId(
                                        quotationCont
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

                  GetBuilder<QuotationController>(
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
                                  quotationCont.isVatExemptCheckBoxShouldAppear
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
                                        '${quotationCont.selectedCurrencyName} ${formatDoubleWithCommas(double.parse(quotationCont.totalQuotation))}',
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
                          bool hasType1WithEmptyTitle = quotationController
                              .rowsInListViewInQuotation
                              .values
                              .any((map) {
                                return map['line_type_id'] == '1' &&
                                    (map['title']?.isEmpty ?? true);
                              });
                          bool hasType2WithEmptyId = quotationController
                              .rowsInListViewInQuotation
                              .values
                              .any((map) {
                                return map['line_type_id'] == '2' &&
                                    (map['item_id']?.isEmpty ?? true);
                              });
                          bool hasType3WithEmptyId = quotationController
                              .rowsInListViewInQuotation
                              .values
                              .any((map) {
                                return map['line_type_id'] == '3' &&
                                    (map['combo']?.isEmpty ?? true);
                              });
                          bool hasType4WithEmptyImage = quotationController
                              .rowsInListViewInQuotation
                              .values
                              .any((map) {
                                return map['line_type_id'] == '4' &&
                                    (map['image'] == Uint8List(0) ||
                                        map['image']?.isEmpty);
                              });
                          bool hasType5WithEmptyNote = quotationController
                              .rowsInListViewInQuotation
                              .values
                              .any((map) {
                                return map['line_type_id'] == '5' &&
                                    (map['note']?.isEmpty ?? true);
                              });
                          if (quotationController
                              .rowsInListViewInQuotation
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
                              var res = await updateQuotation(
                                '${widget.info['id']}',
                                // termsAndConditionsController.text!=oldTermsAndConditionsString,
                                refController.text,
                                selectedCustomerIds,
                                validityController.text,
                                inputDateController.text,
                                '', //todo paymentTermsController.text,
                                quotationCont.selectedPriceListId,
                                quotationCont
                                    .selectedCurrencyId, //selectedCurrency
                                termsAndConditionsController.text,
                                selectedSalesPersonId.toString(),
                                '',
                                quotationCont.selectedCashingMethodId,
                                commissionController.text,
                                totalCommissionController.text,
                                quotationController.totalItems
                                    .toString(), //total before vat
                                specialDiscPercentController
                                    .text, // inserted by user
                                quotationController.specialDisc, // calculated
                                globalDiscPercentController.text,
                                quotationController.globalDisc,
                                quotationController.vat11.toString(), //vat
                                quotationController.vatInPrimaryCurrency
                                    .toString(),
                                quotationController
                                    .totalQuotation, // quotationController.totalQuotation

                                quotationCont.isVatExemptChecked ? '1' : '0',
                                quotationCont.isVatNoPrinted ? '1' : '0',
                                quotationCont.isPrintedAsVatExempt ? '1' : '0',
                                quotationCont.isPrintedAs0 ? '1' : '0',
                                quotationCont.isBeforeVatPrices ? '0' : '1',

                                quotationCont.isBeforeVatPrices ? '1' : '0',
                                codeController.text,
                                quotationCont.status,
                                quotationController.rowsInListViewInQuotation,
                                quotationController.orderedKeys,
                                cancelledReasonController.text,
                                deliveryTermsController.text,
                                chanceController.text,
                              );
                              if (res['success'] == true) {
                                Get.back();

                                if (widget.fromPage == 'pendingDocs') {
                                  pendingDocsController.getAllPendingDocs();
                                  homeController.selectedTab.value =
                                      'pending_docs';
                                } else if (quotationCont.status ==
                                    'confirmed') {
                                  quotationController
                                      .getAllQuotationsFromBack();
                                  homeController.selectedTab.value =
                                      'to_sales_order';
                                } else if (quotationCont.status ==
                                    'cancelled') {
                                  quotationController
                                      .getAllQuotationsFromBack();
                                  homeController.selectedTab.value =
                                      'quotation_summary';
                                } else if (quotationCont.status == 'sent') {
                                  quotationController
                                      .getAllQuotationsFromBack();
                                  homeController.selectedTab.value =
                                      'pending_quotation';
                                } else {
                                  quotationController
                                      .getAllQuotationsFromBack();
                                  homeController.selectedTab.value =
                                      'pending_quotation';
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
      quotationController.quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
    );
    quotationController
        .addToRowsInListViewInQuotation(quotationController.quotationCounter, {
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
    // Widget p = ReusableTitleRow(
    //   index: quotationController.quotationCounter,
    //   info: {},
    // );
    // quotationController.addToOrderLinesInQuotationList(
    //   '${quotationController.quotationCounter}',
    //   p,
    // );
  }
  // int quotationCounter = 0;

  addNewItem() {
    setState(() {
      quotationController.quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
    );
    quotationController
        .addToRowsInListViewInQuotation(quotationController.quotationCounter, {
          'line_type_id': '2',
          'item_id': '',
          'itemName': '',
          'item_main_code': '',
          'item_discount': '0',
          'item_description': '',
          'item_quantity': '1',
          'item_unit_price': '0',
          'item_total': '0',
          'title': '',
          'note': '',
        });
    quotationController.addToUnitPriceControllers(
      quotationController.quotationCounter,
    );
    // Widget p = ReusableItemRow(
    //   index: quotationController.quotationCounter,
    //   info: {},
    // );
    // quotationController.addToOrderLinesInQuotationList(
    //   '${quotationController.quotationCounter}',
    //   p,
    // );
  }

  addNewCombo() {
    setState(() {
      quotationController.quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
    );
    quotationController
        .addToRowsInListViewInQuotation(quotationController.quotationCounter, {
          'line_type_id': '3',
          'item_id': '',
          'itemName': '',
          'item_main_code': '',
          'item_discount': '0',
          'item_description': '',
          'item_quantity': '1',
          'item_unit_price': '0',
          'item_total': '0',
          'title': '',
          'note': '',
          'combo': '',
        });
    quotationController.addToCombosPricesControllers(
      quotationController.quotationCounter,
    );
    // Widget p = ReusableComboRow(
    //   index: quotationController.quotationCounter,
    //   info: {},
    // );
    // quotationController.addToOrderLinesInQuotationList(
    //   '${quotationController.quotationCounter}',
    //   p,
    // );
  }

  addNewImage() {
    setState(() {
      quotationController.quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
    );

    quotationController
        .addToRowsInListViewInQuotation(quotationController.quotationCounter, {
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

    // Widget p = ReusableImageRow(
    //   index: quotationController.quotationCounter,
    //   info: {},
    // );
    //
    // quotationController.addToOrderLinesInQuotationList(
    //   '${quotationController.quotationCounter}',
    //   p,
    // );
  }

  addNewNote() {
    setState(() {
      quotationController.quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
    );

    quotationController
        .addToRowsInListViewInQuotation(quotationController.quotationCounter, {
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

    // Widget p = ReusableNoteRow(
    //   index: quotationController.quotationCounter,
    //   info: {},
    // );
    //
    // quotationController.addToOrderLinesInQuotationList(
    //   '${quotationController.quotationCounter}',
    //   p,
    // );

    // quotationController.addToOrderLinesList(p);
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
  final QuotationController quotationController = Get.find();
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
      (item) => item["currency"] == quotationController.selectedCurrencyName,
      orElse: () => null,
    );
    quotationController.exchangeRateForSelectedCurrency =
        result != null ? '${result["exchange_rate"]}' : '1';
    quotationController.unitPriceControllers[widget.index]!.text =
        '${widget.info['item_unit_price'] ?? '1'}';
    selectedItemId = widget.info['item_id'].toString();
    quotationController.unitPriceControllers[widget.index]!.text =
        '${double.parse(quotationController.unitPriceControllers[widget.index]!.text) + taxValue}';
    quotationController.unitPriceControllers[widget.index]!.text = double.parse(
      quotationController.unitPriceControllers[widget.index]!.text,
    ).toStringAsFixed(2);

    // qtyController.text = '1';
    quotationController.rowsInListViewInQuotation[widget
            .index]['item_unit_price'] =
        quotationController.unitPriceControllers[widget.index]!.text;
    quotationController.rowsInListViewInQuotation[widget.index]['itemName'] =
        quotationController.itemsNames[selectedItemId];
  }

  @override
  void initState() {
    if (widget.info.isNotEmpty) {
      qtyController.text = '${widget.info['item_quantity'] ?? '1'}';
      quantity = '${widget.info['item_quantity'] ?? '1'}';

      discountController.text = widget.info['item_discount'] ?? '0.0';
      discount = widget.info['item_discount'] ?? '0.0';

      totalLine = widget.info['item_total'] ?? '0';
      mainDescriptionVar = widget.info['item_description'] ?? '';
      mainCode = widget.info['item_main_code'] ?? '';
      descriptionController.text = widget.info['item_description'] ?? '';

      itemCodeController.text = widget.info['item_main_code'].toString();
      selectedItemId = widget.info['item_id'].toString();

      setPrice();
    } else {
      itemCodeController.text =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_main_code'];
      qtyController.text =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_quantity'];
      discountController.text =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_discount'];
      descriptionController.text =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_description'];
      totalLine =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_total'];
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuotationController>(
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
                      quotationController
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
                      cont.setEnteredQtyInQuotation(widget.index, quantity);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
                      cont.getTotalItems();
                    });
                    cont.setEnteredUnitPriceInQuotation(
                      widget.index,
                      cont.unitPriceControllers[widget.index]!.text,
                    );
                    cont.setItemIdInQuotation(widget.index, selectedItemId);
                    cont.setItemNameInQuotation(
                      widget.index,
                      itemName,
                      // value.split(" | ")[0],
                    ); // set only first element as name
                    cont.setMainCodeInQuotation(widget.index, mainCode);
                    cont.setTypeInQuotation(widget.index, '2');
                    cont.setMainDescriptionInQuotation(
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
                      cont.setMainDescriptionInQuotation(
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

                      cont.setEnteredQtyInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
                      cont.getTotalItems();
                    },
                  ),
                ),
                // unitPrice
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
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
                      cont.setEnteredUnitPriceInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
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
                        quotationController.quotationCounter += 1;
                      });
                      quotationController.incrementListViewLengthInQuotation(
                        quotationController.increment,
                      );
                      quotationController.addToRowsInListViewInQuotation(
                        quotationController.quotationCounter,
                        {
                          'line_type_id': '2',
                          'item_id': '',
                          'itemName': '',
                          'item_main_code': '',
                          'item_discount': '0',
                          'item_description': '',
                          'item_quantity': '1',
                          'item_unit_price': '0',
                          'item_total': '0',
                          'title': '',
                          'note': '',
                        },
                      );
                      quotationController.addToUnitPriceControllers(
                        quotationController.quotationCounter,
                      );
                      // Widget p = ReusableItemRow(
                      //   index: quotationController.quotationCounter,
                      //   info: {},
                      // );
                      // quotationController.addToOrderLinesInQuotationList(
                      //   '${quotationController.quotationCounter}',
                      //   p,
                      // );
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
                      cont.setEnteredDiscInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
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
                      cont.rowsInListViewInQuotation[widget
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
                      quotationController.decrementListViewLengthInQuotation(
                        quotationController.increment,
                      );
                      quotationController.removeFromRowsInListViewInQuotation(
                        widget.index,
                      );

                      // quotationController.removeFromOrderLinesInQuotationList(
                      //   (widget.index).toString(),
                      // );

                      setState(() {
                        cont.totalItems = 0.0;
                        cont.globalDisc = "0.0";
                        cont.globalDiscountPercentageValue = "0.0";
                        cont.specialDisc = "0.0";
                        cont.specialDiscountPercentageValue = "0.0";
                        cont.vat11 = "0.0";
                        cont.vatInPrimaryCurrency = "0.0";
                        cont.totalQuotation = "0.0";

                        cont.getTotalItems();
                      });
                      if (cont.rowsInListViewInQuotation != {}) {
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
  final QuotationController quotationController = Get.find();
  String titleValue = '0';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // titleController.text = widget.info['title'] ?? '';
    titleController.text =
        quotationController.rowsInListViewInQuotation[widget.index]['title'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuotationController>(
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
                      cont.setTypeInQuotation(widget.index, '1');
                      cont.setTitleInQuotation(widget.index, val);
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
                      quotationController.decrementListViewLengthInQuotation(
                        quotationController.increment,
                      );
                      quotationController.removeFromRowsInListViewInQuotation(
                        widget.index,
                      );
                      // quotationController.removeFromOrderLinesInQuotationList(
                      //   (widget.index).toString(),
                      // );
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
  final QuotationController quotationController = Get.find();
  String noteValue = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    noteController.text =
        quotationController.rowsInListViewInQuotation[widget.index]['note'];
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
                  quotationController.setTypeInQuotation(widget.index, '5');
                  quotationController.setNoteInQuotation(widget.index, val);
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
                    quotationController.decrementListViewLengthInQuotation(
                      quotationController.increment,
                    );
                    quotationController.removeFromRowsInListViewInQuotation(
                      widget.index,
                    );
                    // quotationController.removeFromOrderLinesInQuotationList(
                    //   widget.index.toString(),
                    // );
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
  final QuotationController quotationController = Get.find();
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
    quotationController.setImageInQuotation(widget.index, imageFile);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuotationController>(
      builder: (cont) {
        return Container(
          height: 100,
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GetBuilder<QuotationController>(
                  builder: (cont) {
                    return InkWell(
                      onTap: () async {
                        final image = await ImagePickerHelper.pickImage();
                        setState(() {
                          imageFile = image!;
                          cont.changeBoolVar(true);
                          cont.increaseImageSpace(30);
                        });
                        cont.setTypeInQuotation(widget.index, '4');
                        cont.setImageInQuotation(widget.index, imageFile);
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
                        quotationController.decrementListViewLengthInQuotation(
                          quotationController.increment + 50,
                        );
                        quotationController.removeFromRowsInListViewInQuotation(
                          widget.index,
                        );
                        // quotationController.removeFromOrderLinesInQuotationList(
                        //   widget.index.toString(),
                        // );
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

  final QuotationController quotationController = Get.find();
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
      (item) => item["currency"] == quotationController.selectedCurrencyName,
      orElse: () => null,
    );

    quotationController.exchangeRateForSelectedCurrency =
        result != null ? '${result["exchange_rate"]}' : '1';

    quotationController.combosPriceControllers[widget.index]!.text =
        '${widget.info['combo_price'] ?? ''}';

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
    quotationController.rowsInListViewInQuotation[widget
            .index]['item_unit_price'] =
        quotationController.combosPriceControllers[widget.index]!.text;
    quotationController.rowsInListViewInQuotation[widget.index]['item_total'] =
        '${widget.info['combo_total']}';
    quotationController.rowsInListViewInQuotation[widget.index]['combo'] =
        widget.info['combo_id'].toString();
  }

  @override
  void initState() {
    if (widget.info['combo_quantity'] != null) {
      qtyController.text =
          '${widget.info['combo_quantity'] ?? widget.info['item_quantity']}';
      quantity =
          '${widget.info['combo_quantity'] ?? widget.info['item_quantity']}';
      quotationController.rowsInListViewInQuotation[widget
              .index]['item_quantity'] =
          '${widget.info['combo_quantity'] ?? widget.info['item_quantity']}';

      discountController.text = widget.info['combo_discount'] ?? '';
      discount = widget.info['combo_discount'] ?? '0.0';
      quotationController.rowsInListViewInQuotation[widget
              .index]['item_discount'] =
          widget.info['combo_discount'] ?? '0.0';

      totalLine = widget.info['combo_total'] ?? '';
      mainDescriptionVar = widget.info['combo_description'] ?? '';

      mainCode = widget.info['combo_code'] ?? '';
      descriptionController.text = widget.info['combo_description'] ?? '';

      quotationController.rowsInListViewInQuotation[widget
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
      if (quotationController.rowsInListViewInQuotation[widget
              .index]['combo'] !=
          '') {
        quotationController.combosPriceControllers[widget.index]!.text =
            quotationController.rowsInListViewInQuotation[widget
                .index]['item_unit_price'];
        selectedComboId =
            quotationController.rowsInListViewInQuotation[widget
                .index]['combo'];
      }
      comboCodeController.text =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_main_code'];
      mainCode =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_main_code'];
      qtyController.text =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_quantity'];
      quantity =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_quantity'];
      discountController.text =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_discount'];
      discount =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_discount'];
      descriptionController.text =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_description'];
      mainDescriptionVar =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_description'];
      totalLine =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_total'];
      comboCodeController.text =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_main_code'];
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuotationController>(
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
                      quotationController
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
                      cont.setEnteredQtyInQuotation(widget.index, quantity);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
                      cont.getTotalItems();
                    });
                    cont.setEnteredUnitPriceInQuotation(
                      widget.index,
                      cont.combosPriceControllers[widget.index]!.text,
                    );
                    cont.setComboInQuotation(widget.index, selectedComboId);
                    cont.setItemNameInQuotation(
                      widget.index,
                      comboName,
                      // value.split(" | ")[0],
                    ); // set only first element as name
                    cont.setMainCodeInQuotation(widget.index, mainCode);
                    cont.setTypeInQuotation(widget.index, '3');
                    cont.setMainDescriptionInQuotation(
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
                      cont.setMainDescriptionInQuotation(
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

                      cont.setEnteredQtyInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
                      cont.getTotalItems();
                    },
                  ),
                ),
                // unitPrice
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
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
                      cont.setEnteredUnitPriceInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
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
                        quotationController.quotationCounter += 1;
                      });
                      quotationController.incrementListViewLengthInQuotation(
                        quotationController.increment,
                      );
                      quotationController.addToRowsInListViewInQuotation(
                        quotationController.quotationCounter,
                        {
                          'line_type_id': '3',
                          'item_id': '',
                          'itemName': '',
                          'item_main_code': '',
                          'item_discount': '0',
                          'item_description': '',
                          'item_quantity': '1',
                          'item_unit_price': '0',
                          'item_total': '0',
                          'title': '',
                          'note': '',
                          'combo': '',
                        },
                      );
                      quotationController.addToCombosPricesControllers(
                        quotationController.quotationCounter,
                      );
                      // Widget p = ReusableComboRow(
                      //   index: quotationController.quotationCounter,
                      //   info: {},
                      // );
                      // quotationController.addToOrderLinesInQuotationList(
                      //   '${quotationController.quotationCounter}',
                      //   p,
                      // );
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
                      cont.setEnteredDiscInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
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
                      cont.rowsInListViewInQuotation[widget
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
                      quotationController.decrementListViewLengthInQuotation(
                        quotationController.increment,
                      );
                      quotationController.removeFromRowsInListViewInQuotation(
                        widget.index,
                      );

                      // quotationController.removeFromOrderLinesInQuotationList(
                      //   (widget.index).toString(),
                      // );

                      setState(() {
                        cont.totalItems = 0.0;
                        cont.globalDisc = "0.0";
                        cont.globalDiscountPercentageValue = "0.0";
                        cont.specialDisc = "0.0";
                        cont.specialDiscountPercentageValue = "0.0";
                        cont.vat11 = "0.0";
                        cont.vatInPrimaryCurrency = "0.0";
                        cont.totalQuotation = "0.0";

                        cont.getTotalItems();
                      });
                      if (cont.rowsInListViewInQuotation != {}) {
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
