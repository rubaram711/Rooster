// import 'dart:typed_data';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rooster_app/utils/image_picker_helper.dart';
// import '../../../../Controllers/HomeController/home_controller.dart';
// import '../../../../Widgets/page_title.dart';
// import '../../../../Widgets/reusable_btn.dart';
// import '../../../../Widgets/reusable_text_field.dart';
// import '../../../../const/Sizes.dart';
// import '../../../../const/colors.dart';
// import '../../../Backend/Transfers/Replenish/add_replenish.dart';
//
// import '../../../Backend/Transfers/Replenish/get_data_create_replenishments.dart';
// import '../../../Backend/ConfigurationsBackend/Warehouses/get_warehouse_qty.dart';
// import '../../../Controllers/ExchangeRatesController/exchange_rates_controller.dart';
// import '../../../Controllers/TransfersController/transfer_controller.dart';
// import '../../../Controllers/WarehousesController/warehouse_controller.dart';
// import '../../../Widgets/TransferWidgets/reusable_show_info_card.dart';
// import '../../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
// import '../../../Widgets/TransferWidgets/under_item_btn.dart';
// import '../../../Widgets/custom_snak_bar.dart';
// import '../../../Widgets/dialog_drop_menu.dart';
// import '../../../Widgets/loading.dart';
// import '../../../Widgets/reusable_add_card.dart';
// import '../../../Widgets/table_title.dart';
// // ignore: depend_on_referenced_packages
// import 'package:intl/intl.dart';
//
// import '../../../const/functions.dart';
// import 'print_replenish.dart';
//
// class Replenish extends StatefulWidget {
//   const Replenish({super.key});
//
//   @override
//   State<Replenish> createState() => _ReplenishState();
// }
//
// class _ReplenishState extends State<Replenish> {
//   TextEditingController refController = TextEditingController();
//   TextEditingController dateController = TextEditingController();
//   TextEditingController currencyController = TextEditingController();
//
//   late Uint8List imageFile;
//   int currentStep = 0;
//   int selectedTabIndex = 0;
//
//   List tabsList = [
//     '',
//     'other_information',
//   ];
//   String? selectedDestWrhs = '';
//   String? selectedItem = '';
//   double listViewLength = Sizes.deviceHeight * 0.08;
//   double increment = Sizes.deviceHeight * 0.08;
//   final TransferController transferController = Get.find();
//   final HomeController homeController = Get.find();
//   final ExchangeRatesController exchangeRatesController = Get.find();
//   String selectedCurrencyId = '';
//   final WarehouseController warehouseController = Get.find();
//   int progressVar = 0;
//   Map data = {};
//   bool isInfoFetched = false;
//   String replenishmentNumber = '';
//   getFieldsForCreateTransferFromBack() async {
//     setState(() {
//       currentStep = 0;
//       selectedTabIndex = 0;
//       selectedItem = '';
//       selectedDestWrhs = '';
//       progressVar = 0;
//       replenishmentNumber = '';
//       data = {};
//       transferController.transferToInReplenishController.text = '';
//       transferController.setTransferToIdInReplenish('');
//       currencyController.text = 'USD';
//     });
//     var p = await getReplenishmentsDataForCreate();
//     if ('$p' != '[]') {
//       setState(() {
//         replenishmentNumber = '${p['replenishmentNumber']}';
//         isInfoFetched = true;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     setState(() {
//       listViewLength = Sizes.deviceHeight * 0.08;
//     });
//     dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     getFieldsForCreateTransferFromBack();
//     exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();
//     // warehouseController.resetValues();
//     warehouseController.getWarehousesFromBack();
//     transferController.getAllProductsFromBack('');
//     transferController.resetReplenish();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isInfoFetched
//         ? GetBuilder<TransferController>(builder: (cont) {
//       return Container(
//         padding: EdgeInsets.symmetric(
//             horizontal: MediaQuery.of(context).size.width * 0.02),
//         height: MediaQuery.of(context).size.height * 0.85,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   PageTitle(text: 'replenish'.tr),
//                 ],
//               ),
//               gapH16,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       UnderTitleBtn(
//                         text: 'preview'.tr,
//                         onTap: () {
//                           bool isThereItemsEmpty = false;
//                           var keys =
//                           cont.itemsListInReplenish.keys.toList();
//                           for (int i = 0; i < keys.length; i++) {
//                             if (cont.itemsListInReplenish[keys[i]]
//                             ["itemId"] ==
//                                 '' ||
//                                 cont.itemsListInReplenish[keys[i]]
//                                 ["cost"] ==
//                                     '' ||
//                                 cont.itemsListInReplenish[keys[i]]
//                                 ["replenishedQty"] ==
//                                     '' ||
//                                 cont.itemsListInReplenish[keys[i]]
//                                 ["replenishedQty"] ==
//                                     '0') {
//                               setState(() {
//                                 isThereItemsEmpty = true;
//                               });
//                               break;
//                             }
//                           }
//                           if (isThereItemsEmpty) {
//                             CommonWidgets.snackBar('error',
//                                 'check all order lines and enter the required fields');
//                           } else {
//                             Navigator.push(context, MaterialPageRoute(
//                                 builder: (BuildContext context) {
//                                   return PrintReplenish(
//                                     currency: currencyController.text,
//                                     replenishNumber: replenishmentNumber,
//                                     receivedDate: '',
//                                     creationDate: dateController.text,
//                                     ref: refController.text,
//                                     destWarehouse: selectedDestWrhs ?? '',
//                                     status: 'sent',
//                                     rowsInListViewInReplenish: cont.itemsListInReplenish,
//                                   );
//                                 }));
//                           }
//                         },
//                       ),
//                       UnderTitleBtn(
//                           text: 'submit_and_preview'.tr,
//                           onTap: () async {
//                             bool isThereItemsEmpty = false;
//                             var keys =
//                             cont.itemsListInReplenish.keys.toList();
//                             for (int i = 0; i < keys.length; i++) {
//                               if (cont.itemsListInReplenish[keys[i]]
//                               ["itemId"] ==
//                                   '' ||
//                                   cont.itemsListInReplenish[keys[i]]
//                                   ["cost"] ==
//                                       '' ||
//                                   cont.itemsListInReplenish[keys[i]]
//                                   ["replenishedQty"] ==
//                                       '' ||
//                                   cont.itemsListInReplenish[keys[i]]
//                                   ["replenishedQty"] ==
//                                       '0') {
//                                 setState(() {
//                                   isThereItemsEmpty = true;
//                                 });
//                                 break;
//                               }
//                             }
//                             if (isThereItemsEmpty) {
//                               CommonWidgets.snackBar('error',
//                                   'check all order lines and enter the required fields');
//                             } else {
//                               var res = await addReplenishment(
//                                   transferController
//                                       .transferToIdInReplenish,
//                                   refController.text,
//                                   '',
//                                   dateController.text,
//                                   selectedCurrencyId,
//                                   transferController
//                                       .itemsListInReplenish);
//                               if (res['success'] == true) {
//                                 CommonWidgets.snackBar(
//                                     'Success', res['message']);
//                                 // ignore: use_build_context_synchronously
//                                 Navigator.push(context, MaterialPageRoute(
//                                     builder: (BuildContext context) {
//                                       return PrintReplenish(
//                                         currency: currencyController.text,
//                                         replenishNumber: replenishmentNumber,
//                                         receivedDate: '',
//                                         creationDate: dateController.text,
//                                         ref: refController.text,
//                                         destWarehouse: selectedDestWrhs ?? '',
//                                         status: 'sent',
//                                         rowsInListViewInReplenish: cont.itemsListInReplenish,
//                                       );
//                                     }));
//                               } else {
//                                 CommonWidgets.snackBar(
//                                     'error', res['message']);
//                               }
//                             }
//                           }),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       ReusableTimeLineTile(
//                           id: 0,
//                           progressVar: progressVar,
//                           isFirst: true,
//                           isLast: false,
//                           isPast: true,
//                           text: 'processing'.tr),
//                       ReusableTimeLineTile(
//                           id: 1,
//                           progressVar: progressVar,
//                           isFirst: false,
//                           isLast: false,
//                           isPast: false,
//                           text: 'pending'.tr),
//                       ReusableTimeLineTile(
//                         id: 2,
//                         progressVar: progressVar,
//                         isFirst: false,
//                         isLast: true,
//                         isPast: false,
//                         text: 'received'.tr,
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//               gapH16,
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 20, vertical: 20),
//                 decoration: BoxDecoration(
//                     border: Border.all(color: Others.divider),
//                     borderRadius:
//                     const BorderRadius.all(Radius.circular(9))),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.35,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               isInfoFetched
//                                   ? Text(replenishmentNumber,
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 20,
//                                       color:
//                                       TypographyColor.titleTable))
//                                   : const CircularProgressIndicator(),
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width *
//                                     0.05,
//                               ),
//                               DialogTextField(
//                                 textEditingController: refController,
//                                 text: '${'ref'.tr}:',
//                                 hint: 'manual_reference'.tr,
//                                 rowWidth:
//                                 MediaQuery.of(context).size.width *
//                                     0.18,
//                                 textFieldWidth:
//                                 MediaQuery.of(context).size.width *
//                                     0.15,
//                                 validationFunc: (val) {},
//                               ),
//                             ],
//                           ),
//                           gapH16,
//                           GetBuilder<TransferController>(
//                               builder: (transferCont) {
//                                 return Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text('${'transfer_to'.tr}*'),
//                                     GetBuilder<WarehouseController>(
//                                         builder: (cont) {
//                                           return DropdownMenu<String>(
//                                             width: MediaQuery.of(context)
//                                                 .size
//                                                 .width *
//                                                 0.25,
//                                             // requestFocusOnTap: false,
//                                             enableSearch: true,
//                                             controller: transferCont
//                                                 .transferToInReplenishController,
//                                             hintText: '${'search'.tr}...',
//                                             inputDecorationTheme:
//                                             InputDecorationTheme(
//                                               // filled: true,
//                                               hintStyle: const TextStyle(
//                                                   fontStyle: FontStyle.italic),
//                                               contentPadding:
//                                               const EdgeInsets.fromLTRB(
//                                                   20, 0, 25, 5),
//                                               // outlineBorder: BorderSide(color: Colors.black,),
//                                               enabledBorder: OutlineInputBorder(
//                                                 borderSide: BorderSide(
//                                                     color: Primary.primary
//                                                         .withAlpha((0.2 * 255).toInt()),
//                                                     width: 1),
//                                                 borderRadius:
//                                                 const BorderRadius.all(
//                                                     Radius.circular(9)),
//                                               ),
//                                               focusedBorder: OutlineInputBorder(
//                                                 borderSide: BorderSide(
//                                                     color: Primary.primary
//                                                         .withAlpha((0.4 * 255).toInt()),
//                                                     width: 2),
//                                                 borderRadius:
//                                                 const BorderRadius.all(
//                                                     Radius.circular(9)),
//                                               ),
//                                             ),
//                                             // menuStyle: ,
//                                             menuHeight: 250,
//                                             dropdownMenuEntries: cont
//                                                 .warehousesNameList
//                                                 .map<DropdownMenuEntry<String>>(
//                                                     (String option) {
//                                                   return DropdownMenuEntry<String>(
//                                                     value: option,
//                                                     label: option,
//                                                   );
//                                                 }).toList(),
//                                             enableFilter: true,
//                                             onSelected: (String? val) async {
//                                               setState(() {
//                                                 selectedDestWrhs = val!;
//                                                 var index = cont
//                                                     .warehousesNameList
//                                                     .indexOf(val);
//                                                 transferCont
//                                                     .setTransferToIdInReplenish(
//                                                     cont.warehouseIdsList[
//                                                     index]);
//                                               });
//                                               // listViewLength =
//                                               //     Sizes.deviceHeight * 0.08;
//                                               // transferCont
//                                               //     .clearReplenishOrderLines();
//                                               for (int i = 0;
//                                               i <
//                                                   transferCont
//                                                       .itemsListInReplenish
//                                                       .length;
//                                               i++) {
//                                                 var keys = transferCont.itemsListInReplenish.keys.toList();
//                                                 var p = await getQTyOfItemInWarehouse(
//                                                     transferCont
//                                                         .itemsListInReplenish[keys[i]]['itemId'],
//                                                     transferController
//                                                         .transferToIdInReplenish);
//                                                 if ('$p' != '[]') {
//                                                   String val=formatPackagingInfo( p['qtyOnHandPackages']);
//                                                   transferController.setQtyOnHandInSourceInReplenish('${keys[i]}',
//                                                       val.isNotEmpty?val:  '0 ${p['item']['packageUnitName'] ?? ''}');
//                                                   // setState(() {
//                                                   //   transferCont
//                                                   //       .itemsListInReplenish[keys[i]]['qtyOnHandPackages'] = p[
//                                                   //   'qtyOnHandPackages'] ??
//                                                   //       '0 ${p['item']['packageUnitName'] ?? ''}';
//                                                   // });
//                                                 }
//                                               }
//                                             },
//                                           );
//                                         }),
//                                   ],
//                                 );
//                               }),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.3,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             width:
//                             MediaQuery.of(context).size.width * 0.25,
//                             child: Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('date'.tr),
//                                 DialogDateTextField(
//                                   textEditingController: dateController,
//                                   text: '',
//                                   textFieldWidth:
//                                   MediaQuery.of(context).size.width *
//                                       0.15,
//                                   validationFunc: (val) {},
//                                   onChangedFunc: (val) {
//                                     dateController.text = val;
//                                   },
//                                   onDateSelected: (value) {
//                                     dateController.text = value;
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           gapH16,
//                           SizedBox(
//                             width:
//                             MediaQuery.of(context).size.width * 0.2,
//                             child: Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('cur'.tr),
//                                 GetBuilder<ExchangeRatesController>(
//                                     builder: (cont) {
//                                       return DropdownMenu<String>(
//                                         width: MediaQuery.of(context)
//                                             .size
//                                             .width *
//                                             0.1,
//                                         // requestFocusOnTap: false,
//                                         enableSearch: true,
//                                         controller: currencyController,
//                                         hintText: '',
//                                         inputDecorationTheme:
//                                         InputDecorationTheme(
//                                           // filled: true,
//                                           hintStyle: const TextStyle(
//                                               fontStyle: FontStyle.italic),
//                                           contentPadding:
//                                           const EdgeInsets.fromLTRB(
//                                               20, 0, 25, 5),
//                                           // outlineBorder: BorderSide(color: Colors.black,),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderSide: BorderSide(
//                                                 color: Primary.primary
//                                                     .withAlpha((0.2 * 255).toInt()),
//                                                 width: 1),
//                                             borderRadius:
//                                             const BorderRadius.all(
//                                                 Radius.circular(9)),
//                                           ),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderSide: BorderSide(
//                                                 color: Primary.primary
//                                                     .withAlpha((0.4 * 255).toInt()),
//                                                 width: 2),
//                                             borderRadius:
//                                             const BorderRadius.all(
//                                                 Radius.circular(9)),
//                                           ),
//                                         ),
//                                         // menuStyle: ,
//                                         menuHeight: 250,
//                                         dropdownMenuEntries: cont
//                                             .currenciesNamesList
//                                             .map<DropdownMenuEntry<String>>(
//                                                 (String option) {
//                                               return DropdownMenuEntry<String>(
//                                                 value: option,
//                                                 label: option,
//                                               );
//                                             }).toList(),
//                                         enableFilter: true,
//                                         onSelected: (String? val) {
//                                           setState(() {
//                                             selectedItem = val!;
//                                             var index = cont
//                                                 .currenciesNamesList
//                                                 .indexOf(val);
//                                             selectedCurrencyId =
//                                             cont.currenciesIdsList[index];
//                                           });
//                                         },
//                                       );
//                                     }),
//                               ],
//                             ),
//                           ),
//                           gapH16,
//                           Text('${'total_qty'.tr}: ')
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               gapH16,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Wrap(
//                       spacing: 0.0,
//                       direction: Axis.horizontal,
//                       children: tabsList
//                           .map((element) => _buildTabChipItem(
//                           element, tabsList.indexOf(element)))
//                           .toList()),
//                 ],
//               ),
//               // tabsContent[selectedTabIndex],
//               selectedTabIndex == 0
//                   ? Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       // horizontal:
//                       // MediaQuery.of(context).size.width *
//                       //     0.01,
//                         vertical: 15),
//                     decoration: BoxDecoration(
//                         color: Primary.primary,
//                         borderRadius: const BorderRadius.all(
//                             Radius.circular(6))),
//                     child: Row(
//                       mainAxisAlignment:
//                       MainAxisAlignment.spaceBetween,
//                       children: [
//                         TableTitle(
//                           text: 'item'.tr,
//                           width: MediaQuery.of(context).size.width *
//                               0.15,
//                         ),
//                         TableTitle(
//                           text: 'description'.tr,
//                           width: MediaQuery.of(context).size.width *
//                               0.15,
//                         ),
//                         TableTitle(
//                           text: 'qty_available_at_wrhs'.tr,
//                           width: MediaQuery.of(context).size.width *
//                               0.1,
//                         ),
//                         TableTitle(
//                           text: 'replenish_qty'.tr,
//                           width: MediaQuery.of(context).size.width *
//                               0.07,
//                         ),
//                         TableTitle(
//                           text: 'pack'.tr,
//                           width: MediaQuery.of(context).size.width *
//                               0.07,
//                         ),
//                         TableTitle(
//                           text: 'unit_cost'.tr,
//                           width: MediaQuery.of(context).size.width *
//                               0.07,
//                         ),
//                         TableTitle(
//                           text: 'note'.tr,
//                           width: MediaQuery.of(context).size.width *
//                               0.1,
//                         ),
//                         // TableTitle(
//                         //   text: 'more_options'.tr,
//                         //   width: MediaQuery.of(context).size.width *
//                         //       0.07,
//                         // ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                         horizontal:
//                         MediaQuery.of(context).size.width *
//                             0.01),
//                     decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(6),
//                           bottomRight: Radius.circular(6)),
//                       color: Colors.white,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: listViewLength,
//                           child: ListView.builder(
//                             padding: const EdgeInsets.symmetric(
//                               // horizontal:  MediaQuery.of(context).size.width *
//                               //     0.01,
//                                 vertical: 10),
//                             itemCount: cont
//                                 .itemsListInReplenish
//                                 .length, //products is data from back res
//                             itemBuilder: (context, index) {
//                               var keys = cont.itemsListInReplenish.keys
//                                   .toList();
//                               return ReusableItemRow(index: keys[index],);
//                             },
//                             //     Row(
//                             //   children: [
//                             //     Container(
//                             //       width:  20,// MediaQuery.of(context).size.width * 0.03,
//                             //       height: 20,
//                             //       margin:
//                             //       const EdgeInsets.symmetric(
//                             //           vertical: 15),
//                             //       decoration: const BoxDecoration(
//                             //         image: DecorationImage(
//                             //           image: AssetImage(
//                             //               'assets/images/newRow.png'),
//                             //           fit: BoxFit.contain,
//                             //         ),
//                             //       ),
//                             //     ),
//                             //     cont.orderLinesInTransferOutList[index],
//                             //     SizedBox(
//                             //       width: MediaQuery.of(context)
//                             //           .size
//                             //           .width *
//                             //           0.035,
//                             //       child: const ReusableMore(
//                             //         itemsList: [],
//                             //       ),
//                             //     ),
//                             //     SizedBox(
//                             //       width: MediaQuery.of(context)
//                             //           .size
//                             //           .width *
//                             //           0.035,
//                             //       child: InkWell(
//                             //         onTap: () {
//                             //           setState(() {
//                             //             cont.removeFromOrderLinesInTransferOutList(
//                             //                 index);
//                             //             listViewLength =
//                             //                 listViewLength -
//                             //                     increment;
//                             //           });
//                             //         },
//                             //         child: Icon(
//                             //           Icons.delete_outline,
//                             //           color: Primary.primary,
//                             //         ),
//                             //       ),
//                             //     ),
//                             //   ],
//                             // ),
//                           ),
//                         ),
//                         // Row(
//                         //   children: [
//                         //     ReusableAddCard(
//                         //       text: 'item'.tr,
//                         //       onTap: () {
//                         //         if (cont.transferToIdInReplenish !=
//                         //             '') {
//                         //           addNewItem();
//                         //         } else {
//                         //           CommonWidgets.snackBar('error',
//                         //               'you must choose a warehouse first');
//                         //         }
//                         //       },
//                         //     ),
//                         //     gapW32,
//                         //     ReusableAddCard(
//                         //       text: 'image'.tr,
//                         //       onTap: () {
//                         //         // addNewImage();
//                         //       },
//                         //     ),
//                         //     gapW32,
//                         //     ReusableAddCard(
//                         //       text: 'note'.tr,
//                         //       onTap: () {
//                         //         // addNewNote();
//                         //       },
//                         //     ),
//                         //   ],
//                         // )
//                       ],
//                     ),
//                   ),
//                   gapH28,
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       ReusableButtonWithColor(
//                         width: MediaQuery.of(context).size.width *
//                             0.15,
//                         height: 45,
//                         isDisable:
//                         cont.itemsListInReplenish.isEmpty,
//                         onTapFunction: () async {
//                           bool isThereItemsEmpty = false;
//                           var keys = cont.itemsListInReplenish.keys
//                               .toList();
//                           for (int i = 0; i < keys.length; i++) {
//                             if (cont.itemsListInReplenish[keys[i]]
//                             ["itemId"] ==
//                                 '' ||
//                                 cont.itemsListInReplenish[keys[i]]
//                                 ["cost"] ==
//                                     '' ||
//                                 cont.itemsListInReplenish[keys[i]]
//                                 ["replenishedQty"] ==
//                                     '' ||
//                                 cont.itemsListInReplenish[keys[i]]
//                                 ["replenishedQty"] ==
//                                     '0') {
//                               setState(() {
//                                 isThereItemsEmpty = true;
//                               });
//                               break;
//                             }
//                           }
//                           if (isThereItemsEmpty) {
//                             CommonWidgets.snackBar('error',
//                                 'check all order lines and enter the required fields');
//                           } else {
//                             var res = await addReplenishment(
//                                 transferController
//                                     .transferToIdInReplenish,
//                                 refController.text,
//                                 '',
//                                 dateController.text,
//                                 selectedCurrencyId,
//                                 transferController
//                                     .itemsListInReplenish);
//                             if (res['success'] == true) {
//                               CommonWidgets.snackBar(
//                                   'Success', res['message']);
//                               //todo
//                               // transferController.isReplenishmentInfoFetched = false;
//                               transferController
//                                   .getAllReplenishmentFromBack();
//                               homeController.selectedTab.value =
//                               'replenishment';
//                             } else {
//                               CommonWidgets.snackBar(
//                                   'error', res['message']);
//                             }
//                           }
//                         },
//                         btnText: 'submit'.tr,
//                       ),
//                     ],
//                   )
//                 ],
//               )
//                   : const SizedBox(),
//               gapH40,
//             ],
//           ),
//         ),
//       );
//     })
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
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(9),
//                     topRight: Radius.circular(9)))),
//         child: Container(
//           width: name.length * 10, // MediaQuery.of(context).size.width * 0.09,
//           height: MediaQuery.of(context).size.height * 0.07,
//           decoration: BoxDecoration(
//               color: selectedTabIndex == index ? Primary.p20 : Colors.white,
//               border: selectedTabIndex == index
//                   ? Border(
//                 top: BorderSide(color: Primary.primary, width: 3),
//               )
//                   : null,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withAlpha((0.5 * 255).toInt()),
//                   spreadRadius: 9,
//                   blurRadius: 9,
//                   // offset: Offset(0, 3),
//                 )
//               ]),
//           child: Center(
//             child: Text(
//               name.tr,
//               style: TextStyle(
//                   fontWeight: FontWeight.bold, color: Primary.primary),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   addNewItem() {
//     setState(() {
//       listViewLength = listViewLength + increment;
//     });
//     int index = transferController.itemsListInReplenish.length + 1;
//     // Widget p = ReusableItemRow(index: index);
//     // transferController.addToOrderLinesInReplenishList(p);
//     transferController.addToItemsListInReplenish('$index', {
//       'itemId': '',
//       'itemCode': '',
//       'mainDescription': '',
//       'replenishedQty': '',
//       'replenishedQtyPackage': '',
//       'cost': '',
//       'note': '',
//       'qtyOnHandPackagesInSource': '',
//       'productsPackages': <String>[],
//     });
//   }
//
//   addNewImage() {
//     setState(() {
//       listViewLength = listViewLength + 100;
//     });
//     GetBuilder<TransferController>(builder: (cont) {
//       return InkWell(
//         onTap: () async {
//           final image = await ImagePickerHelper.pickImage();
//           setState(() {
//
//             imageFile = image!;
//             cont.changeBoolVarInTransferOut(true);
//             cont.increaseImageSpaceInTransferOut(90);
//             listViewLength =
//                 listViewLength + (cont.imageSpaceHeightInTransferOut) + 10;
//           });
//         },
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//           child: DottedBorder(
//             dashPattern: const [10, 10],
//             color: Others.borderColor,
//             radius: const Radius.circular(9),
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.63,
//               height: cont.imageSpaceHeightInTransferOut,
//               child: cont.imageAvailableInReplenish
//                   ? Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Image.memory(
//                     imageFile,
//                     height: cont.imageSpaceHeightInTransferOut,
//                   ),
//                 ],
//               )
//                   : Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   gapW20,
//                   Icon(Icons.cloud_upload_outlined,
//                       color: Others.iconColor, size: 32),
//                   gapW20,
//                   Text(
//                     'drag_drop_image'.tr,
//                     style: TextStyle(color: TypographyColor.textTable),
//                   ),
//                   Text(
//                     'browse'.tr,
//                     style: TextStyle(color: Primary.primary),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//     // transferController.addToOrderLinesInReplenishList(p);
//   }
//
//   addNewNote() {
//     setState(() {
//       listViewLength = listViewLength + increment;
//     });
//     Container(
//       width: MediaQuery.of(context).size.width * 0.63,
//       margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//       child: ReusableTextField(
//         textEditingController: TextEditingController(), //todo
//         isPasswordField: false,
//         hint: 'note'.tr,
//         onChangedFunc: (val) {},
//         validationFunc: (val) {},
//       ),
//     );
//     // transferController.addToOrderLinesInReplenishList(p);
//   }
//
//   List<Step> getSteps() => [
//     Step(
//         title: const Text(''),
//         content: Container(
//           //page
//         ),
//         isActive: currentStep >= 0),
//     Step(
//         title: const Text(''),
//         content: Container(),
//         isActive: currentStep >= 1),
//     Step(
//         title: const Text(''),
//         content: Container(),
//         isActive: currentStep >= 2),
//   ];
// }
//
// class ReusableItemRow extends StatefulWidget {
//   const ReusableItemRow({super.key, required this.index});
//   final String index;
//   @override
//   State<ReusableItemRow> createState() => _ReusableItemRowState();
// }
//
// class _ReusableItemRowState extends State<ReusableItemRow> {
//   final TransferController transferController = Get.find();
//   String qty = '0';
//   TextEditingController qtyController = TextEditingController();
//   TextEditingController costController = TextEditingController();
//   TextEditingController packageController = TextEditingController();
//   TextEditingController noteController = TextEditingController();
//   TextEditingController productController = TextEditingController();
//   List<String> productsPackages = [];
//   String selectedPackage = '';
//   String selectedItemId = '';
//   bool isDataFetched = false;
//   String note = '';
//   String defaultTransactionPackageType = '';
//   getQTyOfItemInWarehouseFromBack() async {
//     var p = await getQTyOfItemInWarehouse(
//         selectedItemId, transferController.transferToIdInReplenish);
//     if ('$p' != '[]') {
//       setState(() {
//         // disc = p['item']['mainDescription'] ?? '';
//         defaultTransactionPackageType =
//         '${p['item']['defaultTransactionPackageType'] ?? ''}';
//         costController.text = '${p['item']['unitCost'] ?? '0'}';
//         transferController.setCostItemInReplenish(
//             widget.index, costController.text);
//         // qtyInWarehouse =
//         //     '${p['qtyOnHandPackages'] ?? '0 ${p['item']['packageUnitName'] ?? ''}'}';
//         if (p['item']['packageUnitName'] != null) {
//           productsPackages.add(p['item']['packageUnitName']);
//         }
//         if (p['item']['packageSetName'] != null) {
//           productsPackages.add(p['item']['packageSetName']);
//         }
//         if (p['item']['packageSupersetName'] != null) {
//           productsPackages.add(p['item']['packageSupersetName']);
//         }
//         if (p['item']['packagePaletteName'] != null) {
//           productsPackages.add(p['item']['packagePaletteName']);
//         }
//         if (p['item']['packageContainerName'] != null) {
//           productsPackages.add(p['item']['packageContainerName']);
//         }
//         defaultTransactionPackageType =
//         '${p['item']['defaultTransactionPackageType'] ?? '1'}';
//         if (defaultTransactionPackageType == '1') {
//           packageController.text = p['item']['packageUnitName'];
//         } else if (defaultTransactionPackageType == '2') {
//           packageController.text = p['item']['packageSetName'];
//         } else if (defaultTransactionPackageType == '3') {
//           packageController.text = p['item']['packageSupersetName'];
//         } else if (defaultTransactionPackageType == '4') {
//           packageController.text = p['item']['packagePaletteName'];
//         } else if (defaultTransactionPackageType == '5') {
//           packageController.text = p['item']['packageContainerName'];
//         }
//         transferController.setReplenishedQtyPackageIdInReplenish(
//             widget.index, packageController.text);
//         transferController.setProductsPackagesInReplenish(
//             widget.index, productsPackages);
//         transferController.setMainDescriptionInReplenish(
//             widget.index, p['item']['mainDescription'] ?? '');
//         String val=formatPackagingInfo( p['qtyOnHandPackages']??{});
//         transferController.setQtyOnHandInSourceInReplenish(widget.index,
//             val.isNotEmpty?val: '0 ${p['item']['packageUnitName'] ?? ''}');
//
//         isDataFetched = true;
//       });
//     }
//   }
//
//   String? dropDownValue;
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     qtyController.text= transferController.itemsListInReplenish[widget.index]['replenishedQty'];
//     packageController.text= transferController.itemsListInReplenish[widget.index]['replenishedQtyPackage'];
//     costController.text= transferController.itemsListInReplenish[widget.index]['cost'];
//     noteController.text= transferController.itemsListInReplenish[widget.index]['note'];
//     productController.text= transferController.itemsListInReplenish[widget.index]['itemCode'];
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<TransferController>(builder: (cont) {
//       return Container(
//         margin: const EdgeInsets.symmetric(
//           vertical: 5,
//         ),
//         child: Form(
//           key: _formKey,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 width: MediaQuery.of(context).size.width * 0.02,
//                 height: 20,
//                 margin: const EdgeInsets.symmetric(vertical: 15),
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/images/newRow.png'),
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//               cont.isProductsFetched
//                   ? DropdownMenu<String>(
//                 width: MediaQuery.of(context).size.width * 0.12,
//                 // requestFocusOnTap: false,
//                 enableSearch: true,
//                 controller: productController,
//                 hintText: '${'search'.tr}...',
//                 inputDecorationTheme: InputDecorationTheme(
//                   // filled: true,
//                   hintStyle: const TextStyle(fontStyle: FontStyle.italic),
//                   contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
//                   // outlineBorder: BorderSide(color: Colors.black,),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
//                     borderRadius: const BorderRadius.all(Radius.circular(9)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
//                     borderRadius: const BorderRadius.all(Radius.circular(9)),
//                   ),
//                 ),
//                 // menuStyle: ,
//                 menuHeight: 250,
//                 dropdownMenuEntries: cont.productsCodes
//                     .map<DropdownMenuEntry<String>>((String option) {
//                   return DropdownMenuEntry<String>(
//                     value: option,
//                     label: option,
//                   );
//                 }).toList(),
//                 enableFilter: true,
//                 onSelected: (String? value) {
//                   setState(() {
//                     selectedItemId =
//                     '${cont.productsIds[cont.productsCodes.indexOf(value!)]}';
//                   });
//                   cont.setItemIdInReplenish(
//                       widget.index, selectedItemId);
//                   cont.setItemNameInReplenish(widget.index, value!);
//                   getQTyOfItemInWarehouseFromBack();
//                 },
//               )
//               // DialogDropMenu(
//               //         optionsList: cont.productsNames,
//               //         controller: productController,
//               //         text: '',
//               //         hint: 'item'.tr,
//               //         rowWidth: MediaQuery.of(context).size.width * 0.12,
//               //         textFieldWidth: MediaQuery.of(context).size.width * 0.12,
//               //         onSelected: (value) {
//               //           setState(() {
//               //             selectedItemId =
//               //                 '${cont.productsIds[cont.productsNames.indexOf(value)]}';
//               //           });
//               //           cont.setItemIdInReplenish(
//               //               widget.index, selectedItemId);
//               //           cont.setItemNameInReplenish(widget.index, value);
//               //           getQTyOfItemInWarehouseFromBack();
//               //         },
//               //       )
//               // SizedBox(
//               //                     width: MediaQuery.of(context).size.width * 0.07,
//               //                     child: DropdownButtonFormField<String>(
//               //                       autovalidateMode: AutovalidateMode.always,
//               //                       value: dropDownValue,
//               //                       decoration: InputDecoration(
//               //                         // contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
//               //                         // outlineBorder: BorderSide(color: Colors.black,),
//               //                         enabledBorder: OutlineInputBorder(
//               //                           borderSide: BorderSide(
//               //                               color: Primary.primary.withAlpha((0.2 * 255).toInt()),
//               //                               width: 1),
//               //                           borderRadius:
//               //                               const BorderRadius.all(Radius.circular(9)),
//               //                         ),
//               //                         focusedBorder: OutlineInputBorder(
//               //                           borderSide: BorderSide(
//               //                               color: Primary.primary.withAlpha((0.4 * 255).toInt()),
//               //                               width: 2),
//               //                           borderRadius:
//               //                               const BorderRadius.all(Radius.circular(9)),
//               //                         ),
//               //                       ),
//               //                       items: cont.productsNames.map(
//               //                         (String label) {
//               //                           return DropdownMenuItem<String>(
//               //                             value: label,
//               //                             child: Text(
//               //                               label,
//               //                             ),
//               //                           );
//               //                         },
//               //                       ).toList(),
//               //                       hint: Text(
//               //                         'item'.tr,
//               //                       ),
//               //                       onChanged: (String? value) {
//               //                         setState(() {
//               //                           dropDownValue = value;
//               //                           selectedItemId =
//               //                               '${cont.productsIds[cont.productsNames.indexOf(value!)]}';
//               //                         });
//               //                         cont.setItemIdInReplenish(
//               //                             '${widget.index}', selectedItemId);
//               //                         getQTyOfItemInWarehouseFromBack();
//               //                       },
//               //                       validator: (String? value) {
//               //                         // widget.validationFunc(value);
//               //                         return value == null ? "Choose item from list" : null;
//               //                       },
//               //                     ),
//               //                   )
//                   : loading(),
//               ReusableShowInfoCard(
//                   text: cont.itemsListInReplenish[widget.index]['mainDescription'],
//                   width: MediaQuery.of(context).size.width * 0.15),
//               ReusableShowInfoCard(
//                   text: cont.itemsListInReplenish[widget.index]['qtyOnHandPackagesInSource'],
//                   width: MediaQuery.of(context).size.width * 0.1),
//               // ReusableShowInfoCard(
//               //     text: qtyInDes, width: MediaQuery.of(context).size.width * 0.1),
//               SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.07,
//                   child: ReusableNumberField(
//                     textEditingController: qtyController,
//                     isPasswordField: false,
//                     isCentered: true,
//                     hint: '0',
//                     onChangedFunc: (val) {
//                       _formKey.currentState!.validate();
//                       cont.setReplenishedQtyInReplenish(widget.index, val);
//                       setState(() {
//                         qty = val;
//                       });
//                     },
//                     validationFunc: (String? value) {
//                       if (value!.isEmpty || double.parse(value) <= 0) {
//                         return 'must be >0';
//                       }
//                       return null;
//                     },
//                   )),
//               DialogDropMenu(
//                 optionsList:  cont.itemsListInReplenish[widget.index]['productsPackages'],
//                 text: '',
//                 hint: '',
//                 controller: packageController,
//                 rowWidth: MediaQuery.of(context).size.width * 0.07,
//                 textFieldWidth: MediaQuery.of(context).size.width * 0.07,
//                 onSelected: (value) {
//                   cont.setReplenishedQtyPackageIdInReplenish(
//                       widget.index, value);
//                   setState(() {
//                     selectedPackage = value;
//                   });
//                 },
//               ),
//               // ReusableShowInfoCard(
//               //     text: unitCost,
//               //     width: MediaQuery.of(context).size.width * 0.07),
//               SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.07,
//                   child: ReusableNumberField(
//                     textEditingController: costController,
//                     isPasswordField: false,
//                     isCentered: true,
//                     hint: '0',
//                     onChangedFunc: (val) {
//                       _formKey.currentState!.validate();
//                       cont.setCostItemInReplenish(widget.index, val);
//                     },
//                     validationFunc: (String? value) {
//                       if (value!.isEmpty) {
//                         return 'required field';
//                       }
//                       return null;
//                     },
//                   )),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.1,
//                 child: ReusableTextField(
//                     onChangedFunc: (val) {
//                       cont.setNoteInReplenish(widget.index, val);
//                       setState(() {
//                         note = val;
//                       });
//                     },
//                     validationFunc: (val) {},
//                     hint: '',
//                     isPasswordField: false,
//                     textEditingController: noteController),
//               ),
//               // SizedBox(
//               //   width: MediaQuery.of(context).size.width * 0.03,
//               //   child: const ReusableMore(
//               //     itemsList: [],
//               //   ),
//               // ),
//               // SizedBox(
//               //   width: MediaQuery.of(context).size.width * 0.03,
//               //   child: InkWell(
//               //     onTap: () {
//               //       // setState(() {
//               //       //   cont.removeFromOrderLinesInTransferOutList(index);
//               //       //   listViewLength =
//               //       //       listViewLength -
//               //       //           increment;
//               //       // });
//               //     },
//               //     child: Icon(
//               //       Icons.delete_outline,
//               //       color: Primary.primary,
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }
