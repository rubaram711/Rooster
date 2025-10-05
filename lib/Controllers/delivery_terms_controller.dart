import 'package:get/get.dart';
import 'package:rooster_app/Backend/DeliveryTerms/get_all_delivery_terms.dart';





class DeliveryTermsController extends GetxController {
  int selectedTabIndex = 0;
  List deliveryTermsList = [];
  List<String> deliveryTermsNamesList = [];
  List<String> deliveryTermsIdsList = [];
  bool isDeliveryTermsFetched = false;


  getDeliveryTermsFromBack()async{
    deliveryTermsList = [];
    deliveryTermsIdsList = [];
    deliveryTermsNamesList = [
     // 'EXWORK',
     // 'CIF',
     // 'FOB'
    ];
    isDeliveryTermsFetched = false;
    var res = await getAllDeliveryTerms();
    if (res['success'] == true) {
      deliveryTermsList = res['data'];
      deliveryTermsList = deliveryTermsList.reversed.toList();
      deliveryTermsNamesList=deliveryTermsList.map((e) => '${e['name']}',).toList();
      deliveryTermsIdsList=deliveryTermsList.map((e) => '${e['id']}',).toList();
      isDeliveryTermsFetched = true;
    }
    update();
  }





}
