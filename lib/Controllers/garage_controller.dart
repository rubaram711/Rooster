import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';





class GarageController extends GetxController {
  int selectedTabIndex = 0;
  bool isItUpdateAttribute=false;
  bool isAttributesFetched = false;
  TextEditingController searchOnAttributeValueController = TextEditingController();
  int selectedAttributeIndex=0;
  String selectedAttributeText='';
  List attributeValuesList=[];

  setIsItUpdateAttribute(bool value){
    isItUpdateAttribute=value;
    update();
  }
  setSelectedAttributeText(String value){
    selectedAttributeText=value;
    update();
  }



  setSelectedAttributeIndex(int val){
    selectedAttributeIndex=val;
    update();
  }

  getAllAttributesFromBack()async{
    attributeValuesList = [];
    isAttributesFetched = false;
    // var p= await getAttribute(searchOnRoleController.text);
    // if (p["success"]==true) {
    //   attributesList = p['data']['attribute'];
      isAttributesFetched=true;
    // }
    update();
  }


}
