import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ComboBackend/delete_combo.dart';
import 'package:rooster_app/Backend/ComboBackend/get_combo_create_info.dart';
import 'package:rooster_app/Backend/ComboBackend/get_combos.dart';
// import 'package:rooster_app/Models/Combo/creat_combo_model.dart';
import 'package:rooster_app/Widgets/custom_snak_bar.dart';
import 'package:rooster_app/const/functions.dart';
import 'package:rooster_app/const/sizes.dart';
import 'package:rooster_app/Backend/ComboBackend/store_combo.dart';
import '../../../Controllers/home_controller.dart';

abstract class ComboControllerAbstract extends GetxController {
  //Combo
  changeBoolVar(bool val);
  increaseImageSpace(double val);
  setImageInCombo(Uint8List imageFile);
  setTypeInCombo(int index, String val);
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
    String brand,
    List<int> image,
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
}

class ComboController extends ComboControllerAbstract {
  Map<int, Widget> photosWidgetsMap = {};
  double photosListWidth = 0;
  List photosFilesList = [];
  List imagesUrlsToRemove = [];

  String totalQty = '';
  List warehousesList = [];

  // addImageToPhotosWidgetsList(Widget widget) {
  //   photosWidgetsList.add(widget);
  //   update();
  // }
  int counterForImages = 0;
  incCounter() {
    counterForImages++;
  }

  addImageToPhotosWidgetsMap(int index, Widget widget) {
    photosWidgetsMap[index] = widget;
    // counterForImages++;
    update();
  }

  addImageToPhotosFilesList(Uint8List imageFile) {
    photosFilesList.add(imageFile);
    update();
  }

  removeImageFromPhotosFilesList(Uint8List imageFile) {
    photosFilesList.remove(imageFile);
    update();
  }

  removeFromImagesList(int key) {
    photosWidgetsMap.remove(key);
    photosListWidth = photosListWidth - 130;
    update();
  }

  resetPhotosFilesList() {
    photosFilesList = [];
    update();
  }

  addImageToImagesUrlsToRemoveList(String imageUrl) {
    imagesUrlsToRemove.add(imageUrl);
    update();
  }

  removeImageFromImagesUrlsToRemoveList(String imageUrl) {
    imagesUrlsToRemove.remove(imageUrl);
    update();
  }

  resetImagesUrlsToRemoveList() {
    imagesUrlsToRemove = [];
    update();
  }

  setPhotosListWidth(double val) {
    photosListWidth = val;
    update();
  }

  // resetPhotosWidgetsList() {
  //   photosWidgetsList = [];
  //   update();
  // }

  resetPhotosWidgetsMap() {
    photosWidgetsMap = {};
    update();
  }

  ///--------------------------------------------------------

  bool imageAvailable = false;
  double imageSpaceHeight = 90;
  @override
  changeBoolVar(bool val) {
    imageAvailable = val;
    update();
  }

  late Uint8List image1;
  @override
  setImageInCombo(Uint8List imageFile) {
    // print(imageFile);
    image1 = imageFile;
    update();
  }

  @override
  setTypeInCombo(int index, String val) {
    rowsInListViewInCombo[index]['line_type_id'] = val;
    update();
  }

  List<Widget> photosWidgetsList = [];

  @override
  increaseImageSpace(double val) {
    imageSpaceHeight = imageSpaceHeight + val;
    update();
  }

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

  // late List<CreatComboModel> comboCreateInfo;
  String? code = '';
  late List items;
  List<String> itemsName = [];
  List itemsIds = [];
  List<String> itemsInfo = [];
  List<String> itemsDes = [];
  List<String> itemsTotalQuantity = [];
  List<List<String>> itemsMultiPartList = [];
  List<String> itemsForSplit = [];
  Map priceCurrency = {}, itemUnitPrice = {}, itemsCodes = {};
  Map<String,List<String>> allCodesForItem={};
  List<String> allCodesForAllItems=[];
  @override
  getComboCreatFieldFromBack() async {
    itemsIds = [];
    itemsInfo = [];
    itemsDes = [];
    itemsTotalQuantity = [];
    itemsMultiPartList = [];
    itemsForSplit = [];
    priceCurrency = {};
    itemUnitPrice = {};
    itemsCodes = {};
    allCodesForItem={};
    allCodesForAllItems=[];
    items=[];
    isCombosInfoFetched = false;
    var response = await getFieldsForCreateCombo();
    code = response['code'];
    items = response['items'];

    for (var item in items) {
      itemsName.add('${item['item_name']}');
      itemsIds.add('${item['id']}');
      itemUnitPrice["${item['id']}"] = item['unitPrice'];
      priceCurrency["${item['id']}"] = item['priceCurrency']['name'];
      itemsCodes["${item['id']}"] = item['mainCode'];
      itemsCode.add('${item['mainCode']}');
      itemsIds.add('${item['id']}');
      itemsInfo.add(
        '${item['mainCode']}, ${item['mainDescription']} , ${item['totalQuantities']} Pcs',
      );
      itemsDes.add('${item['mainDescription']}');
      itemsName.add('${item['item_name']}');
      itemsTotalQuantity.add('${item['totalQuantities']}');
      allCodesForItem["${item['id']}"] = [
        ...?item["barcodes"]?.map((e) => e["code"].toString()),
        ...?item["supplierCodes"]?.map((e) => e["code"].toString()),
        ...?item["alternativeCodes"]?.map((e) => e["code"].toString()),
      ];
      allCodesForAllItems.addAll([
        ...?item["barcodes"]?.map((e) => e["code"].toString()),
        ...?item["supplierCodes"]?.map((e) => e["code"].toString()),
        ...?item["alternativeCodes"]?.map((e) => e["code"].toString()),
      ]);
    }
    for (int i = 0; i < itemsCode.length; i++) {
      itemsForSplit.add(itemsCode[i]);
      itemsForSplit.add(itemsName[i]);
      itemsForSplit.add(itemsDes[i]);
      itemsForSplit.add('${itemsTotalQuantity[i]} Pcs');
    }
    itemsMultiPartList = splitList(itemsForSplit, 4);

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
    rowsInListViewInCombo[index]['unit_price'] = val;
    update();
  }

  @override
  setItemIdInListViewLengthInCombo(int index, String val) {
    rowsInListViewInCombo[index]['item_id'] = val;
    update();
  }

  @override
  setItemNameInListViewLengthInCombo(int index, String val) {
    rowsInListViewInCombo[index]['item_name'] = val;
    update();
  }

  @override
  setItemDescriptionInListViewLengthInCombo(int index, String? val) {
    rowsInListViewInCombo[index]['description'] = val;
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

  bool isCombosPageIsLastPage = false;
  setIsCombosPageIsLastPage(bool val) {
    isCombosPageIsLastPage = val;
    update();
  }

  @override
  storeComboInDataBase(
    String companyId,
    String name,
    String code,
    String description,
    String currencyid,
    String price,
    String active,
    String brand,
    List<int> image,
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
      brand,
      image,
      itemss,
    );
    if (res['success'] == true) {
      Get.back();
      CommonWidgets.snackBar('Success', res['message']);
      resultStorInDB = 'Success';
      getAllCombosFromBackWithSeach('');
      if (isCombosPageIsLastPage) {
        homeController.selectedTab.value = 'combo_summary';
      } else {
        CommonWidgets.snackBar('Success', res['message']);
        Get.back();
      }
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
