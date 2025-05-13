import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Models/Waste/waste_model.dart';
import '../Backend/SessionsBackend/get_sessions.dart';
import '../Backend/WasteBackend/get_waste_report.dart';




class WasteReportsController extends GetxController {
  TextEditingController dateController = TextEditingController();
  TextEditingController sessionNumberController = TextEditingController();
  TextEditingController posTerminalController = TextEditingController();
  String selectedPosId = '';
  String selectedPosName = '';

  TextEditingController searchInSessionsController = TextEditingController();
  List sessionsList = [];
  List<String> sessionsNumbers = [];
  List<String> sessionsIds = [];
  String selectedSessionId = '';
  bool isSessionsFetched = false;

  getSessionsFromBack() async {
    sessionsList = [];
    sessionsIds = [];
    sessionsNumbers = [];
    isSessionsFetched = false;
      var p = await getAllSessions(searchInSessionsController.text);
      if('$p' != '[]'){
        sessionsList=p;
        sessionsList=sessionsList.reversed.toList();
        for(var session in sessionsList){
          sessionsNumbers.add(session['sessionNumber']);
          sessionsIds.add('${session['id']}');
        }
      }
    isSessionsFetched = true;
      update();
  }


 List<WasteModel> wasteDetails=[];
  bool isWasteDetailsFetched=false;
  String errorMessage='';
  getWasteDetailsFromBack() async {
    wasteDetails = [];
    isWasteDetailsFetched = false;
      var p = await getWasteDetails
        (date: dateController.text,
          posId: selectedPosId,
          sessionId: selectedSessionId);
      if(p['success'] == true){
        wasteDetails=p['data']
            // .take(p['data'].length - 1)
            .map<WasteModel>((e)=>WasteModel.fromJson(e)).toList();
      }else{
        errorMessage=p['message'];
      }
    isWasteDetailsFetched = true;
      update();
  }

  setSelectedPos(String id,String name){
    selectedPosId=id;
    selectedPosName=name;
    update();
  }

  setSelectedSessionId(String val){
    selectedSessionId=val;
    update();
  }

}
