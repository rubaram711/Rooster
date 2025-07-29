import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/combo_controller.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/Screens/Combo/ComboSummaryWidgets/showitems.dart';
import 'package:rooster_app/Screens/Combo/ComboSummaryWidgets/update_combo_dialog.dart';
import 'package:rooster_app/Screens/Combo/combo.dart';
import 'package:rooster_app/Widgets/page_title.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import 'package:rooster_app/Widgets/reusable_text_field.dart';
import 'package:rooster_app/Widgets/table_item.dart';
import 'package:rooster_app/Widgets/table_title.dart';
import 'package:rooster_app/const/colors.dart';
import 'package:rooster_app/const/sizes.dart';

import '../../Widgets/reusable_more.dart';

class ComboSummary extends StatefulWidget {
  const ComboSummary({super.key});

  @override
  State<ComboSummary> createState() => _ComboSummaryState();
}

class _ComboSummaryState extends State<ComboSummary> {
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
  final ComboController comboController = Get.find();
  bool isNumberOrderedUp = true;
  bool isCreationOrderedUp = true;
  bool isCustomerOrderedUp = true;
  String searchValue = '';
  Timer? searchOnStoppedTyping;
  List combosList = [];
  bool isCombosFetched = false;
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
    await comboController.getAllCombosFromBackWithSeach(searchValue);
  }

  @override
  void initState() {
    exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();
    comboController.getComboCreatFieldFromBack();
    comboController.searchInComboController.text = '';
    listViewLength =
        Sizes.deviceHeight * (0.09 * comboController.combosList.length);
    comboController.getAllCombosFromBackWithSeach('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ComboController>(
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
                    PageTitle(text: 'combos'.tr),
                    ReusableButtonWithColor(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: 45,
                      onTapFunction: () {
                        showDialog<String>(
                          context: context,
                          builder:
                              (BuildContext context) => AlertDialog(
                                backgroundColor: Colors.white,
                                contentPadding: const EdgeInsets.all(0),
                                titlePadding: const EdgeInsets.all(0),
                                actionsPadding: const EdgeInsets.all(0),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(9),
                                  ),
                                ),
                                elevation: 0,
                                content: const Combo(),
                              ),
                        );
                      },
                      btnText: 'create_new_combo'.tr,
                    ),
                  ],
                ),
                gapH24,
                SizedBox(
                  // width: MediaQuery.of(context).size.width * 0.59,
                  child: ReusableSearchTextField(
                    hint: '${"search".tr}...',
                    textEditingController: cont.searchInComboController,
                    onChangedFunc: (value) {
                      search(value);
                    },
                    validationFunc: () {},
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Column(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          TableTitle(
                            text: 'name'.tr,
                            width:
                                MediaQuery.of(context).size.width * 0.10, //085
                          ),
                          TableTitle(
                            text: 'description'.tr,
                            width:
                                MediaQuery.of(context).size.width * 0.10, //085
                          ),
                          TableTitle(
                            text: 'creation'.tr,
                            width:
                                MediaQuery.of(context).size.width * 0.10, //085
                          ),
                          TableTitle(
                            text: 'currency'.tr,
                            width:
                                MediaQuery.of(context).size.width * 0.07, //085
                          ),
                          TableTitle(
                            text: 'price'.tr,
                            width:
                                MediaQuery.of(context).size.width * 0.07, //085
                          ),
                          TableTitle(
                            text: 'total'.tr,
                            width:
                                MediaQuery.of(context).size.width * 0.07, //085
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
                    cont.isCombosFetched
                        ? Container(
                          color: Colors.white,
                          // height: listViewLength,
                          height:
                              MediaQuery.of(context).size.height *
                              0.4, //listViewLength

                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: cont.combosList.length,
                            itemBuilder:
                                (context, index) => Column(
                                  children: [
                                    ComboAsRowInTable(
                                      info: cont.combosList[index],
                                      index: index,
                                      isDesktop: true,
                                    ),
                                    const Divider(),
                                  ],
                                ),
                          ),
                        )
                        : const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    //****************************************** */
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       '${'rows_per_page'.tr}:  ',
                    //       style: const TextStyle(
                    //         fontSize: 13,
                    //         color: Colors.black54,
                    //       ),
                    //     ),
                    //     Container(
                    //       width: 60,
                    //       height: 30,
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(6),
                    //         border: Border.all(color: Colors.black, width: 2),
                    //       ),
                    //       child: Center(
                    //         child: DropdownButtonHideUnderline(
                    //           child: DropdownButton<String>(
                    //             borderRadius: BorderRadius.circular(0),
                    //             items:
                    //                 ['10', '20', '50', 'all'.tr].map((
                    //                   String value,
                    //                 ) {
                    //                   return DropdownMenuItem<String>(
                    //                     value: value,
                    //                     child: Text(
                    //                       value,
                    //                       style: const TextStyle(
                    //                         fontSize: 12,
                    //                         color: Colors.grey,
                    //                       ),
                    //                     ),
                    //                   );
                    //                 }).toList(),
                    //             value: selectedNumberOfRows,
                    //             onChanged: (val) {
                    //               setState(() {
                    //                 selectedNumberOfRows = val!;
                    //                 if (val == '10') {
                    //                   listViewLength =
                    //                       combosList.length < 10
                    //                           ? Sizes.deviceHeight *
                    //                               (0.09 * combosList.length)
                    //                           : Sizes.deviceHeight *
                    //                               (0.09 * 10);
                    //                   selectedNumberOfRowsAsInt =
                    //                       combosList.length < 10
                    //                           ? combosList.length
                    //                           : 10;
                    //                 }
                    //                 if (val == '20') {
                    //                   listViewLength =
                    //                       combosList.length < 20
                    //                           ? Sizes.deviceHeight *
                    //                               (0.09 * combosList.length)
                    //                           : Sizes.deviceHeight *
                    //                               (0.09 * 20);
                    //                   selectedNumberOfRowsAsInt =
                    //                       combosList.length < 20
                    //                           ? combosList.length
                    //                           : 20;
                    //                 }
                    //                 if (val == '50') {
                    //                   listViewLength =
                    //                       combosList.length < 50
                    //                           ? Sizes.deviceHeight *
                    //                               (0.09 * combosList.length)
                    //                           : Sizes.deviceHeight *
                    //                               (0.09 * 50);
                    //                   selectedNumberOfRowsAsInt =
                    //                       combosList.length < 50
                    //                           ? combosList.length
                    //                           : 50;
                    //                 }
                    //                 if (val == 'all'.tr) {
                    //                   listViewLength =
                    //                       Sizes.deviceHeight *
                    //                       (0.09 * combosList.length);
                    //                   selectedNumberOfRowsAsInt =
                    //                       combosList.length;
                    //                 }
                    //               });
                    //             },
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     gapW16,
                    //     Text(
                    //       selectedNumberOfRows == 'all'.tr
                    //           ? '${'all'.tr} of ${combosList.length}'
                    //           : '$start-$selectedNumberOfRows of ${combosList.length}',
                    //       style: const TextStyle(
                    //         fontSize: 13,
                    //         color: Colors.black54,
                    //       ),
                    //     ),
                    //     gapW16,
                    //     InkWell(
                    //       onTap: () {
                    //         setState(() {
                    //           isArrowBackClicked = !isArrowBackClicked;
                    //           isArrowForwardClicked = false;
                    //         });
                    //       },
                    //       child: Row(
                    //         children: [
                    //           Icon(
                    //             Icons.skip_previous,
                    //             color:
                    //                 isArrowBackClicked
                    //                     ? Colors.black87
                    //                     : Colors.grey,
                    //           ),
                    //           Icon(
                    //             Icons.navigate_before,
                    //             color:
                    //                 isArrowBackClicked
                    //                     ? Colors.black87
                    //                     : Colors.grey,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     gapW10,
                    //     InkWell(
                    //       onTap: () {
                    //         setState(() {
                    //           isArrowForwardClicked = !isArrowForwardClicked;
                    //           isArrowBackClicked = false;
                    //         });
                    //       },
                    //       child: Row(
                    //         children: [
                    //           Icon(
                    //             Icons.navigate_next,
                    //             color:
                    //                 isArrowForwardClicked
                    //                     ? Colors.black87
                    //                     : Colors.grey,
                    //           ),
                    //           Icon(
                    //             Icons.skip_next,
                    //             color:
                    //                 isArrowForwardClicked
                    //                     ? Colors.black87
                    //                     : Colors.grey,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     gapW40,
                    //   ],
                    // ),
                    //****************************************** */
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  } //@override Build

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
} //End Combo Summary Class

class ComboAsRowInTable extends StatefulWidget {
  const ComboAsRowInTable({
    super.key,
    required this.info,
    required this.index,
    required this.isDesktop,
  });
  final Map info;
  final int index;
  final bool isDesktop;
  @override
  State<ComboAsRowInTable> createState() => _ComboAsRowInTableState();
}

class _ComboAsRowInTableState extends State<ComboAsRowInTable> {
  String itemName = '', description = '';
  double itemPrice = 0;
  double itemTotal = 0;
  double itemdiscount = 0;

  double totalAllItems = 0;
  String itemBrand = '';
  String brand = '';
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
  Map comboItemInfo = {};
  final HomeController homeController = Get.find();
  final ComboController comboController = Get.find();
  ExchangeRatesController exchangeRatesController = Get.find();
  String diss = '0';
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onDoubleTap: () {
        homeController.selectedTab.value = 'combo_data';
        comboController.setSelectedCombo(widget.info);
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
              text: '${widget.info['name'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.10
                      : 150,
            ),
            TableItem(
              text: '${widget.info['description'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.10
                      : 150,
            ),
            TableItem(
              text: '${widget.info['created_at'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.10
                      : 150,
            ),
            TableItem(
              text: '${widget.info['currency']['name'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),
            TableItem(
              text: '${widget.info['price'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),
            TableItem(
              text: '${widget.info['total'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),

            //*******************reusablemore preview and update */
            GetBuilder<ComboController>(
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
                                  content: UpdateComboDialog(
                                    index: widget.index,
                                    info: widget.info,
                                  ),
                                ),
                          );
                        },
                        child: Text('Update'.tr),
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
                                  content: ShowItemsComboDialog(
                                    info: widget.info,
                                  ),
                                ),
                          );
                        },
                        child: Text('show_items'.tr),
                      ),
                    ],
                  ),
                );
              },
            ),
            //**************************** */
            //***Delete btn */
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.03,
              child: InkWell(
                onTap: () async {
                  comboController.deleteItemFromComboFromDB(
                    '${comboController.combosList[widget.index]['id']}',
                  );
                },
                child: Icon(Icons.delete_outline, color: Primary.primary),
              ),
            ),
            // **************
          ],
        ),
      ),
    );
  }
}
