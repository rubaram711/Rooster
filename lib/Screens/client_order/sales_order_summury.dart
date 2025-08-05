import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/sales_order_controller.dart';
import 'package:rooster_app/Controllers/task_controller.dart';
import 'package:rooster_app/Screens/client_order/print_sales_order.dart';
import '../../Controllers/home_controller.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../../const/functions.dart';
import '../../const/urls.dart';

import 'update_sales_order_dialog.dart';

class ClientOrderSummary extends StatefulWidget {
  const ClientOrderSummary({super.key});

  @override
  State<ClientOrderSummary> createState() => _ClientOrderState();
}

class _ClientOrderState extends State<ClientOrderSummary> {
  final TextEditingController filterController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final ExchangeRatesController exchangeRatesController = Get.find();

  double listViewLength = 100;
  String selectedNumberOfRows = '10';
  int selectedNumberOfRowsAsInt = 10;
  int start = 1;
  bool isArrowBackClicked = false;
  bool isArrowForwardClicked = false;
  final HomeController homeController = Get.find();
  final SalesOrderController salesOrderController = Get.find();
  bool isNumberOrderedUp = true;
  bool isCreationOrderedUp = true;
  bool isCustomerOrderedUp = true;
  bool isSalespersonOrderedUp = true;
  String searchValue = '';
  Timer? searchOnStoppedTyping;
  bool isSalesOrderFetched = false;
  onChangeHandler(value) {
    const duration = Duration(
      milliseconds: 800,
    ); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel()); // clear timer
    }
    setState(
      () => searchOnStoppedTyping = Timer(duration, () => search(value)),
    );
  }

  search(value) async {
    setState(() {
      searchValue = value;
    });
    await salesOrderController.getAllSalesOrderFromBackWithoutExcept();
  }

  TaskController taskController = Get.find();
  int selectedTabIndex = 0;
  List tabsList = ['all_sales_orders'];
  String searchValueInTasks = '';
  Timer? searchOnStoppedTypingInTasks;

  _onChangeTaskSearchHandler(value) {
    const duration = Duration(
      milliseconds: 800,
    ); // set the duration that you want call search() after that.
    if (searchOnStoppedTypingInTasks != null) {
      setState(() => searchOnStoppedTypingInTasks!.cancel()); // clear timer
    }
    setState(
      () =>
          searchOnStoppedTypingInTasks = Timer(
            duration,
            () => searchOnTask(value),
          ),
    );
  }

  searchOnTask(value) async {
    setState(() {
      searchValueInTasks = value;
    });
    await taskController.getAllTasksFromBack(value);
  }

  _salesOrderSearchHandler(value) {
    const duration = Duration(
      milliseconds: 800,
    ); // set the duration that you want call search() after that.
    if (searchOnStoppedTypingInTasks != null) {
      setState(() => searchOnStoppedTypingInTasks!.cancel()); // clear timer
    }
    setState(
      () =>
          searchOnStoppedTypingInTasks = Timer(
            duration,
            () => searchOnSalesOrder(value),
          ),
    );
  }

  searchOnSalesOrder(value) async {
    salesOrderController.setSearchInSalesOrdersController(value);
    await salesOrderController.getAllSalesOrderFromBackWithoutExcept();
  }

  Future<void> generatePdfFromImageUrl() async {
    String companyLogo = await getCompanyLogoFromPref();

    // 1. Download image
    final response = await http.get(Uri.parse(companyLogo));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    final Uint8List imageBytes = response.bodyBytes;
    // String companyLogo = await getCompanyLogoFromPref();
    // final Uint8List logoBytes = await fetchImage(
    //   companyLogo,
    // );
    salesOrderController.setLogo(imageBytes);
  }

  @override
  void initState() {
    generatePdfFromImageUrl();
    salesOrderController.itemsMultiPartList = [];
    salesOrderController.salesPersonListNames = [];
    salesOrderController.salesPersonListId = [];
    exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();
    salesOrderController.getAllUsersSalesPersonFromBack();
    salesOrderController.getFieldsForCreateSalesOrderFromBack();
    salesOrderController.searchInSalesOrdersController.text = '';
    listViewLength =
        Sizes.deviceHeight *
        (0.09 * salesOrderController.salesOrderListCC.length);
    salesOrderController.getAllSalesOrderFromBackWithoutExcept();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesOrderController>(
      builder: (cont) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageTitle(text: 'sales_order'.tr),
                    ReusableButtonWithColor(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: 45,
                      onTapFunction: () {
                        homeController.selectedTab.value = 'new_sales_order';
                      },
                      btnText: 'create_new_sales_order'.tr,
                    ),
                  ],
                ),
                gapH24,
                SizedBox(
                  // width: MediaQuery.of(context).size.width * 0.59,
                  child: ReusableSearchTextField(
                    hint: '${"search".tr}...',
                    textEditingController: cont.searchInSalesOrdersController,
                    onChangedFunc: (value) {
                      if (selectedTabIndex == 1) {
                        _onChangeTaskSearchHandler(value);
                      } else {
                        _salesOrderSearchHandler(value);
                      }
                    },
                    validationFunc: () {},
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 0.0,
                      direction: Axis.horizontal,
                      children:
                          tabsList
                              .map(
                                (element) => ReusableBuildTabChipItem(
                                  index: tabsList.indexOf(element),
                                  function: () {
                                    setState(() {
                                      selectedTabIndex = tabsList.indexOf(
                                        element,
                                      );
                                    });
                                  },
                                  isClicked:
                                      selectedTabIndex ==
                                      tabsList.indexOf(element),
                                  name: element,
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      //   padding:
                      //       const EdgeInsets.symmetric(vertical: 15),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
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
                          tableTitleWithOrderArrow(
                            'number'.tr,
                            MediaQuery.of(context).size.width * 0.09,
                            () {
                              setState(() {
                                isNumberOrderedUp = !isNumberOrderedUp;
                                isNumberOrderedUp
                                    ? cont.salesOrderListCC.sort(
                                      (a, b) => a['salesOrderNumber'].compareTo(
                                        b['salesOrderNumber'],
                                      ),
                                    )
                                    : cont.salesOrderListCC.sort(
                                      (a, b) => b['salesOrderNumber'].compareTo(
                                        a['salesOrderNumber'],
                                      ),
                                    );
                              });
                            },
                          ),
                          tableTitleWithOrderArrow(
                            'creation'.tr,
                            MediaQuery.of(context).size.width * 0.09,
                            () {
                              setState(() {
                                isCreationOrderedUp = !isCreationOrderedUp;
                                isCreationOrderedUp
                                    ? cont.salesOrderListCC.sort(
                                      (a, b) => a['createdAtDate'].compareTo(
                                        b['createdAtDate'],
                                      ),
                                    )
                                    : cont.salesOrderListCC.sort(
                                      (a, b) => b['createdAtDate'].compareTo(
                                        a['createdAtDate'],
                                      ),
                                    );
                              });
                            },
                          ),
                          tableTitleWithOrderArrow(
                            'customer'.tr,
                            MediaQuery.of(context).size.width * 0.09,
                            () {
                              setState(() {
                                isCustomerOrderedUp = !isCustomerOrderedUp;
                                isCustomerOrderedUp
                                    ? cont.salesOrderListCC.sort(
                                      (a, b) => '${a['client']['name']}'
                                          .compareTo('${b['client']['name']}'),
                                    )
                                    : cont.salesOrderListCC.sort(
                                      (a, b) => '${b['client']['name']}'
                                          .compareTo('${a['client']['name']}'),
                                    );
                              });
                            },
                          ),
                          tableTitleWithOrderArrow(
                            'salesperson'.tr,
                            MediaQuery.of(context).size.width * 0.07,
                            () {
                              setState(() {
                                isSalespersonOrderedUp =
                                    !isSalespersonOrderedUp;
                                isSalespersonOrderedUp
                                    ? cont.salesOrderListCC.sort(
                                      (a, b) => a['salesperson'].compareTo(
                                        b['salesperson'],
                                      ),
                                    )
                                    : cont.salesOrderListCC.sort(
                                      (a, b) => b['salesperson'].compareTo(
                                        a['salesperson'],
                                      ),
                                    );
                              });
                            },
                          ),
                          // TableTitle(
                          //   text: 'task'.tr,
                          //   width:
                          //       MediaQuery.of(context).size.width *
                          //       0.07, //085
                          // ),
                          TableTitle(
                            text: 'total'.tr,
                            width:
                                MediaQuery.of(context).size.width * 0.06, //085
                          ),
                          TableTitle(
                            text: 'cur'.tr,
                            isCentered: false,
                            width:
                                MediaQuery.of(context).size.width * 0.04, //085
                          ),
                          TableTitle(
                            text: 'status'.tr,
                            width: 90, //085
                          ),
                          TableTitle(
                            text: 'more_options'.tr,
                            width: MediaQuery.of(context).size.width * 0.11,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03,
                          ),
                        ],
                      ),
                    ),
                    cont.isSalesOrderFetched
                        ? Container(
                          color: Colors.white,
                          // height: listViewLength,
                          height:
                              MediaQuery.of(context).size.height *
                              0.4, //listViewLength
                          child: ListView.builder(
                            itemCount: cont.salesOrderListCC.length,
                            itemBuilder:
                                (context, index) => Column(
                                  children: [
                                    SalesOrderAsRowInTable(
                                      info: cont.salesOrderListCC[index],
                                      index: index,
                                    ),
                                    const Divider(),
                                  ],
                                ),
                          ),
                        )
                        : const CircularProgressIndicator(),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Text(
                    //       '${'rows_per_page'.tr}:  ',
                    //       style: const TextStyle(
                    //           fontSize: 13, color: Colors.black54),
                    //     ),
                    //     Container(
                    //       width: 60,
                    //       height: 30,
                    //       decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(6),
                    //           border: Border.all(color: Colors.black, width: 2)),
                    //       child: Center(
                    //         child: DropdownButtonHideUnderline(
                    //           child: DropdownButton<String>(
                    //             borderRadius: BorderRadius.circular(0),
                    //             items: ['10', '20', '50', 'all'.tr]
                    //                 .map((String value) {
                    //               return DropdownMenuItem<String>(
                    //                 value: value,
                    //                 child: Text(
                    //                   value,
                    //                   style: const TextStyle(
                    //                       fontSize: 12, color: Colors.grey),
                    //                 ),
                    //               );
                    //             }).toList(),
                    //             value: selectedNumberOfRows,
                    //             onChanged: (val) {
                    //               setState(() {
                    //                 selectedNumberOfRows = val!;
                    //               if(val=='10'){
                    //                 listViewLength = cont.quotationsList.length < 10
                    //                     ?Sizes.deviceHeight * (0.09 * cont.quotationsList.length)
                    //                     : Sizes.deviceHeight * (0.09 * 10);
                    //                 selectedNumberOfRowsAsInt=cont.quotationsList.length < 10? cont.quotationsList.length:10;
                    //               }if(val=='20'){
                    //                 listViewLength = cont.quotationsList.length < 20
                    //                     ? Sizes.deviceHeight * (0.09 * cont.quotationsList.length)
                    //                     : Sizes.deviceHeight * (0.09 * 20);
                    //                 selectedNumberOfRowsAsInt=cont.quotationsList.length < 20? cont.quotationsList.length:20;
                    //               }if(val=='50'){
                    //                 listViewLength = cont.quotationsList.length < 50
                    //                     ? Sizes.deviceHeight * (0.09 * cont.quotationsList.length)
                    //                     : Sizes.deviceHeight * (0.09 * 50);
                    //                 selectedNumberOfRowsAsInt=cont.quotationsList.length < 50? cont.quotationsList.length:50;
                    //               }if(val=='all'.tr){
                    //                 listViewLength = Sizes.deviceHeight * (0.09 * cont.quotationsList.length);
                    //                 selectedNumberOfRowsAsInt= cont.quotationsList.length;
                    //               }
                    //               });
                    //             },
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     gapW16,
                    //     Text(selectedNumberOfRows=='all'.tr?'${'all'.tr} of ${quotationsList.length}':'$start-$selectedNumberOfRows of ${quotationsList.length}',
                    //         style: const TextStyle(
                    //             fontSize: 13, color: Colors.black54)),
                    //     gapW16,
                    //     InkWell(
                    //         onTap: () {
                    //           setState(() {
                    //             isArrowBackClicked = !isArrowBackClicked;
                    //             isArrowForwardClicked = false;
                    //           });
                    //         },
                    //         child: Row(
                    //           children: [
                    //             Icon(
                    //               Icons.skip_previous,
                    //               color: isArrowBackClicked
                    //                   ? Colors.black87
                    //                   : Colors.grey,
                    //             ),
                    //             Icon(
                    //               Icons.navigate_before,
                    //               color: isArrowBackClicked
                    //                   ? Colors.black87
                    //                   : Colors.grey,
                    //             ),
                    //           ],
                    //         )),
                    //     gapW10,
                    //     InkWell(
                    //         onTap: () {
                    //           setState(() {
                    //             isArrowForwardClicked = !isArrowForwardClicked;
                    //             isArrowBackClicked = false;
                    //           });
                    //         },
                    //         child: Row(
                    //           children: [
                    //             Icon(
                    //               Icons.navigate_next,
                    //               color: isArrowForwardClicked
                    //                   ? Colors.black87
                    //                   : Colors.grey,
                    //             ),
                    //             Icon(
                    //               Icons.skip_next,
                    //               color: isArrowForwardClicked
                    //                   ? Colors.black87
                    //                   : Colors.grey,
                    //             ),
                    //           ],
                    //         )),
                    //     gapW40,
                    //   ],
                    // )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

class SalesOrderAsRowInTable extends StatefulWidget {
  const SalesOrderAsRowInTable({
    super.key,
    required this.info,
    required this.index,
    this.isDesktop = true,
  });
  final Map info;
  final int index;
  final bool isDesktop;

  @override
  State<SalesOrderAsRowInTable> createState() => _SalesOrderAsRowInTableState();
}

class _SalesOrderAsRowInTableState extends State<SalesOrderAsRowInTable> {
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
  double totalPriceAfterSpecialDiscountBysalesOrderCurrency = 0.0;
  double vatBySalesOrderCurrency = 0.0;
  double finalPriceBySalesOrderCurrency = 0.0;
  List itemsInfoPrint = [];
  Map salesOrderItemInfo = {};

  String brand = '';

  final HomeController homeController = Get.find();
  final SalesOrderController salesOrderController = Get.find();
  String diss = '0';
  double totalBeforeVatvValue = 0.0;
  double globalDiscountValue = 0.0;
  double specialDiscountValue = 0.0;
  double specialDisc = 0.0;
  double res = 0.0;

  ExchangeRatesController exchangeRatesController = Get.find();

  late Uint8List imageFile;
  bool isLoading = false; // Add loading state

  @override
  void initState() {
    imageFile = Uint8List(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            TableItem(
              text: '${widget.info['salesOrderNumber'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.09
                      : 150,
            ),
            TableItem(
              text: '${widget.info['createdAtDate'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.09
                      : 150,
            ),
            TableItem(
              text:
                  widget.info['client'] == null
                      ? ''
                      : '${widget.info['client']['name'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.09
                      : 150,
            ),
            TableItem(
              text:
                  widget.info['salesperson'] == null
                      ? ''
                      : '${widget.info['salesperson']['name'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),
            SizedBox(
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.06
                      : 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Text(
                      numberWithComma('${widget.info['total'] ?? ''}'),
                      style: TextStyle(
                        fontSize: 12,
                        color: TypographyColor.textTable,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TableItem(
              text: '${widget.info['currency']['name'] ?? ''}',
              isCentered: false,
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.04
                      : 150,
            ),
            SizedBox(
              width: widget.isDesktop ? 90 : 150,
              child: Center(
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        widget.info['status'] == "pending"
                            ? Others.orangeStatusColor
                            : widget.info['status'] == 'cancelled'
                            ? Others.redStatusColor
                            : widget.info['status'] == 'sent'
                            ? Colors.blue
                            : Others.greenStatusColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.info['status'] ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            GetBuilder<SalesOrderController>(
              builder: (cont) {
                return SizedBox(
                  width:
                      widget.isDesktop
                          ? MediaQuery.of(context).size.width * 0.11
                          : 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Tooltip(
                        message: 'preview'.tr,
                        child: InkWell(
                          onTap: () async {
                            itemsInfoPrint = [];
                            salesOrderItemInfo = {};
                            totalAllItems = 0;
                            cont.totalAllItems = 0;
                            totalAllItems = 0;
                            cont.totalAllItems = 0;
                            totalPriceAfterDiscount = 0;
                            additionalSpecialDiscount = 0;
                            totalPriceAfterSpecialDiscount = 0;
                            totalPriceAfterSpecialDiscountBysalesOrderCurrency =
                                0;
                            vatBySalesOrderCurrency = 0;
                            vatBySalesOrderCurrency = 0;
                            finalPriceBySalesOrderCurrency = 0;

                            for (var item in widget.info['orderLines']) {
                              if ('${item['line_type_id']}' == '2') {
                                qty = item['item_quantity'];
                                var map =
                                    cont.itemsMap[item['item_id'].toString()];
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
                                salesOrderItemInfo = {
                                  'line_type_id': '2',
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
                                  'isImageList': false,
                                  'note': '',
                                  'image': '',
                                };
                                itemsInfoPrint.add(salesOrderItemInfo);
                              } else if ('${item['line_type_id']}' == '3') {
                                var qty = item['combo_quantity'];

                                var ind = cont.combosIdsList.indexOf(
                                  item['combo_id'].toString(),
                                );
                                var itemName = cont.combosNamesList[ind];
                                var itemPrice = double.parse(
                                  '${item['combo_unit_price'] ?? 0.0}',
                                );

                                var itemDescription = item['combo_description'];

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
                            totalPriceAfterSpecialDiscountBysalesOrderCurrency =
                                totalPriceAfterSpecialDiscount;
                            vatBySalesOrderCurrency =
                                '${widget.info['vatExempt']}' == '1'
                                    ? 0
                                    : (totalPriceAfterSpecialDiscountBysalesOrderCurrency *
                                            double.parse(
                                              await getCompanyVatFromPref(),
                                            )) /
                                        100;
                            finalPriceBySalesOrderCurrency =
                                totalPriceAfterSpecialDiscountBysalesOrderCurrency +
                                vatBySalesOrderCurrency;
                            var quotNumber = '';
                            widget.info['quotation'] == null
                                ? quotNumber = ''
                                : quotNumber =
                                    widget.info['quotation']['quotationNumber'];
                            print("--------------quotNumber");
                            print(quotNumber);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  // print('widget.info[ ${widget.info['termsAndConditions']}');
                                  return PrintSalesOrder(
                                    quotationNumber: quotNumber,
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
                                    isInSalesOrder: true,
                                    salesOrderNumber:
                                        widget.info['salesOrderNumber'] ?? '',
                                    creationDate: widget.info['validity'] ?? '',
                                    ref: widget.info['reference'] ?? '',
                                    receivedUser: '',
                                    senderUser: homeController.userName,
                                    status: widget.info['status'] ?? '',
                                    totalBeforeVat:
                                        widget.info['totalBeforeVat'] ?? '',
                                    discountOnAllItem:
                                        discountOnAllItem.toString(),
                                    totalAllItems:
                                    // totalAllItems.toString()  ,
                                    formatDoubleWithCommas(totalAllItems),

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
                                    // itemCurrencyName: itemCurrencyName,
                                    // itemCurrencySymbol: itemCurrencySymbol,
                                    // itemCurrencyLatestRate:
                                    //     itemCurrencyLatestRate,
                                    totalPriceAfterSpecialDiscountBySalesOrderCurrency:
                                        formatDoubleWithCommas(
                                          totalPriceAfterSpecialDiscountBysalesOrderCurrency,
                                        ),

                                    vatBySalesOrderCurrency:
                                        formatDoubleWithCommas(
                                          vatBySalesOrderCurrency,
                                        ),
                                    finalPriceBySalesOrderCurrency:
                                        formatDoubleWithCommas(
                                          finalPriceBySalesOrderCurrency,
                                        ),
                                    specialDisc: specialDisc.toString(),
                                    specialDiscount:
                                        widget.info['specialDiscount'] ?? '0',
                                    specialDiscountAmount:
                                        widget.info['specialDiscountAmount'] ??
                                        '',
                                    salesPerson:
                                        widget.info['salesperson'] != null
                                            ? widget.info['salesperson']['name']
                                            : '---',
                                    salesOrderCurrency:
                                        widget.info['currency']['name'] ?? '',
                                    salesOrderCurrencySymbol:
                                        widget.info['currency']['symbol'] ?? '',
                                    salesOrderCurrencyLatestRate:
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
                                        widget.info['termsAndConditions'] ?? '',
                                    itemsInfoPrint: itemsInfoPrint,
                                  );
                                },
                              ),
                            );
                          },
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            color: Primary.primary,
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'modify'.tr,
                        child: InkWell(
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
                                    content: UpdateSalesOrderDialog(
                                      index: widget.index,
                                      info: widget.info,
                                      fromPage: 'salesOrderSummary',
                                    ),
                                  ),
                            );
                          },
                          child: Icon(Icons.edit, color: Primary.primary),
                        ),
                      ),

                      // Tooltip(
                      //   message: 'send'.tr,
                      //   child: InkWell(
                      //     onTap: () async {
                      //       String cashMethodId = '';
                      //       String clientId = '';
                      //       String pricelistId = '';
                      //       String salespersonId = ' ';
                      //       String commissionMethodId = '';
                      //       String currencyId = ' ';

                      //       if (widget.info['cashingMethod'] != null) {
                      //         cashMethodId =
                      //             '${widget.info['cashingMethod']['id']}';
                      //       }
                      //       if (widget.info['commissionMethod'] != null) {
                      //         commissionMethodId =
                      //             '${widget.info['commissionMethod']['id']}';
                      //       }
                      //       if (widget.info['currency'] != null) {
                      //         currencyId = '${widget.info['currency']['id']}';
                      //       }
                      //       if (widget.info['client'] != null) {
                      //         clientId = widget.info['client']['id'].toString();
                      //       }
                      //       if (widget.info['pricelist'] != null) {
                      //         pricelistId =
                      //             widget.info['pricelist']['id'].toString();
                      //       }
                      //       if (widget.info['salesperson'] != null) {
                      //         salespersonId =
                      //             widget.info['salesperson']['id'].toString();
                      //       }
                      //       Map<int, Map<String, dynamic>> orderLines1 = {};

                      //       Map<int, dynamic> orderLinesMap = {
                      //         for (
                      //           int i = 0;
                      //           i < widget.info['orderLines'].length;
                      //           i++
                      //         )
                      //           (i + 1): widget.info['orderLines'][i],
                      //       };

                      //       for (int i = 0; i < orderLinesMap.length; i++) {
                      //         Map<String, dynamic> selectedOrderLine =
                      //             orderLinesMap[i + 1];
                      //         print("selectedOrderLine----");
                      //         print(selectedOrderLine);
                      //         orderLines1[i + 1] = {};
                      //         if (selectedOrderLine['line_type_id'] == 1) {
                      //           // Map the fields you want to copy from selectedOrderLine to orderLines1

                      //           orderLines1[i + 1]!['line_type_id'] =
                      //               selectedOrderLine['line_type_id']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['item_id'] = '';

                      //           orderLines1[i + 1]!['itemName'] = '';
                      //           orderLines1[i + 1]!['item_main_code'] = '';
                      //           orderLines1[i + 1]!['item_discount'] = '0';
                      //           orderLines1[i + 1]!['item_description'] = '';
                      //           orderLines1[i + 1]!['item_quantity'] = '0';
                      //           orderLines1[i + 1]!['item_warehouseId'] = '';
                      //           orderLines1[i + 1]!['combo_warehouseId'] = '';
                      //           orderLines1[i + 1]!['item_unit_price'] = '0';
                      //           orderLines1[i + 1]!['item_total'] = '0';
                      //           orderLines1[i + 1]!['title'] =
                      //               selectedOrderLine['title'] ?? '';
                      //           orderLines1[i + 1]!['note'] = '';
                      //           orderLines1[i + 1]!['combo'] = '';
                      //           // Add more fields as needed
                      //         }
                      //         if (selectedOrderLine['line_type_id'] == 2) {
                      //           // Map the fields you want to copy from selectedOrderLine to orderLines1

                      //           orderLines1[i + 1]!['line_type_id'] =
                      //               selectedOrderLine['line_type_id']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['item_id'] =
                      //               selectedOrderLine['item_id']?.toString() ??
                      //               '';

                      //           orderLines1[i + 1]!['itemName'] =
                      //               selectedOrderLine['item_name'] ?? '';
                      //           orderLines1[i + 1]!['item_main_code'] =
                      //               selectedOrderLine['item_main_code'] ?? '';
                      //           orderLines1[i + 1]!['item_discount'] =
                      //               selectedOrderLine['item_discount']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['item_description'] =
                      //               selectedOrderLine['item_description'] ?? '';
                      //           orderLines1[i + 1]!['item_quantity'] =
                      //               selectedOrderLine['item_quantity']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['item_warehouseId'] =
                      //               selectedOrderLine['item_warehouse_id']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['combo_warehouseId'] = '';
                      //           orderLines1[i + 1]!['item_unit_price'] =
                      //               selectedOrderLine['item_unit_price']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['item_total'] =
                      //               selectedOrderLine['item_total']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['title'] =
                      //               selectedOrderLine['title'] ?? '';
                      //           orderLines1[i + 1]!['note'] =
                      //               selectedOrderLine['note'] ?? '';
                      //           orderLines1[i + 1]!['combo'] = '';
                      //           // Add more fields as needed
                      //         }
                      //         if (selectedOrderLine['line_type_id'] == 3) {
                      //           // Map the fields you want to copy from selectedOrderLine to orderLines1
                      //           orderLines1[i + 1]!['line_type_id'] =
                      //               selectedOrderLine['line_type_id']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['item_id'] = '';

                      //           orderLines1[i + 1]!['itemName'] =
                      //               selectedOrderLine['combo_name'] ?? '';
                      //           orderLines1[i + 1]!['item_main_code'] =
                      //               selectedOrderLine['combo_code'] ?? '';
                      //           orderLines1[i + 1]!['item_discount'] =
                      //               selectedOrderLine['combo_discount']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['item_description'] =
                      //               selectedOrderLine['combo_description'] ??
                      //               '';
                      //           orderLines1[i + 1]!['item_quantity'] =
                      //               selectedOrderLine['combo_quantity']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['item_warehouseId'] = '';
                      //           orderLines1[i + 1]!['combo_warehouseId'] =
                      //               selectedOrderLine['combo_warehouse_id']
                      //                   ?.toString() ??
                      //               '10';
                      //           orderLines1[i + 1]!['item_unit_price'] =
                      //               selectedOrderLine['combo_unit_price']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['item_total'] =
                      //               selectedOrderLine['combo_total']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['title'] =
                      //               selectedOrderLine['title'] ?? '';
                      //           orderLines1[i + 1]!['note'] =
                      //               selectedOrderLine['note'] ?? '';
                      //           orderLines1[i + 1]!['combo'] =
                      //               selectedOrderLine['combo_id']?.toString() ??
                      //               '';
                      //           // Add more fields as needed
                      //         }
                      //         if (selectedOrderLine['line_type_id'] == 4) {
                      //           // Map the fields you want to copy from selectedOrderLine to orderLines1

                      //           orderLines1[i + 1]!['line_type_id'] =
                      //               selectedOrderLine['line_type_id']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['item_id'] = '';

                      //           orderLines1[i + 1]!['itemName'] = '';
                      //           orderLines1[i + 1]!['item_main_code'] = '';
                      //           orderLines1[i + 1]!['item_discount'] = '0';
                      //           orderLines1[i + 1]!['item_description'] = '';
                      //           orderLines1[i + 1]!['item_quantity'] = '0';
                      //           orderLines1[i + 1]!['item_warehouseId'] = '';
                      //           orderLines1[i + 1]!['combo_warehouseId'] = '';
                      //           orderLines1[i + 1]!['item_unit_price'] = '0';
                      //           orderLines1[i + 1]!['item_total'] = '0';
                      //           orderLines1[i + 1]!['title'] = '';
                      //           orderLines1[i + 1]!['note'] = '';
                      //           if (selectedOrderLine['image'] != null &&
                      //               selectedOrderLine['image'].isNotEmpty) {
                      //             try {
                      //               final response = await http.get(
                      //                 Uri.parse(
                      //                   '$baseImage${selectedOrderLine['image']}',
                      //                 ),
                      //               );

                      //               if (response.statusCode == 200) {
                      //                 imageFile = response.bodyBytes;
                      //               } else {
                      //                 imageFile = Uint8List(
                      //                   0,
                      //                 ); // Set to empty if loading fails
                      //               }
                      //             } catch (e) {
                      //               imageFile = Uint8List(
                      //                 0,
                      //               ); // Set to empty if loading fails
                      //             }
                      //           } else {
                      //             imageFile = Uint8List(
                      //               0,
                      //             ); // Set to empty if no image URL
                      //           }
                      //           orderLines1[i + 1]!['image'] = imageFile;
                      //           // Add more fields as needed
                      //         }
                      //         if (selectedOrderLine['line_type_id'] == 5) {
                      //           // Map the fields you want to copy from selectedOrderLine to orderLines1

                      //           orderLines1[i + 1]!['line_type_id'] =
                      //               selectedOrderLine['line_type_id']
                      //                   ?.toString() ??
                      //               '';
                      //           orderLines1[i + 1]!['item_id'] = '';

                      //           orderLines1[i + 1]!['itemName'] = '';
                      //           orderLines1[i + 1]!['item_main_code'] = '';
                      //           orderLines1[i + 1]!['item_discount'] = '0';
                      //           orderLines1[i + 1]!['item_description'] = '';
                      //           orderLines1[i + 1]!['item_quantity'] = '0';
                      //           orderLines1[i + 1]!['item_warehouseId'] = '';
                      //           orderLines1[i + 1]!['combo_warehouseId'] = '';
                      //           orderLines1[i + 1]!['item_unit_price'] = '0';
                      //           orderLines1[i + 1]!['item_total'] = '0';
                      //           orderLines1[i + 1]!['title'] = '';
                      //           orderLines1[i + 1]!['note'] =
                      //               selectedOrderLine['note'] ?? '';
                      //           orderLines1[i + 1]!['combo'] = '';
                      //           // Add more fields as needed
                      //         }
                      //       }

                      //       print("-------orderLines1---------");
                      //       print(orderLines1);
                      //       var res = await updateSalesOrder(
                      //         '${widget.info['id']}',
                      //         false,
                      //         '${widget.info['reference'] ?? ''}',
                      //         clientId,

                      //         '${widget.info['validity'] ?? ''}',
                      //         '${widget.info['inputDate'] ?? ''}',

                      //         '', //todo paymentTermsController.text,
                      //         pricelistId,
                      //         currencyId,
                      //         '${widget.info['termsAndConditions']}',
                      //         salespersonId,
                      //         commissionMethodId,
                      //         cashMethodId,
                      //         '${widget.info['commissionRate'] ?? ''}',
                      //         '${widget.info['commissionTotal'] ?? ''}',
                      //         '${widget.info['totalBeforeVat'] ?? '0.0'}', //total before vat
                      //         '${widget.info['specialDiscountAmount'] ?? '0'}', // inserted by user
                      //         '${widget.info['specialDiscount'] ?? '0'}', // calculated
                      //         '${widget.info['globalDiscountAmount'] ?? ''}',
                      //         '${widget.info['globalDiscount'] ?? ''}',
                      //         '${widget.info['vat'] ?? ''}', //vat
                      //         '${widget.info['vatLebanese'] ?? ''}',
                      //         '${widget.info['total'] ?? ''}',
                      //         '${widget.info['vatExempt'] ?? ''}',
                      //         '${widget.info['notPrinted'] ?? ''}',
                      //         '${widget.info['printedAsVatExempt'] ?? ''}',
                      //         '${widget.info['printedAsPercentage'] ?? ''}',
                      //         '${widget.info['vatInclusivePrices'] ?? ''}',
                      //         '${widget.info['beforeVatPrices'] ?? ''}',

                      //         '${widget.info['code'] ?? ''}',

                      //         'sent', // status,
                      //         orderLines1,
                      //       );
                      //       if (res['success'] == true) {
                      //         // pendingDocsController.getAllPendingDocs();
                      //         salesOrderController
                      //             .getAllSalesOrderFromBackWithoutExcept();
                      //         CommonWidgets.snackBar('Success', res['message']);
                      //       } else {
                      //         print(res['message']);
                      //         CommonWidgets.snackBar('error', res['message']);
                      //       }
                      //     },
                      //     child: Icon(
                      //       Icons.send,
                      //       color: Primary.primary,
                      //       size: 17.00,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),

                  //       ReusableMore(
                  //         itemsList: [
                  //           PopupMenuItem<String>(
                  //             value: '1',
                  //             onTap: () async {
                  //               itemsInfoPrint = [];
                  //               salesOrderItemInfo = {};
                  //               totalAllItems = 0;
                  //               cont.totalAllItems = 0;
                  //               totalAllItems = 0;
                  //               cont.totalAllItems = 0;
                  //               totalPriceAfterDiscount = 0;
                  //               additionalSpecialDiscount = 0;
                  //               totalPriceAfterSpecialDiscount = 0;
                  //               totalPriceAfterSpecialDiscountBysalesOrderCurrency =
                  //                   0;
                  //               vatBySalesOrderCurrency = 0;
                  //               vatBySalesOrderCurrency = 0;
                  //               finalPriceBySalesOrderCurrency = 0;
                  //
                  //               for (var item in widget.info['orderLines']) {
                  //                 if ('${item['line_type_id']}' == '2') {
                  //                   qty = item['item_quantity'];
                  //                   var map =
                  //                       cont.itemsMap[item['item_id'].toString()];
                  //                   itemName = map['item_name'];
                  //                   itemPrice = double.parse(
                  //                     '${item['item_unit_price'] ?? '0'}',
                  //                   );
                  //                   //     map['unitPrice'] ?? 0.0;
                  //                   // formatDoubleWithCommas(map['unitPrice']);
                  //
                  //                   itemDescription = item['item_description'];
                  //
                  //                   itemImage =
                  //                       '${map['images']}' != '[]'
                  //                           ? map['images'][0]
                  //                           : '';
                  //                   // itemCurrencyName = map['currency']['name'];
                  //                   // itemCurrencySymbol = map['currency']['symbol'];
                  //                   // itemCurrencyLatestRate =
                  //                   //     map['currency']['latest_rate'];
                  //                   var firstBrandObject = map['itemGroups']
                  //                       .firstWhere(
                  //                         (obj) =>
                  //                             obj["root_name"]?.toLowerCase() ==
                  //                             "brand".toLowerCase(),
                  //                         orElse: () => null,
                  //                       );
                  //                   brand =
                  //                       firstBrandObject == null
                  //                           ? ''
                  //                           : firstBrandObject['name'] ?? '';
                  //                   itemTotal = double.parse('${item['item_total']}');
                  //                   // itemTotal = double.parse(qty) * itemPrice;
                  //                   totalAllItems += itemTotal;
                  //                   salesOrderItemInfo = {
                  //                     'line_type_id': '2',
                  //                     'item_name': itemName,
                  //                     'item_description': itemDescription,
                  //                     'item_quantity': qty,
                  //                     'item_discount': item['item_discount'] ?? '0',
                  //                     'item_unit_price': formatDoubleWithCommas(
                  //                       itemPrice,
                  //                     ),
                  //                     'item_total': formatDoubleWithCommas(itemTotal),
                  //                     'item_image': itemImage,
                  //                     'item_brand': brand,
                  //                     'title': '',
                  //                     'isImageList': false,
                  //                     'note': '',
                  //                     'image': '',
                  //                   };
                  //                   itemsInfoPrint.add(salesOrderItemInfo);
                  //                 } else if ('${item['line_type_id']}' == '3') {
                  //                   var qty = item['item_quantity'];
                  //                   // var map =
                  //                   // cont
                  //                   //     .combosMap[item['combo_id']
                  //                   //     .toString()];
                  //                   var ind = cont.combosIdsList.indexOf(
                  //                     item['combo_id'].toString(),
                  //                   );
                  //                   var itemName = cont.combosNamesList[ind];
                  //                   var itemPrice = double.parse(
                  //                     '${item['combo_price'] ?? 0.0}',
                  //                   );
                  //                   var itemDescription = item['combo_description'];
                  //
                  //                   var itemTotal = double.parse(
                  //                     '${item['combo_total']}',
                  //                   );
                  //                   // double.parse(qty) * itemPrice;
                  //                   var salesOrderItemInfo = {
                  //                     'line_type_id': '3',
                  //                     'item_name': itemName,
                  //                     'item_description': itemDescription,
                  //                     'item_quantity': qty,
                  //                     'item_unit_price': formatDoubleWithCommas(
                  //                       itemPrice,
                  //                     ),
                  //                     'item_discount': item['combo_discount'] ?? '0',
                  //                     'item_total': formatDoubleWithCommas(itemTotal),
                  //                     'note': '',
                  //                     'item_image': '',
                  //                     'item_brand': '',
                  //                     'isImageList': false,
                  //                     'title': '',
                  //                     'image': '',
                  //                   };
                  //                   itemsInfoPrint.add(salesOrderItemInfo);
                  //                 } else if ('${item['line_type_id']}' == '1') {
                  //                   var salesOrderItemInfo = {
                  //                     'line_type_id': '1',
                  //                     'item_name': '',
                  //                     'item_description': '',
                  //                     'item_quantity': '',
                  //                     'item_unit_price': '',
                  //                     'item_discount': '0',
                  //                     'item_total': '',
                  //                     'item_image': '',
                  //                     'item_brand': '',
                  //                     'note': '',
                  //                     'isImageList': false,
                  //                     'title': item['title'],
                  //                     'image': '',
                  //                   };
                  //                   itemsInfoPrint.add(salesOrderItemInfo);
                  //                 } else if ('${item['line_type_id']}' == '5') {
                  //                   var salesOrderItemInfo = {
                  //                     'line_type_id': '5',
                  //                     'item_name': '',
                  //                     'item_description': '',
                  //                     'item_quantity': '',
                  //                     'item_unit_price': '',
                  //                     'item_discount': '0',
                  //                     'item_total': '',
                  //                     'item_image': '',
                  //                     'item_brand': '',
                  //                     'title': '',
                  //                     'note': item['note'],
                  //                     'isImageList': false,
                  //                     'image': '',
                  //                   };
                  //                   itemsInfoPrint.add(salesOrderItemInfo);
                  //                 } else if ('${item['line_type_id']}' == '4') {
                  //                   var salesOrderItemInfo = {
                  //                     'line_type_id': '4',
                  //                     'item_name': '',
                  //                     'item_description': '',
                  //                     'item_quantity': '',
                  //                     'item_unit_price': '',
                  //                     'item_discount': '0',
                  //                     'item_total': '',
                  //                     'item_image': '',
                  //                     'item_brand': '',
                  //                     'title': '',
                  //                     'note': '',
                  //                     'image': '$baseImage${item['image']}',
                  //                     'isImageList': false,
                  //                   };
                  //                   itemsInfoPrint.add(salesOrderItemInfo);
                  //                 }
                  //               }
                  //               // var primaryCurrency = await getCompanyPrimaryCurrencyFromPref();
                  //               // var result = exchangeRatesController
                  //               //     .exchangeRatesList
                  //               //     .firstWhere(
                  //               //       (item) =>
                  //               //   item["currency"] == primaryCurrency,
                  //               //   orElse: () => null,
                  //               // );
                  //               // var primaryLatestRate=
                  //               // result != null
                  //               //     ? '${result["exchange_rate"]}'
                  //               //     : '1';
                  //               // discountOnAllItem =
                  //               //     totalAllItems *
                  //               //     double.parse(
                  //               //       widget.info['globalDiscount'] ?? '0',
                  //               //     ) /
                  //               //     100;
                  //
                  //               totalPriceAfterDiscount =
                  //                   totalAllItems - discountOnAllItem;
                  //               additionalSpecialDiscount =
                  //                   totalPriceAfterDiscount *
                  //                   double.parse(
                  //                     widget.info['specialDiscount'] ?? '0',
                  //                   ) /
                  //                   100;
                  //               totalPriceAfterSpecialDiscount =
                  //                   totalPriceAfterDiscount -
                  //                   additionalSpecialDiscount;
                  //               totalPriceAfterSpecialDiscountBysalesOrderCurrency =
                  //                   totalPriceAfterSpecialDiscount;
                  //               vatBySalesOrderCurrency =
                  //                   '${widget.info['vatExempt']}' == '1'
                  //                       ? 0
                  //                       : (totalPriceAfterSpecialDiscountBysalesOrderCurrency *
                  //                               double.parse(
                  //                                 await getCompanyVatFromPref(),
                  //                               )) /
                  //                           100;
                  //               finalPriceBySalesOrderCurrency =
                  //                   totalPriceAfterSpecialDiscountBysalesOrderCurrency;
                  //               vatBySalesOrderCurrency;
                  //               Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                   builder: (BuildContext context) {
                  //                     // print('widget.info[ ${widget.info['termsAndConditions']}');
                  //                     return PrintSalesOrder(
                  //                       isPrintedAs0:
                  //                           '${widget.info['printedAsPercentage']}' ==
                  //                                   '1'
                  //                               ? true
                  //                               : false,
                  //                       isVatNoPrinted:
                  //                           '${widget.info['notPrinted']}' == '1'
                  //                               ? true
                  //                               : false,
                  //                       isPrintedAsVatExempt:
                  //                           '${widget.info['printedAsVatExempt']}' ==
                  //                                   '1'
                  //                               ? true
                  //                               : false,
                  //                       isInSalesOrder: true,
                  //                       salesOrderNumber:
                  //                           widget.info['salesOrderNumber'] ?? '',
                  //                       creationDate: widget.info['validity'] ?? '',
                  //                       ref: widget.info['reference'] ?? '',
                  //                       receivedUser: '',
                  //                       senderUser: homeController.userName,
                  //                       status: widget.info['status'] ?? '',
                  //                       totalBeforeVat:
                  //                           widget.info['totalBeforeVat'] ?? '',
                  //                       discountOnAllItem:
                  //                           discountOnAllItem.toString(),
                  //                       totalAllItems:
                  //                       // totalAllItems.toString()  ,
                  //                       formatDoubleWithCommas(
                  //                         totalPriceAfterDiscount,
                  //                       ),
                  //
                  //                       globalDiscount:
                  //                           widget.info['globalDiscount'] ?? '0',
                  //
                  //                       totalPriceAfterDiscount:
                  //                           formatDoubleWithCommas(
                  //                             totalPriceAfterDiscount,
                  //                           ),
                  //                       additionalSpecialDiscount:
                  //                           additionalSpecialDiscount.toStringAsFixed(
                  //                             2,
                  //                           ),
                  //                       totalPriceAfterSpecialDiscount:
                  //                           formatDoubleWithCommas(
                  //                             totalPriceAfterSpecialDiscount,
                  //                           ),
                  //                       // itemCurrencyName: itemCurrencyName,
                  //                       // itemCurrencySymbol: itemCurrencySymbol,
                  //                       // itemCurrencyLatestRate:
                  //                       //     itemCurrencyLatestRate,
                  //                       totalPriceAfterSpecialDiscountBysalesOrderCurrency:
                  //                           formatDoubleWithCommas(
                  //                             totalPriceAfterSpecialDiscountBysalesOrderCurrency,
                  //                           ),
                  //
                  //                       vatBySalesOrderCurrency:
                  //                           formatDoubleWithCommas(
                  //                             vatBySalesOrderCurrency,
                  //                           ),
                  //                       finalPriceBySalesOrderCurrency:
                  //                           formatDoubleWithCommas(
                  //                             finalPriceBySalesOrderCurrency,
                  //                           ),
                  //                       specialDisc: specialDisc.toString(),
                  //                       specialDiscount:
                  //                           widget.info['specialDiscount'] ?? '0',
                  //                       specialDiscountAmount:
                  //                           widget.info['specialDiscountAmount'] ??
                  //                           '',
                  //                       salesPerson:
                  //                           widget.info['salesperson'] != null
                  //                               ? widget.info['salesperson']['name']
                  //                               : '---',
                  //                       salesOrderCurrency:
                  //                           widget.info['currency']['name'] ?? '',
                  //                       salesOrderCurrencySymbol:
                  //                           widget.info['currency']['symbol'] ?? '',
                  //                       salesOrderCurrencyLatestRate:
                  //                           widget.info['currency']['latest_rate'] ??
                  //                           '',
                  //                       clientPhoneNumber:
                  //                           widget.info['client'] != null
                  //                               ? widget.info['client']['phoneNumber'] ??
                  //                                   '---'
                  //                               : "---",
                  //                       clientName:
                  //                           widget.info['client']['name'] ?? '',
                  //                       termsAndConditions:
                  //                           widget.info['termsAndConditions'] ?? '',
                  //                       itemsInfoPrint: itemsInfoPrint,
                  //                     );
                  //                   },
                  //                 ),
                  //               );
                  //             },
                  //             child: Text('preview'.tr),
                  //           ),
                  //           PopupMenuItem<String>(
                  //             value: '2',
                  //             onTap: () async {
                  //               showDialog<String>(
                  //                 context: context,
                  //                 builder:
                  //                     (BuildContext context) => AlertDialog(
                  //                       backgroundColor: Colors.white,
                  //                       shape: const RoundedRectangleBorder(
                  //                         borderRadius: BorderRadius.all(
                  //                           Radius.circular(9),
                  //                         ),
                  //                       ),
                  //                       elevation: 0,
                  //                       content: UpdateSalesOrderDialog(
                  //                         index: widget.index,
                  //                         info: widget.info,
                  //                       ),
                  //                     ),
                  //               );
                  //             },
                  //             child: Text('Update'.tr),
                  //           ),
                  //         ],
                  //       ),
                );
              },
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          ],
        ),
      ),
    );
  }
}
