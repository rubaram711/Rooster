import 'package:get/get.dart';

import '../Backend/PaymentTerms/get_all_payment_terms.dart';





class PaymentTermsController extends GetxController {
  int selectedTabIndex = 0;
  List paymentTermsList = [];
  List<String> paymentTermsNamesList = [];
  List<String> paymentTermsIdsList = [];
  bool isPaymentTermsFetched = false;

addPaymentTermsToLists(Map term){
  paymentTermsList.add(term);
  paymentTermsNamesList=paymentTermsList.map((e) => '${e['title']}',).toList();
  paymentTermsIdsList=paymentTermsList.map((e) => '${e['id']}',).toList();
  paymentTermsNamesList.add(term['title']);
  paymentTermsIdsList.add('${term['id']}');
  update();
}
  getPaymentTermsFromBack()async{
    paymentTermsList = [];
    paymentTermsIdsList = [];
    paymentTermsNamesList = [];
    isPaymentTermsFetched = false;
    var res= await getAllPaymentTerms();
    if (res['success'] == true) {
      paymentTermsList.addAll(res['data']);
      paymentTermsList=paymentTermsList.reversed.toList();
      paymentTermsNamesList=paymentTermsList.map((e) => '${e['title']}',).toList();
      paymentTermsIdsList=paymentTermsList.map((e) => '${e['id']}',).toList();
    isPaymentTermsFetched=true;
   }
    update();
  }





}
