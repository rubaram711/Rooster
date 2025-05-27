import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/Quotations/update_quotation.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Controllers/task_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/Screens/Quotations/print_quotation.dart';
import 'package:rooster_app/Screens/Quotations/schedule_task_dialog.dart';
import 'package:rooster_app/Screens/Quotations/tasks.dart';
import 'package:rooster_app/Widgets/custom_snak_bar.dart';
import 'package:rooster_app/Widgets/page_title.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import 'package:rooster_app/Widgets/reusable_more.dart';
import 'package:rooster_app/Widgets/reusable_text_field.dart';
import 'package:rooster_app/Widgets/table_item.dart';
import 'package:rooster_app/Widgets/table_title.dart';
import 'package:rooster_app/const/colors.dart';
import 'package:rooster_app/const/functions.dart';
import 'package:rooster_app/const/sizes.dart';
import 'package:rooster_app/const/urls.dart';

class ToInvoice extends StatefulWidget {
  const ToInvoice({super.key});

  @override
  State<ToInvoice> createState() => _ToInvoiceState();
}

class _ToInvoiceState extends State<ToInvoice> {
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
  final QuotationController quotationController = Get.find();
  bool isNumberOrderedUp = true;
  bool isCreationOrderedUp = true;
  bool isCustomerOrderedUp = true;
  bool isSalespersonOrderedUp = true;
  String searchValue = '';
  Timer? searchOnStoppedTyping;
  List quotationsList = [];
  bool isQuotationsFetched = false;
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
    await quotationController.getAllQuotationsFromBack();
  }

  TaskController taskController = Get.find();
  int selectedTabIndex = 0;
  List tabsList = ['all_quotations', 'tasks'];
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

  @override
  void initState() {
    quotationController.itemsMultiPartList = [];
    quotationController.salesPersonListNames = [];
    quotationController.salesPersonListId = [];
    exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();
    quotationController.getAllUsersSalesPersonFromBack();
    quotationController.getFieldsForCreateQuotationFromBack();
    quotationController.searchInQuotationsController.text = '';
    listViewLength =
        Sizes.deviceHeight * (0.09 * quotationController.quotationsList.length);
    quotationController.getAllQuotationsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuotationController>(
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
                  children: [PageTitle(text: 'to_invoice'.tr)],
                ),
                gapH24,
                SizedBox(
                  // width: MediaQuery.of(context).size.width * 0.59,
                  child: ReusableSearchTextField(
                    hint: '${"search".tr}...',
                    textEditingController: cont.searchInQuotationsController,
                    onChangedFunc: (value) {
                      if (selectedTabIndex == 1) {
                        // cont.searchInQuotationsController.text=value;
                        _onChangeTaskSearchHandler(value);
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
                selectedTabIndex == 0
                    ? Column(
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
                                        ? cont.quotationsList.sort(
                                          (a, b) => a['quotationNumber']
                                              .compareTo(b['quotationNumber']),
                                        )
                                        : cont.quotationsList.sort(
                                          (a, b) => b['quotationNumber']
                                              .compareTo(a['quotationNumber']),
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
                                        ? cont.quotationsList.sort(
                                          (a, b) => a['createdAtDate']
                                              .compareTo(b['createdAtDate']),
                                        )
                                        : cont.quotationsList.sort(
                                          (a, b) => b['createdAtDate']
                                              .compareTo(a['createdAtDate']),
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
                                        ? cont.quotationsList.sort(
                                          (a, b) => '${a['client']['name']}'
                                              .compareTo(
                                                '${b['client']['name']}',
                                              ),
                                        )
                                        : cont.quotationsList.sort(
                                          (a, b) => '${b['client']['name']}'
                                              .compareTo(
                                                '${a['client']['name']}',
                                              ),
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
                                        ? cont.quotationsList.sort(
                                          (a, b) => a['salesperson'].compareTo(
                                            b['salesperson'],
                                          ),
                                        )
                                        : cont.quotationsList.sort(
                                          (a, b) => b['salesperson'].compareTo(
                                            a['salesperson'],
                                          ),
                                        );
                                  });
                                },
                              ),
                              TableTitle(
                                text: 'task'.tr,
                                width:
                                    MediaQuery.of(context).size.width *
                                    0.07, //085
                              ),
                              TableTitle(
                                text: 'total'.tr,
                                width:
                                    MediaQuery.of(context).size.width *
                                    0.07, //085
                              ),
                              TableTitle(
                                text: 'currency'.tr,
                                width:
                                    MediaQuery.of(context).size.width *
                                    0.07, //085
                              ),
                              TableTitle(
                                text: 'status'.tr,
                                width:
                                    MediaQuery.of(context).size.width *
                                    0.085, //085
                              ),
                              TableTitle(
                                text: 'more_options'.tr,
                                width: MediaQuery.of(context).size.width * 0.07,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.03,
                              ),
                            ],
                          ),
                        ),

                        cont.isQuotationsFetched
                            ? Container(
                              color: Colors.white,
                              // height: listViewLength,
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.4, //listViewLength
                              child: ListView.builder(
                                itemCount: cont.quotationsList.length,
                                // itemCount:  cont.quotationsList.length>9?selectedNumberOfRowsAsInt:cont.quotationsList.length,
                                itemBuilder: (context, index) {
                                  if (cont.quotationsList[index]['status'] ==
                                      'pending') {
                                    return Column(
                                      children: [
                                        QuotationAsRowInTable(
                                          info: cont.quotationsList[index],
                                          index: index,
                                        ),
                                        const Divider(),
                                      ],
                                    );
                                  }
                                },
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
                    )
                    : const Tasks(),
              ],
            ),
          ),
        );
      },
    );
  }

  //**********End GetBuilder */
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

class QuotationAsRowInTable extends StatefulWidget {
  const QuotationAsRowInTable({
    super.key,
    required this.info,
    required this.index,
    this.isDesktop = true,
  });
  final Map info;
  final int index;
  final bool isDesktop;

  @override
  State<QuotationAsRowInTable> createState() => _QuotationAsRowInTableState();
}

class _QuotationAsRowInTableState extends State<QuotationAsRowInTable> {
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
  String brand = '';

  final HomeController homeController = Get.find();
  final QuotationController quotationController = Get.find();
  String diss = '0';
  double totalBeforeVatvValue = 0.0;
  double globalDiscountValue = 0.0;
  double specialDiscountValue = 0.0;
  double specialDisc = 0.0;
  double res = 0.0;
  void _showPopupMenu(BuildContext context, TapDownDetails details) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(100, 100), // Position of click
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: Text("schedule_task".tr),
          onTap: () {
            showDialog<String>(
              context: context,
              builder:
                  (BuildContext context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                    elevation: 0,
                    content: ScheduleTaskDialogContent(
                      quotationId: '${widget.info['id']}',
                      isUpdate: false,
                      task: {},
                    ),
                  ),
            );
          },
        ),
      ],
    );
  }

  ExchangeRatesController exchangeRatesController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onDoubleTap: () {
        if (widget.info['status'] == 'pending') {
          homeController.selectedTab.value = 'quotation_data';
        } else {
          homeController.selectedTab.value = 'quotation_summary';
        }
        quotationController.setSelectedQuotation(widget.info);
      },
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
              text: '${widget.info['quotationNumber'] ?? ''}',
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
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTapDown: (details) => _showPopupMenu(context, details),
                child: TableItem(
                  text:
                      widget.info['tasks'].isNotEmpty
                          ? widget.info['tasks']
                              .map((task) => task["summary"] as String)
                              .join(", ")
                          : 'No Records',
                  width:
                      widget.isDesktop
                          ? MediaQuery.of(context).size.width * 0.07
                          : 150,
                ),
              ),
            ),

            TableItem(
              text: numberWithComma('${widget.info['total'] ?? ''}'),
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),
            TableItem(
              text: '${widget.info['currency']['name'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),
            SizedBox(
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.085
                      : 150,
              child: Center(
                child: Container(
                  width: '${widget.info['status']}'.length * 10.0,
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
            GetBuilder<QuotationController>(
              builder: (cont) {
                return SizedBox(
                  width:
                      widget.isDesktop
                          ? MediaQuery.of(context).size.width * 0.07
                          : 150,
                  child: ReusableMore(
                    itemsList: [
                      PopupMenuItem<String>(
                        value: '1',
                        onTap: () async {
                          itemsInfoPrint = [];
                          quotationItemInfo = {};
                          totalAllItems = 0;
                          cont.totalAllItems = 0;
                          totalAllItems = 0;
                          cont.totalAllItems = 0;
                          totalPriceAfterDiscount = 0;
                          additionalSpecialDiscount = 0;
                          totalPriceAfterSpecialDiscount = 0;
                          totalPriceAfterSpecialDiscountByQuotationCurrency = 0;
                          vatByQuotationCurrency = 0;
                          vatByQuotationCurrency = 0;
                          finalPriceByQuotationCurrency = 0;

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
                                  '${map['images']}' != '[]'
                                      ? map['images'][0]
                                      : '';
                              // itemCurrencyName = map['currency']['name'];
                              // itemCurrencySymbol = map['currency']['symbol'];
                              // itemCurrencyLatestRate =
                              //     map['currency']['latest_rate'];
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
                              itemTotal = double.parse('${item['item_total']}');
                              // itemTotal = double.parse(qty) * itemPrice;
                              totalAllItems += itemTotal;
                              quotationItemInfo = {
                                'line_type_id': '2',
                                'item_name': itemName,
                                'item_description': itemDescription,
                                'item_quantity': qty,
                                'item_discount': item['item_discount'] ?? '0',
                                'item_unit_price': formatDoubleWithCommas(
                                  itemPrice,
                                ),
                                'item_total': formatDoubleWithCommas(itemTotal),
                                'item_image': itemImage,
                                'item_brand': brand,
                                'title': '',
                                'isImageList': false,
                                'note': '',
                                'image': '',
                              };
                              itemsInfoPrint.add(quotationItemInfo);
                            } else if ('${item['line_type_id']}' == '3') {
                              var qty = item['item_quantity'];
                              // var map =
                              // cont
                              //     .combosMap[item['combo_id']
                              //     .toString()];
                              var ind = cont.combosIdsList.indexOf(
                                item['combo_id'].toString(),
                              );
                              var itemName = cont.combosNamesList[ind];
                              var itemPrice = double.parse(
                                '${item['combo_price'] ?? 0.0}',
                              );
                              var itemDescription = item['combo_description'];

                              var itemTotal = double.parse(
                                '${item['combo_total']}',
                              );
                              // double.parse(qty) * itemPrice;
                              var quotationItemInfo = {
                                'line_type_id': '3',
                                'item_name': itemName,
                                'item_description': itemDescription,
                                'item_quantity': qty,
                                'item_unit_price': formatDoubleWithCommas(
                                  itemPrice,
                                ),
                                'item_discount': item['combo_discount'] ?? '0',
                                'item_total': formatDoubleWithCommas(itemTotal),
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
                          // var primaryCurrency = await getCompanyPrimaryCurrencyFromPref();
                          // var result = exchangeRatesController
                          //     .exchangeRatesList
                          //     .firstWhere(
                          //       (item) =>
                          //   item["currency"] == primaryCurrency,
                          //   orElse: () => null,
                          // );
                          // var primaryLatestRate=
                          // result != null
                          //     ? '${result["exchange_rate"]}'
                          //     : '1';
                          // discountOnAllItem =
                          //     totalAllItems *
                          //     double.parse(
                          //       widget.info['globalDiscount'] ?? '0',
                          //     ) /
                          //     100;

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
                          totalPriceAfterSpecialDiscountByQuotationCurrency =
                              totalPriceAfterSpecialDiscount;
                          vatByQuotationCurrency =
                              '${widget.info['vatExempt']}' == '1'
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
                                // print('widget.info[ ${widget.info['termsAndConditions']}');
                                return PrintQuotationData(
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
                                  isInQuotation: true,
                                  quotationNumber:
                                      widget.info['quotationNumber'] ?? '',
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
                                  formatDoubleWithCommas(
                                    totalPriceAfterDiscount,
                                  ),

                                  globalDiscount:
                                      widget.info['globalDiscount'] ?? '0',

                                  totalPriceAfterDiscount:
                                      formatDoubleWithCommas(
                                        totalPriceAfterDiscount,
                                      ),
                                  additionalSpecialDiscount:
                                      additionalSpecialDiscount.toStringAsFixed(
                                        2,
                                      ),
                                  totalPriceAfterSpecialDiscount:
                                      formatDoubleWithCommas(
                                        totalPriceAfterSpecialDiscount,
                                      ),
                                  // itemCurrencyName: itemCurrencyName,
                                  // itemCurrencySymbol: itemCurrencySymbol,
                                  // itemCurrencyLatestRate:
                                  //     itemCurrencyLatestRate,
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
                                      widget.info['specialDiscount'] ?? '0',
                                  specialDiscountAmount:
                                      widget.info['specialDiscountAmount'] ??
                                      '',
                                  salesPerson:
                                      widget.info['salesperson'] != null
                                          ? widget.info['salesperson']['name']
                                          : '---',
                                  quotationCurrency:
                                      widget.info['currency']['name'] ?? '',
                                  quotationCurrencySymbol:
                                      widget.info['currency']['symbol'] ?? '',
                                  quotationCurrencyLatestRate:
                                      widget.info['currency']['latest_rate'] ??
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
                        child: Text('preview'.tr),
                      ),
                      // PopupMenuItem<String>(
                      //   value: '2',
                      //   onTap: () async {
                      //     showDialog<String>(
                      //       context: context,
                      //       builder:
                      //           (BuildContext context) => AlertDialog(
                      //             backgroundColor: Colors.white,
                      //             shape: const RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.all(
                      //                 Radius.circular(9),
                      //               ),
                      //             ),
                      //             elevation: 0,
                      //             content: UpdateQuotationDialog(
                      //               index: widget.index,
                      //               info: widget.info,
                      //             ),
                      //           ),
                      //     );
                      //   },
                      //   child: Text('Update'.tr),
                      // ),
                      PopupMenuItem<String>(
                        value: '2',
                        onTap: () async {
                          //update from back
                          var res = await updateQuotation(
                            '${widget.info['id']}',

                            '${widget.info['id']['reference']}',
                            '${widget.info['id']['client']['id']}',

                            '${widget.info['id']['validity']}',
                            '', //todo paymentTermsController.text,
                            '${widget.info['id']['pricelist']['id']}',
                            '${widget.info['id']['currency']['id']}',
                            '${widget.info['id']['termsAndConditions']}',
                            '${widget.info['id']['salesperson']['id']}',
                            '',
                            '${widget.info['id']['cashingMethod']}',
                            '${widget.info['id']['commissionMethod']}',
                            '${widget.info['id']['commissionTotal']}',
                            '${widget.info['id']['totalBeforeVat']}', //total before vat
                            '${widget.info['id']['specialDiscountAmount']}', // inserted by user
                            '${widget.info['id']['specialDiscount']}', // calculated
                            '${widget.info['id']['globalDiscountAmount']}',
                            '${widget.info['id']['globalDiscount']}',
                            '${widget.info['id']['vat']}', //vat
                            '${widget.info['id']['vatLebanese']}',
                            '${widget.info['id']['total']}',
                            quotationController.isVatExemptChecked ? '1' : '0',
                            quotationController.isVatNoPrinted ? '1' : '0',
                            quotationController.isPrintedAsVatExempt
                                ? '1'
                                : '0',
                            quotationController.isPrintedAs0 ? '1' : '0',
                            quotationController.isBeforeVatPrices ? '0' : '1',
                            quotationController.isBeforeVatPrices ? '1' : '0',

                            '${widget.info['id']['code']}',
                            'cancelled', // status,
                            // quotationController.rowsInListViewInQuotation,
                            widget.info['id']['orderLines'],
                          );
                          if (res['success'] == true) {
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
                            CommonWidgets.snackBar(
                              'Success',
                              'Cancelled Successfully',
                            );
                          } else {
                            CommonWidgets.snackBar(
                              'error',
                              'Error : Not Cancelled',
                            );
                          }
                        },
                        child: Text('cancelled'.tr),
                      ),
                    ],
                  ),
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
