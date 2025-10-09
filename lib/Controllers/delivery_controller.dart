import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/DeliveryBackend/get_all_deliveries.dart';
import 'package:rooster_app/Backend/DeliveryBackend/get_delivery_for_create_field.dart';


import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/const/functions.dart';

abstract class DeliveryControllerAbstract extends GetxController {
  getFieldsForCreateDeliveryFromBack();
  resetItemsAfterChangePriceList();
  incrementListViewLengthInDelivery(double val);
  decrementListViewLengthInDelivery(double val);
  addToOrderLinesInDeliveryList(String index, Widget p);
  removeFromOrderLinesInDeliveryList(String index);
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
  setItemIdInDelivery(int index, String val);
  setItemNameInDelivery(int index, String val);
  setMainCodeInDelivery(int index, String val);
  setTypeInDelivery(int index, String val);
  setTitleInDelivery(int index, String val);
  setNoteInDelivery(int index, String val);
  setImageInDelivery(int index, Uint8List imageFile);
  setMainDescriptionInDelivery(int index, String val);
  setItemWareHouseInDelivery(int index, String val);

  setComboWareHouseInDelivery(int index, String val);
  setEnteredQtyInDelivery(int index, String val);
  setComboInDelivery(int index, String val);
  setEnteredUnitPriceInDelivery(int index, String val);
  setEnteredDiscInDelivery(int index, String val);
  setMainTotalInDelivery(int index, String val);
  getTotalItems();
  setStatus(String val);
  setCompanyVat(double val);
  setLatestRate(double val);
  setComboWarehouseId(int index, String val);
  setVat11();
  setTotalAllDelivery();
  setIsVatExemptChecked(bool val);
  setSelectedCurrency(String id, String name);
  setSelectedCurrencySymbol(String val);
  setExchangeRateForSelectedCurrency(String val);
  changeBoolVar(bool val);
  increaseImageSpace(double val);
  setLogo(Uint8List val);
  setIsBeforeVatPrices(bool val);
  getAllTaxationGroupsFromBack();
  resetDeliveries();
  clearList();
  addToRowsInListViewInDelivery(int index, Map p);
  removeFromRowsInListViewInDelivery(int index);
  setSearchInDeliveryController(String value);
  getAllDeliveryFromBack();
  getAllDeliveryFromBackWithoutExcept();
  getAllUsersSalesPersonFromBack();
  setDeliveries(List value);
  setSelectedDelivery(Map map);
  resetDeliveriesData();
  clearRowsInListViewInDeliveryData();
  addToRowsInListViewInDeliveryData(List p);
  setIsSubmitAndPreviewClicked(bool val);
  setSelectedDriverId(String val);
}

class DeliveryController extends DeliveryControllerAbstract {
  String selectedDriverId = '';
  @override
  setSelectedDriverId(String val) {
    selectedDriverId = val;
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
  setItemIdInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['item_id'] = val;
    update();
  }

  @override
  setItemNameInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['itemName'] = val;
    update();
  }

  @override
  setMainCodeInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['item_main_code'] = val;
    update();
  }

  @override
  setTypeInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['line_type_id'] = val;
    update();
  }

  @override
  setTitleInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['title'] = val;
    update();
  }

  @override
  setNoteInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['note'] = val;
    update();
  }

  @override
  setImageInDelivery(int index, Uint8List imageFile) {
    // print(imageFile);
    rowsInListViewInDelivery[index]['image'] = imageFile;
    update();
  }

  @override
  setMainDescriptionInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['item_description'] = val;
    update();
  }

  @override
  setItemWareHouseInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['item_warehouseId'] = val;
    update();
  }

  @override
  setComboWareHouseInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['combo_warehouseId'] = val;
    update();
  }

  @override
  setEnteredQtyInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['item_quantity'] = val;
    update();
  }

  @override
  setComboInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['combo'] = val;
    update();
  }

  @override
  setComboWarehouseId(int index, String val) {
    rowsInListViewInDelivery[index]['combo_warehouseId'] = val;
    update();
  }

  @override
  setEnteredUnitPriceInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['item_unit_price'] = val;
    update();
  }

  @override
  setEnteredDiscInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['item_discount'] = val;
    update();
  }

  @override
  setMainTotalInDelivery(int index, String val) {
    rowsInListViewInDelivery[index]['item_total'] = val;
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
    if (rowsInListViewInDelivery != {}) {
      totalItems = rowsInListViewInDelivery.values
          .map((item) => double.parse(item['item_total'] ?? '0'))
          .reduce((a, b) => a + b);
    }

    setVat11();
    setTotalAllDelivery();
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
    // taxationGroupsList = [];
    // // taxationGroupsList = {};
    // isTaxationGroupsFetched = false;
    // var p = await getCurrencies();
    // if ('$p' != '[]') {
    //   taxationGroupsList.addAll(p['taxationGroups']);
    //   // print(taxationGroupsList);

    //   for (var tax in taxationGroupsList) {
    //     for (var rate in tax['tax_rates']) {
    //       // ratesInTaxationGroupList[rate['id']] = rate['tax_rate'];
    //       ratesInTaxationGroupList["${rate['id']}"] = rate['tax_rate']; //map
    //     }
    //   }

    //   isTaxationGroupsFetched = true;
    //   update();
    // }

    // isTaxationGroupsFetched = true;
    // update();
  }

  Map<String, Widget> orderLinesDeliveryList = {};
  @override
  resetDeliveries() {
    cashingMethodsNamesList = [];
    cashingMethodsIdsList = [];
    orderLinesDeliveryList = {};
    rowsInListViewInDelivery = {};
    // itemsList = [];
    itemsCode = [];
    itemsIds = [];
    isDeliveredInfoFetched = false;

    totalItems = 0;
    specialDisc = '0';
    globalDisc = '0';
    vatInPrimaryCurrency = '0';
    vat11 = '0';
    totalDelivery = '0.00';
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
    setTotalAllDelivery();
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
    setTotalAllDelivery();
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

  double preTotalDelivery = 0;
  String totalDelivery = '';
  @override
  setTotalAllDelivery() {
    preTotalDelivery = (totalItems - preGlobalDisc - preSpecialDisc) + preVat;
    totalDelivery = preTotalDelivery.toStringAsFixed(2);
    // setVat11();
  }

  bool isVatExemptChecked = false;
  @override
  setIsVatExemptChecked(bool val) {
    isVatExemptChecked = val;
    setVat11();
    setTotalAllDelivery();
    update();
  }

  List<String> cashingMethodsNamesList = [];
  List<String> cashingMethodsIdsList = [];
  List<String> itemsCode = [];
  List itemsIds = [];
  List warehouseIds = [];
  bool isDeliveredInfoFetched = false;
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
  List<String> warehousesName = [];
  List<String> priceListsCodes = [];
  List<String> priceListsNames = [];
  List<String> priceListsIds = [];
  List priceLists = [];
  String selectedPriceListId = '';
  List<String> itemsTotalQuantity = [];
  List<List<String>> itemsMultiPartList = [];
  List<List<String>> warehousesMultiPartList = [];
  Map customersMap = {};
  List<String> customerNameList = [];
  List<String> driverNameList = [];
  List<String> warehousesNameList = [];
  List<String> customerTitleList = [];
  List<String> customerNumberList = [];
  List customersPricesListsIds = [];
  List customerIdsList = [];
  List driverIdsList = [];
  List<List<String>> customersMultiPartList = [];
  String deliveryNumber = '';
  List<String> customerForSplit = [];
  List<String> itemsForSplit = [];
  List<String> warehousesForSplit = [];
  Map itemsDescription = {};
  Map itemsMap = {};
  Map warehousesMap = {};
  Map itemsCodes = {};
  Map itemsNames = {};
  Map combosNames = {};
  Map warehousesNames = {};
  Map warehouseNames = {};
  Map warehousesInfo = {};
  Map warehousesComboInfo = {};
  Map itemUnitPrice = {};
  Map warehouseUnitPrice = {};
  Map itemsVats = {};
  Map warehousesVats = {};
  Map itemsPricesCurrencies = {};
  Map warehousePricesCurrencies = {};
  List<String> combosCodesList = [];
  List<String> combosNamesList = [];
  List<String> combosDescriptionList = [];
  List<String> combosPricesList = [];
  List<String> combosIdsList = [];
  List<List<String>> combosMultiPartList = [];
  List<String> combosForSplit = [];
  Map combosPricesCurrencies = {};
  Map combosMap = {};
  Map<String,List<String>> allCodesForItem={};
  List<String> allCodesForAllItems=[];
  List items=[];
  @override
  getFieldsForCreateDeliveryFromBack() async {
    allCodesForItem={};
     allCodesForAllItems=[];
     items=[];
    combosPricesCurrencies = {};
    combosPricesList = [];
    combosNamesList = [];
    warehousesNameList = [];
    combosIdsList = [];
    combosCodesList = [];
    combosDescriptionList = [];
    combosMultiPartList = [];
    combosForSplit = [];
    cashingMethodsNamesList = [];
    cashingMethodsIdsList = [];
    itemsDescription = {};
    itemsMap = {};
    warehousesMap = {};
    itemsCodes = {};
    itemsNames = {};
    combosNames = {};
    warehousesNames = {};
    warehousesInfo = {};
    itemUnitPrice = {};
    warehouseUnitPrice = {};
    itemsVats = {};
    warehousesVats = {};
    itemsPricesCurrencies = {};
    warehousePricesCurrencies = {};
    deliveryNumber = '';
    customersMap = {};
    customersPricesListsIds = [];
    customerNameList = [];
    driverNameList = [];
    customersMultiPartList = [];
    customerIdsList = [];
    driverIdsList = [];
    customerNumberList = [];
    priceListsCodes = [];
    priceListsNames = [];
    priceListsIds = [];
    priceLists = [];
    selectedPriceListId = '';
    itemsCode = [];
    itemsIds = [];
    warehouseIds = [];
    itemsMap = {};
    combosMap = {};
    itemsMultiPartList = [];
    warehousesMultiPartList = [];
    itemsDes = [];
    itemsName = [];
    warehousesName = [];
    itemsTotalQuantity = [];
    customerForSplit = [];
    itemsForSplit = [];
    warehousesForSplit = [];
    phoneNumber = {};
    email = {};
    clientNumber = {};
    country = {};
    city = {};
    floorAndBuilding = {};
    street = {};
    warehousesInfo = {};
    warehousesComboInfo = {};
    isDeliveredInfoFetched = false;
    var p = await getFieldsForCreateDelivery();
    for (var item in p['items']) {
      items.add(item);
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

    deliveryNumber = p['DeliveryNumber'].toString();

    for (var driver in p['drivers']) {
      driverNameList.add('${driver['name']}');
      driverIdsList.add('${driver['id']}');
    }

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

    // priceLists = p['pricelists'];
    // for (var priceList in p['pricelists']) {
    //   priceListsCodes.add(priceList['code']);
    //   priceListsNames.add(priceList['title']);
    //   priceListsIds.add('${priceList['id']}');
    //   if (priceList['code'] == 'STANDARD') {
    //     selectedPriceListId = '${priceList['id']}';
    //   }
    // }
    // for (var priceList in p['cashingMethods']) {
    //   cashingMethodsNamesList.add(priceList['title']);
    //   cashingMethodsIdsList.add('${priceList['id']}');
    // }
    for (var combo in p['combos']) {
      combosMap["${combo['id']}"] = combo;
      combosPricesCurrencies["${combo['id']}"] = combo['currency']['name'];
      combosCodesList.add(combo['code'] ?? '');
      combosNamesList.add(combo['name'] ?? '');
      combosNames["${combo['id']}"] = combo['name'];
      combosDescriptionList.add(combo['description'] ?? '');
      combosPricesList.add('${combo['price']}');
      combosIdsList.add('${combo['id']}');
      // warehousesComboInfo["${combo['id']}"] = combo['warehouses'];
    }
    for (int i = 0; i < combosCodesList.length; i++) {
      combosForSplit.add(combosCodesList[i]);
      combosForSplit.add(combosNamesList[i]);
      combosForSplit.add(combosDescriptionList[i]);
      combosForSplit.add(combosPricesList[i]);
    }
    combosMultiPartList = splitList(combosForSplit, 4);

    isDeliveredInfoFetched = true;
    update();
  }

  ExchangeRatesController exchangeRatesController = Get.find();
  @override
  resetItemsAfterChangePriceList() async {
    itemsCode = [];
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
    // var res = await getPriceListItems(selectedPriceListId);
    // if (res['success'] == true) {
    //   for (var item in res['data']) {
    //     itemsCode.add('${item['mainCode']}');
    //     itemsIds.add('${item['id']}');
    //     itemsInfo.add(
    //       '${item['mainCode']}, ${item['mainDescription']} , ${item['totalQuantities']} Pcs',
    //     );
    //     itemsDes.add('${item['mainDescription']}');
    //     itemsName.add('${item['item_name']}');
    //     itemsTotalQuantity.add('${item['totalQuantities']}');
    //     itemsMap["${item['id']}"] = item;
    //     itemsDescription["${item['id']}"] = item['mainDescription'];
    //     itemsNames["${item['id']}"] = item['item_name'];
    //     itemsCodes["${item['id']}"] = item['mainCode'];
    //     itemUnitPrice["${item['id']}"] = item['unitPrice'];
    //     itemsPricesCurrencies["${item['id']}"] = item['priceCurrency']['name'];
    //     List helper = item['taxationGroup']['tax_rates'];
    //     helper = helper.reversed.toList();
    //     itemsVats["${item['id']}"] = helper[0]['tax_rate'];
    //     warehousesInfo["${item['id']}"] = item['warehouses'];
    //   }
    //   for (int i = 0; i < itemsCode.length; i++) {
    //     itemsForSplit.add(itemsCode[i]);
    //     itemsForSplit.add(itemsName[i]);
    //     itemsForSplit.add(itemsDes[i]);
    //     itemsForSplit.add('${itemsTotalQuantity[i]} Pcs');
    //   }
    //   itemsMultiPartList = splitList(itemsForSplit, 4);
    //   var keys = unitPriceControllers.keys.toList();
    //   for (int i = 0; i < unitPriceControllers.length; i++) {
    //     var selectedItemId = '${rowsInListViewInDelivery[keys[i]]['item_id']}';
    //     if (selectedItemId != '') {
    //       if (itemUnitPrice.keys.contains(selectedItemId)) {
    //         if (itemsPricesCurrencies[selectedItemId] == selectedCurrencyName) {
    //           unitPriceControllers[keys[i]]!.text =
    //               itemUnitPrice[selectedItemId].toString();
    //         } else if (selectedCurrencyName == 'USD' &&
    //             itemsPricesCurrencies[selectedItemId] != selectedCurrencyName) {
    //           var result = exchangeRatesController.exchangeRatesList.firstWhere(
    //             (item) =>
    //                 item["currency"] == itemsPricesCurrencies[selectedItemId],
    //             orElse: () => null,
    //           );
    //           var divider = '1';
    //           if (result != null) {
    //             divider = result["exchange_rate"].toString();
    //           }
    //           unitPriceControllers[keys[i]]!.text =
    //               '${double.parse('${(double.parse(itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
    //         } else if (selectedCurrencyName != 'USD' &&
    //             itemsPricesCurrencies[selectedItemId] == 'USD') {
    //           unitPriceControllers[keys[i]]!.text =
    //               '${double.parse('${(double.parse(itemUnitPrice[selectedItemId].toString()) * double.parse(exchangeRateForSelectedCurrency))}')}';
    //         } else {
    //           var result = exchangeRatesController.exchangeRatesList.firstWhere(
    //             (item) =>
    //                 item["currency"] == itemsPricesCurrencies[selectedItemId],
    //             orElse: () => null,
    //           );
    //           var divider = '1';
    //           if (result != null) {
    //             divider = result["exchange_rate"].toString();
    //           }
    //           var usdPrice =
    //               '${double.parse('${(double.parse(itemUnitPrice[selectedItemId].toString()) / double.parse(divider))}')}';
    //           unitPriceControllers[keys[i]]!.text =
    //               '${double.parse('${(double.parse(usdPrice) * double.parse(exchangeRateForSelectedCurrency))}')}';
    //         }
    //         if (!isBeforeVatPrices) {
    //           var taxRate = double.parse(itemsVats[selectedItemId]) / 100.0;
    //           var taxValue =
    //               taxRate * double.parse(unitPriceControllers[keys[i]]!.text);

    //           unitPriceControllers[keys[i]]!.text =
    //               '${double.parse(unitPriceControllers[keys[i]]!.text) + taxValue}';
    //         }
    //         unitPriceControllers[keys[i]]!.text = double.parse(
    //           unitPriceControllers[keys[i]]!.text,
    //         ).toStringAsFixed(2);
    //         var totalLine =
    //             '${(int.parse(rowsInListViewInDelivery[keys[i]]['item_quantity']) * double.parse(unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(rowsInListViewInDelivery[keys[i]]['item_discount']) / 100)}';

    //         setEnteredUnitPriceInDelivery(
    //           keys[i],
    //           unitPriceControllers[keys[i]]!.text,
    //         );
    //         setMainTotalInDelivery(keys[i], totalLine);
    //         getTotalItems();
    //       } else {
    //         rowsInListViewInDelivery.remove(keys[i]);
    //         orderLinesDeliveryList.remove('${keys[i]}');
    //         unitPriceControllers.remove(keys[i]);
    //         decrementListViewLengthInDelivery(increment);
    //       }
    //     }
    //   }
    // }
    update();
  }

  double listViewLengthInDelivery = 50;
  double increment = 60;
  @override
  incrementListViewLengthInDelivery(double val) {
    listViewLengthInDelivery = listViewLengthInDelivery + val;
    update();
  }

  @override
  decrementListViewLengthInDelivery(double val) {
    listViewLengthInDelivery = listViewLengthInDelivery - val;
    update();
  }

  @override
  addToOrderLinesInDeliveryList(String index, Widget p) {
    orderLinesDeliveryList[index] = p;
    update();
  }

  @override
  removeFromOrderLinesInDeliveryList(String index) {
    orderLinesDeliveryList.remove(index);
    update();
  }

  Map newRowMap = {};
  Map rowsInListViewInDelivery = {
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
    rowsInListViewInDelivery = {};
    update();
  }

  @override
  addToRowsInListViewInDelivery(int index, Map p) {
    rowsInListViewInDelivery[index] = p;
    update();
  }

  @override
  removeFromRowsInListViewInDelivery(int index) {
    rowsInListViewInDelivery.remove(index);

    update();
  }

  TextEditingController searchInDeliveryController = TextEditingController();
  @override
  setSearchInDeliveryController(String value) {
    searchInDeliveryController.text = value;
    update();
  }

  List deliveryList = [];
  bool isDeliveryFetched = false;
  @override
  getAllDeliveryFromBack() async {
    deliveryList = [];
    isDeliveryFetched = false;
    update();
    var p = await getAllDeliveries(searchInDeliveryController.text);
    if ('$p' != '[]') {
      deliveryList = p;
      // print(deliveryList.length);
      deliveryList = deliveryList.reversed.toList();
      // isDeliveryFetched = true;
    }
    isDeliveryFetched = true;
    update();
  }

  List deliveryListPending = [];
  @override
  getAllDeliveryFromBackWithoutExcept() async {
    deliveryList = [];
    deliveryListPending = [];
    isDeliveryFetched = false;
    update();
    var p = await getAllDeliveriesWithoutExcept(
      searchInDeliveryController.text,
    );
    if ('$p' != '[]') {
      deliveryList = p;
      // print(deliveryList.length);
      deliveryList = deliveryList.reversed.toList();
      // isDeliveryFetched = true;
      for (int i = 0; i < deliveryList.length; i++) {
        var item = deliveryList[i];

        if (item['status'] == 'pending') {
          // Check if this item already exists in deliveryListPending
          bool exists = deliveryListPending.any(
                (element) => element['id'] == item['id'],
          );

          if (!exists) {
            deliveryListPending.add(item);
          }
        } else {
          continue;
        }
      }
    }
    isDeliveryFetched = true;
    update();
  }

  @override
  setDeliveries(List value) {
    deliveryList = value;
    update();
  }

  List salesPersonList = [];
  List<String> salesPersonListNames = [];
  List salesPersonListId = [];
  String salesPersonName = '';
  int salesPersonId = 0;
  @override
  getAllUsersSalesPersonFromBack() async {
    //   deliveryList = [];
    //   isDeliveryFetched = false;
    //   update();
    //   var p = await getAllUsersSalesPerson();
    //   if ('$p' != '[]') {
    //     salesPersonList = p;
    //     for (var salesPerson in salesPersonList) {
    //       salesPersonName = salesPerson['name'];
    //       salesPersonId = salesPerson['id'];
    //       salesPersonListNames.add(salesPersonName);
    //       salesPersonListId.add(salesPersonId);
    //     }
    //   }
    //   isDeliveryFetched = true;
    //   update();
  }
  // sales order in document

  Map selectedDeliveryData = {};
  List rowsInListViewInDeliveryData = [];
  @override
  setSelectedDelivery(Map map) {
    selectedDeliveryData = map;
    update();
  }

  @override
  resetDeliveriesData() {
    rowsInListViewInDeliveryData = [];
    selectedDeliveryData = {};
    update();
  }

  @override
  clearRowsInListViewInDeliveryData() {
    rowsInListViewInDeliveryData = [];
    update();
  }

  @override
  addToRowsInListViewInDeliveryData(List p) {
    rowsInListViewInDeliveryData = p;
    update();
  }
}
