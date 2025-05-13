import 'package:get/get.dart';
import '../Backend/get_currencies.dart';




class TaxationGroupsController extends GetxController {
  int selectedTabIndex = 0;
  List taxationGroupsList = [];
  bool isTaxationGroupsFetched = false;
  List ratesInTaxationGroupList=[];
  int selectedTaxationGroupIndex=0;

  setSelectedTaxationGroupIndex(int val){
     selectedTaxationGroupIndex=val;
     update();
  }
  setRatesInTaxationGroupLis(List newList){
    ratesInTaxationGroupList=newList;
    update();
  }

  getAllTaxationGroupsFromBack() async {
      taxationGroupsList = [];
      isTaxationGroupsFetched = false;
      var p= await getCurrencies();
      if ('$p' != '[]') {
        taxationGroupsList.addAll(p['taxationGroups']);
        taxationGroupsList=taxationGroupsList.reversed.toList();
        setRatesInTaxationGroupLis(taxationGroupsList[selectedTaxationGroupIndex]['tax_rates'].reversed.toList());
        isTaxationGroupsFetched=true;
        update();
      }
      isTaxationGroupsFetched = true;
      update();
  }



}
