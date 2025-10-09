import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:rooster_app/Controllers/home_controller.dart';

import '../Backend/HeadersBackend/get_headers.dart';





class CompanySettingsController extends GetxController {

  int selectedCostOption = 1;
  bool isShowQuantitiesOnPosChecked = true;
  bool isShowLogoOnPosChecked = false;

  Uint8List? imageFile;
  String selectedPhoneCode = '', selectedMobileCode = '',logo='';
  TextEditingController headerName=TextEditingController();
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
    headerName.clear();
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



  getHeadersFromBack(bool isItHaveHeader2) async {
    headersList = [];
    isHeadersFetched = false;
    var p = await getAllHeaders();
    if (p['success']==true && '${p['data']}'!='[]') {

      for (  int i=0;i<2 ;i++) {
        //var header in p['data']
        headersList.add(p['data'][i]);

      }
      // cashTraysList=cashTraysList.reversed.toList();

      if(headersList.isEmpty && isItHaveHeader2){
        headersList=[
          { 'id': '',
            'logo':'',
            'fullCompanyName': '',
            'email': '',
            'vat': '',
            'trn': '',
            'bankInfo': '',
            'phoneCode': '+961',
            'phoneNumber': '',
            'mobileCode': '+961',
            'mobileNumber': '',
            'address': '',
            'localPayments': '',
            'companySubjectToVat': '',
            'headerName': 'Header 1',
            'defaultQuotationCurrency': {
              'id':'',
              'name':'',
            },
          } ,
          { 'id': '',
            'logo':'',
            'fullCompanyName': '',
            'email': '',
            'vat': '',
            'trn': '',
            'bankInfo': '',
            'phoneCode': '+961',
            'phoneNumber': '',
            'mobileCode': '+961',
            'mobileNumber': '',
            'address': '',
            'localPayments': '',
            'companySubjectToVat': '',
            'headerName': 'Header 2',
            'defaultQuotationCurrency': {
              'id':'',
              'name':'',
            },
          }
        ];
      }
      else if(headersList.length==1 && isItHaveHeader2){
        headersList.add({
          'id': '',
          'logo':'',
          'fullCompanyName': '',
          'email': '',
          'vat': '',
          'trn': '',
          'bankInfo': '',
          'phoneCode': '+961',
          'phoneNumber': '',
          'mobileCode': '+961',
          'mobileNumber': '',
          'address': '',
          'localPayments': '',
          'companySubjectToVat': '',
          'headerName': 'Header 2',
          'defaultQuotationCurrency': {
            'id':'',
            'name':'',
          },
        });
      }
      else if (headersList.isEmpty && !isItHaveHeader2){
        headersList=[
          { 'id': '',
            'logo':'',
            'fullCompanyName': '',
            'email': '',
            'vat': '',
            'trn': '',
            'bankInfo': '',
            'phoneCode': '+961',
            'phoneNumber': '',
            'mobileCode': '+961',
            'mobileNumber': '',
            'address': '',
            'localPayments': '',
            'companySubjectToVat': '',
            'headerName': 'Header 1',
            'defaultQuotationCurrency': {
            'id':'',
            'name':'',
            },
          } ,
        ];
      }
    }else{
      headersList=[
        { 'id': '',
          'logo':'',
          'fullCompanyName': '',
          'email': '',
          'vat': '',
          'trn': '',
          'bankInfo': '',
          'phoneCode': '+961',
          'phoneNumber': '',
          'mobileCode': '+961',
          'mobileNumber': '',
          'address': '',
          'localPayments': '',
          'companySubjectToVat': '',
          'headerName': 'Header 1',
          'defaultQuotationCurrency': {
            'id':'',
            'name':'',
          },
        } ,
        { 'id': '',
          'logo':'',
          'fullCompanyName': '',
          'email': '',
          'vat': '',
          'trn': '',
          'bankInfo': '',
          'phoneCode': '+961',
          'phoneNumber': '',
          'mobileCode': '+961',
          'mobileNumber': '',
          'address': '',
          'localPayments': '',
          'companySubjectToVat': '',
          'headerName': 'Header 2',
          'defaultQuotationCurrency': {
            'id':'',
            'name':'',
          },
        }
      ];
    }
    isHeadersFetched = true;
    update();
  }
  bool isHeadersFetched=false;
  List<Map> headersList=[];
  setFirstHeader(Map header){
    headersList[0]=header;
    update();
  }
  addToHeadersList(Map newMap){
    headersList.add(newMap);
    update();
  }

  updateLogo(int index,String newVal){
    headersList[index]['logo']=newVal;
  }
  updateLogoFile(int index,Uint8List val){
    headersList[index]['logo']=val;
  }
  updateFullCompanyName(int index,String newVal){
    headersList[index]['fullCompanyName']=newVal;
  }
  updateCompanyEmail(int index,String newVal){
    headersList[index]['email']=newVal;
  }
  updateVat(int index,String newVal){
    headersList[index]['vat']=newVal;
  }
  updateTrn(int index,String newVal){
    headersList[index]['trn']=newVal;
  }
  updatePhoneCode(int index,String newVal){
    headersList[index]['phoneCode']=newVal;
  }
  updatePhoneNumber(int index,String newVal){
    headersList[index]['phoneNumber']=newVal;
  }
  updateBankInfo(int index,String newVal){
    headersList[index]['bankInfo']=newVal;
  }
  updateMobileCode(int index,String newVal){
    headersList[index]['mobileCode']=newVal;
  }
  updateMobileNumber(int index,String newVal){
    headersList[index]['mobileNumber']=newVal;
  }
  updateAddress(int index,String newVal){
    headersList[index]['address']=newVal;
  }
  updateLocalPayments(int index,String newVal){
    headersList[index]['localPayments']=newVal;
  }
  updateHeaderName(int index,String newVal){
    headersList[index]['headerName']=newVal;
  }
  updateHeaderId(int index,String newVal){
    headersList[index]['id']=newVal;
  }
  updateCompanySubjectToVat(int index,String newVal){
    headersList[index]['companySubjectToVat']=newVal;
  }
  updateQuotationCurrency(int index,String idVal,String nameVal){
    if(!headersList[index].containsKey('defaultQuotationCurrency')){
      headersList[index].addAll({'defaultQuotationCurrency': {
        'id': '',
        'name': '',
      },});
    }
    else if(headersList[index]['defaultQuotationCurrency']==null){
      headersList[index]['defaultQuotationCurrency']={'id': '',
        'name': '',};
    }
    headersList[index]['defaultQuotationCurrency']['id']=idVal;
    headersList[index]['defaultQuotationCurrency']['name']=nameVal;
  }
}
