import 'package:get/get.dart';

import '../Backend/get_currencies.dart';




class DiscountsController extends GetxController {
  int selectedTabIndex = 0;
  List discountsList = [];
  bool isDiscountsFetched = false;

  // resetValues(){
  //   warehousesList = [];
  //   warehousesNameList = [];
  //   warehouseIdsList = [];
  //   isWarehousesFetched = false;
  //   update();
  // }
  getDiscountsFromBack()async{
    discountsList = [];
    isDiscountsFetched = false;
    var p= await getCurrencies();
    if ('$p' != '[]') {

        discountsList.addAll(p['discountTypes']);
        discountsList=discountsList.reversed.toList();
        isDiscountsFetched=true;
        update();
    }
  }

  //
  // setActiveInWarehouse(String val, int index){
  //   warehousesList[index]['active']= val;
  //   update();
  // }
  //
  // setSelectedTabIndex(int val){
  //    selectedTabIndex = val;
  //    update();
  // }



}
