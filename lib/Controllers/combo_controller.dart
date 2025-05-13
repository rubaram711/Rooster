import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ComboBackend/delete_combo.dart';
import 'package:rooster_app/Backend/ComboBackend/get_combo_create_info.dart';
import 'package:rooster_app/Backend/ComboBackend/get_combos.dart';
import 'package:rooster_app/Models/Combo/creat_combo_model.dart';
import 'package:rooster_app/Widgets/custom_snak_bar.dart';
import 'package:rooster_app/const/sizes.dart';
import 'package:rooster_app/Backend/ComboBackend/store_combo.dart';
import '../../../Controllers/home_controller.dart';

abstract class ComboControllerAbstract extends GetxController {
  //Combo
  incrementlistViewLengthInCombo(double val);
  decrementlistViewLengthInCombo(double val);
  removeFromRowsInListViewInCombo(int index);
  addToRowsInListViewInCombo(int index, Map p);
  resetCombo();
  getComboCreatFieldFromBack();
  setItemIdInListViewLengthInCombo(int index, String val);
  setItemNameInListViewLengthInCombo(int index, String val);
  setItemDescriptionInListViewLengthInCombo(int index, String val);
  setItemQuantityInListViewLengthInCombo(int index, String val);
  setEnteredUnitPriceInCombo(int index, String val);
  setItemDiscountInListViewLengthInCombo(int index, String val);
  setItemtotalInListViewLengthInCombo(int index, String val);
  storeComboInDataBase(
    String companyId,
    String name,
    String code,
    String description,
    String currencyid,
    String price,
    String active,
    Map itemss,
  );
  deleteItemFromComboFromDB(String id);
  setSelectedCurrency(String id, String name);
  setSelectedCurrencySymbol(String val);
  setExchangeRateForSelectedCurrency(String val);
  addToUnitPriceControllers(int index);
  addToOrderLinesInComboList(String index, Widget p);
  removeFromOrderLinesInComboList(String index);
  setLatestRate(double val);
  setCompanyPrimaryCurrency(String val);
  //Combo Summary

  getAllCombosFromBackWithSeach(String searchvalue);
  setSelectedCombo(Map map);
  setSelectedCombo2(Map map);
  setIsSubmitAndPreviewClicked(bool val);
  Uint8List logoBytes = Uint8List(0);
  setLogo(Uint8List val) {
    logoBytes = val;
    update();
  }
}

class ComboController extends ComboControllerAbstract {
  final HomeController homeController = Get.find();
  Map newRowMap = {};

  Map rowsInListViewInCombo = {};
  double listViewLengthInCombo = Sizes.deviceHeight * 0.08;
  double increment = Sizes.deviceHeight * 0.08;

  @override
  incrementlistViewLengthInCombo(double val) {
    listViewLengthInCombo = listViewLengthInCombo + val;
    update();
  }

  @override
  decrementlistViewLengthInCombo(double val) {
    listViewLengthInCombo = listViewLengthInCombo - val;
    update();
  }

  @override
  removeFromRowsInListViewInCombo(int index) {
    rowsInListViewInCombo.remove(index);

    update();
  }

  @override
  addToRowsInListViewInCombo(int index, Map p) {
    rowsInListViewInCombo[index] = (p);
    update();
  }

  String companyPrimaryCurrency = 'USD';
  @override
  setCompanyPrimaryCurrency(String val) {
    companyPrimaryCurrency = val;
    update();
  }

  double latestRate = 89500;
  @override
  setLatestRate(double val) {
    latestRate = val;
    update();
  }

  Map<String, Widget> orderLinesComboList = {};
  @override
  addToOrderLinesInComboList(String index, Widget p) {
    orderLinesComboList[index] = p;
    update();
  }

  @override
  removeFromOrderLinesInComboList(String index) {
    orderLinesComboList.remove(index);
    update();
  }

  List<String> itemsCode = [];
  bool isCombosInfoFetched = false;
  double totalItems = 0.0;
  String specialDisc = '';
  String globalDisc = ''; // GlobalDisc as int to show it in ui
  String totalCombo = '';

  @override
  resetCombo() {
    orderLinesComboList = {};
    rowsInListViewInCombo = {};
    unitPriceControllers = {};
    itemsCode = [];
    itemsIds = [];
    isCombosInfoFetched = false;
    totalItems = 0;
    specialDisc = '0';
    globalDisc = '0';
    totalCombo = '0.00';
    update();
  }

  String totalItem = '';
  getTotalItems() {
    if (rowsInListViewInCombo != {}) {
      totalItems = rowsInListViewInCombo.values
          .map((item) => double.parse(item['total'] ?? '0'))
          .reduce((a, b) => a + b);
    }

    update();
  }

  late List<CreatComboModel> comboCreateInfo;
  String? code = '';
  late List items;
  List<String> itemsName = [];
  List itemsIds = [];
  Map priceCurrency = {}, itemUnitPrice = {}, itemsCodes = {};

  @override
  getComboCreatFieldFromBack() async {
    var response = await getFieldsForCreateCombo();
    code = response['code'];
    items = response['items'];

    for (var item in items) {
      itemsName.add('${item['item_name']}');
      itemsIds.add('${item['id']}');
      itemUnitPrice["${item['id']}"] = item['unitPrice'];
      priceCurrency["${item['id']}"] = item['priceCurrency']['name'];
      itemsCodes["${item['id']}"] = item['mainCode'];
    }

    isCombosInfoFetched = true;

    update();
  }

  Map<int, TextEditingController> unitPriceControllers = {};
  @override
  addToUnitPriceControllers(int index) {
    unitPriceControllers[index] = TextEditingController();
    update();
  }

  @override
  setEnteredUnitPriceInCombo(int index, String val) {
    rowsInListViewInCombo[index]['price'] = val;
    update();
  }

  @override
  setItemIdInListViewLengthInCombo(int index, String val) {
    rowsInListViewInCombo[index]['itemId'] = val;
    update();
  }

  @override
  setItemNameInListViewLengthInCombo(int index, String val) {
    rowsInListViewInCombo[index]['itemName'] = val;
    update();
  }

  @override
  setItemDescriptionInListViewLengthInCombo(int index, String? val) {
    rowsInListViewInCombo[index]['itemDescription'] = val;
    update();
  }

  @override
  setItemQuantityInListViewLengthInCombo(int index, String? val) {
    rowsInListViewInCombo[index]['quantity'] = val;
    update();
  }

  @override
  setItemDiscountInListViewLengthInCombo(int index, String val) {
    rowsInListViewInCombo[index]['discount'] = val;
    update();
  }

  @override
  setItemtotalInListViewLengthInCombo(int index, String val) {
    rowsInListViewInCombo[index]['total'] = val;
    update();
  }

  String resultStorInDB = 'NotSuccess';

  @override
  storeComboInDataBase(
    String companyId,
    String name,
    String code,
    String description,
    String currencyid,
    String price,
    String active,
    Map itemss,
  ) async {
    var res = await storeCombo(
      companyId,
      name,
      code,
      description,
      currencyid,
      price,
      active,
      itemss,
    );
    if (res['success'] == true) {
      Get.back();
      CommonWidgets.snackBar('Success', res['message']);
      resultStorInDB = 'Success';
      getAllCombosFromBackWithSeach('');
      homeController.selectedTab.value = 'combo_summary';
      update();
    } else {
      CommonWidgets.snackBar('error', res['message']);
    }
    update();
  }

  String selectedCurrencyId = '',
      selectedCurrencySymbol = '',
      selectedCurrencyName = 'USD',
      exchangeRateForSelectedCurrency = '';

  @override
  setSelectedCurrency(String id, String name) {
    selectedCurrencyId = id;
    selectedCurrencyName = name;
    update();
  }

  @override
  setSelectedCurrencySymbol(String val) {
    selectedCurrencySymbol = val;
    update();
  }

  @override
  setExchangeRateForSelectedCurrency(String val) {
    exchangeRateForSelectedCurrency = val;
    update();
  }

  //Combo Summary section
  bool isSubmitAndPreviewClicked = false;
  @override
  setIsSubmitAndPreviewClicked(bool val) {
    isSubmitAndPreviewClicked = val;
    update();
  }

  Uint8List logoBytes = Uint8List(0);
  @override
  setLogo(Uint8List val) {
    logoBytes = val;
    update();
  }

  TextEditingController searchInComboController = TextEditingController();
  List combosList = [];
  bool isCombosFetched = false;

  @override
  getAllCombosFromBackWithSeach(String searchvalue) async {
    combosList = [];
    isCombosFetched = false;
    update();
    var p = await getAllCombosWithSearch(searchvalue);
    if ('$p' != '[]') {
      combosList = p;
      combosList = combosList.reversed.toList();
    }
    isCombosFetched = true;
    update();
  }

  Map selectedComboData = {};
  @override
  setSelectedCombo(Map map) {
    selectedComboData = map;
    update();
  }

  Map selectedComboData2 = {};
  @override
  setSelectedCombo2(Map map) {
    selectedComboData2['orderLines'] = map;
    update();
  }

  @override
  deleteItemFromComboFromDB(String id) async {
    var res = await deleteCombo(id);
    var p = json.decode(res.body);
    if (res.statusCode == 200) {
      getAllCombosFromBackWithSeach('');
      CommonWidgets.snackBar('Success', "Combo Deleted Successfully");
    } else {
      CommonWidgets.snackBar('error', p['message']);
    }
  }
}
