import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';
import 'package:dio/dio.dart';



Future updateReplenishment(
    String id,
    String destWarehouseId,
    String reference,
    String totalQuantity ,
    String date,
    String replenishmentCurrencyId,
    Map items,
    ) async {
  print('reference');
  print(reference);
  print(replenishmentCurrencyId);
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "destWarehouseId":destWarehouseId,
    "reference":reference,
    // "totalQuantity ":totalQuantity,
    "date":date,
    "replenishmentCurrencyId":replenishmentCurrencyId,
  });

  var itemsKeys = items.keys.toList();

  for (int i = 0; i < itemsKeys.length; i++) {
    formData.fields.addAll([
      MapEntry("items[$i][itemId]",'${items[itemsKeys[i]]['itemId']}'),
      MapEntry("items[$i][replenishedQty]",'${items[itemsKeys[i]]['replenishedQty']}'),
      MapEntry("items[$i][unitCost]",'${items[itemsKeys[i]]['cost']}'),
      MapEntry("items[$i][replenishedQtyPackageName]",'${items[itemsKeys[i]]['replenishedQtyPackage']}'),
      MapEntry("items[$i][note]",'${items[itemsKeys[i]]['note']}'),
    ]);
  }

  Response response = await Dio().post(
      '$kUpdateReplenishmentsUrl/$id',
      data: formData,
      options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
            "Authorization": "Bearer $token"
          }
      )
  )      .catchError((err) {
    // print('100');
    // print(err.response);
    return err.response;
  });

  // String name='${response.data['data']['order_number']}';
  return response.data;
}

