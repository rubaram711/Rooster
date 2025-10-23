import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/PriceListBackend/get_prices_list_items.dart';
import 'package:rooster_app/Backend/SalesInvoiceBackend/get_sales_invoices.dart';
import 'package:rooster_app/Backend/SalesInvoiceBackend/get_sales_invoice_create_info.dart';

import 'package:rooster_app/Backend/UsersBackend/get_user.dart';
import 'package:rooster_app/Backend/get_currencies.dart';
import 'package:rooster_app/Controllers/combo_controller.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/const/functions.dart';


class SalesInvoiceController extends GetxController {
  String selectedPaymentTermId = '';
  setSelectedPaymentTermId(String val) {
    selectedPaymentTermId = val;
    update();
  }

  List<Map> headersList = [];
  int selectedHeaderIndex = 1;
  Map selectedHeader = {};
  setSelectedHeaderIndex(int val) {
    selectedHeaderIndex = val;
    update();
  }

  setSelectedHeader(Map val) {
    selectedHeader = val;
    update();
  }

  int selectedTypeIndex = 1;
  String selectedInvoiceType = 'real';
  setSelectedTypeIndex(int val) {
    selectedTypeIndex = val;
    update();
  }

  setSelectedType(String val) {
    selectedInvoiceType = val;
    update();
  }

  int salesInvoiceCounter = 0;
  setSalesInvoiceCounter(int val) {
    salesInvoiceCounter = val;
    update();
  }

  TextEditingController warehouseMenuController = TextEditingController();
  String selectedWarehouseId = '';

  setSelectedWarehouseId(String val) {
    selectedWarehouseId = val;
    update();
  }

  bool isSubmitAndPreviewClicked = false;

  setIsSubmitAndPreviewClicked(bool val) {
    isSubmitAndPreviewClicked = val;
    update();
  }

  String status = '';

  setStatus(String val) {
    status = val;
    update();
  }

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

  setItemIdInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_id'] = val;
    update();
  }


  setItemNameInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['itemName'] = val;
    update();
  }


  setItemWareHouseInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_WarehouseId'] = val;
    update();
  }


  setMainCodeInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_main_code'] = val;
    update();
  }


  setTypeInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['line_type_id'] = val;
    update();
  }


  setTitleInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['title'] = val;
    update();
  }


  setNoteInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['note'] = val;
    update();
  }


  setImageInSalesInvoice(int index, Uint8List imageFile) {
    // print(imageFile);
    rowsInListViewInSalesInvoice[index]['image'] = imageFile;
    update();
  }


  setMainDescriptionInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_description'] = val;
    update();
  }


  setEnteredQtyInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_quantity'] = val;
    update();
  }


  setComboInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['combo'] = val;
    update();
  }


  setEnteredUnitPriceInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_unit_price'] = val;
    update();
  }


  setEnteredDiscInSalesInvoice(int index, String val) {
    rowsInListViewInSalesInvoice[index]['item_discount'] = val;
    update();
  }


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

  getTotalItems() {
    if (rowsInListViewInSalesInvoice != {}) {
      totalItems = rowsInListViewInSalesInvoice.values
          .map((item) => double.parse(item['item_total'] ?? '0'))
          .reduce((a, b) => a + b);
    }


    setTotalSalesInvoiceAfterVat();
    if(globalDiscountPercentageValue != '' || globalDiscountPercentageValue != '0') {
      setGlobalDisc(globalDiscountPercentageValue);
    }
    if((specialDiscountPercentageValue !='' || specialDiscountPercentageValue !='0') && (globalDiscountPercentageValue == ''||  globalDiscountPercentageValue == '0') )
    {
      setSpecialDisc(specialDiscountPercentageValue);
    }
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


  resetSalesInvoice() {
    cashingMethodsNamesList = [];
    cashingMethodsIdsList = [];
    rowsInListViewInSalesInvoice = {};
    orderedKeys = [];
    itemsCode = [];
    itemsIds = [];
    isSalesInvoiceInfoFetched = false;

    totalItems = 0;
    specialDiscAmount.text = '';
    globalDiscountAmount.text = '';
    // vatInPrimaryCurrency = '0';
    // vat11 = '0';
    totalSalesInvoice = '0.00';
    update();
  }


  setSelectedPriceListId(String value) {
    selectedPriceListId = value;
    update();
  }

  bool isVatExemptCheckBoxShouldAppear = true;

  setIsVatExemptCheckBoxShouldAppear(bool val) {
    isVatExemptCheckBoxShouldAppear = val;
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

  String selectedCashingMethodId = '';

  setSelectedCashingMethodId(String value) {
    selectedCashingMethodId = value;
    update();
  }

  double preGlobalDisc = 0.0; //GlobalDisc as double used in calc
  TextEditingController globalDiscountAmount = TextEditingController(); // GlobalDisc as int to show it in ui
  String globalDiscountPercentageValue = '';


  setGlobalDisc(String globalDiscountPercentage) {
    if(globalDiscountPercentage!='0') {
      globalDiscountPercentageValue = globalDiscountPercentage;
      preGlobalDisc =
          (totalItems) * double.parse(globalDiscountPercentageValue) / 100;
      globalDiscountAmount.text = preGlobalDisc.toStringAsFixed(2);

      totalAfterGlobalDis = totalItems - preGlobalDisc;
      totalAfterGlobalSpecialDis = totalAfterGlobalDis - preSpecialDisc;
      setSpecialDisc(specialDiscountPercentageValue);
      setTotalSalesInvoiceAfterVat();
      update();
    }
  }

  setGlobalDiscPercentage(String globalDiscountAmount) {
    if(globalDiscountAmount!='0') {
      preGlobalDisc=double.parse(globalDiscountAmount);
      globalDiscountPercentageValue =
          ((double.parse(globalDiscountAmount) / totalItems) * 100)
              .toStringAsFixed(2);
      // preGlobalDisc =
      //     (totalItems) * double.parse(globalDiscountPercentageValue) / 100;
      // globalDiscountAmount.text = preGlobalDisc.toStringAsFixed(2);

      totalAfterGlobalDis = totalItems - preGlobalDisc;
      totalAfterGlobalSpecialDis = totalAfterGlobalDis - preSpecialDisc;
      setSpecialDisc(specialDiscountPercentageValue);
      // setVat11();
      setTotalSalesInvoiceAfterVat();
      update();
    }
  }

  double preSpecialDisc = 0.0;
  TextEditingController specialDiscAmount = TextEditingController();
  String specialDiscountPercentageValue = '0';

  setSpecialDisc(String specialDiscountPercentage) {
    if(specialDiscountPercentage!='0') {
      specialDiscountPercentageValue = specialDiscountPercentage;
      preSpecialDisc =
          totalAfterGlobalDis *
              double.parse(specialDiscountPercentageValue) /
              100;
      specialDiscAmount.text = preSpecialDisc.toStringAsFixed(2);
      totalAfterGlobalSpecialDis = totalAfterGlobalDis - preSpecialDisc;

      setTotalSalesInvoiceAfterVat();
      update();
    }
  }
  setSpecialDiscPercentage(String specialDiscountAmount) {
    if(specialDiscountAmount!='0') {
      preSpecialDisc=double.parse(specialDiscountAmount);
      specialDiscountPercentageValue =
          ((double.parse(specialDiscountAmount) / totalItems) * 100)
              .toStringAsFixed(2);
      totalAfterGlobalSpecialDis = totalAfterGlobalDis - preSpecialDisc;
      setTotalSalesInvoiceAfterVat();
      update();
    }
  }


  double preVatInPrimaryCurrency = 0.0;
  double latestRate = 1;
  String companyPrimaryCurrency = 'USD';
  setCompanyPrimaryCurrency(String val) {
    companyPrimaryCurrency = val;
    update();
  }


  setCompanyVat(double val) {
    companyVat=val;
    setTotalSalesInvoiceAfterVat();
    update();
  }


  setLatestRate(double val) {
    latestRate = val;
    update();
  }



  double preTotalSalesInvoice = 0;
  String totalSalesInvoice = '';
  double vatInSalesInvoiceCurrency = 0.0;
  setTotalSalesInvoiceAfterVat() {
    // preTotalSalesInvoice =
    //     (totalItems - preGlobalDisc - preSpecialDisc) + preVat;
    // totalSalesInvoice = preTotalSalesInvoice.toStringAsFixed(2);
    var valueBeforeVat=(totalItems - preGlobalDisc - preSpecialDisc);
    if(companyVat==0 ||  isPrintedAsVatExempt
        || isPrintedAs0
        || isVatNoPrinted){
      companyVat=0;
      vatInSalesInvoiceCurrency=0;
      totalSalesInvoice = valueBeforeVat.toStringAsFixed(2);
    }else{
      vatInSalesInvoiceCurrency=double.parse((valueBeforeVat * (companyVat/100)).toStringAsFixed(2));
      preTotalSalesInvoice = valueBeforeVat + vatInSalesInvoiceCurrency;
      totalSalesInvoice = preTotalSalesInvoice.toStringAsFixed(2);
    }
  }

  bool isVatExemptChecked = false;

  setIsVatExemptChecked(bool val) {
    isVatExemptChecked = val;
    setTotalSalesInvoiceAfterVat();
    update();
  }

  List<String> cashingMethodsNamesList = [];
  List<String> cashingMethodsIdsList = [];
  List<String> itemsCode = [];
  List itemsIds = [];
  bool isSalesInvoiceInfoFetched = false;
  Map email = {};
  Map phoneNumber = {};
  Map mobileNumber = {};
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
  // List<String> combosCodesList = [];
  // List<String> combosNamesList = [];
  // List<String> combosDescriptionList = [];
  // List<String> combosPricesList = [];
  // List<String> combosIdsList = [];
  // List<List<String>> combosMultiPartList = [];
  // List<String> combosForSplit = [];
  // Map combosPricesCurrencies = {};
  // Map combosMap = {};
  Map<String,List<String>> allCodesForItem={};
  List<String> allCodesForAllItems=[];
  List items=[];

  getFieldsForCreateSalesInvoiceFromBack() async {
    headersList = [];
    // combosPricesCurrencies = {};
    // combosPricesList = [];
    // combosNamesList = [];
    // combosIdsList = [];
    // combosCodesList = [];
    // combosDescriptionList = [];
    // combosMultiPartList = [];
    // combosForSplit = [];
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
    // combosMap = {};
    // itemsMultiPartList = [];
    itemsDes = [];
    itemsName = [];
    itemsTotalQuantity = [];
    customerForSplit = [];
    itemsForSplit = [];
    phoneNumber = {};
    mobileNumber = {};
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
      phoneNumber["${client['id']}"] = '${client['phone_code'] ?? ''}-${client['phone_number'] ?? ''}';
      mobileNumber["${client['id']}"] =  '${client['mobile_code'] ?? ''}-${client['mobile_number'] ?? ''}';
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

    // for (int i = 0; i < itemsCode.length; i++) {
    //   itemsForSplit.add(itemsCode[i]);
    //   itemsForSplit.add(itemsName[i]);
    //   itemsForSplit.add(itemsDes[i]);
    //   itemsForSplit.add('${itemsTotalQuantity[i]} Pcs');
    // }
    // itemsMultiPartList = splitList(itemsForSplit, 4);

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
    if(headersList.isNotEmpty && headersList[0].isNotEmpty) {
      setQuotationCurrency(headersList[0]);
    }

    for (var priceList in p['cashingMethods']) {
      cashingMethodsNamesList.add(priceList['title']);
      cashingMethodsIdsList.add('${priceList['id']}');
    }
    // for (var combo in p['combos']) {
    //   combosMap["${combo['id']}"] = combo;
    //   combosPricesCurrencies["${combo['id']}"] = combo['currency']['name'];
    //   combosCodesList.add(combo['code'] ?? '');
    //   combosNamesList.add(combo['name'] ?? '');
    //   combosDescriptionList.add(combo['description'] ?? '');
    //   combosPricesList.add('${combo['price']}');
    //   combosIdsList.add('${combo['id']}');
    // }
    // for (int i = 0; i < combosCodesList.length; i++) {
    //   combosForSplit.add(combosCodesList[i]);
    //   combosForSplit.add(combosNamesList[i]);
    //   combosForSplit.add(combosDescriptionList[i]);
    //   combosForSplit.add(combosPricesList[i]);
    // }
    // combosMultiPartList = splitList(combosForSplit, 4);

    isSalesInvoiceInfoFetched = true;
    update();
    comboController.getCombosForQuotation();
    resetItemsAfterChangePriceList();
  }

  ExchangeRatesController exchangeRatesController = Get.find();
  ComboController comboController = Get.find();

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
    allCodesForItem={};
    allCodesForAllItems=[];
    items=[];
    var res = await getPriceListItems(selectedPriceListId);
    if (res['success'] == true) {
      for (var item in res['data']) {
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
        List helper =item['taxationGroup'] !=null? item['taxationGroup']['tax_rates']:[];
        helper = helper.reversed.toList();
        itemsVats["${item['id']}"] =helper.isNotEmpty? helper[0]['tax_rate']:'1';
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
                '${(double.parse(rowsInListViewInSalesInvoice[keys[i]]['item_quantity']) * double.parse(unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(rowsInListViewInSalesInvoice[keys[i]]['item_discount']) / 100)}';

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

  incrementListViewLengthInSalesInvoice(double val) {
    listViewLengthInSalesInvoice = listViewLengthInSalesInvoice + val;
    update();
  }


  decrementListViewLengthInSalesInvoice(double val) {
    listViewLengthInSalesInvoice = listViewLengthInSalesInvoice - val;
    update();
  }


  clearList() {
    rowsInListViewInSalesInvoice = {};
    orderedKeys = [];
    update();
  }


  addToRowsInListViewInSalesInvoice(int index, Map p) {
    rowsInListViewInSalesInvoice[index] = p;
    orderedKeys.add(index);
    update();
  }


  removeFromRowsInListViewInSalesInvoice(int index) {
    rowsInListViewInSalesInvoice.remove(index);
    orderedKeys.remove(index);
    update();
  }

  TextEditingController searchInSalesInvoicesController =
      TextEditingController();

  setSearchInSalesInvoicesController(String value) {
    searchInSalesInvoicesController.text = value;
    update();
  }

  List salesInvoicesList1 = [];
  bool isSalesInvoiceFetched = false;

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

        if (cc['status'] == 'confirmed' ||
            cc['status'] == 'cancelled' ||
            cc['status'] == 'pending') {
          // Check if this item already exists in Sales Invoice List pending
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


  setSalesInvoices(List value) {
    salesInvoicesList2 = value;
    update();
  }

  List salesPersonList = [];
  List<String> salesPersonListNames = [];
  List salesPersonListId = [];
  String salesPersonName = '';
  int salesPersonId = 0;

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



  setSelectedSalesInvoice(Map map) {
    selectedSalesInvoiceData = map;
    update();
  }


  resetSalesInvoiceData() {
    rowsInListViewInSalesInvoiceData = [];
    selectedSalesInvoiceData = {};
    update();
  }


  clearRowsInListViewInSalesInvoiceData() {
    rowsInListViewInSalesInvoiceData = [];
    update();
  }

  addToRowsInListViewInSalesInvoiceData(List p) {
    rowsInListViewInSalesInvoiceData = p;
    update();
  }

  TextEditingController currencyController = TextEditingController();
  setQuotationCurrency(Map header) {
    if (header['default_quotation_currency'] != null) {
      exchangeRateForSelectedCurrency =
          header['default_quotation_currency']['latest_rate'];
      selectedCurrencyId = '${header['default_quotation_currency']['id']}';
      selectedCurrencySymbol = header['default_quotation_currency']['symbol'];
      selectedCurrencyName = header['default_quotation_currency']['name'];
      currencyController.text = header['default_quotation_currency']['name'];
      setPriceAsCurrency(header['default_quotation_currency']['name']);
      update();
    }
  }

  setPriceAsCurrency(String val) {
    var keys = unitPriceControllers.keys.toList();
    for (int i = 0; i < unitPriceControllers.length; i++) {
      var selectedItemId =
          '${rowsInListViewInSalesInvoice[keys[i]]['item_id']}';
      if (selectedItemId != '') {
        if (itemsPricesCurrencies[selectedItemId] == val) {
          unitPriceControllers[keys[i]]!.text =
              itemUnitPrice[selectedItemId].toString();
        } else if (val == 'USD' &&
            itemsPricesCurrencies[selectedItemId] != val) {
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
            '${(double.parse(rowsInListViewInSalesInvoice[keys[i]]['item_quantity']) * double.parse(unitPriceControllers[keys[i]]!.text)) * (1 - double.parse(rowsInListViewInSalesInvoice[keys[i]]['item_discount']) / 100)}';
        setEnteredUnitPriceInSalesInvoice(
          keys[i],
          unitPriceControllers[keys[i]]!.text,
        );
        setMainTotalInSalesInvoice(keys[i], totalLine);
        getTotalItems();
      }
    }
    var comboKeys =
    combosPriceControllers
        .keys
        .toList();
    for (
    int i = 0;
    i <
        combosPriceControllers
            .length;
    i++
    ) {
      var selectedComboId =
          '${rowsInListViewInSalesInvoice[comboKeys[i]]['combo']}';
      if (selectedComboId != '') {
        var ind = comboController
            .combosIdsList
            .indexOf(
          selectedComboId,
        );
        if (comboController
            .combosPricesCurrencies[selectedComboId] ==
            selectedCurrencyName) {
          combosPriceControllers[comboKeys[i]]!
              .text = comboController
              .combosPricesList[ind]
              .toString();
        } else if (selectedCurrencyName ==
            'USD' &&
            comboController.combosPricesCurrencies[selectedComboId] !=
                selectedCurrencyName) {
          var result = exchangeRatesController
              .exchangeRatesList
              .firstWhere(
                (item) =>
            item["currency"] ==
                comboController
                    .combosPricesCurrencies[selectedComboId],
            orElse: () => null,
          );
          var divider = '1';
          if (result != null) {
            divider =
                result["exchange_rate"]
                    .toString();
          }
          combosPriceControllers[comboKeys[i]]!
              .text =
          '${double.parse('${(double.parse(
              comboController.combosPricesList[ind].toString()) /
              double.parse(divider))}')}';
        } else if (selectedCurrencyName !=
            'USD' &&
            comboController.combosPricesCurrencies[selectedComboId] ==
                'USD') {
          combosPriceControllers[comboKeys[i]]!
              .text =
          '${double.parse('${(double.parse(
              comboController.combosPricesList[ind].toString()) *
              double.parse(exchangeRateForSelectedCurrency))}')}';
        } else {
          var result = exchangeRatesController
              .exchangeRatesList
              .firstWhere(
                (item) =>
            item["currency"] ==
                comboController
                    .combosPricesCurrencies[selectedComboId],
            orElse: () => null,
          );
          var divider = '1';
          if (result != null) {
            divider =
                result["exchange_rate"]
                    .toString();
          }
          var usdPrice =
              '${double.parse('${(double.parse(
              comboController.combosPricesList[ind].toString()) /
              double.parse(divider))}')}';
          combosPriceControllers[comboKeys[i]]!
              .text =
          '${double.parse('${(double.parse(usdPrice) * double.parse(
              comboController.exchangeRateForSelectedCurrency))}')}';
        }
        combosPriceControllers[comboKeys[i]]!
            .text =
        '${double.parse(combosPriceControllers[comboKeys[i]]!.text)}';

        combosPriceControllers[comboKeys[i]]!
            .text = double.parse(
          combosPriceControllers[comboKeys[i]]!
              .text,
        ).toStringAsFixed(2);
        var totalLine =
            '${(int.parse(
            rowsInListViewInSalesInvoice[comboKeys[i]]['item_quantity']) *
            double.parse(combosPriceControllers[comboKeys[i]]!.text)) * (1 -
            double.parse(
                rowsInListViewInSalesInvoice[keys[i]]['item_discount']) /
                100)}';
        setEnteredQtyInSalesInvoice(
          comboKeys[i],
          rowsInListViewInSalesInvoice[comboKeys[i]]['item_quantity'],
        );
        setMainTotalInSalesInvoice(
          comboKeys[i],
          totalLine,
        );
        getTotalItems();

        setEnteredUnitPriceInSalesInvoice(
          comboKeys[i],
          combosPriceControllers[comboKeys[i]]!
              .text,
        );
        setMainTotalInSalesInvoice(
          comboKeys[i],
          totalLine,
        );
        getTotalItems();
      }}
}}
