import 'package:get/get.dart';

import '../Backend/get_currencies.dart';


class CashingMethodsController extends GetxController {
  int selectedTabIndex = 0;
  List cashingMethodsList = [];
  bool isCashingMethodsFetched = false;
  getCashingMethodsFromBack() async {
    cashingMethodsList = [];
      isCashingMethodsFetched = false;
      update();
      var p = await getCurrencies();
      if('$p' != '[]'){
        cashingMethodsList.addAll(p['cachingMethods']);
        cashingMethodsList=cashingMethodsList.reversed.toList();
      }
      isCashingMethodsFetched = true;
      update();
  }

  setActiveInCashingMethod(String val, int index){
    cashingMethodsList[index]['active']= val;
    update();
  }

  setSelectedTabIndex(int val){
     selectedTabIndex = val;
     update();
  }
}
