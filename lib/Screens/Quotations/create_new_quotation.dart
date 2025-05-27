import 'dart:convert';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/Screens/Combo/combo.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/create_product_dialog.dart';
import 'package:rooster_app/Screens/Quotations/print_quotation.dart';
import 'package:rooster_app/Widgets/dialog_title.dart';
import 'package:rooster_app/Widgets/loading.dart';
import 'package:rooster_app/const/functions.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Screens/Quotations/create_client_dialog.dart';
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
  TextEditingController currencyController = TextEditingController();

  TextEditingController totalCommissionController = TextEditingController();
  TextEditingController refController = TextEditingController();
  TextEditingController validityController = TextEditingController();
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
  final QuotationController quotationController = Get.find();
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
    quotationController.selectedCurrencyId =
        exchangeRatesController.currenciesIdsList[index];
    quotationController.selectedCurrencySymbol =
        exchangeRatesController.currenciesSymbolsList[index];
    quotationController.selectedCurrencyName = 'USD';
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

  late  QuillController _controller ;
  String? _savedContent;

  void _saveContent() {
    final deltaJson = _controller.document.toDelta().toJson();
    final jsonString = jsonEncode(deltaJson);

    setState(() {
      _savedContent = jsonString;
    });

    // You can now send `jsonString` to your backend
    print('Saved content as JSON:\n$jsonString');
    termsAndConditionsController.text=jsonString;
  }

  // Restore content from saved string (e.g., from API)
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

  @override
  void initState() {
    _controller = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    generatePdfFromImageUrl();
    checkVatExempt();
    quotationController.isVatExemptChecked = false;
    quotationController.itemsMultiPartList = [];
    quotationController.salesPersonListNames = [];
    quotationController.salesPersonListId = [];
    quotationController.isBeforeVatPrices = true;
    priceConditionController.text = 'Prices are before vat';
    quotationController.getAllUsersSalesPersonFromBack();
    quotationController.getAllTaxationGroupsFromBack();
    setVars();
    quotationController.getFieldsForCreateQuotationFromBack();
    getCurrency();
    quotationController.resetQuotation();
    quotationController.listViewLengthInQuotation = 50;
    validityController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    priceListController.text='STANDARD';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuotationController>(
      builder: (quotationCont) {
        var keysList = quotationCont.orderLinesQuotationList.keys.toList();
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
                      children: [PageTitle(text: 'create_new_quotation'.tr)],
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
                                // bool isThereItemsEmpty = false;
                                // var keys =
                                //     quotationCont.rowsInListViewInQuotation.keys
                                //         .toList();
                                // for (int i = 0; i < keys.length; i++) {
                                //   if (quotationCont
                                //               .rowsInListViewInQuotation[keys[i]]["item_quantity"] ==
                                //           '' ||
                                //       quotationCont
                                //               .rowsInListViewInQuotation[keys[i]]["item_quantity"] ==
                                //           '0') {
                                //     setState(() {
                                //       isThereItemsEmpty = true;
                                //     });
                                //     break;
                                //   }
                                // }
                                // if (isThereItemsEmpty) {
                                //   CommonWidgets.snackBar(
                                //     'error',
                                //     'check all order lines and enter the required fields',
                                //   );
                                // } else {
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
                                            'line_type_id':'2',
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
                                            'isImageList':true,
                                            'note': '',
                                            'image':''
                                          };
                                          itemsInfoPrint.add(quotationItemInfo);
                                        }
                                        else if ('${item['line_type_id']}' == '3') {
                                          var qty = item['item_quantity'];
                                          // var map =
                                          //     quotationCont
                                          //         .combosMap[item['combo']
                                          //         .toString()];
                                          var ind=quotationCont
                                              .combosIdsList.indexOf(item['combo']
                                              .toString());
                                          var itemName = quotationCont.combosNamesList[ind];
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
                                            'line_type_id':'3',
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
                                            'isImageList':true,
                                            'title': '',
                                            'image':''
                                          };
                                          itemsInfoPrint.add(quotationItemInfo);
                                        }
                                        else if('${item['line_type_id']}' == '1'){
                                          var quotationItemInfo = {
                                            'line_type_id':'1',
                                            'item_name': '',
                                            'item_description': '',
                                            'item_quantity': '',
                                            'item_unit_price': '',
                                            'item_discount':'0',
                                            'item_total':'',
                                            'item_image': '',
                                            'item_brand': '',
                                            'note': '',
                                            'isImageList':true,
                                            'title':item['title'],
                                            'image':''
                                          };
                                          itemsInfoPrint.add(quotationItemInfo);
                                        }
                                        else if('${item['line_type_id']}' == '5'){
                                          var quotationItemInfo = {
                                            'line_type_id':'5',
                                            'item_name': '',
                                            'item_description': '',
                                            'item_quantity': '',
                                            'item_unit_price': '',
                                            'item_discount':'0',
                                            'item_total':'',
                                            'item_image': '',
                                            'item_brand': '',
                                            'title': '',
                                            'note':item['note'],
                                          'image':'',
                                            'isImageList':true,
                                          };
                                          itemsInfoPrint.add(quotationItemInfo);
                                        }
                                        else if('${item['line_type_id']}' == '4'){
                                          var quotationItemInfo = {
                                            'line_type_id':'4',
                                            'item_name': '',
                                            'item_description': '',
                                            'item_quantity': '',
                                            'item_unit_price': '',
                                            'item_discount':'0',
                                            'item_total':'',
                                            'item_image': '',
                                            'item_brand': '',
                                            'title': '',
                                            'note': '',
                                            'image':item['image'],
                                            'isImageList':true,
                                          };
                                          itemsInfoPrint.add(quotationItemInfo);
                                        }
                                      }
                                      return PrintQuotationData(
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
                                        ref: refController.text,
                                        receivedUser: '',
                                        senderUser: homeController.userName,
                                        status: '',
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
                                _saveContent();

                                var oldKeys =
                                quotationController
                                    .rowsInListViewInQuotation
                                    .keys
                                    .toList()
                                  ..sort();
                                for (int i = 0; i < oldKeys.length; i++) {
                                  quotationController.newRowMap[i + 1] =
                                  quotationController
                                      .rowsInListViewInQuotation[oldKeys[i]]!;
                                }

                                var res = await storeQuotations(
                                  refController.text,
                                  selectedCustomerIds,
                                  validityController.text,
                                  '',//todo paymentTermsController.text,
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
                                  quotationCont.isVatNoPrinted ? '1' : '0',
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
                                  // quotationController.rowsInListViewInQuotation,
                                  quotationController.newRowMap,

                                  titleController.text,
                                );
                                if (res['success'] == true) {
                                  CommonWidgets.snackBar(
                                    'Success',
                                    res['message'],
                                  );
                                  homeController.selectedTab.value =
                                  'quotation_summary';
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
                                              'line_type_id':'2',
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
                                              'isImageList':true,
                                              'note': '',
                                              'image':''
                                            };
                                            itemsInfoPrint.add(quotationItemInfo);
                                          }
                                          else if ('${item['line_type_id']}' == '3') {
                                            var qty = item['item_quantity'];
                                            // var map =
                                            // quotationCont
                                            //     .combosMap[item['combo']
                                            //     .toString()];
                                            var ind=quotationCont
                                                .combosIdsList.indexOf(item['combo']
                                                .toString());
                                            var itemName = quotationCont.combosNamesList[ind];
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
                                              'line_type_id':'3',
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
                                              'isImageList':true,
                                              'title': '',
                                              'image':''
                                            };
                                            itemsInfoPrint.add(quotationItemInfo);
                                          }
                                          else if('${item['line_type_id']}' == '1'){
                                            var quotationItemInfo = {
                                              'line_type_id':'1',
                                              'item_name': '',
                                              'item_description': '',
                                              'item_quantity': '',
                                              'item_unit_price': '',
                                              'item_discount':'0',
                                              'item_total':'',
                                              'item_image': '',
                                              'item_brand': '',
                                              'note': '',
                                              'isImageList':true,
                                              'title':item['title'],
                                              'image':''
                                            };
                                            itemsInfoPrint.add(quotationItemInfo);
                                          }
                                          else if('${item['line_type_id']}' == '5'){
                                            var quotationItemInfo = {
                                              'line_type_id':'5',
                                              'item_name': '',
                                              'item_description': '',
                                              'item_quantity': '',
                                              'item_unit_price': '',
                                              'item_discount':'0',
                                              'item_total':'',
                                              'item_image': '',
                                              'item_brand': '',
                                              'title': '',
                                              'note':item['note'],
                                              'image':'',
                                              'isImageList':true,
                                            };
                                            itemsInfoPrint.add(quotationItemInfo);
                                          }
                                          else if('${item['line_type_id']}' == '4'){
                                            var quotationItemInfo = {
                                              'line_type_id':'4',
                                              'item_name': '',
                                              'item_description': '',
                                              'item_quantity': '',
                                              'item_unit_price': '',
                                              'item_discount':'0',
                                              'item_total':'',
                                              'item_image': '',
                                              'item_brand': '',
                                              'title': '',
                                              'note': '',
                                              'image':item['image'],
                                              'isImageList':true,
                                            };
                                            itemsInfoPrint.add(quotationItemInfo);
                                          }
                                        }
                                        return PrintQuotationData(
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
                                          ref: refController.text,
                                          receivedUser: '',
                                          senderUser: homeController.userName,
                                          status: '',
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
                                          termsAndConditions:
                                          termsAndConditionsController.text,
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

                                // }
                              },
                            ),
                            UnderTitleBtn(
                              text: 'send_by_email'.tr,
                              onTap: () {
                                if (progressVar == 0) {
                                  setState(() {
                                    progressVar += 1;
                                  });
                                }
                              },
                            ),
                            UnderTitleBtn(
                              text: 'confirm'.tr,
                              onTap: () {
                                if (progressVar == 1) {
                                  setState(() {
                                    progressVar += 1;
                                  });
                                }
                              },
                            ),
                            UnderTitleBtn(
                              text: 'cancel'.tr,
                              onTap: () {
                                setState(() {
                                  progressVar = 0;
                                });
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
                                quotationCont.quotationNumber,
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
                                              quotationCont.setSelectedCurrency(
                                                cont.currenciesIdsList[index],
                                                val,
                                              );
                                              quotationCont
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
                                                } else if (quotationCont
                                                            .selectedCurrencyName ==
                                                        'USD' &&
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
                                              if (selectedComboId != '') {
                                                var ind = quotationCont.combosIdsList.indexOf(selectedComboId);
                                                if (quotationCont
                                                        .combosPricesCurrencies[selectedComboId] ==
                                                    quotationCont
                                                        .selectedCurrencyName) {
                                                  quotationCont
                                                      .combosPriceControllers[comboKeys[i]]!
                                                      .text = quotationCont
                                                          .combosPricesList[ind]
                                                          .toString();
                                                } else if (quotationCont
                                                            .selectedCurrencyName ==
                                                        'USD' &&
                                                    quotationCont
                                                            .combosPricesCurrencies[selectedComboId] !=
                                                        quotationCont
                                                            .selectedCurrencyName) {
                                                  var result = exchangeRatesController
                                                      .exchangeRatesList
                                                      .firstWhere(
                                                        (item) =>
                                                            item["currency"] ==
                                                            quotationCont
                                                                .combosPricesCurrencies[selectedComboId],
                                                        orElse: () => null,
                                                      );
                                                  var divider = '1';
                                                  if (result != null) {
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
                                                  var result = exchangeRatesController
                                                      .exchangeRatesList
                                                      .firstWhere(
                                                        (item) =>
                                                            item["currency"] ==
                                                            quotationCont
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
                                                ).toStringAsFixed(2);
                                                var totalLine =
                                                    '${(int.parse(quotationCont.rowsInListViewInQuotation[comboKeys[i]]['item_quantity']) * double.parse(quotationCont.combosPriceControllers[comboKeys[i]]!.text)) * (1 - double.parse(quotationCont.rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';
                                                quotationCont
                                                    .setEnteredQtyInQuotation(
                                                  comboKeys[i],
                                              quotationCont.rowsInListViewInQuotation[comboKeys[i]]['item_quantity'],
                                                    );
                                                quotationCont
                                                    .setMainTotalInQuotation(
                                                  comboKeys[i],
                                                      totalLine,
                                                    );
                                                // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
                                                quotationCont.getTotalItems();

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
                                          quotationCont.priceListsCodes.map<
                                            DropdownMenuEntry<String>
                                          >((String option) {
                                            return DropdownMenuEntry<String>(
                                              value: option,
                                              label: option,
                                            );
                                          }).toList(),
                                      enableFilter: true,
                                      onSelected: (String? val) {
                                        var index = quotationCont
                                            .priceListsCodes
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
                          gapH16,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.37,
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
                                          0.13,
                                      textFieldWidth:
                                          MediaQuery.of(context).size.width *
                                          0.1,
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
                                          0.18,
                                      textFieldWidth:
                                          MediaQuery.of(context).size.width *
                                          0.17,
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
                                          'Phone Number'.tr,
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
                                    //email
                                    Row(
                                      children: [
                                        Text(
                                          'email'.tr,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        gapW10,
                                        Text(
                                          "${quotationCont.email[selectedCustomerIds] ?? ''}",
                                          style: const TextStyle(fontSize: 12),
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
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TableTitle(
                                    text: 'item_code'.tr,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.14,
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
                                        MediaQuery.of(context).size.width *
                                        0.05,
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
                                        MediaQuery.of(context).size.width *
                                        0.05,
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
                                    child: ListView(
                                      children:
                                          keysList.map((key) {
                                            return Dismissible(
                                              key: Key(
                                                key,
                                              ), // Ensure each widget has a unique key
                                              onDismissed:
                                                  (direction) => quotationCont
                                                      .removeFromOrderLinesInQuotationList(
                                                        key.toString(),
                                                      ),
                                              child:
                                                  quotationCont
                                                      .orderLinesQuotationList[key] ??
                                                  const SizedBox(),
                                            );
                                          }).toList(),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            onPressed: _loadContent,
                                          ),
                                          gapW6,
                                          IconButton(
                                            icon: const Icon(Icons.restore),
                                            onPressed: _loadContent,
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
                                        QuillSimpleToolbar(controller: _controller,
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
                                            showCodeBlock: false
                                          )),
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
                                    _saveContent();
                                    var oldKeys =
                                        quotationController
                                            .rowsInListViewInQuotation
                                            .keys
                                            .toList()
                                          ..sort();
                                    for (int i = 0; i < oldKeys.length; i++) {
                                      quotationController.newRowMap[i + 1] =
                                          quotationController
                                              .rowsInListViewInQuotation[oldKeys[i]]!;
                                    }

                                    var res = await storeQuotations(
                                      refController.text,
                                      selectedCustomerIds,
                                      validityController.text,
                                      '',//todo paymentTermsController.text,
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
                                      quotationCont.isVatNoPrinted ? '1' : '0',
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
                                      // quotationController.rowsInListViewInQuotation,
                                      quotationController.newRowMap,

                                      titleController.text,
                                    );
                                    if (res['success'] == true) {
                                      CommonWidgets.snackBar(
                                        'Success',
                                        res['message'],
                                      );
                                      homeController.selectedTab.value =
                                          'quotation_summary';
                                    } else {
                                      CommonWidgets.snackBar(
                                        'error',
                                        res['message'],
                                      );
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
  int quotationCounter = 0;
  addNewTitle() {
    setState(() {
      quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
    );
    quotationController.addToRowsInListViewInQuotation(quotationCounter, {
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
    Widget p = ReusableTitleRow(index: quotationCounter);

    quotationController.addToOrderLinesInQuotationList('$quotationCounter', p);
  }

  addNewItem() {
    setState(() {
      quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
    );

    // int index = quotationController.orderLinesQuotationList.length + 1;

    quotationController.addToRowsInListViewInQuotation(quotationCounter, {
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
    quotationController.addToUnitPriceControllers(quotationCounter);
    Widget p = ReusableItemRow(index: quotationCounter);

    quotationController.addToOrderLinesInQuotationList('$quotationCounter', p);
  }

  addNewCombo() {
    setState(() {
      quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
    );

    quotationController.addToRowsInListViewInQuotation(quotationCounter, {
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
    quotationController.addToCombosPricesControllers(quotationCounter);

    Widget p = ReusableComboRow(index: quotationCounter);
    quotationController.addToOrderLinesInQuotationList('$quotationCounter', p);
  }

  addNewImage() {
    setState(() {
      quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment + 50,
    );

    quotationController.addToRowsInListViewInQuotation(quotationCounter, {
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
    Widget p = ReusableImageRow(index: quotationCounter);

    quotationController.addToOrderLinesInQuotationList('$quotationCounter', p);
  }

  addNewNote() {
    setState(() {
      quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
    );

    quotationController.addToRowsInListViewInQuotation(quotationCounter, {
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

    Widget p = ReusableNoteRow(index: quotationCounter);

    quotationController.addToOrderLinesInQuotationList('$quotationCounter', p);
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
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // discountController.text = '0';
    // qtyController.text = '0';
    // discount = '0';
    // quantity = '0';
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
    itemCodeController.text =
        quotationController.rowsInListViewInQuotation[widget
            .index]['item_main_code'];

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
                Container(
                  width: MediaQuery.of(context).size.width * 0.02,
                  height: 20,
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/newRow.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                ReusableDropDownMenusWithSearch(
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
                    if (value == null || value.isEmpty) {
                      return 'select_option'.tr;
                    }
                    return null;
                  },
                  rowWidth: MediaQuery.of(context).size.width * 0.13,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.13,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.27,
                  child: TextFormField(
                    style: GoogleFonts.openSans(fontSize: 12),
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    textAlign: TextAlign.center,
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

                      cont.setEnteredQtyInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
                      // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
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
                      cont.setEnteredDiscInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
                      await cont.getTotalItems();
                    },
                  ),
                ),

                //total
                ReusableShowInfoCard(
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
                              quotationController
                                  .decrementListViewLengthInQuotation(
                                    quotationController.increment,
                                  );
                              quotationController
                                  .removeFromRowsInListViewInQuotation(
                                    widget.index,
                                  );
                              quotationController
                                  .removeFromOrderLinesInQuotationList(
                                    widget.index.toString(),
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
  final _formKey = GlobalKey<FormState>();

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
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.02,
                  height: 20,
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/newRow.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
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
                              quotationController
                                  .removeFromOrderLinesInQuotationList(
                                    widget.index.toString(),
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
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //image
            Container(
              width: MediaQuery.of(context).size.width * 0.02,
              height: 20,
              margin: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/newRow.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
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
                          quotationController
                              .decrementListViewLengthInQuotation(
                                quotationController.increment,
                              );
                          quotationController
                              .removeFromRowsInListViewInQuotation(
                                widget.index,
                              );
                          quotationController
                              .removeFromOrderLinesInQuotationList(
                                widget.index.toString(),
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
  final QuotationController quotationController = Get.find();
  late Uint8List imageFile;

  double listViewLength = Sizes.deviceHeight * 0.08;

  final _formKey = GlobalKey<FormState>();

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
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //image
            Container(
              width: MediaQuery.of(context).size.width * 0.02,
              height: 20,
              margin: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/newRow.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            //image
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
                          quotationController
                              .decrementListViewLengthInQuotation(
                                quotationController.increment + 50,
                              );
                          quotationController
                              .removeFromRowsInListViewInQuotation(
                                widget.index,
                              );
                          quotationController
                              .removeFromOrderLinesInQuotationList(
                                widget.index.toString(),
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
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    comboCodeController.text =
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
    comboCodeController.text =
        quotationController.rowsInListViewInQuotation[widget
            .index]['item_main_code'];


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
                Container(
                  width: MediaQuery.of(context).size.width * 0.02,
                  height: 20,
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/newRow.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                ReusableDropDownMenusWithSearch(
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
                  rowWidth: MediaQuery.of(context).size.width * 0.13,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.13,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.27,
                  child: TextFormField(
                    style: GoogleFonts.openSans(fontSize: 12),
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    textAlign: TextAlign.center,
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

                      cont.setEnteredQtyInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
                      // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
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
                      cont.setEnteredDiscInQuotation(widget.index, val);
                      cont.setMainTotalInQuotation(widget.index, totalLine);
                      await cont.getTotalItems();
                    },
                  ),
                ),

                //total
                ReusableShowInfoCard(
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
                              quotationController
                                  .removeFromOrderLinesInQuotationList(
                                    widget.index.toString(),
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
