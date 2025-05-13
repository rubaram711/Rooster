import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';
import 'package:dio/dio.dart';



Future addTransferOut(
    String destWarehouseId,
    String sourceWarehouseId,
    String reference,
    String totalQuantity ,
    String date,
    List items,
    ) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "destWarehouseId":destWarehouseId,
    "sourceWarehouseId":sourceWarehouseId,
    "reference":reference,
    // "totalQuantity ":totalQuantity,
    "creationDate":date,
  });

  // var itemsKeys = items.keys.toList();

  for (int i = 0; i < items.length; i++) {
    formData.fields.addAll([
      MapEntry("items[$i][itemId]",'${items[i]['itemId']}'),
      MapEntry("items[$i][transferredQuantity]",'${items[i]['transferredQty']}'),
      MapEntry("items[$i][transferredQtyPackageName]",'${items[i]['transferredQtyPackageName']}'),
      MapEntry("items[$i][note]",''),
    ]);
  }

  Response response = await Dio().post(
      kAddTransferOutUrl,
      data: formData,
      options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
            "Authorization": "Bearer $token"
          }
      )
  )    .catchError((err) {
    // print('100');
    // print(err.response);
    return err.response;
    // if (err is DioError) {
    //   print(err.response);
    // }
  }
  );

  // String name='${response.data['data']['order_number']}';
  // print('response.data ${response.data}');
    return response.data;
}

