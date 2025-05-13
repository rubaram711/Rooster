
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:rooster_app/Models/Inventory/inventory_model.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future storeInventory(
    String warehouseId,
    String inventoryDate,
    List<InventoryItem> inventoryItems,
    List<TextEditingController> physicalQtyControllersList,
    List<double> difference,
    List<double> physicalCost ,
    List<double> theoreticalCost ,
    List<double> quantities,
    ) async {

  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "warehouseId": warehouseId,
    'inventoryDate':inventoryDate,
  });



  for (int i = 0; i < inventoryItems.length; i++) {
    formData.fields.addAll([
      MapEntry("inventoryItems[$i][itemId]",'${inventoryItems[i].id}'),
      MapEntry("inventoryItems[$i][qtyOnHand]",'${quantities[i]}'),
      MapEntry("inventoryItems[$i][countedQty]",physicalQtyControllersList[i].text),
      MapEntry("inventoryItems[$i][physicalCost]",'${physicalCost[i]}'),
      MapEntry("inventoryItems[$i][theoreticalCost]",'${theoreticalCost[i]}'),
      MapEntry("inventoryItems[$i][difference]",'${difference[i]}'),
    ]);
  }

  Response response = await Dio().post(
      kInventoryUrl,
      data: formData,
      options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
            "Authorization": "Bearer $token"
          }
      )
  )    .catchError((err) {
      // print(100);
      // print(err.response);
    return err.response;
  });
  return response.data;
  // if(response.data['success'] == true){
  //   return 'success';
  // }else{
  //   return 'error';
  // }
}
