// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:rooster_app/Backend/SalesInvoiceBackend/update_sales_invoice.dart';
// import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
// import 'package:rooster_app/Controllers/pending_docs_review_controller.dart';
// import 'package:rooster_app/Controllers/sales_invoice_controller.dart';
// import 'package:rooster_app/Controllers/task_controller.dart';
// import 'package:rooster_app/Screens/SalesInvoice/sales_invoice_summary.dart';
// import 'package:rooster_app/Screens/Quotations/schedule_task_dialog.dart';
// import 'package:rooster_app/Screens/SalesInvoice/print_sales_invoice.dart';
// import '../../Controllers/home_controller.dart';
// import '../../Locale_Memory/save_user_info_locally.dart';
// import '../../Widgets/custom_snak_bar.dart';
// import '../../Widgets/page_title.dart';
// import '../../Widgets/reusable_btn.dart';
// import '../../Widgets/reusable_text_field.dart';
// import '../../Widgets/table_item.dart';
// import '../../Widgets/table_title.dart';
// import '../../const/Sizes.dart';
// import '../../const/colors.dart';
// import '../../const/functions.dart';
// import '../../const/urls.dart';

// class ToDeleiver extends StatefulWidget {
//   const ToDeleiver({super.key});

//   @override
//   State<ToDeleiver> createState() => _ToDeleiver();
// }

// class _ToDeleiver extends State<ToDeleiver> {
//   final TextEditingController filterController = TextEditingController();
//   TextEditingController searchController = TextEditingController();
//   final ExchangeRatesController exchangeRatesController = Get.find();

//   double listViewLength = 100;
//   String selectedNumberOfRows = '10';
//   int selectedNumberOfRowsAsInt = 10;
//   int start = 1;
//   bool isArrowBackClicked = false;
//   bool isArrowForwardClicked = false;
//   final HomeController homeController = Get.find();
//   final SalesInvoiceController salesInvoiceController = Get.find();
//   final PendingDocsReviewController pendingDocsController = Get.find();
//   bool isNumberOrderedUp = true;
//   bool isCreationOrderedUp = true;
//   bool isCustomerOrderedUp = true;
//   bool isSalespersonOrderedUp = true;
//   String searchValue = '';
//   Timer? searchOnStoppedTyping;
//   bool isPendindDocsFetched = false;
//   onChangeHandler(value) {
//     const duration = Duration(
//       milliseconds: 800,
//     ); // set the duration that you want call search() after that.
//     if (searchOnStoppedTyping != null) {
//       setState(() => searchOnStoppedTyping!.cancel()); // clear timer
//     }
//     setState(
//       () => searchOnStoppedTyping = Timer(duration, () => search(value)),
//     );
//   }

//   search(value) async {
//     setState(() {
//       searchValue = value;
//     });
//     await pendingDocsController.getAllPendingDocs();
//   }

//   TaskController taskController = Get.find();
//   int selectedTabIndex = 0;
//   List tabsList = ['all_sales_invoices'];
//   String searchValueInTasks = '';
//   Timer? searchOnStoppedTypingInTasks;

//   // _onChangeTaskSearchHandler(value) {
//   //   const duration = Duration(
//   //     milliseconds: 800,
//   //   ); // set the duration that you want call search() after that.
//   //   if (searchOnStoppedTypingInTasks != null) {
//   //     setState(() => searchOnStoppedTypingInTasks!.cancel()); // clear timer
//   //   }
//   //   setState(
//   //     () =>
//   //         searchOnStoppedTypingInTasks = Timer(
//   //           duration,
//   //           () => searchOnTask(value),
//   //         ),
//   //   );
//   // }

//   // searchOnTask(value) async {
//   //   setState(() {
//   //     searchValueInTasks = value;
//   //   });
//   //   await taskController.getAllTasksFromBack(value);
//   // }

//   _salesInvoiceSearchHandler(value) {
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
//             () => searchOnSalesInvoice(value),
//           ),
//     );
//   }

//   searchOnSalesInvoice(value) async {
//     pendingDocsController.setSearchInPendingDocsController(value);
//     await pendingDocsController.getAllPendingDocs();
//   }

//   Future<void> generatePdfFromImageUrl() async {
//     String companyLogo = await getCompanyLogoFromPref();

//     // 1. Download image
//     final response = await http.get(Uri.parse(companyLogo));
//     if (response.statusCode != 200) {
//       throw Exception('Failed to load image');
//     }

//     final Uint8List imageBytes = response.bodyBytes;
//     // String companyLogo = await getCompanyLogoFromPref();
//     // final Uint8List logoBytes = await fetchImage(
//     //   companyLogo,
//     // );
//     salesInvoiceController.setLogo(imageBytes);
//   }

//   @override
//   void initState() {
//     pendingDocsController.searchInPendingDocsController.text = '';
//     listViewLength =
//         Sizes.deviceHeight *
//         (0.09 * salesInvoiceController.SalesInvoicesList.length);
//     // salesOrderController.getAllSalesOrderFromBackWithoutEcxcept();
//     salesInvoiceController.getFieldsForCreateSalesInvoiceFromBack();
//     pendingDocsController.getAllPendingDocs();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<PendingDocsReviewController>(
//       builder: (cont) {
//         return Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: MediaQuery.of(context).size.width * 0.02,
//           ),
//           height: MediaQuery.of(context).size.height * 0.85,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     PageTitle(text: 'to_deliver'.tr),
//                     ReusableButtonWithColor(
//                       width: MediaQuery.of(context).size.width * 0.15,
//                       height: 45,
//                       onTapFunction: () {
//                         homeController.selectedTab.value = 'new_sales_invoice';
//                       },
//                       btnText: 'create_sales_invoice'.tr,
//                     ),
//                   ],
//                 ),
//                 gapH24,
//                 SizedBox(
//                   // width: MediaQuery.of(context).size.width * 0.59,
//                   child: ReusableSearchTextField(
//                     hint: '${"search".tr}...',
//                     textEditingController: cont.searchInPendingDocsController,
//                     onChangedFunc: (value) {
//                       if (selectedTabIndex == 1) {
//                         // cont.searchInQuotationsController.text=value;
//                         // _onChangeTaskSearchHandler(value);
//                       } else {
//                         _salesInvoiceSearchHandler(value);
//                       }
//                     },
//                     validationFunc: () {},
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.1),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Wrap(
//                       spacing: 0.0,
//                       direction: Axis.horizontal,
//                       children:
//                           tabsList
//                               .map(
//                                 (element) => ReusableBuildTabChipItem(
//                                   index: tabsList.indexOf(element),
//                                   function: () {
//                                     setState(() {
//                                       selectedTabIndex = tabsList.indexOf(
//                                         element,
//                                       );
//                                     });
//                                   },
//                                   isClicked:
//                                       selectedTabIndex ==
//                                       tabsList.indexOf(element),
//                                   name: element,
//                                 ),
//                               )
//                               .toList(),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Container(
//                       //   padding:
//                       //       const EdgeInsets.symmetric(vertical: 15),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 5,
//                         vertical: 15,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Primary.primary,
//                         borderRadius: const BorderRadius.all(
//                           Radius.circular(6),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,

//                         children: [
//                           tableTitleWithOrderArrow(
//                             'number'.tr,
//                             MediaQuery.of(context).size.width * 0.07,
//                             () {
//                               setState(() {
//                                 isNumberOrderedUp = !isNumberOrderedUp;
//                                 isNumberOrderedUp
//                                     ? cont.salesInvoicesPendingDocs.sort(
//                                       (a, b) => a['salesInvoiceNumber']
//                                           .compareTo(b['salesInvoiceNumber']),
//                                     )
//                                     : cont.salesInvoicesPendingDocs.sort(
//                                       (a, b) => b['salesInvoiceNumber']
//                                           .compareTo(a['salesInvoiceNumber']),
//                                     );
//                               });
//                             },
//                           ),
//                           tableTitleWithOrderArrow(
//                             'creation'.tr,
//                             MediaQuery.of(context).size.width * 0.07,
//                             () {
//                               setState(() {
//                                 isCreationOrderedUp = !isCreationOrderedUp;
//                                 isCreationOrderedUp
//                                     ? cont.salesInvoicesPendingDocs.sort(
//                                       (a, b) => a['createdAtDate'].compareTo(
//                                         b['createdAtDate'],
//                                       ),
//                                     )
//                                     : cont.salesInvoicesPendingDocs.sort(
//                                       (a, b) => b['createdAtDate'].compareTo(
//                                         a['createdAtDate'],
//                                       ),
//                                     );
//                               });
//                             },
//                           ),

//                           tableTitleWithOrderArrow(
//                             'customer'.tr,
//                             MediaQuery.of(context).size.width * 0.07,
//                             () {
//                               setState(() {
//                                 isCustomerOrderedUp = !isCustomerOrderedUp;
//                                 isCustomerOrderedUp
//                                     ? cont.salesInvoicesPendingDocs.sort(
//                                       (a, b) => '${a['client']['name']}'
//                                           .compareTo('${b['client']['name']}'),
//                                     )
//                                     : cont.salesInvoicesPendingDocs.sort(
//                                       (a, b) => '${b['client']['name']}'
//                                           .compareTo('${a['client']['name']}'),
//                                     );
//                               });
//                             },
//                           ),
//                           tableTitleWithOrderArrow(
//                             'salesperson'.tr,
//                             MediaQuery.of(context).size.width * 0.07,
//                             () {
//                               setState(() {
//                                 isSalespersonOrderedUp =
//                                     !isSalespersonOrderedUp;
//                                 isSalespersonOrderedUp
//                                     ? cont.salesInvoicesPendingDocs.sort(
//                                       (a, b) => a['salesperson']['name']
//                                           .compareTo(b['salesperson']['name']),
//                                     )
//                                     : cont.salesInvoicesPendingDocs.sort(
//                                       (a, b) => b['salesperson']['name']
//                                           .compareTo(a['salesperson']['name']),
//                                     );
//                               });
//                             },
//                           ),
//                           tableTitleWithOrderArrow(
//                             'warehouse'.tr,
//                             MediaQuery.of(context).size.width * 0.07,
//                             () {
//                               setState(() {
//                                 isSalespersonOrderedUp =
//                                     !isSalespersonOrderedUp;
//                                 isSalespersonOrderedUp
//                                     ? cont.salesInvoicesPendingDocs.sort(
//                                       (
//                                         a,
//                                         b,
//                                       ) => a['deliveredFromWarehouse']['name']
//                                           .compareTo(
//                                             b['deliveredFromWarehouse']['name'],
//                                           ),
//                                     )
//                                     : cont.salesInvoicesPendingDocs.sort(
//                                       (
//                                         a,
//                                         b,
//                                       ) => b['deliveredFromWarehouse']['name']
//                                           .compareTo(
//                                             a['deliveredFromWarehouse']['name'],
//                                           ),
//                                     );
//                               });
//                             },
//                           ),
//                           // TableTitle(
//                           //   text: 'task'.tr,
//                           //   width:
//                           //       MediaQuery.of(context).size.width *
//                           //       0.07, //085
//                           // ),
//                           TableTitle(
//                             text: 'total'.tr,
//                             width:
//                                 MediaQuery.of(context).size.width * 0.06, //085
//                           ),
//                           TableTitle(
//                             text: 'cur'.tr,
//                             isCentered: false,
//                             width:
//                                 MediaQuery.of(context).size.width * 0.04, //085
//                           ),
//                           TableTitle(
//                             text: 'status'.tr,
//                             width: 90, //085
//                           ),
//                           TableTitle(
//                             text: 'more_options'.tr,
//                             width: MediaQuery.of(context).size.width * 0.11,
//                           ),
//                           tableTitleWithOrderArrow(
//                             'delivery_date'.tr,
//                             MediaQuery.of(context).size.width * 0.07,
//                             () {
//                               setState(() {
//                                 isCreationOrderedUp = !isCreationOrderedUp;
//                                 isCreationOrderedUp
//                                     ? cont.salesInvoicesPendingDocs.sort(
//                                       (a, b) => a['invoiceDeliverytDate']
//                                           .compareTo(b['invoiceDeliverytDate']),
//                                     )
//                                     : cont.salesInvoicesPendingDocs.sort(
//                                       (a, b) => b['invoiceDeliverytDate']
//                                           .compareTo(a['invoiceDeliverytDate']),
//                                     );
//                               });
//                             },
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 0.01,
//                           ),
//                         ],
//                       ),
//                     ),
//                     cont.isPendingDocsFetched
//                         ? Container(
//                           color: Colors.white,
//                           // height: listViewLength,
//                           height:
//                               MediaQuery.of(context).size.height *
//                               0.4, //listViewLength
//                           child: ListView.builder(
//                             itemCount: cont.salesInvoicesPendingDocs.length,
//                             itemBuilder:
//                                 (context, index) => Column(
//                                   children: [
//                                     SalesInvoiceAsRowInTable(
//                                       info:
//                                           cont.salesInvoicesPendingDocs[index],
//                                       index: index,
//                                     ),
//                                     const Divider(),
//                                   ],
//                                 ),
//                           ),
//                         )
//                         : const CircularProgressIndicator(),
//                     // Row(
//                     //   mainAxisAlignment: MainAxisAlignment.end,
//                     //   children: [
//                     //     Text(
//                     //       '${'rows_per_page'.tr}:  ',
//                     //       style: const TextStyle(
//                     //           fontSize: 13, color: Colors.black54),
//                     //     ),
//                     //     Container(
//                     //       width: 60,
//                     //       height: 30,
//                     //       decoration: BoxDecoration(
//                     //           borderRadius: BorderRadius.circular(6),
//                     //           border: Border.all(color: Colors.black, width: 2)),
//                     //       child: Center(
//                     //         child: DropdownButtonHideUnderline(
//                     //           child: DropdownButton<String>(
//                     //             borderRadius: BorderRadius.circular(0),
//                     //             items: ['10', '20', '50', 'all'.tr]
//                     //                 .map((String value) {
//                     //               return DropdownMenuItem<String>(
//                     //                 value: value,
//                     //                 child: Text(
//                     //                   value,
//                     //                   style: const TextStyle(
//                     //                       fontSize: 12, color: Colors.grey),
//                     //                 ),
//                     //               );
//                     //             }).toList(),
//                     //             value: selectedNumberOfRows,
//                     //             onChanged: (val) {
//                     //               setState(() {
//                     //                 selectedNumberOfRows = val!;
//                     //               if(val=='10'){
//                     //                 listViewLength = cont.quotationsList.length < 10
//                     //                     ?Sizes.deviceHeight * (0.09 * cont.quotationsList.length)
//                     //                     : Sizes.deviceHeight * (0.09 * 10);
//                     //                 selectedNumberOfRowsAsInt=cont.quotationsList.length < 10? cont.quotationsList.length:10;
//                     //               }if(val=='20'){
//                     //                 listViewLength = cont.quotationsList.length < 20
//                     //                     ? Sizes.deviceHeight * (0.09 * cont.quotationsList.length)
//                     //                     : Sizes.deviceHeight * (0.09 * 20);
//                     //                 selectedNumberOfRowsAsInt=cont.quotationsList.length < 20? cont.quotationsList.length:20;
//                     //               }if(val=='50'){
//                     //                 listViewLength = cont.quotationsList.length < 50
//                     //                     ? Sizes.deviceHeight * (0.09 * cont.quotationsList.length)
//                     //                     : Sizes.deviceHeight * (0.09 * 50);
//                     //                 selectedNumberOfRowsAsInt=cont.quotationsList.length < 50? cont.quotationsList.length:50;
//                     //               }if(val=='all'.tr){
//                     //                 listViewLength = Sizes.deviceHeight * (0.09 * cont.quotationsList.length);
//                     //                 selectedNumberOfRowsAsInt= cont.quotationsList.length;
//                     //               }
//                     //               });
//                     //             },
//                     //           ),
//                     //         ),
//                     //       ),
//                     //     ),
//                     //     gapW16,
//                     //     Text(selectedNumberOfRows=='all'.tr?'${'all'.tr} of ${quotationsList.length}':'$start-$selectedNumberOfRows of ${quotationsList.length}',
//                     //         style: const TextStyle(
//                     //             fontSize: 13, color: Colors.black54)),
//                     //     gapW16,
//                     //     InkWell(
//                     //         onTap: () {
//                     //           setState(() {
//                     //             isArrowBackClicked = !isArrowBackClicked;
//                     //             isArrowForwardClicked = false;
//                     //           });
//                     //         },
//                     //         child: Row(
//                     //           children: [
//                     //             Icon(
//                     //               Icons.skip_previous,
//                     //               color: isArrowBackClicked
//                     //                   ? Colors.black87
//                     //                   : Colors.grey,
//                     //             ),
//                     //             Icon(
//                     //               Icons.navigate_before,
//                     //               color: isArrowBackClicked
//                     //                   ? Colors.black87
//                     //                   : Colors.grey,
//                     //             ),
//                     //           ],
//                     //         )),
//                     //     gapW10,
//                     //     InkWell(
//                     //         onTap: () {
//                     //           setState(() {
//                     //             isArrowForwardClicked = !isArrowForwardClicked;
//                     //             isArrowBackClicked = false;
//                     //           });
//                     //         },
//                     //         child: Row(
//                     //           children: [
//                     //             Icon(
//                     //               Icons.navigate_next,
//                     //               color: isArrowForwardClicked
//                     //                   ? Colors.black87
//                     //                   : Colors.grey,
//                     //             ),
//                     //             Icon(
//                     //               Icons.skip_next,
//                     //               color: isArrowForwardClicked
//                     //                   ? Colors.black87
//                     //                   : Colors.grey,
//                     //             ),
//                     //           ],
//                     //         )),
//                     //     gapW40,
//                     //   ],
//                     // )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

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
//                         text.length > 8 ? '${text.substring(0, 8)}...' : text,
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
//                         '${text.length > 7 ? text.substring(0, 6) : text}...',
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

// class SalesInvoiceAsRowInTable extends StatefulWidget {
//   const SalesInvoiceAsRowInTable({
//     super.key,
//     required this.info,
//     required this.index,
//     this.isDesktop = true,
//   });
//   final Map info;
//   final int index;
//   final bool isDesktop;

//   @override
//   State<SalesInvoiceAsRowInTable> createState() =>
//       _SalesInvoiceAsRowInTableState();
// }

// class _SalesInvoiceAsRowInTableState extends State<SalesInvoiceAsRowInTable> {
//   String itemName = '';
//   double itemPrice = 0;
//   double itemTotal = 0;
//   double totalAllItems = 0;
//   String itemBrand = '';
//   String itemImage = '';
//   String itemDescription = '';
//   String qty = '0.0';
//   double discountOnAllItem = 0.0;
//   double totalPriceAfterDiscount = 0.0;
//   double additionalSpecialDiscount = 0.0;
//   double totalPriceAfterSpecialDiscount = 0.0;
//   double totalPriceAfterSpecialDiscountBysalesInvoiceCurrency = 0.0;
//   double vatBySalesInvoiceCurrency = 0.0;
//   double finalPriceBySalesInvoiceCurrency = 0.0;
//   List itemsInfoPrint = [];
//   Map salesInvoiceItemInfo = {};

//   String brand = '';

//   final HomeController homeController = Get.find();
//   final SalesInvoiceController salesInvoiceController = Get.find();
//   final PendingDocsReviewController pendingDocsController = Get.find();

//   String diss = '0';
//   double totalBeforeVatvValue = 0.0;
//   double globalDiscountValue = 0.0;
//   double specialDiscountValue = 0.0;
//   double specialDisc = 0.0;
//   double res = 0.0;
//   void _showPopupMenu(BuildContext context, TapDownDetails details) {
//     final RenderBox overlay =
//         Overlay.of(context).context.findRenderObject() as RenderBox;

//     showMenu(
//       context: context,
//       position: RelativeRect.fromRect(
//         details.globalPosition & const Size(100, 100), // Position of click
//         Offset.zero & overlay.size,
//       ),
//       items: [
//         PopupMenuItem(
//           child: Text("schedule_task".tr),
//           onTap: () {
//             showDialog<String>(
//               context: context,
//               builder:
//                   (BuildContext context) => AlertDialog(
//                     backgroundColor: Colors.white,
//                     shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(9)),
//                     ),
//                     elevation: 0,
//                     content: ScheduleTaskDialogContent(
//                       quotationId: '${widget.info['id']}',
//                       isUpdate: false,
//                       task: {},
//                     ),
//                   ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   ExchangeRatesController exchangeRatesController = Get.find();

//   String cashMethodId = '';
//   String clientId = '';
//   String pricelistId = '';
//   String salespersonId = ' ';
//   String commissionMethodId = '';
//   String currencyId = ' ';
//   String warehouseId = ' ';
//   String msg = ' ';

//   @override
//   void initState() {
//     if (widget.info['cashingMethod'] != null) {
//       cashMethodId = '${widget.info['cashingMethod']['id']}';
//     }
//     if (widget.info['deliveredFromWarehouse'] != null) {
//       warehouseId = '${widget.info['deliveredFromWarehouse']['id']}';
//     }
//     if (widget.info['commissionMethod'] != null) {
//       commissionMethodId = '${widget.info['commissionMethod']['id']}';
//     }
//     if (widget.info['currency'] != null) {
//       currencyId = '${widget.info['currency']['id']}';
//     }
//     if (widget.info['client'] != null) {
//       clientId = widget.info['client']['id'].toString();
//     }
//     if (widget.info['pricelist'] != null) {
//       pricelistId = widget.info['pricelist']['id'].toString();
//     }
//     if (widget.info['salesperson'] != null) {
//       salespersonId = widget.info['salesperson']['id'].toString();
//     }
//     salesInvoiceController.orderLinesSalesInvoiceList = {};
//     salesInvoiceController.rowsInListViewInSalesInvoice = {};
//     salesInvoiceController.selectedSalesInvoiceData['orderLines'] =
//         widget.info['orderLines'] ?? '';
//     for (
//       int i = 0;
//       i < salesInvoiceController.selectedSalesInvoiceData['orderLines'].length;
//       i++
//     ) {
//       salesInvoiceController.rowsInListViewInSalesInvoice[i + 1] =
//           salesInvoiceController.selectedSalesInvoiceData['orderLines'][i];
//     }
//     var keys =
//         salesInvoiceController.rowsInListViewInSalesInvoice.keys.toList();
//     for (int i = 0; i < widget.info['orderLines'].length; i++) {
//       if (widget.info['orderLines'][i]['line_type_id'] == 2) {
//         salesInvoiceController.unitPriceControllers[i + 1] =
//             TextEditingController();
//         Widget p = ReusableItemRow(
//           index: i + 1,
//           info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
//         );

//         salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
//       } else if (widget.info['orderLines'][i]['line_type_id'] == 1) {
//         Widget p = ReusableTitleRow(
//           index: i + 1,
//           info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
//         );
//         salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
//       } else if (widget.info['orderLines'][i]['line_type_id'] == 5) {
//         Widget p = ReusableNoteRow(
//           index: i + 1,
//           info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
//         );
//         salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
//       } else if (widget.info['orderLines'][i]['line_type_id'] == 4) {
//         Widget p = ReusableImageRow(
//           index: i + 1,
//           info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
//         );
//         salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
//       } else if (widget.info['orderLines'][i]['line_type_id'] == 3) {
//         salesInvoiceController.combosPriceControllers[i + 1] =
//             TextEditingController();
//         Widget p = ReusableComboRow(
//           index: i + 1,
//           info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
//         );
//         salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
//       }
//     }
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.all(Radius.circular(0)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,

//           children: [
//             TableItem(
//               text: '${widget.info['salesInvoiceNumber'] ?? ''}',
//               width:
//                   widget.isDesktop
//                       ? MediaQuery.of(context).size.width * 0.07
//                       : 150,
//             ),
//             TableItem(
//               text: '${widget.info['createdAtDate'] ?? ''}',
//               width:
//                   widget.isDesktop
//                       ? MediaQuery.of(context).size.width * 0.07
//                       : 150,
//             ),

//             TableItem(
//               text:
//                   widget.info['client'] == null
//                       ? ''
//                       : '${widget.info['client']['name'] ?? ''}',
//               width:
//                   widget.isDesktop
//                       ? MediaQuery.of(context).size.width * 0.07
//                       : 150,
//             ),
//             TableItem(
//               text:
//                   widget.info['salesperson'] == null
//                       ? ''
//                       : '${widget.info['salesperson']['name'] ?? ''}',
//               width:
//                   widget.isDesktop
//                       ? MediaQuery.of(context).size.width * 0.07
//                       : 150,
//             ),
//             TableItem(
//               text:
//                   widget.info['deliveredFromWarehouse'] == null
//                       ? ''
//                       : '${widget.info['deliveredFromWarehouse']['name'] ?? ''}',
//               width:
//                   widget.isDesktop
//                       ? MediaQuery.of(context).size.width * 0.07
//                       : 150,
//             ),

//             SizedBox(
//               width:
//                   widget.isDesktop
//                       ? MediaQuery.of(context).size.width * 0.06
//                       : 150,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(right: 5.0),
//                     child: Text(
//                       numberWithComma('${widget.info['total'] ?? ''}'),
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: TypographyColor.textTable,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             TableItem(
//               text: '${widget.info['currency']['name'] ?? ''}',
//               isCentered: false,
//               width:
//                   widget.isDesktop
//                       ? MediaQuery.of(context).size.width * 0.04
//                       : 150,
//             ),
//             SizedBox(
//               width: widget.isDesktop ? 90 : 150,
//               child: Center(
//                 child: Container(
//                   width: 90,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 1,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color:
//                         widget.info['status'] == "pending"
//                             ? Others.orangeStatusColor
//                             : widget.info['status'] == 'cancelled'
//                             ? Others.redStatusColor
//                             : widget.info['status'] == 'sent'
//                             ? Colors.blue
//                             : Others.greenStatusColor,
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${widget.info['status'] ?? ''}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             GetBuilder<SalesInvoiceController>(
//               builder: (cont) {
//                 return Container(
//                   padding: EdgeInsets.only(left: 10),
//                   width:
//                       widget.isDesktop
//                           ? MediaQuery.of(context).size.width * 0.11
//                           : 150,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Tooltip(
//                         message: 'preview'.tr,
//                         child: InkWell(
//                           onTap: () async {
//                             itemsInfoPrint = [];
//                             salesInvoiceItemInfo = {};
//                             totalAllItems = 0;
//                             cont.totalAllItems = 0;
//                             totalAllItems = 0;
//                             cont.totalAllItems = 0;
//                             totalPriceAfterDiscount = 0;
//                             additionalSpecialDiscount = 0;
//                             totalPriceAfterSpecialDiscount = 0;
//                             totalPriceAfterSpecialDiscountBysalesInvoiceCurrency =
//                                 0;
//                             vatBySalesInvoiceCurrency = 0;
//                             vatBySalesInvoiceCurrency = 0;
//                             finalPriceBySalesInvoiceCurrency = 0;
//                             for (var item in widget.info['orderLines']) {
//                               if ('${item['line_type_id']}' == '2') {
//                                 qty = item['item_quantity'];
//                                 var map =
//                                     cont.itemsMap[item['item_id'].toString()];
//                                 itemName = map['item_name'];
//                                 itemPrice = double.parse(
//                                   '${item['item_unit_price'] ?? '0'}',
//                                 );
//                                 //     map['unitPrice'] ?? 0.0;
//                                 // formatDoubleWithCommas(map['unitPrice']);
//                                 itemDescription = item['item_description'];
//                                 itemImage =
//                                     '${map['images']}' != '[]' &&
//                                             map['images'] != null
//                                         ? '$baseImage${map['images'][0]['img_url']}'
//                                         : '';
//                                 // itemCurrencyName = map['currency']['name'];
//                                 // itemCurrencySymbol = map['currency']['symbol'];
//                                 // itemCurrencyLatestRate =
//                                 //     map['currency']['latest_rate'];
//                                 if (map['itemGroups'] != null) {
//                                   var firstBrandObject = map['itemGroups']
//                                       .firstWhere(
//                                         (obj) =>
//                                             obj["root_name"]?.toLowerCase() ==
//                                             "brand".toLowerCase(),
//                                         orElse: () => null,
//                                       );
//                                   brand =
//                                       firstBrandObject == null
//                                           ? ''
//                                           : firstBrandObject['name'] ?? '';
//                                 }
//                                 itemTotal = double.parse(
//                                   '${item['item_total']}',
//                                 );
//                                 // itemTotal = double.parse(qty) * itemPrice;
//                                 totalAllItems += itemTotal;
//                                 salesInvoiceItemInfo = {
//                                   'line_type_id': '2',
//                                   'item_name': itemName,
//                                   'item_description': itemDescription,
//                                   'item_quantity': qty,
//                                   'item_discount': item['item_discount'] ?? '0',
//                                   'item_unit_price': formatDoubleWithCommas(
//                                     itemPrice,
//                                   ),
//                                   'item_total': formatDoubleWithCommas(
//                                     itemTotal,
//                                   ),
//                                   'item_image': itemImage,
//                                   'item_brand': brand,
//                                   'title': '',
//                                   'isImageList': false,
//                                   'note': '',
//                                   'image': '',
//                                 };
//                                 itemsInfoPrint.add(salesInvoiceItemInfo);
//                               } else if ('${item['line_type_id']}' == '3') {
//                                 var qty = item['combo_quantity'];
//                                 // var map =
//                                 // cont
//                                 //     .combosMap[item['combo_id']
//                                 //     .toString()];
//                                 var ind = cont.combosIdsList.indexOf(
//                                   item['combo_id'].toString(),
//                                 );
//                                 var itemName = cont.combosNamesList[ind];
//                                 var itemPrice = double.parse(
//                                   '${item['combo_unit_price'] ?? 0.0}',
//                                 );
//                                 var itemDescription = item['combo_description'];

//                                 var itemTotal = double.parse(
//                                   '${item['combo_total']}',
//                                 );
//                                 totalAllItems += itemTotal;
//                                 var quotationItemInfo = {
//                                   'line_type_id': '3',
//                                   'item_name': itemName,
//                                   'item_description': itemDescription,
//                                   'item_quantity': qty,
//                                   'item_unit_price': formatDoubleWithCommas(
//                                     itemPrice,
//                                   ),
//                                   'item_discount':
//                                       item['combo_discount'] ?? '0',
//                                   'item_total': formatDoubleWithCommas(
//                                     itemTotal,
//                                   ),
//                                   'note': '',
//                                   'item_image': '',
//                                   'item_brand': '',
//                                   'isImageList': false,
//                                   'title': '',
//                                   'image': '',
//                                 };
//                                 itemsInfoPrint.add(quotationItemInfo);
//                               } else if ('${item['line_type_id']}' == '1') {
//                                 var quotationItemInfo = {
//                                   'line_type_id': '1',
//                                   'item_name': '',
//                                   'item_description': '',
//                                   'item_quantity': '',
//                                   'item_unit_price': '',
//                                   'item_discount': '0',
//                                   'item_total': '',
//                                   'item_image': '',
//                                   'item_brand': '',
//                                   'note': '',
//                                   'isImageList': false,
//                                   'title': item['title'],
//                                   'image': '',
//                                 };
//                                 itemsInfoPrint.add(quotationItemInfo);
//                               } else if ('${item['line_type_id']}' == '5') {
//                                 var quotationItemInfo = {
//                                   'line_type_id': '5',
//                                   'item_name': '',
//                                   'item_description': '',
//                                   'item_quantity': '',
//                                   'item_unit_price': '',
//                                   'item_discount': '0',
//                                   'item_total': '',
//                                   'item_image': '',
//                                   'item_brand': '',
//                                   'title': '',
//                                   'note': item['note'],
//                                   'isImageList': false,
//                                   'image': '',
//                                 };
//                                 itemsInfoPrint.add(quotationItemInfo);
//                               } else if ('${item['line_type_id']}' == '4') {
//                                 var quotationItemInfo = {
//                                   'line_type_id': '4',
//                                   'item_name': '',
//                                   'item_description': '',
//                                   'item_quantity': '',
//                                   'item_unit_price': '',
//                                   'item_discount': '0',
//                                   'item_total': '',
//                                   'item_image': '',
//                                   'item_brand': '',
//                                   'title': '',
//                                   'note': '',
//                                   'image': '$baseImage${item['image']}',
//                                   'isImageList': false,
//                                 };
//                                 itemsInfoPrint.add(quotationItemInfo);
//                               }
//                             }

//                             totalPriceAfterDiscount =
//                                 totalAllItems - discountOnAllItem;
//                             additionalSpecialDiscount =
//                                 totalPriceAfterDiscount *
//                                 double.parse(
//                                   widget.info['specialDiscount'] ?? '0',
//                                 ) /
//                                 100;
//                             totalPriceAfterSpecialDiscount =
//                                 totalPriceAfterDiscount -
//                                 additionalSpecialDiscount;
//                             totalPriceAfterSpecialDiscountBysalesInvoiceCurrency =
//                                 totalPriceAfterSpecialDiscount;
//                             vatBySalesInvoiceCurrency =
//                                 '${widget.info['vatExempt']}' == '1'
//                                     ? 0
//                                     : (totalPriceAfterSpecialDiscountBysalesInvoiceCurrency *
//                                             double.parse(
//                                               await getCompanyVatFromPref(),
//                                             )) /
//                                         100;
//                             finalPriceBySalesInvoiceCurrency =
//                                 totalPriceAfterSpecialDiscountBysalesInvoiceCurrency +
//                                 vatBySalesInvoiceCurrency;
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (BuildContext context) {
//                                   // print('widget.info[ ${widget.info['termsAndConditions']}');
//                                   return PrintSalesInvoice(
//                                     isPrintedAs0:
//                                         '${widget.info['printedAsPercentage']}' ==
//                                                 '1'
//                                             ? true
//                                             : false,
//                                     isVatNoPrinted:
//                                         '${widget.info['notPrinted']}' == '1'
//                                             ? true
//                                             : false,
//                                     isPrintedAsVatExempt:
//                                         '${widget.info['printedAsVatExempt']}' ==
//                                                 '1'
//                                             ? true
//                                             : false,
//                                     isInSalesInvoice: true,
//                                     salesInvoiceNumber:
//                                         widget.info['salesInvoiceNumber'] ?? '',
//                                     creationDate:
//                                         widget.info['valueDate'] ?? '',
//                                     ref: widget.info['reference'] ?? '',
//                                     receivedUser: '',
//                                     senderUser: homeController.userName,
//                                     status: widget.info['status'] ?? '',
//                                     totalBeforeVat:
//                                         widget.info['totalBeforeVat'] ?? '',
//                                     discountOnAllItem:
//                                         discountOnAllItem.toString(),
//                                     totalAllItems: formatDoubleWithCommas(
//                                       totalAllItems,
//                                     ),

//                                     globalDiscount:
//                                         widget.info['globalDiscount'] ?? '0',

//                                     totalPriceAfterDiscount:
//                                         formatDoubleWithCommas(
//                                           totalPriceAfterDiscount,
//                                         ),
//                                     additionalSpecialDiscount:
//                                         additionalSpecialDiscount
//                                             .toStringAsFixed(2),
//                                     totalPriceAfterSpecialDiscount:
//                                         formatDoubleWithCommas(
//                                           totalPriceAfterSpecialDiscount,
//                                         ),
//                                     // itemCurrencyName: itemCurrencyName,
//                                     // itemCurrencySymbol: itemCurrencySymbol,
//                                     // itemCurrencyLatestRate:
//                                     //     itemCurrencyLatestRate,
//                                     totalPriceAfterSpecialDiscountBySalesInvoiceCurrency:
//                                         formatDoubleWithCommas(
//                                           totalPriceAfterSpecialDiscountBysalesInvoiceCurrency,
//                                         ),

//                                     vatBySalesInvoiceCurrency:
//                                         formatDoubleWithCommas(
//                                           vatBySalesInvoiceCurrency,
//                                         ),
//                                     finalPriceBySalesInvoiceCurrency:
//                                         formatDoubleWithCommas(
//                                           finalPriceBySalesInvoiceCurrency,
//                                         ),
//                                     specialDisc: specialDisc.toString(),
//                                     specialDiscount:
//                                         widget.info['specialDiscount'] ?? '0',
//                                     specialDiscountAmount:
//                                         widget.info['specialDiscountAmount'] ??
//                                         '',
//                                     salesPerson:
//                                         widget.info['salesperson'] != null
//                                             ? widget.info['salesperson']['name']
//                                             : '---',
//                                     salesInvoiceCurrency:
//                                         widget.info['currency']['name'] ?? '',
//                                     salesInvoiceCurrencySymbol:
//                                         widget.info['currency']['symbol'] ?? '',
//                                     salesInvoiceCurrencyLatestRate:
//                                         widget
//                                             .info['currency']['latest_rate'] ??
//                                         '',
//                                     clientPhoneNumber:
//                                         widget.info['client'] != null
//                                             ? widget.info['client']['phoneNumber'] ??
//                                                 '---'
//                                             : "---",
//                                     clientName:
//                                         widget.info['client']['name'] ?? '',
//                                     termsAndConditions:
//                                         widget.info['termsAndConditions'] ?? '',
//                                     itemsInfoPrint: itemsInfoPrint,
//                                   );
//                                 },
//                               ),
//                             );
//                           },
//                           child: Icon(
//                             Icons.remove_red_eye_outlined,
//                             color: Primary.primary,
//                           ),
//                         ),
//                       ),
//                       Tooltip(
//                         message: 'modify'.tr,
//                         child: InkWell(
//                           onTap: () async {
//                             showDialog<String>(
//                               context: context,
//                               builder:
//                                   (BuildContext context) => AlertDialog(
//                                     backgroundColor: Colors.white,
//                                     shape: const RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(9),
//                                       ),
//                                     ),
//                                     elevation: 0,
//                                     content: UpdateSalesInvoiceDialog(
//                                       index: widget.index,
//                                       info: widget.info,
//                                     ),
//                                   ),
//                             );
//                           },
//                           child: Icon(Icons.edit, color: Primary.primary),
//                         ),
//                       ),
//                       Tooltip(
//                         message: 'confirm'.tr,
//                         child: InkWell(
//                           onTap: () async {
//                             print("Confirm-----------");
//                             print("NEWMAP-------------------");
//                             Map<int, dynamic> orderLinesMap = {
//                               for (
//                                 int i = 0;
//                                 i < widget.info['orderLines'].length;
//                                 i++
//                               )
//                                 (i + 1): widget.info['orderLines'][i],
//                             };
//                             print(orderLinesMap);
//                             var res = await updateSalesInvoice(
//                               '${widget.info['id']}',
//                               false,
//                               '${widget.info['reference'] ?? ''}',
//                               clientId,

//                               '${widget.info['valueDate'] ?? ''}',
//                               warehouseId,
//                               '', //todo paymentTermsController.text,
//                               pricelistId,
//                               currencyId,
//                               '${widget.info['termsAndConditions']}',
//                               salespersonId,
//                               commissionMethodId,
//                               cashMethodId,
//                               '${widget.info['commissionRate'] ?? ''}',
//                               '${widget.info['commissionTotal'] ?? ''}',
//                               '${widget.info['totalBeforeVat'] ?? '0.0'}', //total before vat
//                               '${widget.info['specialDiscountAmount'] ?? '0'}', // inserted by user
//                               '${widget.info['specialDiscount'] ?? '0'}', // calculated
//                               '${widget.info['globalDiscountAmount'] ?? ''}',
//                               '${widget.info['globalDiscount'] ?? ''}',
//                               '${widget.info['vat'] ?? ''}', //vat
//                               '${widget.info['vatLebanese'] ?? ''}',
//                               '${widget.info['total'] ?? ''}',
//                               '${widget.info['vatExempt'] ?? ''}',
//                               '${widget.info['notPrinted'] ?? ''}',
//                               '${widget.info['printedAsVatExempt'] ?? ''}',
//                               '${widget.info['printedAsPercentage'] ?? ''}',
//                               '${widget.info['vatInclusivePrices'] ?? ''}',
//                               '${widget.info['beforeVatPrices'] ?? ''}',

//                               '${widget.info['code'] ?? ''}',

//                               'confirmed', // status,
//                               // salesInvoiceController.newRowMap,
//                               orderLinesMap,
//                               '${widget.info['inputDate'] ?? ''}',
//                               '${widget.info['invoiceDeliveryDate'] ?? ''}',
//                             );
//                             if (res['success'] == true) {
//                               pendingDocsController.getAllPendingDocs();
//                               homeController.selectedTab.value =
//                                   "sales_invoice_summary";
//                               CommonWidgets.snackBar('Success', res['message']);
//                             } else {
//                               CommonWidgets.snackBar('error', res['message']);
//                             }
//                           },
//                           child: Icon(Icons.check, color: Primary.primary),
//                         ),
//                       ),
//                       Tooltip(
//                         message: 'cancel'.tr,
//                         child: InkWell(
//                           onTap: () async {
//                             print("Cancel-----------");
//                             print("NEWMAP-------------------");
//                             Map<int, dynamic> orderLinesMap = {
//                               for (
//                                 int i = 0;
//                                 i < widget.info['orderLines'].length;
//                                 i++
//                               )
//                                 (i + 1): widget.info['orderLines'][i],
//                             };
//                             print(orderLinesMap);
//                             var res = await updateSalesInvoice(
//                               '${widget.info['id']}',
//                               false,
//                               '${widget.info['reference'] ?? ''}',
//                               clientId,

//                               '${widget.info['valueDate'] ?? ''}',
//                               warehouseId,
//                               '', //todo paymentTermsController.text,
//                               pricelistId,
//                               currencyId,
//                               '${widget.info['termsAndConditions']}',
//                               salespersonId,
//                               commissionMethodId,
//                               cashMethodId,
//                               '${widget.info['commissionRate'] ?? ''}',
//                               '${widget.info['commissionTotal'] ?? ''}',
//                               '${widget.info['totalBeforeVat'] ?? '0.0'}', //total before vat
//                               '${widget.info['specialDiscountAmount'] ?? '0'}', // inserted by user
//                               '${widget.info['specialDiscount'] ?? '0'}', // calculated
//                               '${widget.info['globalDiscountAmount'] ?? ''}',
//                               '${widget.info['globalDiscount'] ?? ''}',
//                               '${widget.info['vat'] ?? ''}', //vat
//                               '${widget.info['vatLebanese'] ?? ''}',
//                               '${widget.info['total'] ?? ''}',
//                               '${widget.info['vatExempt'] ?? ''}',
//                               '${widget.info['notPrinted'] ?? ''}',
//                               '${widget.info['printedAsVatExempt'] ?? ''}',
//                               '${widget.info['printedAsPercentage'] ?? ''}',
//                               '${widget.info['vatInclusivePrices'] ?? ''}',
//                               '${widget.info['beforeVatPrices'] ?? ''}',

//                               '${widget.info['code'] ?? ''}',

//                               'cancelled', // status,

//                               orderLinesMap,
//                               '${widget.info['inputDate'] ?? ''}',
//                               '${widget.info['invoiceDeliveryDate'] ?? ''}',
//                             );
//                             if (res['success'] == true) {
//                               pendingDocsController.getAllPendingDocs();
//                               homeController.selectedTab.value =
//                                   "sales_invoice_summary";
//                               CommonWidgets.snackBar('Success', res['message']);
//                             } else {
//                               CommonWidgets.snackBar('error', res['message']);
//                             }
//                           },
//                           child: Icon(
//                             Icons.cancel_outlined,
//                             color: Primary.primary,
//                           ),
//                         ),
//                       ),
//                       // ReusableMore(
//                       //   itemsList: [
//                       //     PopupMenuItem<String>(
//                       //       value: '1',
//                       //       onTap: () async {
//                       //         itemsInfoPrint = [];
//                       //         salesInvoiceItemInfo = {};
//                       //         totalAllItems = 0;
//                       //         cont.totalAllItems = 0;
//                       //         totalAllItems = 0;
//                       //         cont.totalAllItems = 0;
//                       //         totalPriceAfterDiscount = 0;
//                       //         additionalSpecialDiscount = 0;
//                       //         totalPriceAfterSpecialDiscount = 0;
//                       //         totalPriceAfterSpecialDiscountBysalesInvoiceCurrency =
//                       //             0;
//                       //         vatBySalesInvoiceCurrency = 0;
//                       //         vatBySalesInvoiceCurrency = 0;
//                       //         finalPriceBySalesInvoiceCurrency = 0;
//                       //
//                       //         for (var item in widget.info['orderLines']) {
//                       //           if ('${item['line_type_id']}' == '2') {
//                       //             qty = item['item_quantity'];
//                       //             var map =
//                       //                 cont.itemsMap[item['item_id'].toString()];
//                       //             itemName = map['item_name'];
//                       //             itemPrice = double.parse(
//                       //               '${item['item_unit_price'] ?? '0'}',
//                       //             );
//                       //             //     map['unitPrice'] ?? 0.0;
//                       //             // formatDoubleWithCommas(map['unitPrice']);
//                       //
//                       //             itemDescription = item['item_description'];
//                       //
//                       //             itemImage =
//                       //                 '${map['images']}' != '[]'
//                       //                     ? '$baseImage${map['images'][0]['img_url']}'
//                       //                     : '';
//                       //             // itemCurrencyName = map['currency']['name'];
//                       //             // itemCurrencySymbol = map['currency']['symbol'];
//                       //             // itemCurrencyLatestRate =
//                       //             //     map['currency']['latest_rate'];
//                       //             var firstBrandObject = map['itemGroups']
//                       //                 .firstWhere(
//                       //                   (obj) =>
//                       //                       obj["root_name"]?.toLowerCase() ==
//                       //                       "brand".toLowerCase(),
//                       //                   orElse: () => null,
//                       //                 );
//                       //             brand =
//                       //                 firstBrandObject == null
//                       //                     ? ''
//                       //                     : firstBrandObject['name'] ?? '';
//                       //             itemTotal = double.parse('${item['item_total']}');
//                       //             // itemTotal = double.parse(qty) * itemPrice;
//                       //             totalAllItems += itemTotal;
//                       //             salesInvoiceItemInfo = {
//                       //               'line_type_id': '2',
//                       //               'item_name': itemName,
//                       //               'item_description': itemDescription,
//                       //               'item_quantity': qty,
//                       //               'item_discount': item['item_discount'] ?? '0',
//                       //               'item_unit_price': formatDoubleWithCommas(
//                       //                 itemPrice,
//                       //               ),
//                       //               'item_total': formatDoubleWithCommas(itemTotal),
//                       //               'item_image': itemImage,
//                       //               'item_brand': brand,
//                       //               'title': '',
//                       //               'isImageList': false,
//                       //               'note': '',
//                       //               'image': '',
//                       //             };
//                       //             itemsInfoPrint.add(salesInvoiceItemInfo);
//                       //           } else if ('${item['line_type_id']}' == '3') {
//                       //             var qty = item['item_quantity'];
//                       //             // var map =
//                       //             // cont
//                       //             //     .combosMap[item['combo_id']
//                       //             //     .toString()];
//                       //             var ind = cont.combosIdsList.indexOf(
//                       //               item['combo_id'].toString(),
//                       //             );
//                       //             var itemName = cont.combosNamesList[ind];
//                       //             var itemPrice = double.parse(
//                       //               '${item['combo_price'] ?? 0.0}',
//                       //             );
//                       //             var itemDescription = item['combo_description'];
//                       //
//                       //             var itemTotal = double.parse(
//                       //               '${item['combo_total']}',
//                       //             );
//                       //             // double.parse(qty) * itemPrice;
//                       //             var salesInvoiceItemInfo = {
//                       //               'line_type_id': '3',
//                       //               'item_name': itemName,
//                       //               'item_description': itemDescription,
//                       //               'item_quantity': qty,
//                       //               'item_unit_price': formatDoubleWithCommas(
//                       //                 itemPrice,
//                       //               ),
//                       //               'item_discount': item['combo_discount'] ?? '0',
//                       //               'item_total': formatDoubleWithCommas(itemTotal),
//                       //               'note': '',
//                       //               'item_image': '',
//                       //               'item_brand': '',
//                       //               'isImageList': false,
//                       //               'title': '',
//                       //               'image': '',
//                       //             };
//                       //             itemsInfoPrint.add(salesInvoiceItemInfo);
//                       //           } else if ('${item['line_type_id']}' == '1') {
//                       //             var salesInvoiceItemInfo = {
//                       //               'line_type_id': '1',
//                       //               'item_name': '',
//                       //               'item_description': '',
//                       //               'item_quantity': '',
//                       //               'item_unit_price': '',
//                       //               'item_discount': '0',
//                       //               'item_total': '',
//                       //               'item_image': '',
//                       //               'item_brand': '',
//                       //               'note': '',
//                       //               'isImageList': false,
//                       //               'title': item['title'],
//                       //               'image': '',
//                       //             };
//                       //             itemsInfoPrint.add(salesInvoiceItemInfo);
//                       //           } else if ('${item['line_type_id']}' == '5') {
//                       //             var salesInvoiceItemInfo = {
//                       //               'line_type_id': '5',
//                       //               'item_name': '',
//                       //               'item_description': '',
//                       //               'item_quantity': '',
//                       //               'item_unit_price': '',
//                       //               'item_discount': '0',
//                       //               'item_total': '',
//                       //               'item_image': '',
//                       //               'item_brand': '',
//                       //               'title': '',
//                       //               'note': item['note'],
//                       //               'isImageList': false,
//                       //               'image': '',
//                       //             };
//                       //             itemsInfoPrint.add(salesInvoiceItemInfo);
//                       //           } else if ('${item['line_type_id']}' == '4') {
//                       //             var salesInvoiceItemInfo = {
//                       //               'line_type_id': '4',
//                       //               'item_name': '',
//                       //               'item_description': '',
//                       //               'item_quantity': '',
//                       //               'item_unit_price': '',
//                       //               'item_discount': '0',
//                       //               'item_total': '',
//                       //               'item_image': '',
//                       //               'item_brand': '',
//                       //               'title': '',
//                       //               'note': '',
//                       //               'image': '$baseImage${item['image']}',
//                       //               'isImageList': false,
//                       //             };
//                       //             itemsInfoPrint.add(salesInvoiceItemInfo);
//                       //           }
//                       //         }
//                       //         // var primaryCurrency = await getCompanyPrimaryCurrencyFromPref();
//                       //         // var result = exchangeRatesController
//                       //         //     .exchangeRatesList
//                       //         //     .firstWhere(
//                       //         //       (item) =>
//                       //         //   item["currency"] == primaryCurrency,
//                       //         //   orElse: () => null,
//                       //         // );
//                       //         // var primaryLatestRate=
//                       //         // result != null
//                       //         //     ? '${result["exchange_rate"]}'
//                       //         //     : '1';
//                       //         // discountOnAllItem =
//                       //         //     totalAllItems *
//                       //         //     double.parse(
//                       //         //       widget.info['globalDiscount'] ?? '0',
//                       //         //     ) /
//                       //         //     100;
//                       //
//                       //         totalPriceAfterDiscount =
//                       //             totalAllItems - discountOnAllItem;
//                       //         additionalSpecialDiscount =
//                       //             totalPriceAfterDiscount *
//                       //             double.parse(
//                       //               widget.info['specialDiscount'] ?? '0',
//                       //             ) /
//                       //             100;
//                       //         totalPriceAfterSpecialDiscount =
//                       //             totalPriceAfterDiscount -
//                       //             additionalSpecialDiscount;
//                       //         totalPriceAfterSpecialDiscountBysalesInvoiceCurrency =
//                       //             totalPriceAfterSpecialDiscount;
//                       //         vatBySalesInvoiceCurrency =
//                       //             '${widget.info['vatExempt']}' == '1'
//                       //                 ? 0
//                       //                 : (totalPriceAfterSpecialDiscountBysalesInvoiceCurrency *
//                       //                         double.parse(
//                       //                           await getCompanyVatFromPref(),
//                       //                         )) /
//                       //                     100;
//                       //         finalPriceBySalesInvoiceCurrency =
//                       //             totalPriceAfterSpecialDiscountBysalesInvoiceCurrency;
//                       //         vatBySalesInvoiceCurrency;
//                       //
//                       //         widget.info['salesOrder'] == null
//                       //             ? msg =
//                       //                 '${widget.info['salesInvoiceNumber']} is new Sales Invoice'
//                       //             : widget.info['salesOrder']['quotation'] == null
//                       //             ? msg =
//                       //                 '${widget.info['salesInvoiceNumber']} is  Sales Order[${widget.info['salesOrder']['salesOrderNumber']}] And This Sales Order[${widget.info['salesOrder']['salesOrderNumber']}] is New Sales Order '
//                       //             : msg =
//                       //                 '${widget.info['salesInvoiceNumber']} is  Sales Order[${widget.info['salesOrder']['salesOrderNumber']}] And This Sales Order[${widget.info['salesOrder']['salesOrderNumber']}] is A Quotation [${widget.info['salesOrder']['quotation']['quotationNumber']}]';
//                       //
//                       //         Navigator.push(
//                       //           context,
//                       //           MaterialPageRoute(
//                       //             builder: (BuildContext context) {
//                       //               // print('widget.info[ ${widget.info['termsAndConditions']}');
//                       //               return PrintSalesInvoice(
//                       //                 sequencemsg: msg,
//                       //                 isPrintedAs0:
//                       //                     '${widget.info['printedAsPercentage']}' ==
//                       //                             '1'
//                       //                         ? true
//                       //                         : false,
//                       //                 isVatNoPrinted:
//                       //                     '${widget.info['notPrinted']}' == '1'
//                       //                         ? true
//                       //                         : false,
//                       //                 isPrintedAsVatExempt:
//                       //                     '${widget.info['printedAsVatExempt']}' ==
//                       //                             '1'
//                       //                         ? true
//                       //                         : false,
//                       //                 isInSalesInvoice: true,
//                       //                 salesInvoiceNumber:
//                       //                     widget.info['salesOrderNumber'] ?? '',
//                       //                 creationDate: widget.info['validity'] ?? '',
//                       //                 ref: widget.info['reference'] ?? '',
//                       //                 receivedUser: '',
//                       //                 senderUser: homeController.userName,
//                       //                 status: widget.info['status'] ?? '',
//                       //                 totalBeforeVat:
//                       //                     widget.info['totalBeforeVat'] ?? '',
//                       //                 discountOnAllItem:
//                       //                     discountOnAllItem.toString(),
//                       //                 totalAllItems:
//                       //                 // totalAllItems.toString()  ,
//                       //                 formatDoubleWithCommas(
//                       //                   totalPriceAfterDiscount,
//                       //                 ),
//                       //
//                       //                 globalDiscount:
//                       //                     widget.info['globalDiscount'] ?? '0',
//                       //
//                       //                 totalPriceAfterDiscount:
//                       //                     formatDoubleWithCommas(
//                       //                       totalPriceAfterDiscount,
//                       //                     ),
//                       //                 additionalSpecialDiscount:
//                       //                     additionalSpecialDiscount.toStringAsFixed(
//                       //                       2,
//                       //                     ),
//                       //                 totalPriceAfterSpecialDiscount:
//                       //                     formatDoubleWithCommas(
//                       //                       totalPriceAfterSpecialDiscount,
//                       //                     ),
//                       //                 // itemCurrencyName: itemCurrencyName,
//                       //                 // itemCurrencySymbol: itemCurrencySymbol,
//                       //                 // itemCurrencyLatestRate:
//                       //                 //     itemCurrencyLatestRate,
//                       //                 totalPriceAfterSpecialDiscountBysalesInvoiceCurrency:
//                       //                     formatDoubleWithCommas(
//                       //                       totalPriceAfterSpecialDiscountBysalesInvoiceCurrency,
//                       //                     ),
//                       //
//                       //                 vatBySalesInvoiceCurrency:
//                       //                     formatDoubleWithCommas(
//                       //                       vatBySalesInvoiceCurrency,
//                       //                     ),
//                       //                 finalPriceBySalesInvoiceCurrency:
//                       //                     formatDoubleWithCommas(
//                       //                       finalPriceBySalesInvoiceCurrency,
//                       //                     ),
//                       //                 specialDisc: specialDisc.toString(),
//                       //                 specialDiscount:
//                       //                     widget.info['specialDiscount'] ?? '0',
//                       //                 specialDiscountAmount:
//                       //                     widget.info['specialDiscountAmount'] ??
//                       //                     '',
//                       //                 salesPerson:
//                       //                     widget.info['salesperson'] != null
//                       //                         ? widget.info['salesperson']['name']
//                       //                         : '---',
//                       //                 salesInvoiceCurrency:
//                       //                     widget.info['currency']['name'] ?? '',
//                       //                 salesInvoiceCurrencySymbol:
//                       //                     widget.info['currency']['symbol'] ?? '',
//                       //                 salesInvoiceCurrencyLatestRate:
//                       //                     widget.info['currency']['latest_rate'] ??
//                       //                     '',
//                       //                 clientPhoneNumber:
//                       //                     widget.info['client'] != null
//                       //                         ? widget.info['client']['phoneNumber'] ??
//                       //                             '---'
//                       //                         : "---",
//                       //                 clientName:
//                       //                     widget.info['client']['name'] ?? '',
//                       //                 termsAndConditions:
//                       //                     widget.info['termsAndConditions'] ?? '',
//                       //                 itemsInfoPrint: itemsInfoPrint,
//                       //               );
//                       //             },
//                       //           ),
//                       //         );
//                       //       },
//                       //       child: Text('preview'.tr),
//                       //     ),
//                       //     PopupMenuItem<String>(
//                       //       value: '2',
//                       //       onTap: () async {
//                       //         var res = await updateSalesInvoice(
//                       //           '${widget.info['id']}',
//                       //           false,
//                       //           '${widget.info['reference'] ?? ''}',
//                       //           clientId,
//                       //
//                       //           '${widget.info['valueDate'] ?? ''}',
//                       //           warehouseId,
//                       //           '', //todo paymentTermsController.text,
//                       //           pricelistId,
//                       //           currencyId,
//                       //           '${widget.info['termsAndConditions']}',
//                       //           salespersonId,
//                       //           commissionMethodId,
//                       //           cashMethodId,
//                       //           '${widget.info['commissionRate'] ?? ''}',
//                       //           '${widget.info['commissionTotal'] ?? ''}',
//                       //           '${widget.info['totalBeforeVat'] ?? '0.0'}', //total before vat
//                       //           '${widget.info['specialDiscountAmount'] ?? '0'}', // inserted by user
//                       //           '${widget.info['specialDiscount'] ?? '0'}', // calculated
//                       //           '${widget.info['globalDiscountAmount'] ?? ''}',
//                       //           '${widget.info['globalDiscount'] ?? ''}',
//                       //           '${widget.info['vat'] ?? ''}', //vat
//                       //           '${widget.info['vatLebanese'] ?? ''}',
//                       //           '${widget.info['total'] ?? ''}',
//                       //           '${widget.info['vatExempt'] ?? ''}',
//                       //           '${widget.info['notPrinted'] ?? ''}',
//                       //           '${widget.info['printedAsVatExempt'] ?? ''}',
//                       //           '${widget.info['printedAsPercentage'] ?? ''}',
//                       //           '${widget.info['vatInclusivePrices'] ?? ''}',
//                       //           '${widget.info['beforeVatPrices'] ?? ''}',
//                       //
//                       //           '${widget.info['code'] ?? ''}',
//                       //
//                       //           'confirmed', // status,
//                       //           cont.newRowMap,
//                       //           '${widget.info['inputDate'] ?? ''}',
//                       //           '${widget.info['invoiceDeliveryDate'] ?? ''}',
//                       //         );
//                       //         if (res['success'] == true) {
//                       //           pendingDocsController.getAllPendingDocs();
//                       //
//                       //           CommonWidgets.snackBar('Success', res['message']);
//                       //         } else {
//                       //           print(res['message']);
//                       //           CommonWidgets.snackBar('error', res['message']);
//                       //         }
//                       //       },
//                       //       child: Text('Confirm'.tr),
//                       //     ),
//                       //     PopupMenuItem<String>(
//                       //       value: '3',
//                       //       onTap: () async {
//                       //         var res = await updateSalesInvoice(
//                       //           '${widget.info['id']}',
//                       //           false,
//                       //           '${widget.info['reference'] ?? ''}',
//                       //           clientId,
//                       //
//                       //           '${widget.info['valueDate'] ?? ''}',
//                       //           warehouseId,
//                       //           '', //todo paymentTermsController.text,
//                       //           pricelistId,
//                       //           currencyId,
//                       //           '${widget.info['termsAndConditions']}',
//                       //           salespersonId,
//                       //           commissionMethodId,
//                       //           cashMethodId,
//                       //           '${widget.info['commissionRate'] ?? ''}',
//                       //           '${widget.info['commissionTotal'] ?? ''}',
//                       //           '${widget.info['totalBeforeVat'] ?? '0.0'}', //total before vat
//                       //           '${widget.info['specialDiscountAmount'] ?? '0'}', // inserted by user
//                       //           '${widget.info['specialDiscount'] ?? '0'}', // calculated
//                       //           '${widget.info['globalDiscountAmount'] ?? ''}',
//                       //           '${widget.info['globalDiscount'] ?? ''}',
//                       //           '${widget.info['vat'] ?? ''}', //vat
//                       //           '${widget.info['vatLebanese'] ?? ''}',
//                       //           '${widget.info['total'] ?? ''}',
//                       //           '${widget.info['vatExempt'] ?? ''}',
//                       //           '${widget.info['notPrinted'] ?? ''}',
//                       //           '${widget.info['printedAsVatExempt'] ?? ''}',
//                       //           '${widget.info['printedAsPercentage'] ?? ''}',
//                       //           '${widget.info['vatInclusivePrices'] ?? ''}',
//                       //           '${widget.info['beforeVatPrices'] ?? ''}',
//                       //
//                       //           '${widget.info['code'] ?? ''}',
//                       //
//                       //           'cancelled', // status,
//                       //           cont.newRowMap,
//                       //           '${widget.info['inputDate'] ?? ''}',
//                       //           '${widget.info['invoiceDeliveryDate'] ?? ''}',
//                       //         );
//                       //         if (res['success'] == true) {
//                       //           pendingDocsController.getAllPendingDocs();
//                       //           CommonWidgets.snackBar('Success', res['message']);
//                       //         } else {
//                       //           print(res['message']);
//                       //           CommonWidgets.snackBar('error', res['message']);
//                       //         }
//                       //       },
//                       //       child: Text('Cancel'.tr),
//                       //     ),
//                       //     PopupMenuItem<String>(
//                       //       value: '4',
//                       //       onTap: () async {
//                       //         showDialog<String>(
//                       //           context: context,
//                       //           builder:
//                       //               (BuildContext context) => AlertDialog(
//                       //                 backgroundColor: Colors.white,
//                       //                 shape: const RoundedRectangleBorder(
//                       //                   borderRadius: BorderRadius.all(
//                       //                     Radius.circular(9),
//                       //                   ),
//                       //                 ),
//                       //                 elevation: 0,
//                       //                 content: UpdateSalesInvoiceDialog(
//                       //                   index: widget.index,
//                       //                   info: widget.info,
//                       //                 ),
//                       //               ),
//                       //         );
//                       //       },
//                       //       child: Text('Update'.tr),
//                       //     ),
//                       //   ],
//                       // ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//             TableItem(
//               text: '${widget.info['invoiceDeliveryDate'] ?? '---'}',
//               width:
//                   widget.isDesktop
//                       ? MediaQuery.of(context).size.width * 0.07
//                       : 150,
//             ),
//             SizedBox(width: MediaQuery.of(context).size.width * 0.01),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // class UpdateSalesInvoiceDialog extends StatefulWidget {
// //   const UpdateSalesInvoiceDialog({
// //     super.key,
// //     required this.index,
// //     required this.info,
// //   });
// //   final int index;
// //   final Map info;

// //   @override
// //   State<UpdateSalesInvoiceDialog> createState() =>
// //       _UpdateSalesInvoiceDialogState();
// // }

// // class _UpdateSalesInvoiceDialogState extends State<UpdateSalesInvoiceDialog> {
// //   final _formKey = GlobalKey<FormState>();
// //   String selectedSalesPerson = '';
// //   int selectedSalesPersonId = 0;
// //   List tabsList = ['order_lines', 'other_information'];
// //   TextEditingController cashingMethodsController = TextEditingController();
// //   TextEditingController salesPersonController = TextEditingController();
// //   TextEditingController searchController = TextEditingController();
// //   TextEditingController refController = TextEditingController();
// //   TextEditingController validityController = TextEditingController();
// //   TextEditingController currencyController = TextEditingController();
// //   TextEditingController codeController = TextEditingController();
// //   TextEditingController vatExemptController = TextEditingController();
// //   TextEditingController vatController = TextEditingController();
// //   TextEditingController termsAndConditionsController = TextEditingController();

// //   TextEditingController globalDiscPercentController = TextEditingController();
// //   TextEditingController specialDiscPercentController = TextEditingController();
// //   TextEditingController commissionController = TextEditingController();
// //   TextEditingController totalCommissionController = TextEditingController();

// //   TextEditingController paymentTermsController = TextEditingController();
// //   TextEditingController priceConditionController = TextEditingController();
// //   TextEditingController priceListController = TextEditingController();

// //   String selectedCurrency = '';

// //   String selectedItemCode = '';
// //   String selectedCustomerIds = '';

// //   List<String> termsList = [];

// //   final HomeController homeController = Get.find();
// //   final SalesInvoiceController salesInvoiceController = Get.find();

// //   String paymentTerm = '',
// //       priceListSelected = '',
// //       selectedCountry = '',
// //       selectedCity = '';
// //   String selectedPhoneCode = '', selectedMobileCode = '';
// //   int selectedClientType = 1;
// //   int selectedTabIndex = 0;

// //   String selectedItem = "";
// //   int currentStep = 0;
// //   int indexNum = 0;
// //   String globalDiscountPercentage = ''; // user insert this value
// //   String specialDiscountPercentage = ''; // user insert this value

// //   String selectedPaymentTerm = '',
// //       selectedPriceList = '',
// //       termsAndConditions = '',
// //       specialDisc = '',
// //       globalDisc = '';
// //   final ExchangeRatesController exchangeRatesController = Get.find();
// //   int salesInvoiceCounter = 0;
// //   Map orderLine = {};

// //   getCurrency() async {
// //     salesInvoiceController.selectedCurrencyId =
// //         widget.info['currency']['id'].toString();
// //     selectedCurrency = widget.info['currency']['name'] ?? '';
// //     currencyController.text = selectedCurrency;
// //     int index = exchangeRatesController.currenciesNamesList.indexOf(
// //       selectedCurrency,
// //     );
// //     salesInvoiceController.selectedCurrencyId =
// //         exchangeRatesController.currenciesIdsList[index];
// //     salesInvoiceController.selectedCurrencyName = selectedCurrency;
// //     var vat = await getCompanyVatFromPref();
// //     salesInvoiceController.setCompanyVat(double.parse(vat));
// //     var companyCurrency = await getCompanyPrimaryCurrencyFromPref();
// //     salesInvoiceController.setCompanyPrimaryCurrency(companyCurrency);
// //     var result = exchangeRatesController.exchangeRatesList.firstWhere(
// //       (item) => item["currency"] == companyCurrency,
// //       orElse: () => null,
// //     );
// //     salesInvoiceController.setLatestRate(
// //       double.parse(result != null ? '${result["exchange_rate"]}' : '1'),
// //     );
// //   }

// //   // var isVatZero = false;
// //   checkVatExempt() async {
// //     var companySubjectToVat = await getCompanySubjectToVatFromPref();
// //     if (companySubjectToVat == '1') {
// //       vatExemptController.clear();
// //       salesInvoiceController.setIsVatExempted(false, false, false);
// //       salesInvoiceController.setIsVatExemptCheckBoxShouldAppear(true);
// //     } else {
// //       salesInvoiceController.setIsVatExemptCheckBoxShouldAppear(false);
// //       salesInvoiceController.setIsVatExempted(false, false, true);
// //       salesInvoiceController.setIsVatExemptChecked(true);
// //     }
// //     if ('${widget.info['printedAsPercentage'] ?? ''}' == '1') {
// //       salesInvoiceController.isPrintedAs0 = true;
// //       vatExemptController.text = 'Printed as "vat 0 % = 0"';
// //     }
// //     if ('${widget.info['printedAsVatExempt']}' == '1') {
// //       salesInvoiceController.isPrintedAsVatExempt = true;
// //       vatExemptController.text = 'Printed as "vat exempted"';
// //     }
// //     if ('${widget.info['notPrinted'] ?? ''}' == '1') {
// //       salesInvoiceController.isVatNoPrinted = true;
// //       vatExemptController.text = 'No printed ';
// //     }
// //     salesInvoiceController.isVatExemptChecked =
// //         '${widget.info['vatExempt'] ?? ''}' == '1' ? true : false;
// //   }

// //   late QuillController _controller;
// //   String? _savedContent;

// //   void _saveContent() {
// //     final deltaJson = _controller.document.toDelta().toJson();
// //     final jsonString = jsonEncode(deltaJson);

// //     setState(() {
// //       _savedContent = jsonString;
// //     });

// //     // You can now send `jsonString` to your backend
// //     termsAndConditionsController.text = jsonString;
// //   }

// //   // Restore content from saved string (e.g., from API)
// //   void _loadContent() {
// //     if (_savedContent == null) return;
// //     if (_savedContent == '[{"insert":"\n"}]') {
// //       _controller = QuillController.basic();
// //       return;
// //     }
// //     final delta = Delta.fromJson(jsonDecode(_savedContent!));
// //     final doc = Document.fromDelta(delta);

// //     setState(() {
// //       _controller = QuillController(
// //         document: doc,
// //         selection: const TextSelection.collapsed(offset: 0),
// //       );
// //     });
// //   }

// //   int progressVar = 0;

// //   setProgressVar() {
// //     salesInvoiceController.status = widget.info['status'];
// //     progressVar =
// //         widget.info['status'] == "pending"
// //             ? 0
// //             : widget.info['status'] == 'sent'
// //             ? 1
// //             : widget.info['status'] == 'confirmed'
// //             ? 2
// //             : 0;
// //   }

// //   String oldTermsAndConditionsString = '';
// //   @override
// //   void initState() {
// //     checkVatExempt();
// //     getCurrency();
// //     salesInvoiceController.orderLinesSalesInvoiceList = {};
// //     salesInvoiceController.rowsInListViewInSalesInvoice = {};
// //     // print(widget.info);
// //     setProgressVar();

// //     if (widget.info['cashingMethod'] != null) {
// //       cashingMethodsController.text =
// //           '${widget.info['cashingMethod']['title'] ?? ''}';
// //       salesInvoiceController.selectedCashingMethodId =
// //           '${widget.info['cashingMethod']['id']}';
// //     }

// //     if (widget.info['pricelist'] != null) {
// //       priceListController.text = '${widget.info['pricelist']['code'] ?? ''}';
// //       salesInvoiceController.selectedPriceListId =
// //           '${widget.info['pricelist']['id']}';
// //     } else {
// //       priceListController.text = 'STANDARD';
// //     }

// //     if (widget.info['salesperson'] != null) {
// //       selectedSalesPerson = '${widget.info['salesperson']['name'] ?? ''}';
// //       salesPersonController.text =
// //           '${widget.info['salesperson']['name'] ?? ''}';
// //       selectedSalesPersonId = widget.info['salesperson']['id'] ?? 0;
// //     }

// //     if ('${widget.info['beforeVatPrices'] ?? ''}' == '1') {
// //       priceConditionController.text = 'Prices are before vat';
// //       salesInvoiceController.isBeforeVatPrices = true;
// //     }

// //     if ('${widget.info['vatInclusivePrices'] ?? ''}' == '1') {
// //       priceConditionController.text = 'Prices are vat inclusive';
// //       salesInvoiceController.isBeforeVatPrices = false;
// //     }

// //     searchController.text = widget.info['client']['name'] ?? '';
// //     selectedItem = widget.info['client']['name'] ?? '';
// //     codeController.text = widget.info['code'] ?? '';
// //     selectedItemCode = widget.info['code'] ?? '';
// //     selectedCustomerIds = widget.info['client']['id'].toString();
// //     refController.text = widget.info['reference'] ?? '';
// //     validityController.text = widget.info['validity'] ?? '';
// //     currencyController.text = widget.info['currency']['name'] ?? '';
// //     print('ok1');
// //     print(widget.info['termsAndConditions']);
// //     print(widget.info['termsAndConditions'] ?? '[{"insert":"\n"}]');

// //     oldTermsAndConditionsString =
// //         widget.info['termsAndConditions'] ?? '[{"insert":"\n"}]';
// //     termsAndConditionsController.text =
// //         widget.info['termsAndConditions'] ?? '[{"insert":"\n"}]';
// //     print('ok2');

// //     _savedContent = widget.info['termsAndConditions'] ?? '[{"insert":"\n"}]';
// //     print('ok3');

// //     _loadContent();

// //     print('ok4');

// //     globalDiscPercentController.text =
// //         widget.info['globalDiscount'] ?? ''; // entered by user
// //     specialDiscPercentController.text =
// //         widget.info['specialDiscount'] ?? ''; //entered by user
// //     salesInvoiceController.globalDisc =
// //         widget.info['globalDiscountAmount'] ?? '';
// //     salesInvoiceController.specialDisc =
// //         widget.info['specialDiscountAmount'] ?? '';
// //     salesInvoiceController.totalItems = double.parse(
// //       '${widget.info['totalBeforeVat'] ?? '0.0'}',
// //     );
// //     // print('isVatZero $isVatZero');
// //     salesInvoiceController.vat11 =
// //         salesInvoiceController.isVatExemptChecked
// //             ? '0'
// //             : '${widget.info['vat'] ?? ''}';
// //     salesInvoiceController.vatInPrimaryCurrency =
// //         salesInvoiceController.isVatExemptChecked
// //             ? '0'
// //             : '${widget.info['vatLebanese'] ?? ''}';

// //     // quotationController.totalQuotation = '${widget.info['total'] ?? ''}';
// //     salesInvoiceController.totalSalesOrder = ((salesInvoiceController
// //                     .totalItems -
// //                 double.parse(salesInvoiceController.globalDisc) -
// //                 double.parse(salesInvoiceController.specialDisc)) +
// //             double.parse(salesInvoiceController.vat11))
// //         .toStringAsFixed(2);
// //     salesInvoiceController.city[selectedCustomerIds] =
// //         widget.info['client']['city'] ?? '';
// //     salesInvoiceController.country[selectedCustomerIds] =
// //         widget.info['client']['country'] ?? '';
// //     salesInvoiceController.email[selectedCustomerIds] =
// //         widget.info['client']['email'] ?? '';
// //     salesInvoiceController.phoneNumber[selectedCustomerIds] =
// //         widget.info['client']['phoneNumber'] ?? '';
// //     salesInvoiceController.selectedSalesInvoiceData['orderLines'] =
// //         widget.info['orderLines'] ?? '';
// //     for (
// //       int i = 0;
// //       i < salesInvoiceController.selectedSalesInvoiceData['orderLines'].length;
// //       i++
// //     ) {
// //       salesInvoiceController.rowsInListViewInSalesInvoice[i + 1] =
// //           salesInvoiceController.selectedSalesInvoiceData['orderLines'][i];
// //     }
// //     var keys =
// //         salesInvoiceController.rowsInListViewInSalesInvoice.keys.toList();

// //     for (int i = 0; i < widget.info['orderLines'].length; i++) {
// //       if (widget.info['orderLines'][i]['line_type_id'] == 2) {
// //         salesInvoiceController.unitPriceControllers[i + 1] =
// //             TextEditingController();
// //         Widget p = ReusableItemRow(
// //           index: i + 1,
// //           info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
// //         );

// //         salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
// //       } else if (widget.info['orderLines'][i]['line_type_id'] == 1) {
// //         Widget p = ReusableTitleRow(
// //           index: i + 1,
// //           info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
// //         );
// //         salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
// //       } else if (widget.info['orderLines'][i]['line_type_id'] == 5) {
// //         Widget p = ReusableNoteRow(
// //           index: i + 1,
// //           info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
// //         );
// //         salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
// //       } else if (widget.info['orderLines'][i]['line_type_id'] == 4) {
// //         Widget p = ReusableImageRow(
// //           index: i + 1,
// //           info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
// //         );
// //         salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
// //       } else if (widget.info['orderLines'][i]['line_type_id'] == 3) {
// //         salesInvoiceController.combosPriceControllers[i + 1] =
// //             TextEditingController();
// //         Widget p = ReusableComboRow(
// //           index: i + 1,
// //           info: salesInvoiceController.rowsInListViewInSalesInvoice[keys[i]],
// //         );
// //         salesInvoiceController.orderLinesSalesInvoiceList['${i + 1}'] = p;
// //       }
// //     }
// //     salesInvoiceCounter =
// //         salesInvoiceController.rowsInListViewInSalesInvoice.length;
// //     salesInvoiceController.listViewLengthInSalesInvoice =
// //         salesInvoiceController.orderLinesSalesInvoiceList.length * 60;

// //     super.initState();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GetBuilder<SalesInvoiceController>(
// //       builder: (salesInvoiceCont) {
// //         var keysList =
// //             salesInvoiceCont.orderLinesSalesInvoiceList.keys.toList();
// //         return Container(
// //           color: Colors.white,
// //           width: MediaQuery.of(context).size.width * 0.85,
// //           height: MediaQuery.of(context).size.height * 0.9,
// //           margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
// //           child: SingleChildScrollView(
// //             child: Form(
// //               key: _formKey,
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       PageTitle(text: 'update_sales_invoice'.tr),
// //                       InkWell(
// //                         onTap: () {
// //                           Get.back();
// //                         },
// //                         child: CircleAvatar(
// //                           backgroundColor: Primary.primary,
// //                           radius: 15,
// //                           child: const Icon(
// //                             Icons.close_rounded,
// //                             color: Colors.white,
// //                             size: 20,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   gapH32,
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           UnderTitleBtn(
// //                             text: 'send_by_email'.tr,
// //                             onTap: ()
// //                             // {
// //                             //   if (progressVar == 0) {
// //                             //     setState(() {
// //                             //       progressVar += 1;
// //                             //     });
// //                             //   }
// //                             // },
// //                             async {
// //                               setState(() {
// //                                 progressVar = 1;
// //                               });
// //                               salesInvoiceCont.setStatus('sent');
// //                               var oldKeys =
// //                                   salesInvoiceController
// //                                       .rowsInListViewInSalesInvoice
// //                                       .keys
// //                                       .toList()
// //                                     ..sort();
// //                               for (int i = 0; i < oldKeys.length; i++) {
// //                                 salesInvoiceController.newRowMap[i + 1] =
// //                                     salesInvoiceController
// //                                         .rowsInListViewInSalesInvoice[oldKeys[i]]!;
// //                               }
// //                               if (_formKey.currentState!.validate()) {
// //                                 _saveContent();
// //                                 // var res = await updateSalesOrdder(
// //                                 //   '${widget.info['id']}',
// //                                 //   // termsAndConditionsController.text!=oldTermsAndConditionsString,
// //                                 //   false,
// //                                 //   refController.text,
// //                                 //   selectedCustomerIds,
// //                                 //   validityController.text,
// //                                 //   '', //todo paymentTermsController.text,
// //                                 //   salesInvoiceCont.selectedPriceListId,
// //                                 //   salesInvoiceCont
// //                                 //       .selectedCurrencyId, //selectedCurrency
// //                                 //   termsAndConditionsController.text,
// //                                 //   selectedSalesPersonId.toString(),
// //                                 //   '',
// //                                 //   salesInvoiceCont.selectedCashingMethodId,
// //                                 //   commissionController.text,
// //                                 //   totalCommissionController.text,
// //                                 //   salesInvoiceController.totalItems
// //                                 //       .toString(), //total before vat
// //                                 //   specialDiscPercentController
// //                                 //       .text, // inserted by user
// //                                 //   salesInvoiceController
// //                                 //       .specialDisc, // calculated
// //                                 //   globalDiscPercentController.text,
// //                                 //   salesInvoiceController.globalDisc,
// //                                 //   salesInvoiceController.vat11.toString(), //vat
// //                                 //   salesInvoiceController.vatInPrimaryCurrency
// //                                 //       .toString(),
// //                                 //   salesInvoiceController
// //                                 //       .totalSalesOrder, // quotationController.totalQuotation

// //                                 //   salesInvoiceCont.isVatExemptChecked
// //                                 //       ? '1'
// //                                 //       : '0',
// //                                 //   salesInvoiceCont.isVatNoPrinted ? '1' : '0',
// //                                 //   salesInvoiceCont.isPrintedAsVatExempt
// //                                 //       ? '1'
// //                                 //       : '0',
// //                                 //   salesInvoiceCont.isPrintedAs0 ? '1' : '0',
// //                                 //   salesInvoiceCont.isBeforeVatPrices
// //                                 //       ? '0'
// //                                 //       : '1',

// //                                 //   salesInvoiceCont.isBeforeVatPrices
// //                                 //       ? '1'
// //                                 //       : '0',
// //                                 //   codeController.text,
// //                                 //   salesInvoiceCont.status, // status,
// //                                 //   // quotationController.rowsInListViewInQuotation,
// //                                 //   salesInvoiceController.newRowMap,
// //                                 // );
// //                                 // if (res['success'] == true) {
// //                                 //   Get.back();
// //                                 //   salesInvoiceController
// //                                 //       .getAllSalesInvoiceFromBack();
// //                                 //   // homeController.selectedTab.value = 'new_quotation';
// //                                 //   homeController.selectedTab.value =
// //                                 //       'sales_invoice_summary';
// //                                 //   CommonWidgets.snackBar(
// //                                 //     'Success',
// //                                 //     res['message'],
// //                                 //   );
// //                                 // } else {
// //                                 //   CommonWidgets.snackBar(
// //                                 //     'error',
// //                                 //     res['message'],
// //                                 //   );
// //                                 // }
// //                               }
// //                             },
// //                           ),
// //                           UnderTitleBtn(
// //                             text: 'confirm'.tr,
// //                             onTap: ()
// //                             //  {
// //                             //       setState(() {
// //                             //         progressVar = 2;
// //                             //       });
// //                             //       quotationCont.setStatus('confirmed');
// //                             //   },
// //                             async {
// //                               setState(() {
// //                                 progressVar = 2;
// //                               });
// //                               salesInvoiceCont.setStatus('confirmed');
// //                               var oldKeys =
// //                                   salesInvoiceController
// //                                       .rowsInListViewInSalesInvoice
// //                                       .keys
// //                                       .toList()
// //                                     ..sort();
// //                               for (int i = 0; i < oldKeys.length; i++) {
// //                                 salesInvoiceController.newRowMap[i + 1] =
// //                                     salesInvoiceController
// //                                         .rowsInListViewInSalesInvoice[oldKeys[i]]!;
// //                               }
// //                               if (_formKey.currentState!.validate()) {
// //                                 _saveContent();
// //                                 // var res = await updateSalesOrdder(
// //                                 //   '${widget.info['id']}',
// //                                 //   // termsAndConditionsController.text!=oldTermsAndConditionsString,
// //                                 //   false,
// //                                 //   refController.text,
// //                                 //   selectedCustomerIds,
// //                                 //   validityController.text,
// //                                 //   '', //todo paymentTermsController.text,
// //                                 //   salesInvoiceCont.selectedPriceListId,
// //                                 //   salesInvoiceCont
// //                                 //       .selectedCurrencyId, //selectedCurrency
// //                                 //   termsAndConditionsController.text,
// //                                 //   selectedSalesPersonId.toString(),
// //                                 //   '',
// //                                 //   salesInvoiceCont.selectedCashingMethodId,
// //                                 //   commissionController.text,
// //                                 //   totalCommissionController.text,
// //                                 //   salesInvoiceController.totalItems
// //                                 //       .toString(), //total before vat
// //                                 //   specialDiscPercentController
// //                                 //       .text, // inserted by user
// //                                 //   salesInvoiceController
// //                                 //       .specialDisc, // calculated
// //                                 //   globalDiscPercentController.text,
// //                                 //   salesInvoiceController.globalDisc,
// //                                 //   salesInvoiceController.vat11.toString(), //vat
// //                                 //   salesInvoiceController.vatInPrimaryCurrency
// //                                 //       .toString(),
// //                                 //   salesInvoiceController
// //                                 //       .totalSalesOrder, // quotationController.totalQuotation

// //                                 //   salesInvoiceCont.isVatExemptChecked
// //                                 //       ? '1'
// //                                 //       : '0',
// //                                 //   salesInvoiceCont.isVatNoPrinted ? '1' : '0',
// //                                 //   salesInvoiceCont.isPrintedAsVatExempt
// //                                 //       ? '1'
// //                                 //       : '0',
// //                                 //   salesInvoiceCont.isPrintedAs0 ? '1' : '0',
// //                                 //   salesInvoiceCont.isBeforeVatPrices
// //                                 //       ? '0'
// //                                 //       : '1',

// //                                 //   salesInvoiceCont.isBeforeVatPrices
// //                                 //       ? '1'
// //                                 //       : '0',
// //                                 //   codeController.text,
// //                                 //   salesInvoiceCont.status, // status,
// //                                 //   // quotationController.rowsInListViewInQuotation,
// //                                 //   salesInvoiceController.newRowMap,
// //                                 // );
// //                                 // if (res['success'] == true) {
// //                                 //   Get.back();
// //                                 //   salesInvoiceController
// //                                 //       .getAllSalesInvoiceFromBack();
// //                                 //   // homeController.selectedTab.value = 'new_quotation';
// //                                 //   homeController.selectedTab.value =
// //                                 //       'sales_invoice_summary';
// //                                 //   CommonWidgets.snackBar(
// //                                 //     'Success',
// //                                 //     res['message'],
// //                                 //   );
// //                                 // } else {
// //                                 //   CommonWidgets.snackBar(
// //                                 //     'error',
// //                                 //     res['message'],
// //                                 //   );
// //                                 // }
// //                               }
// //                             },
// //                           ),
// //                           UnderTitleBtn(
// //                             text: 'cancel'.tr,
// //                             onTap: ()
// //                             //  {
// //                             //   setState(() {
// //                             //     progressVar = 0;
// //                             //   });
// //                             //   quotationCont.setStatus('cancelled');
// //                             // },
// //                             async {
// //                               salesInvoiceCont.setStatus('cancelled');
// //                               var oldKeys =
// //                                   salesInvoiceController
// //                                       .rowsInListViewInSalesInvoice
// //                                       .keys
// //                                       .toList()
// //                                     ..sort();
// //                               for (int i = 0; i < oldKeys.length; i++) {
// //                                 salesInvoiceController.newRowMap[i + 1] =
// //                                     salesInvoiceController
// //                                         .rowsInListViewInSalesInvoice[oldKeys[i]]!;
// //                               }
// //                               if (_formKey.currentState!.validate()) {
// //                                 _saveContent();
// //                                 // var res = await updateSalesOrdder(
// //                                 //   '${widget.info['id']}',
// //                                 //   false,
// //                                 //   // termsAndConditionsController.text!=oldTermsAndConditionsString,
// //                                 //   refController.text,
// //                                 //   selectedCustomerIds,
// //                                 //   validityController.text,
// //                                 //   '', //todo paymentTermsController.text,
// //                                 //   salesInvoiceCont.selectedPriceListId,
// //                                 //   salesInvoiceCont
// //                                 //       .selectedCurrencyId, //selectedCurrency
// //                                 //   termsAndConditionsController.text,
// //                                 //   selectedSalesPersonId.toString(),
// //                                 //   '',
// //                                 //   salesInvoiceCont.selectedCashingMethodId,
// //                                 //   commissionController.text,
// //                                 //   totalCommissionController.text,
// //                                 //   salesInvoiceController.totalItems
// //                                 //       .toString(), //total before vat
// //                                 //   specialDiscPercentController
// //                                 //       .text, // inserted by user
// //                                 //   salesInvoiceController
// //                                 //       .specialDisc, // calculated
// //                                 //   globalDiscPercentController.text,
// //                                 //   salesInvoiceController.globalDisc,
// //                                 //   salesInvoiceController.vat11.toString(), //vat
// //                                 //   salesInvoiceController.vatInPrimaryCurrency
// //                                 //       .toString(),
// //                                 //   salesInvoiceController
// //                                 //       .totalSalesOrder, // quotationController.totalQuotation

// //                                 //   salesInvoiceCont.isVatExemptChecked
// //                                 //       ? '1'
// //                                 //       : '0',
// //                                 //   salesInvoiceCont.isVatNoPrinted ? '1' : '0',
// //                                 //   salesInvoiceCont.isPrintedAsVatExempt
// //                                 //       ? '1'
// //                                 //       : '0',
// //                                 //   salesInvoiceCont.isPrintedAs0 ? '1' : '0',
// //                                 //   salesInvoiceCont.isBeforeVatPrices
// //                                 //       ? '0'
// //                                 //       : '1',

// //                                 //   salesInvoiceCont.isBeforeVatPrices
// //                                 //       ? '1'
// //                                 //       : '0',
// //                                 //   codeController.text,
// //                                 //   salesInvoiceCont.status, // status,
// //                                 //   // quotationController.rowsInListViewInQuotation,
// //                                 //   salesInvoiceController.newRowMap,
// //                                 // );
// //                                 // if (res['success'] == true) {
// //                                 //   Get.back();
// //                                 //   salesInvoiceController
// //                                 //       .getAllSalesInvoiceFromBack();
// //                                 //   // homeController.selectedTab.value = 'new_quotation';
// //                                 //   homeController.selectedTab.value =
// //                                 //       'sales_invoice_summary';
// //                                 //   CommonWidgets.snackBar(
// //                                 //     'Success',
// //                                 //     res['message'],
// //                                 //   );
// //                                 // } else {
// //                                 //   CommonWidgets.snackBar(
// //                                 //     'error',
// //                                 //     res['message'],
// //                                 //   );
// //                                 // }
// //                               }
// //                             },
// //                           ),
// //                         ],
// //                       ),
// //                       Row(
// //                         children: [
// //                           ReusableTimeLineTile(
// //                             id: 0,
// //                             progressVar: progressVar,
// //                             isFirst: true,
// //                             isLast: false,
// //                             isPast: true,
// //                             text: 'processing'.tr,
// //                           ),
// //                           ReusableTimeLineTile(
// //                             id: 1,
// //                             progressVar: progressVar,
// //                             isFirst: false,
// //                             isLast: false,
// //                             isPast: false,
// //                             text: 'sales_invoice_sent'.tr,
// //                           ),
// //                           ReusableTimeLineTile(
// //                             id: 2,
// //                             progressVar: progressVar,
// //                             isFirst: false,
// //                             isLast: true,
// //                             isPast: false,
// //                             text: 'confirmed'.tr,
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                   gapH16,
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 20,
// //                       vertical: 20,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       border: Border.all(color: Others.divider),
// //                       borderRadius: const BorderRadius.all(Radius.circular(9)),
// //                     ),
// //                     child: Column(
// //                       children: [
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 Text(
// //                                   '${widget.info['salesOrderNumber'] ?? ''}',
// //                                   style: const TextStyle(
// //                                     fontSize: 20,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             DialogTextField(
// //                               textEditingController: refController,
// //                               text: '${'ref'.tr}:',
// //                               hint: 'manual_reference'.tr,
// //                               rowWidth:
// //                                   MediaQuery.of(context).size.width * 0.18,
// //                               textFieldWidth:
// //                                   MediaQuery.of(context).size.width * 0.15,
// //                               validationFunc: (val) {},
// //                             ),
// //                             SizedBox(
// //                               width: MediaQuery.of(context).size.width * 0.11,
// //                               child: Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text('currency'.tr),
// //                                   GetBuilder<ExchangeRatesController>(
// //                                     builder: (cont) {
// //                                       return DropdownMenu<String>(
// //                                         width:
// //                                             MediaQuery.of(context).size.width *
// //                                             0.07,
// //                                         // requestFocusOnTap: false,
// //                                         enableSearch: true,
// //                                         controller: currencyController,
// //                                         hintText: '',
// //                                         inputDecorationTheme: InputDecorationTheme(
// //                                           // filled: true,
// //                                           hintStyle: const TextStyle(
// //                                             fontStyle: FontStyle.italic,
// //                                           ),
// //                                           contentPadding:
// //                                               const EdgeInsets.fromLTRB(
// //                                                 20,
// //                                                 0,
// //                                                 25,
// //                                                 5,
// //                                               ),
// //                                           // outlineBorder: BorderSide(color: Colors.black,),
// //                                           enabledBorder: OutlineInputBorder(
// //                                             borderSide: BorderSide(
// //                                               color: Primary.primary.withAlpha(
// //                                                 (0.2 * 255).toInt(),
// //                                               ),
// //                                               width: 1,
// //                                             ),
// //                                             borderRadius:
// //                                                 const BorderRadius.all(
// //                                                   Radius.circular(9),
// //                                                 ),
// //                                           ),
// //                                           focusedBorder: OutlineInputBorder(
// //                                             borderSide: BorderSide(
// //                                               color: Primary.primary.withAlpha(
// //                                                 (0.4 * 255).toInt(),
// //                                               ),
// //                                               width: 2,
// //                                             ),
// //                                             borderRadius:
// //                                                 const BorderRadius.all(
// //                                                   Radius.circular(9),
// //                                                 ),
// //                                           ),
// //                                         ),
// //                                         // menuStyle: ,
// //                                         menuHeight: 250,
// //                                         dropdownMenuEntries:
// //                                             cont.currenciesNamesList.map<
// //                                               DropdownMenuEntry<String>
// //                                             >((String option) {
// //                                               return DropdownMenuEntry<String>(
// //                                                 value: option,
// //                                                 label: option,
// //                                               );
// //                                             }).toList(),
// //                                         enableFilter: true,
// //                                         onSelected: (String? val) {
// //                                           setState(() {
// //                                             selectedCurrency = val!;
// //                                             var index = cont.currenciesNamesList
// //                                                 .indexOf(val);
// //                                             salesInvoiceCont
// //                                                 .setSelectedCurrency(
// //                                                   cont.currenciesIdsList[index],
// //                                                   val,
// //                                                 );
// //                                             var result = cont.exchangeRatesList
// //                                                 .firstWhere(
// //                                                   (item) =>
// //                                                       item["currency"] == val,
// //                                                   orElse: () => null,
// //                                                 );
// //                                             salesInvoiceCont
// //                                                 .setExchangeRateForSelectedCurrency(
// //                                                   result != null
// //                                                       ? '${result["exchange_rate"]}'
// //                                                       : '1',
// //                                                 );
// //                                           });
// //                                           var keys =
// //                                               salesInvoiceCont
// //                                                   .unitPriceControllers
// //                                                   .keys
// //                                                   .toList();
// //                                           for (
// //                                             int i = 0;
// //                                             i <
// //                                                 salesInvoiceCont
// //                                                     .unitPriceControllers
// //                                                     .length;
// //                                             i++
// //                                           ) {
// //                                             var selectedItemId =
// //                                                 '${salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_id']}';
// //                                             if (selectedItemId != '') {
// //                                               if (salesInvoiceCont
// //                                                       .itemsPricesCurrencies[selectedItemId] ==
// //                                                   val) {
// //                                                 salesInvoiceCont
// //                                                     .unitPriceControllers[keys[i]]!
// //                                                     .text = salesInvoiceCont
// //                                                         .itemUnitPrice[selectedItemId]
// //                                                         .toString();
// //                                               } else if (val == 'USD' &&
// //                                                   salesInvoiceCont
// //                                                           .itemsPricesCurrencies[selectedItemId] !=
// //                                                       val) {
// //                                                 var result = exchangeRatesController
// //                                                     .exchangeRatesList
// //                                                     .firstWhere(
// //                                                       (item) =>
// //                                                           item["currency"] ==
// //                                                           salesInvoiceCont
// //                                                               .itemsPricesCurrencies[selectedItemId],
// //                                                       orElse: () => null,
// //                                                     );
// //                                                 var divider = '1';
// //                                                 if (result != null) {
// //                                                   divider =
// //                                                       result["exchange_rate"]
// //                                                           .toString();
// //                                                 }
// //                                                 salesInvoiceCont
// //                                                         .unitPriceControllers[keys[i]]!
// //                                                         .text =
// //                                                     '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
// //                                               } else if (salesInvoiceCont
// //                                                           .selectedCurrencyName !=
// //                                                       'USD' &&
// //                                                   salesInvoiceCont
// //                                                           .itemsPricesCurrencies[selectedItemId] ==
// //                                                       'USD') {
// //                                                 salesInvoiceCont
// //                                                         .unitPriceControllers[keys[i]]!
// //                                                         .text =
// //                                                     '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) * double.parse(salesInvoiceCont.exchangeRateForSelectedCurrency))}')}';
// //                                               } else {
// //                                                 var result = exchangeRatesController
// //                                                     .exchangeRatesList
// //                                                     .firstWhere(
// //                                                       (item) =>
// //                                                           item["currency"] ==
// //                                                           salesInvoiceCont
// //                                                               .itemsPricesCurrencies[selectedItemId],
// //                                                       orElse: () => null,
// //                                                     );
// //                                                 var divider = '1';
// //                                                 if (result != null) {
// //                                                   divider =
// //                                                       result["exchange_rate"]
// //                                                           .toString();
// //                                                 }
// //                                                 var usdPrice =
// //                                                     '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
// //                                                 salesInvoiceCont
// //                                                         .unitPriceControllers[keys[i]]!
// //                                                         .text =
// //                                                     '${double.parse('${(double.parse(usdPrice) * double.parse(salesInvoiceCont.exchangeRateForSelectedCurrency))}')}';
// //                                               }
// //                                               if (!salesInvoiceCont
// //                                                   .isBeforeVatPrices) {
// //                                                 var taxRate =
// //                                                     double.parse(
// //                                                       salesInvoiceCont
// //                                                           .itemsVats[selectedItemId],
// //                                                     ) /
// //                                                     100.0;
// //                                                 var taxValue =
// //                                                     taxRate *
// //                                                     double.parse(
// //                                                       salesInvoiceCont
// //                                                           .unitPriceControllers[keys[i]]!
// //                                                           .text,
// //                                                     );

// //                                                 salesInvoiceCont
// //                                                         .unitPriceControllers[keys[i]]!
// //                                                         .text =
// //                                                     '${double.parse(salesInvoiceCont.unitPriceControllers[keys[i]]!.text) + taxValue}';
// //                                               }
// //                                               salesInvoiceCont
// //                                                   .unitPriceControllers[keys[i]]!
// //                                                   .text = double.parse(
// //                                                 salesInvoiceCont
// //                                                     .unitPriceControllers[keys[i]]!
// //                                                     .text,
// //                                               ).toStringAsFixed(2);
// //                                               var totalLine =
// //                                                   '${(double.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_quantity']) * double.parse(salesInvoiceCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_discount']) / 100)}';
// //                                               salesInvoiceCont
// //                                                   .setEnteredUnitPriceInSalesInvoice(
// //                                                     keys[i],
// //                                                     salesInvoiceCont
// //                                                         .unitPriceControllers[keys[i]]!
// //                                                         .text,
// //                                                   );
// //                                               salesInvoiceCont
// //                                                   .setMainTotalInSalesInvoice(
// //                                                     keys[i],
// //                                                     totalLine,
// //                                                   );
// //                                               salesInvoiceCont.getTotalItems();
// //                                             }
// //                                           }
// //                                         },
// //                                       );
// //                                     },
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),

// //                             SizedBox(
// //                               width: MediaQuery.of(context).size.width * 0.14,
// //                               child: Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text('validity'.tr),
// //                                   DialogDateTextField(
// //                                     textEditingController: validityController,
// //                                     text: '',
// //                                     textFieldWidth:
// //                                         MediaQuery.of(context).size.width *
// //                                         0.10,
// //                                     // MediaQuery.of(context).size.width * 0.25,
// //                                     validationFunc: (val) {},
// //                                     onChangedFunc: (val) {
// //                                       validityController.text = val;
// //                                     },
// //                                     onDateSelected: (value) {
// //                                       validityController.text = value;
// //                                       setState(() {
// //                                         // LocalDate a=LocalDate.today();
// //                                         // LocalDate b = LocalDate.dateTime(value);
// //                                         // Period diff = b.periodSince(a);
// //                                         // print("years: ${diff.years}; months: ${diff.months}; days: ${diff.days}");
// //                                       });
// //                                     },
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             SizedBox(
// //                               width: MediaQuery.of(context).size.width * 0.15,
// //                               child: Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text('Pricelist'.tr),
// //                                   DropdownMenu<String>(
// //                                     width:
// //                                         MediaQuery.of(context).size.width *
// //                                         0.10,
// //                                     // requestFocusOnTap: false,
// //                                     enableSearch: true,
// //                                     controller: priceListController,
// //                                     hintText: '',
// //                                     inputDecorationTheme: InputDecorationTheme(
// //                                       // filled: true,
// //                                       hintStyle: const TextStyle(
// //                                         fontStyle: FontStyle.italic,
// //                                       ),
// //                                       contentPadding: const EdgeInsets.fromLTRB(
// //                                         20,
// //                                         0,
// //                                         25,
// //                                         5,
// //                                       ),
// //                                       // outlineBorder: BorderSide(color: Colors.black,),
// //                                       enabledBorder: OutlineInputBorder(
// //                                         borderSide: BorderSide(
// //                                           color: Primary.primary.withAlpha(
// //                                             (0.2 * 255).toInt(),
// //                                           ),
// //                                           width: 1,
// //                                         ),
// //                                         borderRadius: const BorderRadius.all(
// //                                           Radius.circular(9),
// //                                         ),
// //                                       ),
// //                                       focusedBorder: OutlineInputBorder(
// //                                         borderSide: BorderSide(
// //                                           color: Primary.primary.withAlpha(
// //                                             (0.4 * 255).toInt(),
// //                                           ),
// //                                           width: 2,
// //                                         ),
// //                                         borderRadius: const BorderRadius.all(
// //                                           Radius.circular(9),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     // menuStyle: ,
// //                                     menuHeight: 250,
// //                                     dropdownMenuEntries:
// //                                         salesInvoiceCont.priceListsCodes
// //                                             .map<DropdownMenuEntry<String>>((
// //                                               String option,
// //                                             ) {
// //                                               return DropdownMenuEntry<String>(
// //                                                 value: option,
// //                                                 label: option,
// //                                               );
// //                                             })
// //                                             .toList(),
// //                                     enableFilter: true,
// //                                     onSelected: (String? val) {
// //                                       var index = salesInvoiceCont
// //                                           .priceListsCodes
// //                                           .indexOf(val!);
// //                                       salesInvoiceCont.setSelectedPriceListId(
// //                                         salesInvoiceCont.priceListsIds[index],
// //                                       );
// //                                       setState(() {
// //                                         salesInvoiceCont
// //                                             .resetItemsAfterChangePriceList();
// //                                       });
// //                                     },
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         gapH10,
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             //code
// //                             SizedBox(
// //                               width: MediaQuery.of(context).size.width * 0.37,
// //                               child: Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 crossAxisAlignment: CrossAxisAlignment.center,
// //                                 children: [
// //                                   Text('code'.tr),
// //                                   DropdownMenu<String>(
// //                                     width:
// //                                         MediaQuery.of(context).size.width *
// //                                         0.15,
// //                                     // requestFocusOnTap: false,
// //                                     enableSearch: true,
// //                                     controller: codeController,
// //                                     hintText: '${'search'.tr}...',
// //                                     inputDecorationTheme: InputDecorationTheme(
// //                                       // filled: true,
// //                                       hintStyle: const TextStyle(
// //                                         fontStyle: FontStyle.italic,
// //                                       ),
// //                                       contentPadding: const EdgeInsets.fromLTRB(
// //                                         20,
// //                                         0,
// //                                         25,
// //                                         5,
// //                                       ),
// //                                       enabledBorder: OutlineInputBorder(
// //                                         borderSide: BorderSide(
// //                                           color: Primary.primary.withAlpha(
// //                                             (0.2 * 255).toInt(),
// //                                           ),
// //                                           width: 1,
// //                                         ),
// //                                         borderRadius: const BorderRadius.all(
// //                                           Radius.circular(9),
// //                                         ),
// //                                       ),
// //                                       focusedBorder: OutlineInputBorder(
// //                                         borderSide: BorderSide(
// //                                           color: Primary.primary.withAlpha(
// //                                             (0.4 * 255).toInt(),
// //                                           ),
// //                                           width: 2,
// //                                         ),
// //                                         borderRadius: const BorderRadius.all(
// //                                           Radius.circular(9),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     menuHeight: 250,
// //                                     dropdownMenuEntries:
// //                                         salesInvoiceCont.customerNumberList
// //                                             .map<DropdownMenuEntry<String>>((
// //                                               option,
// //                                             ) {
// //                                               return DropdownMenuEntry<String>(
// //                                                 value: option,
// //                                                 label: option,
// //                                               );
// //                                             })
// //                                             .toList(),
// //                                     enableFilter: true,
// //                                     onSelected: (String? val) {
// //                                       setState(() {
// //                                         selectedItemCode = val!;
// //                                         indexNum = salesInvoiceCont
// //                                             .customerNumberList
// //                                             .indexOf(selectedItemCode);
// //                                         selectedCustomerIds =
// //                                             salesInvoiceCont
// //                                                 .customerIdsList[indexNum];
// //                                         searchController.text =
// //                                             salesInvoiceCont
// //                                                 .customerNameList[indexNum];
// //                                       });
// //                                     },
// //                                   ),
// //                                   ReusableDropDownMenuWithSearch(
// //                                     list: salesInvoiceCont.customerNameList,
// //                                     text: '',
// //                                     hint: '${'search'.tr}...',
// //                                     controller: searchController,
// //                                     onSelected: (String? val) {
// //                                       setState(() {
// //                                         selectedItem = val!;
// //                                         var index = salesInvoiceCont
// //                                             .customerNameList
// //                                             .indexOf(selectedItem);
// //                                         selectedCustomerIds =
// //                                             salesInvoiceCont
// //                                                 .customerIdsList[index];
// //                                         codeController.text =
// //                                             salesInvoiceCont
// //                                                 .customerNumberList[index];

// //                                         // codeController =
// //                                         //     quotationController.codeController;
// //                                       });
// //                                     },
// //                                     validationFunc: (value) {},
// //                                     rowWidth:
// //                                         MediaQuery.of(context).size.width *
// //                                         0.18,
// //                                     textFieldWidth:
// //                                         MediaQuery.of(context).size.width *
// //                                         0.17,
// //                                     clickableOptionText: 'create_new_client'.tr,
// //                                     isThereClickableOption: true,
// //                                     onTappedClickableOption: () {
// //                                       showDialog<String>(
// //                                         context: context,
// //                                         builder:
// //                                             (BuildContext context) =>
// //                                                 const AlertDialog(
// //                                                   backgroundColor: Colors.white,
// //                                                   shape: RoundedRectangleBorder(
// //                                                     borderRadius:
// //                                                         BorderRadius.all(
// //                                                           Radius.circular(9),
// //                                                         ),
// //                                                   ),
// //                                                   elevation: 0,
// //                                                   content: CreateClientDialog(),
// //                                                 ),
// //                                       );
// //                                     },
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             DialogTextField(
// //                               textEditingController: paymentTermsController,
// //                               text: 'payment_terms'.tr,
// //                               hint: '',
// //                               rowWidth:
// //                                   MediaQuery.of(context).size.width * 0.24,
// //                               textFieldWidth:
// //                                   MediaQuery.of(context).size.width * 0.15,
// //                               validationFunc: (val) {},
// //                             ),
// //                             // SizedBox(
// //                             //   width: MediaQuery.of(context).size.width * 0.24,
// //                             //   child: Row(
// //                             //     mainAxisAlignment:
// //                             //         MainAxisAlignment.spaceBetween,
// //                             //     children: [
// //                             //       Text('payment_terms'.tr),
// //                             //       GetBuilder<ExchangeRatesController>(
// //                             //         builder: (cont) {
// //                             //           return DropdownMenu<String>(
// //                             //             width:
// //                             //                 MediaQuery.of(context).size.width *
// //                             //                 0.15,
// //                             //             // requestFocusOnTap: false,
// //                             //             enableSearch: true,
// //                             //             controller: paymentTermsController,
// //                             //             hintText: '',
// //                             //             inputDecorationTheme: InputDecorationTheme(
// //                             //               // filled: true,
// //                             //               hintStyle: const TextStyle(
// //                             //                 fontStyle: FontStyle.italic,
// //                             //               ),
// //                             //               contentPadding:
// //                             //                   const EdgeInsets.fromLTRB(
// //                             //                     20,
// //                             //                     0,
// //                             //                     25,
// //                             //                     5,
// //                             //                   ),
// //                             //               // outlineBorder: BorderSide(color: Colors.black,),
// //                             //               enabledBorder: OutlineInputBorder(
// //                             //                 borderSide: BorderSide(
// //                             //                   color: Primary.primary.withAlpha(
// //                             //                     (0.2 * 255).toInt(),
// //                             //                   ),
// //                             //                   width: 1,
// //                             //                 ),
// //                             //                 borderRadius:
// //                             //                     const BorderRadius.all(
// //                             //                       Radius.circular(9),
// //                             //                     ),
// //                             //               ),
// //                             //               focusedBorder: OutlineInputBorder(
// //                             //                 borderSide: BorderSide(
// //                             //                   color: Primary.primary.withAlpha(
// //                             //                     (0.4 * 255).toInt(),
// //                             //                   ),
// //                             //                   width: 2,
// //                             //                 ),
// //                             //                 borderRadius:
// //                             //                     const BorderRadius.all(
// //                             //                       Radius.circular(9),
// //                             //                     ),
// //                             //               ),
// //                             //             ),
// //                             //             // menuStyle: ,
// //                             //             menuHeight: 250,
// //                             //             dropdownMenuEntries:
// //                             //                 termsList.map<
// //                             //                   DropdownMenuEntry<String>
// //                             //                 >((String option) {
// //                             //                   return DropdownMenuEntry<String>(
// //                             //                     value: option,
// //                             //                     label: option,
// //                             //                   );
// //                             //                 }).toList(),
// //                             //             enableFilter: true,
// //                             //             onSelected: (String? val) {
// //                             //               setState(() {
// //                             //                 // selectedCurrency = val!;
// //                             //                 // var index = cont.currenciesNamesList
// //                             //                 //     .indexOf(val);
// //                             //                 // selectedCurrencyId =
// //                             //                 // cont.currenciesIdsList[index];
// //                             //               });
// //                             //             },
// //                             //           );
// //                             //         },
// //                             //       ),
// //                             //     ],
// //                             //   ),
// //                             // ),
// //                           ],
// //                         ),

// //                         gapH10,
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             SizedBox(
// //                               width: MediaQuery.of(context).size.width * 0.3,
// //                               child: Column(
// //                                 mainAxisAlignment: MainAxisAlignment.start,
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   //address
// //                                   Row(
// //                                     children: [
// //                                       Text(
// //                                         '${'Street_building_floor'.tr} ',
// //                                         style: const TextStyle(fontSize: 12),
// //                                       ),
// //                                       gapW10,
// //                                       Text(
// //                                         " ${salesInvoiceCont.street[selectedCustomerIds] ?? ''} ",
// //                                         style: const TextStyle(fontSize: 12),
// //                                       ),
// //                                       Text(
// //                                         salesInvoiceCont.floorAndBuilding[selectedCustomerIds] ==
// //                                                     '' ||
// //                                                 salesInvoiceCont
// //                                                         .floorAndBuilding[selectedCustomerIds] ==
// //                                                     null
// //                                             ? ''
// //                                             : ',',
// //                                       ),
// //                                       Text(
// //                                         " ${salesInvoiceCont.floorAndBuilding[selectedCustomerIds] ?? ''}",
// //                                         style: const TextStyle(fontSize: 12),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   gapH6,
// //                                   //tel
// //                                   Row(
// //                                     children: [
// //                                       Text(
// //                                         'phone_number'.tr,
// //                                         style: const TextStyle(fontSize: 12),
// //                                       ),
// //                                       gapW10,
// //                                       Text(
// //                                         "${salesInvoiceCont.phoneNumber[selectedCustomerIds] ?? ''}",
// //                                         style: const TextStyle(fontSize: 12),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             gapW16,
// //                             SizedBox(
// //                               width: MediaQuery.of(context).size.width * 0.24,
// //                               child: Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text(
// //                                     'price'.tr,
// //                                     style:
// //                                         salesInvoiceCont.isVatExemptChecked
// //                                             ? TextStyle(color: Others.divider)
// //                                             : TextStyle(),
// //                                   ),
// //                                   GetBuilder<ExchangeRatesController>(
// //                                     builder: (cont) {
// //                                       return DropdownMenu<String>(
// //                                         enabled:
// //                                             !salesInvoiceCont
// //                                                 .isVatExemptChecked,
// //                                         width:
// //                                             MediaQuery.of(context).size.width *
// //                                             0.15,
// //                                         // requestFocusOnTap: false,
// //                                         enableSearch: true,
// //                                         controller: priceConditionController,
// //                                         hintText: '',

// //                                         textStyle: const TextStyle(
// //                                           fontSize: 12,
// //                                         ),
// //                                         inputDecorationTheme: InputDecorationTheme(
// //                                           // filled: true,
// //                                           hintStyle: const TextStyle(
// //                                             fontStyle: FontStyle.italic,
// //                                           ),
// //                                           contentPadding:
// //                                               const EdgeInsets.fromLTRB(
// //                                                 20,
// //                                                 0,
// //                                                 25,
// //                                                 5,
// //                                               ),
// //                                           // outlineBorder: BorderSide(color: Colors.black,),
// //                                           disabledBorder: OutlineInputBorder(
// //                                             borderSide: BorderSide(
// //                                               color: Others.divider,
// //                                               width: 1,
// //                                             ),
// //                                             borderRadius:
// //                                                 const BorderRadius.all(
// //                                                   Radius.circular(9),
// //                                                 ),
// //                                           ),
// //                                           enabledBorder: OutlineInputBorder(
// //                                             borderSide: BorderSide(
// //                                               color: Primary.primary.withAlpha(
// //                                                 (0.2 * 255).toInt(),
// //                                               ),
// //                                               width: 1,
// //                                             ),
// //                                             borderRadius:
// //                                                 const BorderRadius.all(
// //                                                   Radius.circular(9),
// //                                                 ),
// //                                           ),
// //                                           focusedBorder: OutlineInputBorder(
// //                                             borderSide: BorderSide(
// //                                               color: Primary.primary.withAlpha(
// //                                                 (0.4 * 255).toInt(),
// //                                               ),
// //                                               width: 2,
// //                                             ),
// //                                             borderRadius:
// //                                                 const BorderRadius.all(
// //                                                   Radius.circular(9),
// //                                                 ),
// //                                           ),
// //                                         ),
// //                                         // menuStyle: ,
// //                                         menuHeight: 250,
// //                                         dropdownMenuEntries:
// //                                             pricesVatConditions.map<
// //                                               DropdownMenuEntry<String>
// //                                             >((String option) {
// //                                               return DropdownMenuEntry<String>(
// //                                                 value: option,
// //                                                 label: option,
// //                                               );
// //                                             }).toList(),
// //                                         enableFilter: true,
// //                                         onSelected: (String? value) {
// //                                           setState(() {
// //                                             if (value ==
// //                                                 'Prices are before vat') {
// //                                               salesInvoiceCont
// //                                                   .setIsBeforeVatPrices(true);
// //                                             } else {
// //                                               salesInvoiceCont
// //                                                   .setIsBeforeVatPrices(false);
// //                                             }
// //                                             var keys =
// //                                                 salesInvoiceCont
// //                                                     .unitPriceControllers
// //                                                     .keys
// //                                                     .toList();
// //                                             for (
// //                                               int i = 0;
// //                                               i <
// //                                                   salesInvoiceCont
// //                                                       .unitPriceControllers
// //                                                       .length;
// //                                               i++
// //                                             ) {
// //                                               var selectedItemId =
// //                                                   '${salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_id']}';
// //                                               if (selectedItemId != '') {
// //                                                 if (salesInvoiceCont
// //                                                         .itemsPricesCurrencies[selectedItemId] ==
// //                                                     selectedCurrency) {
// //                                                   salesInvoiceCont
// //                                                       .unitPriceControllers[keys[i]]!
// //                                                       .text = salesInvoiceCont
// //                                                           .itemUnitPrice[selectedItemId]
// //                                                           .toString();
// //                                                 } else if (salesInvoiceCont
// //                                                             .selectedCurrencyName ==
// //                                                         'USD' &&
// //                                                     salesInvoiceCont
// //                                                             .itemsPricesCurrencies[selectedItemId] !=
// //                                                         selectedCurrency) {
// //                                                   var result = exchangeRatesController
// //                                                       .exchangeRatesList
// //                                                       .firstWhere(
// //                                                         (item) =>
// //                                                             item["currency"] ==
// //                                                             salesInvoiceCont
// //                                                                 .itemsPricesCurrencies[selectedItemId],
// //                                                         orElse: () => null,
// //                                                       );
// //                                                   var divider = '1';
// //                                                   if (result != null) {
// //                                                     divider =
// //                                                         result["exchange_rate"]
// //                                                             .toString();
// //                                                   }
// //                                                   salesInvoiceCont
// //                                                           .unitPriceControllers[keys[i]]!
// //                                                           .text =
// //                                                       '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
// //                                                 } else if (salesInvoiceCont
// //                                                             .selectedCurrencyName !=
// //                                                         'USD' &&
// //                                                     salesInvoiceCont
// //                                                             .itemsPricesCurrencies[selectedItemId] ==
// //                                                         'USD') {
// //                                                   salesInvoiceCont
// //                                                           .unitPriceControllers[keys[i]]!
// //                                                           .text =
// //                                                       '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) * double.parse(salesInvoiceCont.exchangeRateForSelectedCurrency))}')}';
// //                                                 } else {
// //                                                   var result = exchangeRatesController
// //                                                       .exchangeRatesList
// //                                                       .firstWhere(
// //                                                         (item) =>
// //                                                             item["currency"] ==
// //                                                             salesInvoiceCont
// //                                                                 .itemsPricesCurrencies[selectedItemId],
// //                                                         orElse: () => null,
// //                                                       );
// //                                                   var divider = '1';
// //                                                   if (result != null) {
// //                                                     divider =
// //                                                         result["exchange_rate"]
// //                                                             .toString();
// //                                                   }
// //                                                   var usdPrice =
// //                                                       '${double.parse('${(double.parse(salesInvoiceCont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
// //                                                   salesInvoiceCont
// //                                                           .unitPriceControllers[keys[i]]!
// //                                                           .text =
// //                                                       '${double.parse('${(double.parse(usdPrice) * double.parse(salesInvoiceCont.exchangeRateForSelectedCurrency))}')}';
// //                                                 }
// //                                                 if (!salesInvoiceCont
// //                                                     .isBeforeVatPrices) {
// //                                                   var taxRate =
// //                                                       double.parse(
// //                                                         salesInvoiceCont
// //                                                             .itemsVats[selectedItemId],
// //                                                       ) /
// //                                                       100.0;
// //                                                   var taxValue =
// //                                                       taxRate *
// //                                                       double.parse(
// //                                                         salesInvoiceCont
// //                                                             .unitPriceControllers[keys[i]]!
// //                                                             .text,
// //                                                       );

// //                                                   salesInvoiceCont
// //                                                           .unitPriceControllers[keys[i]]!
// //                                                           .text =
// //                                                       '${double.parse(salesInvoiceCont.unitPriceControllers[keys[i]]!.text) + taxValue}';
// //                                                 }
// //                                                 salesInvoiceCont
// //                                                     .unitPriceControllers[keys[i]]!
// //                                                     .text = double.parse(
// //                                                   salesInvoiceCont
// //                                                       .unitPriceControllers[keys[i]]!
// //                                                       .text,
// //                                                 ).toStringAsFixed(2);
// //                                                 var totalLine =
// //                                                     '${(double.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_quantity']) * double.parse(salesInvoiceCont.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(salesInvoiceCont.rowsInListViewInSalesInvoice[keys[i]]['item_discount']) / 100)}';

// //                                                 salesInvoiceCont
// //                                                     .setEnteredUnitPriceInSalesInvoice(
// //                                                       keys[i],
// //                                                       salesInvoiceCont
// //                                                           .unitPriceControllers[keys[i]]!
// //                                                           .text,
// //                                                     );
// //                                                 salesInvoiceCont
// //                                                     .setMainTotalInSalesInvoice(
// //                                                       keys[i],
// //                                                       totalLine,
// //                                                     );
// //                                                 salesInvoiceCont
// //                                                     .getTotalItems();
// //                                               }
// //                                             }
// //                                           });
// //                                         },
// //                                       );
// //                                     },
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         gapH10,
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             SizedBox(
// //                               width: MediaQuery.of(context).size.width * 0.3,
// //                               child: Column(
// //                                 mainAxisAlignment: MainAxisAlignment.start,
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Row(
// //                                     children: [
// //                                       Text(
// //                                         'email'.tr,
// //                                         style: const TextStyle(fontSize: 12),
// //                                       ),
// //                                       gapW10,
// //                                       GetBuilder<SalesInvoiceController>(
// //                                         builder: (cont) {
// //                                           return Text(
// //                                             "${cont.email[selectedCustomerIds] ?? ''}",
// //                                             style: const TextStyle(
// //                                               fontSize: 12,
// //                                             ),
// //                                           );
// //                                         },
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   gapH6,
// //                                   salesInvoiceCont
// //                                           .isVatExemptCheckBoxShouldAppear
// //                                       ? Row(
// //                                         children: [
// //                                           Text(
// //                                             'vat'.tr,
// //                                             style: const TextStyle(
// //                                               fontSize: 12,
// //                                             ),
// //                                           ),
// //                                           gapW10,
// //                                         ],
// //                                       )
// //                                       : SizedBox(),
// //                                 ],
// //                               ),
// //                             ),
// //                             gapW16,
// //                             //vat exempt
// //                             salesInvoiceCont.isVatExemptCheckBoxShouldAppear
// //                                 ? SizedBox(
// //                                   width:
// //                                       MediaQuery.of(context).size.width * 0.28,
// //                                   child: Row(
// //                                     mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       Expanded(
// //                                         child: ListTile(
// //                                           title: Text(
// //                                             'vat_exempt'.tr,
// //                                             style: const TextStyle(
// //                                               fontSize: 12,
// //                                             ),
// //                                           ),
// //                                           leading: Checkbox(
// //                                             value:
// //                                                 salesInvoiceCont
// //                                                     .isVatExemptChecked,
// //                                             onChanged: (bool? value) {
// //                                               salesInvoiceCont
// //                                                   .setIsVatExemptChecked(
// //                                                     value!,
// //                                                   );
// //                                               if (value) {
// //                                                 priceConditionController.text =
// //                                                     'Prices are before vat';
// //                                                 salesInvoiceCont
// //                                                     .setIsBeforeVatPrices(true);
// //                                                 vatExemptController.text =
// //                                                     vatExemptList[0];
// //                                                 salesInvoiceCont
// //                                                     .setIsVatExempted(
// //                                                       true,
// //                                                       false,
// //                                                       false,
// //                                                     );
// //                                               } else {
// //                                                 vatExemptController.clear();
// //                                                 salesInvoiceCont
// //                                                     .setIsVatExempted(
// //                                                       false,
// //                                                       false,
// //                                                       false,
// //                                                     );
// //                                               }
// //                                               // setState(() {
// //                                               //   isVatExemptChecked = value!;
// //                                               // });
// //                                             },
// //                                           ),
// //                                         ),
// //                                       ),
// //                                       salesInvoiceCont.isVatExemptChecked ==
// //                                               false
// //                                           ? DropdownMenu<String>(
// //                                             width:
// //                                                 MediaQuery.of(
// //                                                   context,
// //                                                 ).size.width *
// //                                                 0.15,
// //                                             enableSearch: true,
// //                                             controller: vatExemptController,
// //                                             hintText: '',

// //                                             textStyle: const TextStyle(
// //                                               fontSize: 12,
// //                                             ),
// //                                             inputDecorationTheme:
// //                                                 InputDecorationTheme(
// //                                                   hintStyle: const TextStyle(
// //                                                     fontStyle: FontStyle.italic,
// //                                                   ),
// //                                                   enabledBorder:
// //                                                       OutlineInputBorder(
// //                                                         borderSide: BorderSide(
// //                                                           color: Primary.primary
// //                                                               .withAlpha(
// //                                                                 (0.2 * 255)
// //                                                                     .toInt(),
// //                                                               ),
// //                                                           width: 1,
// //                                                         ),
// //                                                         borderRadius:
// //                                                             const BorderRadius.all(
// //                                                               Radius.circular(
// //                                                                 9,
// //                                                               ),
// //                                                             ),
// //                                                       ),
// //                                                   focusedBorder:
// //                                                       OutlineInputBorder(
// //                                                         borderSide: BorderSide(
// //                                                           color: Primary.primary
// //                                                               .withAlpha(
// //                                                                 (0.4 * 255)
// //                                                                     .toInt(),
// //                                                               ),
// //                                                           width: 2,
// //                                                         ),
// //                                                         borderRadius:
// //                                                             const BorderRadius.all(
// //                                                               Radius.circular(
// //                                                                 9,
// //                                                               ),
// //                                                             ),
// //                                                       ),
// //                                                 ),
// //                                             // menuStyle: ,
// //                                             menuHeight: 250,
// //                                             dropdownMenuEntries:
// //                                                 termsList.map<
// //                                                   DropdownMenuEntry<String>
// //                                                 >((String option) {
// //                                                   return DropdownMenuEntry<
// //                                                     String
// //                                                   >(
// //                                                     value: option,
// //                                                     label: option,
// //                                                   );
// //                                                 }).toList(),
// //                                             enableFilter: true,
// //                                             onSelected: (String? val) {},
// //                                           )
// //                                           : DropdownMenu<String>(
// //                                             width:
// //                                                 MediaQuery.of(
// //                                                   context,
// //                                                 ).size.width *
// //                                                 0.15,
// //                                             // requestFocusOnTap: false,
// //                                             enableSearch: true,
// //                                             controller: vatExemptController,
// //                                             hintText: '',

// //                                             textStyle: const TextStyle(
// //                                               fontSize: 12,
// //                                             ),
// //                                             inputDecorationTheme:
// //                                                 InputDecorationTheme(
// //                                                   // filled: true,
// //                                                   hintStyle: const TextStyle(
// //                                                     fontStyle: FontStyle.italic,
// //                                                   ),
// //                                                   enabledBorder:
// //                                                       OutlineInputBorder(
// //                                                         borderSide: BorderSide(
// //                                                           color: Primary.primary
// //                                                               .withAlpha(
// //                                                                 (0.2 * 255)
// //                                                                     .toInt(),
// //                                                               ),
// //                                                           width: 1,
// //                                                         ),
// //                                                         borderRadius:
// //                                                             const BorderRadius.all(
// //                                                               Radius.circular(
// //                                                                 9,
// //                                                               ),
// //                                                             ),
// //                                                       ),
// //                                                   focusedBorder:
// //                                                       OutlineInputBorder(
// //                                                         borderSide: BorderSide(
// //                                                           color: Primary.primary
// //                                                               .withAlpha(
// //                                                                 (0.4 * 255)
// //                                                                     .toInt(),
// //                                                               ),
// //                                                           width: 2,
// //                                                         ),
// //                                                         borderRadius:
// //                                                             const BorderRadius.all(
// //                                                               Radius.circular(
// //                                                                 9,
// //                                                               ),
// //                                                             ),
// //                                                       ),
// //                                                 ),
// //                                             // menuStyle: ,
// //                                             menuHeight: 250,
// //                                             dropdownMenuEntries:
// //                                                 vatExemptList.map<
// //                                                   DropdownMenuEntry<String>
// //                                                 >((String option) {
// //                                                   return DropdownMenuEntry<
// //                                                     String
// //                                                   >(
// //                                                     value: option,
// //                                                     label: option,
// //                                                   );
// //                                                 }).toList(),
// //                                             enableFilter: true,
// //                                             onSelected: (String? val) {
// //                                               setState(() {
// //                                                 if (val ==
// //                                                     'Printed as "vat exempted"') {
// //                                                   salesInvoiceCont
// //                                                       .setIsVatExempted(
// //                                                         true,
// //                                                         false,
// //                                                         false,
// //                                                       );
// //                                                 } else if (val ==
// //                                                     'Printed as "vat 0 % = 0"') {
// //                                                   salesInvoiceCont
// //                                                       .setIsVatExempted(
// //                                                         false,
// //                                                         true,
// //                                                         false,
// //                                                       );
// //                                                 } else {
// //                                                   salesInvoiceCont
// //                                                       .setIsVatExempted(
// //                                                         false,
// //                                                         false,
// //                                                         true,
// //                                                       );
// //                                                 }
// //                                               });
// //                                             },
// //                                           ),
// //                                     ],
// //                                   ),
// //                                 )
// //                                 : SizedBox(),
// //                           ],
// //                         ),
// //                         gapH10,
// //                       ],
// //                     ),
// //                   ),
// //                   gapH10,
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.start,
// //                     children: [
// //                       Wrap(
// //                         spacing: 0.0,
// //                         direction: Axis.horizontal,
// //                         children:
// //                             tabsList
// //                                 .map(
// //                                   (element) => _buildTabChipItem(
// //                                     element,
// //                                     // element['id'],
// //                                     // element['name'],
// //                                     tabsList.indexOf(element),
// //                                   ),
// //                                 )
// //                                 .toList(),
// //                       ),
// //                     ],
// //                   ),

// //                   selectedTabIndex == 0
// //                       ? Column(
// //                         children: [
// //                           Container(
// //                             padding: EdgeInsets.symmetric(
// //                               // horizontal:
// //                               //     MediaQuery.of(context).size.width * 0.01,
// //                               vertical: 15,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: Primary.primary,
// //                               borderRadius: const BorderRadius.all(
// //                                 Radius.circular(6),
// //                               ),
// //                             ),
// //                             child: Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 SizedBox(
// //                                   width:
// //                                       MediaQuery.of(context).size.width * 0.02,
// //                                 ),
// //                                 TableTitle(
// //                                   text: 'item_code'.tr,
// //                                   width:
// //                                       MediaQuery.of(context).size.width * 0.15,
// //                                 ),
// //                                 TableTitle(
// //                                   text: 'description'.tr,
// //                                   width:
// //                                       MediaQuery.of(context).size.width * 0.3,
// //                                 ),
// //                                 TableTitle(
// //                                   text: 'quantity'.tr,
// //                                   width:
// //                                       MediaQuery.of(context).size.width * 0.04,
// //                                 ),
// //                                 TableTitle(
// //                                   text: 'unit_price'.tr,
// //                                   width:
// //                                       MediaQuery.of(context).size.width * 0.05,
// //                                 ),
// //                                 TableTitle(
// //                                   text: '${'disc'.tr}. %',
// //                                   width:
// //                                       MediaQuery.of(context).size.width * 0.05,
// //                                 ),
// //                                 TableTitle(
// //                                   text: 'total'.tr,
// //                                   width:
// //                                       MediaQuery.of(context).size.width * 0.05,
// //                                 ),
// //                                 TableTitle(
// //                                   text: 'more_options'.tr,
// //                                   width:
// //                                       MediaQuery.of(context).size.width * 0.07,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           Container(
// //                             padding: EdgeInsets.symmetric(
// //                               horizontal:
// //                                   MediaQuery.of(context).size.width * 0.01,
// //                             ),
// //                             decoration: const BoxDecoration(
// //                               borderRadius: BorderRadius.only(
// //                                 bottomLeft: Radius.circular(6),
// //                                 bottomRight: Radius.circular(6),
// //                               ),
// //                               color: Colors.white,
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 SizedBox(
// //                                   height:
// //                                       salesInvoiceCont
// //                                           .listViewLengthInSalesInvoice +
// //                                       50,
// //                                   child: ListView(
// //                                     children:
// //                                         keysList.map((key) {
// //                                           return Dismissible(
// //                                             key: Key(
// //                                               key,
// //                                             ), // Ensure each widget has a unique key
// //                                             onDismissed:
// //                                                 (direction) => salesInvoiceCont
// //                                                     .removeFromOrderLinesInSalesInvoiceList(
// //                                                       key.toString(),
// //                                                     ),
// //                                             child:
// //                                                 salesInvoiceCont
// //                                                     .orderLinesSalesInvoiceList[key] ??
// //                                                 const SizedBox(),
// //                                           );
// //                                         }).toList(),
// //                                   ),
// //                                 ),

// //                                 Row(
// //                                   children: [
// //                                     ReusableAddCard(
// //                                       text: 'title'.tr,
// //                                       onTap: () {
// //                                         addNewTitle();
// //                                       },
// //                                     ),
// //                                     gapW32,
// //                                     ReusableAddCard(
// //                                       text: 'item'.tr,
// //                                       onTap: () {
// //                                         addNewItem();
// //                                       },
// //                                     ),
// //                                     gapW32,
// //                                     ReusableAddCard(
// //                                       text: 'combo'.tr,
// //                                       onTap: () {
// //                                         addNewCombo();
// //                                       },
// //                                     ),
// //                                     gapW32,
// //                                     ReusableAddCard(
// //                                       text: 'image'.tr,
// //                                       onTap: () {
// //                                         addNewImage();
// //                                       },
// //                                     ),
// //                                     gapW32,
// //                                     ReusableAddCard(
// //                                       text: 'note'.tr,
// //                                       onTap: () {
// //                                         addNewNote();
// //                                       },
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           gapH24,
// //                         ],
// //                       )
// //                       : Container(
// //                         padding: EdgeInsets.symmetric(
// //                           horizontal: MediaQuery.of(context).size.width * 0.04,
// //                           vertical: 15,
// //                         ),
// //                         decoration: const BoxDecoration(
// //                           borderRadius: BorderRadius.only(
// //                             bottomLeft: Radius.circular(6),
// //                             bottomRight: Radius.circular(6),
// //                           ),
// //                           color: Colors.white,
// //                         ),
// //                         child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             SizedBox(
// //                               width: MediaQuery.of(context).size.width * 0.35,
// //                               child: Column(
// //                                 children: [
// //                                   DialogDropMenu(
// //                                     controller: salesPersonController,
// //                                     optionsList:
// //                                         salesInvoiceController
// //                                             .salesPersonListNames,
// //                                     text: 'sales_person'.tr,
// //                                     hint: 'search'.tr,
// //                                     rowWidth:
// //                                         MediaQuery.of(context).size.width * 0.3,
// //                                     textFieldWidth:
// //                                         MediaQuery.of(context).size.width *
// //                                         0.15,
// //                                     onSelected: (String? val) {
// //                                       setState(() {
// //                                         selectedSalesPerson = val!;
// //                                         var index = salesInvoiceController
// //                                             .salesPersonListNames
// //                                             .indexOf(val);
// //                                         selectedSalesPersonId =
// //                                             salesInvoiceController
// //                                                 .salesPersonListId[index];
// //                                       });
// //                                     },
// //                                   ),
// //                                   gapH16,
// //                                   DialogDropMenu(
// //                                     optionsList: const [''],
// //                                     text: 'commission_method'.tr,
// //                                     hint: '',
// //                                     rowWidth:
// //                                         MediaQuery.of(context).size.width * 0.3,
// //                                     textFieldWidth:
// //                                         MediaQuery.of(context).size.width *
// //                                         0.15,
// //                                     onSelected: () {},
// //                                   ),
// //                                   gapH16,
// //                                   DialogDropMenu(
// //                                     controller: cashingMethodsController,
// //                                     optionsList:
// //                                         salesInvoiceCont
// //                                             .cashingMethodsNamesList,
// //                                     text: 'cashing_method'.tr,
// //                                     hint: '',
// //                                     rowWidth:
// //                                         MediaQuery.of(context).size.width * 0.3,
// //                                     textFieldWidth:
// //                                         MediaQuery.of(context).size.width *
// //                                         0.15,
// //                                     onSelected: (value) {
// //                                       var index = salesInvoiceCont
// //                                           .cashingMethodsNamesList
// //                                           .indexOf(value);
// //                                       salesInvoiceCont
// //                                           .setSelectedCashingMethodId(
// //                                             salesInvoiceCont
// //                                                 .cashingMethodsIdsList[index],
// //                                           );
// //                                     },
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             SizedBox(
// //                               width: MediaQuery.of(context).size.width * 0.3,
// //                               child: Column(
// //                                 mainAxisAlignment: MainAxisAlignment.start,
// //                                 children: [
// //                                   DialogTextField(
// //                                     textEditingController: commissionController,
// //                                     text: 'commission'.tr,
// //                                     rowWidth:
// //                                         MediaQuery.of(context).size.width * 0.3,
// //                                     textFieldWidth:
// //                                         MediaQuery.of(context).size.width *
// //                                         0.15,
// //                                     validationFunc: (val) {},
// //                                   ),
// //                                   gapH16,
// //                                   DialogTextField(
// //                                     textEditingController:
// //                                         totalCommissionController,
// //                                     text: 'total_commission'.tr,
// //                                     rowWidth:
// //                                         MediaQuery.of(context).size.width * 0.3,
// //                                     textFieldWidth:
// //                                         MediaQuery.of(context).size.width *
// //                                         0.15,
// //                                     validationFunc: (val) {},
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),

// //                   gapH10,

// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       vertical: 20,
// //                       horizontal: 40,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(6),
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'terms_conditions'.tr,
// //                           style: TextStyle(
// //                             fontSize: 15,
// //                             color: TypographyColor.titleTable,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         gapH16,
// //                         SizedBox(
// //                           height: 300,
// //                           child: Column(
// //                             children: [
// //                               QuillSimpleToolbar(
// //                                 controller: _controller,
// //                                 config: QuillSimpleToolbarConfig(
// //                                   showFontFamily: false,
// //                                   showColorButton: false,
// //                                   showBackgroundColorButton: false,
// //                                   showSearchButton: false,
// //                                   showDirection: false,
// //                                   showLink: false,
// //                                   showAlignmentButtons: false,
// //                                   showLeftAlignment: false,
// //                                   showRightAlignment: false,
// //                                   showListCheck: false,
// //                                   showIndent: false,
// //                                   showQuote: false,
// //                                   showCodeBlock: false,
// //                                 ),
// //                               ),
// //                               Expanded(
// //                                 child: Container(
// //                                   padding: const EdgeInsets.all(8),
// //                                   color: Colors.grey[100],
// //                                   child: QuillEditor.basic(
// //                                     controller: _controller,

// //                                     // readOnly: false, // اجعلها true إذا كنت تريد وضع القراءة فقط
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         // ReusableTextField(
// //                         //   textEditingController:
// //                         //       termsAndConditionsController, //todo
// //                         //   isPasswordField: false,
// //                         //   hint: 'terms_conditions'.tr,
// //                         //   onChangedFunc: (val) {},
// //                         //   validationFunc: (val) {
// //                         //     // setState(() {
// //                         //     //   termsAndConditions = val;
// //                         //     // });
// //                         //   },
// //                         // ),
// //                         // gapH16,
// //                         // Text(
// //                         //   'or_create_new_terms_conditions'.tr,
// //                         //   style: TextStyle(
// //                         //     fontSize: 16,
// //                         //     color: Primary.primary,
// //                         //     decoration: TextDecoration.underline,
// //                         //     fontStyle: FontStyle.italic,
// //                         //   ),
// //                         // ),
// //                       ],
// //                     ),
// //                   ),

// //                   gapH16,

// //                   GetBuilder<SalesInvoiceController>(
// //                     builder: (cont) {
// //                       return Container(
// //                         padding: const EdgeInsets.symmetric(
// //                           vertical: 20,
// //                           horizontal: 40,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: Primary.p20,
// //                           borderRadius: BorderRadius.circular(6),
// //                         ),
// //                         child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.end,
// //                           children: [
// //                             SizedBox(
// //                               width: MediaQuery.of(context).size.width * 0.4,
// //                               child: Column(
// //                                 children: [
// //                                   Row(
// //                                     mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       Text('total_before_vat'.tr),
// //                                       ReusableShowInfoCard(
// //                                         text: cont.totalItems.toStringAsFixed(
// //                                           2,
// //                                         ),
// //                                         width:
// //                                             MediaQuery.of(context).size.width *
// //                                             0.1,
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   gapH6,
// //                                   Row(
// //                                     mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       Text('global_disc'.tr),
// //                                       Row(
// //                                         children: [
// //                                           SizedBox(
// //                                             width:
// //                                                 MediaQuery.of(
// //                                                   context,
// //                                                 ).size.width *
// //                                                 0.1,
// //                                             child: ReusableNumberField(
// //                                               textEditingController:
// //                                                   globalDiscPercentController,
// //                                               isPasswordField: false,
// //                                               isCentered: true,
// //                                               hint: '0',
// //                                               onChangedFunc: (val) {
// //                                                 // totalAllItems =
// //                                                 //     quotationController
// //                                                 //         .totalItems ;

// //                                                 setState(() {
// //                                                   if (val == '') {
// //                                                     globalDiscPercentController
// //                                                         .text = '0';
// //                                                     globalDiscountPercentage =
// //                                                         '0';
// //                                                   } else {
// //                                                     globalDiscountPercentage =
// //                                                         val;
// //                                                   }
// //                                                 });
// //                                                 cont.setGlobalDisc(
// //                                                   globalDiscountPercentage,
// //                                                 );
// //                                                 // cont.getTotalItems();
// //                                               },
// //                                               validationFunc: (val) {},
// //                                             ),
// //                                           ),
// //                                           gapW10,
// //                                           ReusableShowInfoCard(
// //                                             text: cont.globalDisc,
// //                                             width:
// //                                                 MediaQuery.of(
// //                                                   context,
// //                                                 ).size.width *
// //                                                 0.1,
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   gapH6,
// //                                   Row(
// //                                     mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       Text('special_disc'.tr),
// //                                       Row(
// //                                         children: [
// //                                           SizedBox(
// //                                             width:
// //                                                 MediaQuery.of(
// //                                                   context,
// //                                                 ).size.width *
// //                                                 0.1,
// //                                             child: ReusableNumberField(
// //                                               textEditingController:
// //                                                   specialDiscPercentController,
// //                                               isPasswordField: false,
// //                                               isCentered: true,
// //                                               hint: '0',
// //                                               onChangedFunc: (val) {
// //                                                 setState(() {
// //                                                   if (val == '') {
// //                                                     specialDiscPercentController
// //                                                         .text = '0';
// //                                                     specialDiscountPercentage =
// //                                                         '0';
// //                                                   } else {
// //                                                     specialDiscountPercentage =
// //                                                         val;
// //                                                   }
// //                                                 });
// //                                                 cont.setSpecialDisc(
// //                                                   specialDiscountPercentage,
// //                                                 );
// //                                               },
// //                                               validationFunc: (val) {},
// //                                             ),
// //                                           ),
// //                                           gapW10,
// //                                           ReusableShowInfoCard(
// //                                             text: cont.specialDisc,
// //                                             width:
// //                                                 MediaQuery.of(
// //                                                   context,
// //                                                 ).size.width *
// //                                                 0.1,
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   gapH6,
// //                                   salesInvoiceCont
// //                                           .isVatExemptCheckBoxShouldAppear
// //                                       ? Row(
// //                                         mainAxisAlignment:
// //                                             MainAxisAlignment.spaceBetween,
// //                                         children: [
// //                                           Text('vat'.tr),
// //                                           Row(
// //                                             children: [
// //                                               ReusableShowInfoCard(
// //                                                 text: cont.vatInPrimaryCurrency,
// //                                                 // .toString(),
// //                                                 width:
// //                                                     MediaQuery.of(
// //                                                       context,
// //                                                     ).size.width *
// //                                                     0.1,
// //                                               ),
// //                                               gapW10,
// //                                               ReusableShowInfoCard(
// //                                                 text: cont.vat11,
// //                                                 // .toString(),
// //                                                 width:
// //                                                     MediaQuery.of(
// //                                                       context,
// //                                                     ).size.width *
// //                                                     0.1,
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ],
// //                                       )
// //                                       : SizedBox(),
// //                                   gapH10,
// //                                   Row(
// //                                     mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       Text(
// //                                         'total_amount'.tr,
// //                                         style: TextStyle(
// //                                           fontSize: 16,
// //                                           color: Primary.primary,
// //                                           fontWeight: FontWeight.bold,
// //                                         ),
// //                                       ),
// //                                       Text(
// //                                         // '${'usd'.tr} 0.00',
// //                                         '${salesInvoiceCont.selectedCurrencyName} ${formatDoubleWithCommas(double.parse(salesInvoiceCont.totalSalesOrder))}',
// //                                         style: TextStyle(
// //                                           fontSize: 16,
// //                                           color: Primary.primary,
// //                                           fontWeight: FontWeight.bold,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                   gapH16,

// //                   //discard & save button
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.end,
// //                     children: [
// //                       // TextButton(
// //                       //   onPressed: () {
// //                       //     setState(() {
// //                       //       isVatExemptChecked =
// //                       //           '${widget.info['vatExempt'] ?? ''}' == '1'
// //                       //               ? true
// //                       //               : false;
// //                       //       isBeforeVatPrices =
// //                       //           '${widget.info['beforeVatPrices'] ?? ''}' == '1'
// //                       //               ? true
// //                       //               : false;
// //                       //       isVatInclusivePrices =
// //                       //           '${widget.info['vatInclusivePrices'] ?? ''}' ==
// //                       //                   '1'
// //                       //               ? true
// //                       //               : false;
// //                       //       isPrintedAsVatExempt =
// //                       //           '${widget.info['printedAsVatExempt'] ?? ''}' ==
// //                       //                   '1'
// //                       //               ? true
// //                       //               : false;
// //                       //       isPrintedAsPercentage =
// //                       //           '${widget.info['printedAsPercentage'] ?? ''}' ==
// //                       //                   '1'
// //                       //               ? true
// //                       //               : false;
// //                       //       isVatNoPrinted =
// //                       //           '${widget.info['notPrinted'] ?? ''}' == '1'
// //                       //               ? true
// //                       //               : false;
// //                       //
// //                       //       searchController.text =
// //                       //           widget.info['client']['name'] ?? '';
// //                       //       codeController.text = widget.info['code'] ?? '';
// //                       //       selectedItemCode = widget.info['code'] ?? '';
// //                       //       refController.text = widget.info['reference'];
// //                       //       validityController.text =
// //                       //           widget.info['validity'] ?? '';
// //                       //       currencyController.text =
// //                       //           widget.info['currency']['name'] ?? '';
// //                       //       termsAndConditionsController.text =
// //                       //           widget.info['termsAndConditions'] ?? '';
// //                       //       globalDiscPercentController.text =
// //                       //           widget.info['globalDiscount'] ??
// //                       //           ''; // entered by user
// //                       //       specialDiscPercentController.text =
// //                       //           widget.info['specialDiscount'] ??
// //                       //           ''; //entered by user
// //                       //       quotationController.globalDisc =
// //                       //           widget.info['globalDiscountAmount'] ?? '';
// //                       //       quotationController.specialDisc =
// //                       //           widget.info['specialDiscountAmount'] ?? '';
// //                       //
// //                       //       quotationController.totalItems = double.parse(
// //                       //         '${widget.info['totalBeforeVat']}',
// //                       //       );
// //                       //       quotationController.vat11 = '${widget.info['vat']}';
// //                       //       quotationController.vatInPrimaryCurrency =
// //                       //           '${widget.info['vatLebanese']}';
// //                       //       quotationController.totalQuotation =
// //                       //           '${widget.info['total']}';
// //                       //
// //                       //       if ('${widget.info['vatExempt'] ?? ''}' == '0' &&
// //                       //           '${widget.info['beforeVatPrices'] ?? ''}' ==
// //                       //               '1') {
// //                       //         vatExemptController.text =
// //                       //             'prices are before vat';
// //                       //       }
// //                       //       if ('${widget.info['vatExempt'] ?? ''}' == '0' &&
// //                       //           '${widget.info['vatInclusivePrices'] ?? ''}' ==
// //                       //               '1') {
// //                       //         vatExemptController.text =
// //                       //             'prices are vat inclusive';
// //                       //       }
// //                       //       if ('${widget.info['vatExempt'] ?? ''}' == '1' &&
// //                       //           '${widget.info['printedAsPercentage'] ?? ''}' ==
// //                       //               '1') {
// //                       //         vatExemptController.text =
// //                       //             'exempted from vat ,printed as "vat 0 % = 0"';
// //                       //       }
// //                       //       if ('${widget.info['vatExempt'] ?? ''}' == '1' &&
// //                       //           '${widget.info['printedAsVatExempt'] ?? ''}' ==
// //                       //               '1') {
// //                       //         vatExemptController.text =
// //                       //             'exempted from vat ,printed as "vat exempted"';
// //                       //       }
// //                       //       if ('${widget.info['vatExempt'] ?? ''}' == '1' &&
// //                       //           '${widget.info['notPrinted'] ?? ''}' == '1') {
// //                       //         vatExemptController.text =
// //                       //             'exempted from vat , no printed ';
// //                       //       }
// //                       //
// //                       //       quotationController.city[selectedCustomerIds] =
// //                       //           widget.info['client']['city'] ?? '';
// //                       //       quotationController.country[selectedCustomerIds] =
// //                       //           widget.info['client']['country'] ?? '';
// //                       //       quotationController.email[selectedCustomerIds] =
// //                       //           widget.info['client']['email'] ?? '';
// //                       //       quotationController
// //                       //               .phoneNumber[selectedCustomerIds] =
// //                       //           widget.info['client']['phoneNumber'] ?? '';
// //                       //     });
// //                       //   },
// //                       //   child: Text(
// //                       //     'discard'.tr,
// //                       //     style: TextStyle(
// //                       //       decoration: TextDecoration.underline,
// //                       //       color: Primary.primary,
// //                       //     ),
// //                       //   ),
// //                       // ),
// //                       // gapW24,
// //                       ReusableButtonWithColor(
// //                         btnText: 'save'.tr,
// //                         onTapFunction: () async {
// //                           var oldKeys =
// //                               salesInvoiceController
// //                                   .rowsInListViewInSalesInvoice
// //                                   .keys
// //                                   .toList()
// //                                 ..sort();
// //                           for (int i = 0; i < oldKeys.length; i++) {
// //                             salesInvoiceController.newRowMap[i + 1] =
// //                                 salesInvoiceController
// //                                     .rowsInListViewInSalesInvoice[oldKeys[i]]!;
// //                           }
// //                           if (_formKey.currentState!.validate()) {
// //                             _saveContent();
// //                             // var res = await updateSalesOrdder(
// //                             //   '${widget.info['id']}',
// //                             //   false,
// //                             //   // termsAndConditionsController.text!=oldTermsAndConditionsString,
// //                             //   refController.text,
// //                             //   selectedCustomerIds,
// //                             //   validityController.text,
// //                             //   '', //todo paymentTermsController.text,
// //                             //   salesInvoiceCont.selectedPriceListId,
// //                             //   salesInvoiceCont
// //                             //       .selectedCurrencyId, //selectedCurrency
// //                             //   termsAndConditionsController.text,
// //                             //   selectedSalesPersonId.toString(),
// //                             //   '',
// //                             //   salesInvoiceCont.selectedCashingMethodId,
// //                             //   commissionController.text,
// //                             //   totalCommissionController.text,
// //                             //   salesInvoiceController.totalItems
// //                             //       .toString(), //total before vat
// //                             //   specialDiscPercentController
// //                             //       .text, // inserted by user
// //                             //   salesInvoiceController.specialDisc, // calculated
// //                             //   globalDiscPercentController.text,
// //                             //   salesInvoiceController.globalDisc,
// //                             //   salesInvoiceController.vat11.toString(), //vat
// //                             //   salesInvoiceController.vatInPrimaryCurrency
// //                             //       .toString(),
// //                             //   salesInvoiceController
// //                             //       .totalSalesOrder, // quotationController.totalQuotation

// //                             //   salesInvoiceCont.isVatExemptChecked ? '1' : '0',
// //                             //   salesInvoiceCont.isVatNoPrinted ? '1' : '0',
// //                             //   salesInvoiceCont.isPrintedAsVatExempt ? '1' : '0',
// //                             //   salesInvoiceCont.isPrintedAs0 ? '1' : '0',
// //                             //   salesInvoiceCont.isBeforeVatPrices ? '0' : '1',

// //                             //   salesInvoiceCont.isBeforeVatPrices ? '1' : '0',
// //                             //   codeController.text,
// //                             //   salesInvoiceCont.status, // status,
// //                             //   // quotationController.rowsInListViewInQuotation,
// //                             //   salesInvoiceController.newRowMap,
// //                             // );
// //                             // if (res['success'] == true) {
// //                             //   Get.back();
// //                             //   salesInvoiceController
// //                             //       .getAllSalesInvoiceFromBack();
// //                             //   // homeController.selectedTab.value = 'new_quotation';
// //                             //   homeController.selectedTab.value =
// //                             //       'sales_invoice_summury';
// //                             //   CommonWidgets.snackBar('Success', res['message']);
// //                             // } else {
// //                             //   CommonWidgets.snackBar('error', res['message']);
// //                             // }
// //                           }
// //                         },
// //                         width: 100,
// //                         height: 35,
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //     // : const CircularProgressIndicator();
// //   }

// //   Widget _buildTabChipItem(String name, int index) {
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           selectedTabIndex = index;
// //         });
// //       },
// //       child: ClipPath(
// //         clipper: const ShapeBorderClipper(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.only(
// //               topLeft: Radius.circular(9),
// //               topRight: Radius.circular(9),
// //             ),
// //           ),
// //         ),
// //         child: Container(
// //           width: name.length * 10, // MediaQuery.of(context).size.width * 0.09,
// //           height: MediaQuery.of(context).size.height * 0.07,
// //           decoration: BoxDecoration(
// //             color: selectedTabIndex == index ? Primary.p20 : Colors.white,
// //             border:
// //                 selectedTabIndex == index
// //                     ? Border(top: BorderSide(color: Primary.primary, width: 3))
// //                     : null,
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.grey.withAlpha((0.5 * 255).toInt()),
// //                 spreadRadius: 9,
// //                 blurRadius: 9,
// //                 // offset: Offset(0, 3),
// //               ),
// //             ],
// //           ),
// //           child: Center(
// //             child: Text(
// //               name.tr,
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 color: Primary.primary,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   bool addTitle = false;
// //   bool addItem = false;
// //   String titleValue = '';

// //   addNewTitle() {
// //     setState(() {
// //       salesInvoiceCounter += 1;
// //     });
// //     salesInvoiceController.incrementListViewLengthInSalesInvoice(
// //       salesInvoiceController.increment,
// //     );
// //     salesInvoiceController
// //         .addToRowsInListViewInSalesInvoice(salesInvoiceCounter, {
// //           'line_type_id': '1',
// //           'item_id': '',
// //           'itemName': '',
// //           'item_main_code': '',
// //           'item_discount': '0',
// //           'item_description': '',
// //           'item_quantity': '0',
// //           'item_unit_price': '0',
// //           'item_total': '0',
// //           'title': '',
// //           'note': '',
// //         });
// //     Widget p = ReusableTitleRow(index: salesInvoiceCounter, info: {});
// //     salesInvoiceController.addToOrderLinesInSalesInvoiceList(
// //       '$salesInvoiceCounter',
// //       p,
// //     );
// //   }
// //   // int salesInvoiceCounter = 0;

// //   addNewItem() {
// //     setState(() {
// //       salesInvoiceCounter += 1;
// //     });
// //     salesInvoiceController.incrementListViewLengthInSalesInvoice(
// //       salesInvoiceController.increment,
// //     );
// //     salesInvoiceController
// //         .addToRowsInListViewInSalesInvoice(salesInvoiceCounter, {
// //           'line_type_id': '2',
// //           'item_id': '',
// //           'itemName': '',
// //           'item_main_code': '',
// //           'item_discount': '0',
// //           'item_description': '',
// //           'item_quantity': '1',
// //           'item_unit_price': '0',
// //           'item_total': '0',
// //           'title': '',
// //           'note': '',
// //         });
// //     salesInvoiceController.addToUnitPriceControllers(salesInvoiceCounter);
// //     Widget p = ReusableItemRow(index: salesInvoiceCounter, info: {});
// //     salesInvoiceController.addToOrderLinesInSalesInvoiceList(
// //       '$salesInvoiceCounter',
// //       p,
// //     );
// //   }

// //   addNewCombo() {
// //     setState(() {
// //       salesInvoiceCounter += 1;
// //     });
// //     salesInvoiceController.incrementListViewLengthInSalesInvoice(
// //       salesInvoiceController.increment,
// //     );
// //     salesInvoiceController
// //         .addToRowsInListViewInSalesInvoice(salesInvoiceCounter, {
// //           'line_type_id': '3',
// //           'item_id': '',
// //           'itemName': '',
// //           'item_main_code': '',
// //           'item_discount': '0',
// //           'item_description': '',
// //           'item_quantity': '1',
// //           'item_unit_price': '0',
// //           'item_total': '0',
// //           'title': '',
// //           'note': '',
// //           'combo': '',
// //         });
// //     salesInvoiceController.addToCombosPricesControllers(salesInvoiceCounter);
// //     Widget p = ReusableComboRow(index: salesInvoiceCounter, info: {});
// //     salesInvoiceController.addToOrderLinesInSalesInvoiceList(
// //       '$salesInvoiceCounter',
// //       p,
// //     );
// //   }

// //   addNewImage() {
// //     setState(() {
// //       salesInvoiceCounter += 1;
// //     });
// //     salesInvoiceController.incrementListViewLengthInSalesInvoice(
// //       salesInvoiceController.increment,
// //     );

// //     salesInvoiceController
// //         .addToRowsInListViewInSalesInvoice(salesInvoiceCounter, {
// //           'line_type_id': '4',
// //           'item_id': '',
// //           'itemName': '',
// //           'item_main_code': '',
// //           'item_discount': '0',
// //           'item_description': '',
// //           'item_quantity': '0',
// //           'item_unit_price': '0',
// //           'item_total': '0',
// //           'title': '',
// //           'note': '',
// //           'image': Uint8List(0),
// //         });

// //     Widget p = ReusableImageRow(index: salesInvoiceCounter, info: {});

// //     salesInvoiceController.addToOrderLinesInSalesInvoiceList(
// //       '$salesInvoiceCounter',
// //       p,
// //     );
// //   }

// //   addNewNote() {
// //     setState(() {
// //       salesInvoiceCounter += 1;
// //     });
// //     salesInvoiceController.incrementListViewLengthInSalesInvoice(
// //       salesInvoiceController.increment,
// //     );

// //     salesInvoiceController
// //         .addToRowsInListViewInSalesInvoice(salesInvoiceCounter, {
// //           'line_type_id': '5',
// //           'item_id': '',
// //           'itemName': '',
// //           'item_main_code': '',
// //           'item_discount': '0',
// //           'item_description': '',
// //           'item_quantity': '0',
// //           'item_unit_price': '0',
// //           'item_total': '0',
// //           'title': '',
// //           'note': '',
// //         });

// //     Widget p = ReusableNoteRow(index: salesInvoiceCounter, info: {});

// //     salesInvoiceController.addToOrderLinesInSalesInvoiceList(
// //       '$salesInvoiceCounter',
// //       p,
// //     );

// //     // quotationController.addToOrderLinesList(p);
// //   }

// //   List<Step> getSteps() => [
// //     Step(
// //       title: const Text(''),
// //       content: Container(
// //         //page
// //       ),
// //       isActive: currentStep >= 0,
// //     ),
// //     Step(
// //       title: const Text(''),
// //       content: Container(),
// //       isActive: currentStep >= 1,
// //     ),
// //     Step(
// //       title: const Text(''),
// //       content: Container(),
// //       isActive: currentStep >= 2,
// //     ),
// //   ];
// // }

// // class ReusableItemRow extends StatefulWidget {
// //   const ReusableItemRow({super.key, required this.index, required this.info});
// //   final int index;
// //   final Map info;
// //   @override
// //   State<ReusableItemRow> createState() => _ReusableItemRowState();
// // }

// // class _ReusableItemRowState extends State<ReusableItemRow> {
// //   String discount = '0', result = '0', quantity = '0';
// //   String qty = '0';

// //   TextEditingController itemCodeController = TextEditingController();
// //   TextEditingController qtyController = TextEditingController();
// //   TextEditingController discountController = TextEditingController();
// //   TextEditingController descriptionController = TextEditingController();

// //   final ProductController productController = Get.find();
// //   final SalesInvoiceController salesInvoiceController = Get.find();
// //   final ExchangeRatesController exchangeRatesController = Get.find();

// //   String selectedItemId = '';
// //   String mainDescriptionVar = '';
// //   String mainCode = '';
// //   String itemName = '';
// //   String totalLine = '0';
// //   double taxRate = 1;
// //   double taxValue = 0;

// //   final focus = FocusNode();
// //   final focus1 = FocusNode();
// //   final dropFocus = FocusNode(); //dropdown
// //   final quantityFocus = FocusNode(); //quantity

// //   final _formKey = GlobalKey<FormState>();

// //   setPrice() {
// //     var result = exchangeRatesController.exchangeRatesList.firstWhere(
// //       (item) => item["currency"] == salesInvoiceController.selectedCurrencyName,
// //       orElse: () => null,
// //     );
// //     salesInvoiceController.exchangeRateForSelectedCurrency =
// //         result != null ? '${result["exchange_rate"]}' : '1';
// //     salesInvoiceController.unitPriceControllers[widget.index]!.text =
// //         '${widget.info['item_unit_price'] ?? ''}';
// //     selectedItemId = widget.info['item_id'].toString();
// //     if (salesInvoiceController.itemsPricesCurrencies[selectedItemId] ==
// //         salesInvoiceController.selectedCurrencyName) {
// //       salesInvoiceController.unitPriceControllers[widget.index]!.text =
// //           salesInvoiceController.itemUnitPrice[selectedItemId].toString();
// //     } else if (salesInvoiceController.selectedCurrencyName == 'USD' &&
// //         salesInvoiceController.itemsPricesCurrencies[selectedItemId] !=
// //             salesInvoiceController.selectedCurrencyName) {
// //       var result = exchangeRatesController.exchangeRatesList.firstWhere(
// //         (item) =>
// //             item["currency"] ==
// //             salesInvoiceController.itemsPricesCurrencies[selectedItemId],
// //         orElse: () => null,
// //       );
// //       var divider = '1';
// //       if (result != null) {
// //         divider = result["exchange_rate"].toString();
// //       }
// //       salesInvoiceController.unitPriceControllers[widget.index]!.text =
// //           '${double.parse('${(double.parse(salesInvoiceController.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
// //     } else if (salesInvoiceController.selectedCurrencyName != 'USD' &&
// //         salesInvoiceController.itemsPricesCurrencies[selectedItemId] == 'USD') {
// //       salesInvoiceController.unitPriceControllers[widget.index]!.text =
// //           '${double.parse('${(double.parse(salesInvoiceController.itemUnitPrice[selectedItemId].toString()) * double.parse(salesInvoiceController.exchangeRateForSelectedCurrency))}')}';
// //     } else {
// //       var result = exchangeRatesController.exchangeRatesList.firstWhere(
// //         (item) =>
// //             item["currency"] ==
// //             salesInvoiceController.itemsPricesCurrencies[selectedItemId],
// //         orElse: () => null,
// //       );
// //       var divider = '1';
// //       if (result != null) {
// //         divider = result["exchange_rate"].toString();
// //       }
// //       var usdPrice =
// //           '${double.parse('${(double.parse(salesInvoiceController.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
// //       salesInvoiceController.unitPriceControllers[widget.index]!.text =
// //           '${double.parse('${(double.parse(usdPrice) * double.parse(salesInvoiceController.exchangeRateForSelectedCurrency))}')}';
// //     }
// //     if (salesInvoiceController.isBeforeVatPrices) {
// //       taxRate = 1;
// //       taxValue = 0;
// //     } else {
// //       taxRate =
// //           double.parse(salesInvoiceController.itemsVats[selectedItemId]) /
// //           100.0;
// //       taxValue =
// //           taxRate *
// //           double.parse(
// //             salesInvoiceController.unitPriceControllers[widget.index]!.text,
// //           );
// //     }
// //     salesInvoiceController.unitPriceControllers[widget.index]!.text =
// //         '${double.parse(salesInvoiceController.unitPriceControllers[widget.index]!.text) + taxValue}';
// //     salesInvoiceController
// //         .unitPriceControllers[widget.index]!
// //         .text = double.parse(
// //       salesInvoiceController.unitPriceControllers[widget.index]!.text,
// //     ).toStringAsFixed(2);

// //     // qtyController.text = '1';
// //     salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //             .index]['item_unit_price'] =
// //         salesInvoiceController.unitPriceControllers[widget.index]!.text;
// //   }

// //   @override
// //   void initState() {
// //     if (widget.info.isNotEmpty) {
// //       qtyController.text = '${widget.info['item_quantity'] ?? ''}';
// //       quantity = '${widget.info['item_quantity'] ?? '0.0'}';

// //       discountController.text = widget.info['item_discount'] ?? '';
// //       discount = widget.info['item_discount'] ?? '0.0';

// //       totalLine = widget.info['item_total'] ?? '';
// //       mainDescriptionVar = widget.info['item_description'] ?? '';
// //       mainCode = widget.info['item_main_code'] ?? '';
// //       descriptionController.text = widget.info['item_description'] ?? '';

// //       itemCodeController.text = widget.info['item_main_code'].toString();
// //       selectedItemId = widget.info['item_id'].toString();

// //       setPrice();
// //     } else {
// //       // discountController.text = '0';
// //       // discount = '0';
// //       // qtyController.text = '0';
// //       // quantity = '0';
// //       // quotationController.unitPriceControllers[widget.index]!.text = '0';
// //       itemCodeController.text =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_main_code'];
// //       qtyController.text =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_quantity'];
// //       discountController.text =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_discount'];
// //       descriptionController.text =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_description'];
// //       totalLine =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_total'];
// //       itemCodeController.text =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_main_code'];
// //     }

// //     super.initState();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GetBuilder<SalesInvoiceController>(
// //       builder: (cont) {
// //         return Container(
// //           height: 50,
// //           margin: const EdgeInsets.symmetric(vertical: 5),
// //           child: Form(
// //             key: _formKey,
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 //image
// //                 Container(
// //                   width: MediaQuery.of(context).size.width * 0.02,
// //                   height: 20,
// //                   margin: const EdgeInsets.symmetric(vertical: 15),
// //                   decoration: const BoxDecoration(
// //                     image: DecorationImage(
// //                       image: AssetImage('assets/images/newRow.png'),
// //                       fit: BoxFit.contain,
// //                     ),
// //                   ),
// //                 ),
// //                 ReusableDropDownMenusWithSearch(
// //                   list:
// //                       salesInvoiceController
// //                           .itemsMultiPartList, // Assuming multiList is List<List<String>>
// //                   text: ''.tr,
// //                   hint: 'item_code'.tr,
// //                   controller: itemCodeController,
// //                   onSelected: (String? value) async {
// //                     itemCodeController.text = value!;
// //                     setState(() {
// //                       selectedItemId =
// //                           '${cont.itemsIds[cont.itemsCode.indexOf(value.split(" | ")[0])]}'; //get the id by the first element of the list.
// //                       mainDescriptionVar =
// //                           cont.itemsDescription[selectedItemId];
// //                       mainCode = cont.itemsCodes[selectedItemId];
// //                       itemName = cont.itemsNames[selectedItemId];
// //                       descriptionController.text =
// //                           cont.itemsDescription[selectedItemId]!;
// //                       if (cont.itemsPricesCurrencies[selectedItemId] ==
// //                           cont.selectedCurrencyName) {
// //                         cont.unitPriceControllers[widget.index]!.text =
// //                             cont.itemUnitPrice[selectedItemId].toString();
// //                       } else if (cont.selectedCurrencyName == 'USD' &&
// //                           cont.itemsPricesCurrencies[selectedItemId] !=
// //                               cont.selectedCurrencyName) {
// //                         var result = exchangeRatesController.exchangeRatesList
// //                             .firstWhere(
// //                               (item) =>
// //                                   item["currency"] ==
// //                                   cont.itemsPricesCurrencies[selectedItemId],
// //                               orElse: () => null,
// //                             );
// //                         var divider = '1';
// //                         if (result != null) {
// //                           divider = result["exchange_rate"].toString();
// //                         }
// //                         cont.unitPriceControllers[widget.index]!.text =
// //                             '${double.parse('${(double.parse(cont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
// //                       } else if (cont.selectedCurrencyName != 'USD' &&
// //                           cont.itemsPricesCurrencies[selectedItemId] == 'USD') {
// //                         cont.unitPriceControllers[widget.index]!.text =
// //                             '${double.parse('${(double.parse(cont.itemUnitPrice[selectedItemId].toString()) * double.parse(cont.exchangeRateForSelectedCurrency))}')}';
// //                       } else {
// //                         var result = exchangeRatesController.exchangeRatesList
// //                             .firstWhere(
// //                               (item) =>
// //                                   item["currency"] ==
// //                                   cont.itemsPricesCurrencies[selectedItemId],
// //                               orElse: () => null,
// //                             );
// //                         var divider = '1';
// //                         if (result != null) {
// //                           divider = result["exchange_rate"].toString();
// //                         }
// //                         var usdPrice =
// //                             '${double.parse('${(double.parse(cont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
// //                         cont.unitPriceControllers[widget.index]!.text =
// //                             '${double.parse('${(double.parse(usdPrice) * double.parse(cont.exchangeRateForSelectedCurrency))}')}';
// //                       }
// //                       if (cont.isBeforeVatPrices) {
// //                         taxRate = 1;
// //                         taxValue = 0;
// //                       } else {
// //                         taxRate =
// //                             double.parse(cont.itemsVats[selectedItemId]) /
// //                             100.0;
// //                         taxValue =
// //                             taxRate *
// //                             double.parse(
// //                               cont.unitPriceControllers[widget.index]!.text,
// //                             );
// //                       }
// //                       cont.unitPriceControllers[widget.index]!.text =
// //                           '${double.parse(cont.unitPriceControllers[widget.index]!.text) + taxValue}';
// //                       qtyController.text = '1';
// //                       quantity = '1';
// //                       discountController.text = '0';
// //                       discount = '0';
// //                       totalLine =
// //                           '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
// //                       cont.setEnteredQtyInSalesInvoice(widget.index, quantity);
// //                       cont.setMainTotalInSalesInvoice(widget.index, totalLine);
// //                       cont.getTotalItems();
// //                     });
// //                     cont.setEnteredUnitPriceInSalesInvoice(
// //                       widget.index,
// //                       cont.unitPriceControllers[widget.index]!.text,
// //                     );
// //                     cont.setItemIdInSalesInvoice(widget.index, selectedItemId);
// //                     cont.setItemNameInSalesInvoice(
// //                       widget.index,
// //                       itemName,
// //                       // value.split(" | ")[0],
// //                     ); // set only first element as name
// //                     cont.setMainCodeInSalesInvoice(widget.index, mainCode);
// //                     cont.setTypeInSalesInvoice(widget.index, '2');
// //                     cont.setMainDescriptionInSalesInvoice(
// //                       widget.index,
// //                       mainDescriptionVar,
// //                     );
// //                   },
// //                   validationFunc: (value) {
// //                     // if (value == null || value.isEmpty) {
// //                     //   return 'select_option'.tr;
// //                     // }
// //                     // return null;
// //                   },
// //                   rowWidth: MediaQuery.of(context).size.width * 0.15,
// //                   textFieldWidth: MediaQuery.of(context).size.width * 0.15,
// //                   clickableOptionText: 'create_virtual_item'.tr,
// //                   isThereClickableOption: true,
// //                   onTappedClickableOption: () {
// //                     productController.clearData();
// //                     productController.getFieldsForCreateProductFromBack();
// //                     productController.setIsItUpdateProduct(false);
// //                     showDialog<String>(
// //                       context: context,
// //                       builder:
// //                           (BuildContext context) => const AlertDialog(
// //                             backgroundColor: Colors.white,
// //                             contentPadding: EdgeInsets.all(0),
// //                             titlePadding: EdgeInsets.all(0),
// //                             actionsPadding: EdgeInsets.all(0),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.all(
// //                                 Radius.circular(9),
// //                               ),
// //                             ),
// //                             elevation: 0,
// //                             content: CreateProductDialogContent(),
// //                           ),
// //                     );
// //                   },
// //                   columnWidths: [
// //                     100.0,
// //                     200.0,
// //                     550.0,
// //                     100.0,
// //                   ], // Set column widths
// //                   focusNode: dropFocus,
// //                   nextFocusNode: quantityFocus, // Set column widths
// //                 ),
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.3,
// //                   child: TextFormField(
// //                     style: GoogleFonts.openSans(
// //                       fontSize: 12,
// //                       // fontWeight: FontWeight.w500,
// //                     ),
// //                     onFieldSubmitted: (value) {
// //                       FocusScope.of(context).requestFocus(focus);
// //                     },
// //                     textAlign: TextAlign.center,
// //                     controller: descriptionController,
// //                     cursorColor: Colors.black,
// //                     decoration: InputDecoration(
// //                       hintText: "".tr,
// //                       // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       errorStyle: const TextStyle(fontSize: 10.0),
// //                       focusedErrorBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(Radius.circular(6)),
// //                         borderSide: BorderSide(width: 1, color: Colors.red),
// //                       ),
// //                     ),
// //                     validator: (String? value) {
// //                       return null;
// //                     },
// //                     keyboardType: const TextInputType.numberWithOptions(
// //                       decimal: false,
// //                       signed: true,
// //                     ),
// //                     onChanged: (val) {
// //                       setState(() {
// //                         mainDescriptionVar = val;
// //                       });

// //                       _formKey.currentState!.validate();
// //                       cont.setMainDescriptionInSalesInvoice(
// //                         widget.index,
// //                         mainDescriptionVar,
// //                       );
// //                     },
// //                   ),
// //                 ),

// //                 //quantity
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.06,
// //                   child: TextFormField(
// //                     style: GoogleFonts.openSans(
// //                       fontSize: 12,
// //                       // fontWeight: FontWeight.w500,
// //                     ),
// //                     focusNode: quantityFocus,
// //                     onFieldSubmitted: (value) {
// //                       FocusScope.of(context).requestFocus(focus);
// //                     },
// //                     textAlign: TextAlign.center,
// //                     controller: qtyController,
// //                     cursorColor: Colors.black,
// //                     decoration: InputDecoration(
// //                       hintText: "".tr,
// //                       // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       errorStyle: const TextStyle(fontSize: 10.0),
// //                       focusedErrorBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(Radius.circular(6)),
// //                         borderSide: BorderSide(width: 1, color: Colors.red),
// //                       ),
// //                     ),
// //                     validator: (String? value) {
// //                       if (value!.isEmpty || double.parse(value) <= 0) {
// //                         return 'must be >0';
// //                       }
// //                       return null;
// //                     },
// //                     keyboardType: const TextInputType.numberWithOptions(
// //                       decimal: false,
// //                       signed: true,
// //                     ),
// //                     inputFormatters: <TextInputFormatter>[
// //                       FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
// //                       // WhitelistingTextInputFormatter.digitsOnly
// //                     ],
// //                     onChanged: (val) {
// //                       setState(() {
// //                         quantity = val;
// //                         totalLine =
// //                             '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
// //                       });

// //                       _formKey.currentState!.validate();

// //                       cont.setEnteredQtyInSalesInvoice(widget.index, val);
// //                       cont.setMainTotalInSalesInvoice(widget.index, totalLine);
// //                       cont.getTotalItems();
// //                     },
// //                   ),
// //                 ),
// //                 // unitPrice
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.05,
// //                   child: TextFormField(
// //                     style: GoogleFonts.openSans(
// //                       fontSize: 12,
// //                       // fontWeight: FontWeight.w500,
// //                     ),
// //                     focusNode: focus,
// //                     onFieldSubmitted: (value) {
// //                       FocusScope.of(context).requestFocus(focus1);
// //                     },
// //                     textAlign: TextAlign.center,
// //                     controller: cont.unitPriceControllers[widget.index],
// //                     cursorColor: Colors.black,
// //                     decoration: InputDecoration(
// //                       hintText: "".tr,
// //                       // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       errorStyle: const TextStyle(fontSize: 10.0),
// //                       focusedErrorBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(Radius.circular(6)),
// //                         borderSide: BorderSide(width: 1, color: Colors.red),
// //                       ),
// //                     ),
// //                     validator: (String? value) {
// //                       return null;

// //                       // if (value!.isEmpty) {
// //                       //   return 'unit Price is required';
// //                       // }
// //                       // return null;
// //                     },
// //                     keyboardType: const TextInputType.numberWithOptions(
// //                       decimal: false,
// //                       signed: true,
// //                     ),
// //                     inputFormatters: <TextInputFormatter>[
// //                       FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
// //                       // WhitelistingTextInputFormatter.digitsOnly
// //                     ],
// //                     onChanged: (val) {
// //                       setState(() {
// //                         if (val == '') {
// //                           cont.unitPriceControllers[widget.index]!.text = '0';
// //                         } else {
// //                           // cont.unitPriceControllers[widget.index]!.text = val;
// //                         }
// //                         // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';
// //                         totalLine =
// //                             '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
// //                       });
// //                       _formKey.currentState!.validate();
// //                       // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
// //                       cont.setEnteredUnitPriceInSalesInvoice(widget.index, val);
// //                       cont.setMainTotalInSalesInvoice(widget.index, totalLine);
// //                       cont.getTotalItems();
// //                     },
// //                   ),
// //                 ),

// //                 //discount
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.05,
// //                   child: TextFormField(
// //                     style: GoogleFonts.openSans(
// //                       fontSize: 12,
// //                       // fontWeight: FontWeight.w500,
// //                     ),
// //                     focusNode: focus1,
// //                     controller: discountController,
// //                     cursorColor: Colors.black,
// //                     textAlign: TextAlign.center,
// //                     decoration: InputDecoration(
// //                       hintText: "".tr,
// //                       // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       errorStyle: const TextStyle(fontSize: 10.0),
// //                       focusedErrorBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(Radius.circular(6)),
// //                         borderSide: BorderSide(width: 1, color: Colors.red),
// //                       ),
// //                     ),
// //                     validator: (String? value) {
// //                       return null;

// //                       // if (value!.isEmpty) {
// //                       //   return 'unit Price is required';
// //                       // }
// //                       // return null;
// //                     },
// //                     keyboardType: const TextInputType.numberWithOptions(
// //                       decimal: false,
// //                       signed: true,
// //                     ),
// //                     inputFormatters: <TextInputFormatter>[
// //                       FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
// //                       // WhitelistingTextInputFormatter.digitsOnly
// //                     ],
// //                     onChanged: (val) {
// //                       setState(() {
// //                         if (val == '') {
// //                           discountController.text = '0';
// //                           discount = '0';
// //                         } else {
// //                           discount = val;
// //                         }
// //                         totalLine =
// //                             '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
// //                       });
// //                       _formKey.currentState!.validate();

// //                       // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
// //                       cont.setEnteredDiscInSalesInvoice(widget.index, val);
// //                       cont.setMainTotalInSalesInvoice(widget.index, totalLine);
// //                       cont.getTotalItems();
// //                     },
// //                   ),
// //                 ),

// //                 //total
// //                 ReusableShowInfoCard(
// //                   // text: double.parse(totalLine).toStringAsFixed(2),
// //                   // text: '${double.parse(totalLine).toStringAsFixed(2)}',
// //                   text: formatDoubleWithCommas(
// //                     double.parse(
// //                       cont.rowsInListViewInSalesInvoice[widget
// //                           .index]['item_total'],
// //                     ),
// //                   ),
// //                   width: MediaQuery.of(context).size.width * 0.07,
// //                 ),

// //                 //more
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.02,
// //                   child: ReusableMore(
// //                     itemsList:
// //                         selectedItemId.isEmpty
// //                             ? []
// //                             : [
// //                               PopupMenuItem<String>(
// //                                 value: '1',
// //                                 onTap: () async {
// //                                   showDialog<String>(
// //                                     context: context,
// //                                     builder:
// //                                         (BuildContext context) => AlertDialog(
// //                                           backgroundColor: Colors.white,
// //                                           shape: const RoundedRectangleBorder(
// //                                             borderRadius: BorderRadius.all(
// //                                               Radius.circular(9),
// //                                             ),
// //                                           ),
// //                                           elevation: 0,
// //                                           content: ShowItemQuantitiesDialog(
// //                                             selectedItemId: selectedItemId,
// //                                           ),
// //                                         ),
// //                                   );
// //                                 },
// //                                 child: Text('Show Quantity'),
// //                               ),
// //                             ],
// //                   ),
// //                 ),

// //                 //delete
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.03,
// //                   child: InkWell(
// //                     onTap: () {
// //                       salesInvoiceController
// //                           .decrementListViewLengthInSalesInvoice(
// //                             salesInvoiceController.increment,
// //                           );
// //                       salesInvoiceController
// //                           .removeFromrowsInListViewInSalesInvoice(widget.index);

// //                       salesInvoiceController
// //                           .removeFromOrderLinesInSalesInvoiceList(
// //                             (widget.index).toString(),
// //                           );

// //                       setState(() {
// //                         cont.totalItems = 0.0;
// //                         cont.globalDisc = "0.0";
// //                         cont.globalDiscountPercentageValue = "0.0";
// //                         cont.specialDisc = "0.0";
// //                         cont.specialDiscountPercentageValue = "0.0";
// //                         cont.vat11 = "0.0";
// //                         cont.vatInPrimaryCurrency = "0.0";
// //                         cont.totalSalesOrder = "0.0";

// //                         cont.getTotalItems();
// //                       });
// //                       if (cont.rowsInListViewInSalesInvoice != {}) {
// //                         cont.getTotalItems();
// //                       }
// //                     },
// //                     child: Icon(Icons.delete_outline, color: Primary.primary),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // class ReusableTitleRow extends StatefulWidget {
// //   const ReusableTitleRow({super.key, required this.index, required this.info});

// //   final int index;
// //   final Map info;
// //   @override
// //   State<ReusableTitleRow> createState() => _ReusableTitleRowState();
// // }

// // class _ReusableTitleRowState extends State<ReusableTitleRow> {
// //   TextEditingController titleController = TextEditingController();
// //   final SalesInvoiceController salesInvoiceController = Get.find();
// //   String titleValue = '0';

// //   final _formKey = GlobalKey<FormState>();

// //   @override
// //   void initState() {
// //     // titleController.text = widget.info['title'] ?? '';
// //     titleController.text =
// //         salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //             .index]['title'];
// //     super.initState();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GetBuilder<SalesInvoiceController>(
// //       builder: (cont) {
// //         return Container(
// //           height: 50,
// //           margin: const EdgeInsets.symmetric(vertical: 5),
// //           child: Form(
// //             key: _formKey,
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Container(
// //                   width: MediaQuery.of(context).size.width * 0.02,
// //                   height: 20,
// //                   margin: const EdgeInsets.symmetric(vertical: 15),
// //                   decoration: const BoxDecoration(
// //                     image: DecorationImage(
// //                       image: AssetImage('assets/images/newRow.png'),
// //                       fit: BoxFit.contain,
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.73,
// //                   child: ReusableTextField(
// //                     textEditingController: titleController,
// //                     isPasswordField: false,
// //                     hint: 'title'.tr,
// //                     onChangedFunc: (val) {
// //                       setState(() {
// //                         titleValue = val;
// //                       });
// //                       cont.setTypeInSalesInvoice(widget.index, '1');
// //                       cont.setTitleInSalesInvoice(widget.index, val);
// //                     },
// //                     validationFunc: (val) {},
// //                   ),
// //                 ),
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.02,
// //                   child: ReusableMore(
// //                     itemsList: [
// //                       // PopupMenuItem<String>(
// //                       //   value: '1',
// //                       //   onTap: () async {},
// //                       //   child: Row(
// //                       //     children: [
// //                       //       Text(''),
// //                       //     ],
// //                       //   ),
// //                       // ),
// //                     ],
// //                   ),
// //                 ),
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.03,
// //                   child: InkWell(
// //                     onTap: () {
// //                       salesInvoiceController
// //                           .decrementListViewLengthInSalesInvoice(
// //                             salesInvoiceController.increment,
// //                           );
// //                       salesInvoiceController
// //                           .removeFromrowsInListViewInSalesInvoice(widget.index);
// //                       salesInvoiceController
// //                           .removeFromOrderLinesInSalesInvoiceList(
// //                             (widget.index).toString(),
// //                           );
// //                     },
// //                     child: Icon(Icons.delete_outline, color: Primary.primary),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // class ReusableNoteRow extends StatefulWidget {
// //   const ReusableNoteRow({super.key, required this.index, required this.info});
// //   final int index;
// //   final Map info;
// //   @override
// //   State<ReusableNoteRow> createState() => _ReusableNoteRowState();
// // }

// // class _ReusableNoteRowState extends State<ReusableNoteRow> {
// //   TextEditingController noteController = TextEditingController();
// //   final SalesInvoiceController salesInvoiceController = Get.find();
// //   String noteValue = '';
// //   final _formKey = GlobalKey<FormState>();

// //   @override
// //   void initState() {
// //     noteController.text =
// //         salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //             .index]['note'];
// //     super.initState();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 60,
// //       margin: const EdgeInsets.symmetric(vertical: 5),
// //       child: Form(
// //         key: _formKey,
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           // mainAxisAlignment: MainAxisAlignment.start,
// //           children: [
// //             //image
// //             Container(
// //               width: MediaQuery.of(context).size.width * 0.02,
// //               height: 20,
// //               margin: const EdgeInsets.symmetric(vertical: 15),
// //               decoration: const BoxDecoration(
// //                 image: DecorationImage(
// //                   image: AssetImage('assets/images/newRow.png'),
// //                   fit: BoxFit.contain,
// //                 ),
// //               ),
// //             ),

// //             //note
// //             SizedBox(
// //               width: MediaQuery.of(context).size.width * 0.73,
// //               child: ReusableTextField(
// //                 textEditingController: noteController,
// //                 isPasswordField: false,
// //                 hint: 'note'.tr,
// //                 onChangedFunc: (val) {
// //                   setState(() {
// //                     noteValue = val;
// //                   });
// //                   salesInvoiceController.setTypeInSalesInvoice(
// //                     widget.index,
// //                     '5',
// //                   );
// //                   salesInvoiceController.setNoteInSalesInvoice(
// //                     widget.index,
// //                     val,
// //                   );
// //                 },
// //                 validationFunc: (val) {},
// //               ),
// //             ),

// //             //more
// //             SizedBox(
// //               width: MediaQuery.of(context).size.width * 0.02,
// //               child: ReusableMore(
// //                 itemsList: [
// //                   // PopupMenuItem<String>(
// //                   //   value: '1',
// //                   //   onTap: () async {
// //                   //     showDialog<String>(
// //                   //         context: context,
// //                   //         builder: (BuildContext context) => AlertDialog(
// //                   //           backgroundColor: Colors.white,
// //                   //           shape: const RoundedRectangleBorder(
// //                   //             borderRadius:
// //                   //             BorderRadius.all(Radius.circular(9)),
// //                   //           ),
// //                   //           elevation: 0,
// //                   //           content: Column(
// //                   //             mainAxisAlignment: MainAxisAlignment.center,
// //                   //             children: [
// //                   //
// //                   //             ],
// //                   //           ),
// //                   //         ));
// //                   //   },
// //                   //   child: const Text('Show Quantity'),
// //                   // ),
// //                 ],
// //               ),
// //             ), //delete
// //             SizedBox(
// //               width: MediaQuery.of(context).size.width * 0.03,
// //               child: InkWell(
// //                 onTap: () {
// //                   setState(() {
// //                     salesInvoiceController
// //                         .decrementListViewLengthInSalesInvoice(
// //                           salesInvoiceController.increment,
// //                         );
// //                     salesInvoiceController
// //                         .removeFromrowsInListViewInSalesInvoice(widget.index);
// //                     salesInvoiceController
// //                         .removeFromOrderLinesInSalesInvoiceList(
// //                           widget.index.toString(),
// //                         );
// //                   });
// //                 },
// //                 child: Icon(Icons.delete_outline, color: Primary.primary),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class ReusableImageRow extends StatefulWidget {
// //   const ReusableImageRow({super.key, required this.index, required this.info});
// //   final int index;
// //   final Map info;
// //   @override
// //   State<ReusableImageRow> createState() => _ReusableImageRowState();
// // }

// // class _ReusableImageRowState extends State<ReusableImageRow> {
// //   final SalesInvoiceController salesInvoiceController = Get.find();
// //   late Uint8List imageFile;
// //   bool isLoading = false; // Add loading state
// //   double listViewLength = Sizes.deviceHeight * 0.08;

// //   final _formKey = GlobalKey<FormState>();

// //   @override
// //   void initState() {
// //     imageFile = Uint8List(0);
// //     _loadImage();
// //     super.initState();
// //   }

// //   Future<void> _loadImage() async {
// //     setState(() {
// //       isLoading = true;
// //     });

// //     if (widget.info['image'] != null && widget.info['image'].isNotEmpty) {
// //       try {
// //         final response = await http.get(
// //           Uri.parse('$baseImage${widget.info['image']}'),
// //         );

// //         if (response.statusCode == 200) {
// //           imageFile = response.bodyBytes;
// //         } else {
// //           imageFile = Uint8List(0); // Set to empty if loading fails
// //         }
// //       } catch (e) {
// //         imageFile = Uint8List(0); // Set to empty if loading fails
// //       }
// //     } else {
// //       imageFile = Uint8List(0); // Set to empty if no image URL
// //     }
// //     salesInvoiceController.setImageInSalesInvoice(widget.index, imageFile);
// //     setState(() {
// //       isLoading = false;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GetBuilder<SalesInvoiceController>(
// //       builder: (cont) {
// //         return Container(
// //           height: 100,
// //           margin: const EdgeInsets.symmetric(vertical: 2),
// //           child: Form(
// //             key: _formKey,
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 //image
// //                 Container(
// //                   width: MediaQuery.of(context).size.width * 0.02,
// //                   height: 20,
// //                   margin: const EdgeInsets.symmetric(vertical: 15),
// //                   decoration: const BoxDecoration(
// //                     image: DecorationImage(
// //                       image: AssetImage('assets/images/newRow.png'),
// //                       fit: BoxFit.contain,
// //                     ),
// //                   ),
// //                 ),

// //                 //image
// //                 GetBuilder<SalesInvoiceController>(
// //                   builder: (cont) {
// //                     return InkWell(
// //                       onTap: () async {
// //                         final image = await ImagePickerHelper.pickImage();
// //                         setState(() {
// //                           imageFile = image!;
// //                           cont.changeBoolVar(true);
// //                           cont.increaseImageSpace(30);
// //                         });
// //                         cont.setTypeInSalesInvoice(widget.index, '4');
// //                         cont.setImageInSalesInvoice(widget.index, imageFile);
// //                       },
// //                       child: Container(
// //                         margin: const EdgeInsets.symmetric(
// //                           vertical: 5,
// //                           horizontal: 5,
// //                         ),
// //                         child: DottedBorder(
// //                           dashPattern: const [10, 10],
// //                           color: Others.borderColor,
// //                           radius: const Radius.circular(9),
// //                           child: SizedBox(
// //                             width: MediaQuery.of(context).size.width * 0.72,
// //                             height: cont.imageSpaceHeight,
// //                             child:
// //                                 imageFile.isNotEmpty
// //                                     ? Row(
// //                                       mainAxisAlignment:
// //                                           MainAxisAlignment.start,
// //                                       children: [
// //                                         Image.memory(
// //                                           imageFile,
// //                                           height: cont.imageSpaceHeight,
// //                                         ),
// //                                       ],
// //                                     )
// //                                     : Row(
// //                                       mainAxisAlignment:
// //                                           MainAxisAlignment.start,
// //                                       crossAxisAlignment:
// //                                           CrossAxisAlignment.center,
// //                                       children: [
// //                                         gapW20,
// //                                         Icon(
// //                                           Icons.cloud_upload_outlined,
// //                                           color: Others.iconColor,
// //                                           size: 32,
// //                                         ),
// //                                         gapW20,
// //                                         Text(
// //                                           'drag_drop_image'.tr,
// //                                           style: TextStyle(
// //                                             color: TypographyColor.textTable,
// //                                           ),
// //                                         ),
// //                                         Text(
// //                                           'browse'.tr,
// //                                           style: TextStyle(
// //                                             color: Primary.primary,
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                           ),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),

// //                 //more
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.02,
// //                   child: ReusableMore(
// //                     itemsList: [
// //                       // PopupMenuItem<String>(
// //                       //   value: '1',
// //                       //   onTap: () async {
// //                       //     showDialog<String>(
// //                       //         context: context,
// //                       //         builder: (BuildContext context) => AlertDialog(
// //                       //           backgroundColor: Colors.white,
// //                       //           shape: const RoundedRectangleBorder(
// //                       //             borderRadius:
// //                       //             BorderRadius.all(Radius.circular(9)),
// //                       //           ),
// //                       //           elevation: 0,
// //                       //           content: Column(
// //                       //             mainAxisAlignment: MainAxisAlignment.center,
// //                       //             children: [
// //                       //
// //                       //             ],
// //                       //           ),
// //                       //         ));
// //                       //   },
// //                       //   child: const Text('Show Quantity'),
// //                       // ),
// //                     ],
// //                   ),
// //                 ),
// //                 //delete
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.03,
// //                   child: InkWell(
// //                     onTap: () {
// //                       setState(() {
// //                         salesInvoiceController
// //                             .decrementListViewLengthInSalesInvoice(
// //                               salesInvoiceController.increment + 50,
// //                             );
// //                         salesInvoiceController
// //                             .removeFromrowsInListViewInSalesInvoice(
// //                               widget.index,
// //                             );
// //                         salesInvoiceController
// //                             .removeFromOrderLinesInSalesInvoiceList(
// //                               widget.index.toString(),
// //                             );
// //                       });
// //                     },
// //                     child: Icon(Icons.delete_outline, color: Primary.primary),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // class ReusableComboRow extends StatefulWidget {
// //   const ReusableComboRow({super.key, required this.index, required this.info});
// //   final int index;
// //   final Map info;
// //   @override
// //   State<ReusableComboRow> createState() => _ReusableComboRowState();
// // }

// // class _ReusableComboRowState extends State<ReusableComboRow> {
// //   String discount = '0', result = '0', quantity = '0';
// //   String qty = '0';

// //   TextEditingController comboCodeController = TextEditingController();
// //   TextEditingController qtyController = TextEditingController();
// //   TextEditingController discountController = TextEditingController();
// //   TextEditingController descriptionController = TextEditingController();

// //   final SalesInvoiceController salesInvoiceController = Get.find();
// //   final ExchangeRatesController exchangeRatesController = Get.find();

// //   String selectedComboId = '';
// //   String mainDescriptionVar = '';
// //   String mainCode = '';
// //   String comboName = '';
// //   String totalLine = '0';
// //   double taxRate = 1;
// //   double taxValue = 0;

// //   final focus = FocusNode();
// //   final focus1 = FocusNode();
// //   final dropFocus = FocusNode(); //dropdown
// //   final quantityFocus = FocusNode(); //quantity

// //   final _formKey = GlobalKey<FormState>();

// //   setPrice() {
// //     var result = exchangeRatesController.exchangeRatesList.firstWhere(
// //       (item) => item["currency"] == salesInvoiceController.selectedCurrencyName,
// //       orElse: () => null,
// //     );

// //     salesInvoiceController.exchangeRateForSelectedCurrency =
// //         result != null ? '${result["exchange_rate"]}' : '1';

// //     salesInvoiceController.combosPriceControllers[widget.index]!.text =
// //         '${widget.info['combo_price'] ?? ''}';

// //     selectedComboId = widget.info['combo_id'].toString();
// //     // var ind=quotationController.combosIdsList.indexOf(selectedComboId);

// //     // if (quotationController.combosPricesCurrencies[selectedComboId] ==
// //     //     quotationController.selectedCurrencyName) {
// //     //
// //     //   quotationController.combosPriceControllers[widget.index]!.text =
// //     //       quotationController.combosPricesList[ind].toString();
// //     //
// //     // } else if (quotationController.selectedCurrencyName == 'USD' &&
// //     //     quotationController.combosPricesCurrencies[selectedComboId] !=
// //     //         quotationController.selectedCurrencyName) {
// //     //
// //     //   var result = exchangeRatesController.exchangeRatesList.firstWhere(
// //     //         (item) =>
// //     //     item["currency"] ==
// //     //         quotationController.combosPricesCurrencies[selectedComboId],
// //     //     orElse: () => null,
// //     //   );
// //     //   var divider = '1';
// //     //   if (result != null) {
// //     //     divider = result["exchange_rate"].toString();
// //     //   }
// //     //   quotationController.combosPriceControllers[widget.index]!.text =
// //     //   '${double.parse('${(double.parse(quotationController.combosPricesList[ind].toString()) / double.parse(divider))}')}';
// //     //
// //     // } else if (quotationController.selectedCurrencyName != 'USD' &&
// //     //     quotationController.combosPricesCurrencies[selectedComboId] == 'USD') {
// //     //
// //     //   quotationController.combosPriceControllers[widget.index]!.text =
// //     //   '${double.parse('${(double.parse(quotationController.combosPricesList[ind].toString()) * double.parse(quotationController.exchangeRateForSelectedCurrency))}')}';
// //     //
// //     // } else {
// //     //
// //     //   var result = exchangeRatesController.exchangeRatesList.firstWhere(
// //     //         (item) =>
// //     //     item["currency"] ==
// //     //         quotationController.combosPricesCurrencies[selectedComboId],
// //     //     orElse: () => null,
// //     //   );
// //     //   var divider = '1';
// //     //   if (result != null) {
// //     //     divider = result["exchange_rate"].toString();
// //     //   }
// //     //   var usdPrice =
// //     //       '${double.parse('${(double.parse(quotationController.combosPricesList[ind].toString()) / double.parse(divider))}')}';
// //     //   quotationController.combosPriceControllers[widget.index]!.text =
// //     //   '${double.parse('${(double.parse(usdPrice) * double.parse(quotationController.exchangeRateForSelectedCurrency))}')}';
// //     //
// //     // }

// //     // quotationController.combosPriceControllers[widget.index]!.text =
// //     // '${double.parse(quotationController.combosPriceControllers[widget.index]!.text) + taxValue}';
// //     //
// //     // quotationController.combosPriceControllers[widget.index]!.text = double.parse(
// //     //   quotationController.combosPriceControllers[widget.index]!.text,
// //     // ).toStringAsFixed(2);

// //     // qtyController.text = '1';
// //     salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //             .index]['item_unit_price'] =
// //         salesInvoiceController.combosPriceControllers[widget.index]!.text;
// //     salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //             .index]['item_total'] =
// //         '${widget.info['combo_total']}';
// //     salesInvoiceController.rowsInListViewInSalesInvoice[widget.index]['combo'] =
// //         widget.info['combo_id'].toString();
// //   }

// //   @override
// //   void initState() {
// //     if (widget.info.isNotEmpty) {
// //       qtyController.text = '${widget.info['combo_quantity'] ?? ''}';
// //       quantity = '${widget.info['combo_quantity'] ?? '0.0'}';
// //       salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_quantity'] =
// //           '${widget.info['combo_quantity'] ?? '0.0'}';

// //       discountController.text = widget.info['combo_discount'] ?? '';
// //       discount = widget.info['combo_discount'] ?? '0.0';
// //       salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_discount'] =
// //           widget.info['combo_discount'] ?? '0.0';

// //       totalLine = widget.info['combo_total'] ?? '';
// //       mainDescriptionVar = widget.info['combo_description'] ?? '';

// //       mainCode = widget.info['combo_code'] ?? '';
// //       descriptionController.text = widget.info['combo_description'] ?? '';

// //       salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_description'] =
// //           widget.info['combo_description'] ?? '';

// //       comboCodeController.text = widget.info['combo_code'].toString();
// //       selectedComboId = widget.info['combo_id'].toString();

// //       setPrice();
// //     } else {
// //       // discountController.text = '0';
// //       // discount = '0';
// //       // qtyController.text = '0';
// //       // quantity = '0';
// //       // quotationController.combosPriceControllers[widget.index]!.text = '0';
// //       comboCodeController.text =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_main_code'];
// //       qtyController.text =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_quantity'];
// //       discountController.text =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_discount'];
// //       descriptionController.text =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_description'];
// //       totalLine =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_total'];
// //       comboCodeController.text =
// //           salesInvoiceController.rowsInListViewInSalesInvoice[widget
// //               .index]['item_main_code'];
// //     }

// //     super.initState();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GetBuilder<SalesInvoiceController>(
// //       builder: (cont) {
// //         return Container(
// //           height: 50,
// //           margin: const EdgeInsets.symmetric(vertical: 5),
// //           child: Form(
// //             key: _formKey,
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 //image
// //                 Container(
// //                   width: MediaQuery.of(context).size.width * 0.02,
// //                   height: 20,
// //                   margin: const EdgeInsets.symmetric(vertical: 15),
// //                   decoration: const BoxDecoration(
// //                     image: DecorationImage(
// //                       image: AssetImage('assets/images/newRow.png'),
// //                       fit: BoxFit.contain,
// //                     ),
// //                   ),
// //                 ),
// //                 ReusableDropDownMenusWithSearch(
// //                   list:
// //                       salesInvoiceController
// //                           .combosMultiPartList, // Assuming multiList is List<List<String>>
// //                   text: ''.tr,
// //                   hint: 'combo'.tr,
// //                   controller: comboCodeController,
// //                   onSelected: (String? value) async {
// //                     comboCodeController.text = value!;
// //                     setState(() {
// //                       var ind = cont.combosCodesList.indexOf(
// //                         value.split(" | ")[0],
// //                       );
// //                       selectedComboId = cont.combosIdsList[ind];
// //                       mainDescriptionVar = cont.combosDescriptionList[ind];
// //                       mainCode = cont.combosCodesList[ind];
// //                       comboName = cont.combosNamesList[ind];
// //                       descriptionController.text =
// //                           cont.combosDescriptionList[ind];
// //                       if (cont.combosPricesCurrencies[selectedComboId] ==
// //                           cont.selectedCurrencyName) {
// //                         cont.combosPriceControllers[widget.index]!.text =
// //                             cont.combosPricesList[ind].toString();
// //                       } else if (cont.selectedCurrencyName == 'USD' &&
// //                           cont.combosPricesCurrencies[selectedComboId] !=
// //                               cont.selectedCurrencyName) {
// //                         var result = exchangeRatesController.exchangeRatesList
// //                             .firstWhere(
// //                               (item) =>
// //                                   item["currency"] ==
// //                                   cont.combosPricesCurrencies[selectedComboId],
// //                               orElse: () => null,
// //                             );
// //                         var divider = '1';
// //                         if (result != null) {
// //                           divider = result["exchange_rate"].toString();
// //                         }
// //                         cont.combosPriceControllers[widget.index]!.text =
// //                             '${double.parse('${(double.parse(cont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
// //                       } else if (cont.selectedCurrencyName != 'USD' &&
// //                           cont.combosPricesCurrencies[selectedComboId] ==
// //                               'USD') {
// //                         cont.combosPriceControllers[widget.index]!.text =
// //                             '${double.parse('${(double.parse(cont.combosPricesList[ind].toString()) * double.parse(cont.exchangeRateForSelectedCurrency))}')}';
// //                       } else {
// //                         var result = exchangeRatesController.exchangeRatesList
// //                             .firstWhere(
// //                               (item) =>
// //                                   item["currency"] ==
// //                                   cont.combosPricesCurrencies[selectedComboId],
// //                               orElse: () => null,
// //                             );
// //                         var divider = '1';
// //                         if (result != null) {
// //                           divider = result["exchange_rate"].toString();
// //                         }
// //                         var usdPrice =
// //                             '${double.parse('${(double.parse(cont.combosPricesList[ind].toString()) / double.parse(divider))}')}';
// //                         cont.combosPriceControllers[widget.index]!.text =
// //                             '${double.parse('${(double.parse(usdPrice) * double.parse(cont.exchangeRateForSelectedCurrency))}')}';
// //                       }

// //                       cont.combosPriceControllers[widget.index]!.text =
// //                           '${double.parse(cont.combosPriceControllers[widget.index]!.text) + taxValue}';
// //                       qtyController.text = '1';
// //                       quantity = '1';
// //                       discountController.text = '0';
// //                       discount = '0';
// //                       totalLine =
// //                           '${(double.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
// //                       cont.setEnteredQtyInSalesInvoice(widget.index, quantity);
// //                       cont.setMainTotalInSalesInvoice(widget.index, totalLine);
// //                       cont.getTotalItems();
// //                     });
// //                     cont.setEnteredUnitPriceInSalesInvoice(
// //                       widget.index,
// //                       cont.combosPriceControllers[widget.index]!.text,
// //                     );
// //                     cont.setComboInSalesInvoice(widget.index, selectedComboId);
// //                     cont.setItemNameInSalesInvoice(
// //                       widget.index,
// //                       comboName,
// //                       // value.split(" | ")[0],
// //                     ); // set only first element as name
// //                     cont.setMainCodeInSalesInvoice(widget.index, mainCode);
// //                     cont.setTypeInSalesInvoice(widget.index, '3');
// //                     cont.setMainDescriptionInSalesInvoice(
// //                       widget.index,
// //                       mainDescriptionVar,
// //                     );
// //                   },
// //                   validationFunc: (value) {
// //                     // if ((value == null || value.isEmpty)&& selectedComboId.isEmpty ) {
// //                     //   return 'select_option'.tr;
// //                     // }
// //                     return null;
// //                   },
// //                   rowWidth: MediaQuery.of(context).size.width * 0.15,
// //                   textFieldWidth: MediaQuery.of(context).size.width * 0.15,
// //                   clickableOptionText: 'create_virtual_item'.tr,
// //                   isThereClickableOption: true,
// //                   onTappedClickableOption: () {
// //                     showDialog<String>(
// //                       context: context,
// //                       builder:
// //                           (BuildContext context) => const AlertDialog(
// //                             backgroundColor: Colors.white,
// //                             contentPadding: EdgeInsets.all(0),
// //                             titlePadding: EdgeInsets.all(0),
// //                             actionsPadding: EdgeInsets.all(0),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.all(
// //                                 Radius.circular(9),
// //                               ),
// //                             ),
// //                             elevation: 0,
// //                             content: Combo(),
// //                           ),
// //                     );
// //                   },
// //                   columnWidths: [
// //                     100.0,
// //                     200.0,
// //                     550.0,
// //                     100.0,
// //                   ], // Set column widths
// //                   focusNode: dropFocus,
// //                   nextFocusNode: quantityFocus, // Set column widths
// //                 ),
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.3,
// //                   child: TextFormField(
// //                     style: GoogleFonts.openSans(
// //                       fontSize: 12,
// //                       // fontWeight: FontWeight.w500,
// //                     ),
// //                     onFieldSubmitted: (value) {
// //                       FocusScope.of(context).requestFocus(focus);
// //                     },
// //                     textAlign: TextAlign.center,
// //                     controller: descriptionController,
// //                     cursorColor: Colors.black,
// //                     decoration: InputDecoration(
// //                       hintText: "".tr,
// //                       // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       errorStyle: const TextStyle(fontSize: 10.0),
// //                       focusedErrorBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(Radius.circular(6)),
// //                         borderSide: BorderSide(width: 1, color: Colors.red),
// //                       ),
// //                     ),
// //                     validator: (String? value) {
// //                       return null;
// //                     },
// //                     keyboardType: const TextInputType.numberWithOptions(
// //                       decimal: false,
// //                       signed: true,
// //                     ),
// //                     onChanged: (val) {
// //                       setState(() {
// //                         mainDescriptionVar = val;
// //                       });

// //                       _formKey.currentState!.validate();
// //                       cont.setMainDescriptionInSalesInvoice(
// //                         widget.index,
// //                         mainDescriptionVar,
// //                       );
// //                     },
// //                   ),
// //                 ),

// //                 //quantity
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.06,
// //                   child: TextFormField(
// //                     style: GoogleFonts.openSans(
// //                       fontSize: 12,
// //                       // fontWeight: FontWeight.w500,
// //                     ),
// //                     focusNode: quantityFocus,
// //                     onFieldSubmitted: (value) {
// //                       FocusScope.of(context).requestFocus(focus);
// //                     },
// //                     textAlign: TextAlign.center,
// //                     controller: qtyController,
// //                     cursorColor: Colors.black,
// //                     decoration: InputDecoration(
// //                       hintText: "".tr,
// //                       // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       errorStyle: const TextStyle(fontSize: 10.0),
// //                       focusedErrorBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(Radius.circular(6)),
// //                         borderSide: BorderSide(width: 1, color: Colors.red),
// //                       ),
// //                     ),
// //                     validator: (String? value) {
// //                       if (value!.isEmpty || double.parse(value) <= 0) {
// //                         return 'must be >0';
// //                       }
// //                       return null;
// //                     },
// //                     keyboardType: const TextInputType.numberWithOptions(
// //                       decimal: false,
// //                       signed: true,
// //                     ),
// //                     inputFormatters: <TextInputFormatter>[
// //                       FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
// //                       // WhitelistingTextInputFormatter.digitsOnly
// //                     ],
// //                     onChanged: (val) {
// //                       setState(() {
// //                         quantity = val;
// //                         totalLine =
// //                             '${(double.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
// //                       });

// //                       _formKey.currentState!.validate();

// //                       cont.setEnteredQtyInSalesInvoice(widget.index, val);
// //                       cont.setMainTotalInSalesInvoice(widget.index, totalLine);
// //                       cont.getTotalItems();
// //                     },
// //                   ),
// //                 ),
// //                 // unitPrice
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.05,
// //                   child: TextFormField(
// //                     style: GoogleFonts.openSans(
// //                       fontSize: 12,
// //                       // fontWeight: FontWeight.w500,
// //                     ),
// //                     focusNode: focus,
// //                     onFieldSubmitted: (value) {
// //                       FocusScope.of(context).requestFocus(focus1);
// //                     },
// //                     textAlign: TextAlign.center,
// //                     controller: cont.combosPriceControllers[widget.index],
// //                     cursorColor: Colors.black,
// //                     decoration: InputDecoration(
// //                       hintText: "".tr,
// //                       // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       errorStyle: const TextStyle(fontSize: 10.0),
// //                       focusedErrorBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(Radius.circular(6)),
// //                         borderSide: BorderSide(width: 1, color: Colors.red),
// //                       ),
// //                     ),
// //                     validator: (String? value) {
// //                       return null;

// //                       // if (value!.isEmpty) {
// //                       //   return 'unit Price is required';
// //                       // }
// //                       // return null;
// //                     },
// //                     keyboardType: const TextInputType.numberWithOptions(
// //                       decimal: false,
// //                       signed: true,
// //                     ),
// //                     inputFormatters: <TextInputFormatter>[
// //                       FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
// //                       // WhitelistingTextInputFormatter.digitsOnly
// //                     ],
// //                     onChanged: (val) {
// //                       setState(() {
// //                         if (val == '') {
// //                           cont.combosPriceControllers[widget.index]!.text = '0';
// //                         } else {
// //                           // cont.combosPriceControllers[widget.index]!.text = val;
// //                         }
// //                         // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';
// //                         totalLine =
// //                             '${(double.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
// //                       });
// //                       _formKey.currentState!.validate();
// //                       // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
// //                       cont.setEnteredUnitPriceInSalesInvoice(widget.index, val);
// //                       cont.setMainTotalInSalesInvoice(widget.index, totalLine);
// //                       cont.getTotalItems();
// //                     },
// //                   ),
// //                 ),

// //                 //discount
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.05,
// //                   child: TextFormField(
// //                     style: GoogleFonts.openSans(
// //                       fontSize: 12,
// //                       // fontWeight: FontWeight.w500,
// //                     ),
// //                     focusNode: focus1,
// //                     controller: discountController,
// //                     cursorColor: Colors.black,
// //                     textAlign: TextAlign.center,
// //                     decoration: InputDecoration(
// //                       hintText: "".tr,
// //                       // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderSide: BorderSide(
// //                           color: Colors.black.withAlpha((0.1 * 255).toInt()),
// //                           width: 1,
// //                         ),
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(6),
// //                         ),
// //                       ),
// //                       errorStyle: const TextStyle(fontSize: 10.0),
// //                       focusedErrorBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(Radius.circular(6)),
// //                         borderSide: BorderSide(width: 1, color: Colors.red),
// //                       ),
// //                     ),
// //                     validator: (String? value) {
// //                       return null;

// //                       // if (value!.isEmpty) {
// //                       //   return 'unit Price is required';
// //                       // }
// //                       // return null;
// //                     },
// //                     keyboardType: const TextInputType.numberWithOptions(
// //                       decimal: false,
// //                       signed: true,
// //                     ),
// //                     inputFormatters: <TextInputFormatter>[
// //                       FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
// //                       // WhitelistingTextInputFormatter.digitsOnly
// //                     ],
// //                     onChanged: (val) {
// //                       setState(() {
// //                         if (val == '') {
// //                           discountController.text = '0';
// //                           discount = '0';
// //                         } else {
// //                           discount = val;
// //                         }
// //                         totalLine =
// //                             '${(double.parse(quantity) * double.parse(cont.combosPriceControllers[widget.index]!.text)) * (1 - double.parse(discount) / 100)}';
// //                       });
// //                       _formKey.currentState!.validate();

// //                       // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
// //                       cont.setEnteredDiscInSalesInvoice(widget.index, val);
// //                       cont.setMainTotalInSalesInvoice(widget.index, totalLine);
// //                       cont.getTotalItems();
// //                     },
// //                   ),
// //                 ),

// //                 //total
// //                 ReusableShowInfoCard(
// //                   // text: double.parse(totalLine).toStringAsFixed(2),
// //                   // text: '${double.parse(totalLine).toStringAsFixed(2)}',
// //                   text: formatDoubleWithCommas(
// //                     double.parse(
// //                       cont.rowsInListViewInSalesInvoice[widget
// //                           .index]['item_total'],
// //                     ),
// //                   ),
// //                   width: MediaQuery.of(context).size.width * 0.07,
// //                 ),

// //                 //more
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.02,
// //                   child: ReusableMore(
// //                     itemsList:
// //                         selectedComboId.isEmpty
// //                             ? []
// //                             : [
// //                               // PopupMenuItem<String>(
// //                               //   value: '1',
// //                               //   onTap: () async {
// //                               //     showDialog<String>(
// //                               //       context: context,
// //                               //       builder:
// //                               //           (BuildContext context) => AlertDialog(
// //                               //         backgroundColor: Colors.white,
// //                               //         shape: const RoundedRectangleBorder(
// //                               //           borderRadius: BorderRadius.all(
// //                               //             Radius.circular(9),
// //                               //           ),
// //                               //         ),
// //                               //         elevation: 0,
// //                               //         content: ShowItemQuantitiesDialog(
// //                               //           selectedItemId: selectedComboId,
// //                               //         ),
// //                               //       ),
// //                               //     );
// //                               //   },
// //                               //   child: Text('Show Quantity'),
// //                               // ),
// //                             ],
// //                   ),
// //                 ),

// //                 //delete
// //                 SizedBox(
// //                   width: MediaQuery.of(context).size.width * 0.03,
// //                   child: InkWell(
// //                     onTap: () {
// //                       salesInvoiceController
// //                           .decrementListViewLengthInSalesInvoice(
// //                             salesInvoiceController.increment,
// //                           );
// //                       salesInvoiceController
// //                           .removeFromrowsInListViewInSalesInvoice(widget.index);

// //                       salesInvoiceController
// //                           .removeFromOrderLinesInSalesInvoiceList(
// //                             (widget.index).toString(),
// //                           );

// //                       setState(() {
// //                         cont.totalItems = 0.0;
// //                         cont.globalDisc = "0.0";
// //                         cont.globalDiscountPercentageValue = "0.0";
// //                         cont.specialDisc = "0.0";
// //                         cont.specialDiscountPercentageValue = "0.0";
// //                         cont.vat11 = "0.0";
// //                         cont.vatInPrimaryCurrency = "0.0";
// //                         cont.totalSalesOrder = "0.0";

// //                         cont.getTotalItems();
// //                       });
// //                       if (cont.rowsInListViewInSalesInvoice != {}) {
// //                         cont.getTotalItems();
// //                       }
// //                     },
// //                     child: Icon(Icons.delete_outline, color: Primary.primary),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rooster_app/Backend/SalesOrderBackend/update_sales_order.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/pending_docs_review_controller.dart';
import 'package:rooster_app/Controllers/sales_order_controller.dart';
import 'package:rooster_app/Controllers/task_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/Screens/client_order/print_sales_order.dart';
import 'package:rooster_app/Screens/client_order/sales_order_summury.dart';
import 'package:rooster_app/const/urls.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../../const/functions.dart';

class ToDeleiver extends StatefulWidget {
  const ToDeleiver({super.key});

  @override
  State<ToDeleiver> createState() => _ToDeleiverState();
}

class _ToDeleiverState extends State<ToDeleiver> {
  final TextEditingController filterController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  double listViewLength = 100;
  String selectedNumberOfRows = '10';
  int selectedNumberOfRowsAsInt = 10;
  int start = 1;
  bool isArrowBackClicked = false;
  bool isArrowForwardClicked = false;
  final HomeController homeController = Get.find();
  final SalesOrderController salesOrderController = Get.find();
  final PendingDocsReviewController pendingDocsController = Get.find();
  bool isNumberOrderedUp = true;
  bool isCreationOrderedUp = true;
  bool isCustomerOrderedUp = true;
  bool isSalespersonOrderedUp = true;
  String searchValue = '';
  Timer? searchOnStoppedTyping;
  bool isPendindDocsFetched = false;
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
    await pendingDocsController.getAllPendingDocs();
  }

  TaskController taskController = Get.find();
  int selectedTabIndex = 0;
  List tabsList = ['all_sales_orders'];
  String searchValueInTasks = '';
  Timer? searchOnStoppedTypingInTasks;

  // _onChangeTaskSearchHandler(value) {
  //   const duration = Duration(
  //     milliseconds: 800,
  //   ); // set the duration that you want call search() after that.
  //   if (searchOnStoppedTypingInTasks != null) {
  //     setState(() => searchOnStoppedTypingInTasks!.cancel()); // clear timer
  //   }
  //   setState(
  //     () =>
  //         searchOnStoppedTypingInTasks = Timer(
  //           duration,
  //           () => searchOnTask(value),
  //         ),
  //   );
  // }

  // searchOnTask(value) async {
  //   setState(() {
  //     searchValueInTasks = value;
  //   });
  //   await taskController.getAllTasksFromBack(value);
  // }

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
    // pendingDocsController.setSearchInPendingDocsController(value);
    // await pendingDocsController.getAllPendingDocs();
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
    pendingDocsController.searchInPendingDocsController.text = '';
    listViewLength =
        Sizes.deviceHeight *
        (0.09 * salesOrderController.salesOrdersList.length);
    // salesOrderController.getAllSalesOrderFromBackWithoutEcxcept();
    salesOrderController.getFieldsForCreateSalesOrderFromBack();
    salesOrderController.getAllSalesOrderFromBackWithoutExcept();
    pendingDocsController.getAllPendingDocs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesOrderController>(
      // return GetBuilder<PendingDocsReviewController>(
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
                    PageTitle(text: 'to_deliver'.tr),
                    ReusableButtonWithColor(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: 45,
                      onTapFunction: () {
                        homeController.selectedTab.value = 'new_sales_order';
                      },
                      btnText: 'create_sales_order'.tr,
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
                        // cont.searchInQuotationsController.text=value;
                        // _onChangeTaskSearchHandler(value);
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
                                    ? cont.salesOrderListConfirmed.sort(
                                      (a, b) => a['salesOrderNumber'].compareTo(
                                        b['salesOrderNumber'],
                                      ),
                                    )
                                    : cont.salesOrderListConfirmed.sort(
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
                                    ? cont.salesOrderListConfirmed.sort(
                                      (a, b) => a['createdAtDate'].compareTo(
                                        b['createdAtDate'],
                                      ),
                                    )
                                    : cont.salesOrderListConfirmed.sort(
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
                                    ? cont.salesOrderListConfirmed.sort(
                                      (a, b) => '${a['client']['name']}'
                                          .compareTo('${b['client']['name']}'),
                                    )
                                    : cont.salesOrderListConfirmed.sort(
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
                                    ? cont.salesOrderListConfirmed.sort(
                                      (a, b) => a['salesperson'].compareTo(
                                        b['salesperson'],
                                      ),
                                    )
                                    : cont.salesOrderListConfirmed.sort(
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
                            itemCount: cont.salesOrderListConfirmed.length,
                            itemBuilder:
                                (context, index) => Column(
                                  children: [
                                    SalesOrderAsRowInTable(
                                      info:
                                          salesOrderController
                                              .salesOrderListConfirmed[index],
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
  // String itemCurrencyName = '';
  // String itemCurrencySymbol = '';
  // String itemCurrencyLatestRate = '';
  String brand = '';

  final HomeController homeController = Get.find();
  final SalesOrderController salesOrderController = Get.find();
  final PendingDocsReviewController pendingDocsController = Get.find();
  String diss = '0';
  double totalBeforeVatvValue = 0.0;
  double globalDiscountValue = 0.0;
  double specialDiscountValue = 0.0;
  double specialDisc = 0.0;
  double res = 0.0;

  ExchangeRatesController exchangeRatesController = Get.find();
  String cashMethodId = '';
  String clientId = '';
  String pricelistId = '';
  String salespersonId = ' ';
  String commissionMethodId = '';
  String currencyId = ' ';
  late Uint8List imageFile;
  bool isLoading = false; // Add loading state
  // Future<void> _loadImage() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   if (widget.info['image'] != null && widget.info['image'].isNotEmpty) {
  //     try {
  //       final response = await http.get(
  //         Uri.parse('$baseImage${widget.info['image']}'),
  //       );
  //
  //       if (response.statusCode == 200) {
  //         imageFile = response.bodyBytes;
  //       } else {
  //         imageFile = Uint8List(0); // Set to empty if loading fails
  //       }
  //     } catch (e) {
  //       imageFile = Uint8List(0); // Set to empty if loading fails
  //     }
  //   } else {
  //     imageFile = Uint8List(0); // Set to empty if no image URL
  //   }
  //   salesOrderController.setImageInSalesOrder(widget.index, imageFile);
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  @override
  void initState() {
    imageFile = Uint8List(0);
    if (widget.info['cashingMethod'] != null) {
      cashMethodId = '${widget.info['cashingMethod']['id']}';
    }
    if (widget.info['commissionMethod'] != null) {
      commissionMethodId = '${widget.info['commissionMethod']['id']}';
    }
    if (widget.info['currency'] != null) {
      currencyId = '${widget.info['currency']['id']}';
    }
    if (widget.info['client'] != null) {
      clientId = widget.info['client']['id'].toString();
    }
    if (widget.info['pricelist'] != null) {
      pricelistId = widget.info['pricelist']['id'].toString();
    }
    if (widget.info['salesperson'] != null) {
      salespersonId = widget.info['salesperson']['id'].toString();
    }
    salesOrderController.orderLinesSalesOrderList = {};
    salesOrderController.rowsInListViewInSalesOrder = {};
    salesOrderController.selectedSalesOrderData['orderLines'] =
        widget.info['orderLines'] ?? '';
    for (
      int i = 0;
      i < salesOrderController.selectedSalesOrderData['orderLines'].length;
      i++
    ) {
      salesOrderController.rowsInListViewInSalesOrder[i + 1] =
          salesOrderController.selectedSalesOrderData['orderLines'][i];
    }
    var keys = salesOrderController.rowsInListViewInSalesOrder.keys.toList();
    for (int i = 0; i < widget.info['orderLines'].length; i++) {
      if (widget.info['orderLines'][i]['line_type_id'] == 2) {
        salesOrderController.unitPriceControllers[i + 1] =
            TextEditingController();
        Widget p = ReusableItemRow(
          index: i + 1,
          info: salesOrderController.rowsInListViewInSalesOrder[keys[i]],
        );

        salesOrderController.orderLinesSalesOrderList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 1) {
        Widget p = ReusableTitleRow(
          index: i + 1,
          info: salesOrderController.rowsInListViewInSalesOrder[keys[i]],
        );
        salesOrderController.orderLinesSalesOrderList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 5) {
        Widget p = ReusableNoteRow(
          index: i + 1,
          info: salesOrderController.rowsInListViewInSalesOrder[keys[i]],
        );
        salesOrderController.orderLinesSalesOrderList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 4) {
        Widget p = ReusableImageRow(
          index: i + 1,
          info: salesOrderController.rowsInListViewInSalesOrder[keys[i]],
        );
        salesOrderController.orderLinesSalesOrderList['${i + 1}'] = p;
      } else if (widget.info['orderLines'][i]['line_type_id'] == 3) {
        salesOrderController.combosPriceControllers[i + 1] =
            TextEditingController();
        Widget p = ReusableComboRow(
          index: i + 1,
          info: salesOrderController.rowsInListViewInSalesOrder[keys[i]],
        );
        salesOrderController.orderLinesSalesOrderList['${i + 1}'] = p;
      }
    }
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
                return Container(
                  padding: EdgeInsets.only(left: 10),
                  width:
                      widget.isDesktop
                          ? MediaQuery.of(context).size.width * 0.11
                          : 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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

                                itemDescription = item['item_description'];
                                itemImage =
                                    '${map['images']}' != '[]' &&
                                            map['images'] != null
                                        ? '$baseImage${map['images'][0]['img_url']}'
                                        : '';

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

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  // print('widget.info[ ${widget.info['termsAndConditions']}');
                                  return PrintSalesOrder(
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
                                    ),
                                  ),
                            );
                          },
                          child: Icon(Icons.edit, color: Primary.primary),
                        ),
                      ),

                      Tooltip(
                        message: 'send'.tr,
                        child: InkWell(
                          onTap: () async {
                            Map<int, Map<String, dynamic>> orderLines1 = {};

                            Map<int, dynamic> orderLinesMap = {
                              for (
                                int i = 0;
                                i < widget.info['orderLines'].length;
                                i++
                              )
                                (i + 1): widget.info['orderLines'][i],
                            };

                            for (int i = 0; i < orderLinesMap.length; i++) {
                              Map<String, dynamic> selectedOrderLine =
                                  orderLinesMap[i + 1];
                              orderLines1[i + 1] = {};
                              if (selectedOrderLine['line_type_id'] == 1) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1

                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] = '';
                                orderLines1[i + 1]!['item_main_code'] = '';
                                orderLines1[i + 1]!['item_discount'] = '0';
                                orderLines1[i + 1]!['item_description'] = '';
                                orderLines1[i + 1]!['item_quantity'] = '0';
                                orderLines1[i + 1]!['item_warehouseId'] = '';
                                orderLines1[i + 1]!['combo_warehouseId'] = '';
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
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] =
                                    selectedOrderLine['item_id']?.toString() ??
                                    '';

                                orderLines1[i + 1]!['itemName'] =
                                    selectedOrderLine['item_name'] ?? '';
                                orderLines1[i + 1]!['item_main_code'] =
                                    selectedOrderLine['item_main_code'] ?? '';
                                orderLines1[i + 1]!['item_discount'] =
                                    selectedOrderLine['item_discount']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_description'] =
                                    selectedOrderLine['item_description'] ?? '';
                                orderLines1[i + 1]!['item_quantity'] =
                                    selectedOrderLine['item_quantity']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_warehouseId'] =
                                    selectedOrderLine['item_warehouse_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['combo_warehouseId'] = '';
                                orderLines1[i + 1]!['item_unit_price'] =
                                    selectedOrderLine['item_unit_price']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_total'] =
                                    selectedOrderLine['item_total']
                                        ?.toString() ??
                                    '';
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
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] =
                                    selectedOrderLine['combo_name'] ?? '';
                                orderLines1[i + 1]!['item_main_code'] =
                                    selectedOrderLine['combo_code'] ?? '';
                                orderLines1[i + 1]!['item_discount'] =
                                    selectedOrderLine['combo_discount']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_description'] =
                                    selectedOrderLine['combo_description'] ??
                                    '';
                                orderLines1[i + 1]!['item_quantity'] =
                                    selectedOrderLine['combo_quantity']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_warehouseId'] = '';
                                orderLines1[i + 1]!['combo_warehouseId'] =
                                    selectedOrderLine['combo_warehouse_id']
                                        ?.toString() ??
                                    '10';
                                orderLines1[i + 1]!['item_unit_price'] =
                                    selectedOrderLine['combo_unit_price']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_total'] =
                                    selectedOrderLine['combo_total']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['title'] =
                                    selectedOrderLine['title'] ?? '';
                                orderLines1[i + 1]!['note'] =
                                    selectedOrderLine['note'] ?? '';
                                orderLines1[i + 1]!['combo'] =
                                    selectedOrderLine['combo_id']?.toString() ??
                                    '';
                                // Add more fields as needed
                              }
                              if (selectedOrderLine['line_type_id'] == 4) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1

                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] = '';
                                orderLines1[i + 1]!['item_main_code'] = '';
                                orderLines1[i + 1]!['item_discount'] = '0';
                                orderLines1[i + 1]!['item_description'] = '';
                                orderLines1[i + 1]!['item_quantity'] = '0';
                                orderLines1[i + 1]!['item_warehouseId'] = '';
                                orderLines1[i + 1]!['combo_warehouseId'] = '';
                                orderLines1[i + 1]!['item_unit_price'] = '0';
                                orderLines1[i + 1]!['item_total'] = '0';
                                orderLines1[i + 1]!['title'] = '';
                                orderLines1[i + 1]!['note'] = '';
                                if (selectedOrderLine['image'] != null &&
                                    selectedOrderLine['image'].isNotEmpty) {
                                  try {
                                    final response = await http.get(
                                      Uri.parse(
                                        '$baseImage${selectedOrderLine['image']}',
                                      ),
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
                                  imageFile = Uint8List(
                                    0,
                                  ); // Set to empty if no image URL
                                }
                                orderLines1[i + 1]!['image'] = imageFile;
                                // Add more fields as needed
                              }
                              if (selectedOrderLine['line_type_id'] == 5) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1

                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] = '';
                                orderLines1[i + 1]!['item_main_code'] = '';
                                orderLines1[i + 1]!['item_discount'] = '0';
                                orderLines1[i + 1]!['item_description'] = '';
                                orderLines1[i + 1]!['item_quantity'] = '0';
                                orderLines1[i + 1]!['item_warehouseId'] = '';
                                orderLines1[i + 1]!['combo_warehouseId'] = '';
                                orderLines1[i + 1]!['item_unit_price'] = '0';
                                orderLines1[i + 1]!['item_total'] = '0';
                                orderLines1[i + 1]!['title'] = '';
                                orderLines1[i + 1]!['note'] =
                                    selectedOrderLine['note'] ?? '';
                                orderLines1[i + 1]!['combo'] = '';
                                // Add more fields as needed
                              }
                            }

                            var res = await updateSalesOrdder(
                              '${widget.info['id']}',
                              false,
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

                              'sent', // status,
                              orderLines1,
                            );
                            if (res['success'] == true) {
                              // pendingDocsController.getAllPendingDocs();
                              salesOrderController
                                  .getAllSalesOrderFromBackWithoutExcept();

                              CommonWidgets.snackBar('Success', res['message']);
                            } else {
                              CommonWidgets.snackBar('error', res['message']);
                            }
                          },
                          child: Icon(
                            Icons.send,
                            color: Primary.primary,
                            size: 17.00,
                          ),
                        ),
                      ),

                      // Tooltip(
                      //   message: 'cancel'.tr,
                      //   child: InkWell(
                      //     onTap: () async {
                      //       print("NEWMAP-------------------");
                      //       Map<int, dynamic> orderLinesMap = {
                      //         for (
                      //           int i = 0;
                      //           i < widget.info['orderLines'].length;
                      //           i++
                      //         )
                      //           (i + 1): widget.info['orderLines'][i],
                      //       };
                      //       print(orderLinesMap);
                      //       var res = await updateSalesOrdder(
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
                      //         'cancelled', // status,
                      //         // quotationController.rowsInListViewInSalesOrder,
                      //         // salesOrderController.newRowMap,
                      //         orderLinesMap,
                      //       );
                      //       if (res['success'] == true) {
                      //         // pendingDocsController.getAllPendingDocs();
                      //         salesOrderController
                      //             .getAllSalesOrderFromBackWithoutEcxcept();
                      //         homeController.selectedTab.value =
                      //             "sales_order_summary";
                      //         CommonWidgets.snackBar('Success', res['message']);
                      //       } else {
                      //         print(res['message']);
                      //         CommonWidgets.snackBar('error', res['message']);
                      //       }
                      //     },
                      //     child: Icon(
                      //       Icons.cancel_outlined,
                      //       color: Primary.primary,
                      //     ),
                      //   ),
                      // ),

                      // // ReusableMore(
                      //   itemsList: [
                      //     PopupMenuItem<String>(
                      //       value: '1',
                      //       onTap: () async {
                      //         itemsInfoPrint = [];
                      //         salesOrderItemInfo = {};
                      //         totalAllItems = 0;
                      //         cont.totalAllItems = 0;
                      //         totalAllItems = 0;
                      //         cont.totalAllItems = 0;
                      //         totalPriceAfterDiscount = 0;
                      //         additionalSpecialDiscount = 0;
                      //         totalPriceAfterSpecialDiscount = 0;
                      //         totalPriceAfterSpecialDiscountBysalesOrderCurrency =
                      //             0;
                      //         vatBySalesOrderCurrency = 0;
                      //         vatBySalesOrderCurrency = 0;
                      //         finalPriceBySalesOrderCurrency = 0;
                      //
                      //         for (var item in widget.info['orderLines']) {
                      //           if ('${item['line_type_id']}' == '2') {
                      //             qty = item['item_quantity'];
                      //             var map =
                      //                 cont.itemsMap[item['item_id'].toString()];
                      //             itemName = map['item_name'];
                      //             itemPrice = double.parse(
                      //               '${item['item_unit_price'] ?? '0'}',
                      //             );
                      //             //     map['unitPrice'] ?? 0.0;
                      //             // formatDoubleWithCommas(map['unitPrice']);
                      //
                      //             itemDescription = item['item_description'];
                      //
                      //             itemImage =
                      //                 '${map['images']}' != '[]'
                      //                     ? '$baseImage${map['images'][0]['img_url']}'
                      //                     : '';
                      //             // itemCurrencyName = map['currency']['name'];
                      //             // itemCurrencySymbol = map['currency']['symbol'];
                      //             // itemCurrencyLatestRate =
                      //             //     map['currency']['latest_rate'];
                      //             var firstBrandObject = map['itemGroups']
                      //                 .firstWhere(
                      //                   (obj) =>
                      //                       obj["root_name"]?.toLowerCase() ==
                      //                       "brand".toLowerCase(),
                      //                   orElse: () => null,
                      //                 );
                      //             brand =
                      //                 firstBrandObject == null
                      //                     ? ''
                      //                     : firstBrandObject['name'] ?? '';
                      //             itemTotal = double.parse('${item['item_total']}');
                      //             // itemTotal = double.parse(qty) * itemPrice;
                      //             totalAllItems += itemTotal;
                      //             salesOrderItemInfo = {
                      //               'line_type_id': '2',
                      //               'item_name': itemName,
                      //               'item_description': itemDescription,
                      //               'item_quantity': qty,
                      //               'item_discount': item['item_discount'] ?? '0',
                      //               'item_unit_price': formatDoubleWithCommas(
                      //                 itemPrice,
                      //               ),
                      //               'item_total': formatDoubleWithCommas(itemTotal),
                      //               'item_image': itemImage,
                      //               'item_brand': brand,
                      //               'title': '',
                      //               'isImageList': false,
                      //               'note': '',
                      //               'image': '',
                      //             };
                      //             itemsInfoPrint.add(salesOrderItemInfo);
                      //           } else if ('${item['line_type_id']}' == '3') {
                      //             var qty = item['item_quantity'];
                      //             // var map =
                      //             // cont
                      //             //     .combosMap[item['combo_id']
                      //             //     .toString()];
                      //             var ind = cont.combosIdsList.indexOf(
                      //               item['combo_id'].toString(),
                      //             );
                      //             var itemName = cont.combosNamesList[ind];
                      //             var itemPrice = double.parse(
                      //               '${item['combo_price'] ?? 0.0}',
                      //             );
                      //             var itemDescription = item['combo_description'];
                      //
                      //             var itemTotal = double.parse(
                      //               '${item['combo_total']}',
                      //             );
                      //             // double.parse(qty) * itemPrice;
                      //             var salesOrderItemInfo = {
                      //               'line_type_id': '3',
                      //               'item_name': itemName,
                      //               'item_description': itemDescription,
                      //               'item_quantity': qty,
                      //               'item_unit_price': formatDoubleWithCommas(
                      //                 itemPrice,
                      //               ),
                      //               'item_discount': item['combo_discount'] ?? '0',
                      //               'item_total': formatDoubleWithCommas(itemTotal),
                      //               'note': '',
                      //               'item_image': '',
                      //               'item_brand': '',
                      //               'isImageList': false,
                      //               'title': '',
                      //               'image': '',
                      //             };
                      //             itemsInfoPrint.add(salesOrderItemInfo);
                      //           } else if ('${item['line_type_id']}' == '1') {
                      //             var salesOrderItemInfo = {
                      //               'line_type_id': '1',
                      //               'item_name': '',
                      //               'item_description': '',
                      //               'item_quantity': '',
                      //               'item_unit_price': '',
                      //               'item_discount': '0',
                      //               'item_total': '',
                      //               'item_image': '',
                      //               'item_brand': '',
                      //               'note': '',
                      //               'isImageList': false,
                      //               'title': item['title'],
                      //               'image': '',
                      //             };
                      //             itemsInfoPrint.add(salesOrderItemInfo);
                      //           } else if ('${item['line_type_id']}' == '5') {
                      //             var salesOrderItemInfo = {
                      //               'line_type_id': '5',
                      //               'item_name': '',
                      //               'item_description': '',
                      //               'item_quantity': '',
                      //               'item_unit_price': '',
                      //               'item_discount': '0',
                      //               'item_total': '',
                      //               'item_image': '',
                      //               'item_brand': '',
                      //               'title': '',
                      //               'note': item['note'],
                      //               'isImageList': false,
                      //               'image': '',
                      //             };
                      //             itemsInfoPrint.add(salesOrderItemInfo);
                      //           } else if ('${item['line_type_id']}' == '4') {
                      //             var salesOrderItemInfo = {
                      //               'line_type_id': '4',
                      //               'item_name': '',
                      //               'item_description': '',
                      //               'item_quantity': '',
                      //               'item_unit_price': '',
                      //               'item_discount': '0',
                      //               'item_total': '',
                      //               'item_image': '',
                      //               'item_brand': '',
                      //               'title': '',
                      //               'note': '',
                      //               'image': '$baseImage${item['image']}',
                      //               'isImageList': false,
                      //             };
                      //             itemsInfoPrint.add(salesOrderItemInfo);
                      //           }
                      //         }
                      //         // var primaryCurrency = await getCompanyPrimaryCurrencyFromPref();
                      //         // var result = exchangeRatesController
                      //         //     .exchangeRatesList
                      //         //     .firstWhere(
                      //         //       (item) =>
                      //         //   item["currency"] == primaryCurrency,
                      //         //   orElse: () => null,
                      //         // );
                      //         // var primaryLatestRate=
                      //         // result != null
                      //         //     ? '${result["exchange_rate"]}'
                      //         //     : '1';
                      //         // discountOnAllItem =
                      //         //     totalAllItems *
                      //         //     double.parse(
                      //         //       widget.info['globalDiscount'] ?? '0',
                      //         //     ) /
                      //         //     100;
                      //
                      //         totalPriceAfterDiscount =
                      //             totalAllItems - discountOnAllItem;
                      //         additionalSpecialDiscount =
                      //             totalPriceAfterDiscount *
                      //             double.parse(
                      //               widget.info['specialDiscount'] ?? '0',
                      //             ) /
                      //             100;
                      //         totalPriceAfterSpecialDiscount =
                      //             totalPriceAfterDiscount -
                      //             additionalSpecialDiscount;
                      //         totalPriceAfterSpecialDiscountBysalesOrderCurrency =
                      //             totalPriceAfterSpecialDiscount;
                      //         vatBySalesOrderCurrency =
                      //             '${widget.info['vatExempt']}' == '1'
                      //                 ? 0
                      //                 : (totalPriceAfterSpecialDiscountBysalesOrderCurrency *
                      //                         double.parse(
                      //                           await getCompanyVatFromPref(),
                      //                         )) /
                      //                     100;
                      //         finalPriceBySalesOrderCurrency =
                      //             totalPriceAfterSpecialDiscountBysalesOrderCurrency;
                      //         vatBySalesOrderCurrency;
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (BuildContext context) {
                      //               // print('widget.info[ ${widget.info['termsAndConditions']}');
                      //               return PrintSalesOrder(
                      //                 isPrintedAs0:
                      //                     '${widget.info['printedAsPercentage']}' ==
                      //                             '1'
                      //                         ? true
                      //                         : false,
                      //                 isVatNoPrinted:
                      //                     '${widget.info['notPrinted']}' == '1'
                      //                         ? true
                      //                         : false,
                      //                 isPrintedAsVatExempt:
                      //                     '${widget.info['printedAsVatExempt']}' ==
                      //                             '1'
                      //                         ? true
                      //                         : false,
                      //                 isInSalesOrder: true,
                      //                 salesOrderNumber:
                      //                     widget.info['salesOrderNumber'] ?? '',
                      //                 creationDate: widget.info['validity'] ?? '',
                      //                 ref: widget.info['reference'] ?? '',
                      //                 receivedUser: '',
                      //                 senderUser: homeController.userName,
                      //                 status: widget.info['status'] ?? '',
                      //                 totalBeforeVat:
                      //                     widget.info['totalBeforeVat'] ?? '',
                      //                 discountOnAllItem:
                      //                     discountOnAllItem.toString(),
                      //                 totalAllItems:
                      //                 // totalAllItems.toString()  ,
                      //                 formatDoubleWithCommas(
                      //                   totalPriceAfterDiscount,
                      //                 ),
                      //
                      //                 globalDiscount:
                      //                     widget.info['globalDiscount'] ?? '0',
                      //
                      //                 totalPriceAfterDiscount:
                      //                     formatDoubleWithCommas(
                      //                       totalPriceAfterDiscount,
                      //                     ),
                      //                 additionalSpecialDiscount:
                      //                     additionalSpecialDiscount.toStringAsFixed(
                      //                       2,
                      //                     ),
                      //                 totalPriceAfterSpecialDiscount:
                      //                     formatDoubleWithCommas(
                      //                       totalPriceAfterSpecialDiscount,
                      //                     ),
                      //                 // itemCurrencyName: itemCurrencyName,
                      //                 // itemCurrencySymbol: itemCurrencySymbol,
                      //                 // itemCurrencyLatestRate:
                      //                 //     itemCurrencyLatestRate,
                      //                 totalPriceAfterSpecialDiscountBysalesOrderCurrency:
                      //                     formatDoubleWithCommas(
                      //                       totalPriceAfterSpecialDiscountBysalesOrderCurrency,
                      //                     ),
                      //
                      //                 vatBySalesOrderCurrency:
                      //                     formatDoubleWithCommas(
                      //                       vatBySalesOrderCurrency,
                      //                     ),
                      //                 finalPriceBySalesOrderCurrency:
                      //                     formatDoubleWithCommas(
                      //                       finalPriceBySalesOrderCurrency,
                      //                     ),
                      //                 specialDisc: specialDisc.toString(),
                      //                 specialDiscount:
                      //                     widget.info['specialDiscount'] ?? '0',
                      //                 specialDiscountAmount:
                      //                     widget.info['specialDiscountAmount'] ??
                      //                     '',
                      //                 salesPerson:
                      //                     widget.info['salesperson'] != null
                      //                         ? widget.info['salesperson']['name']
                      //                         : '---',
                      //                 salesOrderCurrency:
                      //                     widget.info['currency']['name'] ?? '',
                      //                 salesOrderCurrencySymbol:
                      //                     widget.info['currency']['symbol'] ?? '',
                      //                 salesOrderCurrencyLatestRate:
                      //                     widget.info['currency']['latest_rate'] ??
                      //                     '',
                      //                 clientPhoneNumber:
                      //                     widget.info['client'] != null
                      //                         ? widget.info['client']['phoneNumber'] ??
                      //                             '---'
                      //                         : "---",
                      //                 clientName:
                      //                     widget.info['client']['name'] ?? '',
                      //                 termsAndConditions:
                      //                     widget.info['termsAndConditions'] ?? '',
                      //                 itemsInfoPrint: itemsInfoPrint,
                      //               );
                      //             },
                      //           ),
                      //         );
                      //       },
                      //       child: Text('preview'.tr),
                      //     ),
                      //     PopupMenuItem<String>(
                      //       value: '2',
                      //       onTap: () async {
                      //         var res = await updateSalesOrdder(
                      //           '${widget.info['id']}',
                      //           false,
                      //           '${widget.info['reference'] ?? ''}',
                      //           clientId,
                      //
                      //           '${widget.info['validity'] ?? ''}',
                      //           '${widget.info['inputDate'] ?? ''}',
                      //
                      //           '', //todo paymentTermsController.text,
                      //           pricelistId,
                      //           currencyId,
                      //           '${widget.info['termsAndConditions']}',
                      //           salespersonId,
                      //           commissionMethodId,
                      //           cashMethodId,
                      //           '${widget.info['commissionRate'] ?? ''}',
                      //           '${widget.info['commissionTotal'] ?? ''}',
                      //           '${widget.info['totalBeforeVat'] ?? '0.0'}', //total before vat
                      //           '${widget.info['specialDiscountAmount'] ?? '0'}', // inserted by user
                      //           '${widget.info['specialDiscount'] ?? '0'}', // calculated
                      //           '${widget.info['globalDiscountAmount'] ?? ''}',
                      //           '${widget.info['globalDiscount'] ?? ''}',
                      //           '${widget.info['vat'] ?? ''}', //vat
                      //           '${widget.info['vatLebanese'] ?? ''}',
                      //           '${widget.info['total'] ?? ''}',
                      //           '${widget.info['vatExempt'] ?? ''}',
                      //           '${widget.info['notPrinted'] ?? ''}',
                      //           '${widget.info['printedAsVatExempt'] ?? ''}',
                      //           '${widget.info['printedAsPercentage'] ?? ''}',
                      //           '${widget.info['vatInclusivePrices'] ?? ''}',
                      //           '${widget.info['beforeVatPrices'] ?? ''}',
                      //
                      //           '${widget.info['code'] ?? ''}',
                      //
                      //           'confirmed', // status,
                      //           // quotationController.rowsInListViewInSalesOrder,
                      //           cont.newRowMap,
                      //         );
                      //         if (res['success'] == true) {
                      //           pendingDocsController.getAllPendingDocs();
                      //
                      //           CommonWidgets.snackBar('Success', res['message']);
                      //         } else {
                      //           print(res['message']);
                      //           CommonWidgets.snackBar('error', res['message']);
                      //         }
                      //       },
                      //       child: Text('Confirm'.tr),
                      //     ),
                      //     PopupMenuItem<String>(
                      //       value: '3',
                      //       onTap: () async {
                      //         var res = await updateSalesOrdder(
                      //           '${widget.info['id']}',
                      //           false,
                      //           '${widget.info['reference'] ?? ''}',
                      //           clientId,
                      //
                      //           '${widget.info['validity'] ?? ''}',
                      //           '${widget.info['inputDate'] ?? ''}',
                      //
                      //           '', //todo paymentTermsController.text,
                      //           pricelistId,
                      //           currencyId,
                      //           '${widget.info['termsAndConditions']}',
                      //           salespersonId,
                      //           commissionMethodId,
                      //           cashMethodId,
                      //           '${widget.info['commissionRate'] ?? ''}',
                      //           '${widget.info['commissionTotal'] ?? ''}',
                      //           '${widget.info['totalBeforeVat'] ?? '0.0'}', //total before vat
                      //           '${widget.info['specialDiscountAmount'] ?? '0'}', // inserted by user
                      //           '${widget.info['specialDiscount'] ?? '0'}', // calculated
                      //           '${widget.info['globalDiscountAmount'] ?? ''}',
                      //           '${widget.info['globalDiscount'] ?? ''}',
                      //           '${widget.info['vat'] ?? ''}', //vat
                      //           '${widget.info['vatLebanese'] ?? ''}',
                      //           '${widget.info['total'] ?? ''}',
                      //           '${widget.info['vatExempt'] ?? ''}',
                      //           '${widget.info['notPrinted'] ?? ''}',
                      //           '${widget.info['printedAsVatExempt'] ?? ''}',
                      //           '${widget.info['printedAsPercentage'] ?? ''}',
                      //           '${widget.info['vatInclusivePrices'] ?? ''}',
                      //           '${widget.info['beforeVatPrices'] ?? ''}',
                      //
                      //           '${widget.info['code'] ?? ''}',
                      //           'cancelled', // status,
                      //           // quotationController.rowsInListViewInSalesOrder,
                      //           cont.newRowMap,
                      //         );
                      //         if (res['success'] == true) {
                      //           pendingDocsController.getAllPendingDocs();
                      //           CommonWidgets.snackBar('Success', res['message']);
                      //         } else {
                      //           print(res['message']);
                      //           CommonWidgets.snackBar('error', res['message']);
                      //         }
                      //       },
                      //       child: Text('Cancel'.tr),
                      //     ),
                      //     PopupMenuItem<String>(
                      //       value: '4',
                      //       onTap: () async {
                      //         showDialog<String>(
                      //           context: context,
                      //           builder:
                      //               (BuildContext context) => AlertDialog(
                      //                 backgroundColor: Colors.white,
                      //                 shape: const RoundedRectangleBorder(
                      //                   borderRadius: BorderRadius.all(
                      //                     Radius.circular(9),
                      //                   ),
                      //                 ),
                      //                 elevation: 0,
                      //                 content: UpdateSalesOrderDialog(
                      //                   index: widget.index,
                      //                   info: widget.info,
                      //                 ),
                      //               ),
                      //         );
                      //       },
                      //       child: Text('Update'.tr),
                      //     ),
                      //   ],
                      // ),
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
