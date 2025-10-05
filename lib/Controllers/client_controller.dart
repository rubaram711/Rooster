import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../Backend/ClientsBackend/get_clients.dart';
import '../Backend/ClientsBackend/get_transactions.dart';
import '../Backend/GarageBackend/get_all_cars_attributes.dart';
import '../Backend/UsersBackend/get_user.dart';


class ClientController extends GetxController {
  List accounts = [];
  bool isClientsFetched = false;
  List transactionsOrders = [];
  List transactionsQuotations = [];
  bool isTransactionsFetched = false;
  TextEditingController searchController = TextEditingController();
  String selectedClientId='';
  Map selectedClient={};
  String hoveredClientId='';
  setSelectedClientId(String value) {
    selectedClientId = value;
    update();
  }
  setSelectedClient(Map value) {
    selectedClient = value;
    update();
  }
  setHoveredClientId(String value) {
    hoveredClientId = value;
    update();
  }


  setIsClientsFetched(bool value) {
    isClientsFetched = value;
    update();
  }

  setAccounts(List value) {
    accounts = value;
    update();
  }
  setIsTransactionsFetched(bool value) {
    isTransactionsFetched = value;
    update();
  }

  setTransactionsOrders(List value) {
    transactionsOrders = value;
    update();
  }
  setTransactionsQuotations(List value) {
    transactionsQuotations = value;
    update();
  }

  removeFromAccounts(int index) {
    accounts.removeAt(index);
    update();
  }

  getAllClientsFromBack() async {
    accounts = [];
    isClientsFetched = false;
    var p = await getAllClients(searchController.text);

    accounts = p;
    // accounts = accounts.reversed.toList();
    isClientsFetched = true;
    update();
  }

  getTransactionsFromBack() async {
    transactionsOrders = [];
    transactionsQuotations = [];
    isTransactionsFetched = false;
    var p = await getClientsTransactions(searchController.text,selectedClientId);
    transactionsOrders= p['orders'];
    transactionsQuotations = p['quotations'];
    isTransactionsFetched = true;
    update();
  }


  List<Map> contactsList=[
    // {    'type':'1',
    //   'name':'',
    //   'title':'',
    //   'jobPosition':'',
    //   'deliveryAddress':'',
    //   'phoneCode':'',
    //   'phoneNumber':'',
    //   'extension':'',
    //   'mobileCode':'',
    //   'mobileNumber':'',
    //   'email':'',
    //   'note':'',
    //   'internalNote':'',}
  ];
   addToContactsList(Map newMap){
     contactsList.add(newMap);
     update();
   }


   updateContactType(int index,String newVal){
     contactsList[index]['type']=newVal;
   }
   updateContactName(int index,String newVal){
     contactsList[index]['name']=newVal;
   }
   updateContactTitle(int index,String newVal){
     contactsList[index]['title']=newVal;
   }
   updateContactJobPosition(int index,String newVal){
     contactsList[index]['jobPosition']=newVal;
   }
   updateContactDeliveryAddress(int index,String newVal){
     contactsList[index]['deliveryAddress']=newVal;
   }
   updateContactPhoneCode(int index,String newVal){
     contactsList[index]['phoneCode']=newVal;
   }
   updateContactPhoneNumber(int index,String newVal){
     contactsList[index]['phoneNumber']=newVal;
   }
   updateContactExtension(int index,String newVal){
     contactsList[index]['extension']=newVal;
   }
   updateContactMobileCode(int index,String newVal){
     contactsList[index]['mobileCode']=newVal;
   }
   updateContactMobileNumber(int index,String newVal){
     contactsList[index]['mobileNumber']=newVal;
   }
   updateContactEmail(int index,String newVal){
     contactsList[index]['email']=newVal;
   }
   updateContactNote(int index,String newVal){
     contactsList[index]['note']=newVal;
   }
   updateContactInternalNote(int index,String newVal){
     contactsList[index]['internalNote']=newVal;
   }


  List salesPersonList = [];
  List<String> salesPersonListNames = [];
  List salesPersonListId = [];
  String salesPersonName = '';
  int salesPersonId = 0;
  String selectedSalesPerson = '';
  int selectedSalesPersonId = 0;
  TextEditingController salesPersonController = TextEditingController();

  getAllUsersSalesPersonFromBack() async {
    salesPersonList = [];
    salesPersonListNames = [];
    salesPersonName = '';
    salesPersonId = 0;
    update();
    var p = await getAllUsersSalesPerson();
    if ('$p' != '[]') {
      salesPersonList = p;
      for (var salesPerson in salesPersonList) {
        salesPersonName = salesPerson['name'];
        salesPersonId = salesPerson['id'];
        salesPersonListNames.add(salesPersonName);
        salesPersonListId.add(salesPersonId);
      }
      selectedSalesPerson=salesPersonListNames[0];
      selectedSalesPersonId=salesPersonListId[0];
      salesPersonController.text=salesPersonListNames[0];
    }
    update();
  }

  setSelectedSalesPerson(String name,int id){
    selectedSalesPerson=name;
    selectedSalesPersonId=id;
    update();
  }




  List<Map> carsList=[
//      'odometer': '',
//       'registration': '',//unique
//       'year': '',
//       'color': '',
//       'model': '',
//       'brand': '',
//       'chassis_no': '',//number
//       'rating': '',
//       'comment': '',
//       'car_fax': '',
//   'technician':''
  ];
  addToCarsList(Map newMap){
    carsList.add(newMap);
    update();
  }

  updateCarTechnician(int index,String id,String name){
    if(carsList[index]['technician'].isEmpty){
      carsList[index]['technician']={
        'id':id,
        'name':name
      };
    }else{
    carsList[index]['technician']['id']=id;
    carsList[index]['technician']['name']=name;
    }
  }
  updateCarOdometer(int index,String newVal){
    carsList[index]['odometer']=newVal;
  }
  updateCarRegistration(int index,String newVal){
    carsList[index]['registration']=newVal;
  }
  updateCarYear(int index,String newVal){
    carsList[index]['year']=newVal;
  }
  updateCarColor(int index,String id,String name){
    // carsList[index]['color']=newVal;
    if(carsList[index]['color'].isEmpty){
      carsList[index]['color']={
        'id':id,
        'name':name
      };
    }else{
      carsList[index]['color']['id']=id;
      carsList[index]['color']['name']=name;
    }
  }
  updateCarModel(int index,String id,String name){
    // carsList[index]['model']=newVal;
    if(carsList[index]['model'].isEmpty){
      carsList[index]['model']={
        'id':id,
        'name':name
      };
    }else{
      carsList[index]['model']['id']=id;
      carsList[index]['model']['name']=name;
    }
  }
  updateCarBrand(int index,String id,String name){
    // carsList[index]['brand']=newVal;
    if(carsList[index]['brand'].isEmpty){
      carsList[index]['brand']={
        'id':id,
        'name':name
      };
    }else{
      carsList[index]['brand']['id']=id;
      carsList[index]['brand']['name']=name;
    }
  }

  updateCarChassisNo(int index,String newVal){
    carsList[index]['chassis_no']=newVal;
  }
  updateCarRating(int index,String newVal){
    carsList[index]['rating']=newVal;
  }
  updateCarComment(int index,String newVal){
    carsList[index]['comment']=newVal;
  }
  updateCarFax(int index,String newVal){
    carsList[index]['car_fax']=newVal;
  }


  // bool isItForUpdate=false;
  // setIsItForUpdate(bool val){
  //   isItForUpdate=val;
  //   update();
  // }
  List<String> carsTechnicianNames=[];
  List<String> carsTechnicianIds=[];
  List<String> carsColorsNames=[];
  List<String> carsColorsIds=[];
  List<String> carsBrandsNames=[];
  List<String> carsBrandsIds=[];

  List<String> carsBrandsMapsToModelsIds=[];
 bool isAttributesFetched=false;
  bool isModelsFetched=false;
  List carModels=[];
  getAllCarsAttributesFromBack() async {
    carsTechnicianNames=[];
    carsTechnicianIds=[];
    carsColorsNames=[];
    carsColorsIds=[];
    carsBrandsNames=[];
    carsBrandsIds=[];
    isAttributesFetched=false;
    isModelsFetched=false;
    carModels=[];
    var p = await getAllCarsAttributes();
    if (p['success']==true) {

      carModels   = (p['data']['car_models'] as List?)!;
      final technicians = p['data']['technicians'] as List?;
      final carBrands   = p['data']['car_brands'] as List?;
      final carColors   = p['data']['car_colors'] as List?;

      carsTechnicianNames = extractNames(technicians);
      carsTechnicianIds   = extractIds(technicians);

      carsBrandsNames     = extractNames(carBrands);
      carsBrandsIds       = extractIds(carBrands);

      carsColorsNames     = extractNames(carColors);
      carsColorsIds       = extractIds(carColors);

    }
    isModelsFetched=true;
    isAttributesFetched=true;
    update();
  }

  List<String> extractNames(List<dynamic>? data) =>
      data?.map((e) => e['name'] as String).toList() ?? [];

  List<String> extractIds(List<dynamic>? data) =>
      data?.map((e) => '${e['id']}').toList() ?? [];

  List<String> extractModelsIdsWithCondition(String conditionVal) =>
      carModels.
      where((e) =>  '${e['car_brand_id']}'==conditionVal,)
          .map((e) => '${e['id']}').toList() ;

  List<String> extractModelsNamesWithCondition(String conditionVal) =>
      carModels.
      where((e) =>  '${e['car_brand_id']}'==conditionVal,)
          .map((e) => '${e['name']}').toList() ;

}
