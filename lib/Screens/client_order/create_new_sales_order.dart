import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rooster_app/Backend/Quotations/TermsAndConditions/get_terms_and_conditions.dart';
import 'package:rooster_app/Backend/SalesOrderBackend/store_sales_order.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Controllers/sales_order_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/Screens/Combo/combo.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/create_product_dialog.dart';
import 'package:rooster_app/Screens/client_order/print_sales_order.dart';
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
import '../../Backend/Quotations/TermsAndConditions/save_terms_and_conditions.dart';
import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../Widgets/TransferWidgets/under_item_btn.dart';
import '../../Widgets/dialog_drop_menu.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_more.dart';
import '../../Widgets/table_title.dart';
import '../../Widgets/TransferWidgets/reusable_show_info_card.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../../const/constants.dart';
import 'package:flutter_quill/quill_delta.dart';

class CreateNewClientOrder extends StatefulWidget {
  const CreateNewClientOrder({super.key});

  @override
  State<CreateNewClientOrder> createState() => _CreateNewClientOrderState();
}

class _CreateNewClientOrderState extends State<CreateNewClientOrder> {
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
  List<String> termsList = [];
  String selectedTab = 'order_lines'.tr;

  double listViewLength = Sizes.deviceHeight * 0.08;
  double increment = Sizes.deviceHeight * 0.08;

  bool isActiveVatChecked = false;
  bool isActiveDeliveredChecked = false;
  final SalesOrderController salesOrderController = Get.find();
  final HomeController homeController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();

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
    salesOrderController.selectedCurrencyId =
        exchangeRatesController.currenciesIdsList[index];
    salesOrderController.selectedCurrencySymbol =
        exchangeRatesController.currenciesSymbolsList[index];
    salesOrderController.selectedCurrencyName = 'USD';
    var vat = await getCompanyVatFromPref();
    salesOrderController.setCompanyVat(double.parse(vat));
    var companyCurrency = await getCompanyPrimaryCurrencyFromPref();
    var companyCurrencyLatestRate =
        await getPrimaryCurrencyLatestRateFromPref();
    salesOrderController.setCompanyPrimaryCurrency(companyCurrency);
    salesOrderController.setLatestRate(double.parse(companyCurrencyLatestRate));
  }

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
  }

  Future<void> generatePdfFromImageUrl() async {
    String companyLogo = await getCompanyLogoFromPref();

    // 1. Download image
    final response = await http.get(Uri.parse(companyLogo));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    final Uint8List imageBytes = response.bodyBytes;
    salesOrderController.setLogo(imageBytes);
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
    // print('Saved content as JSON:\n$jsonString');
    termsAndConditionsController.text = jsonString;
  }

  void _saveTermsAndConditions() async {
    final deltaJson = _controller.document.toDelta().toJson();
    final jsonString = jsonEncode(deltaJson);

    setState(() {
      _savedContent = jsonString;
    });
    termsAndConditionsController.text = jsonString;

    // print('_savedContent $_savedContent');
    var p = await storeTermsAndConditions(_savedContent!);
    if (p['success'] == true) {
      CommonWidgets.snackBar('Success', p['message']);
    } else {
      CommonWidgets.snackBar('error', p['message']);
    }
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
    _controller = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    generatePdfFromImageUrl();
    checkVatExempt();
    salesOrderController.isVatExemptChecked = false;
    salesOrderController.itemsMultiPartList = [];
    salesOrderController.salesPersonListNames = [];
    salesOrderController.salesPersonListId = [];
    salesOrderController.isBeforeVatPrices = true;
    priceConditionController.text = 'Prices are before vat';
    salesOrderController.getAllUsersSalesPersonFromBack();
    salesOrderController.getAllTaxationGroupsFromBack();
    setVars();
    salesOrderController.getFieldsForCreateSalesOrderFromBack();
    getCurrency();
    salesOrderController.resetSalesOrder();
    salesOrderController.listViewLengthInSalesOrder = 50;
    validityController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    inputDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    priceListController.text = 'STANDARD';
    getAllTermsAndConditions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesOrderController>(
      builder: (salesOrderCont) {
        return salesOrderCont.isSalesOrderInfoFetched
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
                      children: [PageTitle(text: 'create_sales_order'.tr)],
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      List itemsInfoPrint = [];
                                      for (var item
                                          in salesOrderCont
                                              .rowsInListViewInSalesOrder
                                              .values) {
                                        if ('${item['line_type_id']}' == '2') {
                                          var qty = item['item_quantity'];
                                          var map =
                                              salesOrderCont
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
                                                  ? map['images'][0]
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
                                          var itemTotal = double.parse(
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
                                            'title': '',
                                            'isImageList': true,
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
                                          var ind = salesOrderCont.combosIdsList
                                              .indexOf(
                                                item['combo'].toString(),
                                              );
                                          var itemName =
                                              salesOrderCont
                                                  .combosNamesList[ind];
                                          var itemPrice = double.parse(
                                            '${item['item_unit_price'] ?? 0.0}',
                                          );
                                          var itemDescription =
                                              item['item_description'];

                                          var itemTotal = double.parse(
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
                                            'isImageList': true,
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
                                            'title': '',
                                            'note': '',
                                            'image': item['image'],
                                            'isImageList': true,
                                          };
                                          itemsInfoPrint.add(quotationItemInfo);
                                        }
                                      }
                                      var quotNumber = '';

                                      return PrintSalesOrder(
                                        quotationNumber: quotNumber,
                                        isPrintedAs0:
                                            salesOrderCont.isPrintedAs0,
                                        isVatNoPrinted:
                                            salesOrderCont.isVatNoPrinted,
                                        isPrintedAsVatExempt:
                                            salesOrderCont.isPrintedAsVatExempt,
                                        isInSalesOrder: false,
                                        salesOrderNumber:
                                            salesOrderCont.salesOrderNumber,
                                        creationDate: validityController.text,
                                        ref: refController.text,
                                        receivedUser: '',
                                        senderUser: homeController.userName,
                                        status: '',
                                        totalBeforeVat:
                                            salesOrderCont.totalItems
                                                .toString(),
                                        discountOnAllItem:
                                            salesOrderCont.preGlobalDisc
                                                .toString(),
                                        totalAllItems: formatDoubleWithCommas(
                                          salesOrderCont.totalItems,
                                        ),
                                        globalDiscount:
                                            globalDiscPercentController.text,
                                        //widget.info['globalDiscount'] ?? '0',
                                        totalPriceAfterDiscount:
                                            salesOrderCont.preGlobalDisc == 0.0
                                                ? formatDoubleWithCommas(
                                                  salesOrderCont.totalItems,
                                                )
                                                : formatDoubleWithCommas(
                                                  salesOrderCont
                                                      .totalAfterGlobalDis,
                                                ),
                                        additionalSpecialDiscount:
                                            salesOrderCont.preSpecialDisc
                                                .toStringAsFixed(2),
                                        totalPriceAfterSpecialDiscount:
                                            salesOrderCont.preSpecialDisc == 0
                                                ? formatDoubleWithCommas(
                                                  salesOrderCont.totalItems,
                                                )
                                                : formatDoubleWithCommas(
                                                  salesOrderCont
                                                      .totalAfterGlobalSpecialDis,
                                                ),
                                        totalPriceAfterSpecialDiscountBySalesOrderCurrency:
                                            salesOrderCont.preSpecialDisc == 0
                                                ? formatDoubleWithCommas(
                                                  salesOrderCont.totalItems,
                                                )
                                                : formatDoubleWithCommas(
                                                  salesOrderCont
                                                      .totalAfterGlobalSpecialDis,
                                                ),

                                        vatBySalesOrderCurrency:
                                            formatDoubleWithCommas(
                                              double.parse(
                                                salesOrderCont.vat11,
                                              ),
                                            ),
                                        finalPriceBySalesOrderCurrency:
                                            formatDoubleWithCommas(
                                              double.parse(
                                                salesOrderCont.totalSalesOrder,
                                              ),
                                            ),
                                        specialDisc: specialDisc.toString(),
                                        specialDiscount:
                                            specialDiscPercentController.text,
                                        specialDiscountAmount:
                                            salesOrderCont.specialDisc,
                                        salesPerson: selectedSalesPerson,
                                        salesOrderCurrency:
                                            salesOrderCont.selectedCurrencyName,
                                        salesOrderCurrencySymbol:
                                            salesOrderCont
                                                .selectedCurrencySymbol,
                                        salesOrderCurrencyLatestRate:
                                            salesOrderCont
                                                .exchangeRateForSelectedCurrency,
                                        clientPhoneNumber:
                                            salesOrderCont
                                                .phoneNumber[selectedCustomerIds] ??
                                            '---',
                                        clientName: clientNameController.text,
                                        termsAndConditions:
                                            termsAndConditionsController.text,
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
                                    salesOrderController
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
                                bool hasType4WithEmptyImage =
                                    salesOrderController
                                        .rowsInListViewInSalesOrder
                                        .values
                                        .any((map) {
                                          return map['line_type_id'] == '4' &&
                                              (map['image'] == Uint8List(0) ||
                                                  map['image']?.isEmpty);
                                        });
                                bool hasType5WithEmptyNote =
                                    salesOrderController
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
                                  _saveContent();
                                  var res = await storeSalesOrder(
                                    refController.text,
                                    selectedCustomerIds,
                                    validityController.text,
                                    inputDateController.text,
                                    '', //todo paymentTermsController.text,
                                    salesOrderCont.salesOrderNumber,
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
                                    salesOrderController.totalSalesOrder, //

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
                                    salesOrderController
                                        .rowsInListViewInSalesOrder,
                                    salesOrderCont.orderedKeys,
                                    titleController.text,
                                  );
                                  if (res['success'] == true) {
                                    CommonWidgets.snackBar(
                                      'Success',
                                      res['message'],
                                    );
                                    homeController.selectedTab.value =
                                        'to_invoice';
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          List itemsInfoPrint = [];
                                          for (var item
                                              in salesOrderCont
                                                  .rowsInListViewInSalesOrder
                                                  .values) {
                                            if ('${item['line_type_id']}' ==
                                                '2') {
                                              var qty = item['item_quantity'];
                                              var map =
                                                  salesOrderCont
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
                                                      ? map['images'][0]
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
                                              //     quotationCont
                                              //         .combosMap[item['combo']
                                              //         .toString()];
                                              var ind = salesOrderCont
                                                  .combosIdsList
                                                  .indexOf(
                                                    item['combo'].toString(),
                                                  );
                                              var itemName =
                                                  salesOrderCont
                                                      .combosNamesList[ind];
                                              var itemPrice = double.parse(
                                                '${item['item_unit_price'] ?? 0.0}',
                                              );
                                              var itemDescription =
                                                  item['item_description'];

                                              var itemTotal = double.parse(
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
                                          var quotNumber = '';

                                          return PrintSalesOrder(
                                            quotationNumber: quotNumber,
                                            isPrintedAs0:
                                                salesOrderCont.isPrintedAs0,
                                            isVatNoPrinted:
                                                salesOrderCont.isVatNoPrinted,
                                            isPrintedAsVatExempt:
                                                salesOrderCont
                                                    .isPrintedAsVatExempt,
                                            isInSalesOrder: false,
                                            salesOrderNumber:
                                                salesOrderCont.salesOrderNumber,
                                            creationDate:
                                                validityController.text,
                                            ref: refController.text,
                                            receivedUser: '',
                                            senderUser: homeController.userName,
                                            status: '',
                                            totalBeforeVat:
                                                salesOrderCont.totalItems
                                                    .toString(),
                                            discountOnAllItem:
                                                salesOrderCont.preGlobalDisc
                                                    .toString(),
                                            totalAllItems:
                                                formatDoubleWithCommas(
                                                  salesOrderCont.totalItems,
                                                ),
                                            globalDiscount:
                                                globalDiscPercentController
                                                    .text,
                                            //widget.info['globalDiscount'] ?? '0',
                                            totalPriceAfterDiscount:
                                                salesOrderCont.preGlobalDisc ==
                                                        0.0
                                                    ? formatDoubleWithCommas(
                                                      salesOrderCont.totalItems,
                                                    )
                                                    : formatDoubleWithCommas(
                                                      salesOrderCont
                                                          .totalAfterGlobalDis,
                                                    ),
                                            additionalSpecialDiscount:
                                                salesOrderCont.preSpecialDisc
                                                    .toStringAsFixed(2),
                                            totalPriceAfterSpecialDiscount:
                                                salesOrderCont.preSpecialDisc ==
                                                        0
                                                    ? formatDoubleWithCommas(
                                                      salesOrderCont.totalItems,
                                                    )
                                                    : formatDoubleWithCommas(
                                                      salesOrderCont
                                                          .totalAfterGlobalSpecialDis,
                                                    ),
                                            totalPriceAfterSpecialDiscountBySalesOrderCurrency:
                                                salesOrderCont.preSpecialDisc ==
                                                        0
                                                    ? formatDoubleWithCommas(
                                                      salesOrderCont.totalItems,
                                                    )
                                                    : formatDoubleWithCommas(
                                                      salesOrderCont
                                                          .totalAfterGlobalSpecialDis,
                                                    ),

                                            vatBySalesOrderCurrency:
                                                formatDoubleWithCommas(
                                                  double.parse(
                                                    salesOrderCont.vat11,
                                                  ),
                                                ),
                                            finalPriceBySalesOrderCurrency:
                                                formatDoubleWithCommas(
                                                  double.parse(
                                                    salesOrderCont
                                                        .totalSalesOrder,
                                                  ),
                                                ),
                                            specialDisc: specialDisc.toString(),
                                            specialDiscount:
                                                specialDiscPercentController
                                                    .text,
                                            specialDiscountAmount:
                                                salesOrderCont.specialDisc,
                                            salesPerson: selectedSalesPerson,
                                            salesOrderCurrency:
                                                salesOrderCont
                                                    .selectedCurrencyName,
                                            salesOrderCurrencySymbol:
                                                salesOrderCont
                                                    .selectedCurrencySymbol,
                                            salesOrderCurrencyLatestRate:
                                                salesOrderCont
                                                    .exchangeRateForSelectedCurrency,
                                            clientPhoneNumber:
                                                salesOrderCont
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
                                  } else {
                                    CommonWidgets.snackBar(
                                      'error',
                                      res['message'],
                                    );
                                  }
                                }
                                // }
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
                        borderRadius: const BorderRadius.all(
                          Radius.circular(9),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                salesOrderCont.salesOrderNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: TypographyColor.titleTable,
                                ),
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
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
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
                                              cont.currenciesNamesList.map<
                                                DropdownMenuEntry<String>
                                              >((String option) {
                                                return DropdownMenuEntry<
                                                  String
                                                >(value: option, label: option);
                                              }).toList(),
                                          enableFilter: true,
                                          onSelected: (String? val) {
                                            setState(() {
                                              selectedCurrency = val!;
                                              var index = cont
                                                  .currenciesNamesList
                                                  .indexOf(val);
                                              salesOrderCont.setSelectedCurrency(
                                                cont.currenciesIdsList[index],
                                                val,
                                              );
                                              salesOrderCont
                                                  .setSelectedCurrencySymbol(
                                                    cont.currenciesSymbolsList[index],
                                                  );
                                              var result = cont
                                                  .exchangeRatesList
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
                                                } else if (salesOrderCont
                                                            .selectedCurrencyName ==
                                                        'USD' &&
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
                                                    '${(int.parse(salesOrderCont.rowsInListViewInSalesOrder[keys[i]]['item_quantity']) * double.parse(salesOrderCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(salesOrderCont.rowsInListViewInSalesOrder[keys[i]]['item_discount']) / 100)}';

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
                                            var comboKeys =
                                                salesOrderCont
                                                    .combosPriceControllers
                                                    .keys
                                                    .toList();
                                            for (
                                              int i = 0;
                                              i <
                                                  salesOrderCont
                                                      .combosPriceControllers
                                                      .length;
                                              i++
                                            ) {
                                              var selectedComboId =
                                                  '${salesOrderCont.rowsInListViewInSalesOrder[comboKeys[i]]['combo']}';
                                              if (selectedComboId != '') {
                                                var ind = salesOrderCont
                                                    .combosIdsList
                                                    .indexOf(selectedComboId);
                                                if (salesOrderCont
                                                        .combosPricesCurrencies[selectedComboId] ==
                                                    salesOrderCont
                                                        .selectedCurrencyName) {
                                                  salesOrderCont
                                                      .combosPriceControllers[comboKeys[i]]!
                                                      .text = salesOrderCont
                                                          .combosPricesList[ind]
                                                          .toString();
                                                } else if (salesOrderCont
                                                            .selectedCurrencyName ==
                                                        'USD' &&
                                                    salesOrderCont
                                                            .combosPricesCurrencies[selectedComboId] !=
                                                        salesOrderCont
                                                            .selectedCurrencyName) {
                                                  var result = exchangeRatesController
                                                      .exchangeRatesList
                                                      .firstWhere(
                                                        (item) =>
                                                            item["currency"] ==
                                                            salesOrderCont
                                                                .combosPricesCurrencies[selectedComboId],
                                                        orElse: () => null,
                                                      );
                                                  var divider = '1';
                                                  if (result != null) {
                                                    divider =
                                                        result["exchange_rate"]
                                                            .toString();
                                                  }
                                                  salesOrderCont
                                                          .combosPriceControllers[comboKeys[i]]!
                                                          .text =
                                                      '${double.parse('${(double.parse(salesOrderCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                } else if (salesOrderCont
                                                            .selectedCurrencyName !=
                                                        'USD' &&
                                                    salesOrderCont
                                                            .combosPricesCurrencies[selectedComboId] ==
                                                        'USD') {
                                                  salesOrderCont
                                                          .combosPriceControllers[comboKeys[i]]!
                                                          .text =
                                                      '${double.parse('${(double.parse(salesOrderCont.combosPricesList[ind].toString()) * double.parse(salesOrderCont.exchangeRateForSelectedCurrency))}')}';
                                                } else {
                                                  var result = exchangeRatesController
                                                      .exchangeRatesList
                                                      .firstWhere(
                                                        (item) =>
                                                            item["currency"] ==
                                                            salesOrderCont
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
                                                      '${double.parse('${(double.parse(salesOrderCont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
                                                  salesOrderCont
                                                          .combosPriceControllers[comboKeys[i]]!
                                                          .text =
                                                      '${double.parse('${(double.parse(usdPrice) * double.parse(salesOrderCont.exchangeRateForSelectedCurrency))}')}';
                                                }
                                                salesOrderCont
                                                        .combosPriceControllers[comboKeys[i]]!
                                                        .text =
                                                    '${double.parse(salesOrderCont.combosPriceControllers[comboKeys[i]]!.text)}';

                                                salesOrderCont
                                                    .combosPriceControllers[comboKeys[i]]!
                                                    .text = double.parse(
                                                  salesOrderCont
                                                      .combosPriceControllers[comboKeys[i]]!
                                                      .text,
                                                ).toStringAsFixed(2);
                                                var totalLine =
                                                    '${(int.parse(salesOrderCont.rowsInListViewInSalesOrder[comboKeys[i]]['item_quantity']) * double.parse(salesOrderCont.combosPriceControllers[comboKeys[i]]!.text)) * (1 - double.parse(salesOrderCont.rowsInListViewInSalesOrder[keys[i]]['item_discount']) / 100)}';
                                                salesOrderCont
                                                    .setEnteredQtyInSalesOrder(
                                                      comboKeys[i],
                                                      salesOrderCont
                                                          .rowsInListViewInSalesOrder[comboKeys[i]]['item_quantity'],
                                                    );
                                                salesOrderCont
                                                    .setMainTotalInSalesOrder(
                                                      comboKeys[i],
                                                      totalLine,
                                                    );
                                                salesOrderCont.getTotalItems();

                                                salesOrderCont
                                                    .setEnteredUnitPriceInSalesOrder(
                                                      comboKeys[i],
                                                      salesOrderCont
                                                          .combosPriceControllers[comboKeys[i]]!
                                                          .text,
                                                    );
                                                salesOrderCont
                                                    .setMainTotalInSalesOrder(
                                                      comboKeys[i],
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
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('pricelist'.tr),
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
                                          salesOrderController.priceListsCodes
                                              .map<DropdownMenuEntry<String>>((
                                                String option,
                                              ) {
                                                return DropdownMenuEntry<
                                                  String
                                                >(value: option, label: option);
                                              })
                                              .toList(),
                                      enableFilter: true,
                                      onSelected: (String? val) {
                                        var index = salesOrderCont
                                            .priceListsCodes
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
                          gapH16,
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
                                      textEditingController:
                                          inputDateController,
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
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ReusableDropDownMenusWithSearchCode(
                                      list:
                                          salesOrderCont.customersMultiPartList,
                                      text: 'code'.tr,
                                      hint: '${'search'.tr}...',
                                      controller: codeController,
                                      onSelected: (String? value) {
                                        codeController.text = value!;
                                        int index = salesOrderCont
                                            .customerNumberList
                                            .indexOf(value);
                                        clientNameController.text =
                                            salesOrderCont
                                                .customerNameList[index];
                                        setState(() {
                                          selectedCustomerIds =
                                              salesOrderCont
                                                  .customerIdsList[salesOrderCont
                                                  .customerNumberList
                                                  .indexOf(value)];
                                          if (salesOrderCont
                                              .customersPricesListsIds[index]
                                              .isNotEmpty && salesOrderCont
                                              .customersPricesListsIds[index]!=null) {
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
                                              .isNotEmpty && salesOrderCont
                                              .customersSalesPersonsIds[index]!=null) {
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
                                        });
                                      },
                                      validationFunc: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'select_option'.tr;
                                        }
                                        return null;
                                      },
                                      rowWidth:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                      textFieldWidth:
                                          MediaQuery.of(context).size.width *
                                          0.12,
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
                                      list: salesOrderCont.customerNameList,
                                      text: '',
                                      hint: '${'search'.tr}...',
                                      controller: clientNameController,
                                      onSelected: (String? val) {
                                        setState(() {
                                          var index = salesOrderCont
                                              .customerNameList
                                              .indexOf(val!);
                                          codeController.text =
                                              salesOrderCont
                                                  .customerNumberList[index];
                                          selectedCustomerIds =
                                              salesOrderCont
                                                  .customerIdsList[index];
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
                                        });
                                      },
                                      validationFunc: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'select_option'.tr;
                                        }
                                        return null;
                                      },
                                      rowWidth:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                      textFieldWidth:
                                          MediaQuery.of(context).size.width *
                                          0.14,
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
                              // SizedBox(
                              //   width: MediaQuery.of(context).size.width * 0.24,
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Text('payment_terms'.tr),
                              //
                              //       GetBuilder<ExchangeRatesController>(
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
                              //                 termsList.map<
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
                                          'Phone Number'.tr,
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
                                      'price_conditions'.tr,
                                      style:
                                          salesOrderCont.isVatExemptChecked
                                              ? TextStyle(color: Others.divider)
                                              : TextStyle(),
                                    ),
                                    GetBuilder<ExchangeRatesController>(
                                      builder: (cont) {
                                        return DropdownMenu<String>(
                                          enabled:
                                              !salesOrderCont
                                                  .isVatExemptChecked,
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.15,
                                          // requestFocusOnTap: false,
                                          enableSearch: true,
                                          controller: priceConditionController,
                                          hintText: '',
                                          textStyle: TextStyle(fontSize: 12),
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
                                                salesOrderCont
                                                    .setIsBeforeVatPrices(true);
                                                // ch
                                              } else {
                                                salesOrderCont
                                                    .setIsBeforeVatPrices(
                                                      false,
                                                    );
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
                                                    salesOrderCont
                                                        .rowsInListViewInSalesOrder[keys[i]]['item_id'];
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
                                                      '${(int.parse(salesOrderCont.rowsInListViewInSalesOrder[keys[i]]['item_quantity']) * double.parse(salesOrderCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(salesOrderCont.rowsInListViewInSalesOrder[keys[i]]['item_discount']) / 100)}';

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
                                                  salesOrderCont
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //vat
                                    salesOrderCont
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
                              //vat exempt
                              salesOrderCont.isVatExemptCheckBoxShouldAppear
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
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            leading: Checkbox(
                                              // checkColor: Colors.white,
                                              // fillColor: MaterialStateProperty.resolveWith(getColor),
                                              value:
                                                  salesOrderCont
                                                      .isVatExemptChecked,
                                              onChanged: (bool? value) {
                                                salesOrderCont
                                                    .setIsVatExemptChecked(
                                                      value!,
                                                    );
                                                if (value) {
                                                  // priceConditionController.clear();
                                                  priceConditionController
                                                          .text =
                                                      'Prices are before vat';
                                                  salesOrderCont
                                                      .setIsBeforeVatPrices(
                                                        true,
                                                      );
                                                  vatExemptController.text =
                                                      vatExemptList[0];
                                                  salesOrderCont
                                                      .setIsVatExempted(
                                                        true,
                                                        false,
                                                        false,
                                                      );
                                                } else {
                                                  // priceConditionController.text='Prices are before vat';
                                                  vatExemptController.clear();
                                                  salesOrderCont
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
                                        salesOrderCont.isVatExemptChecked ==
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
                                                fontSize: 12,
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
                              child: Row(
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
                                                0.10
                                            : MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.13,
                                  ),
                                  TableTitle(
                                    text: 'description'.tr,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.23,
                                  ),
                                  TableTitle(
                                    text: 'quantity'.tr,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.05,
                                  ),
                                  TableTitle(
                                    text: 'warehouse'.tr,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.10,
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
                                                0.05
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
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.01,
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
                                            .listViewLengthInSalesOrder,
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
                                              row['line_type_id'] ?? '';

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
                                        'terms_conditions'.tr,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: TypographyColor.titleTable,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.save_alt),
                                            onPressed: () async {
                                              _saveTermsAndConditions();
                                            },
                                          ),
                                          gapW6,
                                          IconButton(
                                            icon: const Icon(Icons.restore),
                                            onPressed:
                                                showLastTermsAndConditionsList,
                                          ),
                                        ],
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
                                                salesOrderController.totalItems,
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
                                                      salesOrderCont.setGlobalDisc(
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
                                                      salesOrderController
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
                                                      salesOrderCont.setSpecialDisc(
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
                                                      salesOrderController
                                                          .specialDisc,
                                                    ),
                                                  ),

                                                  // salesOrderCont.specialDisc,
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
                                        salesOrderCont.isVatNoPrinted
                                            ? SizedBox()
                                            : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  salesOrderCont
                                                          .isPrintedAsVatExempt
                                                      ? 'vat_exempt'.tr
                                                          .toUpperCase()
                                                      : salesOrderCont
                                                          .isPrintedAs0
                                                      ? '${'vat'.tr} 0%'
                                                      : 'vat'.tr,
                                                ),
                                                Row(
                                                  children: [
                                                    ReusableShowInfoCard(
                                                      text: formatDoubleWithCommas(
                                                        double.parse(
                                                          salesOrderCont
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
                                                              salesOrderCont
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
                                    _saveContent();
                                    bool hasType1WithEmptyTitle =
                                        salesOrderController
                                            .rowsInListViewInSalesOrder
                                            .values
                                            .any((map) {
                                              return map['line_type_id'] ==
                                                      '1' &&
                                                  (map['title']?.isEmpty ??
                                                      true);
                                            });
                                    bool
                                    hasType2WithEmptyId = salesOrderController
                                        .rowsInListViewInSalesOrder
                                        .values
                                        .any((map) {
                                          return map['line_type_id'] == '2' &&
                                              (map['item_id']?.isEmpty ?? true);
                                        });
                                    bool
                                    hasType3WithEmptyId = salesOrderController
                                        .rowsInListViewInSalesOrder
                                        .values
                                        .any((map) {
                                          return map['line_type_id'] == '3' &&
                                              (map['combo']?.isEmpty ?? true);
                                        });
                                    bool hasType4WithEmptyImage =
                                        salesOrderController
                                            .rowsInListViewInSalesOrder
                                            .values
                                            .any((map) {
                                              return map['line_type_id'] ==
                                                      '4' &&
                                                  (map['image'] ==
                                                          Uint8List(0) ||
                                                      map['image']?.isEmpty);
                                            });
                                    bool
                                    hasType5WithEmptyNote = salesOrderController
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
                                      print(
                                        "Createsalesorder-------------------",
                                      );
                                      print(
                                        salesOrderController
                                            .rowsInListViewInSalesOrder,
                                      );

                                      var res = await storeSalesOrder(
                                        refController.text,
                                        selectedCustomerIds,
                                        validityController.text,
                                        inputDateController.text,
                                        '', //todo paymentTermsController.text,
                                        salesOrderCont.salesOrderNumber,
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
                                        salesOrderController.vat11
                                            .toString(), //vat
                                        salesOrderController
                                            .vatInPrimaryCurrency
                                            .toString(),
                                        salesOrderController.totalSalesOrder, //

                                        salesOrderCont.isVatExemptChecked
                                            ? '1'
                                            : '0',
                                        salesOrderCont.isVatNoPrinted
                                            ? '1'
                                            : '0',
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
                                        salesOrderController
                                            .rowsInListViewInSalesOrder,
                                        salesOrderCont.orderedKeys,
                                        titleController.text,
                                      );
                                      if (res['success'] == true) {
                                        CommonWidgets.snackBar(
                                          'Success',
                                          res['message'],
                                        );
                                        homeController.selectedTab.value =
                                            'to_invoice';
                                      } else {
                                        CommonWidgets.snackBar(
                                          'error',
                                          res['message'],
                                        );
                                      }
                                    }
                                  },
                                  btnText: 'create_sales_order'.tr,
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
                                          salesOrderCont.salesPersonListNames,
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
                                          var index = salesOrderCont
                                              .salesPersonListNames
                                              .indexOf(val);
                                          selectedSalesPersonId =
                                              salesOrderCont
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
                                          salesOrderCont
                                              .cashingMethodsNamesList,
                                      text: 'cashing_method'.tr,
                                      hint: '',
                                      rowWidth:
                                          MediaQuery.of(context).size.width *
                                          0.3,
                                      textFieldWidth:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                      onSelected: (value) {
                                        var index = salesOrderCont
                                            .cashingMethodsNamesList
                                            .indexOf(value);
                                        salesOrderCont
                                            .setSelectedCashingMethodId(
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
        'combo': '',
      },
    );
  }

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
        'item_quantity': '0',
        'item_warehouseId': '',
        'combo_warehouseId': '',
        'item_unit_price': '0',
        'item_total': '0',
        'title': '',
        'note': '',
        'combo': '',
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
        'item_quantity': '0',
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
      salesOrderController.increment + 50,
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
        'combo': '',
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

  TextEditingController itemCodeController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController itemwarehouseController = TextEditingController();

  final SalesOrderController salesOrderController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();
  final HomeController homeController = Get.find();
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
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // discountController.text = '0';
    // qtyController.text = '0';
    // discount = '0';
    // quantity = '0';
    var inddd = salesOrderController.warehouseIds.indexOf(
      salesOrderController.rowsInListViewInSalesOrder[widget
          .index]['item_warehouseId'],
    );

    itemwarehouseController.text =
        salesOrderController.rowsInListViewInSalesOrder[widget
                    .index]['item_warehouseId'] !=
                ''
            ? salesOrderController.warehousesNameList[inddd]
            : salesOrderController.rowsInListViewInSalesOrder[widget
                .index]['item_warehouseId'];
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
                      if (value == null || value.isEmpty) {
                        return 'select_option'.tr;
                      }
                      return null;
                    },
                    rowWidth:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.10
                            : MediaQuery.of(context).size.width * 0.13,
                    textFieldWidth:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.10
                            : MediaQuery.of(context).size.width * 0.13,
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
                    nextFocusNode: quantityFocus,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.20,
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

                      cont.setEnteredQtyInSalesOrder(widget.index, val);
                      cont.setMainTotalInSalesOrder(widget.index, totalLine);
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

                //warehouse
                DropdownMenu<String>(
                  width: MediaQuery.of(context).size.width * 0.10,
                  // requestFocusOnTap: false,
                  enableSearch: true,
                  controller: itemwarehouseController,
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
                    setState(() {
                      itemwarehouseController.text = value!;

                      var index = cont.warehousesNameList.indexOf(value);
                      var val = '${cont.warehouseIds[index]}';
                      cont.setItemWareHouseInSalesOrder(widget.index, val);
                    });
                  },
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
                        cont.setEnteredUnitPriceInSalesOrder(widget.index, val);
                        cont.setMainTotalInSalesOrder(widget.index, totalLine);
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
                          'item_quantity': '0',
                          'item_warehouseId': '',
                          'combo_warehouseId': '',
                          'item_unit_price': '0',
                          'item_total': '0',
                          'title': '',
                          'note': '',
                          'combo': '',
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
                      cont.setEnteredDiscInSalesOrder(widget.index, val);
                      cont.setMainTotalInSalesOrder(widget.index, totalLine);
                      await cont.getTotalItems();
                    },
                  ),
                ),

                //total
                Obx(
                  () => ReusableShowInfoCard(
                    text: formatDoubleWithCommas(
                      double.parse(
                        cont.rowsInListViewInSalesOrder[widget
                            .index]['item_total'],
                      ),
                    ),
                    width:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.05
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
                              salesOrderController
                                  .decrementListViewLengthInSalesOrder(
                                    salesOrderController.increment,
                                  );
                              salesOrderController
                                  .removeFromRowsInListViewInSalesOrder(
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
                              cont.totalSalesOrder = "0.0";
                            });
                            if (cont.rowsInListViewInSalesOrder != {}) {
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
  final SalesOrderController salesOrderController = Get.find();
  String titleValue = '0';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
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
                  width: MediaQuery.of(context).size.width * 0.63,
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
                              salesOrderController
                                  .decrementListViewLengthInSalesOrder(
                                    salesOrderController.increment,
                                  );
                              salesOrderController
                                  .removeFromRowsInListViewInSalesOrder(
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
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.63,
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
                          salesOrderController
                              .decrementListViewLengthInSalesOrder(
                                salesOrderController.increment,
                              );
                          salesOrderController
                              .removeFromRowsInListViewInSalesOrder(
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
  final SalesOrderController salesOrderController = Get.find();
  late Uint8List imageFile;

  double listViewLength = Sizes.deviceHeight * 0.08;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    imageFile =
        salesOrderController.rowsInListViewInSalesOrder[widget.index]['image'];
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
                        width: MediaQuery.of(context).size.width * 0.62,
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
                          salesOrderController
                              .decrementListViewLengthInSalesOrder(
                                salesOrderController.increment + 50,
                              );
                          salesOrderController
                              .removeFromRowsInListViewInSalesOrder(
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
  TextEditingController warehouseController = TextEditingController();
  final SalesOrderController salesOrderController = Get.find();
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
    var indd = salesOrderController.warehouseIds.indexOf(
      salesOrderController.rowsInListViewInSalesOrder[widget
          .index]['combo_warehouseId'],
    );
    // var indx = salesOrderController.warehousesNameList[indd];

    // print(salesOrderController.warehousesNameList[indd]);

    warehouseController.text =
        salesOrderController.rowsInListViewInSalesOrder[widget
                    .index]['combo_warehouseId'] !=
                ''
            ? salesOrderController.warehousesNameList[indd]
            : salesOrderController.rowsInListViewInSalesOrder[widget
                .index]['combo_warehouseId'];
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
                            ? MediaQuery.of(context).size.width * 0.10
                            : MediaQuery.of(context).size.width * 0.13,
                    textFieldWidth:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.10
                            : MediaQuery.of(context).size.width * 0.13,
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
                  width: MediaQuery.of(context).size.width * 0.20,
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
                      cont.setMainDescriptionInSalesOrder(
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
                  controller: warehouseController,
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
                    warehouseController.text = value!;

                    var index = cont.warehousesNameList.indexOf(value);
                    var val = '${cont.warehouseIds[index]}';
                    cont.setComboWareHouseInSalesOrder(widget.index, val);
                  },
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
                        cont.setEnteredUnitPriceInSalesOrder(widget.index, val);
                        cont.setMainTotalInSalesOrder(widget.index, totalLine);
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
                          'item_quantity': '0',
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
                      cont.setEnteredDiscInSalesOrder(widget.index, val);
                      cont.setMainTotalInSalesOrder(widget.index, totalLine);
                      await cont.getTotalItems();
                    },
                  ),
                ),

                //total
                Obx(
                  () => ReusableShowInfoCard(
                    text: formatDoubleWithCommas(
                      double.parse(
                        cont.rowsInListViewInSalesOrder[widget
                            .index]['item_total'],
                      ),
                    ),
                    width:
                        homeController.isOpened.value
                            ? MediaQuery.of(context).size.width * 0.05
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
                              salesOrderController
                                  .decrementListViewLengthInSalesOrder(
                                    salesOrderController.increment,
                                  );
                              salesOrderController
                                  .removeFromRowsInListViewInSalesOrder(
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
                              cont.totalSalesOrder = "0.0";
                            });
                            if (cont.rowsInListViewInSalesOrder != {}) {
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
    return GetBuilder<SalesOrderController>(
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
