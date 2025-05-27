import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';





class CompanySettingsController extends GetxController {

  int selectedCostOption = 1;
  bool isShowQuantitiesOnPosChecked = true;
  bool isShowLogoOnPosChecked = false;

  Uint8List? imageFile;
  String selectedPhoneCode = '', selectedMobileCode = '',logo='';
  TextEditingController fullCompanyName=TextEditingController();
  TextEditingController address=TextEditingController();
  TextEditingController mobile=TextEditingController();
  TextEditingController phone=TextEditingController();
  TextEditingController email=TextEditingController();
  TextEditingController trn=TextEditingController();
  TextEditingController bankInformation=TextEditingController();
  TextEditingController localPayments=TextEditingController();
  TextEditingController vat=TextEditingController();
  TextEditingController primaryCurrency=TextEditingController();
  TextEditingController posCurrency=TextEditingController();
  String selectedCurrencyId = '';
  String selectedCurrencyName = '';
  String selectedCurrencySymbol = '';
  String selectedPosCurrencyId = '';
  String selectedPosCurrencyName = '';
  String selectedPosCurrencySymbol = '';
  String exchangeRateForSelectedCurrency = '';
  bool isCompanySubjectToVat = true;
  bool isPosCurrencyFound=false;
  setSelectedCurrency(String id,String name,String symbol){
    selectedCurrencyId=id;
    selectedCurrencyName=name;
    selectedCurrencySymbol=symbol;
    update();
  }
  setSelectedPosCurrency(String id,String name,String symbol){
    selectedPosCurrencyId=id;
    selectedPosCurrencyName=name;
    selectedPosCurrencySymbol=symbol;
    update();
  }
  setIsCompanySubjectToVat(bool val){
    isCompanySubjectToVat=val;
    update();
  }
  setSelectedCurrencySymbol(String val){
    selectedCurrencySymbol=val;
    update();
  }
  setExchangeRateForSelectedCurrency(String val){
    exchangeRateForSelectedCurrency=val;
    update();
  }
  setSelectedCostOption (int val){
     selectedCostOption = val;
     update();
  }

  setIsShowQuantitiesOnPosChecked(bool val){
    isShowQuantitiesOnPosChecked = val;
    update();
  }

  setIsShowLogoOnPosChecked(bool val){
    isShowLogoOnPosChecked = val;
    update();
  }



  setImageFile(Uint8List val) {
    imageFile=val;
    update();
  }

  setSelectedPhoneCode(String val) {
    selectedPhoneCode=val;
    update();
  }
  setSelectedMobileCode(String val) {
    selectedMobileCode=val;
    update();
  }

  resetValues(){
    // selectedCostOption = 1;
    // isShowQuantitiesOnPosChecked = false;
    imageFile=null;
    selectedPhoneCode = '';
    selectedMobileCode = '';
    fullCompanyName.clear();
    address.clear();
    mobile.clear();
    phone.clear();
    email.clear();
    trn.clear();
    bankInformation.clear();
    localPayments.clear();
    vat.clear();
    update();
  }
}
