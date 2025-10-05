import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/GarageBackend/BrandsBackend/get_all_brand.dart';
import 'package:rooster_app/Backend/GarageBackend/ModelsBackend/get_all_model.dart';
import 'package:rooster_app/Backend/GarageBackend/TechniciansBackend/get_all_technician.dart';

import '../Backend/GarageBackend/ColorsBackend/get_all_colors.dart';





class GarageController extends GetxController {
  int selectedTabIndex = 0;
  bool isItUpdateAttribute=false;
  bool isAttributesFetched = false;
  TextEditingController searchOnAttributeValueController = TextEditingController();
  int selectedAttributeIndex=0;
  String selectedAttributeText='';
  String selectedAttributeId='';
  List attributeValuesList=[];

  setIsItUpdateAttribute(bool value){
    isItUpdateAttribute=value;
    update();
  }
  setSelectedAttributeText(String value){
    selectedAttributeText=value;
    update();
  }
  setSelectedAttributeId(String value){
    selectedAttributeId=value;
    update();
  }



  setSelectedAttributeIndex(int val){
    selectedAttributeIndex=val;
    update();
  }

  getAllAttributesFromBack()async{
    attributeValuesList = [];
    isAttributesFetched = false;
    var p;
    if(selectedAttributeText=='color')
      { p= await getAllColors(searchOnAttributeValueController.text);}
    else if(selectedAttributeText=='brand')
      { p= await getAllBrands(searchOnAttributeValueController.text);}
    else if(selectedAttributeText=='model')
      { p= await getAllModels(searchOnAttributeValueController.text);}
    else
      { p= await getAllTechnicians(searchOnAttributeValueController.text);}
    if (p["success"]==true) {
      attributeValuesList = p['data'];
      isAttributesFetched=true;
    }
    update();
  }

  List carBrands=[];
  List<String> carBrandsNames=[];
  List<String> carBrandsIds=[];
  bool isBrandsFetched = false;
  String selectedBrandId='';
  getAllBrandsFromBack()async{
    carBrands = [];
    carBrandsNames = [];
    carBrandsIds = [];
    isAttributesFetched = false;
    var p= await getAllBrands('');
    if (p["success"]==true) {
      carBrands = p['data'];
      carBrandsNames=carBrands.map<String>((element) => element['name'],).toList();
      carBrandsIds=carBrands.map<String>((element) =>'${element['id']}',).toList();
      isBrandsFetched=true;
    }
    update();
  }

  updateSelectedCarBrand(String val){
    selectedBrandId=val;
    update();
  }

}
