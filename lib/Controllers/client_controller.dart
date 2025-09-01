import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../Backend/ClientsBackend/get_clients.dart';
import '../Backend/ClientsBackend/get_transactions.dart';
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
  ];
  addToCarsList(Map newMap){
    carsList.add(newMap);
    update();
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
  updateCarColor(int index,String newVal){
    carsList[index]['color']=newVal;
  }
  updateCarModel(int index,String newVal){
    carsList[index]['model']=newVal;
  }
  updateCarBrand(int index,String newVal){
    carsList[index]['brand']=newVal;
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


}
