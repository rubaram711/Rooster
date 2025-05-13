import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';
import 'package:dio/dio.dart';



Future addTransferIn(
    String transferId,
    String date,
    List items,
    ) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "transferId":transferId,
    // "totalQuantity ":totalQuantity,
    "receivingDate":date,
  });
  // var itemsKeys = items.keys.toList();

  for (int i = 0; i < items.length; i++) {
    formData.fields.addAll([
      MapEntry("items[$i][itemId]",'${items[i]['itemId']}'),
      MapEntry("items[$i][receivedQuantity]",'${items[i]['receivedQty']}'),
      MapEntry("items[$i][receivedQtyPackageName]",'${items[i]['transferredQtyPackageName']}'),
      MapEntry("items[$i][qtyDifferencePackageName]",'${items[i]['transferredQtyPackageName']}'),
      MapEntry("items[$i][qtyDifference]",'${items[i]['qtyDifference']}'),
      MapEntry("items[$i][note]",items[i]['note']??''),
    ]);
  }

  Response response = await Dio().post(
      kTransferInUrl,
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
  // print('response.data ${response.statusCode}');
  return response.data;
}

