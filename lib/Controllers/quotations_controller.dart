import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/Quotations/get_quotation_create_info.dart';
import 'package:rooster_app/Backend/Quotations/get_quotations.dart';

class QuotationsController extends GetxController {
  List<Widget> orderLinesList = [];
  bool imageAvailable = false;
  double imageSpaceHeight = 90;
  addToOrderLinesList(Widget p) {
    orderLinesList.add(p);
    update();
  }
  removeFromOrderLinesList(int index) {
    orderLinesList.removeAt(index);
    update();
  }

  changeBoolVar(bool val) {
    imageAvailable = val;
    update();
  }

  increaseImageSpace(double val) {
    imageSpaceHeight = imageSpaceHeight + val;
    update();
  }

  bool isSubmitAndPreviewClicked = false;

  setIsSubmitAndPreviewClicked(bool val) {
    isSubmitAndPreviewClicked = val;
    update();
  }
  Map<String,Widget> orderLinesQuotationList = {};

  resetQuotation() {
    orderLinesQuotationList = {};
    itemsList = [];
    itemsNames = [];
    itemsIds = [];
    isItemsFetched = false;
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

  List<String> itemsList = [];
  List<String> itemsNames = [];
  List itemsIds = [];
  bool isItemsFetched = false;

  Map email = {};
  Map phoneNumber = {};
  Map clientNumber = {};
  Map name = {};
  Map country = {};
  Map city = {};

  getFieldsForCreateQuotationFromBack() async {
    itemsList = [];
    itemsNames = [];
    itemsIds = [];
    isItemsFetched = false;
    var p = await getFieldsForCreateQuotation();
    for (var item in p['items']) {
      itemsNames.add('${item['mainCode']}');
      itemsIds.add('${item['id']}');

      update();
    }

    // itemsList.addAll(p);
    isItemsFetched = true;
    update();
  }
  TextEditingController codeController = TextEditingController();

  getClientEmail(int index) async {
    var p = await getFieldsForCreateQuotation();
    phoneNumber = {};
    email = {};
    clientNumber = {};
    country = {};
    city = {};

    for (var client in p['clients']) {
      if (index == client['id']) {
        if (client['phone_number'] == null) {
          phoneNumber["${client['id']}"] = '';
        } else {
          phoneNumber["${client['id']}"] = client['phone_number'];
        }
        email["${client['id']}"] = client['email'];
        country["${client['id']}"] = client['country'] ;
        city["${client['id']}"] = client['city'] ;

        clientNumber["${client['id']}"] = client['client_number'];
        codeController.text = client['client_number'];

      }
    }
    update();
  }

  TextEditingController nameController = TextEditingController();
  String clientName='';
  setClientName(int index)async{
    var p = await getFieldsForCreateQuotation();
    name = {};
    phoneNumber = {};
    email = {};

    for (var client in p['clients']) {
      if (index == client['id']) {
        name ["${client['id']}"] = client['name'];
        nameController.text = client['name'];
        if (client['phone_number'] == null) {
          phoneNumber["${client['id']}"] = '';
        } else {
          phoneNumber["${client['id']}"] = client['phone_number'];
        }
        email["${client['id']}"] = client['email'];
      }

    }

    update();
  }


  List rowsInListViewInQuotation = [];
  // Map rowsInListViewInQuotation={};
  clearList() {
    rowsInListViewInQuotation = [];
    update();
  }

  addToRowsInListViewInQuotation(Map p) {
    rowsInListViewInQuotation.add(p);
    update();
  }

  removeFromRowsInListViewInQuotation(int index) {
    rowsInListViewInQuotation.removeAt(index);
    update();
  }

  addToOrderLinesInQuotationList(String index,Widget p){
    orderLinesQuotationList[index]=p;
    update();
  }
  removeFromOrderLinesInQuotationList(String index){
    orderLinesQuotationList.remove(index);
    update();
  }

  setItemIdInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['item'] = val;
    update();
  }

  // setItemNameInQuotation(int index,String val){
  //   rowsInListViewInQuotation[index]['itemName']=val;
  //   update();
  // }

  setTypeInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['type'] = val;
    update();
  }
  setTitleInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['title'] = val;
    update();
  }
  setMainDescriptionInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['description'] = val;
    update();
  }

  setEnteredQtyInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['quantity'] = val;
    update();
  }
  setEnteredUnitPriceInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['unitPrice'] = val;
    update();
  }
  setEnteredDiscInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['discount'] = val;
    update();
  }
  setMainTotalInQuotation(int index, String val) {
    rowsInListViewInQuotation[index]['total'] = val;
    update();
  }

  int totalItems = 0;
  double globalDisc = 0;
  double totalAfterGlobalDis = 0;
  double specialDisc = 0;
  double totalAfterGlobalSpecialDis = 0;
  double vat11 = 0;
  double vat11LBP = 0;
  getTotalItems() {
    totalItems = 0;
    for (int i = 0; i < rowsInListViewInQuotation.length; i++) {
      totalItems += int.parse(rowsInListViewInQuotation[i]['total']);
    }
    setVat11();
    setTotalAllQuotation();
    update();
  }

  setGlobalDisc(String val) {
    globalDisc = (totalItems) * int.parse(val) / 100;
    totalAfterGlobalDis = totalItems - globalDisc;
    totalAfterGlobalSpecialDis = totalAfterGlobalDis - specialDisc;
    setVat11();
    setTotalAllQuotation();
    update();
  }

  setSpecialDisc(String val) {
    specialDisc = totalAfterGlobalDis * int.parse(val) / 100;
    totalAfterGlobalSpecialDis = totalAfterGlobalDis - specialDisc;
    setVat11();
    setTotalAllQuotation();
    update();
  }

  setVat11() {
    vat11 = (totalItems - globalDisc - specialDisc) * 11 / 100;
    vat11LBP = vat11 * 89500;
    update();
  }

  double totalQuotation = 0;
  setTotalAllQuotation() {
    totalQuotation = (totalItems - globalDisc - specialDisc) + vat11;
    setVat11();
  }

  double listViewLengthInQuotation = 50;
  double increment = 50;
  incrementListViewLengthInQuotation(double val) {
    listViewLengthInQuotation = listViewLengthInQuotation + val;
    update();
  }

  decrementListViewLengthInQuotation(double val) {
    listViewLengthInQuotation = listViewLengthInQuotation - val;
    update();
  }

  Map itemsMap = {};
  Map whInfo = {};
  List warehousesList = [];
  getDataQuotationFromBack() async {
    var p = await getFieldsForCreateQuotation();
    if ('$p' != '[]') {
      for (var item in p['items']) {
        warehousesList = [];
        whInfo = {};
        itemsMap["${item['id']}"] = item['mainDescription'];

      }
    }
  }

  List  nameList=[];
  getWarehousesForItem(String index) async {
    var p = await getFieldsForCreateQuotation();
    if ('$p' != '[]') {
      whInfo = {};
      warehousesList = [];
      nameList = [];

      for (var item in p['items']) {
        warehousesList = item['warehouses'];

        for (var wh in warehousesList) {

          if (wh['pivot']['item_id'].toString() == index ) {
            whInfo["${wh['pivot']['warehouse_id']}"]={"Name":wh['name'],"Qty": wh['qty_on_hand']};

            nameList.add(wh['name']);
          }
        }

      }
    }
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
      isQuotationsFetched = true;
    }
    update();
  }



}
