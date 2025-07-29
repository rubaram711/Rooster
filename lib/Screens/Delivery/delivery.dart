import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rooster_app/Backend/DeliveryBackend/store_delivery.dart';
import 'package:rooster_app/Controllers/delivery_controller.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/Screens/Combo/combo.dart';
import 'package:rooster_app/Screens/Delivery/print_delivery_data.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/create_product_dialog.dart';
import 'package:rooster_app/Widgets/dialog_title.dart';
import 'package:rooster_app/Widgets/loading.dart';
import 'package:rooster_app/const/functions.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Screens/Quotations/create_client_dialog.dart';
import 'package:rooster_app/Widgets/reusable_drop_down_menu.dart';
import 'package:rooster_app/Widgets/table_item.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../Widgets/TransferWidgets/under_item_btn.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_more.dart';
import '../../Widgets/table_title.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class CreateDelivery extends StatefulWidget {
  const CreateDelivery({super.key});

  @override
  State<CreateDelivery> createState() => _CreateDeliveryState();
}

class _CreateDeliveryState extends State<CreateDelivery> {
  String selectedSalesPerson = '';
  int selectedSalesPersonId = 0;

  TextEditingController refController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController expectedDateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController clientNameController = TextEditingController();
  TextEditingController driverNameController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  TextEditingController vatExemptController = TextEditingController();

  int currentStep = 0;
  int selectedTabIndex = 0;
  List tabsList = ['order_lines', 'links'];
  List<String> termsList = [];
  String selectedTab = 'order_lines'.tr;

  double listViewLength = Sizes.deviceHeight * 0.08;
  double increment = Sizes.deviceHeight * 0.08;

  bool isActiveVatChecked = false;
  bool isActiveDeliveredChecked = false;
  // final DeliveryController deliveryController = Get.find();
  final HomeController homeController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();

  int progressVar = 0;
  String selectedCustomerIds = '';
  String selectedDriverIds = '';

  setVars() async {
    setState(() {
      currentStep = 0;
      selectedTabIndex = 0;
      progressVar = 0;
      selectedCustomerIds = '';
    });
  }

  checkVatExempt() async {
    var companySubjectToVat = await getCompanySubjectToVatFromPref();
    if (companySubjectToVat == '1') {
      vatExemptController.clear();
      deliveryController.setIsVatExempted(false, false, false);
      deliveryController.setIsVatExemptCheckBoxShouldAppear(true);
    } else {
      deliveryController.setIsVatExemptCheckBoxShouldAppear(false);
      deliveryController.setIsVatExempted(false, false, true);
      deliveryController.setIsVatExemptChecked(true);
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
    deliveryController.setLogo(imageBytes);
  }

  @override
  void initState() {
    generatePdfFromImageUrl();
    checkVatExempt();
    deliveryController.isVatExemptChecked = false;
    deliveryController.itemsMultiPartList = [];
    deliveryController.salesPersonListNames = [];
    deliveryController.salesPersonListId = [];
    deliveryController.isBeforeVatPrices = true;
    // deliveryController.getAllUsersSalesPersonFromBack();
    // deliveryController.getAllTaxationGroupsFromBack();
    setVars();
    deliveryController.getFieldsForCreateDeliveryFromBack();
    // getCurrency();
    deliveryController.resetDeliveries();
    deliveryController.listViewLengthInDelivery = 50;
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    expectedDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());
    TimeOfDay now = TimeOfDay.now();
    String formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    timeController.text = formattedTime;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryController>(
      builder: (deliveryCont) {
        var keysList = deliveryCont.orderLinesDeliveryList.keys.toList();
        return deliveryCont.isDeliveredInfoFetched
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
                      children: [PageTitle(text: 'delivery'.tr)],
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
                                setState(() {
                                  progressVar = 1;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      List itemsInfoPrint = [];
                                      var itemTotal = 0.0;
                                      for (var item
                                          in deliveryCont
                                              .rowsInListViewInDelivery
                                              .values) {
                                        if ('${item['line_type_id']}' == '2') {
                                          var qty = item['item_quantity'];
                                          var map =
                                              deliveryCont
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
                                          itemTotal += double.parse(
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

                                          var ind = deliveryCont.combosIdsList
                                              .indexOf(
                                                item['combo'].toString(),
                                              );
                                          var itemName =
                                              deliveryCont.combosNamesList[ind];
                                          var itemPrice = double.parse(
                                            '${item['item_unit_price'] ?? 0.0}',
                                          );
                                          var itemDescription =
                                              item['item_description'];

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

                                      return PrintDeliveryData(
                                        isInDelivery: true,
                                        deliveryNumber:
                                            deliveryCont.deliveryNumber,
                                        creationDate: dateController.text,
                                        expectedDate:
                                            expectedDateController.text,
                                        receivedUser: '',
                                        senderUser: homeController.userName,

                                        clientPhoneNumber:
                                            deliveryCont
                                                .phoneNumber[selectedCustomerIds] ??
                                            '---',
                                        clientName: clientNameController.text,
                                        total: itemTotal.toString(),
                                        itemsInfoPrint: itemsInfoPrint,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),

                            UnderTitleBtn(
                              text: 'print'.tr,
                              onTap: () async {
                                // _saveContent();
                                setState(() {
                                  progressVar = 0;
                                });
                                deliveryCont.setStatus("sent");
                                // print("press--Print--------------------------");

                                var oldKeys =
                                    deliveryCont.rowsInListViewInDelivery.keys
                                        .toList()
                                      ..sort();
                                for (int i = 0; i < oldKeys.length; i++) {
                                  deliveryCont.newRowMap[i + 1] =
                                      deliveryCont
                                          .rowsInListViewInDelivery[oldKeys[i]]!;
                                }
                                // print(
                                //   "----------------DateTime-----------------",
                                // );
                                String dateString =
                                    expectedDateController
                                        .text; // e.g., "2025-06-29"
                                // Parse the time
                                String timeString =
                                    timeController.text; // e.g., "14:30"

                                // Combine date and time strings into a single string
                                String dateTimeString =
                                    '$dateString $timeString';

                                // Parse into DateTime object
                                DateTime dateTime = DateFormat(
                                  'yyyy-MM-dd HH:mm',
                                ).parse(dateTimeString);

                                // Format into desired output
                                String formattedDateTime = DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(dateTime);

                                var res = await storeDelivery(
                                  refController.text,
                                  selectedCustomerIds,
                                  deliveryCont.selectedDriverId.toString(),
                                  dateController.text,
                                  formattedDateTime, //timestamp

                                  '',
                                  '',
                                  deliveryCont.newRowMap,
                                );
                                if (res['success'] == true) {
                                  CommonWidgets.snackBar(
                                    'Success',
                                    res['message'],
                                  );
                                  homeController.selectedTab.value =
                                      'deliveries_summary';
                                } else {
                                  CommonWidgets.snackBar(
                                    'error',
                                    res['message'],
                                  );
                                }
                              },
                            ),
                            UnderTitleBtn(
                              text: 'send'.tr,
                              onTap: () async {
                                setState(() {
                                  progressVar = 1;
                                });
                                deliveryCont.setStatus("sent");

                                var oldKeys =
                                    deliveryCont.rowsInListViewInDelivery.keys
                                        .toList()
                                      ..sort();
                                for (int i = 0; i < oldKeys.length; i++) {
                                  deliveryCont.newRowMap[i + 1] =
                                      deliveryCont
                                          .rowsInListViewInDelivery[oldKeys[i]]!;
                                }
                                // print(
                                //   "----------------DateTime-----------------",
                                // );
                                String dateString =
                                    expectedDateController
                                        .text; // e.g., "2025-06-29"
                                // Parse the time
                                String timeString =
                                    timeController.text; // e.g., "14:30"

                                // Combine date and time strings into a single string
                                String dateTimeString =
                                    '$dateString $timeString';

                                // Parse into DateTime object
                                DateTime dateTime = DateFormat(
                                  'yyyy-MM-dd HH:mm',
                                ).parse(dateTimeString);

                                // Format into desired output
                                String formattedDateTime = DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(dateTime);

                                var res = await storeDelivery(
                                  refController.text,
                                  selectedCustomerIds,
                                  deliveryCont.selectedDriverId.toString(),
                                  dateController.text,
                                  formattedDateTime, //timestamp

                                  '',
                                  '',
                                  deliveryCont.newRowMap,
                                );
                                if (res['success'] == true) {
                                  CommonWidgets.snackBar(
                                    'Success',
                                    res['message'],
                                  );
                                  homeController.selectedTab.value =
                                      'deliveries_summary';
                                } else {
                                  CommonWidgets.snackBar(
                                    'error',
                                    res['message'],
                                  );
                                }
                              },
                            ),
                            UnderTitleBtn(
                              text: 'cancel'.tr,
                              onTap: () async {
                                setState(() {
                                  progressVar = 0;
                                });
                                deliveryCont.setStatus("cancelled");

                                var oldKeys =
                                    deliveryCont.rowsInListViewInDelivery.keys
                                        .toList()
                                      ..sort();
                                for (int i = 0; i < oldKeys.length; i++) {
                                  deliveryCont.newRowMap[i + 1] =
                                      deliveryCont
                                          .rowsInListViewInDelivery[oldKeys[i]]!;
                                }
                                // print(
                                //   "----------------DateTime-----------------",
                                // );
                                String dateString =
                                    expectedDateController
                                        .text; // e.g., "2025-06-29"
                                // Parse the time
                                String timeString =
                                    timeController.text; // e.g., "14:30"

                                // Combine date and time strings into a single string
                                String dateTimeString =
                                    '$dateString $timeString';

                                // Parse into DateTime object
                                DateTime dateTime = DateFormat(
                                  'yyyy-MM-dd HH:mm',
                                ).parse(dateTimeString);

                                // Format into desired output
                                String formattedDateTime = DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(dateTime);

                                var res = await storeDelivery(
                                  refController.text,
                                  selectedCustomerIds,
                                  deliveryCont.selectedDriverId.toString(),
                                  dateController.text,
                                  formattedDateTime, //timestamp

                                  '',
                                  '',
                                  deliveryCont.newRowMap,
                                );
                                if (res['success'] == true) {
                                  CommonWidgets.snackBar(
                                    'Success',
                                    res['message'],
                                  );
                                  homeController.selectedTab.value =
                                      'deliveries_summary';
                                } else {
                                  CommonWidgets.snackBar(
                                    'error',
                                    res['message'],
                                  );
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
                              text: 'pending'.tr,
                            ),
                            ReusableTimeLineTile(
                              id: 1,
                              progressVar: progressVar,
                              isFirst: false,
                              isLast: false,
                              isPast: true,
                              text: 'delivered'.tr,
                            ),
                            // ReusableTimeLineTile(
                            //   id: 2,
                            //   progressVar: progressVar,
                            //   isFirst: false,
                            //   isLast: false,
                            //   isPast: true,
                            //   text: 'proforma'.tr,
                            // ),
                            ReusableTimeLineTile(
                              id: 3,
                              progressVar: progressVar,
                              isFirst: false,
                              isLast: true,
                              isPast: false,
                              text: 'invoiced'.tr,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // ),
                    // ),
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
                                deliveryCont.deliveryNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: TypographyColor.titleTable,
                                ),
                              ),
                              gapW10,
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.13,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('date'.tr),
                                    DialogDateTextField(
                                      textEditingController: dateController,
                                      text: '',
                                      textFieldWidth:
                                          MediaQuery.of(context).size.width *
                                          0.10,
                                      // MediaQuery.of(context).size.width * 0.25,
                                      validationFunc: (val) {},
                                      onChangedFunc: (val) {
                                        dateController.text = val;
                                      },
                                      onDateSelected: (value) {
                                        dateController.text = value;
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
                              DialogTextField(
                                textEditingController: refController,
                                text: '${'ref'.tr}:',
                                hint: 'manual_reference'.tr,
                                rowWidth:
                                    MediaQuery.of(context).size.width * 0.14,
                                textFieldWidth:
                                    MediaQuery.of(context).size.width * 0.12,
                                validationFunc: (val) {},
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.18,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('expected_delivery'.tr),
                                    DialogDateTextField(
                                      textEditingController:
                                          expectedDateController,
                                      text: '',
                                      textFieldWidth:
                                          MediaQuery.of(context).size.width *
                                          0.10,
                                      // MediaQuery.of(context).size.width * 0.25,
                                      validationFunc: (val) {},
                                      onChangedFunc: (val) {
                                        expectedDateController.text = val;
                                      },
                                      onDateSelected: (value) {
                                        expectedDateController.text = value;
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
                              //Time
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.07,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(''),
                                    DialogTimeTextField(
                                      textEditingController: timeController,
                                      text: '',
                                      textFieldWidth:
                                          MediaQuery.of(context).size.width *
                                          0.07,
                                      // MediaQuery.of(context).size.width * 0.25,
                                      validationFunc: (val) {},
                                      onChangedFunc: (val) {
                                        dateController.text = val;
                                      },
                                      onTimeSelected: (value) {
                                        timeController.text = value;
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
                                width: MediaQuery.of(context).size.width * 0.03,
                              ),
                            ],
                          ),
                          gapH16,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //code search
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.57,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ReusableDropDownMenusWithSearchCode(
                                      list: deliveryCont.customersMultiPartList,
                                      text: 'code'.tr,
                                      hint: '${'search'.tr}...',
                                      controller: codeController,
                                      onSelected: (String? value) {
                                        codeController.text = value!;
                                        int index = deliveryCont
                                            .customerNumberList
                                            .indexOf(value);
                                        clientNameController.text =
                                            deliveryCont
                                                .customerNameList[index];
                                        setState(() {
                                          selectedCustomerIds =
                                              deliveryCont
                                                  .customerIdsList[deliveryCont
                                                  .customerNumberList
                                                  .indexOf(value)];
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
                                      list: deliveryCont.customerNameList,
                                      text: '',
                                      hint: '${'search'.tr}...',
                                      controller: clientNameController,
                                      onSelected: (String? val) {
                                        setState(() {
                                          var index = deliveryCont
                                              .customerNameList
                                              .indexOf(val!);
                                          codeController.text =
                                              deliveryCont
                                                  .customerNumberList[index];
                                          selectedCustomerIds =
                                              deliveryCont
                                                  .customerIdsList[index];
                                          if (deliveryCont
                                              .customersPricesListsIds[index]
                                              .isNotEmpty) {
                                            deliveryCont.setSelectedPriceListId(
                                              '${deliveryCont.customersPricesListsIds[index]}',
                                            );

                                            setState(() {
                                              deliveryCont
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
                                          0.27,
                                      textFieldWidth:
                                          MediaQuery.of(context).size.width *
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
                            ],
                          ),

                          gapH16,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.49,
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
                                          " ${deliveryCont.street[selectedCustomerIds] ?? ''} ",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          deliveryCont.floorAndBuilding[selectedCustomerIds] ==
                                                      '' ||
                                                  deliveryCont
                                                          .floorAndBuilding[selectedCustomerIds] ==
                                                      null
                                              ? ''
                                              : ',',
                                        ),
                                        Text(
                                          " ${deliveryCont.floorAndBuilding[selectedCustomerIds] ?? ''}",
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
                                          "${deliveryCont.phoneNumber[selectedCustomerIds] ?? ''}",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.18,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Driver'.tr),
                                        DropdownMenu<String>(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.15,
                                          // requestFocusOnTap: false,
                                          enableSearch: true,
                                          controller: driverNameController,
                                          hintText: 'Driver'.tr,
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
                                              deliveryCont.driverNameList.map<
                                                DropdownMenuEntry<String>
                                              >((String option) {
                                                return DropdownMenuEntry<
                                                  String
                                                >(value: option, label: option);
                                              }).toList(),
                                          enableFilter: true,
                                          onSelected: (String? val) {
                                            var index = deliveryCont
                                                .driverNameList
                                                .indexOf(val!);
                                            deliveryCont.setSelectedDriverId(
                                              '${deliveryCont.driverIdsList[index]}',
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.03,
                              ),
                            ],
                          ),
                          gapH16,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.50,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //vat
                                    deliveryCont.isVatExemptCheckBoxShouldAppear
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
                              // Total Qty
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.22,
                                child: Row(
                                  children: [
                                    Text(
                                      'total_qty:'.tr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    gapW10,
                                    Text(
                                      "",
                                      style: const TextStyle(fontSize: 12),
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
                                    text: 'item'.tr,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.10,
                                  ),
                                  TableTitle(
                                    text: 'description'.tr,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.32,
                                  ),
                                  TableTitle(
                                    text: 'quantity'.tr,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.07,
                                  ),
                                  TableTitle(
                                    text: 'warehouse'.tr,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.12,
                                  ),

                                  TableTitle(
                                    text: 'more_options'.tr,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.12,
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
                                        deliveryCont.listViewLengthInDelivery,
                                    child: ListView(
                                      children:
                                          keysList.map((key) {
                                            return Dismissible(
                                              key: Key(
                                                key,
                                              ), // Ensure each widget has a unique key
                                              onDismissed:
                                                  (direction) => deliveryCont
                                                      .removeFromOrderLinesInDeliveryList(
                                                        key.toString(),
                                                      ),
                                              child:
                                                  deliveryCont
                                                      .orderLinesDeliveryList[key] ??
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

                            gapH70,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ReusableButtonWithColor(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height: 45,
                                  onTapFunction: () async {

                                    var oldKeys =
                                        deliveryController
                                            .rowsInListViewInDelivery
                                            .keys
                                            .toList()
                                          ..sort();
                                    for (int i = 0; i < oldKeys.length; i++) {
                                      deliveryController.newRowMap[i + 1] =
                                          deliveryController
                                              .rowsInListViewInDelivery[oldKeys[i]]!;
                                    }
                                    // print(
                                    //   "----------------DateTime-----------------",
                                    // );
                                    String dateString =
                                        expectedDateController
                                            .text; // e.g., "2025-06-29"
                                    // Parse the time
                                    String timeString =
                                        timeController.text; // e.g., "14:30"

                                    // Combine date and time strings into a single string
                                    String dateTimeString =
                                        '$dateString $timeString';

                                    // Parse into DateTime object
                                    DateTime dateTime = DateFormat(
                                      'yyyy-MM-dd HH:mm',
                                    ).parse(dateTimeString);

                                    // Format into desired output
                                    String formattedDateTime = DateFormat(
                                      'yyyy-MM-dd HH:mm:ss',
                                    ).format(dateTime);
                                    bool hasType1WithEmptyTitle =
                                        deliveryController.newRowMap.values.any(
                                          (map) {
                                            return map['line_type_id'] == '1' &&
                                                (map['title']?.isEmpty ?? true);
                                          },
                                        );
                                    bool hasType2WithEmptyId =
                                        deliveryController.newRowMap.values.any(
                                          (map) {
                                            return map['line_type_id'] == '2' &&
                                                (map['item_id']?.isEmpty ??
                                                    true);
                                          },
                                        );
                                    bool hasType3WithEmptyId =
                                        deliveryController.newRowMap.values.any(
                                          (map) {
                                            return map['line_type_id'] == '3' &&
                                                (map['combo']?.isEmpty ?? true);
                                          },
                                        );
                                    bool hasType4WithEmptyImage =
                                        deliveryController.newRowMap.values.any(
                                          (map) {
                                            return map['line_type_id'] == '4' &&
                                                (map['image'] == Uint8List(0) ||
                                                    map['image']?.isEmpty);
                                          },
                                        );
                                    bool hasType5WithEmptyNote =
                                        deliveryController.newRowMap.values.any(
                                          (map) {
                                            return map['line_type_id'] == '5' &&
                                                (map['note']?.isEmpty ?? true);
                                          },
                                        );
                                    if (deliveryController.newRowMap.isEmpty) {
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
                                      var res = await storeDelivery(
                                        refController.text,
                                        selectedCustomerIds,
                                        deliveryCont.selectedDriverId
                                            .toString(),
                                        dateController.text,
                                        formattedDateTime, //timestamp

                                        '',
                                        '',
                                        deliveryController.newRowMap,
                                      );
                                      if (res['success'] == true) {
                                        CommonWidgets.snackBar(
                                          'Success',
                                          res['message'],
                                        );
                                        homeController.selectedTab.value =
                                            'deliveries_summary';
                                      } else {
                                        CommonWidgets.snackBar(
                                          'error',
                                          res['message'],
                                        );
                                      }
                                    }
                                  },
                                  btnText: 'submit'.tr,
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
                            children: [],
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
  int deliveryCounter = 0;
  addNewTitle() {
    setState(() {
      deliveryCounter += 1;
    });
    deliveryController.incrementListViewLengthInDelivery(
      deliveryController.increment,
    );
    deliveryController.addTorowsInListViewInDelivery(deliveryCounter, {
      'line_type_id': '1',
      'item_id': '',
      'itemName': '',
      'item_main_code': '',
      'item_discount': '0',
      'item_description': '',
      'item_quantity': '0',
      'item_warehouseId': '0',
      'combo_warehouseId': '0',
      'item_unit_price': '0',
      'item_total': '0',
      'title': '',
      'note': '',
      'combo': '',
    });
    Widget p = ReusableTitleRow(index: deliveryCounter);

    deliveryController.addToOrderLinesInDeliveryList('$deliveryCounter', p);
  }

  DeliveryController deliveryController = Get.find();
  addNewItem() {
    setState(() {
      deliveryCounter += 1;
    });
    deliveryController.incrementListViewLengthInDelivery(
      deliveryController.increment,
    );

    deliveryController.addTorowsInListViewInDelivery(deliveryCounter, {
      'line_type_id': '2',
      'item_id': '',
      'itemName': '',
      'item_main_code': '',
      'item_discount': '0',
      'item_description': '',
      'item_warehouseId': '',
      'combo_warehouseId': '',
      'item_quantity': '0',
      'item_unit_price': '0',
      'item_total': '0',
      'title': '',
      'note': '',
      'combo': '',
    });
    deliveryController.addToUnitPriceControllers(deliveryCounter);
    Widget p = ReusableItemRow(index: deliveryCounter);

    deliveryController.addToOrderLinesInDeliveryList('$deliveryCounter', p);
  }

  addNewCombo() {
    setState(() {
      deliveryCounter += 1;
    });
    deliveryController.incrementListViewLengthInDelivery(
      deliveryController.increment,
    );

    deliveryController.addTorowsInListViewInDelivery(deliveryCounter, {
      'line_type_id': '3',
      'item_id': '',
      'itemName': '',
      'item_main_code': '',
      'item_discount': '0',
      'item_description': '',
      'item_warehouseId': '',
      'combo_warehouseId': '',
      'item_quantity': '0',
      'item_unit_price': '0',
      'item_total': '0',
      'title': '',
      'note': '',
      'combo': '',
    });
    deliveryController.addToCombosPricesControllers(deliveryCounter);

    Widget p = ReusableComboRow(index: deliveryCounter);
    deliveryController.addToOrderLinesInDeliveryList('$deliveryCounter', p);
  }

  addNewImage() {
    setState(() {
      deliveryCounter += 1;
    });
    deliveryController.incrementListViewLengthInDelivery(
      deliveryController.increment + 50,
    );

    deliveryController.addTorowsInListViewInDelivery(deliveryCounter, {
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
    });
    Widget p = ReusableImageRow(index: deliveryCounter);

    deliveryController.addToOrderLinesInDeliveryList('$deliveryCounter', p);
  }

  addNewNote() {
    setState(() {
      deliveryCounter += 1;
    });
    deliveryController.incrementListViewLengthInDelivery(
      deliveryController.increment,
    );

    deliveryController.addTorowsInListViewInDelivery(deliveryCounter, {
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
    });

    Widget p = ReusableNoteRow(index: deliveryCounter);

    deliveryController.addToOrderLinesInDeliveryList('$deliveryCounter', p);
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
  String discount = '0', result = '0', quantity = '0', price = '';

  String qty = '0';
  String warehouse = '';
  final ProductController productController = Get.find();

  TextEditingController itemCodeController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController warehouseController = TextEditingController();

  final DeliveryController deliveryController = Get.find();
  // final ExchangeRatesController exchangeRatesController = Get.find();
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
    itemCodeController.text =
        deliveryController.rowsInListViewInDelivery[widget
            .index]['item_main_code'];
    qtyController.text =
        deliveryController.rowsInListViewInDelivery[widget
            .index]['item_quantity'];

    descriptionController.text =
        deliveryController.rowsInListViewInDelivery[widget
            .index]['item_description'];

    itemCodeController.text =
        deliveryController.rowsInListViewInDelivery[widget
            .index]['item_main_code'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryController>(
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
                  hint: 'Item'.tr,
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
                      price = cont.itemUnitPrice[selectedItemId].toString();
                    });
                    qtyController.text = '1';
                    quantity = '1';
                    cont.setItemIdInDelivery(widget.index, selectedItemId);
                    cont.setItemNameInDelivery(
                      widget.index,
                      itemName,
                    ); // set only first element as name
                    cont.setMainCodeInDelivery(widget.index, mainCode);
                    cont.setEnteredUnitPriceInDelivery(widget.index, price);
                    cont.setEnteredQtyInDelivery(widget.index, quantity);
                    cont.setTypeInDelivery(widget.index, '2');
                    cont.setMainDescriptionInDelivery(
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
                  rowWidth: MediaQuery.of(context).size.width * 0.12,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.12,
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
                      cont.setMainDescriptionInDelivery(
                        widget.index,
                        mainDescriptionVar,
                      );
                    },
                  ),
                ),

                //quantity
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,

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
                      });

                      _formKey.currentState!.validate();

                      cont.setEnteredQtyInDelivery(widget.index, val);
                    },
                  ),
                ),
                //warehouse
                DropdownMenu<String>(
                  width: MediaQuery.of(context).size.width * 0.16,
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
                    cont.setItemWareHouseInDelivery(widget.index, val);
                  },
                ),
                // ReusableDropDownMenusWithSearch(
                //   list:
                //       cont.warehousesMultiPartList, // Assuming multiList is List<List<String>>
                //   text: ''.tr,
                //   hint: ''.tr,

                //   onSelected: (String? value) {
                //     warehouseController.text = value!;
                //     cont.setItemWareHouseInDelivery(widget.index, value);
                //   },
                //   controller: warehouseController,
                //   validationFunc: (value) {},
                //   rowWidth: MediaQuery.of(context).size.width * 0.16,
                //   textFieldWidth: MediaQuery.of(context).size.width * 0.16,
                //   clickableOptionText: 'create_virtual_item'.tr,
                //   isThereClickableOption: true,
                //   onTappedClickableOption: () {},
                //   columnWidths: [100.0, 200.0, 550.0, 100.0],
                // ), // warehouse
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
                              deliveryController
                                  .decrementListViewLengthInDelivery(
                                    deliveryController.increment,
                                  );
                              deliveryController
                                  .removeFromrowsInListViewInDelivery(
                                    widget.index,
                                  );
                              deliveryController
                                  .removeFromOrderLinesInDeliveryList(
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
                              cont.totalDelivery = "0.0";
                            });
                            if (cont.rowsInListViewInDelivery != {}) {
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
  final DeliveryController deliveryController = Get.find();
  String titleValue = '0';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    titleController.text =
        deliveryController.rowsInListViewInDelivery[widget.index]['title'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryController>(
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
                      cont.setTypeInDelivery(widget.index, '1');
                      cont.setTitleInDelivery(widget.index, val);
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
                              deliveryController
                                  .decrementListViewLengthInDelivery(
                                    deliveryController.increment,
                                  );
                              deliveryController
                                  .removeFromrowsInListViewInDelivery(
                                    widget.index,
                                  );
                              deliveryController
                                  .removeFromOrderLinesInDeliveryList(
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
  final DeliveryController deliveryController = Get.find();
  String noteValue = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    noteController.text =
        deliveryController.rowsInListViewInDelivery[widget.index]['note'];
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
                  deliveryController.setTypeInDelivery(widget.index, '5');
                  deliveryController.setNoteInDelivery(widget.index, val);
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
                        //     // PopupMenuItem<String>(
                        //     //   value: '1',
                        //     //   onTap: () async {
                        //     //     showDialog<String>(
                        //     //         context: context,
                        //     //         builder: (BuildContext context) => AlertDialog(
                        //     //           backgroundColor: Colors.white,
                        //     //           shape: const RoundedRectangleBorder(
                        //     //             borderRadius:
                        //     //             BorderRadius.all(Radius.circular(9)),
                        //     //           ),
                        //     //           elevation: 0,
                        //     //           content: Column(
                        //     //             mainAxisAlignment: MainAxisAlignment.center,
                        //     //             children: [
                        //     //
                        //     //             ],
                        //     //           ),
                        //     //         ));
                        //     //   },
                        //     //   child: const Text('Show Quantity'),
                        //     // ),
                      ],
                    ),
                  ),
                  //delete
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          deliveryController.decrementListViewLengthInDelivery(
                            deliveryController.increment,
                          );
                          deliveryController.removeFromrowsInListViewInDelivery(
                            widget.index,
                          );
                          deliveryController.removeFromOrderLinesInDeliveryList(
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
  final DeliveryController salesOrderController = Get.find();
  late Uint8List imageFile;

  double listViewLength = Sizes.deviceHeight * 0.08;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    imageFile =
        salesOrderController.rowsInListViewInDelivery[widget.index]['image'];
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
            GetBuilder<DeliveryController>(
              builder: (cont) {
                return InkWell(
                  onTap: () async {
                    final image = await ImagePickerHelper.pickImage();
                    setState(() {
                      imageFile = image!;
                      cont.changeBoolVar(true);
                      cont.increaseImageSpace(30);
                    });
                    cont.setTypeInDelivery(widget.index, '4');
                    cont.setImageInDelivery(widget.index, imageFile);
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
                        // ],
                        // ),
                        // ));
                        // },
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
                              .decrementListViewLengthInDelivery(
                                salesOrderController.increment + 50,
                              );
                          salesOrderController
                              .removeFromrowsInListViewInDelivery(widget.index);
                          salesOrderController
                              .removeFromOrderLinesInDeliveryList(
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
  TextEditingController warehouseController = TextEditingController();

  final DeliveryController deliveryController = Get.find();
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
        deliveryController.rowsInListViewInDelivery[widget
            .index]['item_main_code'];
    qtyController.text =
        deliveryController.rowsInListViewInDelivery[widget
            .index]['item_quantity'];
    discountController.text =
        deliveryController.rowsInListViewInDelivery[widget
            .index]['item_discount'];
    descriptionController.text =
        deliveryController.rowsInListViewInDelivery[widget
            .index]['item_description'];
    totalLine =
        deliveryController.rowsInListViewInDelivery[widget.index]['item_total'];
    comboCodeController.text =
        deliveryController.rowsInListViewInDelivery[widget
            .index]['item_main_code'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryController>(
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
                      cont.setEnteredQtyInDelivery(widget.index, quantity);
                      cont.setMainTotalInDelivery(widget.index, totalLine);
                      cont.getTotalItems();
                    });
                    cont.setEnteredUnitPriceInDelivery(
                      widget.index,
                      cont.combosPriceControllers[widget.index]!.text,
                    );
                    cont.setComboInDelivery(widget.index, selectedComboId);
                    cont.setItemNameInDelivery(
                      widget.index,
                      comboName,
                      // value.split(" | ")[0],
                    ); // set only first element as name
                    cont.setMainCodeInDelivery(widget.index, mainCode);
                    cont.setTypeInDelivery(widget.index, '3');
                    cont.setMainDescriptionInDelivery(
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
                  rowWidth: MediaQuery.of(context).size.width * 0.12,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.12,
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
                      cont.setMainDescriptionInDelivery(
                        widget.index,
                        descriptionVar,
                      );
                    },
                  ),
                ),

                //quantity
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,

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

                      cont.setEnteredQtyInDelivery(widget.index, val);
                      cont.setMainTotalInDelivery(widget.index, totalLine);
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
                  width: MediaQuery.of(context).size.width * 0.16,
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
                    cont.setComboWareHouseInDelivery(widget.index, val);
                  },
                ),
                // ReusableDropDownMenusWithSearch(
                //   list:
                //       cont.warehousesMultiPartList, // Assuming multiList is List<List<String>>
                //   text: ''.tr,
                //   hint: 'warehouse'.tr,

                //   onSelected: (String? value) {
                //     warehouseController.text = value!;
                //     cont.setComboWareHouseInDelivery(widget.index, value);
                //   },
                //   controller: warehouseController,
                //   validationFunc: (value) {},
                //   rowWidth: MediaQuery.of(context).size.width * 0.16,
                //   textFieldWidth: MediaQuery.of(context).size.width * 0.16,
                //   clickableOptionText: 'create_virtual_item'.tr,
                //   isThereClickableOption: true,
                //   onTappedClickableOption: () {},
                //   columnWidths: [100.0, 200.0, 550.0, 100.0],
                // ),

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
                              selectedComboId.isEmpty
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
                                                    ShowComboQuantitiesDialog(
                                                      selectedItemId:
                                                          selectedComboId,
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
                              deliveryController
                                  .decrementListViewLengthInDelivery(
                                    deliveryController.increment,
                                  );
                              deliveryController
                                  .removeFromrowsInListViewInDelivery(
                                    widget.index,
                                  );
                              deliveryController
                                  .removeFromOrderLinesInDeliveryList(
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
                              cont.totalDelivery = "0.0";
                            });
                            if (cont.rowsInListViewInDelivery != {}) {
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
    return GetBuilder<DeliveryController>(
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

class ShowComboQuantitiesDialog extends StatelessWidget {
  const ShowComboQuantitiesDialog({super.key, required this.selectedItemId});
  final String selectedItemId;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryController>(
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
                      text: 'Quantities of ${cont.combosNames[selectedItemId]}',
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
                    itemCount: 1,
                    // cont
                    // .warehousesComboInfo[selectedItemId]
                    // .length, // data from back
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Center(child: Text("No Data Was Found")),
                      );

                      // var info = cont.warehousesComboInfo[selectedItemId];
                      // return WarehouseAsRow(info: info[index], index: index);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
