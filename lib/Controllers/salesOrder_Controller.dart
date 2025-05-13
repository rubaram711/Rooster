import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/Quotations/get_quotation_create_info.dart';
import 'package:rooster_app/Backend/Quotations/get_quotations.dart';
import 'package:rooster_app/Backend/get_currencies.dart';

import '../Backend/UsersBackend/get_user.dart';
import '../const/functions.dart';

class SalesOrderController extends GetxController {
  Uint8List logoBytes = Uint8List(0);
  setLogo(Uint8List val) {
    logoBytes = val;
    update();
  }

  bool isBeforeVatPrices = true;
  setIsBeforeVatPrices(bool val) {
    isBeforeVatPrices = val;
    update();
  }

  bool isVatExemptCheckBoxShouldAppear = true;
  setIsVatExemptCheckBoxShouldAppear(bool val) {
    isVatExemptCheckBoxShouldAppear = val;
    update();
  }

  bool isVatExemptChecked = false;
  setIsVatExemptChecked(bool val) {
    isVatExemptChecked = val;
    setVat11();
    setTotalAllSalesOrder();
    update();
  }

  bool isPrintedAsVatExempt = false;
  bool isPrintedAs0 = false;
  bool isVatNoPrinted = false;
  setIsVatExempted(
    bool isPrintedAsVatExemptVal,
    bool isPrint0Val,
    bool isVatNoPrintedVal,
  ) {
    isPrintedAsVatExempt = isPrintedAsVatExemptVal;
    isPrintedAs0 = isPrint0Val;
    isVatNoPrinted = isVatNoPrintedVal;
    update();
  }

  double totalAllItems = 0.0;

  Map quotationItemInfos = {};
  // List itemList = [];

  Map<int, TextEditingController> unitPriceControllers = {};

  addToUnitPriceControllers(int index) {
    unitPriceControllers[index] = TextEditingController();
    update();
  }

  String exchangeRateForSelectedCurrency = '';
  String selectedCurrencyId = '';
  String selectedCurrencySymbol = '';
  String selectedCurrencyName = 'USD';

  setSelectedCurrency(String id, String name) {
    selectedCurrencyId = id;
    selectedCurrencyName = name;
    update();
  }

  setSelectedCurrencySymbol(String val) {
    selectedCurrencySymbol = val;
    update();
  }

  setExchangeRateForSelectedCurrency(String val) {
    exchangeRateForSelectedCurrency = val;
    update();
  }

  // List<Widget> orderLinesList = [];
  bool imageAvailable = false;
  double imageSpaceHeight = 90;
  changeBoolVar(bool val) {
    imageAvailable = val;
    update();
  }

  List<Widget> photosWidgetsList = [];
  List photosFilesList = [];
  double photosListWidth = 0;

  increaseImageSpace(double val) {
    imageSpaceHeight = imageSpaceHeight + val;
    update();
  }

  addImageToPhotosWidgetsList(Widget widget) {
    photosWidgetsList.add(widget);
    update();
  }

  addImageToPhotosFilesList(Uint8List imageFile) {
    photosFilesList.add(imageFile);
    update();
  }

  setPhotosListWidth(double val) {
    photosListWidth = val;
    update();
  }

  resetPhotosFilesList() {
    photosFilesList = [];
    update();
  }

  bool isSubmitAndPreviewClicked = false;
  setIsSubmitAndPreviewClicked(bool val) {
    isSubmitAndPreviewClicked = val;
    update();
  }

  Map<String, Widget> orderLinesSalesOrderList = {};
  resetSalesOrder() {
    orderLinesSalesOrderList = {};
    rowsInListViewInSalesOrder = {};
    // itemsList = [];
    itemsCode = [];
    itemsIds = [];
    isSalesOrderInfoFetched = false;

    totalItems = 0;
    specialDisc = '0';
    globalDisc = '0';
    vatInPrimaryCurrency = '0';
    vat11 = '0';
    totalSalesOrder = '0.00';
    update();
  }

  setSalesOrder(List value) {
    SalesOrderList = value;
    update();
  }

  int selectedTabIndex = 0;
  setSelectedTabIndex(int index) {
    selectedTabIndex = index;
    update();
  }

  // List<String> itemsList = [];
  List<String> itemsCode = [];
  List itemsIds = [];
  bool isSalesOrderInfoFetched = false;
  Map email = {};
  Map phoneNumber = {};
  Map clientNumber = {};
  Map name = {};
  Map country = {};
  Map city = {};
  Map floorAndBuilding = {};
  Map street = {};
  List<String> itemsInfo = [];
  List<String> itemsDes = [];
  List<String> itemsName = [];
  List<String> itemsTotalQuantity = [];
  List<List<String>> itemsMultiPartList = [];
  Map customersMap = {};
  List<String> customerNameList = [];
  List<String> customerTitleList = [];
  List<String> customerNumberList = [];
  List customerIdsList = [];
  List<List<String>> customersMultiPartList = [];
  String salesorderNumber = '';
  List<String> customerForSplit = [];
  List<String> itemsForSplit = [];
  Map itemsDescription = {};
  Map itemsMap = {};
  Map itemsCodes = {};
  Map itemsNames = {};
  Map warehousesInfo = {};
  Map itemUnitPrice = {};
  Map itemsVats = {};
  Map priceCurrency = {};
  getFieldsForCreateQuotationFromBack() async {
    itemsDescription = {};
    itemsMap = {};
    itemsCodes = {};
    itemsNames = {};
    warehousesInfo = {};
    // warehousesList = [];
    itemUnitPrice = {};
    itemsVats = {};
    priceCurrency = {};
    salesorderNumber = '';
    customersMap = {};
    customerNameList = [];
    customersMultiPartList = [];
    customerIdsList = [];
    customerNumberList = [];
    // itemsList = [];
    itemsCode = [];
    itemsIds = [];
    itemsMap = {};
    itemsMultiPartList = [];
    itemsDes = [];
    itemsName = [];
    itemsTotalQuantity = [];
    customerForSplit = [];
    itemsForSplit = [];
    phoneNumber = {};
    email = {};
    clientNumber = {};
    country = {};
    city = {};
    floorAndBuilding = {};
    street = {};
    warehousesInfo = {};
    isSalesOrderInfoFetched = false;
    var p = await getFieldsForCreateQuotation();
    for (var item in p['items']) {
      itemsCode.add('${item['mainCode']}');
      // print('${item['mainDescription']}');
      itemsIds.add('${item['id']}');
      itemsInfo.add(
        '${item['mainCode']}, ${item['mainDescription']} , ${item['totalQuantities']} Pcs',
      );
      itemsDes.add('${item['mainDescription']}');
      itemsName.add('${item['item_name']}');
      itemsTotalQuantity.add('${item['totalQuantities']}');
      itemsMap["${item['id']}"] = item;
      itemsDescription["${item['id']}"] = item['mainDescription'];
      itemsNames["${item['id']}"] = item['item_name'];
      itemsCodes["${item['id']}"] = item['mainCode'];
      itemUnitPrice["${item['id']}"] = item['unitPrice'];
      priceCurrency["${item['id']}"] = item['priceCurrency']['name'];
      List helper = item['taxationGroup']['tax_rates'];
      helper = helper.reversed.toList();
      itemsVats["${item['id']}"] = helper[0]['tax_rate'];
      warehousesInfo["${item['id']}"] = item['warehouses'];
    }
    salesorderNumber = p['salesorderNumber'].toString();

    for (var client in p['clients']) {
      customersMap['${client['id']}'] = client;
      customerNameList.add('${client['name']}');
      customerNumberList.add('${client['client_number']}');
      customerIdsList.add('${client['id']}');
      phoneNumber["${client['id']}"] = client['phone_number'] ?? '';
      email["${client['id']}"] = client['email'] ?? '';
      country["${client['id']}"] = client['country'] ?? '';
      city["${client['id']}"] = client['city'] ?? '';
      floorAndBuilding["${client['id']}"] = client['floor_and_building'] ?? '';
      street["${client['id']}"] = client['street'] ?? '';
      clientNumber["${client['id']}"] = client['client_number'];
    }
    for (int i = 0; i < customerNumberList.length; i++) {
      customerForSplit.add(customerNumberList[i]);
      customerForSplit.add(customerNameList[i]);
    }
    customersMultiPartList = splitList(customerForSplit, 2);

    for (int i = 0; i < itemsCode.length; i++) {
      itemsForSplit.add(itemsCode[i]);
      itemsForSplit.add(itemsName[i]);
      itemsForSplit.add(itemsDes[i]);
      itemsForSplit.add('${itemsTotalQuantity[i]} Pcs');
    }
    itemsMultiPartList = splitList(itemsForSplit, 4);
    isSalesOrderInfoFetched = true;
    update();
  }

  addToOrderLinesInSalesOrderList(String index, Widget p) {
    orderLinesSalesOrderList[index] = p;
    update();
  }

  removeFromOrderLinesInSalesOrderList(String index) {
    orderLinesSalesOrderList.remove(index);
    update();
  }

  Map newRowMap = {};
  Map rowsInListViewInSalesOrder = {
    // 0: {
    //    'type': '',
    //    'item': '',
    //    'discount': '0',
    //    'description': '',
    //    'quantity': '0',
    //    'unitPrice': '0',
    //    'total': '0',
    //  }
  };
  clearList() {
    rowsInListViewInSalesOrder = {};
    update();
  }

  addTorowsInListViewInSalesOrder(int index, Map p) {
    rowsInListViewInSalesOrder[index] = p;
    update();
  }

  removeFromrowsInListViewInSalesOrder(int index) {
    rowsInListViewInSalesOrder.remove(index);

    update();
  }

  setItemIdInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_id'] = val;
    update();
  }

  setItemNameInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['itemName'] = val;
    update();
  }

  setMainCodeInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_main_code'] = val;
    update();
  }

  setTypeInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['line_type_id'] = val;
    update();
  }

  setTitleInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['title'] = val;
    update();
  }

  setNoteInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['note'] = val;
    update();
  }

  // setImageInSalesOrder(int index, String val) {
  setImageInSalesOrder(int index, Uint8List imageFile) {
    // print(imageFile);
    rowsInListViewInSalesOrder[index]['image'] = imageFile;
    update();
  }

  setMainDescriptionInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_description'] = val;
    update();
  }

  setEnteredQtyInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_quantity'] = val;
    update();
  }

  setEnteredUnitPriceInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_unit_price'] = val;
    update();
  }

  setEnteredDiscInsalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_discount'] = val;
    update();
  }

  setMainTotalInQuotation(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_total'] = val;
    update();
  }

  double totalItems = 0.0;
  double totalAfterGlobalDis = 0.0;
  double totalAfterGlobalSpecialDis = 0.0;
  bool updateItem = false;

  String totalItem = '';
  getTotalItems() {
    if (rowsInListViewInSalesOrder != {}) {
      totalItems = rowsInListViewInSalesOrder.values
          .map((item) => double.parse(item['item_total'] ?? '0'))
          .reduce((a, b) => a + b);
    }

    setVat11();
    setTotalAllSalesOrder();
    // setGlobalDisc(globalDiscountPercentageValue);
    // setSpecialDisc(specialDiscountPercentageValue);

    update();
  }

  double preGlobalDisc = 0.0; //GlobalDisc as double used in calc
  String globalDisc = ''; // GlobalDisc as int to show it in ui
  String globalDiscountPercentageValue = '';

  setGlobalDisc(String globalDiscountPercentage) {
    globalDiscountPercentageValue = globalDiscountPercentage;
    preGlobalDisc =
        (totalItems) * double.parse(globalDiscountPercentageValue) / 100;
    globalDisc = preGlobalDisc.toStringAsFixed(2);

    totalAfterGlobalDis = totalItems - preGlobalDisc;
    totalAfterGlobalSpecialDis = totalAfterGlobalDis - preSpecialDisc;
    setSpecialDisc(specialDiscountPercentageValue);
    setVat11();
    setTotalAllSalesOrder();
    update();
  }

  double preSpecialDisc = 0.0;
  String specialDisc = '';
  String specialDiscountPercentageValue = '0';

  setSpecialDisc(String specialDiscountPercentage) {
    specialDiscountPercentageValue = specialDiscountPercentage;
    preSpecialDisc =
        totalAfterGlobalDis *
        double.parse(specialDiscountPercentageValue) /
        100;
    specialDisc = preSpecialDisc.toStringAsFixed(2);
    totalAfterGlobalSpecialDis = totalAfterGlobalDis - preSpecialDisc;
    setVat11();
    setTotalAllSalesOrder();
    update();
  }

  double preVat = 0.0;
  double preVatInPrimaryCurrency = 0.0;
  String vat11 = '';
  String vatInPrimaryCurrency = '';
  double vat = 11;
  double latestRate = 89500;
  String companyPrimaryCurrency = 'USD';
  setCompanyPrimaryCurrency(String val) {
    companyPrimaryCurrency = val;
    update();
  }

  setCompanyVat(double val) {
    vat = val;
    update();
  }

  setLatestRate(double val) {
    latestRate = val;
    update();
  }

  setVat11() {
    if (isVatExemptChecked) {
      preVat = 0;
      vat11 = '0';
      preVatInPrimaryCurrency = 0;
      vatInPrimaryCurrency = '0';
    } else {
      preVat =
          (totalItems - preGlobalDisc - preSpecialDisc) *
          vat /
          100; //all variables as double
      vat11 = preVat.toStringAsFixed(2);
      if (companyPrimaryCurrency == selectedCurrencyName) {
        preVatInPrimaryCurrency = double.parse(vat11);
      } else if (companyPrimaryCurrency == 'USD') {
        preVatInPrimaryCurrency =
            double.parse(vat11) / double.parse(exchangeRateForSelectedCurrency);
      } else {
        if (selectedCurrencyName == 'USD') {
          preVatInPrimaryCurrency = double.parse(vat11) * latestRate;
        } else {
          var usdPreVat =
              double.parse(vat11) /
              double.parse(exchangeRateForSelectedCurrency);
          preVatInPrimaryCurrency = usdPreVat * latestRate;
        }
      }
      // preVat11LBP = double.parse(vat11)  * latestRate;
      vatInPrimaryCurrency = preVatInPrimaryCurrency.toStringAsFixed(2);
      update();
    }
  }

  double pretotalSalesOrder = 0;
  String totalSalesOrder = '';

  setTotalAllSalesOrder() {
    pretotalSalesOrder = (totalItems - preGlobalDisc - preSpecialDisc) + preVat;
    totalSalesOrder = pretotalSalesOrder.toStringAsFixed(2);
    // setVat11();
  }

  double listViewLengthInSalesOrder = 50;
  double increment = 60;
  incrementListViewLengthInSalesOrder(double val) {
    listViewLengthInSalesOrder = listViewLengthInSalesOrder + val;
    update();
  }

  decrementListViewLengthInSalesOrder(double val) {
    listViewLengthInSalesOrder = listViewLengthInSalesOrder - val;
    update();
  }

  double companyVat = 0.0;
  List taxationGroupsList = [];
  bool isTaxationGroupsFetched = false;
  Map ratesInTaxationGroupList = {};
  // List ratesInTaxationGroupList= [];
  int selectedTaxationGroupIndex = 0;
  getAllTaxationGroupsFromBack() async {
    taxationGroupsList = [];
    // taxationGroupsList = {};
    isTaxationGroupsFetched = false;
    var p = await getCurrencies();
    if ('$p' != '[]') {
      taxationGroupsList.addAll(p['taxationGroups']);
      // print(taxationGroupsList);

      for (var tax in taxationGroupsList) {
        for (var rate in tax['tax_rates']) {
          // ratesInTaxationGroupList[rate['id']] = rate['tax_rate'];
          ratesInTaxationGroupList["${rate['id']}"] = rate['tax_rate']; //map
        }
      }

      isTaxationGroupsFetched = true;
      update();
    }

    isTaxationGroupsFetched = true;
    update();
  }

  //SalesOrder  summary section
  TextEditingController searchInSalesOrderController = TextEditingController();
  List SalesOrderList = [];
  bool isSalesOrderFetched = false;
  getAllQuotationsFromBack() async {
    SalesOrderList = [];
    isSalesOrderFetched = false;
    update();
    var p = await getAllQuotation(searchInSalesOrderController.text);
    if ('$p' != '[]') {
      SalesOrderList = p;
      // print(SalesOrderList.length);
      SalesOrderList = SalesOrderList.reversed.toList();
      // isSalesOrderFetched = true;
    }
    isSalesOrderFetched = true;
    update();
  }

  //quotation in document

  Map selectedSalesOrderData = {};
  List rowsInListViewInSalesOrderData = [];

  setSelectedQuotation(Map map) {
    selectedSalesOrderData = map;
    update();
  }

  resetSalesOrderData() {
    rowsInListViewInSalesOrderData = [];
    selectedSalesOrderData = {};
    update();
  }

  clearrowsInListViewInSalesOrderData() {
    rowsInListViewInSalesOrderData = [];
    update();
  }

  addTorowsInListViewInSalesOrderData(List p) {
    rowsInListViewInSalesOrderData = p;
    update();
  }

  List salesPersonList = [];
  List<String> salesPersonListNames = [];
  List salesPersonListId = [];
  String salesPersonName = '';
  int salesPersonId = 0;
  getAllUsersSalesPersonFromBack() async {
    SalesOrderList = [];
    isSalesOrderFetched = false;
    update();
    var p = await getAllUsersSalesPerson();
    if ('$p' != '[]') {
      salesPersonList = p;
      for (var salesPerson in salesPersonList) {
        salesPersonName = salesPerson['name'];
        salesPersonId = salesPerson['id'];
        salesPersonListNames.add(salesPersonName);
        salesPersonListId.add(salesPersonId);
      }
    }
    isSalesOrderFetched = true;
    update();
  }
}
