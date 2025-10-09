import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rooster_app/Controllers/payment_terms_controller.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Controllers/terms_and_conditions_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/Screens/Combo/combo.dart';
import 'package:rooster_app/Screens/Configuration/delivery_terms.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/create_product_dialog.dart';
import 'package:rooster_app/Screens/Quotations/print_quotation.dart';
import 'package:rooster_app/Widgets/dialog_title.dart';
import 'package:rooster_app/Widgets/loading.dart';
import 'package:rooster_app/const/functions.dart';
import 'package:rooster_app/const/urls.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Screens/Client/create_client_dialog.dart';
import 'package:rooster_app/Widgets/reusable_drop_down_menu.dart';
import 'package:rooster_app/Widgets/table_item.dart';
import '../../../Backend/Quotations/store_quotation.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Controllers/delivery_terms_controller.dart';
import '../../Locale_Memory/save_header_2_locally.dart';
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

class CreateNewQuotation extends StatefulWidget {
  const CreateNewQuotation({super.key});

  @override
  State<CreateNewQuotation> createState() => _CreateNewQuotationState();
}

class _CreateNewQuotationState extends State<CreateNewQuotation> {
  String selectedSalesPerson = '';
  int selectedSalesPersonId = 0;
  TextEditingController globalDiscPercentController = TextEditingController();
  TextEditingController specialDiscPercentController = TextEditingController();
  TextEditingController controller = TextEditingController();
  TextEditingController commissionController = TextEditingController();

  TextEditingController totalCommissionController = TextEditingController();
  TextEditingController refController = TextEditingController();
  TextEditingController deliveryTermsController = TextEditingController();
  TextEditingController chanceController = TextEditingController();
  TextEditingController validityController = TextEditingController();
  TextEditingController inputDateController = TextEditingController();
  TextEditingController clientNameController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  TextEditingController vatExemptController = TextEditingController();

  TextEditingController paymentTermsController = TextEditingController();
  TextEditingController termsAndConditionsMenuController =
      TextEditingController();
  TextEditingController priceConditionController = TextEditingController();
  TextEditingController priceListController = TextEditingController();
  TextEditingController salesPersonController = TextEditingController();

  TextEditingController termsAndConditionsController = TextEditingController();
  TextEditingController cashingMethodsController = TextEditingController();

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
  List tabsList = ['order_lines', 'other_information'];
  String selectedTab = 'order_lines'.tr;

  double listViewLength = Sizes.deviceHeight * 0.08;
  double increment = Sizes.deviceHeight * 0.08;

  bool isActiveVatChecked = false;
  bool isActiveDeliveredChecked = false;
  QuotationController quotationController = Get.find();
  HomeController homeController = Get.find();
  TermsAndConditionsController termsController = Get.find();
  PaymentTermsController paymentController = Get.find();
  DeliveryTermsController deliveryController = Get.find();
  ExchangeRatesController exchangeRatesController = Get.find();

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
      quotationController.currencyController.text = '';
    });
  }

  getCurrency() async {
    await exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();
    if (quotationController.currencyController.text.isEmpty) {
      quotationController.currencyController.text = 'USD';
      int index = exchangeRatesController.currenciesNamesList.indexOf('USD');
      quotationController.selectedCurrencyId =
          exchangeRatesController.currenciesIdsList[index];
      quotationController.selectedCurrencySymbol =
          exchangeRatesController.currenciesSymbolsList[index];
      quotationController.selectedCurrencyName = 'USD';
    }
    // var vat = await getCompanyVatFromPref();
    // quotationController.setCompanyVat(double.parse(vat));
    setVat();
    var companyCurrency = await getCompanyPrimaryCurrencyFromPref();
    var companyCurrencyLatestRate =
        await getPrimaryCurrencyLatestRateFromPref();
    quotationController.setCompanyPrimaryCurrency(companyCurrency);
    quotationController.setLatestRate(double.parse(companyCurrencyLatestRate));
  }

  setVat() async {
    if (quotationController.selectedHeaderIndex == 1) {
      var vat = await getCompanyVatFromPref();
      quotationController.setCompanyVat(double.parse(vat));
    } else {
      var vat = await getCompanyVat2FromPref();
      quotationController.setCompanyVat(double.parse(vat));
    }
  }

  checkVatExempt() async {
    if (quotationController.selectedHeaderIndex == 1) {
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
    } else {
      var companySubjectToVat = await getCompanySubjectToVat2FromPref();
      if (companySubjectToVat == '1') {
        vatExemptController.clear();
        quotationController.setIsVatExempted(false, false, false);
        quotationController.setIsVatExemptCheckBoxShouldAppear(true);
      } else {
        quotationController.setIsVatExemptCheckBoxShouldAppear(false);
        quotationController.setIsVatExempted(false, false, true);
        quotationController.setIsVatExemptChecked(true);
      }
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
    quotationController.setLogo(imageBytes);
  }

  late QuillController _controller;
  String? savedContent;

  void _saveContent() {
    final deltaJson = _controller.document.toDelta().toJson();
    final jsonString = jsonEncode(deltaJson);

    setState(() {
      savedContent = jsonString;
    });

    // You can now send `jsonString` to your backend
    termsAndConditionsController.text = jsonString;
  }

late bool isItHasTwoHeaders=false;
  checkIfItItHasTwoHeaders()async{
    var val=await getIsItHasMultiHeadersFromPref();
    isItHasTwoHeaders=(val=='1');
  }

  @override
  void initState() {
    checkIfItItHasTwoHeaders();
    quotationController.orderedKeys = [];
    quotationController.rowsInListViewInQuotation = {};
    quotationController.selectedHeaderIndex = 1;
    chanceController.text = chanceLevels[0];
    quotationController.quotationCounter = 0;
    _controller = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    generatePdfFromImageUrl();
    checkVatExempt();
    quotationController.isVatExemptChecked = false;
    // quotationController.newRowMap = {};
    quotationController.rowsInListViewInQuotation = {};
    quotationController.itemsMultiPartList = [];
    quotationController.salesPersonListNames = [];
    quotationController.salesPersonListId = [];
    quotationController.isBeforeVatPrices = true;
    priceConditionController.text = 'Prices are before vat';
    quotationController.getAllUsersSalesPersonFromBack();
    quotationController.getAllTaxationGroupsFromBack();
    setVars();
    quotationController.resetQuotation();
    quotationController.getFieldsForCreateQuotationFromBack();
    getCurrency();
    quotationController.listViewLengthInQuotation = 50;
    validityController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    inputDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    priceListController.text = 'STANDARD';
    paymentController.getPaymentTermsFromBack();
    deliveryController.getDeliveryTermsFromBack();
    termsController.getTermsAndConditionsFromBack();
    // getAllTermsAndConditions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GetBuilder<QuotationController>(
      builder: (quotationCont) {
        return quotationCont.isQuotationsInfoFetched
            ? Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              height: MediaQuery.of(context).size.height * 0.85,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [PageTitle(text: 'create_quotation'.tr)],
                    ),
                    gapH16,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            UnderTitleBtn(
                              text: 'preview'.tr,
                              onTap: () {
                                var itemTotal = 0.00;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      List itemsInfoPrint = [];
                                      for (var item
                                          in quotationCont
                                              .rowsInListViewInQuotation
                                              .values) {
                                        if ('${item['line_type_id']}' == '2') {
                                          var qty = item['item_quantity'];
                                          var map =
                                              quotationCont
                                                  .itemsMap[item['item_id']
                                                  .toString()];
                                          var itemName = map['item_name'];
                                          var itemPrice = double.parse(
                                            '${item['item_unit_price'] ?? 0.0}',
                                          );
                                          var itemDescription =
                                              item['item_description'];

                                          var itemImage =
                                              // '${map['images']}' != '[]'
                                              //     ? map['images'][0]
                                              //     : '';
                                              '${map['images']}' != '[]'
                                                  ? '$baseImage${map['images'][0]['img_url']}'
                                                  : '';
                                          // var firstBrandObject =
                                          //     map['itemGroups'].firstWhere(
                                          //       (obj) =>
                                          //           obj["root_name"]
                                          //               ?.toLowerCase() ==
                                          //           "brand".toLowerCase(),
                                          //       orElse: () => null,
                                          //     );
                                          // var brand =
                                          //     firstBrandObject == null
                                          //         ? ''
                                          //         : firstBrandObject['name'] ??
                                          //             '';
                                          var firstBrandObject =
                                              map['itemGroups'].firstWhere(
                                                (obj) =>
                                                    obj["root_name"]
                                                        ?.toLowerCase() ==
                                                    "brand".toLowerCase(),
                                                orElse: () => null,
                                              );
                                          var brand =
                                              firstBrandObject == null
                                                  ? ''
                                                  : firstBrandObject['name'] ??
                                                      '';
                                          itemTotal = double.parse(
                                            '${item['item_total']}',
                                          );
                                          // double.parse(qty) * itemPrice;
                                          var quotationItemInfo = {
                                            'line_type_id': '2',
                                            'item_name': itemName,
                                            'item_description': itemDescription,
                                            'item_quantity': qty,
                                            'item_unit_price':
                                                formatDoubleWithCommas(
                                                  itemPrice,
                                                ),
                                            'item_discount':
                                                item['item_discount'] ?? '0',
                                            'item_total':
                                                formatDoubleWithCommas(
                                                  itemTotal,
                                                ),
                                            'item_image': itemImage,
                                            'item_brand': brand,
                                            'combo_image': '',
                                            'combo_brand': '',
                                            'title': '',
                                            'isImageList': false,
                                            'note': '',
                                            'image': '',
                                          };
                                          itemsInfoPrint.add(quotationItemInfo);
                                        } else if ('${item['line_type_id']}' ==
                                            '3') {
                                          var qty = item['item_quantity'];
                                          // var map =
                                          //     quotationCont
                                          //         .combosMap[item['combo']
                                          //         .toString()];
                                          var ind = quotationCont.combosIdsList
                                              .indexOf(
                                                item['combo'].toString(),
                                              );
                                          var itemName =
                                              quotationCont
                                                  .combosNamesList[ind];
                                          var itemPrice = double.parse(
                                            '${item['item_unit_price'] ?? 0.0}',
                                          );
                                          var itemDescription =
                                              item['item_description'];
                                          var combosMap =
                                              quotationCont
                                                  .combosMap[item['combo']
                                                  .toString()];
                                          var comboImage =
                                              '${combosMap['image']}' != '' &&
                                                      combosMap['image'] !=
                                                          null &&
                                                      combosMap['image']
                                                          .isNotEmpty
                                                  ? '${combosMap['image']}'
                                                  : '';
                                          var comboBrand =
                                              combosMap['brand'] ?? '';

                                          itemTotal += double.parse(
                                            '${item['item_total']}',
                                          );
                                          // double.parse(qty) * itemPrice;
                                          var quotationItemInfo = {
                                            'line_type_id': '3',
                                            'item_name': itemName,
                                            'item_description': itemDescription,
                                            'item_quantity': qty,
                                            'item_unit_price':
                                                formatDoubleWithCommas(
                                                  itemPrice,
                                                ),
                                            'item_discount':
                                                item['item_discount'] ?? '0',
                                            'item_total':
                                                formatDoubleWithCommas(
                                                  itemTotal,
                                                ),
                                            'note': '',
                                            'item_image': '',
                                            'item_brand': '',
                                            'combo_image': comboImage,
                                            'combo_brand': comboBrand,
                                            'isImageList': false,
                                            'title': '',
                                            'image': '',
                                          };
                                          itemsInfoPrint.add(quotationItemInfo);
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
                                          itemsInfoPrint.add(quotationItemInfo);
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
                                          itemsInfoPrint.add(quotationItemInfo);
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
                                          itemsInfoPrint.add(quotationItemInfo);
                                        }
                                      }

                                      // _saveContent();
                                      final deltaJson =
                                          _controller.document
                                              .toDelta()
                                              .toJson();
                                      final jsonString = jsonEncode(deltaJson);
                                      savedContent = jsonString;
                                      termsAndConditionsController.text =
                                          jsonString;

                                      var terms =
                                          termsAndConditionsController.text ==
                                                  ' '
                                              ? ' '
                                              : termsAndConditionsController
                                                  .text;
                                      return PrintQuotationData(
                                        termsAndConditions:
                                            termsController
                                                .termsAndConditionsList[termsController
                                                .termsAndConditionsIdsList
                                                .indexOf(
                                                  quotationCont
                                                      .selectedTermAndConditionId,
                                                )],
                                        header: quotationCont.selectedHeader,
                                        isPrintedAs0:
                                            quotationCont.isPrintedAs0,
                                        isVatNoPrinted:
                                            quotationCont.isVatNoPrinted,
                                        isPrintedAsVatExempt:
                                            quotationCont.isPrintedAsVatExempt,
                                        isInQuotation: false,
                                        quotationNumber:
                                            quotationCont.quotationNumber,
                                        creationDate: validityController.text,
                                        vat: quotationCont.vat11,
                                        fromPage: 'createQuotation',
                                        ref: refController.text,
                                        receivedUser: '',
                                        senderUser: homeController.userName,
                                        status: '',
                                        cancellationReason: '',
                                        totalBeforeVat:
                                            quotationCont.totalItems.toString(),
                                        discountOnAllItem:
                                            quotationCont.preGlobalDisc
                                                .toString(),
                                        totalAllItems: formatDoubleWithCommas(
                                          quotationCont.totalItems,
                                        ),
                                        globalDiscount:
                                            globalDiscPercentController.text,
                                        //widget.info['globalDiscount'] ?? '0',
                                        totalPriceAfterDiscount:
                                            quotationCont.preGlobalDisc == 0.0
                                                ? formatDoubleWithCommas(
                                                  quotationCont.totalItems,
                                                )
                                                : formatDoubleWithCommas(
                                                  quotationCont
                                                      .totalAfterGlobalDis,
                                                ),
                                        additionalSpecialDiscount: quotationCont
                                            .preSpecialDisc
                                            .toStringAsFixed(2),
                                        totalPriceAfterSpecialDiscount:
                                            quotationCont.preSpecialDisc == 0
                                                ? formatDoubleWithCommas(
                                                  quotationCont.totalItems,
                                                )
                                                : formatDoubleWithCommas(
                                                  quotationCont
                                                      .totalAfterGlobalSpecialDis,
                                                ),
                                        totalPriceAfterSpecialDiscountByQuotationCurrency:
                                            quotationCont.preSpecialDisc == 0
                                                ? formatDoubleWithCommas(
                                                  quotationCont.totalItems,
                                                )
                                                : formatDoubleWithCommas(
                                                  quotationCont
                                                      .totalAfterGlobalSpecialDis,
                                                ),

                                        vatByQuotationCurrency:
                                            formatDoubleWithCommas(
                                              double.parse(quotationCont.vat11),
                                            ),
                                        finalPriceByQuotationCurrency:
                                            formatDoubleWithCommas(
                                              double.parse(
                                                quotationCont.totalQuotation,
                                              ),
                                            ),

                                        specialDisc: specialDisc.toString(),
                                        specialDiscount:
                                            specialDiscPercentController.text,
                                        specialDiscountAmount:
                                            quotationCont.specialDisc,
                                        salesPerson: selectedSalesPerson,
                                        quotationCurrency:
                                            quotationCont.selectedCurrencyName,
                                        quotationCurrencySymbol:
                                            quotationCont
                                                .selectedCurrencySymbol,
                                        quotationCurrencyLatestRate:
                                            quotationCont
                                                .exchangeRateForSelectedCurrency,
                                        clientPhoneNumber:
                                            quotationCont
                                                .phoneNumber[selectedCustomerIds] ??
                                            '---',
                                        clientName: clientNameController.text,
                                        termsAndConditionsNote: terms,
                                        itemsInfoPrint: itemsInfoPrint,
                                      );
                                    },
                                  ),
                                );
                                // }
                              },
                            ),
                            UnderTitleBtn(
                              text: 'submit_and_preview'.tr,
                              onTap: () async {
                                bool hasType1WithEmptyTitle =
                                    quotationController
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
                                bool hasType4WithEmptyImage =
                                    quotationController
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
                                  _saveContent();
                                  var res = await storeQuotations(
                                    refController.text,
                                    selectedCustomerIds,
                                    validityController.text,
                                    inputDateController.text,
                                    quotationCont.selectedPaymentTermId,
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
                                    quotationController
                                        .rowsInListViewInQuotation,
                                    // quotationController.newRowMap,
                                    quotationCont.orderedKeys,
                                    titleController.text,
                                    deliveryTermsController.text,
                                    chanceController.text,
                                   isItHasTwoHeaders
                                        ? quotationCont
                                            .headersList[quotationCont
                                                    .selectedHeaderIndex -
                                                1]['id']
                                            .toString()
                                        : '',
                                    quotationCont.selectedTermAndConditionId,
                                  );
                                  if (res['success'] == true) {
                                    CommonWidgets.snackBar(
                                      'Success',
                                      res['message'],
                                    );
                                    homeController.selectedTab.value =
                                        'pending_quotation';
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          var itemTotal = 0.00;
                                          List itemsInfoPrint = [];
                                          for (var item
                                              in quotationCont
                                                  .rowsInListViewInQuotation
                                                  .values) {
                                            if ('${item['line_type_id']}' ==
                                                '2') {
                                              var qty = item['item_quantity'];
                                              var map =
                                                  quotationCont
                                                      .itemsMap[item['item_id']
                                                      .toString()];
                                              var itemName = map['item_name'];
                                              var itemPrice = double.parse(
                                                '${item['item_unit_price'] ?? 0.0}',
                                              );
                                              var itemDescription =
                                                  item['item_description'];

                                              var itemImage =
                                                  '${map['images']}' != '[]'
                                                      ? map['images'][0]['img_url']
                                                      : '';
                                              var firstBrandObject =
                                                  map['itemGroups'].firstWhere(
                                                    (obj) =>
                                                        obj["root_name"]
                                                            ?.toLowerCase() ==
                                                        "brand".toLowerCase(),
                                                    orElse: () => null,
                                                  );
                                              var brand =
                                                  firstBrandObject == null
                                                      ? ''
                                                      : firstBrandObject['name'] ??
                                                          '';
                                              itemTotal = double.parse(
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
                                              var qty = item['item_quantity'];
                                              // var map =
                                              // quotationCont
                                              //     .combosMap[item['combo']
                                              //     .toString()];
                                              var ind = quotationCont
                                                  .combosIdsList
                                                  .indexOf(
                                                    item['combo'].toString(),
                                                  );
                                              var itemName =
                                                  quotationCont
                                                      .combosNamesList[ind];
                                              var itemPrice = double.parse(
                                                '${item['item_unit_price'] ?? 0.0}',
                                              );
                                              var itemDescription =
                                                  item['item_description'];

                                              var combosMap =
                                                  quotationCont
                                                      .combosMap[item['combo']
                                                      .toString()];
                                              var comboImage =
                                                  '${combosMap['image']}' !=
                                                              '' &&
                                                          combosMap['image'] !=
                                                              null &&
                                                          combosMap['image']
                                                              .isNotEmpty
                                                      ? '${combosMap['image']}'
                                                      : '';

                                              var comboBrand =
                                                  combosMap['brand'] ?? '';

                                              itemTotal += double.parse(
                                                '${item['item_total']}',
                                              );

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
                                                'combo_brand': comboBrand,
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

                                          return PrintQuotationData(
                                            termsAndConditions:
                                                quotationCont
                                                        .selectedTermAndConditionId
                                                        .isNotEmpty
                                                    ? termsController
                                                        .termsAndConditionsTextsList[termsController
                                                        .termsAndConditionsIdsList
                                                        .indexOf(
                                                          quotationCont
                                                              .selectedTermAndConditionId,
                                                        )]
                                                    : '',
                                            header:
                                                quotationCont.selectedHeader,
                                            isPrintedAs0:
                                                quotationCont.isPrintedAs0,
                                            isVatNoPrinted:
                                                quotationCont.isVatNoPrinted,
                                            isPrintedAsVatExempt:
                                                quotationCont
                                                    .isPrintedAsVatExempt,
                                            isInQuotation: false,
                                            quotationNumber:
                                                quotationCont.quotationNumber,
                                            creationDate:
                                                validityController.text,
                                            vat: quotationCont.vat11,
                                            fromPage: 'createQuotation',
                                            ref: refController.text,
                                            receivedUser: '',
                                            senderUser: homeController.userName,
                                            cancellationReason: '',
                                            status: '',
                                            totalBeforeVat:
                                                quotationCont.totalItems
                                                    .toString(),
                                            discountOnAllItem:
                                                quotationCont.preGlobalDisc
                                                    .toString(),
                                            totalAllItems:
                                                formatDoubleWithCommas(
                                                  quotationCont.totalItems,
                                                ),
                                            globalDiscount:
                                                globalDiscPercentController
                                                    .text,

                                            //widget.info['globalDiscount'] ?? '0',
                                            totalPriceAfterDiscount:
                                                quotationCont.preGlobalDisc ==
                                                        0.0
                                                    ? formatDoubleWithCommas(
                                                      quotationCont.totalItems,
                                                    )
                                                    : formatDoubleWithCommas(
                                                      quotationCont
                                                          .totalAfterGlobalDis,
                                                    ),
                                            additionalSpecialDiscount:
                                                quotationCont.preSpecialDisc
                                                    .toStringAsFixed(2),
                                            totalPriceAfterSpecialDiscount:
                                                quotationCont.preSpecialDisc ==
                                                        0
                                                    ? formatDoubleWithCommas(
                                                      quotationCont.totalItems,
                                                    )
                                                    : formatDoubleWithCommas(
                                                      quotationCont
                                                          .totalAfterGlobalSpecialDis,
                                                    ),
                                            totalPriceAfterSpecialDiscountByQuotationCurrency:
                                                quotationCont.preSpecialDisc ==
                                                        0
                                                    ? formatDoubleWithCommas(
                                                      quotationCont.totalItems,
                                                    )
                                                    : formatDoubleWithCommas(
                                                      quotationCont
                                                          .totalAfterGlobalSpecialDis,
                                                    ),

                                            vatByQuotationCurrency:
                                                formatDoubleWithCommas(
                                                  double.parse(
                                                    quotationCont.vat11,
                                                  ),
                                                ),
                                            finalPriceByQuotationCurrency:
                                                formatDoubleWithCommas(
                                                  double.parse(
                                                    quotationCont
                                                        .totalQuotation,
                                                  ),
                                                ),
                                            specialDisc: specialDisc.toString(),
                                            specialDiscount:
                                                specialDiscPercentController
                                                    .text,
                                            specialDiscountAmount:
                                                quotationCont.specialDisc,
                                            salesPerson: selectedSalesPerson,
                                            quotationCurrency:
                                                quotationCont
                                                    .selectedCurrencyName,
                                            quotationCurrencySymbol:
                                                quotationCont
                                                    .selectedCurrencySymbol,
                                            quotationCurrencyLatestRate:
                                                quotationCont
                                                    .exchangeRateForSelectedCurrency,
                                            clientPhoneNumber:
                                                quotationCont
                                                    .phoneNumber[selectedCustomerIds] ??
                                                '---',
                                            clientName:
                                                clientNameController.text,
                                            termsAndConditionsNote:
                                                termsAndConditionsController
                                                    .text,
                                            itemsInfoPrint: itemsInfoPrint,
                                          );
                                        },
                                      ),
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
                            // UnderTitleBtn(
                            //   text: 'send_by_email'.tr,
                            //   onTap: () {
                            //     if (progressVar == 0) {
                            //       setState(() {
                            //         progressVar += 1;
                            //       });
                            //     }
                            //   },
                            // ),
                            // UnderTitleBtn(
                            //   text: 'confirm'.tr,
                            //   onTap: () {
                            //     if (progressVar == 1) {
                            //       setState(() {
                            //         progressVar += 1;
                            //       });
                            //     }
                            //   },
                            // ),
                            // UnderTitleBtn(
                            //   text: 'cancel'.tr,
                            //   onTap: () {
                            //     setState(() {
                            //       progressVar = 0;
                            //     });
                            //   },
                            // ),
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
                    // gapH10,
                    isItHasTwoHeaders
                        ? Column(
                      children: [
                        gapH10,
                        ReusableRadioBtns(
                          isRow: true,
                          groupVal: quotationCont.selectedHeaderIndex,
                          title1:
                          quotationCont
                              .headersList[0]['header_name'],
                          title2:
                          quotationCont
                              .headersList[1]['header_name'],
                          func: (value) {
                            if (value == 1) {
                              quotationCont.setSelectedHeaderIndex(1);
                              quotationCont.setSelectedHeader(
                                quotationCont.headersList[0],
                              );
                              quotationCont.setQuotationCurrency(
                                quotationCont.headersList[0],
                              );
                            } else {
                              quotationCont.setSelectedHeaderIndex(2);
                              quotationCont.setSelectedHeader(
                                quotationCont.headersList[1],
                              );
                              quotationCont.setQuotationCurrency(
                                quotationCont.headersList[1],
                              );
                            }
                            setVat();
                            checkVatExempt();
                          },
                          width1:
                          MediaQuery.of(context).size.width *
                              0.15,
                          width2:
                          MediaQuery.of(context).size.width *
                              0.15,
                        ),
                      ],
                    )
                        : SizedBox.shrink(),
                    gapH10,
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
                          Obx(
                            () =>
                                screenWidth > 1250
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          quotationCont.quotationNumber,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: TypographyColor.titleTable,
                                          ),
                                        ),
                                        ReusableReferenceTextField(
                                          type: 'quotations',
                                          textEditingController: refController,
                                          rowWidth:
                                              homeController.isOpened.value
                                                  ? MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.12
                                                  : MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.15,
                                          textFieldWidth:
                                              homeController.isOpened.value
                                                  ? MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.09
                                                  : MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.13,
                                        ),
                                        // DialogTextField(
                                        //   textEditingController: refController,
                                        //   text: '${'ref'.tr}:',
                                        //   hint: 'manual_reference'.tr,
                                        //   rowWidth:
                                        //       homeController.isOpened.value
                                        //           ? MediaQuery.of(
                                        //                 context,
                                        //               ).size.width *
                                        //               0.12
                                        //           : MediaQuery.of(
                                        //                 context,
                                        //               ).size.width *
                                        //               0.15,
                                        //   textFieldWidth:
                                        //       homeController.isOpened.value
                                        //           ? MediaQuery.of(
                                        //                 context,
                                        //               ).size.width *
                                        //               0.09
                                        //           : MediaQuery.of(
                                        //                 context,
                                        //               ).size.width *
                                        //               0.13,
                                        //   validationFunc: (val) {},
                                        //   onChangedFunc: (val){
                                        //   },
                                        // ),
                                        SizedBox(
                                          width:
                                              homeController.isOpened.value
                                                  ? MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.12
                                                  : MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.14,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('currency'.tr),
                                              GetBuilder<
                                                ExchangeRatesController
                                              >(
                                                builder: (cont) {
                                                  return cont
                                                          .isExchangeRatesFetched
                                                      ?
                                                      //   CustomSearchableDropdown(hint: '',width:  homeController.isOpened.value? MediaQuery.of(context).size.width * 0.07:
                                                      //   MediaQuery.of(context).size.width * 0.1, items: cont.currenciesNamesList, onSelected: (String? val) {
                                                      //   setState(() {
                                                      //     selectedCurrency = val!;
                                                      //     var index = cont
                                                      //         .currenciesNamesList
                                                      //         .indexOf(val);
                                                      //     quotationCont.setSelectedCurrency(
                                                      //       cont.currenciesIdsList[index],
                                                      //       val,
                                                      //     );
                                                      //     quotationCont
                                                      //         .setSelectedCurrencySymbol(
                                                      //       cont.currenciesSymbolsList[index],
                                                      //     );
                                                      //     var matchedItems =
                                                      //     exchangeRatesController
                                                      //         .exchangeRatesList
                                                      //         .where(
                                                      //           (item) =>
                                                      //       item["currency"] ==
                                                      //           val,
                                                      //     );
                                                      //
                                                      //     var result =
                                                      //     matchedItems.isNotEmpty
                                                      //         ? matchedItems.reduce(
                                                      //           (a, b) =>
                                                      //       DateTime.parse(
                                                      //         a["start_date"],
                                                      //       ).isAfter(
                                                      //         DateTime.parse(
                                                      //           b["start_date"],
                                                      //         ),
                                                      //       )
                                                      //           ? a
                                                      //           : b,
                                                      //     )
                                                      //         : null;
                                                      //     quotationCont
                                                      //         .setExchangeRateForSelectedCurrency(
                                                      //       result != null
                                                      //           ? '${result["exchange_rate"]}'
                                                      //           : '1',
                                                      //     );
                                                      //   });
                                                      //   var keys =
                                                      //   quotationCont
                                                      //       .unitPriceControllers
                                                      //       .keys
                                                      //       .toList();
                                                      //   for (
                                                      //   int i = 0;
                                                      //   i <
                                                      //       quotationCont
                                                      //           .unitPriceControllers
                                                      //           .length;
                                                      //   i++
                                                      //   ) {
                                                      //     var selectedItemId =
                                                      //         '${quotationCont.rowsInListViewInQuotation[keys[i]]['item_id']}';
                                                      //     if (selectedItemId != '') {
                                                      //       if (quotationCont
                                                      //           .itemsPricesCurrencies[selectedItemId] ==
                                                      //           val) {
                                                      //         quotationCont
                                                      //             .unitPriceControllers[keys[i]]!
                                                      //             .text = quotationCont
                                                      //             .itemUnitPrice[selectedItemId]
                                                      //             .toString();
                                                      //       } else if (quotationCont
                                                      //           .selectedCurrencyName ==
                                                      //           'USD' &&
                                                      //           quotationCont
                                                      //               .itemsPricesCurrencies[selectedItemId] !=
                                                      //               val) {
                                                      //         var matchedItems =
                                                      //         exchangeRatesController
                                                      //             .exchangeRatesList
                                                      //             .where(
                                                      //               (item) =>
                                                      //           item["currency"] ==
                                                      //               quotationCont
                                                      //                   .itemsPricesCurrencies[selectedItemId],
                                                      //         );
                                                      //
                                                      //         var result =
                                                      //         matchedItems.isNotEmpty
                                                      //             ? matchedItems.reduce(
                                                      //               (a, b) =>
                                                      //           DateTime.parse(
                                                      //             a["start_date"],
                                                      //           ).isAfter(
                                                      //             DateTime.parse(
                                                      //               b["start_date"],
                                                      //             ),
                                                      //           )
                                                      //               ? a
                                                      //               : b,
                                                      //         )
                                                      //             : null;
                                                      //         var divider = '1';
                                                      //         if (result != null) {
                                                      //           divider =
                                                      //               result["exchange_rate"]
                                                      //                   .toString();
                                                      //         }
                                                      //         quotationCont
                                                      //             .unitPriceControllers[keys[i]]!
                                                      //             .text =
                                                      //         '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                      //       } else if (quotationCont
                                                      //           .selectedCurrencyName !=
                                                      //           'USD' &&
                                                      //           quotationCont
                                                      //               .itemsPricesCurrencies[selectedItemId] ==
                                                      //               'USD') {
                                                      //         quotationCont
                                                      //             .unitPriceControllers[keys[i]]!
                                                      //             .text =
                                                      //         '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                      //       } else {
                                                      //         var matchedItems =
                                                      //         exchangeRatesController
                                                      //             .exchangeRatesList
                                                      //             .where(
                                                      //               (item) =>
                                                      //           item["currency"] ==
                                                      //               quotationCont
                                                      //                   .itemsPricesCurrencies[selectedItemId],
                                                      //         );
                                                      //
                                                      //         var result =
                                                      //         matchedItems.isNotEmpty
                                                      //             ? matchedItems.reduce(
                                                      //               (a, b) =>
                                                      //           DateTime.parse(
                                                      //             a["start_date"],
                                                      //           ).isAfter(
                                                      //             DateTime.parse(
                                                      //               b["start_date"],
                                                      //             ),
                                                      //           )
                                                      //               ? a
                                                      //               : b,
                                                      //         )
                                                      //             : null;
                                                      //         var divider = '1';
                                                      //         if (result != null) {
                                                      //           divider =
                                                      //               result["exchange_rate"]
                                                      //                   .toString();
                                                      //         }
                                                      //         var usdPrice =
                                                      //             '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                      //         quotationCont
                                                      //             .unitPriceControllers[keys[i]]!
                                                      //             .text =
                                                      //         '${double.parse('${(double.parse(usdPrice) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                      //       }
                                                      //       if (!quotationCont
                                                      //           .isBeforeVatPrices) {
                                                      //         var taxRate =
                                                      //             double.parse(
                                                      //               quotationCont
                                                      //                   .itemsVats[selectedItemId],
                                                      //             ) /
                                                      //                 100.0;
                                                      //         var taxValue =
                                                      //             taxRate *
                                                      //                 double.parse(
                                                      //                   quotationCont
                                                      //                       .unitPriceControllers[keys[i]]!
                                                      //                       .text,
                                                      //                 );
                                                      //
                                                      //         quotationCont
                                                      //             .unitPriceControllers[keys[i]]!
                                                      //             .text =
                                                      //         '${double.parse(quotationCont.unitPriceControllers[keys[i]]!.text) + taxValue}';
                                                      //       }
                                                      //       quotationCont
                                                      //           .unitPriceControllers[keys[i]]!
                                                      //           .text = double.parse(
                                                      //         quotationCont
                                                      //             .unitPriceControllers[keys[i]]!
                                                      //             .text,
                                                      //       ).toStringAsFixed(2);
                                                      //       var totalLine =
                                                      //           '${(int.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_quantity']) * double.parse(quotationCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';
                                                      //
                                                      //       quotationCont
                                                      //           .setEnteredUnitPriceInQuotation(
                                                      //         keys[i],
                                                      //         quotationCont
                                                      //             .unitPriceControllers[keys[i]]!
                                                      //             .text,
                                                      //       );
                                                      //       quotationCont
                                                      //           .setMainTotalInQuotation(
                                                      //         keys[i],
                                                      //         totalLine,
                                                      //       );
                                                      //       quotationCont.getTotalItems();
                                                      //     }
                                                      //   }
                                                      //   var comboKeys =
                                                      //   quotationCont
                                                      //       .combosPriceControllers
                                                      //       .keys
                                                      //       .toList();
                                                      //   for (
                                                      //   int i = 0;
                                                      //   i <
                                                      //       quotationCont
                                                      //           .combosPriceControllers
                                                      //           .length;
                                                      //   i++
                                                      //   ) {
                                                      //     var selectedComboId =
                                                      //         '${quotationCont.rowsInListViewInQuotation[comboKeys[i]]['combo']}';
                                                      //     if (selectedComboId != '') {
                                                      //       var ind = quotationCont
                                                      //           .combosIdsList
                                                      //           .indexOf(selectedComboId);
                                                      //       if (quotationCont
                                                      //           .combosPricesCurrencies[selectedComboId] ==
                                                      //           quotationCont
                                                      //               .selectedCurrencyName) {
                                                      //         quotationCont
                                                      //             .combosPriceControllers[comboKeys[i]]!
                                                      //             .text = quotationCont
                                                      //             .combosPricesList[ind]
                                                      //             .toString();
                                                      //       } else if (quotationCont
                                                      //           .selectedCurrencyName ==
                                                      //           'USD' &&
                                                      //           quotationCont
                                                      //               .combosPricesCurrencies[selectedComboId] !=
                                                      //               quotationCont
                                                      //                   .selectedCurrencyName) {
                                                      //         var matchedItems =
                                                      //         exchangeRatesController
                                                      //             .exchangeRatesList
                                                      //             .where(
                                                      //               (item) =>
                                                      //           item["currency"] ==
                                                      //               quotationCont
                                                      //                   .combosPricesCurrencies[selectedComboId],
                                                      //         );
                                                      //
                                                      //         var result =
                                                      //         matchedItems.isNotEmpty
                                                      //             ? matchedItems.reduce(
                                                      //               (a, b) =>
                                                      //           DateTime.parse(
                                                      //             a["start_date"],
                                                      //           ).isAfter(
                                                      //             DateTime.parse(
                                                      //               b["start_date"],
                                                      //             ),
                                                      //           )
                                                      //               ? a
                                                      //               : b,
                                                      //         )
                                                      //             : null;
                                                      //         var divider = '1';
                                                      //         if (result != null) {
                                                      //           divider =
                                                      //               result["exchange_rate"]
                                                      //                   .toString();
                                                      //         }
                                                      //         quotationCont
                                                      //             .combosPriceControllers[comboKeys[i]]!
                                                      //             .text =
                                                      //         '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                      //       } else if (quotationCont
                                                      //           .selectedCurrencyName !=
                                                      //           'USD' &&
                                                      //           quotationCont
                                                      //               .combosPricesCurrencies[selectedComboId] ==
                                                      //               'USD') {
                                                      //         quotationCont
                                                      //             .combosPriceControllers[comboKeys[i]]!
                                                      //             .text =
                                                      //         '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                      //       } else {
                                                      //         var matchedItems =
                                                      //         exchangeRatesController
                                                      //             .exchangeRatesList
                                                      //             .where(
                                                      //               (item) =>
                                                      //           item["currency"] ==
                                                      //               quotationCont
                                                      //                   .combosPricesCurrencies[selectedComboId],
                                                      //         );
                                                      //
                                                      //         var result =
                                                      //         matchedItems.isNotEmpty
                                                      //             ? matchedItems.reduce(
                                                      //               (a, b) =>
                                                      //           DateTime.parse(
                                                      //             a["start_date"],
                                                      //           ).isAfter(
                                                      //             DateTime.parse(
                                                      //               b["start_date"],
                                                      //             ),
                                                      //           )
                                                      //               ? a
                                                      //               : b,
                                                      //         )
                                                      //             : null;
                                                      //         var divider = '1';
                                                      //         if (result != null) {
                                                      //           divider =
                                                      //               result["exchange_rate"]
                                                      //                   .toString();
                                                      //         }
                                                      //         var usdPrice =
                                                      //             '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                      //         quotationCont
                                                      //             .combosPriceControllers[comboKeys[i]]!
                                                      //             .text =
                                                      //         '${double.parse('${(double.parse(usdPrice) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                      //       }
                                                      //       quotationCont
                                                      //           .combosPriceControllers[comboKeys[i]]!
                                                      //           .text =
                                                      //       '${double.parse(quotationCont.combosPriceControllers[comboKeys[i]]!.text)}';
                                                      //
                                                      //       quotationCont
                                                      //           .combosPriceControllers[comboKeys[i]]!
                                                      //           .text = double.parse(
                                                      //         quotationCont
                                                      //             .combosPriceControllers[comboKeys[i]]!
                                                      //             .text,
                                                      //       ).toStringAsFixed(2);
                                                      //       var totalLine =
                                                      //           '${(int.parse(quotationCont.rowsInListViewInQuotation[comboKeys[i]]['item_quantity']) * double.parse(quotationCont.combosPriceControllers[comboKeys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';
                                                      //       quotationCont
                                                      //           .setEnteredQtyInQuotation(
                                                      //         comboKeys[i],
                                                      //         quotationCont
                                                      //             .rowsInListViewInQuotation[comboKeys[i]]['item_quantity'],
                                                      //       );
                                                      //       quotationCont
                                                      //           .setMainTotalInQuotation(
                                                      //         comboKeys[i],
                                                      //         totalLine,
                                                      //       );
                                                      //       // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
                                                      //       quotationCont.getTotalItems();
                                                      //
                                                      //       quotationCont
                                                      //           .setEnteredUnitPriceInQuotation(
                                                      //         comboKeys[i],
                                                      //         quotationCont
                                                      //             .combosPriceControllers[comboKeys[i]]!
                                                      //             .text,
                                                      //       );
                                                      //       quotationCont
                                                      //           .setMainTotalInQuotation(
                                                      //         comboKeys[i],
                                                      //         totalLine,
                                                      //       );
                                                      //       quotationCont.getTotalItems();
                                                      //     }
                                                      //   }
                                                      // });
                                                      DropdownMenu<String>(
                                                        width:
                                                            homeController
                                                                    .isOpened
                                                                    .value
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
                                                        controller:
                                                            quotationCont
                                                                .currencyController,
                                                        hintText: '',
                                                        textStyle:
                                                            const TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                        inputDecorationTheme: InputDecorationTheme(
                                                          isDense: true,
                                                          // filled: true,
                                                          hintStyle:
                                                              const TextStyle(
                                                                fontSize: 12,
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
                                                            cont.currenciesNamesList.map<
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
                                                          setState(() {
                                                            selectedCurrency =
                                                                val!;
                                                            var index = cont
                                                                .currenciesNamesList
                                                                .indexOf(val);
                                                            quotationCont
                                                                .setSelectedCurrency(
                                                                  cont.currenciesIdsList[index],
                                                                  val,
                                                                );
                                                            quotationCont
                                                                .setSelectedCurrencySymbol(
                                                                  cont.currenciesSymbolsList[index],
                                                                );
                                                            var matchedItems =
                                                                exchangeRatesController
                                                                    .exchangeRatesList
                                                                    .where(
                                                                      (item) =>
                                                                          item["currency"] ==
                                                                          val,
                                                                    );

                                                            var result =
                                                                matchedItems
                                                                        .isNotEmpty
                                                                    ? matchedItems.reduce(
                                                                      (a, b) =>
                                                                          DateTime.parse(
                                                                                a["start_date"],
                                                                              ).isAfter(
                                                                                DateTime.parse(
                                                                                  b["start_date"],
                                                                                ),
                                                                              )
                                                                              ? a
                                                                              : b,
                                                                    )
                                                                    : null;

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
                                                            if (selectedItemId !=
                                                                '') {
                                                              if (quotationCont
                                                                      .itemsPricesCurrencies[selectedItemId] ==
                                                                  val) {
                                                                quotationCont
                                                                        .unitPriceControllers[keys[i]]!
                                                                        .text =
                                                                    quotationCont
                                                                        .itemUnitPrice[selectedItemId]
                                                                        .toString();
                                                              } else if (quotationCont
                                                                          .selectedCurrencyName ==
                                                                      'USD' &&
                                                                  quotationCont
                                                                          .itemsPricesCurrencies[selectedItemId] !=
                                                                      val) {
                                                                var matchedItems = exchangeRatesController
                                                                    .exchangeRatesList
                                                                    .where(
                                                                      (item) =>
                                                                          item["currency"] ==
                                                                          quotationCont
                                                                              .itemsPricesCurrencies[selectedItemId],
                                                                    );

                                                                var result =
                                                                    matchedItems
                                                                            .isNotEmpty
                                                                        ? matchedItems.reduce(
                                                                          (
                                                                            a,
                                                                            b,
                                                                          ) =>
                                                                              DateTime.parse(
                                                                                    a["start_date"],
                                                                                  ).isAfter(
                                                                                    DateTime.parse(
                                                                                      b["start_date"],
                                                                                    ),
                                                                                  )
                                                                                  ? a
                                                                                  : b,
                                                                        )
                                                                        : null;
                                                                var divider =
                                                                    '1';
                                                                if (result !=
                                                                    null) {
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
                                                                var matchedItems = exchangeRatesController
                                                                    .exchangeRatesList
                                                                    .where(
                                                                      (item) =>
                                                                          item["currency"] ==
                                                                          quotationCont
                                                                              .itemsPricesCurrencies[selectedItemId],
                                                                    );

                                                                var result =
                                                                    matchedItems
                                                                            .isNotEmpty
                                                                        ? matchedItems.reduce(
                                                                          (
                                                                            a,
                                                                            b,
                                                                          ) =>
                                                                              DateTime.parse(
                                                                                    a["start_date"],
                                                                                  ).isAfter(
                                                                                    DateTime.parse(
                                                                                      b["start_date"],
                                                                                    ),
                                                                                  )
                                                                                  ? a
                                                                                  : b,
                                                                        )
                                                                        : null;
                                                                var divider =
                                                                    '1';
                                                                if (result !=
                                                                    null) {
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
                                                              ).toStringAsFixed(
                                                                2,
                                                              );
                                                              var totalLine =
                                                                  '${(int.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_quantity']) * double.parse(quotationCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';

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
                                                              quotationCont
                                                                  .getTotalItems();
                                                            }
                                                          }

                                                          var comboKeys =
                                                              quotationCont
                                                                  .combosPriceControllers
                                                                  .keys
                                                                  .toList();
                                                          for (
                                                            int i = 0;
                                                            i <
                                                                quotationCont
                                                                    .combosPriceControllers
                                                                    .length;
                                                            i++
                                                          ) {
                                                            var selectedComboId =
                                                                '${quotationCont.rowsInListViewInQuotation[comboKeys[i]]['combo']}';
                                                            if (selectedComboId !=
                                                                '') {
                                                              var ind = quotationCont
                                                                  .combosIdsList
                                                                  .indexOf(
                                                                    selectedComboId,
                                                                  );
                                                              if (quotationCont
                                                                      .combosPricesCurrencies[selectedComboId] ==
                                                                  quotationCont
                                                                      .selectedCurrencyName) {
                                                                quotationCont
                                                                        .combosPriceControllers[comboKeys[i]]!
                                                                        .text =
                                                                    quotationCont
                                                                        .combosPricesList[ind]
                                                                        .toString();
                                                              } else if (quotationCont
                                                                          .selectedCurrencyName ==
                                                                      'USD' &&
                                                                  quotationCont
                                                                          .combosPricesCurrencies[selectedComboId] !=
                                                                      quotationCont
                                                                          .selectedCurrencyName) {
                                                                var matchedItems = exchangeRatesController
                                                                    .exchangeRatesList
                                                                    .where(
                                                                      (item) =>
                                                                          item["currency"] ==
                                                                          quotationCont
                                                                              .combosPricesCurrencies[selectedComboId],
                                                                    );

                                                                var result =
                                                                    matchedItems
                                                                            .isNotEmpty
                                                                        ? matchedItems.reduce(
                                                                          (
                                                                            a,
                                                                            b,
                                                                          ) =>
                                                                              DateTime.parse(
                                                                                    a["start_date"],
                                                                                  ).isAfter(
                                                                                    DateTime.parse(
                                                                                      b["start_date"],
                                                                                    ),
                                                                                  )
                                                                                  ? a
                                                                                  : b,
                                                                        )
                                                                        : null;
                                                                var divider =
                                                                    '1';
                                                                if (result !=
                                                                    null) {
                                                                  divider =
                                                                      result["exchange_rate"]
                                                                          .toString();
                                                                }
                                                                quotationCont
                                                                        .combosPriceControllers[comboKeys[i]]!
                                                                        .text =
                                                                    '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                              } else if (quotationCont
                                                                          .selectedCurrencyName !=
                                                                      'USD' &&
                                                                  quotationCont
                                                                          .combosPricesCurrencies[selectedComboId] ==
                                                                      'USD') {
                                                                quotationCont
                                                                        .combosPriceControllers[comboKeys[i]]!
                                                                        .text =
                                                                    '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                              } else {
                                                                var matchedItems = exchangeRatesController
                                                                    .exchangeRatesList
                                                                    .where(
                                                                      (item) =>
                                                                          item["currency"] ==
                                                                          quotationCont
                                                                              .combosPricesCurrencies[selectedComboId],
                                                                    );

                                                                var result =
                                                                    matchedItems
                                                                            .isNotEmpty
                                                                        ? matchedItems.reduce(
                                                                          (
                                                                            a,
                                                                            b,
                                                                          ) =>
                                                                              DateTime.parse(
                                                                                    a["start_date"],
                                                                                  ).isAfter(
                                                                                    DateTime.parse(
                                                                                      b["start_date"],
                                                                                    ),
                                                                                  )
                                                                                  ? a
                                                                                  : b,
                                                                        )
                                                                        : null;
                                                                var divider =
                                                                    '1';
                                                                if (result !=
                                                                    null) {
                                                                  divider =
                                                                      result["exchange_rate"]
                                                                          .toString();
                                                                }
                                                                var usdPrice =
                                                                    '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                                quotationCont
                                                                        .combosPriceControllers[comboKeys[i]]!
                                                                        .text =
                                                                    '${double.parse('${(double.parse(usdPrice) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                              }
                                                              quotationCont
                                                                      .combosPriceControllers[comboKeys[i]]!
                                                                      .text =
                                                                  '${double.parse(quotationCont.combosPriceControllers[comboKeys[i]]!.text)}';

                                                              quotationCont
                                                                  .combosPriceControllers[comboKeys[i]]!
                                                                  .text = double.parse(
                                                                quotationCont
                                                                    .combosPriceControllers[comboKeys[i]]!
                                                                    .text,
                                                              ).toStringAsFixed(
                                                                2,
                                                              );
                                                              var totalLine =
                                                                  '${(int.parse(quotationCont.rowsInListViewInQuotation[comboKeys[i]]['item_quantity']) * double.parse(quotationCont.combosPriceControllers[comboKeys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';
                                                              quotationCont
                                                                  .setEnteredQtyInQuotation(
                                                                    comboKeys[i],
                                                                    quotationCont
                                                                        .rowsInListViewInQuotation[comboKeys[i]]['item_quantity'],
                                                                  );
                                                              quotationCont
                                                                  .setMainTotalInQuotation(
                                                                    comboKeys[i],
                                                                    totalLine,
                                                                  );
                                                              // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
                                                              quotationCont
                                                                  .getTotalItems();

                                                              quotationCont
                                                                  .setEnteredUnitPriceInQuotation(
                                                                    comboKeys[i],
                                                                    quotationCont
                                                                        .combosPriceControllers[comboKeys[i]]!
                                                                        .text,
                                                                  );
                                                              quotationCont
                                                                  .setMainTotalInQuotation(
                                                                    comboKeys[i],
                                                                    totalLine,
                                                                  );
                                                              quotationCont
                                                                  .getTotalItems();
                                                            }
                                                          }
                                                        },
                                                      )
                                                      : loading();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              homeController.isOpened.value
                                                  ? MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.14
                                                  : MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.15,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('validity'.tr),
                                              DialogDateTextField(
                                                textEditingController:
                                                    validityController,
                                                text: '',
                                                textFieldWidth:
                                                    homeController
                                                            .isOpened
                                                            .value
                                                        ? MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.1
                                                        : MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.11,
                                                // MediaQuery.of(context).size.width * 0.25,
                                                validationFunc: (val) {},
                                                onChangedFunc: (val) {
                                                  validityController.text = val;
                                                },
                                                onDateSelected: (value) {
                                                  validityController.text =
                                                      value;
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
                                                  ? MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.11
                                                  : MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.14,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('potential'.tr),
                                              DropdownMenu<String>(
                                                width:
                                                    homeController
                                                            .isOpened
                                                            .value
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
                                                    chanceLevels.map<
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
                                          width:
                                              homeController.isOpened.value
                                                  ? MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.12
                                                  : MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.15,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('pricelist'.tr),
                                              DropdownMenu<String>(
                                                width:
                                                    homeController
                                                            .isOpened
                                                            .value
                                                        ? MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.08
                                                        : MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.11,
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
                                                    quotationCont
                                                        .priceListsCodes
                                                        .map<
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
                                                        })
                                                        .toList(),
                                                enableFilter: true,
                                                onSelected: (String? val) {
                                                  var index = quotationCont
                                                      .priceListsCodes
                                                      .indexOf(val!);
                                                  quotationCont
                                                      .setSelectedPriceListId(
                                                        quotationCont
                                                            .priceListsIds[index],
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
                                    )
                                    : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              quotationCont.quotationNumber,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.sp,
                                                color:
                                                    TypographyColor.titleTable,
                                              ),
                                            ),
                                            ReusableReferenceTextField(
                                              type: 'quotations',
                                              textEditingController:
                                                  refController,
                                              rowWidth:
                                                  homeController.isOpened.value
                                                      ? MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.18
                                                      : MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.21,
                                              textFieldWidth:
                                                  homeController.isOpened.value
                                                      ? MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.15
                                                      : MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.18,
                                            ),
                                            // DialogTextField(
                                            //   textEditingController:
                                            //       refController,
                                            //   text: '${'ref'.tr}:',
                                            //   hint: 'manual_reference'.tr,
                                            //   rowWidth:
                                            //       homeController.isOpened.value
                                            //           ? MediaQuery.of(
                                            //                 context,
                                            //               ).size.width *
                                            //               0.18
                                            //           : MediaQuery.of(
                                            //                 context,
                                            //               ).size.width *
                                            //               0.21,
                                            //   textFieldWidth:
                                            //       homeController.isOpened.value
                                            //           ? MediaQuery.of(
                                            //                 context,
                                            //               ).size.width *
                                            //               0.15
                                            //           : MediaQuery.of(
                                            //                 context,
                                            //               ).size.width *
                                            //               0.18,
                                            //   validationFunc: (val) {},
                                            // ),
                                            SizedBox(
                                              width:
                                                  homeController.isOpened.value
                                                      ? MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.15
                                                      : MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.18,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('currency'.tr),
                                                  GetBuilder<
                                                    ExchangeRatesController
                                                  >(
                                                    builder: (cont) {
                                                      return cont
                                                              .isExchangeRatesFetched
                                                          ?
                                                          //   CustomSearchableDropdown(hint: '',width:  homeController.isOpened.value? MediaQuery.of(context).size.width * 0.07:
                                                          //   MediaQuery.of(context).size.width * 0.1, items: cont.currenciesNamesList, onSelected: (String? val) {
                                                          //   setState(() {
                                                          //     selectedCurrency = val!;
                                                          //     var index = cont
                                                          //         .currenciesNamesList
                                                          //         .indexOf(val);
                                                          //     quotationCont.setSelectedCurrency(
                                                          //       cont.currenciesIdsList[index],
                                                          //       val,
                                                          //     );
                                                          //     quotationCont
                                                          //         .setSelectedCurrencySymbol(
                                                          //       cont.currenciesSymbolsList[index],
                                                          //     );
                                                          //     var matchedItems =
                                                          //     exchangeRatesController
                                                          //         .exchangeRatesList
                                                          //         .where(
                                                          //           (item) =>
                                                          //       item["currency"] ==
                                                          //           val,
                                                          //     );
                                                          //
                                                          //     var result =
                                                          //     matchedItems.isNotEmpty
                                                          //         ? matchedItems.reduce(
                                                          //           (a, b) =>
                                                          //       DateTime.parse(
                                                          //         a["start_date"],
                                                          //       ).isAfter(
                                                          //         DateTime.parse(
                                                          //           b["start_date"],
                                                          //         ),
                                                          //       )
                                                          //           ? a
                                                          //           : b,
                                                          //     )
                                                          //         : null;
                                                          //     quotationCont
                                                          //         .setExchangeRateForSelectedCurrency(
                                                          //       result != null
                                                          //           ? '${result["exchange_rate"]}'
                                                          //           : '1',
                                                          //     );
                                                          //   });
                                                          //   var keys =
                                                          //   quotationCont
                                                          //       .unitPriceControllers
                                                          //       .keys
                                                          //       .toList();
                                                          //   for (
                                                          //   int i = 0;
                                                          //   i <
                                                          //       quotationCont
                                                          //           .unitPriceControllers
                                                          //           .length;
                                                          //   i++
                                                          //   ) {
                                                          //     var selectedItemId =
                                                          //         '${quotationCont.rowsInListViewInQuotation[keys[i]]['item_id']}';
                                                          //     if (selectedItemId != '') {
                                                          //       if (quotationCont
                                                          //           .itemsPricesCurrencies[selectedItemId] ==
                                                          //           val) {
                                                          //         quotationCont
                                                          //             .unitPriceControllers[keys[i]]!
                                                          //             .text = quotationCont
                                                          //             .itemUnitPrice[selectedItemId]
                                                          //             .toString();
                                                          //       } else if (quotationCont
                                                          //           .selectedCurrencyName ==
                                                          //           'USD' &&
                                                          //           quotationCont
                                                          //               .itemsPricesCurrencies[selectedItemId] !=
                                                          //               val) {
                                                          //         var matchedItems =
                                                          //         exchangeRatesController
                                                          //             .exchangeRatesList
                                                          //             .where(
                                                          //               (item) =>
                                                          //           item["currency"] ==
                                                          //               quotationCont
                                                          //                   .itemsPricesCurrencies[selectedItemId],
                                                          //         );
                                                          //
                                                          //         var result =
                                                          //         matchedItems.isNotEmpty
                                                          //             ? matchedItems.reduce(
                                                          //               (a, b) =>
                                                          //           DateTime.parse(
                                                          //             a["start_date"],
                                                          //           ).isAfter(
                                                          //             DateTime.parse(
                                                          //               b["start_date"],
                                                          //             ),
                                                          //           )
                                                          //               ? a
                                                          //               : b,
                                                          //         )
                                                          //             : null;
                                                          //         var divider = '1';
                                                          //         if (result != null) {
                                                          //           divider =
                                                          //               result["exchange_rate"]
                                                          //                   .toString();
                                                          //         }
                                                          //         quotationCont
                                                          //             .unitPriceControllers[keys[i]]!
                                                          //             .text =
                                                          //         '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                          //       } else if (quotationCont
                                                          //           .selectedCurrencyName !=
                                                          //           'USD' &&
                                                          //           quotationCont
                                                          //               .itemsPricesCurrencies[selectedItemId] ==
                                                          //               'USD') {
                                                          //         quotationCont
                                                          //             .unitPriceControllers[keys[i]]!
                                                          //             .text =
                                                          //         '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                          //       } else {
                                                          //         var matchedItems =
                                                          //         exchangeRatesController
                                                          //             .exchangeRatesList
                                                          //             .where(
                                                          //               (item) =>
                                                          //           item["currency"] ==
                                                          //               quotationCont
                                                          //                   .itemsPricesCurrencies[selectedItemId],
                                                          //         );
                                                          //
                                                          //         var result =
                                                          //         matchedItems.isNotEmpty
                                                          //             ? matchedItems.reduce(
                                                          //               (a, b) =>
                                                          //           DateTime.parse(
                                                          //             a["start_date"],
                                                          //           ).isAfter(
                                                          //             DateTime.parse(
                                                          //               b["start_date"],
                                                          //             ),
                                                          //           )
                                                          //               ? a
                                                          //               : b,
                                                          //         )
                                                          //             : null;
                                                          //         var divider = '1';
                                                          //         if (result != null) {
                                                          //           divider =
                                                          //               result["exchange_rate"]
                                                          //                   .toString();
                                                          //         }
                                                          //         var usdPrice =
                                                          //             '${double.parse('${(double.parse(quotationCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                                          //         quotationCont
                                                          //             .unitPriceControllers[keys[i]]!
                                                          //             .text =
                                                          //         '${double.parse('${(double.parse(usdPrice) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                          //       }
                                                          //       if (!quotationCont
                                                          //           .isBeforeVatPrices) {
                                                          //         var taxRate =
                                                          //             double.parse(
                                                          //               quotationCont
                                                          //                   .itemsVats[selectedItemId],
                                                          //             ) /
                                                          //                 100.0;
                                                          //         var taxValue =
                                                          //             taxRate *
                                                          //                 double.parse(
                                                          //                   quotationCont
                                                          //                       .unitPriceControllers[keys[i]]!
                                                          //                       .text,
                                                          //                 );
                                                          //
                                                          //         quotationCont
                                                          //             .unitPriceControllers[keys[i]]!
                                                          //             .text =
                                                          //         '${double.parse(quotationCont.unitPriceControllers[keys[i]]!.text) + taxValue}';
                                                          //       }
                                                          //       quotationCont
                                                          //           .unitPriceControllers[keys[i]]!
                                                          //           .text = double.parse(
                                                          //         quotationCont
                                                          //             .unitPriceControllers[keys[i]]!
                                                          //             .text,
                                                          //       ).toStringAsFixed(2);
                                                          //       var totalLine =
                                                          //           '${(int.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_quantity']) * double.parse(quotationCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';
                                                          //
                                                          //       quotationCont
                                                          //           .setEnteredUnitPriceInQuotation(
                                                          //         keys[i],
                                                          //         quotationCont
                                                          //             .unitPriceControllers[keys[i]]!
                                                          //             .text,
                                                          //       );
                                                          //       quotationCont
                                                          //           .setMainTotalInQuotation(
                                                          //         keys[i],
                                                          //         totalLine,
                                                          //       );
                                                          //       quotationCont.getTotalItems();
                                                          //     }
                                                          //   }
                                                          //   var comboKeys =
                                                          //   quotationCont
                                                          //       .combosPriceControllers
                                                          //       .keys
                                                          //       .toList();
                                                          //   for (
                                                          //   int i = 0;
                                                          //   i <
                                                          //       quotationCont
                                                          //           .combosPriceControllers
                                                          //           .length;
                                                          //   i++
                                                          //   ) {
                                                          //     var selectedComboId =
                                                          //         '${quotationCont.rowsInListViewInQuotation[comboKeys[i]]['combo']}';
                                                          //     if (selectedComboId != '') {
                                                          //       var ind = quotationCont
                                                          //           .combosIdsList
                                                          //           .indexOf(selectedComboId);
                                                          //       if (quotationCont
                                                          //           .combosPricesCurrencies[selectedComboId] ==
                                                          //           quotationCont
                                                          //               .selectedCurrencyName) {
                                                          //         quotationCont
                                                          //             .combosPriceControllers[comboKeys[i]]!
                                                          //             .text = quotationCont
                                                          //             .combosPricesList[ind]
                                                          //             .toString();
                                                          //       } else if (quotationCont
                                                          //           .selectedCurrencyName ==
                                                          //           'USD' &&
                                                          //           quotationCont
                                                          //               .combosPricesCurrencies[selectedComboId] !=
                                                          //               quotationCont
                                                          //                   .selectedCurrencyName) {
                                                          //         var matchedItems =
                                                          //         exchangeRatesController
                                                          //             .exchangeRatesList
                                                          //             .where(
                                                          //               (item) =>
                                                          //           item["currency"] ==
                                                          //               quotationCont
                                                          //                   .combosPricesCurrencies[selectedComboId],
                                                          //         );
                                                          //
                                                          //         var result =
                                                          //         matchedItems.isNotEmpty
                                                          //             ? matchedItems.reduce(
                                                          //               (a, b) =>
                                                          //           DateTime.parse(
                                                          //             a["start_date"],
                                                          //           ).isAfter(
                                                          //             DateTime.parse(
                                                          //               b["start_date"],
                                                          //             ),
                                                          //           )
                                                          //               ? a
                                                          //               : b,
                                                          //         )
                                                          //             : null;
                                                          //         var divider = '1';
                                                          //         if (result != null) {
                                                          //           divider =
                                                          //               result["exchange_rate"]
                                                          //                   .toString();
                                                          //         }
                                                          //         quotationCont
                                                          //             .combosPriceControllers[comboKeys[i]]!
                                                          //             .text =
                                                          //         '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                          //       } else if (quotationCont
                                                          //           .selectedCurrencyName !=
                                                          //           'USD' &&
                                                          //           quotationCont
                                                          //               .combosPricesCurrencies[selectedComboId] ==
                                                          //               'USD') {
                                                          //         quotationCont
                                                          //             .combosPriceControllers[comboKeys[i]]!
                                                          //             .text =
                                                          //         '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                          //       } else {
                                                          //         var matchedItems =
                                                          //         exchangeRatesController
                                                          //             .exchangeRatesList
                                                          //             .where(
                                                          //               (item) =>
                                                          //           item["currency"] ==
                                                          //               quotationCont
                                                          //                   .combosPricesCurrencies[selectedComboId],
                                                          //         );
                                                          //
                                                          //         var result =
                                                          //         matchedItems.isNotEmpty
                                                          //             ? matchedItems.reduce(
                                                          //               (a, b) =>
                                                          //           DateTime.parse(
                                                          //             a["start_date"],
                                                          //           ).isAfter(
                                                          //             DateTime.parse(
                                                          //               b["start_date"],
                                                          //             ),
                                                          //           )
                                                          //               ? a
                                                          //               : b,
                                                          //         )
                                                          //             : null;
                                                          //         var divider = '1';
                                                          //         if (result != null) {
                                                          //           divider =
                                                          //               result["exchange_rate"]
                                                          //                   .toString();
                                                          //         }
                                                          //         var usdPrice =
                                                          //             '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                          //         quotationCont
                                                          //             .combosPriceControllers[comboKeys[i]]!
                                                          //             .text =
                                                          //         '${double.parse('${(double.parse(usdPrice) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                          //       }
                                                          //       quotationCont
                                                          //           .combosPriceControllers[comboKeys[i]]!
                                                          //           .text =
                                                          //       '${double.parse(quotationCont.combosPriceControllers[comboKeys[i]]!.text)}';
                                                          //
                                                          //       quotationCont
                                                          //           .combosPriceControllers[comboKeys[i]]!
                                                          //           .text = double.parse(
                                                          //         quotationCont
                                                          //             .combosPriceControllers[comboKeys[i]]!
                                                          //             .text,
                                                          //       ).toStringAsFixed(2);
                                                          //       var totalLine =
                                                          //           '${(int.parse(quotationCont.rowsInListViewInQuotation[comboKeys[i]]['item_quantity']) * double.parse(quotationCont.combosPriceControllers[comboKeys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';
                                                          //       quotationCont
                                                          //           .setEnteredQtyInQuotation(
                                                          //         comboKeys[i],
                                                          //         quotationCont
                                                          //             .rowsInListViewInQuotation[comboKeys[i]]['item_quantity'],
                                                          //       );
                                                          //       quotationCont
                                                          //           .setMainTotalInQuotation(
                                                          //         comboKeys[i],
                                                          //         totalLine,
                                                          //       );
                                                          //       // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
                                                          //       quotationCont.getTotalItems();
                                                          //
                                                          //       quotationCont
                                                          //           .setEnteredUnitPriceInQuotation(
                                                          //         comboKeys[i],
                                                          //         quotationCont
                                                          //             .combosPriceControllers[comboKeys[i]]!
                                                          //             .text,
                                                          //       );
                                                          //       quotationCont
                                                          //           .setMainTotalInQuotation(
                                                          //         comboKeys[i],
                                                          //         totalLine,
                                                          //       );
                                                          //       quotationCont.getTotalItems();
                                                          //     }
                                                          //   }
                                                          // });
                                                          DropdownMenu<String>(
                                                            width:
                                                                homeController
                                                                        .isOpened
                                                                        .value
                                                                    ? MediaQuery.of(
                                                                          context,
                                                                        ).size.width *
                                                                        0.1
                                                                    : MediaQuery.of(
                                                                          context,
                                                                        ).size.width *
                                                                        0.13,
                                                            // requestFocusOnTap: false,
                                                            enableSearch: true,
                                                            controller:
                                                                quotationCont
                                                                    .currencyController,
                                                            hintText: '',
                                                            textStyle:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                            inputDecorationTheme: InputDecorationTheme(
                                                              isDense: true,
                                                              // filled: true,
                                                              hintStyle:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        12,
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
                                                                cont.currenciesNamesList.map<
                                                                  DropdownMenuEntry<
                                                                    String
                                                                  >
                                                                >((
                                                                  String option,
                                                                ) {
                                                                  return DropdownMenuEntry<
                                                                    String
                                                                  >(
                                                                    value:
                                                                        option,
                                                                    label:
                                                                        option,
                                                                  );
                                                                }).toList(),
                                                            enableFilter: true,
                                                            onSelected: (
                                                              String? val,
                                                            ) {
                                                              setState(() {
                                                                selectedCurrency =
                                                                    val!;
                                                                var index = cont
                                                                    .currenciesNamesList
                                                                    .indexOf(
                                                                      val,
                                                                    );
                                                                quotationCont
                                                                    .setSelectedCurrency(
                                                                      cont.currenciesIdsList[index],
                                                                      val,
                                                                    );
                                                                quotationCont
                                                                    .setSelectedCurrencySymbol(
                                                                      cont.currenciesSymbolsList[index],
                                                                    );
                                                                var matchedItems =
                                                                    exchangeRatesController
                                                                        .exchangeRatesList
                                                                        .where(
                                                                          (
                                                                            item,
                                                                          ) =>
                                                                              item["currency"] ==
                                                                              val,
                                                                        );

                                                                var result =
                                                                    matchedItems
                                                                            .isNotEmpty
                                                                        ? matchedItems.reduce(
                                                                          (
                                                                            a,
                                                                            b,
                                                                          ) =>
                                                                              DateTime.parse(
                                                                                    a["start_date"],
                                                                                  ).isAfter(
                                                                                    DateTime.parse(
                                                                                      b["start_date"],
                                                                                    ),
                                                                                  )
                                                                                  ? a
                                                                                  : b,
                                                                        )
                                                                        : null;

                                                                quotationCont
                                                                    .setExchangeRateForSelectedCurrency(
                                                                      result !=
                                                                              null
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
                                                                if (selectedItemId !=
                                                                    '') {
                                                                  if (quotationCont
                                                                          .itemsPricesCurrencies[selectedItemId] ==
                                                                      val) {
                                                                    quotationCont
                                                                            .unitPriceControllers[keys[i]]!
                                                                            .text =
                                                                        quotationCont
                                                                            .itemUnitPrice[selectedItemId]
                                                                            .toString();
                                                                  } else if (quotationCont
                                                                              .selectedCurrencyName ==
                                                                          'USD' &&
                                                                      quotationCont
                                                                              .itemsPricesCurrencies[selectedItemId] !=
                                                                          val) {
                                                                    var matchedItems = exchangeRatesController
                                                                        .exchangeRatesList
                                                                        .where(
                                                                          (
                                                                            item,
                                                                          ) =>
                                                                              item["currency"] ==
                                                                              quotationCont.itemsPricesCurrencies[selectedItemId],
                                                                        );

                                                                    var result =
                                                                        matchedItems.isNotEmpty
                                                                            ? matchedItems.reduce(
                                                                              (
                                                                                a,
                                                                                b,
                                                                              ) =>
                                                                                  DateTime.parse(
                                                                                        a["start_date"],
                                                                                      ).isAfter(
                                                                                        DateTime.parse(
                                                                                          b["start_date"],
                                                                                        ),
                                                                                      )
                                                                                      ? a
                                                                                      : b,
                                                                            )
                                                                            : null;
                                                                    var divider =
                                                                        '1';
                                                                    if (result !=
                                                                        null) {
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
                                                                    var matchedItems = exchangeRatesController
                                                                        .exchangeRatesList
                                                                        .where(
                                                                          (
                                                                            item,
                                                                          ) =>
                                                                              item["currency"] ==
                                                                              quotationCont.itemsPricesCurrencies[selectedItemId],
                                                                        );

                                                                    var result =
                                                                        matchedItems.isNotEmpty
                                                                            ? matchedItems.reduce(
                                                                              (
                                                                                a,
                                                                                b,
                                                                              ) =>
                                                                                  DateTime.parse(
                                                                                        a["start_date"],
                                                                                      ).isAfter(
                                                                                        DateTime.parse(
                                                                                          b["start_date"],
                                                                                        ),
                                                                                      )
                                                                                      ? a
                                                                                      : b,
                                                                            )
                                                                            : null;
                                                                    var divider =
                                                                        '1';
                                                                    if (result !=
                                                                        null) {
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
                                                                  ).toStringAsFixed(
                                                                    2,
                                                                  );
                                                                  var totalLine =
                                                                      '${(int.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_quantity']) * double.parse(quotationCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';

                                                                  quotationCont.setEnteredUnitPriceInQuotation(
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
                                                                  quotationCont
                                                                      .getTotalItems();
                                                                }
                                                              }

                                                              var comboKeys =
                                                                  quotationCont
                                                                      .combosPriceControllers
                                                                      .keys
                                                                      .toList();
                                                              for (
                                                                int i = 0;
                                                                i <
                                                                    quotationCont
                                                                        .combosPriceControllers
                                                                        .length;
                                                                i++
                                                              ) {
                                                                var selectedComboId =
                                                                    '${quotationCont.rowsInListViewInQuotation[comboKeys[i]]['combo']}';
                                                                if (selectedComboId !=
                                                                    '') {
                                                                  var ind = quotationCont
                                                                      .combosIdsList
                                                                      .indexOf(
                                                                        selectedComboId,
                                                                      );
                                                                  if (quotationCont
                                                                          .combosPricesCurrencies[selectedComboId] ==
                                                                      quotationCont
                                                                          .selectedCurrencyName) {
                                                                    quotationCont
                                                                            .combosPriceControllers[comboKeys[i]]!
                                                                            .text =
                                                                        quotationCont
                                                                            .combosPricesList[ind]
                                                                            .toString();
                                                                  } else if (quotationCont
                                                                              .selectedCurrencyName ==
                                                                          'USD' &&
                                                                      quotationCont
                                                                              .combosPricesCurrencies[selectedComboId] !=
                                                                          quotationCont
                                                                              .selectedCurrencyName) {
                                                                    var matchedItems = exchangeRatesController
                                                                        .exchangeRatesList
                                                                        .where(
                                                                          (
                                                                            item,
                                                                          ) =>
                                                                              item["currency"] ==
                                                                              quotationCont.combosPricesCurrencies[selectedComboId],
                                                                        );

                                                                    var result =
                                                                        matchedItems.isNotEmpty
                                                                            ? matchedItems.reduce(
                                                                              (
                                                                                a,
                                                                                b,
                                                                              ) =>
                                                                                  DateTime.parse(
                                                                                        a["start_date"],
                                                                                      ).isAfter(
                                                                                        DateTime.parse(
                                                                                          b["start_date"],
                                                                                        ),
                                                                                      )
                                                                                      ? a
                                                                                      : b,
                                                                            )
                                                                            : null;
                                                                    var divider =
                                                                        '1';
                                                                    if (result !=
                                                                        null) {
                                                                      divider =
                                                                          result["exchange_rate"]
                                                                              .toString();
                                                                    }
                                                                    quotationCont
                                                                            .combosPriceControllers[comboKeys[i]]!
                                                                            .text =
                                                                        '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                                  } else if (quotationCont
                                                                              .selectedCurrencyName !=
                                                                          'USD' &&
                                                                      quotationCont
                                                                              .combosPricesCurrencies[selectedComboId] ==
                                                                          'USD') {
                                                                    quotationCont
                                                                            .combosPriceControllers[comboKeys[i]]!
                                                                            .text =
                                                                        '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                                  } else {
                                                                    var matchedItems = exchangeRatesController
                                                                        .exchangeRatesList
                                                                        .where(
                                                                          (
                                                                            item,
                                                                          ) =>
                                                                              item["currency"] ==
                                                                              quotationCont.combosPricesCurrencies[selectedComboId],
                                                                        );

                                                                    var result =
                                                                        matchedItems.isNotEmpty
                                                                            ? matchedItems.reduce(
                                                                              (
                                                                                a,
                                                                                b,
                                                                              ) =>
                                                                                  DateTime.parse(
                                                                                        a["start_date"],
                                                                                      ).isAfter(
                                                                                        DateTime.parse(
                                                                                          b["start_date"],
                                                                                        ),
                                                                                      )
                                                                                      ? a
                                                                                      : b,
                                                                            )
                                                                            : null;
                                                                    var divider =
                                                                        '1';
                                                                    if (result !=
                                                                        null) {
                                                                      divider =
                                                                          result["exchange_rate"]
                                                                              .toString();
                                                                    }
                                                                    var usdPrice =
                                                                        '${double.parse('${(double.parse(quotationCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                                    quotationCont
                                                                            .combosPriceControllers[comboKeys[i]]!
                                                                            .text =
                                                                        '${double.parse('${(double.parse(usdPrice) * double.parse(quotationCont.exchangeRateForSelectedCurrency))}')}';
                                                                  }
                                                                  quotationCont
                                                                          .combosPriceControllers[comboKeys[i]]!
                                                                          .text =
                                                                      '${double.parse(quotationCont.combosPriceControllers[comboKeys[i]]!.text)}';

                                                                  quotationCont
                                                                      .combosPriceControllers[comboKeys[i]]!
                                                                      .text = double.parse(
                                                                    quotationCont
                                                                        .combosPriceControllers[comboKeys[i]]!
                                                                        .text,
                                                                  ).toStringAsFixed(
                                                                    2,
                                                                  );
                                                                  var totalLine =
                                                                      '${(int.parse(quotationCont.rowsInListViewInQuotation[comboKeys[i]]['item_quantity']) * double.parse(quotationCont.combosPriceControllers[comboKeys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';
                                                                  quotationCont.setEnteredQtyInQuotation(
                                                                    comboKeys[i],
                                                                    quotationCont
                                                                        .rowsInListViewInQuotation[comboKeys[i]]['item_quantity'],
                                                                  );
                                                                  quotationCont
                                                                      .setMainTotalInQuotation(
                                                                        comboKeys[i],
                                                                        totalLine,
                                                                      );
                                                                  // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
                                                                  quotationCont
                                                                      .getTotalItems();

                                                                  quotationCont.setEnteredUnitPriceInQuotation(
                                                                    comboKeys[i],
                                                                    quotationCont
                                                                        .combosPriceControllers[comboKeys[i]]!
                                                                        .text,
                                                                  );
                                                                  quotationCont
                                                                      .setMainTotalInQuotation(
                                                                        comboKeys[i],
                                                                        totalLine,
                                                                      );
                                                                  quotationCont
                                                                      .getTotalItems();
                                                                }
                                                              }
                                                            },
                                                          )
                                                          : loading();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),

                                            SizedBox(
                                              width:
                                                  homeController.isOpened.value
                                                      ? MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.17
                                                      : MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.18,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('validity'.tr),
                                                  DialogDateTextField(
                                                    textEditingController:
                                                        validityController,
                                                    text: '',
                                                    textFieldWidth:
                                                        homeController
                                                                .isOpened
                                                                .value
                                                            ? MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.13
                                                            : MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.15,
                                                    // MediaQuery.of(context).size.width * 0.25,
                                                    validationFunc: (val) {},
                                                    onChangedFunc: (val) {
                                                      validityController.text =
                                                          val;
                                                    },
                                                    onDateSelected: (value) {
                                                      validityController.text =
                                                          value;
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
                                          ],
                                        ),
                                        gapH16,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width:
                                                  homeController.isOpened.value
                                                      ? MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.15
                                                      : MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.18,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('chance'.tr),
                                                  DropdownMenu<String>(
                                                    width:
                                                        homeController
                                                                .isOpened
                                                                .value
                                                            ? MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.11
                                                            : MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.14,
                                                    // requestFocusOnTap: false,
                                                    enableSearch: true,
                                                    controller:
                                                        chanceController,
                                                    hintText: '',
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
                                                      focusedBorder: OutlineInputBorder(
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
                                                        chanceLevels.map<
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
                                              width:
                                                  homeController.isOpened.value
                                                      ? screenWidth > 1250
                                                          ? MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.17
                                                          : MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.21
                                                      : MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.20,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('pricelist'.tr),
                                                  DropdownMenu<String>(
                                                    width:
                                                        homeController
                                                                .isOpened
                                                                .value
                                                            ? screenWidth > 1250
                                                                ? MediaQuery.of(
                                                                      context,
                                                                    ).size.width *
                                                                    0.13
                                                                : MediaQuery.of(
                                                                      context,
                                                                    ).size.width *
                                                                    0.15
                                                            : MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.16,
                                                    // requestFocusOnTap: false,
                                                    enableSearch: true,
                                                    controller:
                                                        priceListController,
                                                    hintText: '',
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
                                                      focusedBorder: OutlineInputBorder(
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
                                                        quotationCont
                                                            .priceListsCodes
                                                            .map<
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
                                                            })
                                                            .toList(),
                                                    enableFilter: true,
                                                    onSelected: (String? val) {
                                                      var index = quotationCont
                                                          .priceListsCodes
                                                          .indexOf(val!);
                                                      quotationCont
                                                          .setSelectedPriceListId(
                                                            quotationCont
                                                                .priceListsIds[index],
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
                                            SizedBox(
                                              width:
                                                  homeController.isOpened.value
                                                      ? MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.18
                                                      : MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.22,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('input_date'.tr),
                                                  DialogDateTextField(
                                                    textEditingController:
                                                        inputDateController,
                                                    text: '',
                                                    textFieldWidth:
                                                        homeController
                                                                .isOpened
                                                                .value
                                                            ? MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.13
                                                            : MediaQuery.of(
                                                                  context,
                                                                ).size.width *
                                                                0.17,
                                                    // MediaQuery.of(context).size.width * 0.25,
                                                    validationFunc: (val) {},
                                                    onChangedFunc: (val) {
                                                      inputDateController.text =
                                                          val;
                                                    },
                                                    onDateSelected: (value) {
                                                      inputDateController.text =
                                                          value;
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
                                          ],
                                        ),
                                      ],
                                    ),
                          ),
                          gapH16,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              screenWidth > 1250
                                  ? SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('input_date'.tr),
                                        DialogDateTextField(
                                          textEditingController:
                                              inputDateController,
                                          text: '',
                                          textFieldWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.1,
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
                                  )
                                  : Text(""),
                              SizedBox(
                                width:
                                    screenWidth > 1250
                                        ? MediaQuery.of(context).size.width *
                                            0.32
                                        : MediaQuery.of(context).size.width *
                                            0.48,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ReusableDropDownMenusWithSearchCode(
                                      list:
                                          quotationCont.customersMultiPartList,
                                      text: 'code'.tr,
                                      hint: '${'search'.tr}...',
                                      controller: codeController,
                                      onSelected: (String? value) {
                                        codeController.text = value!;
                                        int index = quotationCont
                                            .customerNumberList
                                            .indexOf(value);
                                        clientNameController.text =
                                            quotationCont
                                                .customerNameList[index];
                                        setState(() {
                                          selectedCustomerIds =
                                              quotationCont
                                                  .customerIdsList[quotationCont
                                                  .customerNumberList
                                                  .indexOf(value)];
                                          if (quotationCont
                                                  .customersPricesListsIds[index]
                                                  .isNotEmpty &&
                                              quotationCont
                                                      .customersPricesListsIds[index] !=
                                                  null) {
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
                                                  .isNotEmpty &&
                                              quotationCont
                                                      .customersSalesPersonsIds[index] !=
                                                  null) {
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
                                        });
                                      },
                                      validationFunc: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'select_option'.tr;
                                        }
                                        return null;
                                      },
                                      rowWidth:
                                          screenWidth > 1250
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.13
                                              : MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.18,
                                      textFieldWidth:
                                          screenWidth > 1250
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.10
                                              : MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.15,
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
                                      columnWidths: [175.0, 230.0],
                                    ),
                                    ReusableDropDownMenuWithSearch(
                                      list: quotationCont.customerNameList,
                                      text: '',
                                      hint: '${'search'.tr}...',
                                      controller: clientNameController,
                                      onSelected: (String? val) {
                                        setState(() {
                                          var index = quotationCont
                                              .customerNameList
                                              .indexOf(val!);
                                          codeController.text =
                                              quotationCont
                                                  .customerNumberList[index];
                                          selectedCustomerIds =
                                              quotationCont
                                                  .customerIdsList[index];
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
                                        });
                                      },
                                      validationFunc: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'select_option'.tr;
                                        }
                                        return null;
                                      },
                                      rowWidth:
                                          screenWidth > 1250
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.17
                                              : MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.27,
                                      textFieldWidth:
                                          screenWidth > 1250
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.16
                                              : MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.26,
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

                              // DialogTextField(
                              //   textEditingController: paymentTermsController,
                              //   text: 'payment_terms'.tr,
                              //   hint: '',
                              //   rowWidth:
                              //       screenWidth > 1250
                              //           ? MediaQuery.of(context).size.width *
                              //               0.20
                              //           : screenWidth > 1049
                              //           ? MediaQuery.of(context).size.width *
                              //               0.23
                              //           : MediaQuery.of(context).size.width *
                              //               0.22,
                              //   textFieldWidth:
                              //       screenWidth > 1250
                              //           ? MediaQuery.of(context).size.width *
                              //               0.11
                              //           : screenWidth > 1049
                              //           ? MediaQuery.of(context).size.width *
                              //               0.13
                              //           : MediaQuery.of(context).size.width *
                              //               0.12,
                              //   validationFunc: (val) {},
                              // ),

                              // ReusableDropDownMenuWithSearch(
                              //   list: termsList,
                              //   text: 'payment_terms'.tr,
                              //   hint: '',
                              //   onSelected: (value) {},
                              //   controller: controller,
                              //   validationFunc: (value) {},
                              //   rowWidth:
                              //       MediaQuery.of(context).size.width * 0.24,
                              //   textFieldWidth:
                              //       MediaQuery.of(context).size.width * 0.15,
                              //   clickableOptionText:
                              //       'create_new_payment_terms'.tr,
                              //   isThereClickableOption: true,
                              //   onTappedClickableOption: () {
                              //     // showDialog<String>(
                              //     //   context: context,
                              //     //   builder:
                              //     //       (
                              //     //       BuildContext context,
                              //     //       ) => const AlertDialog(
                              //     //     backgroundColor: Colors.white,
                              //     //     shape: RoundedRectangleBorder(
                              //     //       borderRadius:
                              //     //       BorderRadius.all(
                              //     //         Radius.circular(9),
                              //     //       ),
                              //     //     ),
                              //     //     elevation: 0,
                              //     //     content: CreateClientDialog(),
                              //     //   ),
                              //     // );
                              //   },
                              // ),
                              GetBuilder<PaymentTermsController>(
                                builder: (cont) {
                                  return ReusableDropDownMenuWithSearch(
                                    key: ValueKey(cont.paymentTermsNamesList.length),
                                    list: cont.paymentTermsNamesList,
                                    text: 'payment_terms'.tr,
                                    hint: '${'search'.tr}...',
                                    controller: paymentTermsController,
                                    onSelected: (String? val) {
                                      int index = cont.paymentTermsNamesList
                                          .indexOf(val!);
                                      quotationCont.setSelectedPaymentTermId(
                                        cont.paymentTermsIdsList[index],
                                      );
                                    },
                                    validationFunc: (value) {
                                      // if (value == null || value.isEmpty) {
                                      //   return 'select_option'.tr;
                                      // }
                                      // return null;
                                    },
                                    rowWidth:
                                        MediaQuery.of(context).size.width *
                                        0.24,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width *
                                        0.15,
                                    clickableOptionText:
                                        'or_create_new_payment_term'.tr,
                                    isThereClickableOption: true,
                                    onTappedClickableOption: () {
                                      showDialog<String>(
                                        context: context,
                                        builder:
                                            (
                                              BuildContext context,
                                            ) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.all(0),
                                              titlePadding:
                                                  const EdgeInsets.all(0),
                                              actionsPadding:
                                                  const EdgeInsets.all(0),
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(9),
                                                        ),
                                                  ),
                                              elevation: 0,
                                              content:
                                                  configDialogs['payment_terms'],
                                            ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),

                          gapH16,
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
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                        gapW10,
                                        Text(
                                          " ${quotationCont.street[selectedCustomerIds] ?? ''} ",
                                          style: TextStyle(fontSize: 12.sp),
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
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                    gapH6,
                                    //tel
                                    Row(
                                      children: [
                                        Text(
                                          'Phone Number'.tr,
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                        gapW10,
                                        Text(
                                          "${quotationCont.phoneNumber[selectedCustomerIds] ?? ''}",
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              gapW16,
                              GetBuilder<DeliveryTermsController>(
                                builder: (cont) {
                                  return cont.isDeliveryTermsFetched?ReusableDropDownMenuWithSearch(
                                    key: ValueKey(cont.deliveryTermsNamesList.length),
                                    list: cont.deliveryTermsNamesList,
                                    text: 'delivery_terms'.tr,
                                    hint: '${'search'.tr}...',
                                    controller: deliveryTermsController,
                                    onSelected: (String? val) {
                                      var index = cont.deliveryTermsNamesList
                                          .indexOf(val!);
                                      quotationCont.setSelectedDeliveryTermId(
                                        cont.deliveryTermsIdsList[index],
                                      );
                                    },
                                    validationFunc: (value) {
                                      // if (value == null || value.isEmpty) {
                                      //   return 'select_option'.tr;
                                      // }
                                      // return null;
                                    },
                                    rowWidth:
                                        MediaQuery.of(context).size.width *
                                        0.24,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width *
                                        0.15,
                                    clickableOptionText:
                                        'or_create_new_delivery_term'.tr,
                                    isThereClickableOption: true,
                                    onTappedClickableOption: () {
                                      showDialog<String>(
                                        context: context,
                                        builder:
                                            (
                                              BuildContext context,
                                            ) => const AlertDialog(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(9),
                                                ),
                                              ),
                                              elevation: 0,
                                              content:
                                                  DeliveryTermsDialogContent(),
                                            ),
                                      );
                                    },
                                  ):loading();
                                },
                              ),
                            ],
                          ),
                          gapH16,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //email
                                    Row(
                                      children: [
                                        Text(
                                          'email'.tr,
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                        gapW10,
                                        Text(
                                          "${quotationCont.email[selectedCustomerIds] ?? ''}",
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                    gapH6,
                                    //vat
                                    quotationCont
                                            .isVatExemptCheckBoxShouldAppear
                                        ? Row(
                                          children: [
                                            Text(
                                              'vat'.tr,
                                              style: TextStyle(fontSize: 12.sp),
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
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.15,
                                          // requestFocusOnTap: false,
                                          enableSearch: true,
                                          controller: priceConditionController,
                                          hintText: '',
                                          textStyle: TextStyle(fontSize: 12.sp),
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
                                              pricesVatConditions.map<
                                                DropdownMenuEntry<String>
                                              >((String option) {
                                                return DropdownMenuEntry<
                                                  String
                                                >(value: option, label: option);
                                              }).toList(),
                                          enableFilter: true,
                                          onSelected: (String? value) {
                                            setState(() {
                                              if (value ==
                                                  'Prices are before vat') {
                                                quotationCont
                                                    .setIsBeforeVatPrices(true);
                                                // ch
                                              } else {
                                                quotationCont
                                                    .setIsBeforeVatPrices(
                                                      false,
                                                    );
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
                                                    quotationCont
                                                        .rowsInListViewInQuotation[keys[i]]['item_id'];
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
                                                    var matchedItems =
                                                        exchangeRatesController
                                                            .exchangeRatesList
                                                            .where(
                                                              (item) =>
                                                                  item["currency"] ==
                                                                  quotationCont
                                                                      .itemsPricesCurrencies[selectedItemId],
                                                            );

                                                    var result =
                                                        matchedItems.isNotEmpty
                                                            ? matchedItems.reduce(
                                                              (a, b) =>
                                                                  DateTime.parse(
                                                                        a["start_date"],
                                                                      ).isAfter(
                                                                        DateTime.parse(
                                                                          b["start_date"],
                                                                        ),
                                                                      )
                                                                      ? a
                                                                      : b,
                                                            )
                                                            : null;
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
                                                    var matchedItems =
                                                        exchangeRatesController
                                                            .exchangeRatesList
                                                            .where(
                                                              (item) =>
                                                                  item["currency"] ==
                                                                  quotationCont
                                                                      .itemsPricesCurrencies[selectedItemId],
                                                            );

                                                    var result =
                                                        matchedItems.isNotEmpty
                                                            ? matchedItems.reduce(
                                                              (a, b) =>
                                                                  DateTime.parse(
                                                                        a["start_date"],
                                                                      ).isAfter(
                                                                        DateTime.parse(
                                                                          b["start_date"],
                                                                        ),
                                                                      )
                                                                      ? a
                                                                      : b,
                                                            )
                                                            : null;
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
                                                      '${(int.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_quantity']) * double.parse(quotationCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';

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
                              //vat exempt
                              quotationCont.isVatExemptCheckBoxShouldAppear
                                  ? SizedBox(
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
                                              style: TextStyle(fontSize: 12.sp),
                                            ),
                                            leading: Checkbox(
                                              // checkColor: Colors.white,
                                              // fillColor: MaterialStateProperty.resolveWith(getColor),
                                              value:
                                                  quotationCont
                                                      .isVatExemptChecked,
                                              onChanged: (bool? value) {
                                                quotationCont
                                                    .setIsVatExemptChecked(
                                                      value!,
                                                    );
                                                if (value) {
                                                  // priceConditionController.clear();
                                                  priceConditionController
                                                          .text =
                                                      'Prices are before vat';
                                                  quotationCont
                                                      .setIsBeforeVatPrices(
                                                        true,
                                                      );
                                                  vatExemptController.text =
                                                      vatExemptList[0];
                                                  quotationCont
                                                      .setIsVatExempted(
                                                        true,
                                                        false,
                                                        false,
                                                      );
                                                } else {
                                                  // priceConditionController.text='Prices are before vat';
                                                  vatExemptController.clear();
                                                  quotationCont
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
                                        quotationCont.isVatExemptChecked ==
                                                false
                                            ? DropdownMenu<String>(
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.15,
                                              // requestFocusOnTap: false,
                                              enableSearch: true,
                                              controller: vatExemptController,
                                              hintText: '',
                                              textStyle: TextStyle(
                                                fontSize: 12.sp,
                                              ),
                                              inputDecorationTheme: InputDecorationTheme(
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
                                              controller: vatExemptController,
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
                                              enableFilter: false,
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
                                      MediaQuery.of(context).size.width * 0.02,
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
                                            MediaQuery.of(context).size.width *
                                            0.28,
                                      ),
                                      TableTitle(
                                        text: 'quantity'.tr,
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                            MediaQuery.of(context).size.width *
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
                                            MediaQuery.of(context).size.width *
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
                                        quotationCont.listViewLengthInQuotation,
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
                                              row['line_type_id'] ?? '';

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
                                            //     //       key.toString(),
                                            //     //     );
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
                                                            )
                                                            : lineType == '2'
                                                            ? ReusableItemRow(
                                                              index: key,
                                                            )
                                                            : lineType == '3'
                                                            ? ReusableComboRow(
                                                              index: key,
                                                            )
                                                            : lineType == '4'
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      // Row(
                                      //   children: [
                                      //     IconButton(
                                      //       icon: const Icon(Icons.save_alt),
                                      //       onPressed: () async {
                                      //         _saveTermsAndConditions();
                                      //       },
                                      //     ),
                                      //     gapW6,
                                      //     IconButton(
                                      //       icon: const Icon(Icons.restore),
                                      //       onPressed:
                                      //           showLastTermsAndConditionsList,
                                      //     ),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                  gapH16,
                                  // ReusableTextField(
                                  //   textEditingController:
                                  //       termsAndConditionsController,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'terms_and_conditions'.tr,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: TypographyColor.titleTable,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  gapH16,
                                  GetBuilder<TermsAndConditionsController>(
                                    builder: (cont) {
                                      return ReusableDropDownMenuWithSearch(
                                        key: ValueKey(cont.termsAndConditionsNamesList.length),
                                        list: cont.termsAndConditionsNamesList,
                                        text: '',
                                        hint: '${'search'.tr}...',
                                        controller:
                                            termsAndConditionsMenuController,
                                        onSelected: (String? val) {
                                          int index = cont
                                              .termsAndConditionsNamesList
                                              .indexOf(val!);
                                          quotationCont
                                              .setSelectedTermAndConditionId(
                                                cont.termsAndConditionsIdsList[index],
                                              );
                                        },
                                        validationFunc: (value) {},
                                        rowWidth:
                                            MediaQuery.of(context).size.width *
                                            0.24,
                                        textFieldWidth:
                                            MediaQuery.of(context).size.width *
                                            0.24,
                                        clickableOptionText:
                                            'or_create_new_terms_and_conditions'
                                                .tr,
                                        isThereClickableOption: true,
                                        onTappedClickableOption: () {
                                          showDialog<String>(
                                            context: context,
                                            builder:
                                                (
                                                  BuildContext context,
                                                ) => AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  contentPadding:
                                                      const EdgeInsets.all(0),
                                                  titlePadding:
                                                      const EdgeInsets.all(0),
                                                  actionsPadding:
                                                      const EdgeInsets.all(0),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                              Radius.circular(
                                                                9,
                                                              ),
                                                            ),
                                                      ),
                                                  elevation: 0,
                                                  content:
                                                      configDialogs['terms_and_conditions'],
                                                ),
                                          );
                                        },
                                      );
                                    },
                                  ),
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
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('total_before_vat'.tr),
                                            ReusableShowInfoCard(
                                              text: formatDoubleWithCommas(
                                                quotationCont.totalItems,
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
                                                      quotationCont.setGlobalDisc(
                                                        globalDiscountPercentage,
                                                      );
                                                    },
                                                    validationFunc: (val) {},
                                                  ),
                                                ),
                                                gapW10,
                                                ReusableShowInfoCard(
                                                  text: formatDoubleWithCommas(
                                                    double.parse(
                                                      quotationCont.globalDisc,
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
                                                      quotationCont.setSpecialDisc(
                                                        specialDiscountPercentage,
                                                      );
                                                    },
                                                    validationFunc: (val) {},
                                                  ),
                                                ),
                                                gapW10,
                                                ReusableShowInfoCard(
                                                  text: formatDoubleWithCommas(
                                                    double.parse(
                                                      quotationCont.specialDisc,
                                                    ),
                                                  ),

                                                  // quotationCont.specialDisc,
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
                                        quotationCont.isVatNoPrinted
                                            ? SizedBox()
                                            : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  quotationCont
                                                          .isPrintedAsVatExempt
                                                      ? 'vat_exempt'.tr
                                                          .toUpperCase()
                                                      : quotationCont
                                                          .isPrintedAs0
                                                      ? '${'vat'.tr} 0%'
                                                      : 'vat'.tr,
                                                ),
                                                Row(
                                                  children: [
                                                    ReusableShowInfoCard(
                                                      text: formatDoubleWithCommas(
                                                        double.parse(
                                                          quotationCont
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
                                                      text:
                                                          formatDoubleWithCommas(
                                                            double.parse(
                                                              quotationCont
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
                            ),
                            gapH28,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ReusableButtonWithColor(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height: 45,
                                  onTapFunction: () async {
                                    bool
                                    hasType1WithEmptyTitle = quotationController
                                        .rowsInListViewInQuotation
                                        .values
                                        .any((map) {
                                          return map['line_type_id'] == '1' &&
                                              (map['title']?.isEmpty ?? true);
                                        });
                                    bool
                                    hasType2WithEmptyId = quotationController
                                        .rowsInListViewInQuotation
                                        .values
                                        .any((map) {
                                          return map['line_type_id'] == '2' &&
                                              (map['item_id']?.isEmpty ?? true);
                                        });
                                    bool
                                    hasType3WithEmptyId = quotationController
                                        .rowsInListViewInQuotation
                                        .values
                                        .any((map) {
                                          return map['line_type_id'] == '3' &&
                                              (map['combo']?.isEmpty ?? true);
                                        });
                                    bool
                                    hasType4WithEmptyImage = quotationController
                                        .rowsInListViewInQuotation
                                        .values
                                        .any((map) {
                                          return map['line_type_id'] == '4' &&
                                              (map['image'] == Uint8List(0) ||
                                                  map['image']?.isEmpty);
                                        });
                                    bool
                                    hasType5WithEmptyNote = quotationController
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
                                      _saveContent();
                                      var res = await storeQuotations(
                                        refController.text,
                                        selectedCustomerIds,
                                        validityController.text,
                                        inputDateController.text,
                                        quotationCont.selectedPaymentTermId,
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
                                        quotationController.vat11
                                            .toString(), //vat
                                        quotationController.vatInPrimaryCurrency
                                            .toString(),
                                        quotationController
                                            .totalQuotation, // quotationController.totalQuotation

                                        quotationCont.isVatExemptChecked
                                            ? '1'
                                            : '0',
                                        quotationCont.isVatNoPrinted
                                            ? '1'
                                            : '0',
                                        quotationCont.isPrintedAsVatExempt
                                            ? '1'
                                            : '0',
                                        quotationCont.isPrintedAs0 ? '1' : '0',
                                        quotationCont.isBeforeVatPrices
                                            ? '0'
                                            : '1',
                                        quotationCont.isBeforeVatPrices
                                            ? '1'
                                            : '0',
                                        codeController.text,
                                        quotationController
                                            .rowsInListViewInQuotation,
                                        // quotationController.newRowMap,
                                        quotationCont.orderedKeys,
                                        titleController.text,
                                        quotationCont.selectedDeliveryTermId,
                                        chanceController.text,
                                            isItHasTwoHeaders
                                            ? quotationCont
                                                .headersList[quotationCont
                                                        .selectedHeaderIndex -
                                                    1]['id']
                                                .toString()
                                            : '',
                                        quotationCont
                                            .selectedTermAndConditionId,
                                      );
                                      if (res['success'] == true) {
                                        CommonWidgets.snackBar(
                                          'Success',
                                          res['message'],
                                        );
                                        homeController.selectedTab.value =
                                            'pending_quotation';
                                      } else {
                                        CommonWidgets.snackBar(
                                          'error',
                                          res['message'],
                                        );
                                      }
                                    }
                                  },
                                  btnText: 'create_quotation'.tr,
                                ),
                              ],
                            ),
                          ],
                        )
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
                                          MediaQuery.of(context).size.width *
                                          0.3,
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
                                          MediaQuery.of(context).size.width *
                                          0.3,
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
                                          MediaQuery.of(context).size.width *
                                          0.3,
                                      textFieldWidth:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                      onSelected: (value) {
                                        var index = quotationCont
                                            .cashingMethodsNamesList
                                            .indexOf(value);
                                        quotationCont
                                            .setSelectedCashingMethodId(
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
                                      textEditingController:
                                          commissionController,
                                      text: 'commission'.tr,
                                      rowWidth:
                                          MediaQuery.of(context).size.width *
                                          0.3,
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
                                          MediaQuery.of(context).size.width *
                                          0.3,
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
                    gapH40,
                  ],
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
  TextEditingController titleController = TextEditingController();
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
          'combo': '',
        });
    // Widget p = ReusableTitleRow(index: quotationController.quotationCounter);
    //
    // quotationController.addToOrderLinesInQuotationList(
    //   '${quotationController.quotationCounter}',
    //   p,
    // );
  }

  addNewItem() {
    setState(() {
      quotationController.quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
    );

    // int index = quotationController.orderLinesQuotationList.length + 1;

    quotationController
        .addToRowsInListViewInQuotation(quotationController.quotationCounter, {
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
          'combo': '',
        });
    quotationController.addToUnitPriceControllers(
      quotationController.quotationCounter,
    );
    // Widget p = ReusableItemRow(index: quotationController.quotationCounter);
    //
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
          'item_quantity': '0',
          'item_unit_price': '0',
          'item_total': '0',
          'title': '',
          'note': '',
          'combo': '',
        });
    quotationController.addToCombosPricesControllers(
      quotationController.quotationCounter,
    );

    // Widget p = ReusableComboRow(index: quotationController.quotationCounter);
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
      quotationController.increment + 50,
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
          'combo': '',
          'image': Uint8List(0),
        });
    // Widget p = ReusableImageRow(index: quotationController.quotationCounter);
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
          'combo': '',
        });

    // Widget p = ReusableNoteRow(index: quotationController.quotationCounter);

    // quotationController.addToOrderLinesInQuotationList(
    //   '${quotationController.quotationCounter}',
    //   p,
    // );
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

  // String qty = '0';
  final ProductController productController = Get.find();

  TextEditingController itemCodeController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final QuotationController quotationController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();
  List<String> itemsList = [];
  String selectedItemId = '';
  int selectedItem = 0;
  bool isDataFetched = false;

  List items = [];
  String mainDescriptionVar = '';
  String mainCode = '';
  String itemName = '';
  String totalLine = '0';
  bool isSelected = false;
  String? selectedValue;
  final focus = FocusNode(); //price
  final focus1 = FocusNode(); //disc
  final dropFocus = FocusNode(); //dropdown
  final quantityFocus = FocusNode(); //quantity
  double taxRate = 1;
  double taxValue = 0;
  @override
  void initState() {
    // discountController.text = '0';
    // qtyController.text = '0';
    // discount = '0';
    // quantity = '0';
    if (quotationController.rowsInListViewInQuotation[widget
            .index]['item_id'] !=
        '') {
      quotationController.unitPriceControllers[widget.index]!.text =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_unit_price'];
    }
    itemName =
        quotationController.rowsInListViewInQuotation[widget.index]['itemName'];
    selectedItemId =
        quotationController.rowsInListViewInQuotation[widget.index]['item_id'];
    itemCodeController.text =
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
    itemCodeController.text =
        quotationController.rowsInListViewInQuotation[widget
            .index]['item_main_code'];

    super.initState();
  }

  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuotationController>(
      builder: (cont) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => ReusableDropDownMenusWithSearch(
                  list:
                      cont.itemsMultiPartList,
                  searchList: cont.items.map((item) => {
                    "id": '${item["id"]}',
                    "codes": cont.allCodesForItem['${item["id"]}'],
                  }).toList(),
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
                      descriptionController.text =
                          cont.itemsDescription[selectedItemId]!;

                      if (cont.itemsPricesCurrencies[selectedItemId] ==
                          cont.selectedCurrencyName) {
                        cont.unitPriceControllers[widget.index]!.text =
                            cont.itemUnitPrice[selectedItemId].toString();
                      } else if (cont.selectedCurrencyName == 'USD' &&
                          cont.itemsPricesCurrencies[selectedItemId] !=
                              cont.selectedCurrencyName) {
                        var matchedItems = exchangeRatesController
                            .exchangeRatesList
                            .where(
                              (item) =>
                                  item["currency"] ==
                                  cont.itemsPricesCurrencies[selectedItemId],
                            );

                        var result =
                            matchedItems.isNotEmpty
                                ? matchedItems.reduce(
                                  (a, b) =>
                                      DateTime.parse(a["start_date"]).isAfter(
                                            DateTime.parse(b["start_date"]),
                                          )
                                          ? a
                                          : b,
                                )
                                : null;
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
                        var matchedItems = exchangeRatesController
                            .exchangeRatesList
                            .where(
                              (item) =>
                                  item["currency"] ==
                                  cont.itemsPricesCurrencies[selectedItemId],
                            );

                        var result =
                            matchedItems.isNotEmpty
                                ? matchedItems.reduce(
                                  (a, b) =>
                                      DateTime.parse(a["start_date"]).isAfter(
                                            DateTime.parse(b["start_date"]),
                                          )
                                          ? a
                                          : b,
                                )
                                : null;
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
                      cont.setEnteredQtyInQuotation(widget.index, quantity);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
                      // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
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
                    if (quotationController.rowsInListViewInQuotation[widget
                                .index]['item_main_code'] !=
                            '' ||
                        quotationController.rowsInListViewInQuotation[widget
                                .index]['item_main_code'] !=
                            null) {
                      return null;
                    } else if (value == null || value.isEmpty) {
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
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
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
                    // _formKey.currentState!.validate();
                    cont.setMainDescriptionInQuotation(
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
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
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

                    // _formKey.currentState!.validate();
                    // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));

                    cont.setEnteredQtyInQuotation(widget.index, val);
                    cont.setMainTotalInQuotation(widget.index, totalLine);
                    // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
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
                      // _formKey.currentState!.validate();
                      // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                      cont.setEnteredUnitPriceInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
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
                        'item_quantity': '0',
                        'item_unit_price': '0',
                        'item_total': '0',
                        'title': '',
                        'note': '',
                        'combo': '',
                      },
                    );
                    quotationController.addToUnitPriceControllers(
                      quotationController.quotationCounter,
                    );
                    // Widget p = ReusableItemRow(
                    //   index: quotationController.quotationCounter,
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
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
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
                    // _formKey.currentState!.validate();

                    // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                    cont.setEnteredDiscInQuotation(widget.index, val);
                    cont.setMainTotalInQuotation(widget.index, totalLine);
                    await cont.getTotalItems();
                  },
                ),
              ),

              //total
              Obx(
                () => ReusableShowInfoCard(
                  text: formatDoubleWithCommas(
                    double.parse(
                      cont.rowsInListViewInQuotation[widget
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
                                              content: ShowItemQuantitiesDialog(
                                                selectedItemId: selectedItemId,
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
                            quotationController
                                .decrementListViewLengthInQuotation(
                                  quotationController.increment,
                                );
                            quotationController
                                .removeFromRowsInListViewInQuotation(
                                  widget.index,
                                );
                            // quotationController
                            //     .removeFromOrderLinesInQuotationList(
                            //       widget.index.toString(),
                            //     );
                          });
                          setState(() {
                            cont.totalItems = 0.0;
                            cont.globalDisc = "0.0";
                            cont.globalDiscountPercentageValue = "0.0";
                            cont.specialDisc = "0.0";
                            cont.specialDiscountPercentageValue = "0.0";
                            cont.vat11 = "0.0";
                            cont.vatInPrimaryCurrency = "0.0";
                            cont.totalQuotation = "0.0";
                          });
                          if (cont.rowsInListViewInQuotation != {}) {
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
  final QuotationController quotationController = Get.find();
  String titleValue = '0';

  @override
  void initState() {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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
                            quotationController
                                .decrementListViewLengthInQuotation(
                                  quotationController.increment,
                                );
                            quotationController
                                .removeFromRowsInListViewInQuotation(
                                  widget.index,
                                );
                            // quotationController
                            //     .removeFromOrderLinesInQuotationList(
                            //       widget.index.toString(),
                            //     );
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
  final QuotationController quotationController = Get.find();
  String noteValue = '';

  @override
  void initState() {
    noteController.text =
        quotationController.rowsInListViewInQuotation[widget.index]['note'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //image
          // Container(
          //   width: MediaQuery.of(context).size.width * 0.02,
          //   height: 20,
          //   margin: const EdgeInsets.symmetric(vertical: 15),
          //   decoration: const BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage('assets/images/newRow.png'),
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
          Expanded(
            // width: MediaQuery.of(context).size.width * 0.63,
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
                        quotationController.decrementListViewLengthInQuotation(
                          quotationController.increment,
                        );
                        quotationController.removeFromRowsInListViewInQuotation(
                          widget.index,
                        );
                        // quotationController
                        //     .removeFromOrderLinesInQuotationList(
                        //       widget.index.toString(),
                        //     );
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
  final QuotationController quotationController = Get.find();
  final HomeController homeController = Get.find();
  late Uint8List imageFile;

  double listViewLength = Sizes.deviceHeight * 0.08;

  @override
  void initState() {
    imageFile =
        quotationController.rowsInListViewInQuotation[widget.index]['image'];
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //image
          // Container(
          //   width: MediaQuery.of(context).size.width * 0.02,
          //   height: 20,
          //   margin: const EdgeInsets.symmetric(vertical: 15),
          //   decoration: const BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage('assets/images/newRow.png'),
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
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
                    child: Obx(
                      () => SizedBox(
                        width:
                            homeController.isOpened.value
                                ? MediaQuery.of(context).size.width * 0.62
                                : MediaQuery.of(context).size.width * 0.79,
                        height: cont.imageSpaceHeight,
                        child:
                            imageFile.isNotEmpty
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.memory(
                                      imageFile,
                                      height: cont.imageSpaceHeight,
                                    ),
                                  ],
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                      style: TextStyle(color: Primary.primary),
                                    ),
                                  ],
                                ),
                      ),
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
                        quotationController.decrementListViewLengthInQuotation(
                          quotationController.increment + 50,
                        );
                        quotationController.removeFromRowsInListViewInQuotation(
                          widget.index,
                        );
                        // quotationController
                        //     .removeFromOrderLinesInQuotationList(
                        //       widget.index.toString(),
                        //     );
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

  TextEditingController comboCodeController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final QuotationController quotationController = Get.find();
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
  @override
  void initState() {
    if (quotationController.rowsInListViewInQuotation[widget.index]['combo'] !=
        '') {
      quotationController.combosPriceControllers[widget.index]!.text =
          quotationController.rowsInListViewInQuotation[widget
              .index]['item_unit_price'];
      selectedComboId =
          quotationController.rowsInListViewInQuotation[widget.index]['combo'];
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
    descriptionVar =
        quotationController.rowsInListViewInQuotation[widget
            .index]['item_description'];
    totalLine =
        quotationController.rowsInListViewInQuotation[widget
            .index]['item_total'];
    comboCodeController.text =
        quotationController.rowsInListViewInQuotation[widget
            .index]['item_main_code'];
    super.initState();
  }

  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuotationController>(
      builder: (cont) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 5),
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
                        var matchedItems = exchangeRatesController
                            .exchangeRatesList
                            .where(
                              (item) =>
                                  item["currency"] ==
                                  cont.combosPricesCurrencies[selectedComboId],
                            );

                        var result =
                            matchedItems.isNotEmpty
                                ? matchedItems.reduce(
                                  (a, b) =>
                                      DateTime.parse(a["start_date"]).isAfter(
                                            DateTime.parse(b["start_date"]),
                                          )
                                          ? a
                                          : b,
                                )
                                : null;

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
                        var matchedItems = exchangeRatesController
                            .exchangeRatesList
                            .where(
                              (item) =>
                                  item["currency"] ==
                                  cont.combosPricesCurrencies[selectedComboId],
                            );

                        var result =
                            matchedItems.isNotEmpty
                                ? matchedItems.reduce(
                                  (a, b) =>
                                      DateTime.parse(a["start_date"]).isAfter(
                                            DateTime.parse(b["start_date"]),
                                          )
                                          ? a
                                          : b,
                                )
                                : null;
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
                      cont.setEnteredQtyInQuotation(widget.index, quantity);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
                      // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
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
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
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
                    // _formKey.currentState!.validate();
                    cont.setMainDescriptionInQuotation(
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
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
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

                    // _formKey.currentState!.validate();
                    // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));

                    cont.setEnteredQtyInQuotation(widget.index, val);
                    cont.setMainTotalInQuotation(widget.index, totalLine);
                    // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
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
                          cont.combosPriceControllers[widget.index]!.text = '0';
                        } else {
                          // cont.unitPriceControllers[widget.index]!.text = val;
                        }
                        // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';
                        totalLine =
                            '${(int.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
                      });
                      // _formKey.currentState!.validate();
                      // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                      cont.setEnteredUnitPriceInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
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
                        'item_quantity': '0',
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
                    // );
                    // quotationController.addToOrderLinesInQuotationList(
                    //   '${quotationController.quotationCounter}',
                    //   p,
                    // );
                    // cont.setEnteredQtyInQuotation(
                    //   quotationController.quotationCounter,
                    //   quantity,
                    // );
                    // cont.setMainTotalInQuotation(
                    //   quotationController.quotationCounter,
                    //   totalLine,
                    // );
                    // cont.getTotalItems();
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
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
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
                    // _formKey.currentState!.validate();

                    // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                    cont.setEnteredDiscInQuotation(widget.index, val);
                    cont.setMainTotalInQuotation(widget.index, totalLine);
                    await cont.getTotalItems();
                  },
                ),
              ),

              //total
              Obx(
                () => ReusableShowInfoCard(
                  text: formatDoubleWithCommas(
                    double.parse(
                      cont.rowsInListViewInQuotation[widget
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
                            quotationController
                                .decrementListViewLengthInQuotation(
                                  quotationController.increment,
                                );
                            quotationController
                                .removeFromRowsInListViewInQuotation(
                                  widget.index,
                                );
                            // quotationController
                            //     .removeFromOrderLinesInQuotationList(
                            //       widget.index.toString(),
                            //     );
                          });
                          setState(() {
                            cont.totalItems = 0.0;
                            cont.globalDisc = "0.0";
                            cont.globalDiscountPercentageValue = "0.0";
                            cont.specialDisc = "0.0";
                            cont.specialDiscountPercentageValue = "0.0";
                            cont.vat11 = "0.0";
                            cont.vatInPrimaryCurrency = "0.0";
                            cont.totalQuotation = "0.0";
                          });
                          if (cont.rowsInListViewInQuotation != {}) {
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
    return GetBuilder<QuotationController>(
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

// //mobile
// class MobileCreateNewQuotation extends StatefulWidget {
//   const MobileCreateNewQuotation({super.key});
//
//   @override
//   State<MobileCreateNewQuotation> createState() =>
//       _MobileCreateNewQuotationState();
// }
//
// class _MobileCreateNewQuotationState extends State<MobileCreateNewQuotation> {
//   String selectedSalesPerson = '';
//   int selectedSalesPersonId = 0;
//   // bool imageAvailable=false;
//   GlobalKey accMoreKey2 = GlobalKey();
//   TextEditingController commissionController = TextEditingController();
//   TextEditingController totalCommissionController = TextEditingController();
//   TextEditingController refController = TextEditingController();
//   TextEditingController validityController = TextEditingController();
//   TextEditingController searchController = TextEditingController();
//   String selectedPaymentTerm = '',
//       selectedPriceList = '',
//       selectedCurrency = '',
//       termsAndConditions = '',
//       specialDisc = '',
//       globalDisc = '';
//   late Uint8List imageFile;
//
//   int currentStep = 0;
//   int selectedTabIndex = 0;
//   GlobalKey accMoreKey = GlobalKey();
//   List tabsList = ['order_lines', 'other_information'];
//   String selectedTab = 'order_lines'.tr;
//   String? selectedItem = '';
//
//   double listViewLength = Sizes.deviceHeight * 0.08;
//   double increment = Sizes.deviceHeight * 0.08;
//   // double imageSpaceHeight = Sizes.deviceHeight * 0.1;
//   // List<Widget> orderLinesList = [];
//   final QuotationController quotationController = Get.find();
//   final HomeController homeController = Get.find();
//   int progressVar = 0;
//   Map data = {};
//   bool isQuotationsInfoFetched = false;
//   List<String> customerNameList = [];
//   List<String> customerTitleList = [];
//   List customerIdsList = [];
//   String selectedCustomerIds = '';
//   String quotationNumber = '';
//   getFieldsForCreateQuotationFromBack() async {
//     setState(() {
//       selectedPaymentTerm = '';
//       selectedPriceList = '';
//       selectedCurrency = '';
//       termsAndConditions = '';
//       specialDisc = '';
//       globalDisc = '';
//       currentStep = 0;
//       selectedTabIndex = 0;
//       selectedItem = '';
//       progressVar = 0;
//       selectedCustomerIds = '';
//
//       quotationNumber = '';
//       data = {};
//       customerNameList = [];
//       customerIdsList = [];
//     });
//     var p = await getFieldsForCreateQuotation();
//     if ('$p' != '[]') {
//       setState(() {
//         data.addAll(p);
//         quotationNumber = p['quotationNumber'].toString();
//         for (var client in p['clients']) {
//           customerNameList.add('${client['name']}');
//           customerIdsList.add('${client['id']}');
//         }
//         isQuotationsInfoFetched = true;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     getFieldsForCreateQuotationFromBack();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isQuotationsInfoFetched
//         ? Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: MediaQuery.of(context).size.width * 0.03,
//       ),
//       height: MediaQuery.of(context).size.height * 0.75,
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [PageTitle(text: 'create_new_quotation'.tr)],
//             ),
//             gapH16,
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 UnderTitleBtn(
//                   text: 'preview'.tr,
//                   onTap: () {
//                     // setState(() {
//                     //   // progressVar+=1;
//                     // });
//                   },
//                 ),
//                 UnderTitleBtn(
//                   text: 'send_by_email'.tr,
//                   onTap: () {
//                     if (progressVar == 0) {
//                       setState(() {
//                         progressVar += 1;
//                       });
//                     }
//                   },
//                 ),
//                 UnderTitleBtn(
//                   text: 'confirm'.tr,
//                   onTap: () {
//                     if (progressVar == 1) {
//                       setState(() {
//                         progressVar += 1;
//                       });
//                     }
//                   },
//                 ),
//                 UnderTitleBtn(
//                   text: 'cancel'.tr,
//                   onTap: () {
//                     setState(() {
//                       progressVar = 0;
//                     });
//                   },
//                 ),
//                 // UnderTitleBtn(
//                 //   text: 'task'.tr,
//                 //   onTap: () {
//                 //     showDialog<String>(
//                 //         context: context,
//                 //         builder: (BuildContext context) =>
//                 //         const AlertDialog(
//                 //             backgroundColor: Colors.white,
//                 //             shape: RoundedRectangleBorder(
//                 //               borderRadius: BorderRadius.all(
//                 //                   Radius.circular(9)),
//                 //             ),
//                 //             elevation: 0,
//                 //             content: ScheduleTaskDialogContent()));
//                 //   },
//                 // ),
//               ],
//             ),
//             gapH10,
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 ReusableTimeLineTile(
//                   id: 0,
//                   isDesktop: false,
//                   progressVar: progressVar,
//                   isFirst: true,
//                   isLast: false,
//                   isPast: true,
//                   text: 'processing'.tr,
//                 ),
//                 ReusableTimeLineTile(
//                   id: 1,
//                   progressVar: progressVar,
//                   isFirst: false,
//                   isDesktop: false,
//                   isLast: false,
//                   isPast: false,
//                   text: 'quotation_sent'.tr,
//                 ),
//                 ReusableTimeLineTile(
//                   id: 2,
//                   progressVar: progressVar,
//                   isFirst: false,
//                   isLast: true,
//                   isDesktop: false,
//                   isPast: false,
//                   text: 'confirmed'.tr,
//                 ),
//               ],
//             ),
//             gapH24,
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 20,
//                 vertical: 20,
//               ),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Others.divider),
//                 borderRadius: const BorderRadius.all(Radius.circular(9)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   isQuotationsInfoFetched
//                       ? Text(
//                     quotationNumber, //'${data['quotationNumber'].toString() ?? ''}',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                       color: TypographyColor.titleTable,
//                     ),
//                   )
//                       : const CircularProgressIndicator(),
//                   gapH16,
//                   DialogTextField(
//                     textEditingController: refController,
//                     text: '${'ref'.tr}:',
//                     hint: 'manual_reference'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth: MediaQuery.of(context).size.width * 0.5,
//                     validationFunc: (val) {},
//                   ),
//                   gapH16,
//                   DialogDropMenu(
//                     optionsList: ['usd'.tr, 'lbp'.tr],
//                     text: 'currency'.tr,
//                     hint: 'usd'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth: MediaQuery.of(context).size.width * 0.1,
//                     onSelected: (value) {
//                       setState(() {
//                         selectedCurrency = value;
//                       });
//                     },
//                   ),
//                   gapH16,
//
//                   DialogTextField(
//                     textEditingController: validityController,
//                     text: 'validity'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth: MediaQuery.of(context).size.width * 0.5,
//                     validationFunc: (val) {},
//                   ),
//                   gapH16,
//
//                   DialogTextField(
//                     textEditingController: validityController,
//                     text: 'code'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth: MediaQuery.of(context).size.width * 0.5,
//                     validationFunc: (val) {},
//                   ),
//                   gapH16,
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('${'name'.tr}*'),
//                         DropdownMenu<String>(
//                           width: MediaQuery.of(context).size.width * 0.5,
//                           // requestFocusOnTap: false,
//                           enableSearch: true,
//                           controller: searchController,
//                           hintText: '${'search'.tr}...',
//                           inputDecorationTheme: InputDecorationTheme(
//                             // filled: true,
//                             hintStyle: const TextStyle(
//                               fontStyle: FontStyle.italic,
//                             ),
//                             contentPadding: const EdgeInsets.fromLTRB(
//                               20,
//                               0,
//                               25,
//                               5,
//                             ),
//                             // outlineBorder: BorderSide(color: Colors.black,),
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Primary.primary.withAlpha(
//                                   (0.2 * 255).toInt(),
//                                 ),
//                                 width: 1,
//                               ),
//                               borderRadius: const BorderRadius.all(
//                                 Radius.circular(9),
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Primary.primary.withAlpha(
//                                   (0.4 * 255).toInt(),
//                                 ),
//                                 width: 2,
//                               ),
//                               borderRadius: const BorderRadius.all(
//                                 Radius.circular(9),
//                               ),
//                             ),
//                           ),
//                           // menuStyle: ,
//                           menuHeight: 250,
//                           dropdownMenuEntries:
//                           customerNameList
//                               .map<DropdownMenuEntry<String>>((
//                               String option,
//                               ) {
//                             return DropdownMenuEntry<String>(
//                               value: option,
//                               label: option,
//                             );
//                           })
//                               .toList(),
//                           enableFilter: true,
//                           onSelected: (String? val) {
//                             setState(() {
//                               selectedItem = val!;
//                               var index = customerNameList.indexOf(val);
//                               selectedCustomerIds = customerIdsList[index];
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   gapH16,
//
//                   // Row(
//                   //   mainAxisAlignment: MainAxisAlignment.start,
//                   //   children: [
//                   //     Text('contact_details'.tr),
//                   //   ],
//                   // ),
//                   // gapH16,
//                   DialogDropMenu(
//                     optionsList: ['cash'.tr, 'on_account'.tr],
//                     text: 'payment_terms'.tr,
//                     hint: 'cash'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth: MediaQuery.of(context).size.width * 0.5,
//                     onSelected: (value) {
//                       setState(() {
//                         selectedPaymentTerm = value;
//                       });
//                     },
//                   ),
//                   gapH16,
//                   DialogDropMenu(
//                     optionsList: ['standard'.tr],
//                     text: 'price_list'.tr,
//                     hint: 'standard'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth: MediaQuery.of(context).size.width * 0.5,
//                     onSelected: (value) {
//                       setState(() {
//                         selectedPriceList = value;
//                       });
//                     },
//                   ),
//                   gapH16,
//                 ],
//               ),
//             ),
//             // Container(
//             //   padding:
//             //   const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             //   decoration: BoxDecoration(
//             //       border: Border.all(color: Others.divider),
//             //       borderRadius: const BorderRadius.all(Radius.circular(9))),
//             //   child: Row(
//             //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //     crossAxisAlignment: CrossAxisAlignment.start,
//             //     children: [
//             //
//             //       SizedBox(
//             //         width: MediaQuery.of(context).size.width * 0.3,
//             //         child: Column(
//             //           crossAxisAlignment: CrossAxisAlignment.start,
//             //           children: [
//             //             // SizedBox(
//             //             //   width: MediaQuery.of(context).size.width * 0.25,
//             //             //   child: Row(
//             //             //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //             //     children: [
//             //             //       Text('validity'.tr),
//             //             //       DialogDateTextField(
//             //             //         text: '',
//             //             //         textFieldWidth:
//             //             //             MediaQuery.of(context).size.width * 0.15,
//             //             //         validationFunc: () {},
//             //             //         onChangedFunc: (value) {
//             //             //           setState(() {
//             //             //             validity=value;
//             //             //           });
//             //             //         },
//             //             //       ),
//             //             //     ],
//             //             //   ),
//             //             // ),
//             //
//             //           ],
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             gapH16,
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Wrap(
//                   spacing: 0.0,
//                   direction: Axis.horizontal,
//                   children:
//                   tabsList
//                       .map(
//                         (element) => _buildTabChipItem(
//                       element,
//                       // element['id'],
//                       // element['name'],
//                       tabsList.indexOf(element),
//                     ),
//                   )
//                       .toList(),
//                 ),
//               ],
//             ),
//             // tabsContent[selectedTabIndex],
//             selectedTabIndex == 0
//                 ? Column(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     // horizontal:
//                     //     MediaQuery.of(context).size.width * 0.01,
//                     vertical: 15,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Primary.primary,
//                     borderRadius: const BorderRadius.all(
//                       Radius.circular(6),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
//                       TableTitle(
//                         text: 'item_code'.tr,
//                         width: MediaQuery.of(context).size.width * 0.13,
//                       ),
//                       TableTitle(
//                         text: 'description'.tr,
//                         width: MediaQuery.of(context).size.width * 0.27,
//                       ),
//                       TableTitle(
//                         text: 'quantity'.tr,
//                         width: MediaQuery.of(context).size.width * 0.05,
//                       ),
//                       TableTitle(
//                         text: 'unit_price'.tr,
//                         width: MediaQuery.of(context).size.width * 0.05,
//                       ),
//                       TableTitle(
//                         text: '${'disc'.tr}. %',
//                         width: MediaQuery.of(context).size.width * 0.05,
//                       ),
//                       TableTitle(
//                         text: 'total'.tr,
//                         width: MediaQuery.of(context).size.width * 0.07,
//                       ),
//                       TableTitle(
//                         text: '     ${'more_options'.tr}',
//                         width: MediaQuery.of(context).size.width * 0.07,
//                       ),
//                     ],
//                   ),
//                 ),
//                 GetBuilder<QuotationController>(
//                   builder: (cont) {
//                     return Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal:
//                         MediaQuery.of(context).size.width * 0.01,
//                       ),
//                       decoration: const BoxDecoration(
//                         borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(6),
//                           bottomRight: Radius.circular(6),
//                         ),
//                         color: Colors.white,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: listViewLength,
//                             child: ListView.builder(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 10,
//                               ),
//                               itemCount: 5,
//                               // cont.orderLinesList
//                               //     .length, //products is data from back res
//                               itemBuilder:
//                                   (context, index) => Row(
//                                 children: [
//                                   Container(
//                                     width: 20,
//                                     height: 20,
//                                     margin:
//                                     const EdgeInsets.symmetric(
//                                       vertical: 15,
//                                     ),
//                                     decoration: const BoxDecoration(
//                                       image: DecorationImage(
//                                         image: AssetImage(
//                                           'assets/images/newRow.png',
//                                         ),
//                                         fit: BoxFit.contain,
//                                       ),
//                                     ),
//                                   ),
//                                   // cont.orderLinesList[index],
//                                   SizedBox(
//                                     width:
//                                     MediaQuery.of(
//                                       context,
//                                     ).size.width *
//                                         0.03,
//                                     child: const ReusableMore(
//                                       itemsList: [],
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width:
//                                     MediaQuery.of(
//                                       context,
//                                     ).size.width *
//                                         0.03,
//                                     child: InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           // cont.removeFromOrderLinesList(
//                                           //     index);
//                                           listViewLength =
//                                               listViewLength -
//                                                   increment;
//                                         });
//                                       },
//                                       child: Icon(
//                                         Icons.delete_outline,
//                                         color: Primary.primary,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               ReusableAddCard(
//                                 text: 'title'.tr,
//                                 onTap: () {
//                                   addNewTitle();
//                                 },
//                               ),
//                               gapW32,
//                               ReusableAddCard(
//                                 text: 'item'.tr,
//                                 onTap: () {
//                                   addNewItem();
//                                 },
//                               ),
//                               gapW32,
//                               ReusableAddCard(
//                                 text: 'combo'.tr,
//                                 onTap: () {
//                                   addNewCombo();
//                                 },
//                               ),
//                               gapW32,
//                               ReusableAddCard(
//                                 text: 'image'.tr,
//                                 onTap: () {
//                                   addNewImage();
//                                 },
//                               ),
//                               gapW32,
//                               ReusableAddCard(
//                                 text: 'note'.tr,
//                                 onTap: () {
//                                   addNewNote();
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   height: listViewLength + 100,
//                   child: ListView(
//                     // physics: AlwaysScrollableScrollPhysics(),
//                     scrollDirection: Axis.horizontal,
//                     children: [
//                       SizedBox(
//                         height: listViewLength + 100,
//                         width: MediaQuery.of(context).size.width,
//                         child: ListView(
//                           children: [
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal:
//                                 MediaQuery.of(context).size.width *
//                                     0.01,
//                                 vertical: 15,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Primary.primary,
//                                 borderRadius: const BorderRadius.all(
//                                   Radius.circular(6),
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   TableTitle(
//                                     text: 'item_code'.tr,
//                                     width:
//                                     MediaQuery.of(
//                                       context,
//                                     ).size.width *
//                                         0.07,
//                                   ),
//                                   TableTitle(
//                                     text: 'description'.tr,
//                                     width:
//                                     MediaQuery.of(
//                                       context,
//                                     ).size.width *
//                                         0.33,
//                                   ),
//                                   TableTitle(
//                                     text: 'quantity'.tr,
//                                     width:
//                                     MediaQuery.of(
//                                       context,
//                                     ).size.width *
//                                         0.05,
//                                   ),
//                                   TableTitle(
//                                     text: 'unit_price'.tr,
//                                     width:
//                                     MediaQuery.of(
//                                       context,
//                                     ).size.width *
//                                         0.05,
//                                   ),
//                                   TableTitle(
//                                     text: '${'disc'.tr}. %',
//                                     width:
//                                     MediaQuery.of(
//                                       context,
//                                     ).size.width *
//                                         0.05,
//                                   ),
//                                   TableTitle(
//                                     text: 'total'.tr,
//                                     width:
//                                     MediaQuery.of(
//                                       context,
//                                     ).size.width *
//                                         0.07,
//                                   ),
//                                   TableTitle(
//                                     text: '     ${'more_options'.tr}',
//                                     width:
//                                     MediaQuery.of(
//                                       context,
//                                     ).size.width *
//                                         0.07,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             GetBuilder<QuotationController>(
//                               builder: (cont) {
//                                 return Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal:
//                                     MediaQuery.of(
//                                       context,
//                                     ).size.width *
//                                         0.01,
//                                   ),
//                                   decoration: const BoxDecoration(
//                                     borderRadius: BorderRadius.only(
//                                       bottomLeft: Radius.circular(6),
//                                       bottomRight: Radius.circular(6),
//                                     ),
//                                     color: Colors.white,
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       SizedBox(
//                                         height: listViewLength,
//                                         child: ListView.builder(
//                                           padding:
//                                           const EdgeInsets.symmetric(
//                                             vertical: 10,
//                                           ),
//                                           itemCount: 2,
//                                           // cont
//                                           //     .orderLinesList
//                                           //     .length, //products is data from back res
//                                           itemBuilder:
//                                               (context, index) => Row(
//                                             children: [
//                                               Container(
//                                                 width: 20,
//                                                 height: 20,
//                                                 margin:
//                                                 const EdgeInsets.symmetric(
//                                                   vertical: 15,
//                                                 ),
//                                                 decoration: const BoxDecoration(
//                                                   image: DecorationImage(
//                                                     image: AssetImage(
//                                                       'assets/images/newRow.png',
//                                                     ),
//                                                     fit:
//                                                     BoxFit
//                                                         .contain,
//                                                   ),
//                                                 ),
//                                               ),
//                                               // cont.orderLinesList[
//                                               //     index],
//                                               SizedBox(
//                                                 width:
//                                                 MediaQuery.of(
//                                                   context,
//                                                 ).size.width *
//                                                     0.03,
//                                                 child:
//                                                 const ReusableMore(
//                                                   itemsList: [],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       Row(
//                                         children: [
//                                           ReusableAddCard(
//                                             text: 'title'.tr,
//                                             onTap: () {
//                                               addNewTitle();
//                                             },
//                                           ),
//                                           gapW32,
//                                           ReusableAddCard(
//                                             text: 'item'.tr,
//                                             onTap: () {
//                                               addNewItem();
//                                             },
//                                           ),
//                                           gapW32,
//                                           ReusableAddCard(
//                                             text: 'combo'.tr,
//                                             onTap: () {
//                                               addNewCombo();
//                                             },
//                                           ),
//                                           gapW32,
//                                           ReusableAddCard(
//                                             text: 'image'.tr,
//                                             onTap: () {
//                                               addNewImage();
//                                             },
//                                           ),
//                                           gapW32,
//                                           ReusableAddCard(
//                                             text: 'note'.tr,
//                                             onTap: () {
//                                               addNewNote();
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 gapH24,
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 20,
//                     horizontal: 20,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'terms_conditions'.tr,
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: TypographyColor.titleTable,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       gapH16,
//                       ReusableTextField(
//                         textEditingController: controller, //todo
//                         isPasswordField: false,
//                         hint: 'terms_conditions'.tr,
//                         onChangedFunc: () {},
//                         validationFunc: (val) {
//                           setState(() {
//                             termsAndConditions = val;
//                           });
//                         },
//                       ),
//                       gapH16,
//                       Text(
//                         'or_create_new_terms_conditions'.tr,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Primary.primary,
//                           decoration: TextDecoration.underline,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 20,
//                     horizontal: 20,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Primary.p20,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width * 0.8,
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('total_before_vat'.tr),
//                                 Container(
//                                   width:
//                                   MediaQuery.of(
//                                     context,
//                                   ).size.width *
//                                       0.2,
//                                   height: 47,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color:
//                                       Colors.black..withAlpha(
//                                         (0.1 * 255).toInt(),
//                                       ),
//                                       width: 1,
//                                     ),
//                                     borderRadius: BorderRadius.circular(
//                                       6,
//                                     ),
//                                   ),
//                                   child: const Center(child: Text('0')),
//                                 ),
//                               ],
//                             ),
//                             gapH6,
//                             Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('global_disc'.tr),
//                                 Row(
//                                   children: [
//                                     SizedBox(
//                                       width:
//                                       MediaQuery.of(
//                                         context,
//                                       ).size.width *
//                                           0.2,
//                                       child: ReusableTextField(
//                                         textEditingController:
//                                         controller, //todo
//                                         isPasswordField: false,
//                                         hint: '0',
//                                         onChangedFunc: (val) {
//                                           setState(() {
//                                             globalDisc = val;
//                                           });
//                                         },
//                                         validationFunc: (val) {},
//                                       ),
//                                     ),
//                                     gapW10,
//                                     Container(
//                                       width:
//                                       MediaQuery.of(
//                                         context,
//                                       ).size.width *
//                                           0.2,
//                                       height: 47,
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                           color: Colors.black.withAlpha(
//                                             (0.1 * 255).toInt(),
//                                           ),
//                                           width: 1,
//                                         ),
//                                         borderRadius:
//                                         BorderRadius.circular(6),
//                                       ),
//                                       child: const Center(
//                                         child: Text('0'),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             gapH6,
//                             Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('special_disc'.tr),
//                                 Row(
//                                   children: [
//                                     SizedBox(
//                                       width:
//                                       MediaQuery.of(
//                                         context,
//                                       ).size.width *
//                                           0.2,
//                                       child: ReusableTextField(
//                                         textEditingController:
//                                         controller, //todo
//                                         isPasswordField: false,
//                                         hint: '0',
//                                         onChangedFunc: (val) {
//                                           setState(() {
//                                             specialDisc = val;
//                                           });
//                                         },
//                                         validationFunc: (val) {},
//                                       ),
//                                     ),
//                                     gapW10,
//                                     Container(
//                                       width:
//                                       MediaQuery.of(
//                                         context,
//                                       ).size.width *
//                                           0.2,
//                                       height: 47,
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                           color: Colors.black.withAlpha(
//                                             (0.1 * 255).toInt(),
//                                           ),
//                                           width: 1,
//                                         ),
//                                         borderRadius:
//                                         BorderRadius.circular(6),
//                                       ),
//                                       child: const Center(
//                                         child: Text('0'),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             gapH6,
//                             Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('vat_11'.tr),
//                                 Row(
//                                   children: [
//                                     Container(
//                                       width:
//                                       MediaQuery.of(
//                                         context,
//                                       ).size.width *
//                                           0.2,
//                                       height: 47,
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                           color: Colors.black.withAlpha(
//                                             (0.1 * 255).toInt(),
//                                           ),
//                                           width: 1,
//                                         ),
//                                         borderRadius:
//                                         BorderRadius.circular(6),
//                                       ),
//                                       child: const Center(
//                                         child: Text('0'),
//                                       ),
//                                     ),
//                                     gapW10,
//                                     Container(
//                                       width:
//                                       MediaQuery.of(
//                                         context,
//                                       ).size.width *
//                                           0.2,
//                                       height: 47,
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                           color: Colors.black.withAlpha(
//                                             (0.1 * 255).toInt(),
//                                           ),
//                                           width: 1,
//                                         ),
//                                         borderRadius:
//                                         BorderRadius.circular(6),
//                                       ),
//                                       child: const Center(
//                                         child: Text('0.00'),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             gapH10,
//                             Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'total_amount'.tr,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Primary.primary,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${'usd'.tr} 0.00',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Primary.primary,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 gapH28,
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     ReusableButtonWithColor(
//                       width: MediaQuery.of(context).size.width * 0.3,
//                       height: 45,
//                       onTapFunction: () async {
//                         var res = await storeQuotation(
//                           refController.text,
//                           selectedCustomerIds,
//                           validityController.text,
//                           '',
//                           '',
//                           '',
//                           termsAndConditions,
//                           '',
//                           '',
//                           '',
//                           commissionController.text,
//                           totalCommissionController.text,
//                           '',
//                           specialDisc,
//                           '',
//                           globalDisc,
//                           '',
//                           '',
//                           '',
//                           '',
//                         );
//                         if (res['success'] == true) {
//                           CommonWidgets.snackBar(
//                             'Success',
//                             res['message'],
//                           );
//                           setState(() {
//                             isQuotationsInfoFetched = false;
//                             getFieldsForCreateQuotationFromBack();
//                           });
//                           homeController.selectedTab.value =
//                           'quotation_summary';
//                         } else {
//                           CommonWidgets.snackBar(
//                             'error',
//                             res['message'],
//                           );
//                         }
//                       },
//                       btnText: 'create_quotation'.tr,
//                     ),
//                   ],
//                 ),
//               ],
//             )
//                 : Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 20,
//                 vertical: 15,
//               ),
//               decoration: const BoxDecoration(
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(6),
//                   bottomRight: Radius.circular(6),
//                 ),
//                 color: Colors.white,
//               ),
//               child: Column(
//                 children: [
//                   DialogDropMenu(
//                     optionsList:  quotationController.salesPersonListNames,
//                     text: 'sales_person'.tr,
//                     hint: 'search'.tr,
//                     rowWidth:
//                     MediaQuery.of(context).size.width *
//                         0.3,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width *
//                         0.15,
//                     onSelected: (String? val) {
//                       setState(() {
//                         selectedSalesPerson = val!;
//                         var index = quotationController.salesPersonListNames
//                             .indexOf(val);
//                         selectedSalesPersonId =
//                         quotationController.salesPersonListId[index];
//                         print(selectedSalesPerson);
//                         print(selectedSalesPersonId);
//                       });
//
//                     },
//                   ),
//                   gapH16,
//                   DialogDropMenu(
//                     optionsList: const [''],
//                     text: 'commission_method'.tr,
//                     hint: '',
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.4,
//                     onSelected: () {},
//                   ),
//                   gapH16,
//                   DialogDropMenu(
//                     optionsList: ['cash'.tr],
//                     text: 'cashing_method'.tr,
//                     hint: '',
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.4,
//                     onSelected: () {},
//                   ),
//                   gapH16,
//                   DialogTextField(
//                     textEditingController: commissionController,
//                     text: 'commission'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.4,
//                     validationFunc: (val) {},
//                   ),
//                   gapH16,
//                   DialogTextField(
//                     textEditingController: totalCommissionController,
//                     text: 'total_commission'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.4,
//                     validationFunc: (val) {},
//                   ),
//                 ],
//               ),
//             ),
//             gapH40,
//           ],
//         ),
//       ),
//     )
//         : const CircularProgressIndicator();
//   }
//
//   Widget _buildTabChipItem(String name, int index) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedTabIndex = index;
//         });
//       },
//       child: ClipPath(
//         clipper: const ShapeBorderClipper(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(9),
//               topRight: Radius.circular(9),
//             ),
//           ),
//         ),
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.25,
//           height: MediaQuery.of(context).size.height * 0.07,
//           decoration: BoxDecoration(
//             color: selectedTabIndex == index ? Primary.p20 : Colors.white,
//             border:
//             selectedTabIndex == index
//                 ? Border(top: BorderSide(color: Primary.primary, width: 3))
//                 : null,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withAlpha((0.5 * 255).toInt()),
//                 spreadRadius: 9,
//                 blurRadius: 9,
//                 // offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Text(
//               name.tr,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Primary.primary,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   addNewTitle() {
//     setState(() {
//       listViewLength = listViewLength + increment;
//     });
//     // Widget p =
//     Container(
//       width: MediaQuery.of(context).size.width * 0.63,
//       margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//       child: ReusableTextField(
//         textEditingController: controller, //todo
//         isPasswordField: false,
//         hint: 'title'.tr,
//         onChangedFunc: (val) {},
//         validationFunc: (val) {},
//       ),
//     );
//     // quotationController.addToOrderLinesList(p);
//   }
//
//   // String price='0',disc='0',result='0',quantity='0';
//   addNewItem() {
//     setState(() {
//       listViewLength = listViewLength + increment;
//     });
//
//
//
//     // quotationController.addToOrderLinesList(p);
//   }
//
//   addNewCombo() {
//     setState(() {
//       listViewLength = listViewLength + increment;
//     });
//     // Widget p = const ReusableComboRow();
//     // quotationController.addToOrderLinesList(p);
//   }
//
//   addNewImage() {
//     setState(() {
//       listViewLength = listViewLength + 100;
//     });
//     // Widget p =
//     GetBuilder<QuotationController>(
//       builder: (cont) {
//         return InkWell(
//           onTap: () async {
//             final image = await ImagePickerHelper.pickImage();
//             setState(() {
//               imageFile = image!;
//               cont.changeBoolVar(true);
//               cont.increaseImageSpace(90);
//               listViewLength = listViewLength + (cont.imageSpaceHeight) + 10;
//             });
//           },
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//             child: DottedBorder(
//               dashPattern: const [10, 10],
//               color: Others.borderColor,
//               radius: const Radius.circular(9),
//               child: SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.63,
//                 height: cont.imageSpaceHeight,
//                 child:
//                 cont.imageAvailable
//                     ? Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Image.memory(
//                       imageFile,
//                       height: cont.imageSpaceHeight,
//                     ),
//                   ],
//                 )
//                     : Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     gapW20,
//                     Icon(
//                       Icons.cloud_upload_outlined,
//                       color: Others.iconColor,
//                       size: 32,
//                     ),
//                     gapW20,
//                     Text(
//                       'drag_drop_image'.tr,
//                       style: TextStyle(
//                         color: TypographyColor.textTable,
//                       ),
//                     ),
//                     Text(
//                       'browse'.tr,
//                       style: TextStyle(color: Primary.primary),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//     // quotationController.addToOrderLinesList(p);
//   }
//
//   addNewNote() {
//     setState(() {
//       listViewLength = listViewLength + increment;
//     });
//     // Widget p =
//     Container(
//       width: MediaQuery.of(context).size.width * 0.63,
//       margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//       child: ReusableTextField(
//         textEditingController: controller, //todo
//         isPasswordField: false,
//         hint: 'note'.tr,
//         onChangedFunc: (val) {},
//         validationFunc: (val) {},
//       ),
//     );
//     // quotationController.addToOrderLinesList(p);
//   }
//
//   List<Step> getSteps() => [
//     Step(
//       title: const Text(''),
//       content: Container(
//         //page
//       ),
//       isActive: currentStep >= 0,
//     ),
//     Step(
//       title: const Text(''),
//       content: Container(),
//       isActive: currentStep >= 1,
//     ),
//     Step(
//       title: const Text(''),
//       content: Container(),
//       isActive: currentStep >= 2,
//     ),
//   ];
// }
