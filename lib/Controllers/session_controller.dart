import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../Backend/SessionsBackend/get_sessions.dart';
import '../Backend/SessionsBackend/get_sessions_details.dart';
import '../Models/Sessions/sessions_model.dart';




class SessionController extends GetxController {
  // TextEditingController searchController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController fromSessionController = TextEditingController();
  TextEditingController toSessionController = TextEditingController();
  TextEditingController sessionNumberController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  String selectedCurrencyId = '';
  String selectedCurrencyName = '';

  TextEditingController searchInSessionsController = TextEditingController();
  List sessionsList = [];
  List<String> sessionsNumbers = [];
  bool isSessionsFetched = false;

  getSessionsFromBack() async {
    sessionsList = [];
    sessionsNumbers = [];
    isSessionsFetched = false;
      var p = await getAllSessions(searchInSessionsController.text);
      if('$p' != '[]'){
        sessionsList=p;
        sessionsList=sessionsList.reversed.toList();
        for(var session in sessionsList){
          sessionsNumbers.add(session['sessionNumber']);
        }
      }
    isSessionsFetched = true;
      update();
  }


 List<SessionOrder> sessionsDetails=[];
  SessionOrder lastSessionOrder=SessionOrder();
  bool isSessionsDetailsFetched=false;
  String errorMessage='';
  getSessionsDetailsFromBack() async {
    sessionsDetails = [];
    isSessionsDetailsFetched = false;
      var p = await getSessionsDetails
        (fromDate: fromDateController.text,
          endDate: toDateController.text,
          fromNumber: fromSessionController.text,
          toNumber: toSessionController.text,
          currencyId: selectedCurrencyId,
          singleSessionNumber: sessionNumberController.text);
      if(p['success'] == true){
        final lastElement = p['data'].last;
        lastSessionOrder = SessionOrder.fromJson(lastElement);
        sessionsDetails=p['data']
            // .take(p['data'].length - 1)
            .map<SessionOrder>((e)=>SessionOrder.fromJson(e)).toList();
      }else{
        errorMessage=p['message'];
      }
    isSessionsDetailsFetched = true;
      update();
  }

  setSelectedCurrency(String id,String name){
    selectedCurrencyId=id;
    selectedCurrencyName=name;
    update();
  }

}
