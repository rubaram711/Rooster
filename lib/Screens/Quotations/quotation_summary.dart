import 'dart:async';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Controllers/task_controller.dart';
import 'package:rooster_app/Screens/Quotations/print_quotation.dart';
import 'package:rooster_app/Screens/Quotations/schedule_task_dialog.dart';
import 'package:rooster_app/Screens/Quotations/tasks.dart';
import 'package:rooster_app/const/constants.dart';
import '../../Backend/Quotations/delete_quotation.dart';
import '../../Backend/Quotations/update_quotation.dart';
import '../../Controllers/home_controller.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_table_menu.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../../const/functions.dart';
import '../../const/urls.dart';
import 'update_quotation_dialog.dart';

class QuotationSummary extends StatefulWidget {
  const QuotationSummary({super.key});

  @override
  State<QuotationSummary> createState() => _QuotationSummaryState();
}

class _QuotationSummaryState extends State<QuotationSummary> {
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
    // await quotationController.getAllQuotationsFromBack();
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

  _quotationSearchHandler(value) {
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
            () => searchOnQuotation(value),
          ),
    );
  }

  searchOnQuotation(value) async {
    quotationController.setSearchInQuotationsController(value);
    await quotationController.getAllQuotationsFromBack();
  }
  //
  //   Future<void> generatePdfFromImageUrl() async {
  //     String companyLogo = await getCompanyLogoFromPref();
  // print('companyLogo1 $companyLogo');
  //     // 1. Download image
  //     final response = await http.get(Uri.parse(companyLogo));
  //     print('response is ${response.statusCode} ');
  //     print(response.body );
  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to load image');
  //     }
  //
  //     final Uint8List imageBytes = response.bodyBytes;
  //     // String companyLogo = await getCompanyLogoFromPref();
  //     // final Uint8List logoBytes = await fetchImage(
  //     //   companyLogo,
  //     // );
  //     quotationController.setLogo(imageBytes);
  //   }

  @override
  void initState() {
    // generatePdfFromImageUrl();
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
                  children: [
                    PageTitle(text: 'quotations'.tr),
                    ReusableButtonWithColor(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: 45,
                      onTapFunction: () {
                        homeController.selectedTab.value = 'new_quotation';
                      },
                      btnText: 'create_new_quotation'.tr,
                    ),
                  ],
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
                      } else {
                        _quotationSearchHandler(value);
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
                                90.w,
                                // MediaQuery.of(context).size.width * 0.08,
                                () {
                                  setState(() {
                                    isNumberOrderedUp = !isNumberOrderedUp;
                                    isNumberOrderedUp
                                        ? cont.quotationsListCC.sort(
                                          (a, b) => a['quotationNumber']
                                              .compareTo(b['quotationNumber']),
                                        )
                                        : cont.quotationsListCC.sort(
                                          (a, b) => b['quotationNumber']
                                              .compareTo(a['quotationNumber']),
                                        );
                                  });
                                },
                              ),
                              tableTitleWithOrderArrow(
                                'creation'.tr,
                                90.w,
                                // MediaQuery.of(context).size.width * 0.08,
                                () {
                                  setState(() {
                                    isCreationOrderedUp = !isCreationOrderedUp;
                                    isCreationOrderedUp
                                        ? cont.quotationsListCC.sort(
                                          (a, b) => a['createdAtDate']
                                              .compareTo(b['createdAtDate']),
                                        )
                                        : cont.quotationsListCC.sort(
                                          (a, b) => b['createdAtDate']
                                              .compareTo(a['createdAtDate']),
                                        );
                                  });
                                },
                              ),
                              tableTitleWithOrderArrow(
                                'customer'.tr,
                                90.w,
                                // MediaQuery.of(context).size.width * 0.08,
                                () {
                                  setState(() {
                                    isCustomerOrderedUp = !isCustomerOrderedUp;
                                    isCustomerOrderedUp
                                        ? cont.quotationsListCC.sort(
                                          (a, b) => '${a['client']['name']}'
                                              .compareTo(
                                                '${b['client']['name']}',
                                              ),
                                        )
                                        : cont.quotationsListCC.sort(
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
                                90.w,
                                // MediaQuery.of(context).size.width * 0.07,
                                () {
                                  setState(() {
                                    isSalespersonOrderedUp =
                                        !isSalespersonOrderedUp;
                                    isSalespersonOrderedUp
                                        ? cont.quotationsListCC.sort(
                                          (a, b) => a['salesperson'].compareTo(
                                            b['salesperson'],
                                          ),
                                        )
                                        : cont.quotationsListCC.sort(
                                          (a, b) => b['salesperson'].compareTo(
                                            a['salesperson'],
                                          ),
                                        );
                                  });
                                },
                              ),
                              TableTitle(
                                text: 'chance'.tr,
                                width: 90.w, //085
                                // MediaQuery.of(context).size.width *
                                // 0.07, //085
                              ),
                              TableTitle(
                                text: 'task'.tr,
                                width: 90.w, //085
                                // MediaQuery.of(context).size.width *
                                // 0.07, //085
                              ),
                              TableTitle(
                                text: 'total'.tr,
                                // isCentered: false,
                                width: 90.w, //085
                                // MediaQuery.of(context).size.width *
                                // 0.06, //085
                              ),
                              // SizedBox(
                              //     width:
                              //     MediaQuery.of(context).size.width *
                              //         0.06,
                              //   child:Row(
                              //     mainAxisAlignment: MainAxisAlignment.end,
                              //     children: [
                              //       Padding(
                              //         padding: const EdgeInsets.only(right: 10.0),
                              //         child: Text('total'.tr,
                              //             style: const TextStyle(
                              //                 color: Colors.white, fontWeight: FontWeight.bold)),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              TableTitle(
                                text: 'cur'.tr,
                                isCentered: false,
                                width: 50.w, //085
                                // MediaQuery.of(context).size.width *
                                // 0.04, //085
                              ),
                              TableTitle(
                                text: 'status'.tr,
                                // isCentered: false,
                                width: 90.w, //085
                                // width: 90, //085
                              ),
                              TableTitle(
                                text: 'more_options'.tr,
                                width: 90.w,
                                // width: MediaQuery.of(context).size.width * 0.09,
                              ),
                              SizedBox(
                                width: 30.w,
                                // width: MediaQuery.of(context).size.width * 0.03,
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
                                itemCount: cont.quotationsListCC.length,
                                // itemCount:  cont.quotationsList.length>9?selectedNumberOfRowsAsInt:cont.quotationsList.length,
                                itemBuilder:
                                    (context, index) => Column(
                                      children: [
                                        QuotationAsRowInTable(
                                          info: cont.quotationsListCC[index],
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
                    )
                    : const Tasks(),
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
      // onDoubleTap:
      //     () {
      //   if (widget.info['status'] == 'pending') {
      //     homeController.selectedTab.value = 'quotation_data';
      //   } else {
      //     homeController.selectedTab.value = 'quotation_summary';
      //   }
      //   quotationController.setSelectedQuotation(widget.info);
      // },
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
              width: widget.isDesktop ? 90.w : 150,
              // widget.isDesktop
              //     ? MediaQuery.of(context).size.width * 0.08
              //     : 150,
            ),
            TableItem(
              text: '${widget.info['createdAtDate'] ?? ''}',
              width: widget.isDesktop ? 90.w : 150,
              // widget.isDesktop ? MediaQuery.of(context).size.width * 0.08 : 150,
            ),
            TableItem(
              text:
                  widget.info['client'] == null
                      ? ''
                      : '${widget.info['client']['name'] ?? ''}',
              width: widget.isDesktop ? 90.w : 150,
              // widget.isDesktop
              //     ? MediaQuery.of(context).size.width * 0.08
              //     : 150,
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
            // TableItem(
            //   text: widget.info['chance'] ?? '',
            //   width:
            //       widget.isDesktop
            //           ? MediaQuery.of(context).size.width * 0.07
            //           : 150,
            // ),
            ReusableStatusDropdown(
              options: chanceLevels,
              value: widget.info['chance'] ?? chanceLevels.first,
              onSelected: (value) async {
                //update from back

                Map<int, Map<String, dynamic>> orderLines1 = {};
                List<int> orderedKeys = [];
                Map<int, dynamic> orderLinesMap = {
                  for (int i = 0; i < widget.info['orderLines'].length; i++)
                    (i + 1): widget.info['orderLines'][i],
                };

                for (int i = 0; i < orderLinesMap.length; i++) {
                  orderedKeys.add(i + 1);
                  Map<String, dynamic> selectedOrderLine = orderLinesMap[i + 1];
                  orderLines1[i + 1] = {};
                  if (selectedOrderLine['line_type_id'] == 1) {
                    // Map the fields you want to copy from selectedOrderLine to orderLines1

                    orderLines1[i + 1]!['line_type_id'] =
                        selectedOrderLine['line_type_id']?.toString() ?? '';
                    orderLines1[i + 1]!['item_id'] = '';

                    orderLines1[i + 1]!['itemName'] = '';
                    orderLines1[i + 1]!['item_main_code'] = '';
                    orderLines1[i + 1]!['item_discount'] = '0';
                    orderLines1[i + 1]!['item_description'] = '';
                    orderLines1[i + 1]!['item_quantity'] = '0';

                    orderLines1[i + 1]!['item_unit_price'] = '0';
                    orderLines1[i + 1]!['item_total'] = '0';
                    orderLines1[i + 1]!['title'] =
                        selectedOrderLine['title'] ?? '';
                    orderLines1[i + 1]!['note'] = '';
                    orderLines1[i + 1]!['combo'] = '';
                    // Add more fields as needed
                  }
                  if (selectedOrderLine['line_type_id'] == 2) {
                    // Map the fields you want to copy from selectedOrderLine to orderLines1

                    orderLines1[i + 1]!['line_type_id'] =
                        selectedOrderLine['line_type_id']?.toString() ?? '';
                    orderLines1[i + 1]!['item_id'] =
                        selectedOrderLine['item_id']?.toString() ?? '';

                    orderLines1[i + 1]!['itemName'] =
                        selectedOrderLine['item_name'] ?? '';
                    orderLines1[i + 1]!['item_main_code'] =
                        selectedOrderLine['item_main_code'] ?? '';
                    orderLines1[i + 1]!['item_discount'] =
                        selectedOrderLine['item_discount']?.toString() ?? '';
                    orderLines1[i + 1]!['item_description'] =
                        selectedOrderLine['item_description'] ?? '';
                    orderLines1[i + 1]!['item_quantity'] =
                        selectedOrderLine['item_quantity']?.toString() ?? '';

                    orderLines1[i + 1]!['item_unit_price'] =
                        selectedOrderLine['item_unit_price']?.toString() ?? '';
                    orderLines1[i + 1]!['item_total'] =
                        selectedOrderLine['item_total']?.toString() ?? '';
                    orderLines1[i + 1]!['title'] =
                        selectedOrderLine['title'] ?? '';
                    orderLines1[i + 1]!['note'] =
                        selectedOrderLine['note'] ?? '';
                    orderLines1[i + 1]!['combo'] = '';
                    // Add more fields as needed
                  }
                  if (selectedOrderLine['line_type_id'] == 3) {
                    // Map the fields you want to copy from selectedOrderLine to orderLines1
                    orderLines1[i + 1]!['line_type_id'] =
                        selectedOrderLine['line_type_id']?.toString() ?? '';
                    orderLines1[i + 1]!['item_id'] = '';

                    orderLines1[i + 1]!['itemName'] =
                        selectedOrderLine['combo_name'] ?? '';
                    orderLines1[i + 1]!['item_main_code'] =
                        selectedOrderLine['combo_code'] ?? '';
                    orderLines1[i + 1]!['item_discount'] =
                        selectedOrderLine['combo_discount']?.toString() ?? '';
                    orderLines1[i + 1]!['item_description'] =
                        selectedOrderLine['combo_description'] ?? '';
                    orderLines1[i + 1]!['item_quantity'] =
                        selectedOrderLine['combo_quantity']?.toString() ?? '';

                    orderLines1[i + 1]!['item_unit_price'] =
                        selectedOrderLine['combo_unit_price']?.toString() ?? '';
                    orderLines1[i + 1]!['item_total'] =
                        selectedOrderLine['combo_total']?.toString() ?? '';
                    orderLines1[i + 1]!['title'] =
                        selectedOrderLine['title'] ?? '';
                    orderLines1[i + 1]!['note'] =
                        selectedOrderLine['note'] ?? '';
                    orderLines1[i + 1]!['combo'] =
                        selectedOrderLine['combo_id']?.toString() ?? '';
                    // Add more fields as needed
                  }
                  if (selectedOrderLine['line_type_id'] == 4) {
                    // Map the fields you want to copy from selectedOrderLine to orderLines1

                    orderLines1[i + 1]!['line_type_id'] =
                        selectedOrderLine['line_type_id']?.toString() ?? '';
                    orderLines1[i + 1]!['item_id'] = '';

                    orderLines1[i + 1]!['itemName'] = '';
                    orderLines1[i + 1]!['item_main_code'] = '';
                    orderLines1[i + 1]!['item_discount'] = '0';
                    orderLines1[i + 1]!['item_description'] = '';
                    orderLines1[i + 1]!['item_quantity'] = '0';

                    orderLines1[i + 1]!['item_unit_price'] = '0';
                    orderLines1[i + 1]!['item_total'] = '0';
                    orderLines1[i + 1]!['title'] = '';
                    orderLines1[i + 1]!['note'] = '';
                    late Uint8List imageFile;
                    if (selectedOrderLine['image'] != null &&
                        selectedOrderLine['image'].isNotEmpty) {
                      try {
                        final response = await http.get(
                          Uri.parse('$baseImage${selectedOrderLine['image']}'),
                        );

                        if (response.statusCode == 200) {
                          imageFile = response.bodyBytes;
                        } else {
                          imageFile = Uint8List(
                            0,
                          ); // Set to empty if loading fails
                        }
                      } catch (e) {
                        imageFile = Uint8List(
                          0,
                        ); // Set to empty if loading fails
                      }
                    } else {
                      imageFile = Uint8List(0); // Set to empty if no image URL
                    }
                    orderLines1[i + 1]!['image'] = imageFile;
                    // Add more fields as needed
                  }
                  if (selectedOrderLine['line_type_id'] == 5) {
                    // Map the fields you want to copy from selectedOrderLine to orderLines1

                    orderLines1[i + 1]!['line_type_id'] =
                        selectedOrderLine['line_type_id']?.toString() ?? '';
                    orderLines1[i + 1]!['item_id'] = '';

                    orderLines1[i + 1]!['itemName'] = '';
                    orderLines1[i + 1]!['item_main_code'] = '';
                    orderLines1[i + 1]!['item_discount'] = '0';
                    orderLines1[i + 1]!['item_description'] = '';
                    orderLines1[i + 1]!['item_quantity'] = '0';

                    orderLines1[i + 1]!['item_unit_price'] = '0';
                    orderLines1[i + 1]!['item_total'] = '0';
                    orderLines1[i + 1]!['title'] = '';
                    orderLines1[i + 1]!['note'] =
                        selectedOrderLine['note'] ?? '';
                    orderLines1[i + 1]!['combo'] = '';
                    // Add more fields as needed
                  }
                }

                String cashMethodId = '';
                String clientId = '';
                String pricelistId = '';
                String salespersonId = ' ';
                String commissionMethodId = '';
                String currencyId = ' ';

                if (widget.info['cashingMethod'] != null) {
                  cashMethodId = '${widget.info['cashingMethod']['id']}';
                }
                if (widget.info['commissionMethod'] != null) {
                  commissionMethodId =
                      '${widget.info['commissionMethod']['id']}';
                }
                if (widget.info['currency'] != null) {
                  currencyId = '${widget.info['currency']['id']}';
                }
                if (widget.info['client'] != null) {
                  clientId = widget.info['client']['id'].toString();
                } else {}
                if (widget.info['pricelist'] != null) {
                  pricelistId = widget.info['pricelist']['id'].toString();
                }
                if (widget.info['salesperson'] != null) {
                  salespersonId = widget.info['salesperson']['id'].toString();
                }

                var res = await updateQuotation(
                  '${widget.info['id']}',
                  // false,
                  '${widget.info['reference'] ?? ''}',
                  clientId,

                  '${widget.info['validity'] ?? ''}',
                  '${widget.info['inputDate'] ?? ''}',
                  '', //todo paymentTermsController.text,
                  pricelistId,
                  currencyId,
                  '${widget.info['termsAndConditions']}',
                  salespersonId,
                  commissionMethodId,
                  cashMethodId,
                  '${widget.info['commissionRate'] ?? ''}',
                  '${widget.info['commissionTotal'] ?? ''}',
                  '${widget.info['totalBeforeVat'] ?? '0.0'}', //total before vat
                  '${widget.info['specialDiscountAmount'] ?? '0'}', // inserted by user
                  '${widget.info['specialDiscount'] ?? '0'}', // calculated
                  '${widget.info['globalDiscountAmount'] ?? ''}',
                  '${widget.info['globalDiscount'] ?? ''}',
                  '${widget.info['vat'] ?? ''}', //vat
                  '${widget.info['vatLebanese'] ?? ''}',
                  '${widget.info['total'] ?? ''}',
                  '${widget.info['vatExempt'] ?? ''}',
                  '${widget.info['notPrinted'] ?? ''}',
                  '${widget.info['printedAsVatExempt'] ?? ''}',
                  '${widget.info['printedAsPercentage'] ?? ''}',
                  '${widget.info['vatInclusivePrices'] ?? ''}',
                  '${widget.info['beforeVatPrices'] ?? ''}',

                  '${widget.info['code'] ?? ''}',
                  widget.info['status'],

                  orderLines1,
                  orderedKeys,
                  '',
                  widget.info['deliveryTerms'] ?? '',
                  value,
                  widget.info['companyHeader'] != null ||
                          '${widget.info['companyHeader']}' != '[]'
                      ? '${widget.info['companyHeader']['id']}'
                      : '',
                );
                if (res['success'] == true) {
                  quotationController.getAllQuotationsFromBack();
                  homeController.selectedTab.value = "quotation_summary";
                  CommonWidgets.snackBar('Success', res['message']);
                } else {
                  CommonWidgets.snackBar('error', res['message']);
                }
              },
              // width:
              //     widget.isDesktop
              //         ? MediaQuery.of(context).size.width * 0.07
              //         : 150,
              width: widget.isDesktop ? 90.w : 150,
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
                  // width:
                  //     widget.isDesktop
                  //         ? MediaQuery.of(context).size.width * 0.07
                  //         : 150,
                  width: widget.isDesktop ? 90.w : 150,
                ),
              ),
            ),
            //
            // TableItem(
            //   text: numberWithComma('${widget.info['total'] ?? ''}'),
            //   width:
            //       widget.isDesktop
            //           ? MediaQuery.of(context).size.width * 0.07
            //           : 150,
            // ),
            SizedBox(
              // width:
              //     widget.isDesktop
              //         ? MediaQuery.of(context).size.width * 0.06
              //         : 150,
              width: widget.isDesktop ? 90.w : 150,
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
              text: ' ${widget.info['currency']['name'] ?? ''}',
              isCentered: false,
              // width:
              //     widget.isDesktop
              //         ? MediaQuery.of(context).size.width * 0.04
              //         : 150,
              width: widget.isDesktop ? 50.w : 150,
            ),
            SizedBox(
              width: widget.isDesktop ? 90.w : 150,
              // width: widget.isDesktop ? 90 : 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90.w,
                    // width: 90,
                    padding: EdgeInsets.symmetric(
                      horizontal: 1.w,
                      vertical: 2.h,
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
                      child: Tooltip(
                        message:
                            widget.info['status'] == 'cancelled'
                                ? widget.info['cancellationReason'] ?? ''
                                : '',
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
                ],
              ),
            ),
            GetBuilder<QuotationController>(
              builder: (cont) {
                return SizedBox(
                  width: widget.isDesktop ? 90.w : 150,
                  // widget.isDesktop
                  //     ? MediaQuery.of(context).size.width * 0.09
                  //     : 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Tooltip(
                        message: 'preview'.tr,
                        child: InkWell(
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
                            totalPriceAfterSpecialDiscountByQuotationCurrency =
                                0;
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
                                quotationItemInfo = {
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
                                  'combo_image': '',
                                  'combo_brand': '',
                                  'title': '',
                                  'isImageList': false,
                                  'note': '',
                                  'image': '',
                                };
                                itemsInfoPrint.add(quotationItemInfo);
                              } else if ('${item['line_type_id']}' == '3') {
                                var qty = item['combo_quantity'];
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
                                var combosmap =
                                    cont.combosMap[item['combo_id'].toString()];
                                var comboImage =
                                    '${combosmap['image']}' != '' &&
                                            combosmap['image'] != null &&
                                            combosmap['image'].isNotEmpty
                                        ? '${combosmap['image']}'
                                        : '';

                                var combobrand = combosmap['brand'] ?? '';
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
                                  'combo_image': comboImage,
                                  'combo_brand': combobrand,
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
                                  'combo_image': '',
                                  'combo_brand': '',
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
                                  'combo_image': '',
                                  'combo_brand': '',
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
                                  'combo_image': '',
                                  'combo_brand': '',
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
                                    header: widget.info['companyHeader'],
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
                                    cancellationReason:
                                        widget.info['cancellationReason'] ?? '',
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
                                    vat: widget.info['vat'] ?? '',
                                    fromPage: 'quotationSummary',
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
                            size: 22.sp,
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
                                    content: UpdateQuotationDialog(
                                      index: widget.index,
                                      info: deepCloneMap(widget.info),
                                      fromPage: 'quotationSummary',
                                    ),
                                  ),
                            );
                          },
                          child: Icon(
                            Icons.edit,
                            color: Primary.primary,
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // GetBuilder<QuotationController>(
            //   builder: (cont) {
            //     return SizedBox(
            //       width:
            //           widget.isDesktop
            //               ? MediaQuery.of(context).size.width * 0.07
            //               : 150,
            //       child: ReusableMore(
            //         itemsList: [
            //           PopupMenuItem<String>(
            //             value: '1',
            //             onTap: () async {
            //               itemsInfoPrint = [];
            //               quotationItemInfo = {};
            //               totalAllItems = 0;
            //               cont.totalAllItems = 0;
            //               totalAllItems = 0;
            //               cont.totalAllItems = 0;
            //               totalPriceAfterDiscount = 0;
            //               additionalSpecialDiscount = 0;
            //               totalPriceAfterSpecialDiscount = 0;
            //               totalPriceAfterSpecialDiscountByQuotationCurrency = 0;
            //               vatByQuotationCurrency = 0;
            //               vatByQuotationCurrency = 0;
            //               finalPriceByQuotationCurrency = 0;
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
            //                   quotationItemInfo = {
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
            //                   itemsInfoPrint.add(quotationItemInfo);
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
            //                   var quotationItemInfo = {
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
            //                   itemsInfoPrint.add(quotationItemInfo);
            //                 } else if ('${item['line_type_id']}' == '1') {
            //                   var quotationItemInfo = {
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
            //                   itemsInfoPrint.add(quotationItemInfo);
            //                 } else if ('${item['line_type_id']}' == '5') {
            //                   var quotationItemInfo = {
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
            //                   itemsInfoPrint.add(quotationItemInfo);
            //                 } else if ('${item['line_type_id']}' == '4') {
            //                   var quotationItemInfo = {
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
            //                   itemsInfoPrint.add(quotationItemInfo);
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
            //               totalPriceAfterSpecialDiscountByQuotationCurrency =
            //                   totalPriceAfterSpecialDiscount;
            //               vatByQuotationCurrency =
            //                   '${widget.info['vatExempt']}' == '1'
            //                       ? 0
            //                       : (totalPriceAfterSpecialDiscountByQuotationCurrency *
            //                               double.parse(
            //                                 await getCompanyVatFromPref(),
            //                               )) /
            //                           100;
            //               finalPriceByQuotationCurrency =
            //                   totalPriceAfterSpecialDiscountByQuotationCurrency +
            //                   vatByQuotationCurrency;
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (BuildContext context) {
            //                     // print('widget.info[ ${widget.info['termsAndConditions']}');
            //                     return PrintQuotationData(
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
            //                       isInQuotation: true,
            //                       quotationNumber:
            //                           widget.info['quotationNumber'] ?? '',
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
            //                       totalPriceAfterSpecialDiscountByQuotationCurrency:
            //                           formatDoubleWithCommas(
            //                             totalPriceAfterSpecialDiscountByQuotationCurrency,
            //                           ),
            //
            //                       vatByQuotationCurrency:
            //                           formatDoubleWithCommas(
            //                             vatByQuotationCurrency,
            //                           ),
            //                       finalPriceByQuotationCurrency:
            //                           formatDoubleWithCommas(
            //                             finalPriceByQuotationCurrency,
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
            //                       quotationCurrency:
            //                           widget.info['currency']['name'] ?? '',
            //                       quotationCurrencySymbol:
            //                           widget.info['currency']['symbol'] ?? '',
            //                       quotationCurrencyLatestRate:
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
            //                       content: UpdateQuotationDialog(
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
            //     );
            //   },
            // ),
            SizedBox(
              width: 30.w,
              // width: MediaQuery.of(context).size.width * 0.03,
              child: InkWell(
                onTap: () async {
                  var res = await deleteQuotation(
                    '${quotationController.quotationsList[widget.index]['id']}',
                  );
                  var p = json.decode(res.body);
                  if (res.statusCode == 200) {
                    quotationController.quotationsListCC = [];
                    quotationController.isQuotationsFetched = false;
                    quotationController.getAllQuotationsFromBack();
                    CommonWidgets.snackBar('Success', p['message']);
                  } else {
                    CommonWidgets.snackBar('error', p['message']);
                  }
                },
                child: Icon(
                  Icons.delete_outline,
                  color: Primary.primary,
                  size: 22.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class MobileQuotationSummary extends StatefulWidget {
//   const MobileQuotationSummary({super.key});
//
//   @override
//   State<MobileQuotationSummary> createState() => _MobileQuotationSummaryState();
// }
//
// class _MobileQuotationSummaryState extends State<MobileQuotationSummary> {
//   final TextEditingController filterController = TextEditingController();
//   TextEditingController searchController = TextEditingController();
//   double listViewLength = 100;
//   String selectedNumberOfRows = '10';
//   int selectedNumberOfRowsAsInt = 10;
//   int start = 1;
//   bool isArrowBackClicked = false;
//   bool isArrowForwardClicked = false;
//   final HomeController homeController = Get.find();
//   bool isNumberOrderedUp = true;
//   bool isCreationOrderedUp = true;
//   bool isCustomerOrderedUp = true;
//   bool isSalespersonOrderedUp = true;
//   getAllQuotationsFromBack() async {
//     var p = await getAllQuotationsWithoutPending('');
//     setState(() {
//       quotationsList.addAll(p);
//       isQuotationsFetched = true;
//       listViewLength =
//           quotationsList.length < 10
//               ? Sizes.deviceHeight * (0.09 * quotationsList.length)
//               : Sizes.deviceHeight * (0.09 * 10);
//     });
//   }
//
//   List quotationsList = [];
//   bool isQuotationsFetched = false;
//
//   TaskController taskController = Get.find();
//   int selectedTabIndex = 0;
//   List tabsList = ['all_quotations', 'tasks'];
//   String searchValueInTasks = '';
//   Timer? searchOnStoppedTypingInTasks;
//
//   _onChangeTaskSearchHandler(value) {
//     const duration = Duration(
//       milliseconds: 800,
//     ); // set the duration that you want call search() after that.
//     if (searchOnStoppedTypingInTasks != null) {
//       setState(() => searchOnStoppedTypingInTasks!.cancel()); // clear timer
//     }
//     setState(
//       () =>
//           searchOnStoppedTypingInTasks = Timer(
//             duration,
//             () => searchOnTask(value),
//           ),
//     );
//   }
//
//   searchOnTask(value) async {
//     setState(() {
//       searchValueInTasks = value;
//     });
//     await taskController.getAllTasksFromBack(value);
//   }
//
//   @override
//   void initState() {
//     // listViewLength = quotationsList.length < 10
//     //     ? Sizes.deviceHeight * (0.09 * quotationsList.length)
//     //     : Sizes.deviceHeight * (0.09 * 10);
//     getAllQuotationsFromBack();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: MediaQuery.of(context).size.width * 0.02,
//       ),
//       height: MediaQuery.of(context).size.height * 0.8,
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             PageTitle(text: 'quotations'.tr),
//             gapH10,
//             ReusableButtonWithColor(
//               width: MediaQuery.of(context).size.width * 0.4,
//               height: 45,
//               onTapFunction: () {
//                 homeController.selectedTab.value = 'new_quotation';
//               },
//               btnText: 'create_new_quotation'.tr,
//             ),
//             gapH10,
//             SizedBox(
//               // width: MediaQuery.of(context).size.width * 0.59,
//               child: ReusableSearchTextField(
//                 hint: '${"search".tr}...',
//                 textEditingController:
//                     selectedTabIndex == 0
//                         ? searchController
//                         : taskController.searchInTasksController,
//                 onChangedFunc: (value) {
//                   if (selectedTabIndex == 1) {
//                     _onChangeTaskSearchHandler(value);
//                   }
//                 },
//                 validationFunc: () {},
//               ),
//             ),
//             gapH24,
//             // ReusableChip(
//             //   name: 'all_quotations'.tr,
//             //   isDesktop: false,
//             // ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Wrap(
//                   spacing: 0.0,
//                   direction: Axis.horizontal,
//                   children:
//                       tabsList
//                           .map(
//                             (element) => ReusableBuildTabChipItem(
//                               index: tabsList.indexOf(element),
//                               function: () {
//                                 setState(() {
//                                   selectedTabIndex = tabsList.indexOf(element);
//                                 });
//                               },
//                               isClicked:
//                                   selectedTabIndex == tabsList.indexOf(element),
//                               name: element,
//                             ),
//                           )
//                           .toList(),
//                 ),
//               ],
//             ),
//             selectedTabIndex == 0
//                 ? SizedBox(
//                   height: listViewLength + 150,
//                   child: SingleChildScrollView(
//                     child: Row(
//                       children: [
//                         Flexible(
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 5,
//                                     vertical: 15,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Primary.primary,
//                                     borderRadius: const BorderRadius.all(
//                                       Radius.circular(6),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       tableTitleWithOrderArrow(
//                                         'number'.tr,
//                                         150,
//                                         () {
//                                           setState(() {
//                                             isNumberOrderedUp =
//                                                 !isNumberOrderedUp;
//                                             isNumberOrderedUp
//                                                 ? quotationsList.sort(
//                                                   (a, b) => a['quotationNumber']
//                                                       .compareTo(
//                                                         b['quotationNumber'],
//                                                       ),
//                                                 )
//                                                 : quotationsList.sort(
//                                                   (a, b) => b['quotationNumber']
//                                                       .compareTo(
//                                                         a['quotationNumber'],
//                                                       ),
//                                                 );
//                                           });
//                                         },
//                                       ),
//                                       tableTitleWithOrderArrow(
//                                         'creation'.tr,
//                                         150,
//                                         () {
//                                           setState(() {
//                                             isCreationOrderedUp =
//                                                 !isCreationOrderedUp;
//                                             isCreationOrderedUp
//                                                 ? quotationsList.sort(
//                                                   (a, b) => a['createdAtDate']
//                                                       .compareTo(
//                                                         b['createdAtDate'],
//                                                       ),
//                                                 )
//                                                 : quotationsList.sort(
//                                                   (a, b) => b['createdAtDate']
//                                                       .compareTo(
//                                                         a['createdAtDate'],
//                                                       ),
//                                                 );
//                                           });
//                                         },
//                                       ),
//                                       tableTitleWithOrderArrow(
//                                         'customer'.tr,
//                                         150,
//                                         () {
//                                           setState(() {
//                                             isCustomerOrderedUp =
//                                                 !isCustomerOrderedUp;
//                                             isCustomerOrderedUp
//                                                 ? quotationsList.sort(
//                                                   (
//                                                     a,
//                                                     b,
//                                                   ) => '${a['client']['name']}'
//                                                       .compareTo(
//                                                         '${b['client']['name']}',
//                                                       ),
//                                                 )
//                                                 : quotationsList.sort(
//                                                   (
//                                                     a,
//                                                     b,
//                                                   ) => '${b['client']['name']}'
//                                                       .compareTo(
//                                                         '${a['client']['name']}',
//                                                       ),
//                                                 );
//                                           });
//                                         },
//                                       ),
//                                       tableTitleWithOrderArrow(
//                                         'salesperson'.tr,
//                                         150,
//                                         () {
//                                           setState(() {
//                                             isSalespersonOrderedUp =
//                                                 !isSalespersonOrderedUp;
//                                             isSalespersonOrderedUp
//                                                 ? quotationsList.sort(
//                                                   (a, b) => a['salesperson']
//                                                       .compareTo(
//                                                         b['salesperson'],
//                                                       ),
//                                                 )
//                                                 : quotationsList.sort(
//                                                   (a, b) => b['salesperson']
//                                                       .compareTo(
//                                                         a['salesperson'],
//                                                       ),
//                                                 );
//                                           });
//                                         },
//                                       ),
//                                       TableTitle(text: 'task'.tr, width: 150),
//                                       TableTitle(text: 'total'.tr, width: 150),
//                                       TableTitle(text: 'status'.tr, width: 150),
//                                       TableTitle(
//                                         text: 'more_options'.tr,
//                                         width: 100,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 isQuotationsFetched
//                                     ? Container(
//                                       color: Colors.white,
//                                       child: Column(
//                                         children: List.generate(
//                                           quotationsList.length > 9
//                                               ? selectedNumberOfRowsAsInt
//                                               : quotationsList.length,
//                                           (index) => Column(
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   QuotationAsRowInTable(
//                                                     info: quotationsList[index],
//                                                     index: index,
//                                                     isDesktop: false,
//                                                   ),
//                                                   SizedBox(
//                                                     width: 100,
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceEvenly,
//                                                       children: [
//                                                         SizedBox(
//                                                           width:
//                                                               MediaQuery.of(
//                                                                 context,
//                                                               ).size.width *
//                                                               0.03,
//                                                           child:
//                                                               const ReusableMore(
//                                                                 itemsList: [],
//                                                               ),
//                                                         ),
//                                                         SizedBox(
//                                                           width:
//                                                               MediaQuery.of(
//                                                                 context,
//                                                               ).size.width *
//                                                               0.03,
//                                                           child: InkWell(
//                                                             onTap: () async {
//                                                               var res =
//                                                                   await deleteQuotation(
//                                                                     '${quotationsList[index]['id']}',
//                                                                   );
//                                                               var p = json
//                                                                   .decode(
//                                                                     res.body,
//                                                                   );
//                                                               if (res.statusCode ==
//                                                                   200) {
//                                                                 CommonWidgets.snackBar(
//                                                                   'Success',
//                                                                   p['message'],
//                                                                 );
//                                                                 setState(() {
//                                                                   selectedNumberOfRowsAsInt =
//                                                                       selectedNumberOfRowsAsInt -
//                                                                       1;
//                                                                   quotationsList
//                                                                       .removeAt(
//                                                                         index,
//                                                                       );
//                                                                   listViewLength =
//                                                                       listViewLength -
//                                                                       0.09;
//                                                                 });
//                                                               } else {
//                                                                 CommonWidgets.snackBar(
//                                                                   'error',
//                                                                   p['message'],
//                                                                 );
//                                                               }
//                                                             },
//                                                             child: Icon(
//                                                               Icons
//                                                                   .delete_outline,
//                                                               color:
//                                                                   Primary
//                                                                       .primary,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               const Divider(),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                                     : const CircularProgressIndicator(),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       '${'rows_per_page'.tr}:  ',
//                                       style: const TextStyle(
//                                         fontSize: 13,
//                                         color: Colors.black54,
//                                       ),
//                                     ),
//                                     Container(
//                                       width: 60,
//                                       height: 30,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(6),
//                                         border: Border.all(
//                                           color: Colors.black,
//                                           width: 2,
//                                         ),
//                                       ),
//                                       child: Center(
//                                         child: DropdownButtonHideUnderline(
//                                           child: DropdownButton<String>(
//                                             borderRadius: BorderRadius.circular(
//                                               0,
//                                             ),
//                                             items:
//                                                 [
//                                                   '10',
//                                                   '20',
//                                                   '50',
//                                                   'all'.tr,
//                                                 ].map((String value) {
//                                                   return DropdownMenuItem<
//                                                     String
//                                                   >(
//                                                     value: value,
//                                                     child: Text(
//                                                       value,
//                                                       style: const TextStyle(
//                                                         fontSize: 12,
//                                                         color: Colors.grey,
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }).toList(),
//                                             value: selectedNumberOfRows,
//                                             onChanged: (val) {
//                                               setState(() {
//                                                 selectedNumberOfRows = val!;
//                                                 if (val == '10') {
//                                                   listViewLength =
//                                                       quotationsList.length < 10
//                                                           ? Sizes.deviceHeight *
//                                                               (0.09 *
//                                                                   quotationsList
//                                                                       .length)
//                                                           : Sizes.deviceHeight *
//                                                               (0.09 * 10);
//                                                   selectedNumberOfRowsAsInt =
//                                                       quotationsList.length < 10
//                                                           ? quotationsList
//                                                               .length
//                                                           : 10;
//                                                 }
//                                                 if (val == '20') {
//                                                   listViewLength =
//                                                       quotationsList.length < 20
//                                                           ? Sizes.deviceHeight *
//                                                               (0.09 *
//                                                                   quotationsList
//                                                                       .length)
//                                                           : Sizes.deviceHeight *
//                                                               (0.09 * 20);
//                                                   selectedNumberOfRowsAsInt =
//                                                       quotationsList.length < 20
//                                                           ? quotationsList
//                                                               .length
//                                                           : 20;
//                                                 }
//                                                 if (val == '50') {
//                                                   listViewLength =
//                                                       quotationsList.length < 50
//                                                           ? Sizes.deviceHeight *
//                                                               (0.09 *
//                                                                   quotationsList
//                                                                       .length)
//                                                           : Sizes.deviceHeight *
//                                                               (0.09 * 50);
//                                                   selectedNumberOfRowsAsInt =
//                                                       quotationsList.length < 50
//                                                           ? quotationsList
//                                                               .length
//                                                           : 50;
//                                                 }
//                                                 if (val == 'all'.tr) {
//                                                   listViewLength =
//                                                       Sizes.deviceHeight *
//                                                       (0.09 *
//                                                           quotationsList
//                                                               .length);
//                                                   selectedNumberOfRowsAsInt =
//                                                       quotationsList.length;
//                                                 }
//                                               });
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     gapW16,
//                                     Text(
//                                       selectedNumberOfRows == 'all'.tr
//                                           ? '${'all'.tr} of ${quotationsList.length}'
//                                           : '$start-$selectedNumberOfRows of ${quotationsList.length}',
//                                       style: const TextStyle(
//                                         fontSize: 13,
//                                         color: Colors.black54,
//                                       ),
//                                     ),
//                                     gapW16,
//                                     InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           isArrowBackClicked =
//                                               !isArrowBackClicked;
//                                           isArrowForwardClicked = false;
//                                         });
//                                       },
//                                       child: Row(
//                                         children: [
//                                           Icon(
//                                             Icons.skip_previous,
//                                             color:
//                                                 isArrowBackClicked
//                                                     ? Colors.black87
//                                                     : Colors.grey,
//                                           ),
//                                           Icon(
//                                             Icons.navigate_before,
//                                             color:
//                                                 isArrowBackClicked
//                                                     ? Colors.black87
//                                                     : Colors.grey,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     gapW10,
//                                     InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           isArrowForwardClicked =
//                                               !isArrowForwardClicked;
//                                           isArrowBackClicked = false;
//                                         });
//                                       },
//                                       child: Row(
//                                         children: [
//                                           Icon(
//                                             Icons.navigate_next,
//                                             color:
//                                                 isArrowForwardClicked
//                                                     ? Colors.black87
//                                                     : Colors.grey,
//                                           ),
//                                           Icon(
//                                             Icons.skip_next,
//                                             color:
//                                                 isArrowForwardClicked
//                                                     ? Colors.black87
//                                                     : Colors.grey,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     gapW40,
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//                 : const Tasks(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String hoverTitle = '';
//   String clickedTitle = '';
//   bool isClicked = false;
//   tableTitleWithOrderArrow(String text, double width, Function onClickedFunc) {
//     return SizedBox(
//       width: width,
//       child: Center(
//         child: InkWell(
//           onTap: () {
//             setState(() {
//               clickedTitle = text;
//               hoverTitle = '';
//               isClicked = !isClicked;
//               onClickedFunc();
//             });
//           },
//           onHover: (val) {
//             if (val) {
//               setState(() {
//                 hoverTitle = text;
//               });
//             } else {
//               setState(() {
//                 hoverTitle = '';
//               });
//             }
//           },
//           child:
//               clickedTitle == text
//                   ? Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         text,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       isClicked
//                           ? const Icon(
//                             Icons.arrow_drop_down,
//                             color: Colors.white,
//                           )
//                           : const Icon(
//                             Icons.arrow_drop_up,
//                             color: Colors.white,
//                           ),
//                     ],
//                   )
//                   : hoverTitle == text
//                   ? Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         '$text...',
//                         style: TextStyle(
//                           color: Colors.white.withAlpha((0.5 * 255).toInt()),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Icon(
//                         Icons.arrow_drop_down,
//                         color: Colors.white.withAlpha((0.5 * 255).toInt()),
//                       ),
//                     ],
//                   )
//                   : Text(
//                     text,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//         ),
//       ),
//     );
//   }
// }
