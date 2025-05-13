import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Backend/PosBackend/create_pos.dart';
import '../../Backend/PosBackend/get_poss.dart';




class PosController extends GetxController {
  List posList = [];
  List<String> possNamesList = [];
  List possIdsList = [];
  bool isPossFetched = false;
  String code = '';
  bool isCodeFetched=false;
  bool  isDefaultWarehouseFetched=false;
  TextEditingController warehouseControllerForDropMenu=TextEditingController();
 String selectedWarehouseId='';

  setIsDefaultWarehouseFetched(bool val){
    isDefaultWarehouseFetched=true;
    update();
  }
  getPossFromBack() async {
    posList = [];
    possNamesList = [];
    possIdsList = [];
    isPossFetched = false;
      var p = await getAllPos('');
      if('$p' != '[]'){
        posList=p;
        posList=posList.reversed.toList();
        for (var c in p ) {
          possNamesList.add('${c['name']}');
          possIdsList.add('${c['id']}');
        }
        getFieldsForCreatePosFromBack();
      }
    isPossFetched = true;
      update();
  }

  setSelectedWarehouseId(String val) {
    selectedWarehouseId = val;
    update();
  }

  getFieldsForCreatePosFromBack() async {
    code = '';
    isCodeFetched=false;
    var p = await getFieldsForCreatePos();
    if('$p' != '[]'){
      code=p['posCode'];
      isCodeFetched = true;
    }
    update();
  }
}
