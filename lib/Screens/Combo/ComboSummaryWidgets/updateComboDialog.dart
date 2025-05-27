import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rooster_app/Backend/ComboBackend/update_combo.dart';
import 'package:rooster_app/Controllers/combo_controller.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/Widgets/TransferWidgets/reusable_show_info_card.dart';
import 'package:rooster_app/Widgets/custom_snak_bar.dart';
import 'package:rooster_app/Widgets/dialog_drop_menu.dart';
import 'package:rooster_app/Widgets/reusable_add_card.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import 'package:rooster_app/Widgets/reusable_text_field.dart';
import 'package:rooster_app/Widgets/table_item.dart';
import 'package:rooster_app/Widgets/table_title.dart';
import 'package:rooster_app/const/functions.dart';
import '../../../Widgets/dialog_title.dart';
import '../../../Widgets/reusable_more.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';

class UpdateComboDialog extends StatefulWidget {
  const UpdateComboDialog({super.key, required this.info, required this.index});
  final int index;
  final Map info;
  @override
  State<UpdateComboDialog> createState() => _UpdateComboDialogState();
}

class _UpdateComboDialogState extends State<UpdateComboDialog> {
  ComboController comboController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();
  final HomeController homeController = Get.find();

  final TextEditingController comboNameController = TextEditingController();
  final TextEditingController comboPriceController = TextEditingController();
  final TextEditingController comboCurrenceController = TextEditingController();
  TextEditingController comboCodeController = TextEditingController();
  final TextEditingController comboMainDescriptionController =
      TextEditingController();

  String selectedCurrency = '';
  String selectedItemCode = '';
  String selectedItem = "";
  int indexNum = 0;
  int comboCounter = 0;
  Map orderLine = {};

  getCurrency() async {
    comboController.selectedCurrencyId =
        widget.info['currency']['id'].toString();
    selectedCurrency = widget.info['currency']['name'] ?? '';
    comboCurrenceController.text = selectedCurrency;
    int index = exchangeRatesController.currenciesNamesList.indexOf(
      selectedCurrency,
    );
    comboController.selectedCurrencyId =
        exchangeRatesController.currenciesIdsList[index];
    comboController.selectedCurrencyName = selectedCurrency;
    var companyCurrency = await getCompanyPrimaryCurrencyFromPref();
    comboController.setCompanyPrimaryCurrency(companyCurrency);
    var result = exchangeRatesController.exchangeRatesList.firstWhere(
      (item) => item["currency"] == companyCurrency,
      orElse: () => null,
    );
    comboController.setLatestRate(
      double.parse(result != null ? '${result["exchange_rate"]}' : '1'),
    );
  }

  addNewItem() {
    setState(() {
      comboCounter += 1;
    });
    comboController.incrementlistViewLengthInCombo(comboController.increment);
    comboController.addToRowsInListViewInCombo(comboCounter, {
      'item_id': '0',
      'item_name': 'Item Name',
      'description': 'Description',
      'quantity': '0',
      'unit_price': '0',
      'discount': '0',
      'total': '0',
    });
    comboController.addToUnitPriceControllers(comboCounter);
    Widget p = ReusableItemRow(index: comboCounter, info: {});
    comboController.addToOrderLinesInComboList('$comboCounter', p);
    print("add item");
    print(comboController.rowsInListViewInCombo);
  }

  @override
  void initState() {
    super.initState();
    getCurrency();
    comboController.orderLinesComboList = {};
    comboController.rowsInListViewInCombo = {};
    comboNameController.text = widget.info['name'];
    comboMainDescriptionController.text = widget.info['description'];
    comboCurrenceController.text = widget.info['currency']['name'];
    comboPriceController.text = widget.info['price'];
    comboCodeController.text = widget.info['code'];

    comboController.selectedComboData2['orderLines'] =
        widget.info['comboItems'] ?? '';

    for (
      int i = 0;
      i < comboController.selectedComboData2['orderLines'].length;
      i++
    ) {
      comboController.rowsInListViewInCombo[i + 1] =
          comboController.selectedComboData2['orderLines'][i];
    }
    var keys = comboController.rowsInListViewInCombo.keys.toList();
    for (int i = 0; i < widget.info['comboItems'].length; i++) {
      comboController.unitPriceControllers[i + 1] = TextEditingController();
      Widget p = ReusableItemRow(
        index: i + 1,
        info: comboController.rowsInListViewInCombo[keys[i]],
      );
      print("initial");
      print(comboController.rowsInListViewInCombo[1]);
      comboController.orderLinesComboList['${i + 1}'] = p;
    }
    comboCounter = comboController.rowsInListViewInCombo.length;
    comboController.listViewLengthInCombo =
        comboController.orderLinesComboList.length * 60;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ComboController>(
      builder: (cont) {
        var keysList = cont.orderLinesComboList.keys.toList();
        comboCodeController = TextEditingController(text: widget.info['code']);
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.95,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DialogTitle(text: 'update_combo'.tr),
                    gapW100,
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
                gapH16,
                Text(
                  "Combo's Name",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17.00,
                  ),
                ),
                gapH10,
                ReusableTextField(
                  onChangedFunc: () {},
                  validationFunc: () {},
                  hint: " ",
                  isPasswordField: false,
                  textEditingController: comboNameController,
                ),
                gapH10,

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DialogTextField(
                      read: true,
                      textEditingController: comboCodeController,
                      text: 'combo_code'.tr,
                      rowWidth: MediaQuery.of(context).size.width * 0.30,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.20,
                      validationFunc: (value) {
                        if (value.isEmpty) {
                          return 'required_field'.tr;
                        }
                        return null;
                      },
                    ),
                    DialogNumericTextField(
                      validationFunc: () {},
                      text: "Price",
                      rowWidth: MediaQuery.of(context).size.width * 0.30,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.20,
                      textEditingController: comboPriceController,
                    ),
                  ],
                ),
                gapH10,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('currency'.tr),
                          GetBuilder<ExchangeRatesController>(
                            builder: (cont) {
                              return DropdownMenu<String>(
                                width: MediaQuery.of(context).size.width * 0.20,
                                // requestFocusOnTap: false,
                                enableSearch: true,
                                controller: comboCurrenceController,
                                hintText: '',
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
                                  // outlineBorder: BorderSide(color: Colors.black,),
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
                                // menuStyle: ,
                                menuHeight: 250,
                                dropdownMenuEntries:
                                    cont.currenciesNamesList
                                        .map<DropdownMenuEntry<String>>((
                                          String option,
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
                                    selectedCurrency = val!;
                                    var index = cont.currenciesNamesList
                                        .indexOf(val);
                                    comboController.setSelectedCurrency(
                                      cont.currenciesIdsList[index],
                                      val,
                                    );
                                    comboController.setSelectedCurrencySymbol(
                                      cont.currenciesSymbolsList[index],
                                    );
                                    var result = cont.exchangeRatesList
                                        .firstWhere(
                                          (item) => item["currency"] == val,
                                          orElse: () => null,
                                        );
                                    comboController
                                        .setExchangeRateForSelectedCurrency(
                                          result != null
                                              ? '${result["exchange_rate"]}'
                                              : '1',
                                        );
                                  });
                                  var keys =
                                      comboController.unitPriceControllers.keys
                                          .toList();
                                  for (
                                    int i = 0;
                                    i <
                                        comboController
                                            .unitPriceControllers
                                            .length;
                                    i++
                                  ) {
                                    var selectedItemId =
                                        '${comboController.rowsInListViewInCombo[keys[i]]['item_id']}';
                                    print("selectedItemId");
                                    print(selectedItemId);

                                    if (selectedItemId != '') {
                                      if (comboController
                                              .priceCurrency[selectedItemId] ==
                                          val) {
                                        print("if1 cur");
                                        print("keys[i]");
                                        print(keys[i]);
                                        print(
                                          "comboControlleritemUnitPriceselectedItemId",
                                        );
                                        print(
                                          "${comboController.itemUnitPrice[selectedItemId]}",
                                        );
                                        comboController
                                            .unitPriceControllers[keys[i]]!
                                            .text = comboController
                                                .itemUnitPrice[selectedItemId]
                                                .toString();
                                      } else if (val == 'USD' &&
                                          comboController
                                                  .priceCurrency[selectedItemId] !=
                                              val) {
                                        print("if2 cur");
                                        var result = exchangeRatesController
                                            .exchangeRatesList
                                            .firstWhere(
                                              (item) =>
                                                  item["currency"] ==
                                                  comboController
                                                      .priceCurrency[selectedItemId],
                                              orElse: () => null,
                                            );
                                        var divider = '1';
                                        if (result != null) {
                                          divider =
                                              result["exchange_rate"]
                                                  .toString();
                                        }
                                        comboController
                                                .unitPriceControllers[keys[i]]!
                                                .text =
                                            '${double.parse('${(double.parse(comboController.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                      } else if (comboController
                                                  .selectedCurrencyName !=
                                              'USD' &&
                                          comboController
                                                  .priceCurrency[selectedItemId] ==
                                              'USD') {
                                        print("if3 cur");
                                        print(keys[i]);
                                        comboController
                                                .unitPriceControllers[keys[i]]!
                                                .text =
                                            '${double.parse('${(double.parse(comboController.itemUnitPrice[selectedItemId].toString()) * double.parse(comboController.exchangeRateForSelectedCurrency))}')}';
                                        comboController
                                            .unitPriceControllers[keys[i]]!
                                            .text = (comboController
                                                    .unitPriceControllers[keys[i]]!
                                                    .text)
                                                .toString();
                                      } else {
                                        print("end else cur");
                                        var result = exchangeRatesController
                                            .exchangeRatesList
                                            .firstWhere(
                                              (item) =>
                                                  item["currency"] ==
                                                  comboController
                                                      .priceCurrency[selectedItemId],
                                              orElse: () => null,
                                            );
                                        var divider = '1';
                                        if (result != null) {
                                          divider =
                                              result["exchange_rate"]
                                                  .toString();
                                        }
                                        var usdPrice =
                                            '${double.parse('${(double.parse(comboController.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                                        comboController
                                                .unitPriceControllers[keys[i]]!
                                                .text =
                                            '${double.parse('${(double.parse(usdPrice) * double.parse(comboController.exchangeRateForSelectedCurrency))}')}';
                                      }
                                      print("out end else");
                                      comboController
                                          .unitPriceControllers[keys[i]]!
                                          .text = double.parse(
                                        comboController
                                            .unitPriceControllers[keys[i]]!
                                            .text,
                                      ).toStringAsFixed(2);
                                      var totalLine =
                                          '${(double.parse(comboController.rowsInListViewInCombo[keys[i]]['quantity'].toString()) * double.parse(comboController.unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(comboController.rowsInListViewInCombo[keys[i]]['discount'].toString()) / 100)}';
                                      comboController
                                          .setEnteredUnitPriceInCombo(
                                            keys[i],
                                            comboController
                                                .unitPriceControllers[keys[i]]!
                                                .text,
                                          );
                                      comboController
                                          .setItemtotalInListViewLengthInCombo(
                                            keys[i],
                                            totalLine,
                                          );
                                      comboController.getTotalItems();
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    DialogTextField(
                      validationFunc: () {},
                      text: "Main Description",
                      rowWidth: MediaQuery.of(context).size.width * 0.30,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.20,
                      textEditingController: comboMainDescriptionController,
                    ),
                  ],
                ),

                gapH20,
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.01,
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
                          gapW16,
                          TableTitle(
                            text: 'item_code'.tr,
                            isCentered: false,
                            width: MediaQuery.of(context).size.width * 0.19,
                          ),

                          TableTitle(
                            text: 'description'.tr,
                            isCentered: false,
                            width: MediaQuery.of(context).size.width * 0.25,
                          ),

                          TableTitle(
                            text: 'quantity'.tr,
                            isCentered: false,
                            width: MediaQuery.of(context).size.width * 0.07,
                          ),
                          TableTitle(
                            text: 'unit_price'.tr,
                            isCentered: false,
                            width: MediaQuery.of(context).size.width * 0.07,
                          ),
                          TableTitle(
                            text: '${'disc'.tr}. %',
                            isCentered: false,
                            width: MediaQuery.of(context).size.width * 0.07,
                          ),
                          TableTitle(
                            text: 'total'.tr,
                            isCentered: false,
                            width: MediaQuery.of(context).size.width * 0.07,
                          ),
                          TableTitle(
                            text: '     ${'more_options'.tr}',
                            isCentered: false,
                            width: MediaQuery.of(context).size.width * 0.07,
                          ),
                        ],
                      ),
                    ),

                    //********************************section Table Row********************************************* */
                    Container(
                      height: MediaQuery.of(context).size.width * 0.20,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.01,
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
                          //+++++++++++++++++Rows in table With SingleScrollView+++++++++++++++++++++++++++++++
                          Container(
                            height: MediaQuery.of(context).size.width * 0.13,
                            child: SingleChildScrollView(
                              child: Column(
                                // height: cont.listViewLengthInCombo + 50,
                                children: [
                                  ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    children:
                                        keysList.map((key) {
                                          return Dismissible(
                                            key: Key(
                                              key,
                                            ), // Ensure each widget has a unique key
                                            onDismissed:
                                                (direction) => cont
                                                    .removeFromOrderLinesInComboList(
                                                      key.toString(),
                                                    ),
                                            child:
                                                cont.orderLinesComboList[key] ??
                                                const SizedBox(),
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //++++++++++++++++++++++++++++++++++++++++++++++++
                          gapH10,
                          Row(
                            children: [
                              ReusableAddCard(
                                text: 'create_new_combo'.tr,
                                onTap: () {
                                  addNewItem();
                                },
                              ),
                              gapW32,
                              ReusableAddCard(
                                text: 'create_append'.tr,
                                onTap: () {
                                  // addNewItem();
                                },
                              ),
                            ],
                          ),

                          //++++++++++++++Save Discard+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                          gapH10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    comboNameController.clear();
                                    comboPriceController.clear();
                                    comboMainDescriptionController.clear();
                                    cont.resetCombo();
                                  });
                                },
                                child: Text(
                                  'discard'.tr,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Primary.primary,
                                  ),
                                ),
                              ),
                              gapW24,
                              ReusableButtonWithColor(
                                btnText: 'update'.tr,
                                onTapFunction: () async {
                                  var oldKeys =
                                      comboController.rowsInListViewInCombo.keys
                                          .toList()
                                        ..sort();
                                  for (int i = 0; i < oldKeys.length; i++) {
                                    comboController.newRowMap[i + 1] =
                                        comboController
                                            .rowsInListViewInCombo[oldKeys[i]]!;
                                  }

                                  var res = await updateCombo(
                                    '${widget.info['id']}',
                                    comboNameController.text,
                                    '${widget.info['code']}',
                                    comboMainDescriptionController.text,
                                    comboController.selectedCurrencyId,
                                    comboPriceController.text,
                                    '1',
                                    comboController.newRowMap,
                                  );
                                  if (res['success'] == true) {
                                    Get.back();
                                    comboController
                                        .getAllCombosFromBackWithSeach('');
                                    homeController.selectedTab.value =
                                        'combo_summary';
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
                                },
                                width: 100,
                                height: 35,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // );
                    // },
                    // ),
                    //**************************************************************************** */
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ReusableItemRow extends StatefulWidget {
  // const ReusableItemRow({super.key});
  const ReusableItemRow({super.key, required this.index, required this.info});
  final int index;
  final Map info;
  @override
  State<ReusableItemRow> createState() => _ReusableItemRowState();
}

class _ReusableItemRowState extends State<ReusableItemRow> {
  String name = '',
      price = '0',
      disc = '0',
      result = '0',
      quantity = '0',
      quantity1 = '0',
      discription = '',
      selectedItemId = '',
      qty = '0',
      totalLine = '0';

  final focus = FocusNode(); //price
  final focus1 = FocusNode(); //disc
  final dropFocus = FocusNode(); //dropdown
  final quantityFocus = FocusNode(); //quantity

  final _formKey = GlobalKey<FormState>();

  final ComboController combocont = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();

  TextEditingController dropDownController = TextEditingController();
  TextEditingController quantityComboController = TextEditingController();
  TextEditingController priceComboController = TextEditingController();
  TextEditingController descritipnComboController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  setPrice() {
    var result = exchangeRatesController.exchangeRatesList.firstWhere(
      (item) => item["currency"] == combocont.selectedCurrencyName,
      orElse: () => null,
    );
    combocont.exchangeRateForSelectedCurrency =
        result != null ? '${result["exchange_rate"]}' : '1';

    combocont.unitPriceControllers[widget.index]!.text =
        '${widget.info['unit_price'] ?? ''}';
    selectedItemId = widget.info['item_id'].toString();

    if (combocont.priceCurrency[selectedItemId] ==
        combocont.selectedCurrencyName) {
      print("if 1 in reusableRow");
      combocont.unitPriceControllers[widget.index]!.text =
          combocont.itemUnitPrice[selectedItemId].toString();
    } else if (combocont.selectedCurrencyName == 'USD' &&
        combocont.priceCurrency[selectedItemId] !=
            combocont.selectedCurrencyName) {
      print("if 2 in reusableRow");
      var result = exchangeRatesController.exchangeRatesList.firstWhere(
        (item) => item["currency"] == combocont.priceCurrency[selectedItemId],
        orElse: () => null,
      );
      var divider = '1';
      if (result != null) {
        divider = result["exchange_rate"].toString();
      }
      combocont.unitPriceControllers[widget.index]!.text =
          '${double.parse('${(double.parse(combocont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
    } else if (combocont.selectedCurrencyName != 'USD' &&
        combocont.priceCurrency[selectedItemId] == 'USD') {
      print("if 3 reusableRow");
      combocont.unitPriceControllers[widget.index]!.text =
          '${double.parse('${(double.parse(combocont.itemUnitPrice[selectedItemId].toString()) * double.parse(combocont.exchangeRateForSelectedCurrency))}')}';
    } else {
      print("end else reusableRow");
      var result = exchangeRatesController.exchangeRatesList.firstWhere(
        (item) => item["currency"] == combocont.priceCurrency[selectedItemId],
        orElse: () => null,
      );
      var divider = '1';
      if (result != null) {
        divider = result["exchange_rate"].toString();
      }
      var usdPrice =
          '${double.parse('${(double.parse(combocont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
      combocont.unitPriceControllers[widget.index]!.text =
          '${double.parse('${(double.parse(usdPrice) * double.parse(combocont.exchangeRateForSelectedCurrency))}')}';
    }
    print("out end else reusableRow");
    combocont.unitPriceControllers[widget.index]!.text = double.parse(
      combocont.unitPriceControllers[widget.index]!.text,
    ).toStringAsFixed(2);

    combocont.rowsInListViewInCombo[widget.index]['unit_price'] =
        combocont.unitPriceControllers[widget.index]!.text;
  }

  @override
  void initState() {
    if (widget.info.isNotEmpty) {
      selectedItemId = widget.info['item_id'].toString();

      quantityComboController.text = '${widget.info['quantity'] ?? '0'}';
      quantity = '${widget.info['quantity'] ?? '0.0'}';
      quantity1 = '${widget.info['quantity'] ?? '0.0'}';

      discountController.text = widget.info['discount'] ?? '0.0';
      disc = widget.info['discount'] ?? '0.0';

      totalLine = widget.info['total'] ?? '';

      descritipnComboController.text = widget.info['description'] ?? '';
      discription = widget.info['description'] ?? '';

      dropDownController.text = widget.info['item_name'] ?? '';
      name = widget.info['item_name'] ?? '';

      setPrice();
    } else {
      quantityComboController.text =
          combocont.rowsInListViewInCombo[widget.index]['quantity'];

      discountController.text =
          combocont.rowsInListViewInCombo[widget.index]['discount'];

      descritipnComboController.text =
          combocont.rowsInListViewInCombo[widget.index]['description'];
      discription =
          combocont.rowsInListViewInCombo[widget.index]['description'];

      dropDownController.text =
          combocont.rowsInListViewInCombo[widget.index]['item_name'] ?? '';
      name = combocont.rowsInListViewInCombo[widget.index]['item_name'] ?? '';

      totalLine = combocont.rowsInListViewInCombo[widget.index]['total'];
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ComboController>(
      builder: (cont) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),

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
                DialogDropMenu(
                  controller: dropDownController,
                  optionsList: cont.itemsName,
                  text: '',
                  hint: ''.tr,
                  rowWidth: MediaQuery.of(context).size.width * 0.16,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.16,
                  onSelected: (String? value) {
                    dropDownController.text = value!;

                    //++++++++++++++++++++Set Info In RawsInListViewInCombo+++++++++++++++++++++++++++++++++++++++++++

                    setState(() {
                      selectedItemId =
                          '${cont.itemsIds[cont.itemsName.indexOf(value)]}';
                      qty =
                          '${cont.items[cont.itemsName.indexOf(value)]['quantity']}'
                              .toString();
                      print("qty in setstate in reusableRow");
                      print(qty);
                      name = value;

                      discription =
                          cont.items[cont.itemsName.indexOf(
                            value,
                          )]['mainDescription'];

                      descritipnComboController.text =
                          cont.items[cont.itemsName.indexOf(
                            value,
                          )]['mainDescription'];

                      // **************************Currency***********************************************************************************
                      if (cont.priceCurrency[selectedItemId] ==
                          cont.selectedCurrencyName) {
                        print("if1 in setstate in reusableRow");
                        cont.unitPriceControllers[widget.index]!.text =
                            cont.itemUnitPrice[selectedItemId].toString();
                      } else if (cont.selectedCurrencyName == 'USD' &&
                          cont.priceCurrency[selectedItemId] !=
                              cont.selectedCurrencyName) {
                        print("if2 in setstate in reusableRow");

                        var result = exchangeRatesController.exchangeRatesList
                            .firstWhere(
                              (item) =>
                                  item["currency"] ==
                                  cont.priceCurrency[selectedItemId],
                              orElse: () => null,
                            );
                        var divider = '1';
                        if (result != null) {
                          divider = result["exchange_rate"].toString();
                        }
                        cont.unitPriceControllers[widget.index]!.text =
                            '${double.parse('${(double.parse(cont.itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
                      } else if (cont.selectedCurrencyName != 'USD' &&
                          cont.priceCurrency[selectedItemId] == 'USD') {
                        print("if3 in setstate in reusableRow");

                        cont.unitPriceControllers[widget.index]!.text =
                            '${double.parse('${(double.parse(cont.itemUnitPrice[selectedItemId].toString()) * double.parse(cont.exchangeRateForSelectedCurrency))}')}';
                      } else {
                        print("end else in setstate in reusableRow");

                        var result = exchangeRatesController.exchangeRatesList
                            .firstWhere(
                              (item) =>
                                  item["currency"] ==
                                  cont.priceCurrency[selectedItemId],
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
                      print("out end else in setstate in reusableRow");

                      quantityComboController.text = '1';
                      quantity = '1';
                      discountController.text = '0';
                      disc = '0';
                      totalLine =
                          '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(disc) / 100)}';

                      cont.setItemQuantityInListViewLengthInCombo(
                        widget.index,
                        quantity,
                      );
                      cont.setItemtotalInListViewLengthInCombo(
                        widget.index,
                        totalLine,
                      );
                      cont.getTotalItems();
                    });
                    //setstate
                    print("out setstate in setstate in reusableRow");

                    cont.setEnteredUnitPriceInCombo(
                      widget.index,
                      cont.unitPriceControllers[widget.index]!.text,
                    );
                    cont.setItemIdInListViewLengthInCombo(
                      widget.index,
                      selectedItemId,
                    );
                    cont.setItemNameInListViewLengthInCombo(widget.index, name);
                    cont.setItemDescriptionInListViewLengthInCombo(
                      widget.index,
                      discription,
                    );

                    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                  },
                ),
                gapW12,
                //description
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.24,
                  child: TextFormField(
                    style: GoogleFonts.openSans(fontSize: 12),
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    textAlign: TextAlign.center,
                    controller: descritipnComboController,
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
                        descritipnComboController.text = val;
                      });
                      _formKey.currentState!.validate();
                      cont.setItemDescriptionInListViewLengthInCombo(
                        widget.index,
                        val,
                      );
                    },
                  ),
                ),

                gapW10,
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
                    controller: quantityComboController,
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
                            '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(disc) / 100)}';
                      });

                      _formKey.currentState!.validate();

                      cont.setItemQuantityInListViewLengthInCombo(
                        widget.index,
                        val,
                      );
                      cont.setItemtotalInListViewLengthInCombo(
                        widget.index,
                        totalLine,
                      );
                      cont.getTotalItems();
                    },
                  ),
                ),

                gapW10,
                //price
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.06,
                  child: TextFormField(
                    style: GoogleFonts.openSans(fontSize: 12),
                    focusNode: focus,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus1);
                    },
                    textAlign: TextAlign.center,
                    controller: cont.unitPriceControllers[widget.index],
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: "".tr,
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
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        if (val == '') {
                          cont.unitPriceControllers[widget.index]!.text = '0';
                        } else {
                          // cont.unitPriceControllers[widget.index]!.text = val;
                        }
                        totalLine =
                            '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(disc) / 100)}';
                      });
                      _formKey.currentState!.validate();

                      cont.setEnteredUnitPriceInCombo(widget.index, val);

                      cont.setItemtotalInListViewLengthInCombo(
                        widget.index,
                        totalLine,
                      );
                      cont.getTotalItems();
                    },
                  ),
                ),

                gapW10,

                //discount
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.06,
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
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                      // WhitelistingTextInputFormatter.digitsOnly
                    ],
                    onChanged: (val) async {
                      setState(() {
                        if (val == '') {
                          discountController.text = '0';
                          disc = '0';
                        } else {
                          disc = val;
                        }
                        totalLine =
                            '${(double.parse(quantity) * double.parse(cont.unitPriceControllers[widget.index]!.text)) * (1 - double.parse(disc) / 100)}';
                      });
                      _formKey.currentState!.validate();

                      // cont.calculateTotal(int.parse(quantity) , double.parse(unitPrice), double.parse(discount));
                      cont.setItemDiscountInListViewLengthInCombo(
                        widget.index,
                        val,
                      );
                      cont.setItemtotalInListViewLengthInCombo(
                        widget.index,
                        totalLine,
                      );
                      cont.getTotalItems();
                    },
                  ),
                ),
                gapW10,

                //total
                ReusableShowInfoCard(
                  text: formatDoubleWithCommas(
                    double.parse(
                      cont.rowsInListViewInCombo[widget.index]['total'],
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.07,
                ),

                gapW10,
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
                                                content: ShowQuantityDialog(
                                                  selectedItemId:
                                                      selectedItemId,
                                                  itemName: name,
                                                  itemquantity: quantity1,
                                                ),
                                              ),
                                        );
                                      },
                                      child: const Text('Show Quantity'),
                                    ),
                                  ],
                        ),
                      ),

                      // delete
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.03,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              combocont.decrementlistViewLengthInCombo(
                                combocont.increment,
                              );
                              combocont.removeFromRowsInListViewInCombo(
                                widget.index,
                              );
                              combocont.removeFromOrderLinesInComboList(
                                widget.index.toString(),
                              );
                            });
                            setState(() {
                              cont.totalItems = 0.0;
                              cont.globalDisc = "0.0";
                              cont.specialDisc = "0.0";

                              cont.totalCombo = "0.0";
                            });
                            if (cont.rowsInListViewInCombo != {}) {
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

class ShowQuantityDialog extends StatelessWidget {
  const ShowQuantityDialog({
    super.key,
    required this.selectedItemId,
    required this.itemName,
    required this.itemquantity,
  });
  final String selectedItemId;
  final String itemName;
  final String itemquantity;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ComboController>(
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
                    DialogTitle(text: 'Quantities of $itemName'),
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
                    itemCount: 1, // data from back
                    itemBuilder: (context, index) {
                      return ShowitemquantityAsRow(
                        //   info: info,
                        isDesktop: true,
                        itemName: itemName,
                        itemquantity: itemquantity,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class ShowitemquantityAsRow extends StatelessWidget {
  const ShowitemquantityAsRow({
    super.key,
    required this.isDesktop,
    required this.itemName,
    required this.itemquantity,
  });
  //final Map info;
  final String itemName;
  final String itemquantity;
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
            text: itemName,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.15 : 150,
          ),

          TableItem(
            isCentered: false,
            text: itemquantity,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.15 : 150,
          ),
        ],
      ),
    );
  }
}
