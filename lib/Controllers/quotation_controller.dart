import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/Quotations/get_quotation_create_info.dart';
import 'package:rooster_app/Backend/Quotations/get_quotations.dart';
import 'package:rooster_app/Backend/get_currencies.dart';

import '../Backend/PriceListBackend/get_prices_list_items.dart';
import '../Backend/UsersBackend/get_user.dart';
import '../const/functions.dart';
import 'exchange_rates_controller.dart';

class QuotationController extends GetxController {
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
    setTotalAllQuotation();
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
  Map<int, TextEditingController> combosPriceControllers = {};

  addToUnitPriceControllers(int index) {
    unitPriceControllers[index] = TextEditingController();
    update();
  }

  addToCombosPricesControllers(int index) {
    combosPriceControllers[index] = TextEditingController();
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

  Map<String, Widget> orderLinesQuotationList = {};
  resetQuotation() {
    cashingMethodsNamesList = [];
    cashingMethodsIdsList = [];
    orderLinesQuotationList = {};
    rowsInListViewInQuotation = {};
    // itemsList = [];
    itemsCode = [];
    itemsIds = [];
    isQuotationsInfoFetched = false;

    totalItems = 0;
    specialDisc = '0';
    globalDisc = '0';
    vatInPrimaryCurrency = '0';
    vat11 = '0';
    totalQuotation = '0.00';
    update();
  }

  setQuotations(List value) {
    quotationsList = value;
    update();
  }

  int selectedTabIndex = 0;
  setSelectedTabIndex(int index) {
    selectedTabIndex = index;
    update();
  }

  setSelectedPriceListId(String value) {
    selectedPriceListId = value;
    update();
  }

  String selectedCashingMethodId = '';
  setSelectedCashingMethodId(String value) {
    selectedCashingMethodId = value;
    update();
  }

  List<String> cashingMethodsNamesList = [];
  List<String> cashingMethodsIdsList = [];
  List<String> itemsCode = [];
  List itemsIds = [];
  bool isQuotationsInfoFetched = false;
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
  String quotationNumber = '';
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

  getFieldsForCreateQuotationFromBack() async {
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
    // warehousesList = [];
    itemUnitPrice = {};
    itemsVats = {};
    itemsPricesCurrencies = {};
    quotationNumber = '';
    customersMap = {};
    customersPricesListsIds = [];
    customerNameList = [];
    customersMultiPartList = [];
    customerIdsList = [];
    customerNumberList = [];
    // itemsList = [];
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
    isQuotationsInfoFetched = false;
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
      itemsPricesCurrencies["${item['id']}"] = item['priceCurrency']['name'];
      List helper = item['taxationGroup']['tax_rates'];
      helper = helper.reversed.toList();
      itemsVats["${item['id']}"] = helper[0]['tax_rate'];
      warehousesInfo["${item['id']}"] = item['warehouses'];
    }
    quotationNumber = p['quotationNumber'].toString();

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
      if(priceList['code']=='STANDARD'){
        selectedPriceListId='${priceList['id']}';
      }
    }
    for (var priceList in p['cashingMethods']) {
      cashingMethodsNamesList.add(priceList['title']);
      cashingMethodsIdsList.add('${priceList['id']}');
    }
    for (var combo in p['combos']) {
      combosMap["${combo['id']}"] = combo;
      combosPricesCurrencies["${combo['id']}"] = combo['currency']['name'];
      combosCodesList.add(combo['code']??'');
      combosNamesList.add(combo['name']??'');
      combosDescriptionList.add(combo['description']??'');
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

    isQuotationsInfoFetched = true;
    update();
  }

  ExchangeRatesController exchangeRatesController = Get.find();
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
        var selectedItemId = '${rowsInListViewInQuotation[keys[i]]['item_id']}';
        if (selectedItemId != '') {
          if (itemUnitPrice.keys.contains(selectedItemId)) {
            if (itemsPricesCurrencies[selectedItemId] == selectedCurrencyName) {
              unitPriceControllers[keys[i]]!.text =
                  itemUnitPrice[selectedItemId].toString();
            } else if (selectedCurrencyName == 'USD' &&
                itemsPricesCurrencies[selectedItemId] != selectedCurrencyName) {
              var result = exchangeRatesController.exchangeRatesList.firstWhere(
                (item) => item["currency"] == itemsPricesCurrencies[selectedItemId],
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
                (item) => item["currency"] == itemsPricesCurrencies[selectedItemId],
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
                '${(int.parse(rowsInListViewInQuotation[keys[i]]['item_quantity']) * double.parse(unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(rowsInListViewInQuotation[keys[i]]['item_discount']) / 100)}';

            setEnteredUnitPriceInQuotation(
              keys[i],
              unitPriceControllers[keys[i]]!.text,
            );
            setMainTotalInQuotation(keys[i], totalLine);
            getTotalItems();
          } else {
            rowsInListViewInQuotation.remove(keys[i]);
            orderLinesQuotationList.remove('${keys[i]}');
            unitPriceControllers.remove(keys[i]);
            decrementListViewLengthInQuotation(increment);
          }
        }
      }
    }
    update();
  }

  addToOrderLinesInQuotationList(String index, Widget p) {
    orderLinesQuotationList[index] = p;
    update();
  }

  removeFromOrderLinesInQuotationList(String index) {
    orderLinesQuotationList.remove(index);
    update();
  }

  Map newRowMap = {};
  Map rowsInListViewInQuotation = {
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
    rowsInListViewInQuotation = {};
    update();
  }

  addToRowsInListViewInQuotation(int index, Map p) {
    rowsInListViewInQuotation[index] = p;
    update();
  }

  removeFromRowsInListViewInQuotation(int index) {
    rowsInListViewInQuotation.remove(index);

    update();
  }

  setItemIdInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['item_id'] = val;
    update();
  }

  setItemNameInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['itemName'] = val;
    update();
  }

  setMainCodeInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['item_main_code'] = val;
    update();
  }

  setTypeInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['line_type_id'] = val;
    update();
  }

  setTitleInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['title'] = val;
    update();
  }

  setNoteInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['note'] = val;
    update();
  }

  // setImageInQuotation(int index, String val) {
  setImageInQuotation(int index, Uint8List imageFile) {
    // print(imageFile);
    rowsInListViewInQuotation[index]['image'] = imageFile;
    update();
  }

  setMainDescriptionInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['item_description'] = val;
    update();
  }

  setEnteredQtyInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['item_quantity'] = val;
    update();
  }

  setComboInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['combo'] = val;
    update();
  }

  setEnteredUnitPriceInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['item_unit_price'] = val;
    update();
  }

  setEnteredDiscInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['item_discount'] = val;
    update();
  }

  setMainTotalInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['item_total'] = val;
    update();
  }

  double totalItems = 0.0;
  double totalAfterGlobalDis = 0.0;
  double totalAfterGlobalSpecialDis = 0.0;
  bool updateItem = false;

  String totalItem = '';
  getTotalItems() {
    if (rowsInListViewInQuotation != {}) {
      totalItems = rowsInListViewInQuotation.values
          .map((item) => double.parse(item['item_total'] ?? '0'))
          .reduce((a, b) => a + b);
    }

    setVat11();
    setTotalAllQuotation();
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
    setTotalAllQuotation();
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
    setTotalAllQuotation();
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

  double preTotalQuotation = 0;
  String totalQuotation = '';

  setTotalAllQuotation() {
    preTotalQuotation = (totalItems - preGlobalDisc - preSpecialDisc) + preVat;
    totalQuotation = preTotalQuotation.toStringAsFixed(2);
    // setVat11();
  }

  double listViewLengthInQuotation = 50;
  double increment = 60;
  incrementListViewLengthInQuotation(double val) {
    listViewLengthInQuotation = listViewLengthInQuotation + val;
    update();
  }

  decrementListViewLengthInQuotation(double val) {
    listViewLengthInQuotation = listViewLengthInQuotation - val;
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

  //Quotations  summary section
  TextEditingController searchInQuotationsController = TextEditingController();
  List quotationsList = [];
  bool isQuotationsFetched = false;
  getAllQuotationsFromBack() async {
    quotationsList = [];
    isQuotationsFetched = false;
    update();
    var p = await getAllQuotation(searchInQuotationsController.text);
    if ('$p' != '[]') {
      quotationsList = p;
      // print(quotationsList.length);
      quotationsList = quotationsList.reversed.toList();
      // isQuotationsFetched = true;
    }
    isQuotationsFetched = true;
    update();
  }

  //quotation in document

  Map selectedQuotationData = {};
  List rowsInListViewInQuotationData = [];

  setSelectedQuotation(Map map) {
    selectedQuotationData = map;
    update();
  }

  resetQuotationData() {
    rowsInListViewInQuotationData = [];
    selectedQuotationData = {};
    update();
  }

  clearRowsInListViewInQuotationData() {
    rowsInListViewInQuotationData = [];
    update();
  }

  addToRowsInListViewInQuotationData(List p) {
    rowsInListViewInQuotationData = p;
    update();
  }

  List salesPersonList = [];
  List<String> salesPersonListNames = [];
  List salesPersonListId = [];
  String salesPersonName = '';
  int salesPersonId = 0;
  getAllUsersSalesPersonFromBack() async {
    quotationsList = [];
    isQuotationsFetched = false;
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
    isQuotationsFetched = true;
    update();
  }
}
