import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/PriceListBackend/get_prices_list_items.dart';
import 'package:rooster_app/Backend/SalesInvoiceBackend/get_sales_invoices.dart';
import 'package:rooster_app/Backend/SalesInvoiceBackend/get_sales_invoice_create_info.dart';

import 'package:rooster_app/Backend/UsersBackend/get_user.dart';
import 'package:rooster_app/Backend/get_currencies.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/const/functions.dart';

abstract class SalesInvoiceControllerAbstract extends GetxController {
  getFieldsForCreateSalesInvoiceFromBack();
  resetItemsAfterChangePriceList();
  incrementListViewLengthInSalesInvoice(double val);
  decrementListViewLengthInSalesInvoice(double val);
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
  setItemIdInSalesInvoice(int index, String val);
  setItemNameInSalesInvoice(int index, String val);
  setItemWareHouseInSalesInvoice(int index, String val);
  setMainCodeInSalesInvoice(int index, String val);
  setTypeInSalesInvoice(int index, String val);
  setTitleInSalesInvoice(int index, String val);
  setNoteInSalesInvoice(int index, String val);
  setImageInSalesInvoice(int index, Uint8List imageFile);
  setMainDescriptionInSalesInvoice(int index, String val);
  setEnteredQtyInSalesInvoice(int index, String val);
  setComboInSalesInvoice(int index, String val);
  setEnteredUnitPriceInSalesInvoice(int index, String val);
  setEnteredDiscInSalesInvoice(int index, String val);
  setMainTotalInSalesInvoice(int index, String val);
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
  resetSalesInvoice();
  clearList();
  addToRowsInListViewInSalesInvoice(int index, Map p);
  removeFromRowsInListViewInSalesInvoice(int index);
  setSearchInSalesInvoicesController(String value);
  getAllSalesInvoiceFromBack();
  getAllSalesInvoiceFromBackWithoutExcept();
  getAllUsersSalesPersonFromBack();
  setSalesInvoices(List value);
  setSelectedSalesInvoice(Map map);
  resetSalesInvoiceData();
  clearRowsInListViewInSalesInvoiceData();
  addToRowsInListViewInSalesInvoiceData(List p);
  setIsSubmitAndPreviewClicked(bool val);
  setSelectedWarehouseId(String val);
}

class SalesInvoiceController extends SalesInvoiceControllerAbstract {
  String selectedPaymentTermId='';
  setSelectedPaymentTermId(String val) {
    selectedPaymentTermId = val;
    update();
  }

  List<Map> headersList=[];
  int selectedHeaderIndex = 1;
  Map selectedHeader={};
  setSelectedHeaderIndex(int val){
    selectedHeaderIndex=val;
    update();
  }
  setSelectedHeader(Map val){
    print('header is $val');
    selectedHeader=val;
    update();
  }

  int selectedTypeIndex = 1;
  String selectedInvoiceType='real';
  setSelectedTypeIndex(int val){
    selectedTypeIndex=val;
    update();
  }
  setSelectedType(String val){
    selectedInvoiceType=val;
    update();
  }

  int salesInvoiceCounter = 0;
  setSalesInvoiceCounter(int val){
    salesInvoiceCounter=val;
    update();
  }
  TextEditingController warehouseMenuController = TextEditingController();
  String selectedWarehouseId = '';
  @override
  setSelectedWarehouseId(String val) {
    selectedWarehouseId = val;
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

  Map selectedSalesInvoiceData = {};
  List rowsInListViewInSalesInvoiceData = [];
  // Map newRowMap = {};
  List<int> orderedKeys = [];
  Map rowsInListViewInSalesInvoice = {
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
  setItemIdInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_id'] = val;
    update();
  }

  @override
  setItemNameInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['itemName'] = val;
    update();
  }

  @override
  setItemWareHouseInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_WarehouseId'] = val;
    update();
  }

  @override
  setMainCodeInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_main_code'] = val;
    update();
  }

  @override
  setTypeInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['line_type_id'] = val;
    update();
  }

  @override
  setTitleInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['title'] = val;
    update();
  }

  @override
  setNoteInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['note'] = val;
    update();
  }

  @override
  setImageInSalesInvoice(int index, Uint8List imageFile) {
    // print(imageFile);
    rowsInListViewInSalesInvoice[index]['image'] = imageFile;
    update();
  }

  @override
  setMainDescriptionInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_description'] = val;
    update();
  }

  @override
  setEnteredQtyInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_quantity'] = val;
    update();
  }

  @override
  setComboInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['combo'] = val;
    update();
  }

  @override
  setEnteredUnitPriceInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_unit_price'] = val;
    update();
  }

  @override
  setEnteredDiscInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_discount'] = val;
    update();
  }

  @override
  setMainTotalInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_total'] = val;
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
    if (rowsInListViewInSalesInvoice != {}) {
      totalItems = rowsInListViewInSalesInvoice.values
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

  @override
  resetSalesInvoice() {
    cashingMethodsNamesList = [];
    cashingMethodsIdsList = [];
    rowsInListViewInSalesInvoice = {};
    orderedKeys = [];
    itemsCode = [];
    itemsIds = [];
    isSalesInvoiceInfoFetched = false;

    totalItems = 0;
    specialDisc = '0';
    globalDisc = '0';
    vatInPrimaryCurrency = '0';
    vat11 = '0';
    totalSalesInvoice = '0.00';
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

  double preTotalSalesInvoice = 0;
  String totalSalesInvoice = '';
  @override
  setTotalAllSalesOrder() {
    preTotalSalesInvoice =
        (totalItems - preGlobalDisc - preSpecialDisc) + preVat;
    totalSalesInvoice = preTotalSalesInvoice.toStringAsFixed(2);
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
  bool isSalesInvoiceInfoFetched = false;
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
  List customersSalesPersonsIds = [];
  List customerIdsList = [];
  List<List<String>> customersMultiPartList = [];
  String salesInvoiceNumber = '';
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
  @override
  getFieldsForCreateSalesInvoiceFromBack() async {
    headersList = [];
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
    salesInvoiceNumber = '';
    customersMap = {};
    customersPricesListsIds = [];
    customersSalesPersonsIds = [];
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
    isSalesInvoiceInfoFetched = false;
    var p = await getFieldsForCreateSalesInvoice();
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
    salesInvoiceNumber = p['salesInvoiceNumber'].toString();

    for (var client in p['clients']) {
      customersMap['${client['id']}'] = client;
      customersPricesListsIds.add('${client['pricelist_id'] ?? ''}');
      customersSalesPersonsIds.add('${client['salesperson_id'] ?? ''}');
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

    for (var header in p['companyHeaders'] ?? []) {
      headersList.add(header);
    }
    // if(headersList.isNotEmpty && headersList[0].isNotEmpty) {
    //   setQuotationCurrency(headersList[0]);
    // }

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

    isSalesInvoiceInfoFetched = true;
    update();
    resetItemsAfterChangePriceList();
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
            '${rowsInListViewInSalesInvoice[keys[i]]['item_id']}';
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
                '${(int.parse(rowsInListViewInSalesInvoice[keys[i]]['item_quantity']) * double.parse(unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(rowsInListViewInSalesInvoice[keys[i]]['item_discount']) / 100)}';

            setEnteredUnitPriceInSalesInvoice(
              keys[i],
              unitPriceControllers[keys[i]]!.text,
            );
            setMainTotalInSalesInvoice(keys[i], totalLine);
            getTotalItems();
          } else {
            rowsInListViewInSalesInvoice.remove(keys[i]);
            unitPriceControllers.remove(keys[i]);
            decrementListViewLengthInSalesInvoice(increment);
          }
        }
      }
    }
    update();
  }

  double listViewLengthInSalesInvoice = 50;
  double increment = 60;
  @override
  incrementListViewLengthInSalesInvoice(double val) {
    listViewLengthInSalesInvoice = listViewLengthInSalesInvoice + val;
    update();
  }

  @override
  decrementListViewLengthInSalesInvoice(double val) {
    listViewLengthInSalesInvoice = listViewLengthInSalesInvoice - val;
    update();
  }


  @override
  clearList() {
    rowsInListViewInSalesInvoice = {};
    orderedKeys = [];
    update();
  }

  @override
  addToRowsInListViewInSalesInvoice(int index, Map p) {
    rowsInListViewInSalesInvoice[index] = p;
    orderedKeys.add(index);
    update();
  }

  @override
  removeFromRowsInListViewInSalesInvoice(int index) {
    rowsInListViewInSalesInvoice.remove(index);
    orderedKeys.remove(index);
    update();
  }

  TextEditingController searchInSalesInvoicesController =
      TextEditingController();
  @override
  setSearchInSalesInvoicesController(String value) {
    searchInSalesInvoicesController.text = value;
    update();
  }

  List salesInvoicesList1 = [];
  bool isSalesInvoiceFetched = false;
  @override
  getAllSalesInvoiceFromBack() async {
    salesInvoicesList1 = [];
    isSalesInvoiceFetched = false;
    update();
    var p = await getAllSalesInvoice(searchInSalesInvoicesController.text);
    if ('$p' != '[]') {
      salesInvoicesList1 = p;
      // print(SalesInvoicesList.length);
      salesInvoicesList1 = salesInvoicesList1.reversed.toList();
      // isSalesInvoiceFetched = true;
    }
    isSalesInvoiceFetched = true;
    update();
  }

  List salesInvoicesList2 = [];
  List salesInvoiceListPending = [];
  List salesInvoicesListCC = [];
  @override
  getAllSalesInvoiceFromBackWithoutExcept() async {
    salesInvoicesList2 = [];
    salesInvoiceListPending = [];
    isSalesInvoiceFetched = false;
    update();
    var p = await getAllSalesInvoiceWithoutExcept(
      searchInSalesInvoicesController.text,
    );
    if ('$p' != '[]') {
      salesInvoicesList2 = p;
      // print(SalesInvoicesList.length);
      salesInvoicesList2 = salesInvoicesList2.reversed.toList();
      // isSalesInvoiceFetched = true;
      for (int i = 0; i < salesInvoicesList2.length; i++) {
        var item = salesInvoicesList2[i];

        if (item['status'] == 'pending') {
          // Check if this item already exists in SalesInvoices List  pending
          bool exists = salesInvoiceListPending.any(
            (element) => element['id'] == item['id'],
          );

          if (!exists) {
            salesInvoiceListPending.add(item);
          }
        } else {
          continue;
        }
      }
      //list cc
      for (int i = 0; i < salesInvoicesList2.length; i++) {
        var cc = salesInvoicesList2[i];

        if (cc['status'] == 'confirmed' || cc['status'] == 'cancelled'  || cc['status'] == 'pending' ) {
          // Check if this item already exists in SalesOrders List pending
          bool existsCC = salesInvoicesListCC.any(
            (element) => element['id'] == cc['id'],
          );

          if (!existsCC) {
            salesInvoicesListCC.add(cc);
          }
        } else {
          continue;
        }
      }
    }
    isSalesInvoiceFetched = true;
    update();
  }

  @override
  setSalesInvoices(List value) {
    salesInvoicesList2 = value;
    update();
  }

  List salesPersonList = [];
  List<String> salesPersonListNames = [];
  List salesPersonListId = [];
  String salesPersonName = '';
  int salesPersonId = 0;
  @override
  getAllUsersSalesPersonFromBack() async {
    salesInvoicesList2 = [];
    isSalesInvoiceFetched = false;
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
    isSalesInvoiceFetched = true;
    update();
  }
  //sales order in document

  @override
  setSelectedSalesInvoice(Map map) {
    selectedSalesInvoiceData = map;
    update();
  }

  @override
  resetSalesInvoiceData() {
    rowsInListViewInSalesInvoiceData = [];
    selectedSalesInvoiceData = {};
    update();
  }

  @override
  clearRowsInListViewInSalesInvoiceData() {
    rowsInListViewInSalesInvoiceData = [];
    update();
  }

  @override
  addToRowsInListViewInSalesInvoiceData(List p) {
    rowsInListViewInSalesInvoiceData = p;
    update();
  }
}
