import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/PriceListBackend/get_prices_list_items.dart';
import 'package:rooster_app/Backend/SalesOrderBackend/get_sales_order_create_info.dart';
import 'package:rooster_app/Backend/SalesOrderBackend/get_sales_orders.dart';
import 'package:rooster_app/Backend/UsersBackend/get_user.dart';
import 'package:rooster_app/Backend/get_currencies.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/const/functions.dart';

abstract class SalesOrderControllerAbstract extends GetxController {
  getFieldsForCreateSalesOrderFromBack();
  resetItemsAfterChangePriceList();
  incrementListViewLengthInSalesOrder(double val);
  decrementListViewLengthInSalesOrder(double val);
  addToOrderLinesInSalesOrderList(String index, Widget p);
  removeFromOrderLinesInSalesOrderList(String index);
  setSelectedPriceListId(String value);
  setIsVatExempted(
    bool isPrintedAsVatExemptVal,
    bool isPrint0Val,
    bool isVatNoPrintedVal,
  );
  setSpecialDisc(String specialDiscountPercentage);
  setGlobalDisc(String globalDiscountPercentage);
  setSelectedCashingMethodId(String value);
  setIsVatExemptCheckBoxShouldAppear(bool val);
  addToUnitPriceControllers(int index);
  addToCombosPricesControllers(int index);
  setItemIdInSalesOrder(int index, String val);
  setItemNameInSalesOrder(int index, String val);
  setMainCodeInSalesOrder(int index, String val);
  setTypeInSalesOrder(int index, String val);
  setTitleInSalesOrder(int index, String val);
  setNoteInSalesOrder(int index, String val);
  setImageInSalesOrder(int index, Uint8List imageFile);
  setMainDescriptionInSalesOrder(int index, String val);
  setComboWareHouseInSalesOrder(int index, String val);
  setEnteredQtyInSalesOrder(int index, String val);
  setComboInSalesOrder(int index, String val);
  setEnteredUnitPriceInSalesOrder(int index, String val);
  setEnteredDiscInSalesOrder(int index, String val);
  setMainTotalInSalesOrder(int index, String val);
  setItemWareHouseInSalesOrder(int index, String val);
  getTotalItems();
  setStatus(String val);
  setCompanyVat(double val);
  setLatestRate(double val);
  setVat11();
  setTotalAllSalesOrder();
  setIsVatExemptChecked(bool val);
  setSelectedCurrency(String id, String name);
  setSelectedCurrencySymbol(String val);
  setExchangeRateForSelectedCurrency(String val);
  changeBoolVar(bool val);
  increaseImageSpace(double val);
  setLogo(Uint8List val);
  setIsBeforeVatPrices(bool val);
  getAllTaxationGroupsFromBack();
  resetSalesOrder();
  clearList();
  addToRowsInListViewInSalesOrder(int index, Map p);
  removeFromRowsInListViewInSalesOrder(int index);
  setSearchInSalesOrdersController(String value);
  getAllSalesOrderFromBack();
  getAllSalesOrderFromBackWithoutExcept();
  getAllUsersSalesPersonFromBack();
  setSalesOrders(List value);
  setSelectedSalesOrder(Map map);
  resetSalesOrderData();
  clearRowsInListViewInSalesOrderData();
  addToRowsInListViewInSalesOrderData(List p);
  setIsSubmitAndPreviewClicked(bool val);
}

class SalesOrderController extends SalesOrderControllerAbstract {
  int salesOrderCounter = 0;
  setSalesOrderCounter(int val){
    salesOrderCounter=val;
    update();
  }

  bool isSubmitAndPreviewClicked = false;
  @override
  setIsSubmitAndPreviewClicked(bool val) {
    isSubmitAndPreviewClicked = val;
    update();
  }

  String status = '';
  @override
  setStatus(String val) {
    status = val;
    update();
  }

  Map<int, TextEditingController> unitPriceControllers = {};
  Map<int, TextEditingController> combosPriceControllers = {};
  @override
  addToUnitPriceControllers(int index) {
    unitPriceControllers[index] = TextEditingController();
    update();
  }

  @override
  addToCombosPricesControllers(int index) {
    combosPriceControllers[index] = TextEditingController();
    update();
  }

  @override
  setItemIdInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_id'] = val;
    update();
  }

  @override
  setItemNameInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['itemName'] = val;
    update();
  }

  @override
  setMainCodeInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_main_code'] = val;
    update();
  }

  @override
  setTypeInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['line_type_id'] = val;
    update();
  }

  @override
  setTitleInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['title'] = val;
    update();
  }

  @override
  setNoteInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['note'] = val;
    update();
  }

  @override
  setImageInSalesOrder(int index, Uint8List imageFile) {
    // print(imageFile);
    rowsInListViewInSalesOrder[index]['image'] = imageFile;
    update();
  }

  @override
  setMainDescriptionInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_description'] = val;
    update();
  }

  @override
  setComboWareHouseInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['combo_warehouseId'] = val;
    update();
  }

  @override
  setItemWareHouseInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_warehouseId'] = val;
    update();
  }

  @override
  setEnteredQtyInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_quantity'] = val;
    update();
  }

  @override
  setComboInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['combo'] = val;
    update();
  }

  @override
  setEnteredUnitPriceInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_unit_price'] = val;
    update();
  }

  @override
  setEnteredDiscInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_discount'] = val;
    update();
  }

  @override
  setMainTotalInSalesOrder(int index, String val) {
    rowsInListViewInSalesOrder[index]['item_total'] = val;
    update();
  }

  double totalAllItems = 0.0;
  String totalItem = '';
  double totalItems = 0.0;
  double totalAfterGlobalDis = 0.0;
  double totalAfterGlobalSpecialDis = 0.0;
  bool updateItem = false;
  @override
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

  String exchangeRateForSelectedCurrency = '';
  String selectedCurrencyId = '';
  String selectedCurrencySymbol = '';
  String selectedCurrencyName = 'USD';
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

  bool imageAvailable = false;
  double imageSpaceHeight = 90;
  @override
  changeBoolVar(bool val) {
    imageAvailable = val;
    update();
  }

  List<Widget> photosWidgetsList = [];
  List photosFilesList = [];
  double photosListWidth = 0;
  @override
  increaseImageSpace(double val) {
    imageSpaceHeight = imageSpaceHeight + val;
    update();
  }

  Uint8List logoBytes = Uint8List(0);
  @override
  setLogo(Uint8List val) {
    logoBytes = val;
    update();
  }

  bool isBeforeVatPrices = true;
  @override
  setIsBeforeVatPrices(bool val) {
    isBeforeVatPrices = val;
    update();
  }

  double companyVat = 0.0;
  List taxationGroupsList = [];
  bool isTaxationGroupsFetched = false;
  Map ratesInTaxationGroupList = {};
  // List ratesInTaxationGroupList= [];
  int selectedTaxationGroupIndex = 0;
  @override
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

  Map<String, Widget> orderLinesSalesOrderList = {};
  @override
  resetSalesOrder() {
    cashingMethodsNamesList = [];
    cashingMethodsIdsList = [];
    orderLinesSalesOrderList = {};
    rowsInListViewInSalesOrder = {};
    orderedKeys = [];
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

  @override
  setSelectedPriceListId(String value) {
    selectedPriceListId = value;
    update();
  }

  bool isVatExemptCheckBoxShouldAppear = true;
  @override
  setIsVatExemptCheckBoxShouldAppear(bool val) {
    isVatExemptCheckBoxShouldAppear = val;
    update();
  }

  bool isPrintedAsVatExempt = false;
  bool isPrintedAs0 = false;
  bool isVatNoPrinted = false;
  @override
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

  String selectedCashingMethodId = '';
  @override
  setSelectedCashingMethodId(String value) {
    selectedCashingMethodId = value;
    update();
  }

  double preGlobalDisc = 0.0; //GlobalDisc as double used in calc
  String globalDisc = ''; // GlobalDisc as int to show it in ui
  String globalDiscountPercentageValue = '';

  @override
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
  @override
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

  @override
  setCompanyVat(double val) {
    vat = val;
    update();
  }

  @override
  setLatestRate(double val) {
    latestRate = val;
    update();
  }

  @override
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

  double preTotalSalesOrder = 0;
  String totalSalesOrder = '';
  @override
  setTotalAllSalesOrder() {
    preTotalSalesOrder = (totalItems - preGlobalDisc - preSpecialDisc) + preVat;
    totalSalesOrder = preTotalSalesOrder.toStringAsFixed(2);
    // setVat11();
  }

  bool isVatExemptChecked = false;
  @override
  setIsVatExemptChecked(bool val) {
    isVatExemptChecked = val;
    setVat11();
    setTotalAllSalesOrder();
    update();
  }

  List<String> cashingMethodsNamesList = [];
  List<String> cashingMethodsIdsList = [];
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
  List<String> priceListsCodes = [];
  List<String> priceListsNames = [];
  List<String> priceListsIds = [];
  List priceLists = [];
  String selectedPriceListId = '';
  List<String> itemsTotalQuantity = [];
  List<List<String>> itemsMultiPartList = [];
  Map customersMap = {};
  List<String> customerNameList = [];
  List<String> customerTitleList = [];
  List<String> customerNumberList = [];
  List customersPricesListsIds = [];
  List customerIdsList = [];
  List<List<String>> customersMultiPartList = [];
  String salesOrderNumber = '';
  List<String> customerForSplit = [];
  List<String> itemsForSplit = [];
  Map itemsDescription = {};
  Map itemsMap = {};
  Map itemsCodes = {};
  Map itemsNames = {};
  Map warehousesInfo = {};
  Map itemUnitPrice = {};
  Map itemsVats = {};
  Map itemsPricesCurrencies = {};
  List<String> combosCodesList = [];
  List<String> combosNamesList = [];
  List<String> combosDescriptionList = [];
  List<String> combosPricesList = [];
  List<String> combosIdsList = [];
  List<List<String>> combosMultiPartList = [];
  List<String> combosForSplit = [];
  Map combosPricesCurrencies = {};
  Map combosMap = {};
  List<String> warehousesNameList = [];
  List<String> warehousesNameList1 = ['w1', 'w2', 'w3'];
  List warehouseIds = [];
  Map warehousesMap = {};
  Map warehousesNames = {};
  List<String> warehousesName = [];
  List<String> warehousesForSplit = [];
  List<List<String>> warehousesMultiPartList = [];
  @override
  getFieldsForCreateSalesOrderFromBack() async {
    warehousesNameList = [];
    warehouseIds = [];
    warehousesMap = {};
    warehousesNames = {};
    warehousesName = [];
    warehousesForSplit = [];
    warehousesMultiPartList = [];
    combosPricesCurrencies = {};
    combosPricesList = [];
    combosNamesList = [];
    combosIdsList = [];
    combosCodesList = [];
    combosDescriptionList = [];
    combosMultiPartList = [];
    combosForSplit = [];
    cashingMethodsNamesList = [];
    cashingMethodsIdsList = [];
    itemsDescription = {};
    itemsMap = {};
    itemsCodes = {};
    itemsNames = {};
    warehousesInfo = {};
    itemUnitPrice = {};
    itemsVats = {};
    itemsPricesCurrencies = {};
    salesOrderNumber = '';
    customersMap = {};
    customersPricesListsIds = [];
    customerNameList = [];
    customersMultiPartList = [];
    customerIdsList = [];
    customerNumberList = [];
    priceListsCodes = [];
    priceListsNames = [];
    priceListsIds = [];
    priceLists = [];
    selectedPriceListId = '';
    itemsCode = [];
    itemsIds = [];
    itemsMap = {};
    combosMap = {};
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
    var p = await getFieldsForCreateSalesOrder();
    // for (var item in p['items']) {
    //   itemsCode.add('${item['mainCode']}');
    //   itemsIds.add('${item['id']}');
    //   itemsInfo.add(
    //     '${item['mainCode']}, ${item['mainDescription']} , ${item['totalQuantities']} Pcs',
    //   );
    //   itemsDes.add('${item['mainDescription']}');
    //   itemsName.add('${item['item_name']}');
    //   itemsTotalQuantity.add('${item['totalQuantities']}');
    //   itemsMap["${item['id']}"] = item;
    //   itemsDescription["${item['id']}"] = item['mainDescription'];
    //   itemsNames["${item['id']}"] = item['item_name'];
    //   itemsCodes["${item['id']}"] = item['mainCode'];
    //   itemUnitPrice["${item['id']}"] = item['unitPrice'];
    //   itemsPricesCurrencies["${item['id']}"] = item['priceCurrency']['name'];
    //   List helper = item['taxationGroup']['tax_rates'];
    //   helper = helper.reversed.toList();
    //   itemsVats["${item['id']}"] = helper[0]['tax_rate'];
    //   warehousesInfo["${item['id']}"] = item['warehouses'];
    // }

    //------------------------------------------------------------------------
    //---------------WAREHOUSE------------------------------------------------
    for (var warehouse in p['warehouses']) {
      warehouseIds.add('${warehouse['id']}');

      warehousesNameList.add('${warehouse['name']}');

      warehousesMap["${warehouse['id']}"] = warehouse;

      warehousesNames["${warehouse['id']}"] = warehouse['name'];
    }
    for (int i = 0; i < warehousesName.length; i++) {
      warehousesForSplit.add(warehousesName[i]);
    }
    warehousesMultiPartList = splitList(warehousesForSplit, 2);

    salesOrderNumber = p['salesOrderNumber'].toString();

    for (var client in p['clients']) {
      customersMap['${client['id']}'] = client;
      customersPricesListsIds.add('${client['pricelist_id'] ?? ''}');
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

    priceLists = p['pricelists'];
    for (var priceList in p['pricelists']) {
      priceListsCodes.add(priceList['code']);
      priceListsNames.add(priceList['title']);
      priceListsIds.add('${priceList['id']}');
      if (priceList['code'] == 'STANDARD') {
        selectedPriceListId = '${priceList['id']}';
      }
    }
    for (var priceList in p['cashingMethods']) {
      cashingMethodsNamesList.add(priceList['title']);
      cashingMethodsIdsList.add('${priceList['id']}');
    }
    for (var combo in p['combos']) {
      combosMap["${combo['id']}"] = combo;
      combosPricesCurrencies["${combo['id']}"] = combo['currency']['name'];
      combosCodesList.add(combo['code'] ?? '');
      combosNamesList.add(combo['name'] ?? '');
      combosDescriptionList.add(combo['description'] ?? '');
      combosPricesList.add('${combo['price']}');
      combosIdsList.add('${combo['id']}');
    }
    for (int i = 0; i < combosCodesList.length; i++) {
      combosForSplit.add(combosCodesList[i]);
      combosForSplit.add(combosNamesList[i]);
      combosForSplit.add(combosDescriptionList[i]);
      combosForSplit.add(combosPricesList[i]);
    }
    combosMultiPartList = splitList(combosForSplit, 4);

    isSalesOrderInfoFetched = true;
    update();
    resetItemsAfterChangePriceList();
  }

  ExchangeRatesController exchangeRatesController = Get.find();
  @override
  resetItemsAfterChangePriceList() async {
    itemsCode = [];
    cashingMethodsNamesList = [];
    cashingMethodsIdsList = [];
    itemsIds = [];
    itemsInfo = [];
    itemsMultiPartList = [];
    itemsDes = [];
    itemsName = [];
    itemsTotalQuantity = [];
    itemsForSplit = [];
    itemsDescription = {};
    itemsMap = {};
    itemsCodes = {};
    itemsNames = {};
    warehousesInfo = {};
    itemUnitPrice = {};
    itemsVats = {};
    itemsPricesCurrencies = {};
    update();
    var res = await getPriceListItems(selectedPriceListId);
    if (res['success'] == true) {
      for (var item in res['data']) {
        itemsCode.add('${item['mainCode']}');
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
        itemsPricesCurrencies["${item['id']}"] = item['priceCurrency']['name'];
        List helper = item['taxationGroup']['tax_rates'];
        helper = helper.reversed.toList();
        itemsVats["${item['id']}"] = helper[0]['tax_rate'];
        warehousesInfo["${item['id']}"] = item['warehouses'];
      }
      for (int i = 0; i < itemsCode.length; i++) {
        itemsForSplit.add(itemsCode[i]);
        itemsForSplit.add(itemsName[i]);
        itemsForSplit.add(itemsDes[i]);
        itemsForSplit.add('${itemsTotalQuantity[i]} Pcs');
      }
      itemsMultiPartList = splitList(itemsForSplit, 4);
      var keys = unitPriceControllers.keys.toList();
      for (int i = 0; i < unitPriceControllers.length; i++) {
        var selectedItemId =
            '${rowsInListViewInSalesOrder[keys[i]]['item_id']}';
        if (selectedItemId != '') {
          if (itemUnitPrice.keys.contains(selectedItemId)) {
            if (itemsPricesCurrencies[selectedItemId] == selectedCurrencyName) {
              unitPriceControllers[keys[i]]!.text =
                  itemUnitPrice[selectedItemId].toString();
            } else if (selectedCurrencyName == 'USD' &&
                itemsPricesCurrencies[selectedItemId] != selectedCurrencyName) {
              var result = exchangeRatesController.exchangeRatesList.firstWhere(
                (item) =>
                    item["currency"] == itemsPricesCurrencies[selectedItemId],
                orElse: () => null,
              );
              var divider = '1';
              if (result != null) {
                divider = result["exchange_rate"].toString();
              }
              unitPriceControllers[keys[i]]!.text =
                  '${double.parse('${(double.parse(itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
            } else if (selectedCurrencyName != 'USD' &&
                itemsPricesCurrencies[selectedItemId] == 'USD') {
              unitPriceControllers[keys[i]]!.text =
                  '${double.parse('${(double.parse(itemUnitPrice[selectedItemId].toString()) * double.parse(exchangeRateForSelectedCurrency))}')}';
            } else {
              var result = exchangeRatesController.exchangeRatesList.firstWhere(
                (item) =>
                    item["currency"] == itemsPricesCurrencies[selectedItemId],
                orElse: () => null,
              );
              var divider = '1';
              if (result != null) {
                divider = result["exchange_rate"].toString();
              }
              var usdPrice =
                  '${double.parse('${(double.parse(itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
              unitPriceControllers[keys[i]]!.text =
                  '${double.parse('${(double.parse(usdPrice) * double.parse(exchangeRateForSelectedCurrency))}')}';
            }
            if (!isBeforeVatPrices) {
              var taxRate = double.parse(itemsVats[selectedItemId]) / 100.0;
              var taxValue =
                  taxRate * double.parse(unitPriceControllers[keys[i]]!.text);

              unitPriceControllers[keys[i]]!.text =
                  '${double.parse(unitPriceControllers[keys[i]]!.text) + taxValue}';
            }
            unitPriceControllers[keys[i]]!.text = double.parse(
              unitPriceControllers[keys[i]]!.text,
            ).toStringAsFixed(2);
            var totalLine =
                '${(int.parse(rowsInListViewInSalesOrder[keys[i]]['item_quantity']) * double.parse(unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(rowsInListViewInSalesOrder[keys[i]]['item_discount']) / 100)}';

            setEnteredUnitPriceInSalesOrder(
              keys[i],
              unitPriceControllers[keys[i]]!.text,
            );
            setMainTotalInSalesOrder(keys[i], totalLine);
            getTotalItems();
          } else {
            rowsInListViewInSalesOrder.remove(keys[i]);
            orderLinesSalesOrderList.remove('${keys[i]}');
            unitPriceControllers.remove(keys[i]);
            decrementListViewLengthInSalesOrder(increment);
          }
        }
      }
    }
    update();
  }

  double listViewLengthInSalesOrder = 50;
  double increment = 60;
  @override
  incrementListViewLengthInSalesOrder(double val) {
    listViewLengthInSalesOrder = listViewLengthInSalesOrder + val;
    update();
  }

  @override
  decrementListViewLengthInSalesOrder(double val) {
    listViewLengthInSalesOrder = listViewLengthInSalesOrder - val;
    update();
  }

  @override
  addToOrderLinesInSalesOrderList(String index, Widget p) {
    orderLinesSalesOrderList[index] = p;
    update();
  }

  @override
  removeFromOrderLinesInSalesOrderList(String index) {
    orderLinesSalesOrderList.remove(index);
    update();
  }

  Map newRowMap = {};
  List<int> orderedKeys = [];
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
  @override
  clearList() {
    rowsInListViewInSalesOrder = {};
    orderedKeys = [];
    update();
  }

  @override
  addToRowsInListViewInSalesOrder(int index, Map p) {
    rowsInListViewInSalesOrder[index] = p;
    orderedKeys.add(index);
    update();
  }

  @override
  removeFromRowsInListViewInSalesOrder(int index) {
    rowsInListViewInSalesOrder.remove(index);
    orderedKeys.remove(index);
    update();
  }

  TextEditingController searchInSalesOrdersController = TextEditingController();
  @override
  setSearchInSalesOrdersController(String value) {
    searchInSalesOrdersController.text = value;
    update();
  }

  List salesOrdersList = [];
  bool isSalesOrderFetched = false;
  @override
  getAllSalesOrderFromBack() async {
    salesOrdersList = [];
    isSalesOrderFetched = false;
    update();
    var p = await getAllSalesOrder(searchInSalesOrdersController.text);
    if ('$p' != '[]') {
      salesOrdersList = p;
      // print(SalesOrdersList.length);
      salesOrdersList = salesOrdersList.reversed.toList();
      // isSalesOrderFetched = true;
    }
    isSalesOrderFetched = true;
    update();
  }

  List salesOrderListPending = [];
  List salesOrderListCC = [];
  List salesOrderListConfirmed = [];
  @override
  getAllSalesOrderFromBackWithoutExcept() async {
    salesOrdersList = [];
    salesOrderListPending = [];
    salesOrderListCC = [];
    isSalesOrderFetched = false;
    update();
    var p = await getAlllSlaesOrderWithoutExcept(
      searchInSalesOrdersController.text,
    );
    if ('$p' != '[]') {
      salesOrdersList = p;
      // print(SalesOrdersList.length);
      salesOrdersList = salesOrdersList.reversed.toList();
      // isSalesOrderFetched = true;
      for (int i = 0; i < salesOrdersList.length; i++) {
        var item = salesOrdersList[i];

        if (item['status'] == 'pending' || item['status'] == 'sent') {
          // Check if this item already exists in SalesOrdersListPending
          bool exists = salesOrderListPending.any(
            (element) => element['id'] == item['id'],
          );

          if (!exists) {
            salesOrderListPending.add(item);
          }
        } else {
          // print("Except");
          continue;
        }
      }
      //list cc
      for (int i = 0; i < salesOrdersList.length; i++) {
        var cc = salesOrdersList[i];

        if (cc['status'] == 'confirmed' || cc['status'] == 'cancelled') {
          // Check if this item already exists in SalesOrdersListPending
          bool existsCC = salesOrderListCC.any(
            (element) => element['id'] == cc['id'],
          );

          if (!existsCC) {
            salesOrderListCC.add(cc);
          }
        } else {
          // print("Except cc");
          continue;
        }
      }
      //list confirmed
      for (int i = 0; i < salesOrdersList.length; i++) {
        var confirm = salesOrdersList[i];

        if (confirm['status'] == 'confirmed' || confirm['status'] == 'sent') {
          // Check if this item already exists in SalesOrdersListPending
          bool existsConfirm = salesOrderListConfirmed.any(
            (element) => element['id'] == confirm['id'],
          );

          if (!existsConfirm) {
            salesOrderListConfirmed.add(confirm);
          }
        } else {
          // print("Exception firm");
          continue;
        }
      }
    }
    isSalesOrderFetched = true;
    update();
  }

  @override
  setSalesOrders(List value) {
    salesOrdersList = value;
    update();
  }

  List salesPersonList = [];
  List<String> salesPersonListNames = [];
  List salesPersonListId = [];
  String salesPersonName = '';
  int salesPersonId = 0;
  @override
  getAllUsersSalesPersonFromBack() async {
    salesOrdersList = [];
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
  //sales order in document

  Map selectedSalesOrderData = {};
  List rowsInListViewInSalesOrderData = [];
  @override
  setSelectedSalesOrder(Map map) {
    selectedSalesOrderData = map;
    update();
  }

  @override
  resetSalesOrderData() {
    rowsInListViewInSalesOrderData = [];
    selectedSalesOrderData = {};
    update();
  }

  @override
  clearRowsInListViewInSalesOrderData() {
    rowsInListViewInSalesOrderData = [];
    update();
  }

  @override
  addToRowsInListViewInSalesOrderData(List p) {
    rowsInListViewInSalesOrderData = p;
    update();
  }
}
