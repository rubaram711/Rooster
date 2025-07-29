
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Screens/Quotations/print_quotation.dart';
import 'package:rooster_app/Widgets/dialog_drop_menu.dart';
import 'package:rooster_app/const/functions.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Controllers/home_controller.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/TransferWidgets/reusable_show_info_card.dart';
import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../Widgets/TransferWidgets/under_item_btn.dart';
import '../../Widgets/table_title.dart';
import '../../const/Delta/convert_from_delta_to_widget.dart';
import '../../const/urls.dart';



// import 'package:http/http.dart' as http;
class QuotationData extends StatefulWidget {
  const QuotationData({super.key});

  @override
  State<QuotationData> createState() => _QuotationDataState();
}

class _QuotationDataState extends State<QuotationData> {
  String brand = '';
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
  double totalPriceAfterSpecialDiscountByQuotationCurrency = 0.0;
  double vatByQuotationCurrency = 0.0;
  double finalPriceByQuotationCurrency = 0.0;
  List itemsInfoPrint = [];

  Map quotationItemInfo = {};
  // String itemCurrencyName = '';
  // String itemCurrencySymbol = '';
  // String itemCurrencyLatestRate = '';

  TextEditingController commissionController = TextEditingController();
  TextEditingController totalCommissionController = TextEditingController();

  // bool isVatExemptChecked = false;

  String specialDisc = '';

  int currentStep = 0;
  int selectedTabIndex = 0;
  List tabsList = ['order_lines', 'other_information'];

  String selectedTab = 'order_lines'.tr;
  String? selectedItem = '';
  String? selectedItemCode = '';

  bool isActiveVatChecked = false;
  bool isActiveDeliveredChecked = false;
  final QuotationController quotationController = Get.find();
  final HomeController homeController = Get.find();
  String selectedCurrencyId = '';

  int progressVar = 0;
  String selectedCustomerIds = '';
  checkVatExempt() async {
    var companySubjectToVat = await getCompanySubjectToVatFromPref();
    if(companySubjectToVat=='1'){
      quotationController.setIsVatExempted(false, false,false);
      quotationController.setIsVatExemptCheckBoxShouldAppear(true);
    }else{
      quotationController.setIsVatExemptCheckBoxShouldAppear(false);
      quotationController.setIsVatExempted(false, false,true);
      quotationController.setIsVatExemptChecked(true);
    }
  }


  @override
  void initState() {
    checkVatExempt();
    quotationController.email[selectedCustomerIds] = '';
    quotationController.phoneNumber[selectedCustomerIds] = '';
    quotationController.resetQuotation();
    quotationController.listViewLengthInQuotation = 50;
    quotationController.isVatExemptChecked =
        quotationController.selectedQuotationData['vatExempt'] == 1
            ? true
            : false;


    super.initState();
  }

  int index = 0;
  int indexNum = 0;
  String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuotationController>(
      builder: (quotationCont) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [PageTitle(text: 'quotation'.tr)],
                ),
                gapH16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        UnderTitleBtn(
                          text: 'preview'.tr,
                          onTap: () async {
                            itemsInfoPrint = [];
                            quotationItemInfo = {};
                            totalAllItems = 0;
                            // quotationCont.totalAllItems = 0;
                            // for (var item in quotationController.selectedQuotationData['orderLines']) {
                            //   ind[item['item_id']] = item['item_quantity'];
                            // }
                            totalAllItems = 0;
                            quotationCont.totalAllItems = 0;
                            totalPriceAfterDiscount = 0;
                            additionalSpecialDiscount = 0;
                            totalPriceAfterSpecialDiscount = 0;
                            totalPriceAfterSpecialDiscountByQuotationCurrency =
                                0;
                            vatByQuotationCurrency = 0;
                            vatByQuotationCurrency = 0;
                            finalPriceByQuotationCurrency = 0;
                            for (var item
                                in quotationController
                                    .selectedQuotationData['orderLines']) {
                              if ('${item['line_type_id']}' == '2') {
                                qty = item['item_quantity'];
                                var map =
                                    quotationController.itemsMap[item['item_id']
                                        .toString()];
                                itemName = map['item_name'];
                                itemPrice = double.parse(
                                  '${item['item_unit_price'] ?? '0'}',
                                );
                                itemDescription = item['item_description'];
                                '${map['images']}' != '[]'
                                    ? itemImage = map['images'][0]
                                    : '';
                                // itemCurrencyName =
                                // map['currency']['name'];
                                // itemCurrencySymbol =
                                // map['currency']['symbol'];
                                // itemCurrencyLatestRate =
                                // map['currency']['latest_rate'];
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
                                itemTotal = double.parse(
                                  '${item['item_total']}',
                                );
                                // itemTotal = double.parse(qty) * itemPrice;
                                totalAllItems += itemTotal;
                                quotationItemInfo = {
                                  'item_name': itemName,
                                  'item_description': itemDescription,
                                  'item_quantity': qty,
                                  'item_discount': item['item_discount'] ?? '0',
                                  'item_unit_price': formatDoubleWithCommas(
                                    itemPrice,
                                  ),
                                  'item_total': formatDoubleWithCommas(
                                    itemTotal,
                                  ),
                                  'item_image': itemImage,
                                  'item_brand': brand,
                                  'title': '',
                                  'isImageList':false,
                                  'note': '',
                                  'image':''
                                };
                                itemsInfoPrint.add(quotationItemInfo);
                              } else if ('${item['line_type_id']}' == '3') {
                                var qty = item['item_quantity'];
                                // var map =
                                // quotationController
                                //     .combosMap[item['combo_id']
                                //     .toString()];
                                var ind=quotationController
                                    .combosIdsList.indexOf(item['combo_id']
                                    .toString());
                                var itemName = quotationController.combosNamesList[ind];
                                var itemPrice = double.parse(
                                  '${item['combo_price'] ?? 0.0}',
                                );
                                var itemDescription =
                                item['combo_description'];


                                var itemTotal = double.parse(
                                  '${item['combo_total']}',
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
                                  item['combo_discount'] ?? '0',
                                  'item_total':
                                  formatDoubleWithCommas(
                                    itemTotal,
                                  ),
                                  'note': '',
                                  'item_image': '',
                                  'item_brand': '',
                                  'isImageList':false,
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
                                  'isImageList':false,
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
                                  'isImageList':false,
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
                                  'image':'$baseImage${item['image']}',
                                  'isImageList':false,
                                };
                                itemsInfoPrint.add(quotationItemInfo);
                              }
                            }
                            discountOnAllItem =
                                totalAllItems *
                                    double.parse(
                                      quotationController.selectedQuotationData['globalDiscount'] ?? '0',
                                    ) /
                                    100;

                            totalPriceAfterDiscount =
                                totalAllItems - discountOnAllItem;
                            additionalSpecialDiscount =
                                totalPriceAfterDiscount *
                                    double.parse(
                                      quotationController.selectedQuotationData['specialDiscount'] ?? '0',
                                    ) /
                                    100;
                            totalPriceAfterSpecialDiscount =
                                totalPriceAfterDiscount -
                                    additionalSpecialDiscount;
                            totalPriceAfterSpecialDiscountByQuotationCurrency =
                                totalPriceAfterSpecialDiscount ;
                            vatByQuotationCurrency =
                            '${quotationController.selectedQuotationData['vatExempt']}' == '1'
                                ? 0
                                : (totalPriceAfterSpecialDiscountByQuotationCurrency *
                                double.parse(
                                  await getCompanyVatFromPref(),
                                )) /
                                100;
                            finalPriceByQuotationCurrency =
                                totalPriceAfterSpecialDiscountByQuotationCurrency +
                                    vatByQuotationCurrency;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return PrintQuotationData(
                                    isPrintedAs0: '${quotationController.selectedQuotationData['printedAsPercentage']}'=='1'?true:false,
                                    isVatNoPrinted: '${quotationController.selectedQuotationData['notPrinted']}'=='1'?true:false,
                                    isPrintedAsVatExempt:'${quotationController.selectedQuotationData['printedAsVatExempt']}'=='1'?true:false,
                                    isInQuotation: true,
                                    quotationNumber:
                                        quotationController
                                            .selectedQuotationData['quotationNumber'] ??
                                        '',
                                    creationDate:
                                        quotationController
                                            .selectedQuotationData['validity'] ??
                                        '',
                                    ref:
                                        quotationController
                                            .selectedQuotationData['reference'] ??
                                        '',
                                    receivedUser: '',
                                    senderUser: homeController.userName,
                                    status:
                                        quotationController
                                            .selectedQuotationData['status'] ??
                                        '',
                                    totalBeforeVat: '${quotationController.selectedQuotationData['totalBeforeVat']}',
                                    discountOnAllItem:
                                        discountOnAllItem.toString(),
                                    totalAllItems:
                                    // totalAllItems.toString()  ,
                                    formatDoubleWithCommas(
                                      totalPriceAfterDiscount,
                                    ),

                                    globalDiscount:
                                        quotationController
                                            .selectedQuotationData['globalDiscount'] ??
                                        '0',

                                    totalPriceAfterDiscount:
                                    // totalPriceAfterDiscount.toString() ,
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
                                    totalPriceAfterSpecialDiscountByQuotationCurrency:
                                        formatDoubleWithCommas(
                                          totalPriceAfterSpecialDiscountByQuotationCurrency,
                                        ),
                                    vatByQuotationCurrency:
                                        formatDoubleWithCommas(
                                          vatByQuotationCurrency,
                                        ),
                                    finalPriceByQuotationCurrency:
                                        formatDoubleWithCommas(
                                          finalPriceByQuotationCurrency,
                                        ),
                                    specialDisc: specialDisc.toString(),
                                    specialDiscount:
                                        quotationController
                                            .selectedQuotationData['specialDiscount'] ??
                                        '0',
                                    specialDiscountAmount:
                                        quotationController
                                            .selectedQuotationData['specialDiscountAmount'] ??
                                        '',
                                    salesPerson:
                                        quotationController
                                                    .selectedQuotationData['salesperson'] !=
                                                null
                                            ? quotationController
                                                .selectedQuotationData['salesperson']['name']
                                            : '---',
                                    quotationCurrency:
                                        quotationController
                                            .selectedQuotationData['currency']['name'] ??
                                        '',
                                    quotationCurrencySymbol:
                                        quotationController
                                            .selectedQuotationData['currency']['symbol'] ??
                                        '',
                                    quotationCurrencyLatestRate:
                                        quotationController
                                            .selectedQuotationData['currency']['latest_rate'] ??
                                        '',
                                    clientPhoneNumber:
                                        quotationController
                                            .selectedQuotationData['client']['phoneNumber'] ??
                                        '---',
                                    clientName:
                                        quotationController
                                            .selectedQuotationData['client']['name'] ??
                                        '',
                                    termsAndConditions:
                                        quotationController
                                            .selectedQuotationData['termsAndConditions'] ??
                                        '',
                                    // rowsInListViewInQuotation: widget.info['orderLines'],
                                    itemsInfoPrint: itemsInfoPrint,
                                  );
                                },
                              ),
                            );
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
                          Text(
                            quotationCont
                                .selectedQuotationData['quotationNumber'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: TypographyColor.titleTable,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ref'.tr),
                                ReusableShowInfoCard(
                                  text:
                                      quotationCont
                                          .selectedQuotationData['reference'] ??
                                      '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.12,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('currency'.tr),
                                ReusableShowInfoCard(
                                  text:
                                      quotationCont
                                          .selectedQuotationData['currency']['name'] ??
                                      '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('validity'.tr),
                                ReusableShowInfoCard(
                                  text:
                                      quotationCont
                                          .selectedQuotationData['validity'] ??
                                      '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                ),

                                // DialogDateTextField(
                                //   textEditingController: validityController,
                                //   text: '',
                                //   textFieldWidth:
                                //   MediaQuery.of(context).size.width * 0.20,
                                //   validationFunc: (val) {},
                                //   onChangedFunc: (val) {
                                //     // dateController.text=val;
                                //   },
                                //   onDateSelected: (value) {
                                //     String rd=quotationCont.selectedQuotationData['validity'].substring(0,10);
                                //     DateTime dt1 = DateTime.parse("$rd 00:00:00");
                                //     DateTime dt2 = DateTime.parse("$value 00:00:00");
                                //     if(dt2.isBefore(dt1)){
                                //       CommonWidgets.snackBar(
                                //           'error',
                                //           'Received date can\'t be before transfer date');
                                //     }else{
                                //       validityController.text = value;}
                                //   },
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('pricelist'.tr),

                                ReusableShowInfoCard(
                                  text: '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
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
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('code'.tr),
                                ReusableShowInfoCard(
                                  text:
                                      quotationCont
                                          .selectedQuotationData['code'] ??
                                      '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),

                                ReusableShowInfoCard(
                                  text:
                                      quotationCont
                                          .selectedQuotationData['client']['name'] ??
                                      '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.24,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('payment_terms'.tr),
                                ReusableShowInfoCard(
                                  text: '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
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
                                Row(
                                  children: [
                                    Text(
                                      '${'Street_building_floor'.tr} :',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    gapW10,
                                    GetBuilder<QuotationController>(
                                      builder: (cont) {
                                        return (quotationCont
                                                        .selectedQuotationData['client']['floor_and_building'] ==
                                                    null &&
                                                quotationCont
                                                        .selectedQuotationData['client']['street'] ==
                                                    null)
                                            ? Text(
                                              '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            )
                                            : Row(
                                              children: [
                                                Text(
                                                  // "${quotationCont.selectedQuotationData['client']['country']} ",
                                                  quotationCont
                                                          .selectedQuotationData['client']['street'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                gapW10,
                                                quotationCont
                                                            .selectedQuotationData['client']['floor_and_building'] ==
                                                        null
                                                    ? Text(
                                                      '',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                    : Text(
                                                      quotationCont
                                                              .selectedQuotationData['client']['city'] ??
                                                          '',
                                                      // "${quotationCont.selectedQuotationData['client']['city']} ",
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                              ],
                                            );
                                      },
                                    ),
                                  ],
                                ),
                                gapH6,
                                Row(
                                  children: [
                                    Text(
                                      'phone_number'.tr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    gapW10,
                                    GetBuilder<QuotationController>(
                                      builder: (cont) {
                                        return quotationCont
                                                    .selectedQuotationData['client']['phoneNumber'] ==
                                                null
                                            ? Text(
                                              '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            )
                                            : Text(
                                              quotationCont
                                                      .selectedQuotationData['client']['phoneNumber'] ??
                                                  '',

                                              // "${quotationCont.selectedQuotationData['client']['phoneNumber']}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            );
                                      },
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('price'.tr),
                                quotationController
                                            .selectedQuotationData['beforeVatPrices'] ==
                                        1
                                    ? ReusableShowInfoCard(
                                      text: 'Prices are before vat',
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                    )
                                    : quotationController
                                            .selectedQuotationData['vatInclusivePrices'] ==
                                        1
                                    ? ReusableShowInfoCard(
                                      text: 'Prices are vat inclusive',
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                    )
                                    : Text(''),
                              ],
                            ),
                          ),

                          //vat exempt
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
                                Row(
                                  children: [
                                    Text(
                                      'email'.tr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    gapW10,
                                    GetBuilder<QuotationController>(
                                      builder: (cont) {
                                        return quotationCont
                                                    .selectedQuotationData['client']['email'] ==
                                                null
                                            ? Text(
                                              '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            )
                                            : Text(
                                              quotationCont
                                                      .selectedQuotationData['client']['email'] ??
                                                  '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            );
                                      },
                                    ),
                                  ],
                                ),
                                gapH6,
                                Row(
                                  children: [
                                    quotationCont.isVatExemptCheckBoxShouldAppear?Text(
                                      'vat'.tr,
                                      style: const TextStyle(fontSize: 12),
                                    ):SizedBox(),
                                    gapW10,
                                  ],
                                ),
                              ],
                            ),
                          ),
                          gapW16,
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      'vat_exempt'.tr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    leading: Checkbox(
                                      // checkColor: Colors.white,
                                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                                      value: quotationCont.isVatExemptChecked,
                                      onChanged: (bool? value) {},
                                    ),
                                  ),
                                ),
                                quotationController
                                            .selectedQuotationData['vatExempt'] ==
                                        0
                                    ? ReusableShowInfoCard(
                                      text: '',
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                    )
                                    : quotationController
                                                .selectedQuotationData['vatExempt'] ==
                                            1 &&
                                        quotationController
                                                .selectedQuotationData['printedAsVatExempt'] ==
                                            1
                                    ? ReusableShowInfoCard(
                                      text: 'Printed as "vat exempted"',
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                    )
                                    : quotationController
                                                .selectedQuotationData['vatExempt'] ==
                                            1 &&
                                        quotationController
                                                .selectedQuotationData['printedAsPercentage'] ==
                                            1
                                    ? ReusableShowInfoCard(
                                      text: 'Printed as "vat 0 % = 0"',
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                    )
                                    : quotationController
                                                .selectedQuotationData['vatExempt'] ==
                                            1 &&
                                        quotationController
                                                .selectedQuotationData['notPrinted'] ==
                                            1
                                    ? ReusableShowInfoCard(
                                      text:
                                          // 'exempted from vat , no printed'
                                          'Not Printed',
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                    )
                                    : Text(''),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // test

                // Container(
                //     width: 300, // Set width
                //     height: 150, // Set height (rectangle shape)
                //     decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
                //         image: DecorationImage(
                //           image: NetworkImage(
                //               // "https://www.google.com/imgres?q=image&imgurl=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1575936123452-b67c3203c357%3Ffm%3Djpg%26q%3D60%26w%3D3000%26ixlib%3Drb-4.0.3%26ixid%3DM3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW1hZ2V8ZW58MHx8MHx8fDA%253D&imgrefurl=https%3A%2F%2Funsplash.com%2Fs%2Fphotos%2Fimage&docid=ExDvm63D_wCvSM&tbnid=-mNI5DBCB_iEPM&vet=12ahUKEwitxdXs7uiLAxX_VqQEHSDQBI8QM3oECBYQAA..i&w=3000&h=2000&hcb=2&ved=2ahUKEwitxdXs7uiLAxX_VqQEHSDQBI8QM3oECBYQAA"
                //               "$baseImagestorage/quotations/images/104/v6TEQ7lVrXwGdegbut0Emfwvdrr6It1tloihspla.png"
                //             ), // Replace with your URL
                //           // fit: BoxFit.cover, // Adjust how the image fits
                //         ))
                //
                // ),
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
                                width: MediaQuery.of(context).size.width * 0.02,
                              ),
                              TableTitle(
                                text: 'item_code'.tr,
                                width: MediaQuery.of(context).size.width * 0.14,
                              ),
                              TableTitle(
                                text: 'description'.tr,
                                width: MediaQuery.of(context).size.width * 0.28,
                              ),
                              TableTitle(
                                text: 'quantity'.tr,
                                width: MediaQuery.of(context).size.width * 0.06,
                              ),
                              TableTitle(
                                text: 'unit_price'.tr,
                                width: MediaQuery.of(context).size.width * 0.06,
                              ),
                              TableTitle(
                                text: '${'disc'.tr}. %',
                                width: MediaQuery.of(context).size.width * 0.06,
                              ),
                              TableTitle(
                                text: 'total'.tr,
                                width: MediaQuery.of(context).size.width * 0.07,
                              ),
                              // TableTitle(
                              //   text: '${'more_options'.tr}',
                              //   width: MediaQuery.of(context).size.width *
                              //       0.07,
                              // ),
                            ],
                          ),
                        ),

                        Container(
                          // padding: EdgeInsets.symmetric(
                          //     horizontal:
                          //     MediaQuery.of(context).size.width *
                          //         0.01),
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
                              GetBuilder<QuotationController>(
                                builder: (cont) {
                                  return SizedBox(
                                    height:
                                        cont
                                            .selectedQuotationData['orderLines']
                                            .length *
                                        100,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      itemCount:
                                          cont
                                              .selectedQuotationData['orderLines']
                                              .length,
                                      itemBuilder:
                                          (context, index) => Column(
                                            children: [
                                              cont.selectedQuotationData['orderLines'][index]['line_type_id'] ==
                                                      2
                                                  ? ReusableItemRow(
                                                    index: index,
                                                    info:
                                                        cont.selectedQuotationData['orderLines'][index],
                                                  )
                                                  : cont.selectedQuotationData['orderLines'][index]['line_type_id'] ==
                                                      1
                                                  ? ReusableTitleRow(
                                                    index: index,
                                                    info:
                                                        cont.selectedQuotationData['orderLines'][index],
                                                  )
                                                  : cont.selectedQuotationData['orderLines'][index]['line_type_id'] ==
                                                      4
                                                  ? ReusableImageRow(
                                                    index: index,
                                                    info:
                                                        cont.selectedQuotationData['orderLines'][index],
                                                  )
                                                  : ReusableNoteRow(
                                                    index: index,
                                                    info:
                                                        cont.selectedQuotationData['orderLines'][index],
                                                  ),
                                            ],
                                          ),

                                      // =>
                                    ),
                                  );
                                },
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
                              Text(
                                'terms_conditions'.tr,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: TypographyColor.titleTable,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              gapH16,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  quillDeltaToWidget('${quotationController.selectedQuotationData['termsAndConditions'] ?? ''} '),
                                ],
                              )
                              // ReusableShowInfoCard(v v
                              //   text:
                              //       '${quotationController.selectedQuotationData['termsAndConditions'] ?? ''} ',
                              //   width: MediaQuery.of(context).size.width * 0.9,
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
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('total_before_vat'.tr),
                                        ReusableShowInfoCard(
                                          text:
                                              '${quotationController.selectedQuotationData['totalBeforeVat']}',
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
                                              child: ReusableShowInfoCard(
                                                text:
                                                '${quotationController.selectedQuotationData['globalDiscount'] ?? '0'}',
                                                width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                    0.1,
                                              ),
                                            ),
                                            gapW10,
                                            ReusableShowInfoCard(
                                              text:
                                              '${quotationController.selectedQuotationData['globalDiscountAmount'] ?? '0'}',
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
                                              child: ReusableShowInfoCard(
                                                text:
                                                '${quotationController.selectedQuotationData['specialDiscount'] ?? ''}',
                                                width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                    0.1,
                                              ),
                                            ),
                                            gapW10,
                                            ReusableShowInfoCard(
                                              text:
                                              '${quotationController.selectedQuotationData['specialDiscountAmount'] ?? ''}',
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
                                    quotationCont.isVatNoPrinted ?SizedBox():Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(quotationCont.isPrintedAsVatExempt
                                            ?'vat_exempt'.tr.toUpperCase()
                                            :quotationCont.isPrintedAs0 ?
                                        '${'vat'.tr} 0%'
                                            :'vat'.tr),
                                        Row(
                                          children: [
                                            ReusableShowInfoCard(
                                              text:quotationCont.isVatExemptChecked?'0':
                                              '${quotationController.selectedQuotationData['vatLebanese']}',
                                              width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                                  0.1,
                                            ),
                                            gapW10,
                                            ReusableShowInfoCard(
                                              text:quotationCont.isVatExemptChecked?'0':
                                              '${quotationController.selectedQuotationData['vat']}',
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
                                          '${quotationCont.selectedQuotationData['currency']['name']} ${quotationCont.isVatExemptChecked
                                              ?double.parse('${quotationController.selectedQuotationData['total']}')-double.parse('${quotationController.selectedQuotationData['vat']}')
                                              :quotationController.selectedQuotationData['total']}',
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
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('sales_person'.tr),

                                      quotationController
                                                  .selectedQuotationData['salesperson'] !=
                                              null
                                          ? ReusableShowInfoCard(
                                            text:
                                                '${quotationController.selectedQuotationData['salesperson']['name']}',
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.15,
                                          )
                                          : ReusableShowInfoCard(
                                            text: '',
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.15,
                                          ),
                                    ],
                                  ),
                                ),
                                // DialogDropMenu(
                                //   optionsList: const [''],
                                //   text: 'sales_person'.tr,
                                //   hint: 'search'.tr,
                                //   rowWidth: MediaQuery.of(context)
                                //       .size
                                //       .width *
                                //       0.3,
                                //   textFieldWidth: MediaQuery.of(context)
                                //       .size
                                //       .width *
                                //       0.15,
                                //   onSelected: () {},
                                // ),
                                gapH16,
                                DialogDropMenu(
                                  optionsList: const [''],
                                  text: 'commission_method'.tr,
                                  hint: '',
                                  rowWidth:
                                      MediaQuery.of(context).size.width * 0.3,
                                  textFieldWidth:
                                      MediaQuery.of(context).size.width * 0.15,
                                  onSelected: () {},
                                ),
                                gapH16,
                                DialogDropMenu(
                                  optionsList: ['cash'.tr],
                                  text: 'cashing_method'.tr,
                                  hint: '',
                                  rowWidth:
                                      MediaQuery.of(context).size.width * 0.3,
                                  textFieldWidth:
                                      MediaQuery.of(context).size.width * 0.15,
                                  onSelected: () {},
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
                                      MediaQuery.of(context).size.width * 0.15,
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
                                      MediaQuery.of(context).size.width * 0.15,
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
        );
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

//item 2
class ReusableItemRow extends StatelessWidget {
  const ReusableItemRow({super.key, required this.index, required this.info});
  final int index;
  final Map info;
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
              // item code
              ReusableShowInfoCard(
                text: '${info['item_main_code'] ?? ''}',
                width: MediaQuery.of(context).size.width * 0.14,
              ),
              ReusableShowInfoCard(
                text: info['item_description'],
                width: MediaQuery.of(context).size.width * 0.28,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.06,
                child: ReusableShowInfoCard(
                  text: info['item_quantity'],
                  width: MediaQuery.of(context).size.width * 0.06,
                ),
              ),
              ReusableShowInfoCard(
                text: numberWithComma(info['item_unit_price']),
                // widget.info['item_unit_price'],
                width: MediaQuery.of(context).size.width * 0.06,
              ),
              ReusableShowInfoCard(
                text: info['item_discount'],
                width: MediaQuery.of(context).size.width * 0.06,
              ),
              ReusableShowInfoCard(
                text: numberWithComma(info['item_total']),
                // widget.info['item_total'],
                width: MediaQuery.of(context).size.width * 0.07,
              ),
            ],
          ),
        );
      },
    );
  }
}

//title 1
class ReusableTitleRow extends StatelessWidget {
  const ReusableTitleRow({super.key, required this.index, required this.info});
  final int index;
  final Map info;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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

          gapW32,
          ReusableShowInfoCard(
            text: info['title'] ?? '',
            width: MediaQuery.of(context).size.width * 0.68,
          ),
        ],
      ),
    );
  }
}

//note 5
class ReusableNoteRow extends StatelessWidget {
  const ReusableNoteRow({super.key, required this.index, required this.info});
  final int index;
  final Map info;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
          gapW32,

          ReusableShowInfoCard(
            text: info['note'] ?? '',
            width: MediaQuery.of(context).size.width * 0.68,
          ),
        ],
      ),
    );
  }
}

//image 4
class ReusableImageRow extends StatelessWidget {
  const ReusableImageRow({super.key, required this.index, required this.info});
  final int index;
  final Map info;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 5),
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
          gapW32,
          Center(
            child:
                info['image'] != ''
                    ? Image.network(
                      "$baseImage${info['image']}",
                      loadingBuilder: (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                      errorBuilder: (
                        BuildContext context,
                        Object exception,
                        StackTrace? stackTrace,
                      ) {
                        return Text('Could not load image');
                      },
                    )
                    : Text('Image URL not available'),
          ),
        ],
      ),
    );
  }
}
