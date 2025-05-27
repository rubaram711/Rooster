import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../Backend/CashTrayBackend/get_cash_tray.dart';
import '../Backend/CashTrayBackend/get_cash_tray_report.dart';

class CashTraysController extends GetxController {
  int selectedTabIndex = 0;
  TextEditingController searchInCashTraysController = TextEditingController();
  TextEditingController selectedCashTrayController = TextEditingController();

  List cashTraysList = [];
  List<String> cashTraysNumbersList = [];
  List<String> cashTraysIdsList = [];
  String selectedCashTrayId = '';
  bool isCashTraysFetched = false;
  // resetValues(){
  //   warehousesList = [];
  //   warehousesNameList = [];
  //   warehouseIdsList = [];
  //   isWarehousesFetched = false;
  //   update();
  // }

  setSelectedCashTrayId(String val) {
    selectedCashTrayId = val;
    update();
  }

  getCashTraysFromBack() async {
    cashTraysList = [];
    cashTraysNumbersList = [];
    cashTraysIdsList = [];
    isCashTraysFetched = false;
    var p = await getAllCashTraies(searchInCashTraysController.text);
    if ('$p' != '[]') {
      cashTraysList = p;
      // cashTraysList=cashTraysList.reversed.toList();
      for (var v in p) {
        cashTraysNumbersList.add(v['tray_number']);
        cashTraysIdsList.add('${v['id']}');
      }
    }
    isCashTraysFetched = true;
    update();
  }

  // String cashTrayNumber = '';
  // getCashTrayNumberFromBack() async {
  //   var currentSessionId = '';
  //   var session = await getOpenSessionId();
  //   if ('${session['data']}' != '[]') {
  //     currentSessionId = '${session['data']['session']['id']}';
  //     var p = await getFieldsForCreateCashTray(currentSessionId);
  //     if ('$p' != '[]') {
  //       cashTrayNumber = p['trayNumber'];
  //     }
  //   }
  //   update();
  // }

  Map report = {};
  int cashingMethodsListLength=0;



  Future getCashTrayReportFromBack() async {
    var res = await getCashTrayReport(selectedCashTrayId);
    if (res['success'] == true) {
      report = res['data'];
      List cashingMethodsList=report['cashingMethodsTotals']??[];
      cashingMethodsListLength=cashingMethodsList.length;

      update();
    }
    return res;
  }


  setSelectedTabIndex(int val) {
    selectedTabIndex = val;
    update();
  }




}
