import 'package:get/get.dart';





class PaymentTermsController extends GetxController {
  int selectedTabIndex = 0;
  List paymentTermsList = [];
  bool isPaymentTermsFetched = false;


  getPaymentTermsFromBack()async{
    paymentTermsList = [];
    isPaymentTermsFetched = false;
    // var p= await getCurrencies();
    // if ('$p' != '[]') {
    //   paymentTermsList.addAll(p['discountTypes']);
    //   paymentTermsList=paymentTermsList.reversed.toList();
      isPaymentTermsFetched=true;
    //   update();
    // }
  }





}
