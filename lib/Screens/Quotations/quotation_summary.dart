import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/Quotations/update_quotation.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Controllers/task_controller.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/create_product_dialog.dart';
import 'package:rooster_app/Screens/Quotations/create_client_dialog.dart';
import 'package:rooster_app/Screens/Quotations/print_quotation.dart';
import 'package:rooster_app/Screens/Quotations/schedule_task_dialog.dart';
import 'package:rooster_app/Screens/Quotations/tasks.dart';
import 'package:rooster_app/Widgets/TransferWidgets/reusable_show_info_card.dart';
import 'package:rooster_app/Widgets/dialog_drop_menu.dart';
import 'package:rooster_app/Widgets/reusable_add_card.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import '../../Backend/Quotations/delete_quotation.dart';
import '../../Backend/Quotations/get_quotations.dart';
import '../../Controllers/home_controller.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_drop_down_menu.dart';
import '../../Widgets/reusable_more.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../../const/constants.dart';
import '../../const/functions.dart';
import '../../const/urls.dart';
import '../Combo/combo.dart';
import 'create_new_quotation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

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
    quotationController.setLogo(imageBytes);
  }
  @override
  void initState() {
    generatePdfFromImageUrl();
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
                              SizedBox(width: MediaQuery.of(context).size.width * 0.03,)
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
                                itemBuilder:
                                    (context, index) => Column(
                                      children: [
                                        QuotationAsRowInTable(
                                          info: cont.quotationsList[index],
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
      onDoubleTap: () {
        if (widget.info['status'] == 'pending') {
          homeController.selectedTab.value = 'quotation_data';
        } else {
          homeController.selectedTab.value = 'quotation_summary';
        }
        quotationController.setSelectedQuotation(widget.info);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
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
                                'line_type_id':'2',
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
                                'isImageList':false,
                                'note': '',
                                'image':''
                              };
                              itemsInfoPrint.add(quotationItemInfo);
                            }    else if ('${item['line_type_id']}' == '3') {
                              var qty = item['item_quantity'];
                              // var map =
                              // cont
                              //     .combosMap[item['combo_id']
                              //     .toString()];
                              var ind=cont
                                  .combosIdsList.indexOf(item['combo_id']
                                  .toString());
                              var itemName = cont.combosNamesList[ind];
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
                                'isImageList':false,
                                'image':''
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
                              totalPriceAfterSpecialDiscount ;
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
                                  widget.info['client']!=null?  widget.info['client']['phoneNumber']??
                                      '---':"---" ,
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
                      PopupMenuItem<String>(
                        value: '2',
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
                                    info: widget.info,
                                  ),
                                ),
                          );
                        },
                        child: Text('Update'.tr),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.03,
              child: InkWell(
                onTap: () async {
                  var res = await deleteQuotation(
                    '${quotationController.quotationsList[widget.index]['id']}',
                  );
                  var p = json.decode(res.body);
                  if (res.statusCode == 200) {
                    CommonWidgets.snackBar('Success', p['message']);
                    quotationController.getAllQuotationsFromBack();
                  } else {
                    CommonWidgets.snackBar('error', p['message']);
                  }
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

class MobileQuotationSummary extends StatefulWidget {
  const MobileQuotationSummary({super.key});

  @override
  State<MobileQuotationSummary> createState() => _MobileQuotationSummaryState();
}

class _MobileQuotationSummaryState extends State<MobileQuotationSummary> {
  final TextEditingController filterController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  double listViewLength = 100;
  String selectedNumberOfRows = '10';
  int selectedNumberOfRowsAsInt = 10;
  int start = 1;
  bool isArrowBackClicked = false;
  bool isArrowForwardClicked = false;
  final HomeController homeController = Get.find();
  bool isNumberOrderedUp = true;
  bool isCreationOrderedUp = true;
  bool isCustomerOrderedUp = true;
  bool isSalespersonOrderedUp = true;
  getAllQuotationsFromBack() async {
    var p = await getAllQuotations();
    setState(() {
      quotationsList.addAll(p);
      isQuotationsFetched = true;
      listViewLength =
          quotationsList.length < 10
              ? Sizes.deviceHeight * (0.09 * quotationsList.length)
              : Sizes.deviceHeight * (0.09 * 10);
    });
  }

  List quotationsList = [];
  bool isQuotationsFetched = false;

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
    // listViewLength = quotationsList.length < 10
    //     ? Sizes.deviceHeight * (0.09 * quotationsList.length)
    //     : Sizes.deviceHeight * (0.09 * 10);
    getAllQuotationsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(text: 'quotations'.tr),
            gapH10,
            ReusableButtonWithColor(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 45,
              onTapFunction: () {
                homeController.selectedTab.value = 'new_quotation';
              },
              btnText: 'create_new_quotation'.tr,
            ),
            gapH10,
            SizedBox(
              // width: MediaQuery.of(context).size.width * 0.59,
              child: ReusableSearchTextField(
                hint: '${"search".tr}...',
                textEditingController:
                    selectedTabIndex == 0
                        ? searchController
                        : taskController.searchInTasksController,
                onChangedFunc: (value) {
                  if (selectedTabIndex == 1) {
                    _onChangeTaskSearchHandler(value);
                  }
                },
                validationFunc: () {},
              ),
            ),
            gapH24,
            // ReusableChip(
            //   name: 'all_quotations'.tr,
            //   isDesktop: false,
            // ),
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
                                  selectedTabIndex = tabsList.indexOf(element);
                                });
                              },
                              isClicked:
                                  selectedTabIndex == tabsList.indexOf(element),
                              name: element,
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
            selectedTabIndex == 0
                ? SizedBox(
                  height: listViewLength + 150,
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
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
                                    children: [
                                      tableTitleWithOrderArrow(
                                        'number'.tr,
                                        150,
                                        () {
                                          setState(() {
                                            isNumberOrderedUp =
                                                !isNumberOrderedUp;
                                            isNumberOrderedUp
                                                ? quotationsList.sort(
                                                  (a, b) => a['quotationNumber']
                                                      .compareTo(
                                                        b['quotationNumber'],
                                                      ),
                                                )
                                                : quotationsList.sort(
                                                  (a, b) => b['quotationNumber']
                                                      .compareTo(
                                                        a['quotationNumber'],
                                                      ),
                                                );
                                          });
                                        },
                                      ),
                                      tableTitleWithOrderArrow(
                                        'creation'.tr,
                                        150,
                                        () {
                                          setState(() {
                                            isCreationOrderedUp =
                                                !isCreationOrderedUp;
                                            isCreationOrderedUp
                                                ? quotationsList.sort(
                                                  (a, b) => a['createdAtDate']
                                                      .compareTo(
                                                        b['createdAtDate'],
                                                      ),
                                                )
                                                : quotationsList.sort(
                                                  (a, b) => b['createdAtDate']
                                                      .compareTo(
                                                        a['createdAtDate'],
                                                      ),
                                                );
                                          });
                                        },
                                      ),
                                      tableTitleWithOrderArrow(
                                        'customer'.tr,
                                        150,
                                        () {
                                          setState(() {
                                            isCustomerOrderedUp =
                                                !isCustomerOrderedUp;
                                            isCustomerOrderedUp
                                                ? quotationsList.sort(
                                                  (
                                                    a,
                                                    b,
                                                  ) => '${a['client']['name']}'
                                                      .compareTo(
                                                        '${b['client']['name']}',
                                                      ),
                                                )
                                                : quotationsList.sort(
                                                  (
                                                    a,
                                                    b,
                                                  ) => '${b['client']['name']}'
                                                      .compareTo(
                                                        '${a['client']['name']}',
                                                      ),
                                                );
                                          });
                                        },
                                      ),
                                      tableTitleWithOrderArrow(
                                        'salesperson'.tr,
                                        150,
                                        () {
                                          setState(() {
                                            isSalespersonOrderedUp =
                                                !isSalespersonOrderedUp;
                                            isSalespersonOrderedUp
                                                ? quotationsList.sort(
                                                  (a, b) => a['salesperson']
                                                      .compareTo(
                                                        b['salesperson'],
                                                      ),
                                                )
                                                : quotationsList.sort(
                                                  (a, b) => b['salesperson']
                                                      .compareTo(
                                                        a['salesperson'],
                                                      ),
                                                );
                                          });
                                        },
                                      ),
                                      TableTitle(text: 'task'.tr, width: 150),
                                      TableTitle(text: 'total'.tr, width: 150),
                                      TableTitle(text: 'status'.tr, width: 150),
                                      TableTitle(
                                        text: 'more_options'.tr,
                                        width: 100,
                                      ),
                                    ],
                                  ),
                                ),
                                isQuotationsFetched
                                    ? Container(
                                      color: Colors.white,
                                      child: Column(
                                        children: List.generate(
                                          quotationsList.length > 9
                                              ? selectedNumberOfRowsAsInt
                                              : quotationsList.length,
                                          (index) => Column(
                                            children: [
                                              Row(
                                                children: [
                                                  QuotationAsRowInTable(
                                                    info: quotationsList[index],
                                                    index: index,
                                                    isDesktop: false,
                                                  ),
                                                  SizedBox(
                                                    width: 100,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.03,
                                                          child:
                                                              const ReusableMore(
                                                                itemsList: [],
                                                              ),
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.03,
                                                          child: InkWell(
                                                            onTap: () async {
                                                              var res =
                                                                  await deleteQuotation(
                                                                    '${quotationsList[index]['id']}',
                                                                  );
                                                              var p = json
                                                                  .decode(
                                                                    res.body,
                                                                  );
                                                              if (res.statusCode ==
                                                                  200) {
                                                                CommonWidgets.snackBar(
                                                                  'Success',
                                                                  p['message'],
                                                                );
                                                                setState(() {
                                                                  selectedNumberOfRowsAsInt =
                                                                      selectedNumberOfRowsAsInt -
                                                                      1;
                                                                  quotationsList
                                                                      .removeAt(
                                                                        index,
                                                                      );
                                                                  listViewLength =
                                                                      listViewLength -
                                                                      0.09;
                                                                });
                                                              } else {
                                                                CommonWidgets.snackBar(
                                                                  'error',
                                                                  p['message'],
                                                                );
                                                              }
                                                            },
                                                            child: Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              color:
                                                                  Primary
                                                                      .primary,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Divider(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    : const CircularProgressIndicator(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${'rows_per_page'.tr}:  ',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                            items:
                                                [
                                                  '10',
                                                  '20',
                                                  '50',
                                                  'all'.tr,
                                                ].map((String value) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                            value: selectedNumberOfRows,
                                            onChanged: (val) {
                                              setState(() {
                                                selectedNumberOfRows = val!;
                                                if (val == '10') {
                                                  listViewLength =
                                                      quotationsList.length < 10
                                                          ? Sizes.deviceHeight *
                                                              (0.09 *
                                                                  quotationsList
                                                                      .length)
                                                          : Sizes.deviceHeight *
                                                              (0.09 * 10);
                                                  selectedNumberOfRowsAsInt =
                                                      quotationsList.length < 10
                                                          ? quotationsList
                                                              .length
                                                          : 10;
                                                }
                                                if (val == '20') {
                                                  listViewLength =
                                                      quotationsList.length < 20
                                                          ? Sizes.deviceHeight *
                                                              (0.09 *
                                                                  quotationsList
                                                                      .length)
                                                          : Sizes.deviceHeight *
                                                              (0.09 * 20);
                                                  selectedNumberOfRowsAsInt =
                                                      quotationsList.length < 20
                                                          ? quotationsList
                                                              .length
                                                          : 20;
                                                }
                                                if (val == '50') {
                                                  listViewLength =
                                                      quotationsList.length < 50
                                                          ? Sizes.deviceHeight *
                                                              (0.09 *
                                                                  quotationsList
                                                                      .length)
                                                          : Sizes.deviceHeight *
                                                              (0.09 * 50);
                                                  selectedNumberOfRowsAsInt =
                                                      quotationsList.length < 50
                                                          ? quotationsList
                                                              .length
                                                          : 50;
                                                }
                                                if (val == 'all'.tr) {
                                                  listViewLength =
                                                      Sizes.deviceHeight *
                                                      (0.09 *
                                                          quotationsList
                                                              .length);
                                                  selectedNumberOfRowsAsInt =
                                                      quotationsList.length;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    gapW16,
                                    Text(
                                      selectedNumberOfRows == 'all'.tr
                                          ? '${'all'.tr} of ${quotationsList.length}'
                                          : '$start-$selectedNumberOfRows of ${quotationsList.length}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    gapW16,
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          isArrowBackClicked =
                                              !isArrowBackClicked;
                                          isArrowForwardClicked = false;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.skip_previous,
                                            color:
                                                isArrowBackClicked
                                                    ? Colors.black87
                                                    : Colors.grey,
                                          ),
                                          Icon(
                                            Icons.navigate_before,
                                            color:
                                                isArrowBackClicked
                                                    ? Colors.black87
                                                    : Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                    gapW10,
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          isArrowForwardClicked =
                                              !isArrowForwardClicked;
                                          isArrowBackClicked = false;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.navigate_next,
                                            color:
                                                isArrowForwardClicked
                                                    ? Colors.black87
                                                    : Colors.grey,
                                          ),
                                          Icon(
                                            Icons.skip_next,
                                            color:
                                                isArrowForwardClicked
                                                    ? Colors.black87
                                                    : Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                    gapW40,
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : const Tasks(),
          ],
        ),
      ),
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
                        text,
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
                        '$text...',
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

class UpdateQuotationDialog extends StatefulWidget {
  const UpdateQuotationDialog({
    super.key,
    required this.index,
    required this.info,
  });
  final int index;
  final Map info;

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
  final QuotationController quotationController = Get.find();

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
  int quotationCounter = 0;
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
    if(companySubjectToVat=='1'){
      vatExemptController.clear();
      quotationController.setIsVatExempted(false, false,false);
      quotationController.setIsVatExemptCheckBoxShouldAppear(true);
    }else{
      quotationController.setIsVatExemptCheckBoxShouldAppear(false);
      quotationController.setIsVatExempted(false, false,true);
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
    checkVatExempt();
    getCurrency();
    quotationController.orderLinesQuotationList = {};
    quotationController.rowsInListViewInQuotation = {};
    // print(widget.info);
    if (widget.info['cashingMethod'] != null) {
      cashingMethodsController.text = '${widget.info['cashingMethod']['title'] ?? ''}';
      quotationController.selectedCashingMethodId = '${widget.info['cashingMethod']['id']}';
    }
    if (widget.info['pricelist'] != null) {
      priceListController.text = '${widget.info['pricelist']['code'] ?? ''}';
      quotationController.selectedPriceListId = '${widget.info['pricelist']['id']}';
    }else{
      priceListController.text='STANDARD';
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
    currencyController.text = widget.info['currency']['name'] ?? '';
    termsAndConditionsController.text = widget.info['termsAndConditions'] ?? '[{"insert":"\n"}]';
    _savedContent=widget.info['termsAndConditions'] ?? '[{"insert":"\n"}]';
    _loadContent();

    globalDiscPercentController.text =
        widget.info['globalDiscount'] ?? ''; // entered by user
    specialDiscPercentController.text =
        widget.info['specialDiscount'] ?? ''; //entered by user
    quotationController.globalDisc = widget.info['globalDiscountAmount'] ?? '';
    quotationController.specialDisc =
        widget.info['specialDiscountAmount'] ?? '';
    quotationController.totalItems = double.parse(
      '${widget.info['totalBeforeVat'] ?? '0.0'}',
    );
    // print('isVatZero $isVatZero');
    quotationController.vat11 = quotationController.isVatExemptChecked ? '0' : '${widget.info['vat'] ?? ''}';
    quotationController.vatInPrimaryCurrency =
    quotationController.isVatExemptChecked ? '0' : '${widget.info['vatLebanese'] ?? ''}';

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
    }
    var keys = quotationController.rowsInListViewInQuotation.keys.toList();

    for (int i = 0; i < widget.info['orderLines'].length; i++) {
      if (widget.info['orderLines'][i]['line_type_id'] == 2) {
        quotationController.unitPriceControllers[i + 1] =
            TextEditingController();
        Widget p = ReusableItemRow(
          index: i + 1,
          info: quotationController.rowsInListViewInQuotation[keys[i]],
        );

        quotationController.orderLinesQuotationList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 1) {
        Widget p = ReusableTitleRow(
          index: i + 1,
          info: quotationController.rowsInListViewInQuotation[keys[i]],
        );
        quotationController.orderLinesQuotationList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 5) {
        Widget p = ReusableNoteRow(
          index: i + 1,
          info: quotationController.rowsInListViewInQuotation[keys[i]],
        );
        quotationController.orderLinesQuotationList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 4) {
        Widget p = ReusableImageRow(
          index: i + 1,
          info: quotationController.rowsInListViewInQuotation[keys[i]],
        );
        quotationController.orderLinesQuotationList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 3){
        quotationController.combosPriceControllers[i + 1] =
            TextEditingController();
        Widget p = ReusableComboRow(
          index: i + 1,
          info: quotationController.rowsInListViewInQuotation[keys[i]],
        );
        quotationController.orderLinesQuotationList['${i + 1}'] = p;
      }
    }
    quotationCounter = quotationController.rowsInListViewInQuotation.length;
    quotationController.listViewLengthInQuotation =
        quotationController.orderLinesQuotationList.length * 60;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuotationController>(
      builder: (quotationCont) {
        var keysList = quotationCont.orderLinesQuotationList.keys.toList();
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
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Pricelist'.tr),
                                  DropdownMenu<String>(
                                    width:
                                    MediaQuery.of(
                                      context,
                                    ).size.width *
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
                                    quotationCont.priceListsCodes.map<
                                        DropdownMenuEntry<String>
                                    >((String option) {
                                      return DropdownMenuEntry<
                                          String
                                      >(value: option, label: option);
                                    }).toList(),
                                    enableFilter: true,
                                    onSelected: (String? val) {
                                      var index = quotationCont.priceListsCodes
                                          .indexOf(val!);
                                      quotationCont.setSelectedPriceListId(quotationCont.priceListsIds[index]);
                                      setState(() {
                                        quotationCont.resetItemsAfterChangePriceList();
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        gapH10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('price'.tr,style:quotationCont.isVatExemptChecked ? TextStyle(
                                      color:Others.divider
                                  ):TextStyle(),),
                                  GetBuilder<ExchangeRatesController>(
                                    builder: (cont) {
                                      return DropdownMenu<String>(
                                        enabled: !quotationCont.isVatExemptChecked,
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
                                              color:Others.divider,
                                              width: 1,
                                            ),
                                            borderRadius:
                                            const BorderRadius.all(
                                              Radius.circular(9),
                                            ),),
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
                                                priceConditionController.text='Prices are before vat';
                                                quotationCont.setIsBeforeVatPrices(true);
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
                                    optionsList: quotationCont.cashingMethodsNamesList,
                                    text: 'cashing_method'.tr,
                                    hint: '',
                                    rowWidth:
                                        MediaQuery.of(context).size.width * 0.3,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width *
                                        0.15,
                                    onSelected: (value) {
                                      var index=quotationCont.cashingMethodsNamesList.indexOf(value);
                                      quotationCont.setSelectedCashingMethodId(quotationCont.cashingMethodsIdsList[index]);
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
                          var oldKeys =
                              quotationController.rowsInListViewInQuotation.keys
                                  .toList()
                                ..sort();
                          for (int i = 0; i < oldKeys.length; i++) {
                            quotationController.newRowMap[i + 1] =
                                quotationController
                                    .rowsInListViewInQuotation[oldKeys[i]]!;
                          }
                          if (_formKey.currentState!.validate()) {
                            _saveContent();
                            var res = await updateQuotation(
                              '${widget.info['id']}',

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
                              'pending', // status,
                              // quotationController.rowsInListViewInQuotation,
                              quotationController.newRowMap,
                            );
                            if (res['success'] == true) {
                              Get.back();
                              quotationController.getAllQuotationsFromBack();
                              // homeController.selectedTab.value = 'new_quotation';
                              homeController.selectedTab.value =
                                  'quotation_summary';
                              CommonWidgets.snackBar('Success', res['message']);
                            } else {
                              CommonWidgets.snackBar('error', res['message']);
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
    });
    Widget p = ReusableTitleRow(index: quotationCounter, info: {});
    quotationController.addToOrderLinesInQuotationList('$quotationCounter', p);
  }
  // int quotationCounter = 0;

  addNewItem() {
    setState(() {
      quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
    );
    quotationController.addToRowsInListViewInQuotation(quotationCounter, {
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
    quotationController.addToUnitPriceControllers(quotationCounter);
    Widget p = ReusableItemRow(index: quotationCounter, info: {});
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
      'item_quantity': '1',
      'item_unit_price': '0',
      'item_total': '0',
      'title': '',
      'note': '',
      'combo': '',
    });
    quotationController.addToCombosPricesControllers(quotationCounter);
    Widget p =  ReusableComboRow(index: quotationCounter, info: {});
    quotationController.addToOrderLinesInQuotationList('$quotationCounter', p);
  }

  addNewImage() {
    setState(() {
      quotationCounter += 1;
    });
    quotationController.incrementListViewLengthInQuotation(
      quotationController.increment,
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
      'image': Uint8List(0),
    });

    Widget p = ReusableImageRow(index: quotationCounter, info: {});

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
    });

    Widget p = ReusableNoteRow(index: quotationCounter, info: {});

    quotationController.addToOrderLinesInQuotationList('$quotationCounter', p);

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
        '${widget.info['item_unit_price'] ?? ''}';
    selectedItemId = widget.info['item_id'].toString();
    if (quotationController.itemsPricesCurrencies[selectedItemId] ==
        quotationController.selectedCurrencyName) {
      quotationController.unitPriceControllers[widget.index]!.text =
          quotationController.itemUnitPrice[selectedItemId].toString();
    } else if (quotationController.selectedCurrencyName == 'USD' &&
        quotationController.itemsPricesCurrencies[selectedItemId] !=
            quotationController.selectedCurrencyName) {
      var result = exchangeRatesController.exchangeRatesList.firstWhere(
        (item) =>
            item["currency"] ==
            quotationController.itemsPricesCurrencies[selectedItemId],
        orElse: () => null,
      );
      var divider = '1';
      if (result != null) {
        divider = result["exchange_rate"].toString();
      }
      quotationController.unitPriceControllers[widget.index]!.text =
          '${double.parse('${(double.parse(quotationController.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
    } else if (quotationController.selectedCurrencyName != 'USD' &&
        quotationController.itemsPricesCurrencies[selectedItemId] == 'USD') {
      quotationController.unitPriceControllers[widget.index]!.text =
          '${double.parse('${(double.parse(quotationController.itemUnitPrice[selectedItemId].toString()) * double.parse(quotationController.exchangeRateForSelectedCurrency))}')}';
    } else {
      var result = exchangeRatesController.exchangeRatesList.firstWhere(
        (item) =>
            item["currency"] ==
            quotationController.itemsPricesCurrencies[selectedItemId],
        orElse: () => null,
      );
      var divider = '1';
      if (result != null) {
        divider = result["exchange_rate"].toString();
      }
      var usdPrice =
          '${double.parse('${(double.parse(quotationController.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
      quotationController.unitPriceControllers[widget.index]!.text =
          '${double.parse('${(double.parse(usdPrice) * double.parse(quotationController.exchangeRateForSelectedCurrency))}')}';
    }
    if (quotationController.isBeforeVatPrices) {
      taxRate = 1;
      taxValue = 0;
    } else {
      taxRate =
          double.parse(quotationController.itemsVats[selectedItemId]) / 100.0;
      taxValue =
          taxRate *
          double.parse(
            quotationController.unitPriceControllers[widget.index]!.text,
          );
    }
    quotationController.unitPriceControllers[widget.index]!.text =
        '${double.parse(quotationController.unitPriceControllers[widget.index]!.text) + taxValue}';
    quotationController.unitPriceControllers[widget.index]!.text = double.parse(
      quotationController.unitPriceControllers[widget.index]!.text,
    ).toStringAsFixed(2);

    // qtyController.text = '1';
    quotationController.rowsInListViewInQuotation[widget
            .index]['item_unit_price'] =
        quotationController.unitPriceControllers[widget.index]!.text;
  }

  @override
  void initState() {
    if (widget.info.isNotEmpty) {
      qtyController.text = '${widget.info['item_quantity'] ?? ''}';
      quantity = '${widget.info['item_quantity'] ?? '0.0'}';

      discountController.text = widget.info['item_discount'] ?? '';
      discount = widget.info['item_discount'] ?? '0.0';

      totalLine = widget.info['item_total'] ?? '';
      mainDescriptionVar = widget.info['item_description'] ?? '';
      mainCode = widget.info['item_main_code'] ?? '';
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
                    textAlign: TextAlign.center,
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

                      quotationController.removeFromOrderLinesInQuotationList(
                        (widget.index).toString(),
                      );

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
                      quotationController.removeFromOrderLinesInQuotationList(
                        (widget.index).toString(),
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
                    quotationController.removeFromOrderLinesInQuotationList(
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
          Uri.parse('https://theravenstyle.com/public/${widget.info['image']}'),
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
                        quotationController.removeFromOrderLinesInQuotationList(
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
    quotationController.rowsInListViewInQuotation[widget
        .index]['item_total'] ='${widget.info['combo_total']}';
    quotationController.rowsInListViewInQuotation[widget
        .index]['combo'] =widget.info['combo_id'].toString();

  }

  @override
  void initState() {
    if (widget.info.isNotEmpty) {
      qtyController.text = '${widget.info['combo_quantity'] ?? ''}';
      quantity = '${widget.info['combo_quantity'] ?? '0.0'}';
      quotationController.rowsInListViewInQuotation[widget
          .index]['item_quantity'] ='${widget.info['combo_quantity'] ?? '0.0'}';

      discountController.text = widget.info['combo_discount'] ?? '';
      discount = widget.info['combo_discount'] ?? '0.0';
      quotationController.rowsInListViewInQuotation[widget
          .index]['item_discount'] =widget.info['combo_discount'] ?? '0.0';

      totalLine = widget.info['combo_total'] ?? '';
      mainDescriptionVar = widget.info['combo_description'] ?? '';


      mainCode = widget.info['combo_code'] ?? '';
      descriptionController.text = widget.info['combo_description'] ?? '';

      quotationController.rowsInListViewInQuotation[widget
          .index]['item_description'] = widget.info['combo_description'] ?? '';

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
                      var ind=cont.combosCodesList.indexOf(value.split(" | ")[0]);
                      selectedComboId = cont.combosIdsList[ind];
                      mainDescriptionVar = cont.combosDescriptionList[ind];
                      mainCode = cont.combosCodesList[ind];
                      comboName = cont.combosNamesList[ind];
                      descriptionController.text = cont.combosDescriptionList[ind];
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
                          cont.combosPricesCurrencies[selectedComboId] == 'USD') {
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
                    textAlign: TextAlign.center,
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

                      quotationController.removeFromOrderLinesInQuotationList(
                        (widget.index).toString(),
                      );

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