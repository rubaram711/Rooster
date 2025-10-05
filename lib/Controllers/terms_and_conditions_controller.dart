import 'package:get/get.dart';
import '../Backend/TermsAndConditions/get_terms_and_conditions.dart';



class TermsAndConditionsController extends GetxController {
  int selectedTabIndex = 0;
  String selectedTermsAndConditionId = '';
  List termsAndConditionsList = [];
  List<String> termsAndConditionsNamesList = [];
  List<String> termsAndConditionsTextsList = [];
  List<String> termsAndConditionsIdsList = [];
  bool isTermsAndConditionsFetched = false;
  bool isItUpdate = false;
Map selectedTermsAndCondition={};
  setSelectedTabIndex(int val){
    selectedTabIndex=val;
    update();
  }
  setSelectedTermsAndConditionId(String val){
    selectedTermsAndConditionId=val;
    update();
  }
  setIsItUpdate(bool val){
    isItUpdate=val;
    update();
  }
  setSelectedTermsAndCondition(Map val){
    selectedTermsAndCondition=val;
    update();
  }
  getTermsAndConditionsFromBack() async {
    termsAndConditionsList = [];
    termsAndConditionsNamesList = [];
    termsAndConditionsTextsList = [];
    termsAndConditionsIdsList = [];
    isTermsAndConditionsFetched = false;
    var res = await getTermsAndConditions();
    if (res['success'] == true) {
      termsAndConditionsList = res['data'];
      termsAndConditionsList = termsAndConditionsList.reversed.toList();
      termsAndConditionsNamesList=termsAndConditionsList.map((e) => '${e['name']}',).toList();
      termsAndConditionsTextsList=termsAndConditionsList.map((e) => '${e['terms_and_conditions']}',).toList();
      termsAndConditionsIdsList=termsAndConditionsList.map((e) => '${e['id']}',).toList();
      isTermsAndConditionsFetched = true;
    }
    update();
  }

  reset() {
    selectedTabIndex = 0;
    isItUpdate = false;
     selectedTermsAndConditionId = '';
     isItUpdate = false;
     selectedTermsAndCondition={};
  }
}
