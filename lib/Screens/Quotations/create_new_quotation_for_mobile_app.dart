// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// // import 'package:rooster_app/utils/image_picker_helper.dart';
// import 'package:rooster_app/Controllers/ExchangeRatesController/exchange_rates_controller.dart';
// import 'package:rooster_app/Controllers/QuotationsController/quotation_controller.dart';
// import 'package:rooster_app/Screens/Configuration/sup_references_dialog.dart';
// import 'package:rooster_app/Screens/Quotations/create_client_dialog.dart';
// import 'package:rooster_app/Screens/Quotations/print_quotation.dart';
// import 'package:rooster_app/Widgets/reusable_drop_down_menu.dart';
// import 'package:rooster_app/Widgets/table_item.dart';
// import '../../../Backend/Quotations/get_quotation_create_info.dart';
// import '../../../Backend/Quotations/store_quotation.dart';
// import '../../../Controllers/home_controller.dart';
// import '../../../Widgets/custom_snak_bar.dart';
// import '../../../Widgets/page_title.dart';
// import '../../../Widgets/reusable_btn.dart';
// import '../../../Widgets/reusable_text_field.dart';
// import '../../../const/Sizes.dart';
// import '../../../const/colors.dart';
// import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
// import '../../Widgets/dialog_drop_menu.dart';
// import '../../Widgets/reusable_add_card.dart';
// import '../../Widgets/reusable_more.dart';
// import '../../Widgets/table_title.dart';
// import '../../Widgets/TransferWidgets/reusable_show_info_card.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:image_picker/image_picker.dart';
// // import 'package:time_machine/time_machine.dart';
//
// class CreateNewQuotationForMobileApp extends StatefulWidget {
//   const CreateNewQuotationForMobileApp({super.key});
//
//   @override
//   State<CreateNewQuotationForMobileApp> createState() => _CreateNewQuotationForMobileAppState();
// }
//
// class _CreateNewQuotationForMobileAppState extends State<CreateNewQuotationForMobileApp> {
//   // bool imageAvailable=false;
//   TextEditingController globalDiscPercentController = TextEditingController();
//   TextEditingController specialDiscPercentController = TextEditingController();
//   TextEditingController controller = TextEditingController();
//   TextEditingController commissionController = TextEditingController();
//   TextEditingController currencyController = TextEditingController();
//
//   TextEditingController totalCommissionController = TextEditingController();
//   TextEditingController refController = TextEditingController();
//   TextEditingController validityController = TextEditingController();
//   TextEditingController searchController = TextEditingController();
//   TextEditingController codeController = TextEditingController();
//
//   TextEditingController vatExemptController = TextEditingController();
//   TextEditingController termsAndConditionsController = TextEditingController();
//   List<String> vatExemptListTrue = [
//     'prices are before vat',
//     'prices are vat inclusive',
//   ];
//   List<String> vatExemptListFalse = [
//     'exempted from vat ,printed as "vat exempted"',
//     'exempted from vat ,printed as "vat 0 % = 0"',
//     'exempted from vat , no printed ',
//   ];
//
//   bool isVatExemptChecked = false;
//   bool isBeforeVatPrices = false;
//   bool isVatInclusivePrices = false;
//   bool isPrintedAsVatExempt = false;
//   bool isPrintedAsPercentage = false;
//   bool isVatNoPrinted = false;
//   String selectedVatExemptListTrue = '';
//   String globalDiscountPercentage = ''; // user insert this value
//   String specialDiscountPercentage = ''; // user insert this value
//
//   String selectedPaymentTerm = '',
//       selectedPriceList = '',
//       selectedCurrency = '',
//       termsAndConditions = '',
//       specialDisc = '',
//       globalDisc = '';
//
//   late Uint8List imageFile;
//
//   int currentStep = 0;
//   int selectedTabIndex = 0;
//   GlobalKey accMoreKey = GlobalKey();
//   GlobalKey accMoreKey3 = GlobalKey();
//   List tabsList = [
//     'order_lines',
//     'other_information',
//   ];
//   List<String> currencyList = [
//     'EUR',
//     'USD',
//     'LBP',
//   ];
//   String selectedTab = 'order_lines'.tr;
//   String? selectedItem = '';
//   String? selectedItemCode = '';
//
//   double listViewLength = Sizes.deviceHeight * 0.08;
//   double increment = Sizes.deviceHeight * 0.08;
//   // double imageSpaceHeight = Sizes.deviceHeight * 0.1;
//   // List<Widget> orderLinesList = [];
//
//   bool isActiveVatChecked = false;
//   bool isActiveDeliveredChecked = false;
//   List<String> vatExemptList = [];
//   final QuotationController quotationController = Get.find();
//   final HomeController homeController = Get.find();
//   final ExchangeRatesController exchangeRatesController = Get.find();
//   String selectedCurrencyId = '';
//
//   int progressVar = 0;
//   Map data = {};
//   bool isQuotationsInfoFetched = false;
//   List<String> customerNameList = [];
//   List<String> customerTitleList = [];
//   List<String> customerNumberList = [];
//   List customerIdsList = [];
//   String selectedCustomerIds = '';
//   String quotationNumber = '';
//   String clientEmail = '';
//   String vat11 = '';
//   Map email = {};
//
//   // address tel email vat get from back and show data
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
//       selectedItemCode = '';
//       progressVar = 0;
//       selectedCustomerIds = '';
//       quotationNumber = '';
//       currencyController.text = '';
//
//       data = {};
//       customerNameList = [];
//       customerIdsList = [];
//       customerNumberList = [];
//     });
//     var p = await getFieldsForCreateQuotation();
//     quotationNumber = p['quotationNumber'];
//     // client_number
//     if ('$p' != '[]') {
//       setState(() {
//         data.addAll(p);
//         quotationNumber = p['quotationNumber'] as String;
//         for (var client in p['clients']) {
//           customerNameList.add('${client['name']}');
//           customerNumberList.add('${client['client_number']}');
//           customerIdsList.add('${client['id']}');
//           // email["${client['id']}"] = client['email'];
//         }
//         isQuotationsInfoFetched = true;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     // quotationController.setIsSubmitAndPreviewClicked(false);
//     getFieldsForCreateQuotationFromBack();
//     exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();
//     quotationController.email[selectedCustomerIds] = '';
//     quotationController.phoneNumber[selectedCustomerIds] = '';
//     quotationController.resetQuotation();
//     quotationController.listViewLengthInQuotation = 50;
//     super.initState();
//   }
//
//   // int index = 0;
//   int totalAllItems = 0;
//   int indexNum = 0;
//   String phoneNumber = '';
//
//   @override
//   Widget build(BuildContext context) {
//     return isQuotationsInfoFetched
//         ? GetBuilder<QuotationController>(builder: (quotationCont) {
//       var keysList = quotationCont.orderLinesQuotationList.keys.toList();
//       return
//
//         Container(
//           padding: EdgeInsets.symmetric(
//               horizontal: MediaQuery.of(context).size.width * 0.02),
//           height: MediaQuery.of(context).size.height * 0.85,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     PageTitle(text: 'create_new_quotation'.tr),
//                   ],
//                 ),
//                 gapH16,
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         UnderTitleBtn(
//                           text: 'preview'.tr,
//                           onTap: () {
//                             bool isThereItemsEmpty = false;
//                             var keys = quotationCont
//                                 .rowsInListViewInQuotation.keys
//                                 .toList();
//                             for (int i = 0; i < keys.length; i++) {
//                               if (quotationCont.rowsInListViewInQuotation[
//                               keys[i]]["quantity"] ==
//                                   '' ||
//                                   quotationCont.rowsInListViewInQuotation[
//                                   keys[i]]["quantity"] ==
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
//                               Navigator.push(context, MaterialPageRoute(
//                                   builder: (BuildContext context) {
//                                     return PrintQuotation(
//                                       isInQuotation: true,
//                                       quotationNumber: quotationNumber,
//                                       creationDate: validityController.text,
//                                       ref: refController.text,
//                                       receivedUser: '',
//                                       senderUser: homeController.useName,
//                                       status: 'sent',
//                                       rowsInListViewInQuotation: quotationCont
//                                           .rowsInListViewInQuotation,
//                                     );
//                                   }));
//                             }
//                           },
//                         ),
//                         UnderTitleBtn(
//                           text: 'send_by_email'.tr,
//                           onTap: () {
//                             if (progressVar == 0) {
//                               setState(() {
//                                 progressVar += 1;
//                               });
//                             }
//                           },
//                         ),
//                         UnderTitleBtn(
//                           text: 'confirm'.tr,
//                           onTap: () {
//                             if (progressVar == 1) {
//                               setState(() {
//                                 progressVar += 1;
//                               });
//                             }
//                           },
//                         ),
//                         UnderTitleBtn(
//                           text: 'cancel'.tr,
//                           onTap: () {
//                             setState(() {
//                               progressVar = 0;
//                             });
//                           },
//                         ),
//                         // UnderTitleBtn(
//                         //   text: 'task'.tr,
//                         //   onTap: () {
//                         //     showDialog<String>(
//                         //         context: context,
//                         //         builder: (BuildContext context) =>
//                         //         const AlertDialog(
//                         //             backgroundColor: Colors.white,
//                         //             shape: RoundedRectangleBorder(
//                         //               borderRadius: BorderRadius.all(
//                         //                   Radius.circular(9)),
//                         //             ),
//                         //             elevation: 0,
//                         //             content:
//                         //             ScheduleTaskDialogContent()));
//                         //   },
//                         // ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         ReusableTimeLineTile(
//                             id: 0,
//                             progressVar: progressVar,
//                             isFirst: true,
//                             isLast: false,
//                             isPast: true,
//                             text: 'processing'.tr),
//                         ReusableTimeLineTile(
//                             id: 1,
//                             progressVar: progressVar,
//                             isFirst: false,
//                             isLast: false,
//                             isPast: false,
//                             text: 'quotation_sent'.tr),
//                         ReusableTimeLineTile(
//                           id: 2,
//                           progressVar: progressVar,
//                           isFirst: false,
//                           isLast: true,
//                           isPast: false,
//                           text: 'confirmed'.tr,
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//                 gapH16,
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 20, vertical: 20),
//                   decoration: BoxDecoration(
//                       border: Border.all(color: Others.divider),
//                       borderRadius:
//                       const BorderRadius.all(Radius.circular(9))),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                               quotationNumber, //'${data['quotationNumber'].toString() ?? ''}',
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 20,
//                                   color: TypographyColor.titleTable)),
//                           DialogTextField(
//                             textEditingController: refController,
//                             text: '${'ref'.tr}:',
//                             hint: 'manual_reference'.tr,
//                             rowWidth:
//                             MediaQuery.of(context).size.width * 0.18,
//                             textFieldWidth:
//                             MediaQuery.of(context).size.width * 0.15,
//                             validationFunc: (val) {},
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 0.15,
//                             child: Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('currency'.tr),
//                                 GetBuilder<ExchangeRatesController>(
//                                     builder: (cont) {
//                                       return DropdownMenu<String>(
//                                         width:
//                                         MediaQuery.of(context).size.width *
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
//                                             selectedCurrency = val!;
//                                             var index = cont.currenciesNamesList
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
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 0.25,
//                             child: Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('validity'.tr),
//                                 DialogDateTextField(
//                                   textEditingController: validityController,
//                                   text: '',
//                                   textFieldWidth:
//                                   MediaQuery.of(context).size.width *
//                                       0.20,
//                                   // MediaQuery.of(context).size.width * 0.25,
//                                   validationFunc: (val) {},
//                                   onChangedFunc: (val) {
//                                     validityController.text = val;
//                                   },
//                                   onDateSelected: (value) {
//                                     validityController.text = value;
//                                     setState(() {
//                                       // LocalDate a=LocalDate.today();
//                                       // LocalDate b = LocalDate.dateTime(value);
//                                       // Period diff = b.periodSince(a);
//                                       // print("years: ${diff.years}; months: ${diff.months}; days: ${diff.days}");
//                                     });
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       gapH16,
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // DialogTextField(
//                           //   textEditingController: codeController,
//                           //   text: '${'code'.tr}',
//                           //   hint: ''.tr,
//                           //   rowWidth:
//                           //       MediaQuery.of(context).size.width * 0.18,
//                           //   textFieldWidth:
//                           //       MediaQuery.of(context).size.width * 0.15,
//                           //   validationFunc: (val) {},
//                           // ),
//
//                           //code
//                           // SizedBox(
//                           //   width: MediaQuery.of(context).size.width * 0.18,
//                           //   child: Row(
//                           //     mainAxisAlignment:
//                           //         MainAxisAlignment.spaceBetween,
//                           //     crossAxisAlignment: CrossAxisAlignment.center,
//                           //     children: [
//                           //       //     Text('${'name'.tr}*'),
//                           //       Text('${'code'.tr}'),
//                           //       DropdownMenu<String>(
//                           //         width: MediaQuery.of(context).size.width *
//                           //             0.15,
//                           //         // requestFocusOnTap: false,
//                           //         enableSearch: true,
//                           //         controller: codeController,
//                           //         hintText: '${'search'.tr}...',
//                           //         inputDecorationTheme: InputDecorationTheme(
//                           //           // filled: true,
//                           //           hintStyle: const TextStyle(
//                           //               fontStyle: FontStyle.italic),
//                           //           contentPadding: const EdgeInsets.fromLTRB(
//                           //               20, 0, 25, 5),
//                           //           // outlineBorder: BorderSide(color: Colors.black,),
//                           //           enabledBorder: OutlineInputBorder(
//                           //             borderSide: BorderSide(
//                           //                 color: Primary.primary
//                           //                     .withAlpha((0.2 * 255).toInt()),
//                           //                 width: 1),
//                           //             borderRadius: const BorderRadius.all(
//                           //                 Radius.circular(9)),
//                           //           ),
//                           //           focusedBorder: OutlineInputBorder(
//                           //             borderSide: BorderSide(
//                           //                 color: Primary.primary
//                           //                     .withAlpha((0.4 * 255).toInt()),
//                           //                 width: 2),
//                           //             borderRadius: const BorderRadius.all(
//                           //                 Radius.circular(9)),
//                           //           ),
//                           //         ),
//                           //         // menuStyle: ,
//                           //         menuHeight: 250,
//                           //         dropdownMenuEntries: customerNumberList
//                           //             .map<DropdownMenuEntry<String>>(
//                           //                 (String option) {
//                           //           return DropdownMenuEntry<String>(
//                           //             value: option,
//                           //             label: option,
//                           //           );
//                           //         }).toList(),
//                           //         enableFilter: true,
//                           //         onSelected: (String? val) {
//                           //           quotationController
//                           //               .getFieldsForCreateQuotationFromBack();
//                           //           setState(() {
//                           //             selectedItemCode = val!;
//                           //             indexNum =
//                           //                 customerNumberList.indexOf(val);
//                           //             // selectedCustomerIds =
//                           //             // customerIdsList[indexnum];
//                           //           });
//                           //           quotationController
//                           //               .setClientName(indexNum);
//                           //
//                           //           searchController.text =
//                           //               quotationController.clientName;
//                           //         },
//                           //       ),
//                           //     ],
//                           //   ),
//                           // ),
//
//                           //code
//                           quotationCont.clientNumber[selectedCustomerIds] ==
//                               null
//                               ? SizedBox(
//                             width: MediaQuery.of(context).size.width *
//                                 0.18,
//                             child: Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment:
//                               CrossAxisAlignment.center,
//                               children: [
//                                 Text('code'.tr),
//                                 DropdownMenu<String>(
//                                   width: MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                       0.15,
//                                   // requestFocusOnTap: false,
//                                   enableSearch: true,
//                                   controller: codeController,
//                                   hintText: '${'search'.tr}...',
//                                   inputDecorationTheme:
//                                   InputDecorationTheme(
//                                     // filled: true,
//                                     hintStyle: const TextStyle(
//                                         fontStyle: FontStyle.italic),
//                                     contentPadding:
//                                     const EdgeInsets.fromLTRB(
//                                         20, 0, 25, 5),
//                                     // outlineBorder: BorderSide(color: Colors.black,),
//                                     enabledBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Primary.primary
//                                               .withAlpha((0.2 * 255).toInt()),
//                                           width: 1),
//                                       borderRadius:
//                                       const BorderRadius.all(
//                                           Radius.circular(9)),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Primary.primary
//                                               .withAlpha((0.4 * 255).toInt()),
//                                           width: 2),
//                                       borderRadius:
//                                       const BorderRadius.all(
//                                           Radius.circular(9)),
//                                     ),
//                                   ),
//                                   // menuStyle: ,
//                                   menuHeight: 250,
//                                   dropdownMenuEntries:
//                                   customerNumberList.map<
//                                       DropdownMenuEntry<
//                                           String>>(
//                                           (String option) {
//                                         return DropdownMenuEntry<String>(
//                                           value: option,
//                                           label: option,
//                                         );
//                                       }).toList(),
//                                   enableFilter: true,
//                                   onSelected: (String? val) {
//                                     quotationController
//                                         .getFieldsForCreateQuotationFromBack();
//                                     setState(() {
//                                       selectedItemCode = val!;
//                                       indexNum = customerNumberList
//                                           .indexOf(val);
//                                       selectedCustomerIds =
//                                       customerIdsList[indexNum];
//                                       searchController =
//                                           quotationController
//                                               .nameController;
//                                     });
//                                     quotationController.setClientName(
//                                         int.parse(
//                                             selectedCustomerIds));
//                                   },
//                                 ),
//                               ],
//                             ),
//                           )
//                               : SizedBox(
//                             width: MediaQuery.of(context).size.width *
//                                 0.18,
//
//                             // width: isDesktop
//                             //     ? MediaQuery.of(context).size.width * 0.35
//                             //     : MediaQuery.of(context).size.width * 0.18,
//                             child: Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment:
//                               CrossAxisAlignment.center,
//                               children: [
//                                 Text('code'.tr),
//                                 DropdownMenu<String>(
//                                   width: MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                       0.15,
//                                   // requestFocusOnTap: false,
//                                   enableSearch: true,
//                                   controller:
//                                   quotationCont.codeController,
//                                   hintText: '${'search'.tr}...',
//                                   inputDecorationTheme:
//                                   InputDecorationTheme(
//                                     // filled: true,
//                                     hintStyle: const TextStyle(
//                                         fontStyle: FontStyle.italic),
//                                     contentPadding:
//                                     const EdgeInsets.fromLTRB(
//                                         20, 0, 25, 5),
//                                     // outlineBorder: BorderSide(color: Colors.black,),
//                                     enabledBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Primary.primary
//                                               .withAlpha((0.2 * 255).toInt()),
//                                           width: 1),
//                                       borderRadius:
//                                       const BorderRadius.all(
//                                           Radius.circular(9)),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(
//                                           color: Primary.primary
//                                               .withAlpha((0.4 * 255).toInt()),
//                                           width: 2),
//                                       borderRadius:
//                                       const BorderRadius.all(
//                                           Radius.circular(9)),
//                                     ),
//                                   ),
//                                   // menuStyle: ,
//                                   menuHeight: 250,
//                                   dropdownMenuEntries:
//                                   customerNumberList.map<
//                                       DropdownMenuEntry<
//                                           String>>(
//                                           (String option) {
//                                         return DropdownMenuEntry<String>(
//                                           value: option,
//                                           label: option,
//                                         );
//                                       }).toList(),
//                                   enableFilter: true,
//                                   onSelected: (String? val) {
//                                     quotationController
//                                         .getFieldsForCreateQuotationFromBack();
//                                     setState(() {
//                                       searchController =
//                                           quotationController
//                                               .nameController;
//                                     });
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           quotationCont.name[indexNum] == null
//                               ? SizedBox(
//                             width: MediaQuery.of(context).size.width *
//                                 0.516,
//                             child: Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment:
//                               CrossAxisAlignment.center,
//                               children: [
//                                 // Text('${'name'.tr}'),
//                                 ReusableDropDownMenuWithSearch(
//                                   list: customerNameList,
//                                   text: 'name'.tr,
//                                   hint: '${'search'.tr}...',
//                                   controller: searchController,
//                                   onSelected: (String? val) {
//                                     quotationController
//                                         .getFieldsForCreateQuotationFromBack();
//                                     setState(() {
//                                       selectedItem = val!;
//                                       var index = customerNameList
//                                           .indexOf(val);
//                                       selectedCustomerIds =
//                                       customerIdsList[index];
//
//                                       codeController =
//                                           quotationController
//                                               .codeController;
//                                     });
//                                     quotationController
//                                         .getClientEmail(int.parse(
//                                         selectedCustomerIds));
//                                   },
//                                   validationFunc: (value) {
//                                     if (value == null ||
//                                         value.isEmpty) {
//                                       return 'select_option'.tr;
//                                     }
//                                     return null;
//                                   },
//                                   rowWidth: MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                       0.516,
//                                   textFieldWidth:
//                                   MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                       0.48,
//                                   clickableOptionText:
//                                   'create_new_client'.tr,
//                                   isThereClickableOption: true,
//                                   onTappedClickableOption: () {
//                                     showDialog<String>(
//                                         context: context,
//                                         builder: (BuildContext
//                                         context) =>
//                                         const AlertDialog(
//                                             backgroundColor:
//                                             Colors.white,
//                                             shape:
//                                             RoundedRectangleBorder(
//                                               borderRadius:
//                                               BorderRadius
//                                                   .all(Radius
//                                                   .circular(
//                                                   9)),
//                                             ),
//                                             elevation: 0,
//                                             content:
//                                             CreateClientDialog()));
//                                   },
//                                 )
//                               ],
//                             ),
//                           )
//                               : SizedBox(
//                             width: MediaQuery.of(context).size.width *
//                                 0.516,
//                             child: Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment:
//                               CrossAxisAlignment.center,
//                               children: [
//                                 // Text('${'na'.tr}'),
//                                 ReusableDropDownMenuWithSearch(
//                                   list: customerNameList,
//                                   text: 'name'.tr,
//                                   hint: '${'search'.tr}...',
//                                   controller: searchController,
//                                   onSelected: (String? val) {
//                                     quotationController
//                                         .getFieldsForCreateQuotationFromBack();
//                                     setState(() {
//                                       codeController =
//                                           quotationController
//                                               .codeController;
//                                     });
//                                   },
//                                   validationFunc: (value) {
//                                     if (value == null ||
//                                         value.isEmpty) {
//                                       return 'select_option'.tr;
//                                     }
//                                     return null;
//                                   },
//                                   rowWidth: MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                       0.516,
//                                   textFieldWidth:
//                                   MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                       0.48,
//                                   clickableOptionText:
//                                   'create_new_client'.tr,
//                                   isThereClickableOption: true,
//                                   onTappedClickableOption: () {
//                                     showDialog<String>(
//                                         context: context,
//                                         builder: (BuildContext
//                                         context) =>
//                                         const AlertDialog(
//                                             backgroundColor:
//                                             Colors.white,
//                                             shape:
//                                             RoundedRectangleBorder(
//                                               borderRadius:
//                                               BorderRadius
//                                                   .all(Radius
//                                                   .circular(
//                                                   9)),
//                                             ),
//                                             elevation: 0,
//                                             content:
//                                             CreateClientDialog()));
//                                   },
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       gapH16,
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 0.3,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text('${'address'.tr} :',
//                                         style:
//                                         const TextStyle(fontSize: 12)),
//                                     gapW10,
//                                     (quotationCont.country[
//                                     selectedCustomerIds] ==
//                                         null &&
//                                         quotationCont.city[
//                                         selectedCustomerIds] ==
//                                             null)
//                                         ? const Text('',
//                                         style: TextStyle(fontSize: 12))
//                                         : Row(
//                                       children: [
//                                         Text(
//                                             "${quotationCont.country[selectedCustomerIds]} ",
//                                             style: const TextStyle(
//                                                 fontSize: 12)),
//                                         quotationCont.city[
//                                         selectedCustomerIds] ==
//                                             null
//                                             ? const Text('',
//                                             style: TextStyle(
//                                                 fontSize: 12))
//                                             : Text(
//                                             " ${quotationCont.city[selectedCustomerIds]}",
//                                             style:
//                                             const TextStyle(
//                                                 fontSize: 12))
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 gapH6,
//                                 Row(
//                                   children: [
//                                     Text('Tel'.tr,
//                                         style:
//                                         const TextStyle(fontSize: 12)),
//                                     gapW10,
//                                     quotationCont.phoneNumber[
//                                     selectedCustomerIds] ==
//                                         null
//                                         ? const Text('',
//                                         style: TextStyle(fontSize: 12))
//                                         : Text(
//                                         "${quotationCont.phoneNumber[selectedCustomerIds]}",
//                                         style: const TextStyle(
//                                             fontSize: 12)),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           gapW16,
//                           //vat exempt
//                           SizedBox(
//                               width:
//                               MediaQuery.of(context).size.width * 0.4,
//                               child: Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                         child: ListTile(
//                                           title: Text('Vat exempt'.tr,
//                                               style: const TextStyle(
//                                                   fontSize: 12)),
//                                           leading: Checkbox(
//                                             // checkColor: Colors.white,
//                                             // fillColor: MaterialStateProperty.resolveWith(getColor),
//                                             value: isVatExemptChecked,
//                                             onChanged: (bool? value) {
//                                               setState(() {
//                                                 isVatExemptChecked = value!;
//                                               });
//                                             },
//                                           ),
//                                         )),
//                                     isVatExemptChecked == false
//                                         ? DropdownMenu<String>(
//                                       width: MediaQuery.of(context)
//                                           .size
//                                           .width *
//                                           0.25,
//                                       // requestFocusOnTap: false,
//                                       enableSearch: true,
//                                       controller: vatExemptController,
//                                       hintText: '',
//                                       inputDecorationTheme:
//                                       InputDecorationTheme(
//                                         // filled: true,
//                                         hintStyle: const TextStyle(
//                                             fontStyle:
//                                             FontStyle.italic),
//                                         contentPadding:
//                                         const EdgeInsets.fromLTRB(
//                                             20, 0, 25, 5),
//                                         // outlineBorder: BorderSide(color: Colors.black,),
//                                         enabledBorder:
//                                         OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                               color: Primary.primary
//                                                   .withAlpha((0.2 * 255).toInt()),
//                                               width: 1),
//                                           borderRadius:
//                                           const BorderRadius.all(
//                                               Radius.circular(9)),
//                                         ),
//                                         focusedBorder:
//                                         OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                               color: Primary.primary
//                                                   .withAlpha((0.4 * 255).toInt()),
//                                               width: 2),
//                                           borderRadius:
//                                           const BorderRadius.all(
//                                               Radius.circular(9)),
//                                         ),
//                                       ),
//                                       // menuStyle: ,
//                                       menuHeight: 250,
//                                       dropdownMenuEntries:
//                                       vatExemptListTrue.map<
//                                           DropdownMenuEntry<
//                                               String>>(
//                                               (String option) {
//                                             return DropdownMenuEntry<
//                                                 String>(
//                                               value: option,
//                                               label: option,
//                                             );
//                                           }).toList(),
//                                       enableFilter: true,
//                                       onSelected: (String? val) {
//                                         setState(() {
//                                           if (val ==
//                                               'prices are before vat') {
//                                             isBeforeVatPrices = true;
//                                             isVatInclusivePrices =
//                                             false;
//                                           } else {
//                                             isBeforeVatPrices = false;
//                                             isVatInclusivePrices =
//                                             true;
//                                           }
//                                         });
//                                       },
//                                     )
//                                         : DropdownMenu<String>(
//                                       width: MediaQuery.of(context)
//                                           .size
//                                           .width *
//                                           0.25,
//                                       // requestFocusOnTap: false,
//                                       enableSearch: true,
//                                       controller: vatExemptController,
//                                       hintText: '',
//                                       inputDecorationTheme:
//                                       InputDecorationTheme(
//                                         // filled: true,
//                                         hintStyle: const TextStyle(
//                                             fontStyle:
//                                             FontStyle.italic),
//                                         contentPadding:
//                                         const EdgeInsets.fromLTRB(
//                                             20, 0, 25, 5),
//                                         // outlineBorder: BorderSide(color: Colors.black,),
//                                         enabledBorder:
//                                         OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                               color: Primary.primary
//                                                   .withAlpha((0.2 * 255).toInt()),
//                                               width: 1),
//                                           borderRadius:
//                                           const BorderRadius.all(
//                                               Radius.circular(9)),
//                                         ),
//                                         focusedBorder:
//                                         OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                               color: Primary.primary
//                                                   .withAlpha((0.4 * 255).toInt()),
//                                               width: 2),
//                                           borderRadius:
//                                           const BorderRadius.all(
//                                               Radius.circular(9)),
//                                         ),
//                                       ),
//                                       // menuStyle: ,
//                                       menuHeight: 250,
//                                       dropdownMenuEntries:
//                                       vatExemptListFalse.map<
//                                           DropdownMenuEntry<
//                                               String>>(
//                                               (String option) {
//                                             return DropdownMenuEntry<
//                                                 String>(
//                                               value: option,
//                                               label: option,
//                                             );
//                                           }).toList(),
//                                       enableFilter: true,
//                                       onSelected: (String? val) {
//                                         setState(() {
//                                           if (val ==
//                                               'exempted from vat ,printed as "vat exempted"') {
//                                             isPrintedAsVatExempt =
//                                             true;
//                                             isPrintedAsPercentage =
//                                             false;
//                                             isVatNoPrinted = false;
//                                           } else if (val ==
//                                               'exempted from vat ,printed as "vat 0 % = 0"') {
//                                             isPrintedAsVatExempt =
//                                             false;
//                                             isPrintedAsPercentage =
//                                             true;
//                                             isVatNoPrinted = false;
//                                           } else {
//                                             isPrintedAsVatExempt =
//                                             false;
//                                             isPrintedAsPercentage =
//                                             false;
//                                             isVatNoPrinted = true;
//                                           }
//                                         });
//                                       },
//                                     ),
//                                   ]))
//                         ],
//                       ),
//                       gapH16,
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 0.3,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text('Email'.tr,
//                                         style:
//                                         const TextStyle(fontSize: 12)),
//                                     gapW10,
//                                     quotationCont.email[
//                                     selectedCustomerIds] ==
//                                         null
//                                         ? const Text('',
//                                         style: TextStyle(fontSize: 12))
//                                         : Text(
//                                         "${quotationCont.email[selectedCustomerIds]}",
//                                         style: const TextStyle(
//                                             fontSize: 12)),
//                                   ],
//                                 ),
//                                 gapH6,
//                                 Row(
//                                   children: [
//                                     Text('Vat'.tr,
//                                         style:
//                                         const TextStyle(fontSize: 12)),
//                                     gapW10,
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           gapW16,
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 gapH16,
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Wrap(
//                         spacing: 0.0,
//                         direction: Axis.horizontal,
//                         children: tabsList
//                             .map((element) => _buildTabChipItem(
//                             element,
//                             // element['id'],
//                             // element['name'],
//                             tabsList.indexOf(element)))
//                             .toList()),
//                   ],
//                 ),
//                 // tabsContent[selectedTabIndex],
//                 selectedTabIndex == 0
//                     ? Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         // horizontal:
//                         //     MediaQuery.of(context).size.width * 0.01,
//                           vertical: 15),
//                       decoration: BoxDecoration(
//                           color: Primary.primary,
//                           borderRadius: const BorderRadius.all(
//                               Radius.circular(6))),
//                       child: Row(
//                         mainAxisAlignment:
//                         MainAxisAlignment.spaceBetween,
//                         children: [
//                           TableTitle(
//                             text: 'item_code'.tr,
//                             width: MediaQuery.of(context).size.width *
//                                 0.14,
//                           ),
//                           TableTitle(
//                             text: 'description'.tr,
//                             width: MediaQuery.of(context).size.width *
//                                 0.28,
//                           ),
//                           TableTitle(
//                             text: 'quantity'.tr,
//                             width: MediaQuery.of(context).size.width *
//                                 0.04,
//                           ),
//                           TableTitle(
//                             text: 'unit_price'.tr,
//                             width: MediaQuery.of(context).size.width *
//                                 0.05,
//                           ),
//                           TableTitle(
//                             text: '${'disc'.tr}. %',
//                             width: MediaQuery.of(context).size.width *
//                                 0.05,
//                           ),
//                           TableTitle(
//                             text: 'total'.tr,
//                             width: MediaQuery.of(context).size.width *
//                                 0.05,
//                           ),
//                           TableTitle(
//                             text: 'more_options'.tr,
//                             width: MediaQuery.of(context).size.width *
//                                 0.07,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal:
//                           MediaQuery.of(context).size.width *
//                               0.01),
//                       decoration: const BoxDecoration(
//                         borderRadius: BorderRadius.only(
//                             bottomLeft: Radius.circular(6),
//                             bottomRight: Radius.circular(6)),
//                         color: Colors.white,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: quotationCont
//                                 .listViewLengthInQuotation,
//                             child: ListView(
//                               // children: quotationCont
//                               //     .orderLinesQuotationList.values
//                               //     .toList(),
//                               children: keysList.map((key) {
//                                 return Dismissible(
//                                     key: Key(key), // Ensure each widget has a unique key
//                                     onDismissed: (direction) => quotationCont.removeFromOrderLinesInQuotationList(key.toString()),
//                                     child: quotationCont.orderLinesQuotationList[key]??const SizedBox());
//                               }).toList(),
//                             ),
//                             // child: ListView.builder(
//                             //     padding: const EdgeInsets.symmetric(
//                             //         vertical: 10),
//                             //     itemCount: cont.orderLinesQuotationList.length,
//                             //     itemBuilder: (context, index) {
//                             //       var keys = cont
//                             //           .orderLinesQuotationList.keys
//                             //           .toList();
//                             //       return cont.orderLinesQuotationList[keys[index]];
//                             //     }),
//                           ),
//                           // }),
//
//                           Row(
//                             children: [
//                               ReusableAddCard(
//                                 text: 'title'.tr,
//                                 onTap: () {
//                                   setState(() {
//                                     addTitle = true;
//                                     addItem = false;
//                                   });
//                                   addNewTitle();
//                                 },
//                               ),
//                               gapW32,
//                               ReusableAddCard(
//                                 text: 'item'.tr,
//                                 onTap: () {
//                                   setState(() {
//                                     addItem = true;
//                                   });
//                                   addNewItem();
//                                 },
//                               ),
//                               gapW32,
//                               ReusableAddCard(
//                                 text: 'combo'.tr,
//                                 onTap: () {
//                                   // addNewCombo();
//                                 },
//                               ),
//                               gapW32,
//                               ReusableAddCard(
//                                 text: 'image'.tr,
//                                 onTap: () {
//                                   // addNewImage();
//                                 },
//                               ),
//                               gapW32,
//                               ReusableAddCard(
//                                 text: 'note'.tr,
//                                 onTap: () {
//                                   // addNewNote();
//                                 },
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                     gapH24,
//
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 20, horizontal: 40),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'terms_conditions'.tr,
//                             style: TextStyle(
//                                 fontSize: 15,
//                                 color: TypographyColor.titleTable,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           gapH16,
//                           ReusableTextField(
//                             textEditingController:
//                             termsAndConditionsController, //todo
//                             isPasswordField: false,
//                             hint: 'terms_conditions'.tr,
//                             onChangedFunc: (val) {},
//                             validationFunc: (val) {
//                               setState(() {
//                                 termsAndConditions = val;
//                               });
//                             },
//                           ),
//                           gapH16,
//                           Text(
//                             'or_create_new_terms_conditions'.tr,
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 color: Primary.primary,
//                                 decoration: TextDecoration.underline,
//                                 fontStyle: FontStyle.italic),
//                           ),
//                         ],
//                       ),
//                     ),
//
//
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 20, horizontal: 40),
//                       decoration: BoxDecoration(
//                         color: Primary.p20,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width *
//                                 0.4,
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text('total_before_vat'.tr),
//                                     // ReusableShowInfoCard(text: '${quotationController.totalQuotation}', width: MediaQuery.of(context).size.width * 0.1),
//
//                                     ReusableShowInfoCard(
//                                         text: quotationCont.totalItems
//                                             .toStringAsFixed(2),
//                                         width: MediaQuery.of(context)
//                                             .size
//                                             .width *
//                                             0.1)
//                                   ],
//                                 ),
//                                 gapH6,
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text('global_disc'.tr),
//                                     Row(
//                                       children: [
//                                         SizedBox(
//                                             width:
//                                             MediaQuery.of(context)
//                                                 .size
//                                                 .width *
//                                                 0.1,
//                                             child:
//                                             ReusableNumberField(
//                                               textEditingController:
//                                               globalDiscPercentController,
//                                               isPasswordField: false,
//                                               isCentered: true,
//                                               hint: '0',
//                                               onChangedFunc: (val) {
//                                                 // totalAllItems =
//                                                 //     quotationController
//                                                 //         .totalItems ;
//
//                                                 setState(() {
//                                                   if (val == '') {
//                                                     globalDiscPercentController
//                                                         .text = '0';
//                                                     globalDiscountPercentage =
//                                                     '0';
//                                                   } else {
//                                                     globalDiscountPercentage =
//                                                         val;
//                                                   }
//                                                 });
//                                                 quotationCont
//                                                     .setGlobalDisc(
//                                                     globalDiscountPercentage);
//                                                 // cont.getTotalItems();
//                                               },
//                                               validationFunc:
//                                                   (val) {},
//                                             )),
//                                         gapW10,
//                                         ReusableShowInfoCard(
//                                             text: quotationCont
//                                                 .globalDisc,
//                                             width:
//                                             MediaQuery.of(context)
//                                                 .size
//                                                 .width *
//                                                 0.1),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                                 gapH6,
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text('special_disc'.tr),
//                                     Row(
//                                       children: [
//                                         SizedBox(
//                                             width:
//                                             MediaQuery.of(context)
//                                                 .size
//                                                 .width *
//                                                 0.1,
//                                             child:
//                                             ReusableNumberField(
//                                               textEditingController:
//                                               specialDiscPercentController,
//                                               isPasswordField: false,
//                                               isCentered: true,
//                                               hint: '0',
//                                               onChangedFunc: (val) {
//                                                 setState(() {
//                                                   if (val == '') {
//                                                     specialDiscPercentController
//                                                         .text = '0';
//                                                     specialDiscountPercentage =
//                                                     '0';
//                                                   } else {
//                                                     specialDiscountPercentage =
//                                                         val;
//                                                   }
//                                                 });
//                                                 quotationCont
//                                                     .setSpecialDisc(
//                                                     specialDiscountPercentage);
//                                               },
//                                               validationFunc:
//                                                   (val) {},
//                                             )),
//                                         gapW10,
//                                         ReusableShowInfoCard(
//                                             text: quotationCont
//                                                 .specialDisc,
//                                             width:
//                                             MediaQuery.of(context)
//                                                 .size
//                                                 .width *
//                                                 0.1),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                                 gapH6,
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text('vat_11'.tr),
//                                     Row(
//                                       children: [
//                                         ReusableShowInfoCard(
//                                             text:
//                                             quotationCont.vat11LBP
//                                             // .toString(),
//                                             ,
//                                             width:
//                                             MediaQuery.of(context)
//                                                 .size
//                                                 .width *
//                                                 0.1),
//                                         gapW10,
//                                         ReusableShowInfoCard(
//                                             text: quotationCont.vat11
//                                             // .toString(),
//                                             ,
//                                             width:
//                                             MediaQuery.of(context)
//                                                 .size
//                                                 .width *
//                                                 0.1),
//
//                                         // Container(
//                                         //   width:
//                                         //       MediaQuery.of(context)
//                                         //               .size
//                                         //               .width *
//                                         //           0.1,
//                                         //   height: 47,
//                                         //   decoration: BoxDecoration(
//                                         //       border: Border.all(
//                                         //           color: Colors.black
//                                         //               .withOpacity(
//                                         //                   0.1),
//                                         //           width: 1),
//                                         //       borderRadius:
//                                         //           BorderRadius
//                                         //               .circular(6)),
//                                         //   child: const Center(
//                                         //       child: Text('0.00')),
//                                         // )
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                                 gapH10,
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'total_amount'.tr,
//                                       style: TextStyle(
//                                           fontSize: 16,
//                                           color: Primary.primary,
//                                           fontWeight:
//                                           FontWeight.bold),
//                                     ),
//                                     Text(
//                                       // '${'usd'.tr} 0.00',
//                                       '${'usd'.tr} ${quotationCont.totalQuotation}',
//                                       style: TextStyle(
//                                           fontSize: 16,
//                                           color: Primary.primary,
//                                           fontWeight:
//                                           FontWeight.bold),
//                                     )
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     gapH28,
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         ReusableButtonWithColor(
//                           width: MediaQuery.of(context).size.width *
//                               0.15,
//                           height: 45,
//                           onTapFunction: () async {
//                             var oldKeys = quotationController.rowsInListViewInQuotation.keys.toList()..sort();
//                             for (int i = 0; i < oldKeys.length; i++) {
//                               quotationController.newRow[i + 1] = quotationController.rowsInListViewInQuotation[oldKeys[i]]!;
//                             }
//
//                             var res = await storeQuotations(
//                               refController.text,
//                               selectedCustomerIds,
//                               validityController.text,
//                               '',
//                               '',
//                               selectedCurrencyId, //selectedCurrency
//                               termsAndConditionsController.text,
//                               '',
//                               '',
//                               '',
//                               commissionController.text,
//                               totalCommissionController.text,
//                               quotationController.totalItems
//                                   .toString(), //total before vat
//                               specialDiscPercentController
//                                   .text, // inserted by user
//                               quotationController
//                                   .specialDisc, // calculated
//                               globalDiscPercentController.text,
//                               quotationController.globalDisc,
//                               quotationController.vat11
//                                   .toString(), //vat
//                               quotationController.vat11LBP.toString(),
//                               quotationController
//                                   .totalQuotation, // quotationController.totalQuotation
//
//                               isVatExemptChecked ? '1' : '0',
//                               isVatNoPrinted ? '1' : '0',
//                               isPrintedAsVatExempt ? '1' : '0',
//                               isPrintedAsPercentage ? '1' : '0',
//                               isVatInclusivePrices ? '1' : '0',
//                               isBeforeVatPrices ? '1' : '0',
//                               codeController.text,
//                               // quotationController.rowsInListViewInQuotation,
//                               quotationController.newRow,
//
//                               titleController.text,
//                               // ''
//                             );
//                             if (res['success'] == true) {
//                               // quotationController.setIsSubmitAndPreviewClicked(true);
//
//                               CommonWidgets.snackBar(
//                                   'Success', res['message']);
//                               setState(() {
//                                 isQuotationsInfoFetched = false;
//                                 quotationController
//                                     .getFieldsForCreateQuotationFromBack();
//                               });
//                               homeController.selectedTab.value =
//                               'quotation_summary';
//                             } else {
//                               CommonWidgets.snackBar(
//                                   'error', res['message']);
//                             }
//                           },
//                           btnText: 'create_quotation'.tr,
//                         ),
//                       ],
//                     )
//                   ],
//                 )
//                     : Container(
//                   padding: EdgeInsets.symmetric(
//                       horizontal:
//                       MediaQuery.of(context).size.width * 0.04,
//                       vertical: 15),
//                   decoration: const BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(6),
//                         bottomRight: Radius.circular(6)),
//                     color: Colors.white,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                           width: MediaQuery.of(context).size.width *
//                               0.35,
//                           child: Column(
//                             children: [
//                               DialogDropMenu(
//                                 optionsList: const [''],
//                                 text: 'sales_person'.tr,
//                                 hint: 'search'.tr,
//                                 rowWidth: MediaQuery.of(context)
//                                     .size
//                                     .width *
//                                     0.3,
//                                 textFieldWidth: MediaQuery.of(context)
//                                     .size
//                                     .width *
//                                     0.15,
//                                 onSelected: () {},
//                               ),
//                               gapH16,
//                               DialogDropMenu(
//                                 optionsList: const [''],
//                                 text: 'commission_method'.tr,
//                                 hint: '',
//                                 rowWidth: MediaQuery.of(context)
//                                     .size
//                                     .width *
//                                     0.3,
//                                 textFieldWidth: MediaQuery.of(context)
//                                     .size
//                                     .width *
//                                     0.15,
//                                 onSelected: () {},
//                               ),
//                               gapH16,
//                               DialogDropMenu(
//                                 optionsList: ['cash'.tr],
//                                 text: 'cashing_method'.tr,
//                                 hint: '',
//                                 rowWidth: MediaQuery.of(context)
//                                     .size
//                                     .width *
//                                     0.3,
//                                 textFieldWidth: MediaQuery.of(context)
//                                     .size
//                                     .width *
//                                     0.15,
//                                 onSelected: () {},
//                               ),
//                             ],
//                           )),
//                       SizedBox(
//                           width:
//                           MediaQuery.of(context).size.width * 0.3,
//                           child: Column(
//                             mainAxisAlignment:
//                             MainAxisAlignment.start,
//                             children: [
//                               DialogTextField(
//                                 textEditingController:
//                                 commissionController,
//                                 text: 'commission'.tr,
//                                 rowWidth: MediaQuery.of(context)
//                                     .size
//                                     .width *
//                                     0.3,
//                                 textFieldWidth: MediaQuery.of(context)
//                                     .size
//                                     .width *
//                                     0.15,
//                                 validationFunc: (val) {},
//                               ),
//                               gapH16,
//                               DialogTextField(
//                                 textEditingController:
//                                 totalCommissionController,
//                                 text: 'total_commission'.tr,
//                                 rowWidth: MediaQuery.of(context)
//                                     .size
//                                     .width *
//                                     0.3,
//                                 textFieldWidth: MediaQuery.of(context)
//                                     .size
//                                     .width *
//                                     0.15,
//                                 validationFunc: (val) {},
//                               ),
//                             ],
//                           )),
//                     ],
//                   ),
//                 ),
//                 gapH40,
//               ],
//             ),
//           ),
//         );
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
//   bool addTitle = false;
//   bool addItem = false;
//   TextEditingController titleController = TextEditingController();
//   String titleValue = '';
//   int quotationCounter = 0;
//   addNewTitle() {
//     setState(() {
//       quotationCounter += 1;
//     });
//     quotationController
//         .incrementListViewLengthInQuotation(quotationController.increment);
//     // int index = quotationController.orderLinesQuotationList.length + 1;
//     quotationController.addToRowsInListViewInQuotation(quotationCounter, {
//       'line_type_id': '',
//       'item_id': '',
//       'itemName': '',
//       'item_discount': '0',
//       'item_description': '',
//       'item_quantity': '0',
//       'item_unit_price': '0',
//       'item_total': '0',
//       'title': '',
//     });
//     Widget p = ReusableTitleRow(index: quotationCounter);
//
//     quotationController.addToOrderLinesInQuotationList('$quotationCounter', p);
//   }
//
//   addNewItem() {
//     setState(() {
//       quotationCounter += 1;
//     });
//     quotationController
//         .incrementListViewLengthInQuotation(quotationController.increment);
//
//     // int index = quotationController.orderLinesQuotationList.length + 1;
//
//     quotationController.addToRowsInListViewInQuotation(quotationCounter, {
//       'line_type_id': '',
//       'item_id': '',
//       'itemName': '',
//       'item_discount': '0',
//       'item_description': '',
//       'item_quantity': '0',
//       'item_unit_price': '0',
//       'item_total': '0',
//       'title': '',
//     });
//     Widget p = ReusableItemRow(index: quotationCounter);
//
//     quotationController.addToOrderLinesInQuotationList('$quotationCounter', p);
//   }
//
//   addNewCombo() {
//     setState(() {
//       listViewLength = listViewLength + increment;
//     });
//     Widget p = const ReusableComboRow();
//     // quotationController.addToOrderLinesList(p);
//   }
//
//   addNewImage() {
//     setState(() {
//       listViewLength = listViewLength + 100;
//     });
//     Widget p = GetBuilder<QuotationController>(builder: (cont) {
//       return InkWell(
//         onTap: () async {
//           final ImagePicker picker = ImagePicker();
//           final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//
//           if (image != null) {
//             Uint8List imageFile;
//             if (Platform.isIOS || Platform.isAndroid) {
//               imageFile = await image.readAsBytes();
//             } else {
//               return; // This part will not run on web
//             }
//           // final image = await ImagePickerWeb.getImageAsBytes();
//           setState(() {
//             
//             // imageFile = image;
//             cont.changeBoolVar(true);
//             cont.increaseImageSpace(90);
//             listViewLength = listViewLength + (cont.imageSpaceHeight) + 10;
//           });
//         }},
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//           child: DottedBorder(
//             dashPattern: const [10, 10],
//             color: Others.borderColor,
//             radius: const Radius.circular(9),
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.63,
//               height: cont.imageSpaceHeight,
//               child: cont.imageAvailable
//                   ? Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Image.memory(
//                     imageFile,
//                     height: cont.imageSpaceHeight,
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
//     // quotationController.addToOrderLinesList(p);
//   }
//
//   addNewNote() {
//     setState(() {
//       listViewLength = listViewLength + increment;
//     });
//     Widget p = Container(
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
// class UnderTitleBtn extends StatelessWidget {
//   const UnderTitleBtn({super.key, required this.text, required this.onTap});
//   final String text;
//   final Function onTap;
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         onTap();
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         margin: EdgeInsets.only(
//           right: MediaQuery.of(context).size.width * 0.009,
//         ),
//         decoration: BoxDecoration(
//             color: Others.btnBg,
//             borderRadius: const BorderRadius.all(Radius.circular(9))),
//         child: Text(
//           text,
//           style: TextStyle(
//             color: TypographyColor.titleTable,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ReusableItemRow extends StatefulWidget {
//   // const ReusableItemRow({super.key});
//   const ReusableItemRow({super.key, required this.index});
//   // const ReusableItemRow({super.key, required this.index, required this.info});
//   final int index;
//   // final Map info;
//   @override
//   State<ReusableItemRow> createState() => _ReusableItemRowState();
// }
//
// class _ReusableItemRowState extends State<ReusableItemRow> {
//   String unitPrice = '0', discount = '0', result = '0', quantity = '0';
//
//   String qty = '0';
//
//   TextEditingController itemCodeController = TextEditingController();
//   TextEditingController qtyController = TextEditingController();
//   TextEditingController unitPriceController = TextEditingController();
//   TextEditingController discountController = TextEditingController();
//
//   final QuotationController quotationController = Get.find();
//   List<String> itemsList = [];
//   String selectedItemId = '';
//   int selectedItem = 0;
//   bool isDataFetched = false;
//
//   bool isQuotationsInfoFetched = false;
//   List items = [];
//   String quotationNumber = '';
//
//   resetDataQuotationFromBack() async {
//     var p = await getFieldsForCreateQuotation();
//     items = p['items'];
//     if ('$p' != '[]') {
//       setState(() {
//         // selectedItem = selectedItemId.indexOf(selectedItemId);
//         // unitPriceController.text = '${items[selectedItem]['unitCost'] ?? '0'}';
//         quotationController.setEnteredUnitPriceInQuotation(
//             widget.index, unitPriceController.text);
//         quotationController.setEnteredDiscInQuotation(
//             widget.index, discountController.text);
//
//         // quotationController.setMainDescriptionInQuotation(
//         //     widget.index, items[selectedItem]['mainDescription'] ?? '');
//         // quotationController.setMainDescriptionInQuotation( widget.index, items[selectedItem]['description'] ?? '');
//
//         quotationController.setMainDescriptionInQuotation(
//             widget.index, quotationController.itemsMap[selectedItemId] ?? '');
//         isDataFetched = true;
//       });
//     }
//   }
//
//   String mainDescriptionVar = '';
//   String totalLine = '0';
//   Map warehouseData = {};
//   bool isSelected = false;
//
//   final focus = FocusNode();
//   final focus1 = FocusNode();
//
//   final _formKey = GlobalKey<FormState>();
//   @override
//   void initState() {
//     quotationController.getFieldsForCreateQuotationFromBack();
//     quotationController.getDataQuotationFromBack();
//
//     unitPrice = '0';
//     discount = '0';
//     quantity = '0';
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<QuotationController>(builder: (cont) {
//       return Container(
//         margin: const EdgeInsets.symmetric(
//           vertical: 5,
//         ),
//         child: Form(
//           key: _formKey,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               //image
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
//
//               // item code
//               DropdownMenu<String>(
//                 width: MediaQuery.of(context).size.width * 0.12,
//                 // requestFocusOnTap: false,
//                 enableSearch: true,
//                 controller: itemCodeController,
//                 hintText: 'item code'.tr,
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
//                 // itemsList
//                 dropdownMenuEntries: cont.itemsNames
//                     .map<DropdownMenuEntry<String>>((String option) {
//                   return DropdownMenuEntry<String>(
//                     value: option,
//                     label: option,
//                   );
//                 }).toList(),
//                 enableFilter: true,
//                 // requestFocusOnTap: isSelected=true,
//                 onSelected: (String? value) async {
//                   itemCodeController.text = value!;
//                   // isSelected=true;
//                   setState(() {
//                     selectedItemId =
//                     '${cont.itemsIds[cont.itemsNames.indexOf(value)]}';
//                     mainDescriptionVar = cont.itemsMap[selectedItemId];
//                     // warehouseData = cont.whInfo;
//                   });
//
//                   cont.setItemIdInQuotation(widget.index, selectedItemId);
//                   cont.setItemNameInQuotation(widget.index, value);
//                   cont.setTypeInQuotation(widget.index, '2');
//                   cont.setMainDescriptionInQuotation(
//                       widget.index, mainDescriptionVar);
//
//                   await cont.getWarehousesForItem(selectedItemId);
//                   setState(() {
//                     warehouseData = cont.whInfo;
//                   });
//                 },
//               ),
//               //description
//               ReusableShowInfoCard(
//                   text: mainDescriptionVar,
//                   width: MediaQuery.of(context).size.width * 0.25),
//               //quantity
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.06,
//
//                 child: TextFormField(
//                   onFieldSubmitted: (value) {
//                     FocusScope.of(context).requestFocus(focus);
//                   },
//                   textAlign: TextAlign.center,
//                   controller: qtyController,
//                   cursorColor: Colors.black,
//                   decoration: InputDecoration(
//                     hintText: "".tr,
//                     // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
//                       borderRadius: const BorderRadius.all(Radius.circular(6)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
//                       borderRadius: const BorderRadius.all(Radius.circular(6)),
//                     ),
//                     errorStyle: const TextStyle(
//                       fontSize: 10.0,
//                     ),
//                     focusedErrorBorder: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(6)),
//                       borderSide: BorderSide(width: 1, color: Colors.red),
//                     ),
//                   ),
//                   validator: (String? value) {
//                     if (value!.isEmpty || double.parse(value) <= 0) {
//                       return 'must be >0';
//                     }
//                     return null;
//                   },
//                   keyboardType: const TextInputType.numberWithOptions(
//                     decimal: false,
//                     signed: true,
//                   ),
//                   inputFormatters: <TextInputFormatter>[
//                     FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
//                     // WhitelistingTextInputFormatter.digitsOnly
//                   ],
//                   onChanged: (val) {
//                     setState(() {
//                       quantity = val;
//                       totalLine =
//                       '${(int.parse(quantity) * double.parse(unitPrice)) * (1 - double.parse(discount) / 100)}';
//                       // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';
//                     });
//
//                     _formKey.currentState!.validate();
//                     // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
//
//                     cont.setEnteredQtyInQuotation(widget.index, val);
//                     cont.setMainTotalInQuotation(widget.index, totalLine);
//                     // cont.setMainTotalInQuotation(widget.index, cont.totalLine.toString() );
//                     cont.getTotalItems();
//                   },
//                 ),
//
//                 // ReusableNumberField(
//                 //   textEditingController: qtyController,
//                 //   isPasswordField: false,
//                 //   isCentered: true,
//                 //   hint: '0',
//                 //   onChangedFunc: (val) {
//                 //     setState(() {
//                 //       quantity = val;
//                 //       myTotal =
//                 //           '${int.parse(quantity) * (int.parse(unitPrice) - int.parse(discount))}';
//                 //       // myTotal='${int.parse(cont.quantity) * (int.parse(cont.unitPrice) - int.parse(cont.discount))}';
//                 //     });
//                 //     _formKey.currentState!.validate();
//                 //     cont.setEnteredQtyInQuotation(widget.index, val);
//                 //
//                 //     cont.setMainTotalInQuotation(widget.index, myTotal);
//                 //     cont.getTotalItems();
//                 //   },
//                 //   validationFunc: (String? value) {
//                 //     if (value!.isEmpty || double.parse(value) <= 0) {
//                 //       return 'must be >0';
//                 //     }
//                 //     return null;
//                 //   },
//                 // )
//               ),
//               // unitPrice
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.05,
//                 // child: ReusableNumberField(
//                 //   textEditingController: unitPriceController,
//                 //   isPasswordField: false,
//                 //   isCentered: true,
//                 //   hint: '0',
//                 //   onChangedFunc: (val) {
//                 //     setState(() {
//                 //       unitPrice = val;
//                 //       myTotal =
//                 //           '${int.parse(quantity) * (int.parse(unitPrice) - int.parse(discount))}';
//                 //       // myTotal='${int.parse(cont.quantity) * (int.parse(cont.unitPrice) - int.parse(cont.discount))}';
//                 //     });
//                 //     _formKey.currentState!.validate();
//                 //     cont.setEnteredUnitPriceInQuotation(widget.index, val);
//                 //     cont.setMainTotalInQuotation(widget.index, myTotal);
//                 //     cont.getTotalItems();
//                 //   },
//                 //   validationFunc: (String? value) {
//                 //     // if( value!.isEmpty || double.parse(value)<=0 ){
//                 //     //   return 'must be >0';
//                 //     // }
//                 //     // return null;
//                 //   },
//                 // )
//                 child: TextFormField(
//                   focusNode: focus,
//                   onFieldSubmitted: (value) {
//                     FocusScope.of(context).requestFocus(focus1);
//                   },
//                   textAlign: TextAlign.center,
//                   controller: unitPriceController,
//                   cursorColor: Colors.black,
//                   decoration: InputDecoration(
//                     hintText: "".tr,
//                     // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
//                       borderRadius: const BorderRadius.all(Radius.circular(6)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
//                       borderRadius: const BorderRadius.all(Radius.circular(6)),
//                     ),
//                     errorStyle: const TextStyle(
//                       fontSize: 10.0,
//                     ),
//                     focusedErrorBorder: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(6)),
//                       borderSide: BorderSide(width: 1, color: Colors.red),
//                     ),
//                   ),
//                   validator: (String? value) {
//                      return null;
//                   },
//                   keyboardType: const TextInputType.numberWithOptions(
//                     decimal: false,
//                     signed: true,
//                   ),
//                   inputFormatters: <TextInputFormatter>[
//                     FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
//                     // WhitelistingTextInputFormatter.digitsOnly
//                   ],
//                   onChanged: (val) {
//                     setState(() {
//                       if (val == '') {
//                         unitPriceController.text = '0';
//                         unitPrice = '0';
//                       } else {
//                         unitPrice = val;
//                       }
//                       // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';
//                       totalLine =
//                       '${(int.parse(quantity) * double.parse(unitPrice)) * (1 - double.parse(discount) / 100)}';
//                     });
//                     _formKey.currentState!.validate();
//                     // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
//                     cont.setEnteredUnitPriceInQuotation(widget.index, val);
//                     cont.setMainTotalInQuotation(widget.index, totalLine);
//                     cont.getTotalItems();
//                   },
//                 ),
//               ),
//
//               //discount
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.05,
//                 // child: ReusableNumberField(
//                 //   textEditingController: discountController,
//                 //   isPasswordField: false,
//                 //   isCentered: true,
//                 //   hint: '0',
//                 //   onChangedFunc: (val) {
//                 //     setState(() {
//                 //       discount = val;
//                 //       myTotal =
//                 //           '${int.parse(quantity) * (int.parse(unitPrice) - int.parse(discount))}';
//                 //       // myTotal='${int.parse(cont.quantity) * (int.parse(cont.unitPrice) - int.parse(cont.discount))}';
//                 //     });
//                 //     cont.setEnteredDiscInQuotation(widget.index, val);
//                 //
//                 //     _formKey.currentState!.validate();
//                 //     cont.setMainTotalInQuotation(widget.index, myTotal);
//                 //
//                 //     cont.getTotalItems();
//                 //   },
//                 //   validationFunc: (String? value) {
//                 //     // if( value!.isEmpty || double.parse(value)<=0 ){
//                 //     //   return 'must be >0';
//                 //     // }
//                 //     // return null;
//                 //   },
//                 // )
//                 child: TextFormField(
//                   focusNode: focus1,
//                   controller: discountController,
//                   cursorColor: Colors.black,
//                   textAlign: TextAlign.center,
//                   decoration: InputDecoration(
//                     hintText: "".tr,
//                     // contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
//                       borderRadius: const BorderRadius.all(Radius.circular(6)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
//                       borderRadius: const BorderRadius.all(Radius.circular(6)),
//                     ),
//                     errorStyle: const TextStyle(
//                       fontSize: 10.0,
//                     ),
//                     focusedErrorBorder: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(6)),
//                       borderSide: BorderSide(width: 1, color: Colors.red),
//                     ),
//                   ),
//                   validator: (String? value) {
//                      return null;
//                   },
//                   keyboardType: const TextInputType.numberWithOptions(
//                     decimal: false,
//                     signed: true,
//                   ),
//                   inputFormatters: <TextInputFormatter>[
//                     FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
//                     // WhitelistingTextInputFormatter.digitsOnly
//                   ],
//                   onChanged: (val) async {
//                     setState(() {
//                       if (val == '') {
//                         discountController.text = '0';
//                         discount = '0';
//                       } else {
//                         discount = val;
//                       }
//
//                       // totalLine= '${ quantity * unitPrice *(1 - discount / 100 ) }';
//
//                       totalLine =
//                       '${(int.parse(quantity) * double.parse(unitPrice)) * (1 - double.parse(discount) / 100)}';
//                     });
//                     _formKey.currentState!.validate();
//
//                     // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
//                     cont.setEnteredDiscInQuotation(widget.index, val);
//                     cont.setMainTotalInQuotation(widget.index, totalLine);
//                     await cont.getTotalItems();
//                   },
//                 ),
//               ),
//
//               //total
//               ReusableShowInfoCard(
//                   text: double.parse(totalLine).toStringAsFixed(2),
//                   width: MediaQuery.of(context).size.width * 0.07),
//
//               //more
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.02,
//                 child: ReusableMore(itemsList: [
//                   PopupMenuItem<String>(
//                     value: '1',
//                     onTap: () async {
//                       showDialog<String>(
//                           context: context,
//                           builder: (BuildContext context) => AlertDialog(
//                             backgroundColor: Colors.white,
//                             shape: const RoundedRectangleBorder(
//                               borderRadius:
//                               BorderRadius.all(Radius.circular(9)),
//                             ),
//                             elevation: 0,
//                             content: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 //table
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 15),
//                                   decoration: BoxDecoration(
//                                       color: Primary.primary,
//                                       borderRadius: const BorderRadius.all(
//                                           Radius.circular(6))),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                     MainAxisAlignment.center,
//                                     children: [
//                                       TableTitle(
//                                         text: 'name'.tr,
//                                         width: MediaQuery.of(context)
//                                             .size
//                                             .width *
//                                             0.08,
//                                       ),
//                                       TableTitle(
//                                         text: 'quantity'.tr,
//                                         width: MediaQuery.of(context)
//                                             .size
//                                             .width *
//                                             0.07,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//
//                                 SizedBox(
//                                   height:
//                                   MediaQuery.of(context).size.height *
//                                       0.5,
//                                   width: MediaQuery.of(context).size.width *
//                                       0.5,
//                                   child: ListView.builder(
//                                       itemCount: warehouseData
//                                           .length, // data from back
//                                       itemBuilder: (context, index) {
//                                         var keys =
//                                         warehouseData.keys.toList();
//                                         return QuotationAsRowInTable(
//                                           info: warehouseData[keys[index]],
//                                           index: index,
//                                         );
//                                       }),
//                                 ),
//                               ],
//                             ),
//                           ));
//                     },
//                     child: const Text('Show Quantity'),
//                   ),
//                 ]),
//               ),
//
//               //delete
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.03,
//                 child: InkWell(
//                   onTap: () {
//                     setState(() {
//                       quotationController.decrementListViewLengthInQuotation(
//                           quotationController.increment);
//                       quotationController
//                           .removeFromRowsInListViewInQuotation(widget.index);
//                       quotationController.removeFromOrderLinesInQuotationList(
//                           widget.index.toString());
//                     });
//                     // cont.getTotalItems();
//
//                     setState(() {
//                       // if(cont.rowsInListViewInQuotation=={}){
//                       //   cont.totalItems=0.0;
//                       //   cont.globalDisc="0.0";
//                       //   cont.specialDisc="0.0";
//                       //   cont.vat11="0.0";
//                       //   cont.vat11LBP="0.0";
//                       //   cont.totalQuotation="0.0";
//                       // }
//                       cont.totalItems = 0.0;
//                       cont.globalDisc = "0.0";
//                       cont.globalDiscountPercentageValue = "0.0";
//                       cont.specialDisc = "0.0";
//                       cont.specialDiscountPercentageValue = "0.0";
//                       cont.vat11 = "0.0";
//                       cont.vat11LBP = "0.0";
//                       cont.totalQuotation = "0.0";
//
//                       // cont.getTotalItems();
//                     });
//                     if(cont.rowsInListViewInQuotation!={}){
//                       cont.getTotalItems();}
//
//                   },
//                   child: Icon(
//                     Icons.delete_outline,
//                     color: Primary.primary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }
//
// class QuotationAsRowInTable extends StatelessWidget {
//   const QuotationAsRowInTable(
//       {super.key,
//         required this.info,
//         required this.index,
//         this.isDesktop = true});
//   final Map info;
//   final int index;
//   final bool isDesktop;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.all(Radius.circular(0))),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           TableItem(
//             text: '${info['Name'] ?? ''}',
//             width: isDesktop ? MediaQuery.of(context).size.width * 0.09 : 150,
//           ),
//           TableItem(
//             text: '${info['Qty'] ?? ''}',
//             width: isDesktop ? MediaQuery.of(context).size.width * 0.09 : 150,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ReusableTitleRow extends StatefulWidget {
//   const ReusableTitleRow({super.key, required this.index});
//   // const ReusableItemRow({super.key, required this.index, required this.info});
//   final int index;
//   // final Map info;
//   @override
//   State<ReusableTitleRow> createState() => _ReusableTitleRowState();
// }
//
// class _ReusableTitleRowState extends State<ReusableTitleRow> {
//   TextEditingController titleController = TextEditingController();
//   final QuotationController quotationController = Get.find();
//   String titleValue = '0';
//   bool isDataFetched = false;
//   bool isQuotationsInfoFetched = false;
//
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     // titleController.text='0';
//
//     quotationController.getFieldsForCreateQuotationFromBack();
//     quotationController.getDataQuotationFromBack();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<QuotationController>(builder: (cont) {
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
//               SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.65,
//                   child: ReusableTextField(
//                     textEditingController: titleController,
//                     isPasswordField: false,
//                     hint: 'title'.tr,
//                     onChangedFunc: (val) {
//                       setState(() {
//                         titleValue = val;
//                       });
//                       cont.setTypeInQuotation(widget.index, '1');
//                       cont.setTitleInQuotation(widget.index, val);
//                     },
//                     validationFunc: (val) {},
//                   )),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.02,
//                 child: const ReusableMore(itemsList: [
//                   // PopupMenuItem<String>(
//                   //   value: '1',
//                   //   onTap: () async {},
//                   //   child: Row(
//                   //     children: [
//                   //       Text(''),
//                   //     ],
//                   //   ),
//                   // ),
//                 ]),
//               ),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.03,
//                 child: InkWell(
//                   onTap: () {
//                     setState(() {
//                       quotationController.decrementListViewLengthInQuotation(
//                           quotationController.increment);
//                       quotationController
//                           .removeFromRowsInListViewInQuotation(widget.index);
//                       quotationController.removeFromOrderLinesInQuotationList(
//                           widget.index.toString());
//                     });
//                   },
//                   child: Icon(
//                     Icons.delete_outline,
//                     color: Primary.primary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }
//
// class ReusableComboRow extends StatefulWidget {
//   const ReusableComboRow({super.key});
//   @override
//   State<ReusableComboRow> createState() => _ReusableComboRowState();
// }
//
// class _ReusableComboRowState extends State<ReusableComboRow> {
//   String price = '0', disc = '0', result = '0', quantity = '0';
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.63,
//       margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           DialogDropMenu(
//             optionsList: const [''],
//             text: '',
//             hint: 'combo'.tr,
//             rowWidth: MediaQuery.of(context).size.width * 0.07,
//             textFieldWidth: MediaQuery.of(context).size.width * 0.07,
//             onSelected: () {},
//           ),
//           SizedBox(
//               width: MediaQuery.of(context).size.width * 0.3,
//               child: ReusableNumberField(
//                 textEditingController: controller, //todo
//                 isPasswordField: false,
//                 hint: 'lorem ipsumlorem ipsum',
//                 onChangedFunc: () {},
//                 validationFunc: (val) {},
//               )),
//           SizedBox(
//               width: MediaQuery.of(context).size.width * 0.05,
//               child: ReusableNumberField(
//                 textEditingController: controller, //todo
//                 isPasswordField: false,
//                 hint: '1.00',
//                 onChangedFunc: (value) {
//                   setState(() {
//                     quantity = value;
//                   });
//                 },
//                 validationFunc: (val) {},
//               )),
//           SizedBox(
//               width: MediaQuery.of(context).size.width * 0.05,
//               child: ReusableNumberField(
//                 textEditingController: controller, //todo
//                 isPasswordField: false,
//                 hint: '150.00',
//                 onChangedFunc: (val) {
//                   setState(() {
//                     price = val;
//                   });
//                 },
//                 validationFunc: (val) {},
//               )),
//           SizedBox(
//               width: MediaQuery.of(context).size.width * 0.05,
//               child: ReusableNumberField(
//                 textEditingController: controller, //todo
//                 isPasswordField: false,
//                 hint: '15',
//                 onChangedFunc: (val) {
//                   setState(() {
//                     disc = val;
//                   });
//                 },
//                 validationFunc: (val) {},
//               )),
//           Container(
//             width: MediaQuery.of(context).size.width * 0.07,
//             height: 47,
//             decoration: BoxDecoration(
//                 border:
//                 Border.all(color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
//                 borderRadius: BorderRadius.circular(6)),
//             child: Center(
//                 child: Text(
//                     '${int.parse(quantity) * (int.parse(price) - int.parse(disc))}')),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class MobileCreateNewQuotation extends StatefulWidget {
//   const MobileCreateNewQuotation({super.key});
//
//   @override
//   State<MobileCreateNewQuotation> createState() =>
//       _MobileCreateNewQuotationState();
// }
//
// class _MobileCreateNewQuotationState extends State<MobileCreateNewQuotation> {
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
//   List tabsList = [
//     'order_lines',
//     'other_information',
//   ];
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
//     quotationNumber = p['quotationNumber'];
//     if ('$p' != '[]') {
//       setState(() {
//         data.addAll(p);
//         quotationNumber = p['quotationNumber'] as String;
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
//           horizontal: MediaQuery.of(context).size.width * 0.03),
//       height: MediaQuery.of(context).size.height * 0.75,
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 PageTitle(text: 'create_new_quotation'.tr),
//               ],
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
//                     id: 0,
//                     isDesktop: false,
//                     progressVar: progressVar,
//                     isFirst: true,
//                     isLast: false,
//                     isPast: true,
//                     text: 'processing'.tr),
//                 ReusableTimeLineTile(
//                     id: 1,
//                     progressVar: progressVar,
//                     isFirst: false,
//                     isDesktop: false,
//                     isLast: false,
//                     isPast: false,
//                     text: 'quotation_sent'.tr),
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
//                   horizontal: 20, vertical: 20),
//               decoration: BoxDecoration(
//                   border: Border.all(color: Others.divider),
//                   borderRadius:
//                   const BorderRadius.all(Radius.circular(9))),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   isQuotationsInfoFetched
//                       ? Text(
//                       quotationNumber, //'${data['quotationNumber'].toString() ?? ''}',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                           color: TypographyColor.titleTable))
//                       : const CircularProgressIndicator(),
//                   gapH16,
//                   DialogTextField(
//                     textEditingController: refController,
//                     text: '${'ref'.tr}:',
//                     hint: 'manual_reference'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.5,
//                     validationFunc: (val) {},
//                   ),
//                   gapH16,
//                   DialogDropMenu(
//                     optionsList: ['usd'.tr, 'lbp'.tr],
//                     text: 'currency'.tr,
//                     hint: 'usd'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.1,
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
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.5,
//                     validationFunc: (val) {},
//                   ),
//                   gapH16,
//
//                   DialogTextField(
//                     textEditingController: validityController,
//                     text: 'code'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.5,
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
//                                 fontStyle: FontStyle.italic),
//                             contentPadding:
//                             const EdgeInsets.fromLTRB(20, 0, 25, 5),
//                             // outlineBorder: BorderSide(color: Colors.black,),
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                   color: Primary.primary.withAlpha((0.2 * 255).toInt()),
//                                   width: 1),
//                               borderRadius: const BorderRadius.all(
//                                   Radius.circular(9)),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                   color: Primary.primary.withAlpha((0.4 * 255).toInt()),
//                                   width: 2),
//                               borderRadius: const BorderRadius.all(
//                                   Radius.circular(9)),
//                             ),
//                           ),
//                           // menuStyle: ,
//                           menuHeight: 250,
//                           dropdownMenuEntries: customerNameList
//                               .map<DropdownMenuEntry<String>>(
//                                   (String option) {
//                                 return DropdownMenuEntry<String>(
//                                   value: option,
//                                   label: option,
//                                 );
//                               }).toList(),
//                           enableFilter: true,
//                           onSelected: (String? val) {
//                             setState(() {
//                               selectedItem = val!;
//                               var index = customerNameList.indexOf(val);
//                               selectedCustomerIds =
//                               customerIdsList[index];
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   gapH16,
//                   // Row(
//                   //   mainAxisAlignment: MainAxisAlignment.start,
//                   //   children: [
//                   //     Text('contact_details'.tr),
//                   //   ],
//                   // ),
//                   // gapH16,
//
//                   DialogDropMenu(
//                     optionsList: ['cash'.tr, 'on_account'.tr],
//                     text: 'payment_terms'.tr,
//                     hint: 'cash'.tr,
//                     rowWidth: MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.5,
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
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.5,
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
//                     spacing: 0.0,
//                     direction: Axis.horizontal,
//                     children: tabsList
//                         .map((element) => _buildTabChipItem(
//                         element,
//                         // element['id'],
//                         // element['name'],
//                         tabsList.indexOf(element)))
//                         .toList()),
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
//                       vertical: 15),
//                   decoration: BoxDecoration(
//                       color: Primary.primary,
//                       borderRadius: const BorderRadius.all(
//                           Radius.circular(6))),
//                   child: Row(
//                     mainAxisAlignment:
//                     MainAxisAlignment.spaceBetween,
//                     children: [
//                       TableTitle(
//                         text: 'item_code'.tr,
//                         width: MediaQuery.of(context).size.width *
//                             0.07,
//                       ),
//                       TableTitle(
//                         text: 'description'.tr,
//                         width: MediaQuery.of(context).size.width *
//                             0.33,
//                       ),
//                       TableTitle(
//                         text: 'quantity'.tr,
//                         width: MediaQuery.of(context).size.width *
//                             0.05,
//                       ),
//                       TableTitle(
//                         text: 'unit_price'.tr,
//                         width: MediaQuery.of(context).size.width *
//                             0.05,
//                       ),
//                       TableTitle(
//                         text: '${'disc'.tr}. %',
//                         width: MediaQuery.of(context).size.width *
//                             0.05,
//                       ),
//                       TableTitle(
//                         text: 'total'.tr,
//                         width: MediaQuery.of(context).size.width *
//                             0.07,
//                       ),
//                       TableTitle(
//                         text: '     ${'more_options'.tr}',
//                         width: MediaQuery.of(context).size.width *
//                             0.07,
//                       ),
//                     ],
//                   ),
//                 ),
//                 GetBuilder<QuotationController>(builder: (cont) {
//                   return Container(
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
//                                 vertical: 10),
//                             itemCount: 5,
//                             // cont.orderLinesList
//                             //     .length, //products is data from back res
//                             itemBuilder: (context, index) => Row(
//                               children: [
//                                 Container(
//                                   width: 20,
//                                   height: 20,
//                                   margin:
//                                   const EdgeInsets.symmetric(
//                                       vertical: 15),
//                                   decoration: const BoxDecoration(
//                                     image: DecorationImage(
//                                       image: AssetImage(
//                                           'assets/images/newRow.png'),
//                                       fit: BoxFit.contain,
//                                     ),
//                                   ),
//                                 ),
//                                 // cont.orderLinesList[index],
//                                 SizedBox(
//                                   width: MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                       0.03,
//                                   child: const ReusableMore(
//                                     itemsList: [],
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                       0.03,
//                                   child: InkWell(
//                                     onTap: () {
//                                       setState(() {
//                                         // cont.removeFromOrderLinesList(
//                                         //     index);
//                                         listViewLength =
//                                             listViewLength -
//                                                 increment;
//                                       });
//                                     },
//                                     child: Icon(
//                                       Icons.delete_outline,
//                                       color: Primary.primary,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             ReusableAddCard(
//                               text: 'title'.tr,
//                               onTap: () {
//                                 addNewTitle();
//                               },
//                             ),
//                             gapW32,
//                             ReusableAddCard(
//                               text: 'item'.tr,
//                               onTap: () {
//                                 addNewItem();
//                               },
//                             ),
//                             gapW32,
//                             ReusableAddCard(
//                               text: 'combo'.tr,
//                               onTap: () {
//                                 addNewCombo();
//                               },
//                             ),
//                             gapW32,
//                             ReusableAddCard(
//                               text: 'image'.tr,
//                               onTap: () {
//                                 addNewImage();
//                               },
//                             ),
//                             gapW32,
//                             ReusableAddCard(
//                               text: 'note'.tr,
//                               onTap: () {
//                                 addNewNote();
//                               },
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                   );
//                 }),
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
//                                   horizontal: MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                       0.01,
//                                   vertical: 15),
//                               decoration: BoxDecoration(
//                                   color: Primary.primary,
//                                   borderRadius:
//                                   const BorderRadius.all(
//                                       Radius.circular(6))),
//                               child: Row(
//                                 children: [
//                                   TableTitle(
//                                     text: 'item_code'.tr,
//                                     width: MediaQuery.of(context)
//                                         .size
//                                         .width *
//                                         0.07,
//                                   ),
//                                   TableTitle(
//                                     text: 'description'.tr,
//                                     width: MediaQuery.of(context)
//                                         .size
//                                         .width *
//                                         0.33,
//                                   ),
//                                   TableTitle(
//                                     text: 'quantity'.tr,
//                                     width: MediaQuery.of(context)
//                                         .size
//                                         .width *
//                                         0.05,
//                                   ),
//                                   TableTitle(
//                                     text: 'unit_price'.tr,
//                                     width: MediaQuery.of(context)
//                                         .size
//                                         .width *
//                                         0.05,
//                                   ),
//                                   TableTitle(
//                                     text: '${'disc'.tr}. %',
//                                     width: MediaQuery.of(context)
//                                         .size
//                                         .width *
//                                         0.05,
//                                   ),
//                                   TableTitle(
//                                     text: 'total'.tr,
//                                     width: MediaQuery.of(context)
//                                         .size
//                                         .width *
//                                         0.07,
//                                   ),
//                                   TableTitle(
//                                     text:
//                                     '     ${'more_options'.tr}',
//                                     width: MediaQuery.of(context)
//                                         .size
//                                         .width *
//                                         0.07,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             GetBuilder<QuotationController>(
//                                 builder: (cont) {
//                                   return Container(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal:
//                                         MediaQuery.of(context)
//                                             .size
//                                             .width *
//                                             0.01),
//                                     decoration: const BoxDecoration(
//                                       borderRadius: BorderRadius.only(
//                                           bottomLeft:
//                                           Radius.circular(6),
//                                           bottomRight:
//                                           Radius.circular(6)),
//                                       color: Colors.white,
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(
//                                           height: listViewLength,
//                                           child: ListView.builder(
//                                             padding: const EdgeInsets
//                                                 .symmetric(
//                                                 vertical: 10),
//                                             itemCount: 2,
//                                             // cont
//                                             //     .orderLinesList
//                                             //     .length, //products is data from back res
//                                             itemBuilder:
//                                                 (context, index) => Row(
//                                               children: [
//                                                 Container(
//                                                   width: 20,
//                                                   height: 20,
//                                                   margin:
//                                                   const EdgeInsets
//                                                       .symmetric(
//                                                       vertical: 15),
//                                                   decoration:
//                                                   const BoxDecoration(
//                                                     image:
//                                                     DecorationImage(
//                                                       image: AssetImage(
//                                                           'assets/images/newRow.png'),
//                                                       fit: BoxFit
//                                                           .contain,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 // cont.orderLinesList[
//                                                 //     index],
//                                                 SizedBox(
//                                                   width: MediaQuery.of(
//                                                       context)
//                                                       .size
//                                                       .width *
//                                                       0.03,
//                                                   child:
//                                                   const ReusableMore(
//                                                     itemsList: [],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         Row(
//                                           children: [
//                                             ReusableAddCard(
//                                               text: 'title'.tr,
//                                               onTap: () {
//                                                 addNewTitle();
//                                               },
//                                             ),
//                                             gapW32,
//                                             ReusableAddCard(
//                                               text: 'item'.tr,
//                                               onTap: () {
//                                                 addNewItem();
//                                               },
//                                             ),
//                                             gapW32,
//                                             ReusableAddCard(
//                                               text: 'combo'.tr,
//                                               onTap: () {
//                                                 addNewCombo();
//                                               },
//                                             ),
//                                             gapW32,
//                                             ReusableAddCard(
//                                               text: 'image'.tr,
//                                               onTap: () {
//                                                 addNewImage();
//                                               },
//                                             ),
//                                             gapW32,
//                                             ReusableAddCard(
//                                               text: 'note'.tr,
//                                               onTap: () {
//                                                 addNewNote();
//                                               },
//                                             ),
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                                   );
//                                 }),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 gapH24,
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 20, horizontal: 20),
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
//                             fontSize: 15,
//                             color: TypographyColor.titleTable,
//                             fontWeight: FontWeight.bold),
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
//                             fontSize: 16,
//                             color: Primary.primary,
//                             decoration: TextDecoration.underline,
//                             fontStyle: FontStyle.italic),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 20, horizontal: 20),
//                   decoration: BoxDecoration(
//                     color: Primary.p20,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width:
//                         MediaQuery.of(context).size.width * 0.8,
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('total_before_vat'.tr),
//                                 Container(
//                                   width: MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                       0.2,
//                                   height: 47,
//                                   decoration: BoxDecoration(
//                                       border: Border.all(
//                                           color: Colors.black
//                                               .withAlpha((0.1 * 255).toInt()),
//                                           width: 1),
//                                       borderRadius:
//                                       BorderRadius.circular(6)),
//                                   child: const Center(
//                                       child: Text('0')),
//                                 )
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
//                                         width:
//                                         MediaQuery.of(context)
//                                             .size
//                                             .width *
//                                             0.2,
//                                         child: ReusableTextField(
//                                           textEditingController:
//                                           controller, //todo
//                                           isPasswordField: false,
//                                           hint: '0',
//                                           onChangedFunc: (val) {
//                                             setState(() {
//                                               globalDisc = val;
//                                             });
//                                           },
//                                           validationFunc: (val) {},
//                                         )),
//                                     gapW10,
//                                     Container(
//                                       width: MediaQuery.of(context)
//                                           .size
//                                           .width *
//                                           0.2,
//                                       height: 47,
//                                       decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: Colors.black
//                                                   .withAlpha((0.1 * 255).toInt()),
//                                               width: 1),
//                                           borderRadius:
//                                           BorderRadius.circular(
//                                               6)),
//                                       child: const Center(
//                                           child: Text('0')),
//                                     )
//                                   ],
//                                 )
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
//                                         width:
//                                         MediaQuery.of(context)
//                                             .size
//                                             .width *
//                                             0.2,
//                                         child: ReusableTextField(
//                                           textEditingController:
//                                           controller, //todo
//                                           isPasswordField: false,
//                                           hint: '0',
//                                           onChangedFunc: (val) {
//                                             setState(() {
//                                               specialDisc = val;
//                                             });
//                                           },
//                                           validationFunc: (val) {},
//                                         )),
//                                     gapW10,
//                                     Container(
//                                       width: MediaQuery.of(context)
//                                           .size
//                                           .width *
//                                           0.2,
//                                       height: 47,
//                                       decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: Colors.black
//                                                   .withAlpha((0.1 * 255).toInt()),
//                                               width: 1),
//                                           borderRadius:
//                                           BorderRadius.circular(
//                                               6)),
//                                       child: const Center(
//                                           child: Text('0')),
//                                     )
//                                   ],
//                                 )
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
//                                       width: MediaQuery.of(context)
//                                           .size
//                                           .width *
//                                           0.2,
//                                       height: 47,
//                                       decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: Colors.black
//                                                   .withAlpha((0.1 * 255).toInt()),
//                                               width: 1),
//                                           borderRadius:
//                                           BorderRadius.circular(
//                                               6)),
//                                       child: const Center(
//                                           child: Text('0')),
//                                     ),
//                                     gapW10,
//                                     Container(
//                                       width: MediaQuery.of(context)
//                                           .size
//                                           .width *
//                                           0.2,
//                                       height: 47,
//                                       decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: Colors.black
//                                                   .withAlpha((0.1 * 255).toInt()),
//                                               width: 1),
//                                           borderRadius:
//                                           BorderRadius.circular(
//                                               6)),
//                                       child: const Center(
//                                           child: Text('0.00')),
//                                     )
//                                   ],
//                                 )
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
//                                       fontSize: 16,
//                                       color: Primary.primary,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 Text(
//                                   '${'usd'.tr} 0.00',
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       color: Primary.primary,
//                                       fontWeight: FontWeight.bold),
//                                 )
//                               ],
//                             )
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
//                       width:
//                       MediaQuery.of(context).size.width * 0.3,
//                       height: 45,
//                       onTapFunction: () async {
//
//
//                         var res = await storeQuotation(
//                             refController.text,
//                             selectedCustomerIds,
//                             validityController.text,
//                             '',
//                             '',
//                             '',
//                             termsAndConditions,
//                             '',
//                             '',
//                             '',
//                             commissionController.text,
//                             totalCommissionController.text,
//                             '',
//                             specialDisc,
//                             '',
//                             globalDisc,
//                             '',
//                             '',
//                             '',
//                             '');
//                         if (res['success'] == true) {
//                           CommonWidgets.snackBar(
//                               'Success', res['message']);
//                           setState(() {
//                             isQuotationsInfoFetched = false;
//                             getFieldsForCreateQuotationFromBack();
//                           });
//                           homeController.selectedTab.value =
//                           'quotation_summary';
//                         } else {
//                           CommonWidgets.snackBar(
//                               'error', res['message']);
//                         }
//                       },
//                       btnText: 'create_quotation'.tr,
//                     ),
//                   ],
//                 )
//               ],
//             )
//                 : Container(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 20, vertical: 15),
//               decoration: const BoxDecoration(
//                 borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(6),
//                     bottomRight: Radius.circular(6)),
//                 color: Colors.white,
//               ),
//               child: Column(
//                 children: [
//                   DialogDropMenu(
//                     optionsList: const [''],
//                     text: 'sales_person'.tr,
//                     hint: 'search'.tr,
//                     rowWidth:
//                     MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.4,
//                     onSelected: () {},
//                   ),
//                   gapH16,
//                   DialogDropMenu(
//                     optionsList: const [''],
//                     text: 'commission_method'.tr,
//                     hint: '',
//                     rowWidth:
//                     MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.4,
//                     onSelected: () {},
//                   ),
//                   gapH16,
//                   DialogDropMenu(
//                     optionsList: ['cash'.tr],
//                     text: 'cashing_method'.tr,
//                     hint: '',
//                     rowWidth:
//                     MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.4,
//                     onSelected: () {},
//                   ),
//                   gapH16,
//                   DialogTextField(
//                     textEditingController: commissionController,
//                     text: 'commission'.tr,
//                     rowWidth:
//                     MediaQuery.of(context).size.width * 0.9,
//                     textFieldWidth:
//                     MediaQuery.of(context).size.width * 0.4,
//                     validationFunc: (val) {},
//                   ),
//                   gapH16,
//                   DialogTextField(
//                     textEditingController:
//                     totalCommissionController,
//                     text: 'total_commission'.tr,
//                     rowWidth:
//                     MediaQuery.of(context).size.width * 0.9,
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
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(9),
//                     topRight: Radius.circular(9)))),
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.25,
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
//                   // offset: const Offset(0, 3),
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
//   addNewTitle() {
//     setState(() {
//       listViewLength = listViewLength + increment;
//     });
//     Widget p = Container(
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
//     // Widget p = const ReusableItemRow();
//     Widget p = const ReusableItemRow(index: 3);
//
//     // quotationController.addToOrderLinesList(p);
//   }
//
//   addNewCombo() {
//     setState(() {
//       listViewLength = listViewLength + increment;
//     });
//     Widget p = const ReusableComboRow();
//     // quotationController.addToOrderLinesList(p);
//   }
//
//   addNewImage() {
//     setState(() {
//       listViewLength = listViewLength + 100;
//     });
//     Widget p = GetBuilder<QuotationController>(builder: (cont) {
//       return InkWell(
//         onTap: () async {
//           final ImagePicker picker = ImagePicker();
//           final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//
//           if (image != null) {
//             Uint8List imageFile;
//             if (Platform.isIOS || Platform.isAndroid) {
//               imageFile = await image.readAsBytes();
//             } else {
//               return; // This part will not run on web
//             }
//           setState(() {
//         imageFile = image!;
//             cont.changeBoolVar(true);
//             cont.increaseImageSpace(90);
//             listViewLength = listViewLength + (cont.imageSpaceHeight) + 10;
//           });
//         }},
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//           child: DottedBorder(
//             dashPattern: const [10, 10],
//             color: Others.borderColor,
//             radius: const Radius.circular(9),
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.63,
//               height: cont.imageSpaceHeight,
//               child: cont.imageAvailable
//                   ? Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Image.memory(
//                     imageFile,
//                     height: cont.imageSpaceHeight,
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
//     // quotationController.addToOrderLinesList(p);
//   }
//
//   addNewNote() {
//     setState(() {
//       listViewLength = listViewLength + increment;
//     });
//     Widget p = Container(
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
//
