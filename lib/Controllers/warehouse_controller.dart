import 'package:get/get.dart';

import '../Backend/ConfigurationsBackend/Warehouses/get_warehouses.dart';




class WarehouseController extends GetxController {
  int selectedTabIndex = 0;
  List warehousesList = [];
  List<String> warehousesNameList = [];
  List warehouseIdsList = [];
  bool isWarehousesFetched = false;
  // resetValues(){
  //   warehousesList = [];
  //   warehousesNameList = [];
  //   warehouseIdsList = [];
  //   isWarehousesFetched = false;
  //   update();
  // }
  resetWarehouse(){
    warehousesList = [];
    warehousesNameList = [];
    warehouseIdsList = [];
    isWarehousesFetched = false;
    update();
  }
  getWarehousesFromBack() async {
    warehousesList = [];
      warehousesNameList = [];
      warehouseIdsList = [];
      isWarehousesFetched = false;

      var p = await getAllWarehouses('');//todo search
      if('$p' != '[]'){
        warehousesList=p;
        // warehousesList=warehousesList.reversed.toList();
        for (var c in p ) {
          warehousesNameList.add('${c['name']}');
          warehouseIdsList.add('${c['id']}');
        }
      }
      isWarehousesFetched = true;
      update();
  }

  setActiveInWarehouse(String val, int index){
    warehousesList[index]['active']= val;
    update();
  }

  setSelectedTabIndex(int val){
     selectedTabIndex = val;
     update();
  }



}
