import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/DeliveryBackend/update_delivery.dart';
import 'package:rooster_app/Controllers/delivery_controller.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Controllers/task_controller.dart';
import 'package:rooster_app/Screens/Delivery/delivery.dart';
import 'package:rooster_app/Screens/Delivery/print_delivery_data.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/create_product_dialog.dart';
import 'package:rooster_app/Screens/Quotations/create_client_dialog.dart';
import 'package:rooster_app/Screens/Quotations/schedule_task_dialog.dart';
import 'package:rooster_app/Screens/Quotations/tasks.dart';
import 'package:rooster_app/Widgets/dialog_drop_menu.dart';
import 'package:rooster_app/Widgets/reusable_add_card.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import '../../Backend/Quotations/delete_quotation.dart';
import '../../Backend/Quotations/get_quotations.dart';
import '../../Controllers/home_controller.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../Widgets/TransferWidgets/under_item_btn.dart';
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
import '../../const/urls.dart';
import '../Combo/combo.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_quill/quill_delta.dart';

class DeliverySummary extends StatefulWidget {
  const DeliverySummary({super.key});

  @override
  State<DeliverySummary> createState() => _DeliverySummaryState();
}

class _DeliverySummaryState extends State<DeliverySummary> {
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
  final DeliveryController deliveryController = Get.find();
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
    await deliveryController.getAllDeliveryFromBack();
  }

  TaskController taskController = Get.find();
  int selectedTabIndex = 0;
  List tabsList = ['all_delivery', 'tasks'];
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
    deliveryController.setSearchInDeliveryController(value);
    await deliveryController.getAllDeliveryFromBack();
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
    deliveryController.setLogo(imageBytes);
  }

  @override
  void initState() {
    generatePdfFromImageUrl();
    deliveryController.itemsMultiPartList = [];
    deliveryController.salesPersonListNames = [];
    deliveryController.salesPersonListId = [];
    exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();
    deliveryController.getAllUsersSalesPersonFromBack();
    deliveryController.getFieldsForCreateDeliveryFromBack();
    deliveryController.searchInDeliveryController.text = '';
    listViewLength =
        Sizes.deviceHeight * (0.09 * deliveryController.deliveryList.length);
    deliveryController.getAllDeliveryFromBack();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryController>(
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
                    PageTitle(text: 'Deliveries'.tr),
                    ReusableButtonWithColor(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: 45,
                      onTapFunction: () {
                        homeController.selectedTab.value = 'new_delivery';
                      },
                      btnText: 'new_delivery'.tr,
                    ),
                  ],
                ),
                gapH24,
                SizedBox(
                  // width: MediaQuery.of(context).size.width * 0.59,
                  child: ReusableSearchTextField(
                    hint: '${"search".tr}...',
                    textEditingController: cont.searchInDeliveryController,
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
                                MediaQuery.of(context).size.width * 0.08,
                                () {
                                  setState(() {
                                    isNumberOrderedUp = !isNumberOrderedUp;
                                    isNumberOrderedUp
                                        ? cont.deliveryList.sort(
                                          (a, b) => a['deliveryNumber']
                                              .compareTo(b['deliveryNumber']),
                                        )
                                        : cont.deliveryList.sort(
                                          (a, b) => b['deliveryNumber']
                                              .compareTo(a['deliveryNumber']),
                                        );
                                  });
                                },
                              ),
                              tableTitleWithOrderArrow(
                                'input_date'.tr,
                                MediaQuery.of(context).size.width * 0.08,
                                () {
                                  setState(() {
                                    isCreationOrderedUp = !isCreationOrderedUp;
                                    isCreationOrderedUp
                                        ? cont.deliveryList.sort(
                                          (a, b) =>
                                              a['date'].compareTo(b['date']),
                                        )
                                        : cont.deliveryList.sort(
                                          (a, b) =>
                                              b['date'].compareTo(a['date']),
                                        );
                                  });
                                },
                              ),

                              tableTitleWithOrderArrow(
                                'delivery_date'.tr,
                                MediaQuery.of(context).size.width * 0.11,
                                () {
                                  setState(() {
                                    isCreationOrderedUp = !isCreationOrderedUp;
                                    isCreationOrderedUp
                                        ? cont.deliveryList.sort(
                                          (a, b) => a['expectedDate'].compareTo(
                                            b['expectedDate'],
                                          ),
                                        )
                                        : cont.deliveryList.sort(
                                          (a, b) => b['expectedDate'].compareTo(
                                            a['expectedDate'],
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
                                        ? cont.deliveryList.sort(
                                          (a, b) => '${a['client']['name']}'
                                              .compareTo(
                                                '${b['client']['name']}',
                                              ),
                                        )
                                        : cont.deliveryList.sort(
                                          (a, b) => '${b['client']['name']}'
                                              .compareTo(
                                                '${a['client']['name']}',
                                              ),
                                        );
                                  });
                                },
                              ),
                              tableTitleWithOrderArrow(
                                'driver'.tr,
                                MediaQuery.of(context).size.width * 0.08,
                                () {
                                  setState(() {
                                    isCustomerOrderedUp = !isCustomerOrderedUp;
                                    isCustomerOrderedUp
                                        ? cont.deliveryList.sort(
                                          (a, b) => '${a['client']['name']}'
                                              .compareTo(
                                                '${b['client']['name']}',
                                              ),
                                        )
                                        : cont.deliveryList.sort(
                                          (a, b) => '${b['client']['name']}'
                                              .compareTo(
                                                '${a['client']['name']}',
                                              ),
                                        );
                                  });
                                },
                              ),
                              TableTitle(
                                text: 'task'.tr,
                                width:
                                    MediaQuery.of(context).size.width *
                                    0.08, //085
                              ),

                              TableTitle(
                                text: 'status'.tr,
                                width:
                                    MediaQuery.of(context).size.width *
                                    0.08, //085
                              ),
                              TableTitle(
                                text: 'more_options'.tr,
                                width: MediaQuery.of(context).size.width * 0.06,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.03,
                              ),
                            ],
                          ),
                        ),
                        cont.isDeliveredInfoFetched
                            ? Container(
                              color: Colors.white,
                              // height: listViewLength,
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.4, //listViewLength
                              child: ListView.builder(
                                itemCount: cont.deliveryList.length,
                                // itemCount:  cont.quotationsList.length>9?selectedNumberOfRowsAsInt:cont.quotationsList.length,
                                itemBuilder:
                                    (context, index) => Column(
                                      children: [
                                        DeliveryAsRowInTable(
                                          info: cont.deliveryList[index],
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

class DeliveryAsRowInTable extends StatefulWidget {
  const DeliveryAsRowInTable({
    super.key,
    required this.info,
    required this.index,
    this.isDesktop = true,
  });
  final Map info;
  final int index;
  final bool isDesktop;

  @override
  State<DeliveryAsRowInTable> createState() => _DeliveryAsRowInTableState();
}

class _DeliveryAsRowInTableState extends State<DeliveryAsRowInTable> {
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
  double totalPriceAfterSpecialDiscountByDeliveryCurrency = 0.0;
  double vatByDeliveryCurrency = 0.0;
  double finalPriceByDeliveryCurrency = 0.0;
  List itemsInfoPrint = [];
  Map deliveryItemInfo = {};
  // String itemCurrencyName = '';
  // String itemCurrencySymbol = '';
  // String itemCurrencyLatestRate = '';
  String brand = '';

  final HomeController homeController = Get.find();
  final DeliveryController quotationController = Get.find();
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
      onDoubleTap: () {},
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
              text: '${widget.info['deliveryNumber'] ?? ''}',

              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.08
                      : 150,
            ),
            TableItem(
              text: '${widget.info['date'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.10
                      : 150,
            ),
            TableItem(
              text: '${widget.info['expectedDelivery'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.11
                      : 150,
            ),
            TableItem(
              text:
                  widget.info['client'] == null
                      ? ''
                      : '${widget.info['client']['name'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.10
                      : 150,
            ),
            TableItem(
              text:
                  widget.info['driver'] == null
                      ? ''
                      : '${widget.info['driver']['name'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.08
                      : 150,
            ),

            // TableItem(
            //   text: 'task',
            //   width:
            //       widget.isDesktop
            //           ? MediaQuery.of(context).size.width * 0.07
            //           : 150,
            // ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTapDown: (details) => _showPopupMenu(context, details),
                child: TableItem(
                  text:
                      // widget.info['tasks'].isNotEmpty
                      //     ? widget.info['tasks']
                      //         .map((task) => task["summary"] as String)
                      //         .join(", ")
                      //     :
                      'No Records',
                  width:
                      widget.isDesktop
                          ? MediaQuery.of(context).size.width * 0.08
                          : 150,
                ),
              ),
            ),
            // TableItem(
            //   text:
            //       widget.info['line_type_id'] == 2
            //           ? widget.info['item_warehouse']
            //           : widget.info['line_type_id'] == 3
            //           ? widget.info['combo_warehouse']
            //           : widget.info['item_warehouse'],

            //   width:
            //       widget.isDesktop
            //           ? MediaQuery.of(context).size.width * 0.08
            //           : 150,
            // ),
            SizedBox(
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.08
                      : 150,
              child: Center(
                child: Container(
                  width:
                      widget.info['status'] == null
                          ? MediaQuery.of(context).size.width * 0.10
                          : '${widget.info['status']}'.length * 10.0,
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
                            : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.info['status'] ?? '---'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            GetBuilder<DeliveryController>(
              builder: (cont) {
                return SizedBox(
                  width:
                      widget.isDesktop
                          ? MediaQuery.of(context).size.width * 0.08
                          : 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Tooltip(
                        message: 'preview'.tr,
                        child: InkWell(
                          onTap: () async {
                            itemsInfoPrint = [];
                            var salesInvoiceItemInfo = {};

                            for (var item in widget.info['orderLines']) {
                              if ('${item['line_type_id']}' == '2') {
                                qty = item['item_quantity'];
                                var map =
                                    cont.itemsMap[item['item_id'].toString()];
                                itemName = map['item_name'];

                                itemDescription = item['item_description'];
                                // itemImage =
                                //     '${map['images']}' != '[]' &&
                                //             map['images'] != null
                                //         ? '$baseImage${map['images'][0]['img_url']}'
                                //         : '';

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
                                var itemwarehouse = '${item['item_warehouse']}';
                                salesInvoiceItemInfo = {
                                  'line_type_id': '2',
                                  'item_name': itemName,
                                  'item_description': itemDescription,
                                  'item_quantity': qty,
                                  'item_warehouse': itemwarehouse,
                                  'combo_warehouse': '',
                                  'item_image': itemImage,
                                  'item_brand': brand,
                                  'title': '',
                                  'isImageList': false,
                                  'note': '',
                                  'image': '',
                                };
                                itemsInfoPrint.add(salesInvoiceItemInfo);
                              } else if ('${item['line_type_id']}' == '3') {
                                var qty = item['combo_quantity'];

                                var ind = cont.combosIdsList.indexOf(
                                  item['combo_id'].toString(),
                                );
                                var itemName = cont.combosNamesList[ind];

                                var itemDescription = item['combo_description'];

                                var itemwarehouse =
                                    '${item['combo_warehouse']}';

                                var quotationItemInfo = {
                                  'line_type_id': '3',
                                  'item_name': itemName,
                                  'item_description': itemDescription,
                                  'item_quantity': qty,
                                  'item_warehouse': '',
                                  'combo_warehouse': itemwarehouse,
                                  'item_image': itemImage,
                                  'item_brand': brand,
                                  'title': '',
                                  'isImageList': false,
                                  'note': '',
                                  'image': '',
                                };
                                itemsInfoPrint.add(quotationItemInfo);
                              } else if ('${item['line_type_id']}' == '1') {
                                var quotationItemInfo = {
                                  'line_type_id': '1',
                                  'item_name': '',
                                  'item_description': '',
                                  'item_quantity': '',
                                  'item_warehouse': '',
                                  'combo_warehouse': '',
                                  'item_image': '',
                                  'item_brand': '',
                                  'title': item['title'],
                                  'isImageList': false,
                                  'note': '',
                                  'image': '',
                                };
                                itemsInfoPrint.add(quotationItemInfo);
                              } else if ('${item['line_type_id']}' == '5') {
                                var quotationItemInfo = {
                                  'line_type_id': '5',
                                  'item_name': '',
                                  'item_description': '',
                                  'item_quantity': '',
                                  'item_warehouse': '',
                                  'combo_warehouse': '',
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
                                  'item_warehouse': '',
                                  'combo_warehouse': '',
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

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  // print('widget.info[ ${widget.info['termsAndConditions']}');
                                  return PrintDeliveryData(
                                    isInDelivery: true,
                                    deliveryNumber:
                                        widget.info['deliveryNumber'] ?? '',

                                    creationDate: widget.info['date'] ?? '',
                                    expectedDate:
                                        widget.info['expectedDelivery'] ?? '',
                                    receivedUser: '',
                                    senderUser: homeController.userName,

                                    clientPhoneNumber:
                                        widget.info['client'] != null
                                            ? widget.info['client']['phoneNumber'] ??
                                                '---'
                                            : "---",
                                    clientName:
                                        widget.info['client']['name'] ?? '',
                                    total: widget.info['total'],
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
                                    content: UpdateDeliveryDialog(
                                      index: widget.index,
                                      info: widget.info,
                                    ),
                                  ),
                            );
                          },
                          child: Icon(Icons.edit, color: Primary.primary),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
              child: InkWell(
                onTap: () async {
                  // print("index");
                  // print([widget.index]);
                  // print("id");
                  // print(quotationController.quotationsList[widget.index]['id']);
                  // var res = await deleteQuotation(
                  //   '${quotationController.quotationsList[widget.index]['id']}',
                  // );
                  // var p = json.decode(res.body);
                  // if (res.statusCode == 200) {
                  //   CommonWidgets.snackBar('Success', p['message']);
                  //   quotationController.getAllQuotationsFromBack();
                  // } else {
                  //   CommonWidgets.snackBar('error', p['message']);
                  // }
                },
                child: Icon(Icons.delete_outline, color: Primary.primary),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          ],
        ),
      ),
    );
  }
}

class MobileDeliverySummary extends StatefulWidget {
  const MobileDeliverySummary({super.key});

  @override
  State<MobileDeliverySummary> createState() => _MobileDeliverySummaryState();
}

class _MobileDeliverySummaryState extends State<MobileDeliverySummary> {
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
    var p = await getAllQuotationsWithoutPending('');
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
                                        'Driver'.tr,
                                        150,
                                        () {
                                          setState(() {
                                            isSalespersonOrderedUp =
                                                !isSalespersonOrderedUp;
                                            isSalespersonOrderedUp
                                                ? quotationsList.sort(
                                                  (a, b) => a['driver']['name']
                                                      .compareTo(
                                                        b['driver']['name'],
                                                      ),
                                                )
                                                : quotationsList.sort(
                                                  (a, b) => b['driver']['name']
                                                      .compareTo(
                                                        a['driver']['name'],
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
                                                  DeliveryAsRowInTable(
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

class UpdateDeliveryDialog extends StatefulWidget {
  const UpdateDeliveryDialog({
    super.key,
    required this.index,
    required this.info,
  });
  final int index;
  final Map info;

  @override
  State<UpdateDeliveryDialog> createState() => _UpdateDeliveryDialogState();
}

class _UpdateDeliveryDialogState extends State<UpdateDeliveryDialog> {
  final _formKey = GlobalKey<FormState>();
  String selectedSalesPerson = '';
  int selectedSalesPersonId = 0;
  List tabsList = ['order_lines', 'Links'];
  TextEditingController cashingMethodsController = TextEditingController();
  TextEditingController salesPersonController = TextEditingController();
  TextEditingController driverNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController refController = TextEditingController();
  TextEditingController validityController = TextEditingController();
  TextEditingController expectedDateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
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
  final DeliveryController deliveryController = Get.find();

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
    deliveryController.selectedCurrencyId =
        widget.info['currency']['id'].toString();
    selectedCurrency = widget.info['currency']['name'] ?? '';
    currencyController.text = selectedCurrency;
    int index = exchangeRatesController.currenciesNamesList.indexOf(
      selectedCurrency,
    );
    deliveryController.selectedCurrencyId =
        exchangeRatesController.currenciesIdsList[index];
    deliveryController.selectedCurrencyName = selectedCurrency;
    var vat = await getCompanyVatFromPref();
    deliveryController.setCompanyVat(double.parse(vat));
    var companyCurrency = await getCompanyPrimaryCurrencyFromPref();
    deliveryController.setCompanyPrimaryCurrency(companyCurrency);
    var result = exchangeRatesController.exchangeRatesList.firstWhere(
      (item) => item["currency"] == companyCurrency,
      orElse: () => null,
    );
    deliveryController.setLatestRate(
      double.parse(result != null ? '${result["exchange_rate"]}' : '1'),
    );
  }

  // var isVatZero = false;
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
    if ('${widget.info['printedAsPercentage'] ?? ''}' == '1') {
      deliveryController.isPrintedAs0 = true;
      vatExemptController.text = 'Printed as "vat 0 % = 0"';
    }
    if ('${widget.info['printedAsVatExempt']}' == '1') {
      deliveryController.isPrintedAsVatExempt = true;
      vatExemptController.text = 'Printed as "vat exempted"';
    }
    if ('${widget.info['notPrinted'] ?? ''}' == '1') {
      deliveryController.isVatNoPrinted = true;
      vatExemptController.text = 'No printed ';
    }
    deliveryController.isVatExemptChecked =
        '${widget.info['vatExempt'] ?? ''}' == '1' ? true : false;
  }

  // late QuillController _controller;
  // String? _savedContent;

  // void _saveContent() {
  //   final deltaJson = _controller.document.toDelta().toJson();
  //   final jsonString = jsonEncode(deltaJson);
  //
  //   setState(() {
  //     _savedContent = jsonString;
  //   });
  //
  //   // You can now send `jsonString` to your backend
  //   termsAndConditionsController.text = jsonString;
  // }

  // Restore content from saved string (e.g., from API)
  // void _loadContent() {
  //   if (_savedContent == null) return;
  //   if (_savedContent == '[{"insert":"\n"}]') {
  //     _controller = QuillController.basic();
  //     return;
  //   }
  //   final delta = Delta.fromJson(jsonDecode(_savedContent!));
  //   final doc = Document.fromDelta(delta);
  //
  //   setState(() {
  //     _controller = QuillController(
  //       document: doc,
  //       selection: const TextSelection.collapsed(offset: 0),
  //     );
  //   });
  // }

  int progressVar = 0;

  setProgressVar() {
    deliveryController.status = widget.info['status'];
    progressVar =
        widget.info['status'] == "pending"
            ? 0
            : widget.info['status'] == 'sent'
            ? 1
            : widget.info['status'] == 'confirmed'
            ? 2
            : 0;
  }

  //preview
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
  double totalPriceAfterSpecialDiscountByDeliveryCurrency = 0.0;
  double vatByDeliveryCurrency = 0.0;
  double finalPriceByDeliveryCurrency = 0.0;
  List itemsInfoPrint = [];
  Map deliveryItemInfo = {};

  String brand = '';

  String oldTermsAndConditionsString = '';
  @override
  void initState() {
    deliveryController.orderLinesDeliveryList = {};
    deliveryController.rowsInListViewInDelivery = {};

    searchController.text = widget.info['client']['name'] ?? '';
    selectedItem = widget.info['client']['name'] ?? '';
    codeController.text = widget.info['client']['client_number'] ?? '';
    selectedItemCode = widget.info['client']['client_number'] ?? '';
    selectedCustomerIds = widget.info['client']['id'].toString();
    //
    widget.info['driver'] != null
        ? driverNameController.text = widget.info['driver']['name']
        : driverNameController.text = '';
    refController.text = widget.info['reference'] ?? '';
    List<String> parts = widget.info['expectedDelivery'].split(' ');
    if (parts.length == 2) {
      String datePart = parts[0]; // "2025-06-29"
      String timePart = parts[1]; // "14:30:00"

      // Assign to controllers
      expectedDateController.text = datePart;
      timeController.text = timePart.substring(
        0,
        8,
      ); // Extract "14:30" if you only want hours and minutes
    } else {
      // Handle invalid format if necessary
    }
    validityController.text = widget.info['date'] ?? '';
    // expectedDateController.text = widget.info['expectedDelivery'] ?? '';

    deliveryController.city[selectedCustomerIds] =
        widget.info['client']['city'] ?? '';
    deliveryController.country[selectedCustomerIds] =
        widget.info['client']['country'] ?? '';
    deliveryController.email[selectedCustomerIds] =
        widget.info['client']['email'] ?? '';
    deliveryController.phoneNumber[selectedCustomerIds] =
        widget.info['client']['phoneNumber'] ?? '';
    deliveryController.selectedDeliveryData['orderLines'] =
        widget.info['orderLines'] ?? '';
    for (
      int i = 0;
      i < deliveryController.selectedDeliveryData['orderLines'].length;
      i++
    ) {
      deliveryController.rowsInListViewInDelivery[i + 1] =
          deliveryController.selectedDeliveryData['orderLines'][i];
    }
    var keys = deliveryController.rowsInListViewInDelivery.keys.toList();

    for (int i = 0; i < widget.info['orderLines'].length; i++) {
      if (widget.info['orderLines'][i]['line_type_id'] == 2) {
        deliveryController.unitPriceControllers[i + 1] =
            TextEditingController();
        Widget p = ReusableItemRow(
          index: i + 1,
          info: deliveryController.rowsInListViewInDelivery[keys[i]],
        );

        deliveryController.orderLinesDeliveryList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 1) {
        Widget p = ReusableTitleRow(
          index: i + 1,
          info: deliveryController.rowsInListViewInDelivery[keys[i]],
        );
        deliveryController.orderLinesDeliveryList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 5) {
        Widget p = ReusableNoteRow(
          index: i + 1,
          info: deliveryController.rowsInListViewInDelivery[keys[i]],
        );
        deliveryController.orderLinesDeliveryList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 4) {
        Widget p = ReusableImageRow(
          index: i + 1,
          info: deliveryController.rowsInListViewInDelivery[keys[i]],
        );
        deliveryController.orderLinesDeliveryList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 3) {
        deliveryController.combosPriceControllers[i + 1] =
            TextEditingController();
        Widget p = ReusableComboRow(
          index: i + 1,
          info: deliveryController.rowsInListViewInDelivery[keys[i]],
        );
        deliveryController.orderLinesDeliveryList['${i + 1}'] = p;
      }
    }
    quotationCounter = deliveryController.rowsInListViewInDelivery.length;
    deliveryController.listViewLengthInDelivery =
        deliveryController.orderLinesDeliveryList.length * 60;
    // TimeOfDay now = TimeOfDay.now();
    // String formattedTime =
    //     '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    // timeController.text = formattedTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryController>(
      builder: (deliveryCont) {
        var keysList = deliveryCont.orderLinesDeliveryList.keys.toList();
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
                      PageTitle(text: 'update_delivery'.tr),
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
                            text: 'preview'.tr,
                            onTap: () async {
                              itemsInfoPrint = [];
                              itemsInfoPrint = [];
                              var salesInvoiceItemInfo = {};

                              for (var item in widget.info['orderLines']) {
                                if ('${item['line_type_id']}' == '2') {
                                  qty = item['item_quantity'];
                                  var map =
                                      deliveryCont.itemsMap[item['item_id']
                                          .toString()];
                                  itemName = map['item_name'];

                                  itemDescription = item['item_description'];
                                  // itemImage =
                                  //     '${map['images']}' != '[]' &&
                                  //             map['images'] != null
                                  //         ? '$baseImage${map['images'][0]['img_url']}'
                                  //         : '';

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
                                  var itemwarehouse =
                                      '${item['item_warehouse']}';
                                  salesInvoiceItemInfo = {
                                    'line_type_id': '2',
                                    'item_name': itemName,
                                    'item_description': itemDescription,
                                    'item_quantity': qty,
                                    'item_warehouse': itemwarehouse,
                                    'combo_warehouse': '',
                                    'item_image': itemImage,
                                    'item_brand': brand,
                                    'title': '',
                                    'isImageList': false,
                                    'note': '',
                                    'image': '',
                                  };
                                  itemsInfoPrint.add(salesInvoiceItemInfo);
                                } else if ('${item['line_type_id']}' == '3') {
                                  var qty = item['combo_quantity'];

                                  var ind = deliveryCont.combosIdsList.indexOf(
                                    item['combo_id'].toString(),
                                  );
                                  var itemName =
                                      deliveryCont.combosNamesList[ind];

                                  var itemDescription =
                                      item['combo_description'];

                                  var itemwarehouse =
                                      '${item['combo_warehouse']}';

                                  var quotationItemInfo = {
                                    'line_type_id': '2',
                                    'item_name': itemName,
                                    'item_description': itemDescription,
                                    'item_quantity': qty,
                                    'item_warehouse': '',
                                    'combo_warehouse': itemwarehouse,
                                    'item_image': itemImage,
                                    'item_brand': brand,
                                    'title': '',
                                    'isImageList': false,
                                    'note': '',
                                    'image': '',
                                  };
                                  itemsInfoPrint.add(quotationItemInfo);
                                } else if ('${item['line_type_id']}' == '1') {
                                  var quotationItemInfo = {
                                    'line_type_id': '1',
                                    'item_name': '',
                                    'item_description': '',
                                    'item_quantity': '',
                                    'item_warehouse': '',
                                    'combo_warehouse': '',
                                    'item_image': '',
                                    'item_brand': '',
                                    'title': item['title'],
                                    'isImageList': false,
                                    'note': '',
                                    'image': '',
                                  };
                                  itemsInfoPrint.add(quotationItemInfo);
                                } else if ('${item['line_type_id']}' == '5') {
                                  var quotationItemInfo = {
                                    'line_type_id': '5',
                                    'item_name': '',
                                    'item_description': '',
                                    'item_quantity': '',
                                    'item_warehouse': '',
                                    'combo_warehouse': '',
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
                                    'item_warehouse': '',
                                    'combo_warehouse': '',
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

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    // print('widget.info[ ${widget.info['termsAndConditions']}');
                                    return PrintDeliveryData(
                                      deliveryNumber:
                                          widget.info['deliveryNumber'] ?? '',

                                      creationDate: widget.info['date'] ?? '',
                                      expectedDate:
                                          widget.info['expectedDelivery'] ?? '',
                                      receivedUser: '',
                                      senderUser: homeController.userName,

                                      clientPhoneNumber:
                                          widget.info['client'] != null
                                              ? widget.info['client']['phoneNumber'] ??
                                                  '---'
                                              : "---",
                                      clientName:
                                          widget.info['client']['name'] ?? '',
                                      total: widget.info['total'],
                                      itemsInfoPrint: itemsInfoPrint,
                                      isInDelivery: true,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          UnderTitleBtn(
                            text: 'Print'.tr,
                            onTap: () {
                              setState(() {
                                progressVar = 0;
                              });
                            },
                          ),
                          UnderTitleBtn(
                            text: 'send'.tr,
                            onTap: ()
                            // {
                            //   if (progressVar == 0) {
                            //     setState(() {
                            //       progressVar += 1;
                            //     });
                            //   }
                            // },
                            async {
                              setState(() {
                                progressVar = 1;
                              });
                              deliveryCont.setStatus("sent");
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
                              if (_formKey.currentState!.validate()) {
                                //   _saveContent();
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

                                var res = await updateDelivery(
                                  '${widget.info['id']}',
                                  selectedCustomerIds,
                                  deliveryCont.selectedDriverId.toString(),
                                  refController.text,
                                  validityController.text,
                                  formattedDateTime,
                                  deliveryCont.status, // status,
                                  deliveryController.newRowMap,
                                );
                                if (res['success'] == true) {
                                  Get.back();
                                  deliveryController.getAllDeliveryFromBack();
                                  homeController.selectedTab.value =
                                      'deliveries_summary';
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
                            text: 'cancel'.tr,
                            onTap: ()
                            // {
                            //   setState(() {
                            //     progressVar = 0;
                            //   });
                            //   quotationCont.setStatus('cancelled');
                            // },
                            async {
                              setState(() {
                                progressVar = 0;
                              });
                              deliveryCont.setStatus("cancelled");
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
                              if (_formKey.currentState!.validate()) {
                                //   _saveContent();
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

                                var res = await updateDelivery(
                                  '${widget.info['id']}',
                                  selectedCustomerIds,
                                  deliveryCont.selectedDriverId.toString(),
                                  refController.text,
                                  validityController.text,
                                  formattedDateTime,
                                  deliveryCont.status, // status,
                                  deliveryController.newRowMap,
                                );
                                if (res['success'] == true) {
                                  Get.back();
                                  deliveryController.getAllDeliveryFromBack();
                                  homeController.selectedTab.value =
                                      'deliveries_summary';
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
                            isPast: false,
                            text: 'delivered'.tr,
                          ),
                          ReusableTimeLineTile(
                            id: 2,
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
                                  '${widget.info['deliveryNumber'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
                                        0.095,
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
                                      validityController.text = val;
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //code
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.60,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('code'.tr),
                                  gapW12,
                                  DropdownMenu<String>(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.13,
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
                                        deliveryCont.customerNumberList
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
                                        indexNum = deliveryCont
                                            .customerNumberList
                                            .indexOf(selectedItemCode);
                                        selectedCustomerIds =
                                            deliveryCont
                                                .customerIdsList[indexNum];
                                        searchController.text =
                                            deliveryCont
                                                .customerNameList[indexNum];
                                      });
                                    },
                                  ),
                                  ReusableDropDownMenuWithSearch(
                                    list: deliveryCont.customerNameList,
                                    text: '',
                                    hint: '${'search'.tr}...',
                                    controller: searchController,
                                    onSelected: (String? val) {
                                      setState(() {
                                        selectedItem = val!;
                                        var index = deliveryCont
                                            .customerNameList
                                            .indexOf(selectedItem);
                                        selectedCustomerIds =
                                            deliveryCont.customerIdsList[index];
                                        codeController.text =
                                            deliveryCont
                                                .customerNumberList[index];

                                        // codeController =
                                        //     quotationController.codeController;
                                      });
                                    },
                                    validationFunc: (value) {},
                                    rowWidth:
                                        MediaQuery.of(context).size.width *
                                        0.27,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width *
                                        0.26,
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
                          ],
                        ),

                        gapH16,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.55,
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
                                        'phone_number'.tr,
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
                                            MediaQuery.of(context).size.width *
                                            0.15,
                                        // requestFocusOnTap: false,
                                        enableSearch: true,
                                        controller: driverNameController,
                                        hintText: ''.tr,
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
                                            deliveryCont.driverNameList.map<
                                              DropdownMenuEntry<String>
                                            >((String option) {
                                              return DropdownMenuEntry<String>(
                                                value: option,
                                                label: option,
                                              );
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
                                  deliveryCont.isVatExemptCheckBoxShouldAppear
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
                            // Total Qty
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.24,
                              child: Row(
                                children: [
                                  Text(
                                    'total_qty:'.tr,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  gapW10,
                                  Text(
                                    "${deliveryCont.phoneNumber[selectedCustomerIds] ?? ''}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
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
                                TableTitle(
                                  text: 'item'.tr,
                                  width:
                                      MediaQuery.of(context).size.width * 0.10,
                                ),
                                TableTitle(
                                  text: 'description'.tr,
                                  width:
                                      MediaQuery.of(context).size.width * 0.32,
                                ),
                                TableTitle(
                                  text: 'quantity'.tr,
                                  width:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                                TableTitle(
                                  text: 'warehouse'.tr,
                                  width:
                                      MediaQuery.of(context).size.width * 0.12,
                                ),

                                TableTitle(
                                  text: 'more_options'.tr,
                                  width:
                                      MediaQuery.of(context).size.width * 0.12,
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
                                      deliveryCont.listViewLengthInDelivery +
                                      50,
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
                                        deliveryController.salesPersonListNames,
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
                                        var index = deliveryController
                                            .salesPersonListNames
                                            .indexOf(val);
                                        selectedSalesPersonId =
                                            deliveryController
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
                                        deliveryCont.cashingMethodsNamesList,
                                    text: 'cashing_method'.tr,
                                    hint: '',
                                    rowWidth:
                                        MediaQuery.of(context).size.width * 0.3,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width *
                                        0.15,
                                    onSelected: (value) {
                                      var index = deliveryController
                                          .cashingMethodsNamesList
                                          .indexOf(value);
                                      deliveryCont.setSelectedCashingMethodId(
                                        deliveryCont
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

                  gapH70,

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
                          deliveryCont.setStatus("Updated");
                          var oldKeys =
                              deliveryController.rowsInListViewInDelivery.keys
                                  .toList()
                                ..sort();
                          for (int i = 0; i < oldKeys.length; i++) {
                            deliveryController.newRowMap[i + 1] =
                                deliveryController
                                    .rowsInListViewInDelivery[oldKeys[i]]!;
                          }
                          if (_formKey.currentState!.validate()) {
                            //   _saveContent();
                            String dateString =
                                expectedDateController
                                    .text; // e.g., "2025-06-29"
                            // Parse the time
                            String timeString =
                                timeController.text; // e.g., "14:30"

                            // Combine date and time strings into a single string
                            String dateTimeString = '$dateString $timeString';

                            // Parse into DateTime object
                            DateTime dateTime = DateFormat(
                              'yyyy-MM-dd HH:mm',
                            ).parse(dateTimeString);

                            // Format into desired output
                            String formattedDateTime = DateFormat(
                              'yyyy-MM-dd HH:mm:ss',
                            ).format(dateTime);

                            var res = await updateDelivery(
                              '${widget.info['id']}',
                              selectedCustomerIds,
                              deliveryCont.selectedDriverId.toString(),
                              refController.text,
                              validityController.text,
                              formattedDateTime,
                              deliveryCont.status, // status,
                              deliveryController.newRowMap,
                            );
                            if (res['success'] == true) {
                              Get.back();
                              deliveryController.getAllDeliveryFromBack();
                              homeController.selectedTab.value =
                                  'deliveries_summary';
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
  String titleValue = '';

  addNewTitle() {
    setState(() {
      quotationCounter += 1;
    });
    deliveryController.incrementListViewLengthInDelivery(
      deliveryController.increment,
    );
    deliveryController.addTorowsInListViewInDelivery(quotationCounter, {
      'line_type_id': '1',
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
    });
    Widget p = ReusableTitleRow(index: quotationCounter, info: {});
    deliveryController.addToOrderLinesInDeliveryList('$quotationCounter', p);
  }
  // int quotationCounter = 0;

  addNewItem() {
    setState(() {
      quotationCounter += 1;
    });
    deliveryController.incrementListViewLengthInDelivery(
      deliveryController.increment,
    );
    deliveryController.addTorowsInListViewInDelivery(quotationCounter, {
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
    });
    deliveryController.addToUnitPriceControllers(quotationCounter);
    Widget p = ReusableItemRow(index: quotationCounter, info: {});
    deliveryController.addToOrderLinesInDeliveryList('$quotationCounter', p);
  }

  addNewCombo() {
    setState(() {
      quotationCounter += 1;
    });
    deliveryController.incrementListViewLengthInDelivery(
      deliveryController.increment,
    );
    deliveryController.addTorowsInListViewInDelivery(quotationCounter, {
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
    deliveryController.addToCombosPricesControllers(quotationCounter);
    Widget p = ReusableComboRow(index: quotationCounter, info: {});
    deliveryController.addToOrderLinesInDeliveryList('$quotationCounter', p);
  }

  addNewImage() {
    setState(() {
      quotationCounter += 1;
    });
    deliveryController.incrementListViewLengthInDelivery(
      deliveryController.increment,
    );

    deliveryController.addTorowsInListViewInDelivery(quotationCounter, {
      'line_type_id': '4',
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
      'image': Uint8List(0),
    });

    Widget p = ReusableImageRow(index: quotationCounter, info: {});

    deliveryController.addToOrderLinesInDeliveryList('$quotationCounter', p);
  }

  addNewNote() {
    setState(() {
      quotationCounter += 1;
    });
    deliveryController.incrementListViewLengthInDelivery(
      deliveryController.increment,
    );

    deliveryController.addTorowsInListViewInDelivery(quotationCounter, {
      'line_type_id': '5',
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
    });

    Widget p = ReusableNoteRow(index: quotationCounter, info: {});

    deliveryController.addToOrderLinesInDeliveryList('$quotationCounter', p);

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
  String warehouse = '';

  TextEditingController itemCodeController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController warehouseController = TextEditingController();
  final ProductController productController = Get.find();
  final DeliveryController deliveryController = Get.find();
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

  @override
  void initState() {
    if (widget.info.isNotEmpty) {
      qtyController.text = '${widget.info['item_quantity'] ?? '0.0'}';
      quantity = '${widget.info['item_quantity'] ?? '0.0'}';

      warehouseController.text = widget.info['item_warehouse'] ?? '';

      mainDescriptionVar = widget.info['item_description'] ?? '';
      mainCode = widget.info['item_name'] ?? '';
      descriptionController.text = widget.info['item_description'] ?? '';

      itemCodeController.text = widget.info['item_name'].toString();
      selectedItemId = widget.info['id'].toString();
    } else {
      // qtyController.text = '0';
      // quantity = '0';

      qtyController.text =
          deliveryController.rowsInListViewInDelivery[widget
              .index]['item_quantity'];

      descriptionController.text =
          deliveryController.rowsInListViewInDelivery[widget
              .index]['item_description'];
    }

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
                      deliveryController
                          .itemsMultiPartList, // Assuming multiList is List<List<String>>
                  text: ''.tr,
                  hint: 'item'.tr,
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
                    });
                    qtyController.text = '1';
                    quantity = '1';
                    cont.setEnteredQtyInDelivery(widget.index, quantity);
                    cont.setItemIdInDelivery(widget.index, selectedItemId);
                    cont.setItemNameInDelivery(
                      widget.index,
                      itemName,
                      // value.split(" | ")[0],
                    ); // set only first element as name
                    cont.setMainCodeInDelivery(widget.index, mainCode);
                    cont.setTypeInDelivery(widget.index, '2');
                    cont.setMainDescriptionInDelivery(
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
                  nextFocusNode: quantityFocus, // Set column widths
                ),
                //description
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.27,
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
                //more
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
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

                // delete
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.03,
                  child: InkWell(
                    onTap: () {
                      deliveryController.decrementListViewLengthInDelivery(
                        deliveryController.increment,
                      );
                      deliveryController.removeFromrowsInListViewInDelivery(
                        widget.index,
                      );

                      deliveryController.removeFromOrderLinesInDeliveryList(
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
                        // cont.totalQuotation = "0.0";

                        cont.getTotalItems();
                      });
                      if (cont.rowsInListViewInDelivery != {}) {
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
  final DeliveryController deliveryController = Get.find();
  String titleValue = '0';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // titleController.text = widget.info['title'] ?? '';
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
                  width: MediaQuery.of(context).size.width * 0.73,
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
                      deliveryController.decrementListViewLengthInDelivery(
                        deliveryController.increment,
                      );
                      deliveryController.removeFromrowsInListViewInDelivery(
                        widget.index,
                      );
                      deliveryController.removeFromOrderLinesInDeliveryList(
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
                  deliveryController.setTypeInDelivery(widget.index, '5');
                  deliveryController.setNoteInDelivery(widget.index, val);
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
  final DeliveryController deliveryController = Get.find();
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
    deliveryController.setImageInDelivery(widget.index, imageFile);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryController>(
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
                        deliveryController.decrementListViewLengthInDelivery(
                          deliveryController.increment + 50,
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
  TextEditingController warehouseController = TextEditingController();

  final DeliveryController deliveryController = Get.find();
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

  @override
  void initState() {
    if (widget.info.isNotEmpty) {
      qtyController.text = '${widget.info['combo_quantity'] ?? '0.0'}';
      quantity = '${widget.info['combo_quantity'] ?? '0.0'}';
      deliveryController.rowsInListViewInDelivery[widget
              .index]['item_quantity'] =
          '${widget.info['combo_quantity'] ?? '0.0'}';

      mainDescriptionVar = widget.info['combo_description'] ?? '';

      mainCode = widget.info['combo_code'] ?? '';
      descriptionController.text = widget.info['combo_description'] ?? '';
      warehouseController.text = widget.info['combo_warehouse'] ?? '';

      deliveryController.rowsInListViewInDelivery[widget
              .index]['item_description'] =
          widget.info['combo_description'] ?? '';

      comboCodeController.text = widget.info['combo_code'].toString();
      selectedComboId = widget.info['combo_id'].toString();
    } else {
      qtyController.text =
          deliveryController.rowsInListViewInDelivery[widget
              .index]['item_quantity'];

      descriptionController.text =
          deliveryController.rowsInListViewInDelivery[widget
              .index]['item_description'];
    }

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
                      deliveryController
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
                      mainDescriptionVar,
                    );
                  },
                  validationFunc: (value) {
                    // if ((value == null || value.isEmpty)&& selectedComboId.isEmpty ) {
                    //   return 'select_option'.tr;
                    // }
                    return null;
                  },
                  rowWidth: MediaQuery.of(context).size.width * 0.12,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.12,
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
                  width: MediaQuery.of(context).size.width * 0.27,
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

                      cont.setEnteredQtyInDelivery(widget.index, val);
                      cont.setMainTotalInDelivery(widget.index, totalLine);
                      cont.getTotalItems();
                    },
                  ),
                ),

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

                //more
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
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
                      deliveryController.decrementListViewLengthInDelivery(
                        deliveryController.increment,
                      );
                      deliveryController.removeFromrowsInListViewInDelivery(
                        widget.index,
                      );

                      deliveryController.removeFromOrderLinesInDeliveryList(
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
                        // cont.totalQuotation = "0.0";

                        cont.getTotalItems();
                      });
                      if (cont.rowsInListViewInDelivery != {}) {
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
