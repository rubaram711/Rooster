import 'package:get/get.dart';

import '../Backend/PaymentTerms/get_all_payment_terms.dart';





class PaymentTermsController extends GetxController {
  int selectedTabIndex = 0;
  List paymentTermsList = [];
  List<String> paymentTermsNamesList = [];
  List<String> paymentTermsIdsList = [];
  bool isPaymentTermsFetched = false;


  getPaymentTermsFromBack()async{
    paymentTermsList = [];
    paymentTermsIdsList = [];
    paymentTermsNamesList = [
      // 'Immediate Payment',
      // '21 Days',
      // '15 Days',
      // '30 Days',
      // '45 Days',
      // 'End of following month',
      // '10 Days after end of next',
      // 'month',
      // '30% now, balance 60 Days',
      // '2/7 Net 30',
      ];
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
