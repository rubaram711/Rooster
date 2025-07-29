import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';
import 'package:dio/dio.dart';

Future storeDelivery(
  String manualReference, //ok
  String clientId, //ok
  String driverId, //ok
  String date, //ok
  String expectedDeliveryDate, //ok

  String total,
  String vatExempt,
  Map items,
) async {
  String token = await getAccessTokenFromPref();

  FormData formData = FormData.fromMap({
    "clientId": clientId, //ok
    "driverId": driverId, //ok
    "reference": manualReference, //ok
    "date": date, //ok
    "expectedDelivery": expectedDeliveryDate, //ok
    // "total": total,
    // "vatExempt": vatExempt, //ok
  });

  for (int i = 1; i < items.length + 1; i++) {
    formData.fields.addAll([
      MapEntry("orderLines[$i][type]", '${items[i]['line_type_id']}'),
      MapEntry(
        "orderLines[$i][item]",
        '${items[i]['item_id']}',
      ), //item means itemCodeId
      MapEntry("orderLines[$i][mainCode]", '${items[i]['item_main_code']}'),
      MapEntry("orderLines[$i][itemName]", '${items[i]['itemName']}'),
      MapEntry("orderLines[$i][discount]", '${items[i]['item_discount']}'),
      MapEntry(
        "orderLines[$i][description]",
        '${items[i]['item_description']}',
      ),
      MapEntry("orderLines[$i][quantity]", '${items[i]['item_quantity']}'),
      MapEntry(
        "orderLines[$i][item_warehouse_id]",
        '${items[i]['item_warehouseId']}',
      ),
      MapEntry("orderLines[$i][unitPrice]", '${items[i]['item_unit_price']}'),
      MapEntry("orderLines[$i][total]", '${items[i]['item_total']}'),

      MapEntry("orderLines[$i][title]", '${items[i]['title']}'),
      MapEntry("orderLines[$i][note]", '${items[i]['note']}'),
      MapEntry("orderLines[$i][combo]", '${items[i]['combo']}'),
      MapEntry("orderLines[$i][comboPrice]", '${items[i]['item_unit_price']}'),
      MapEntry(
        "orderLines[$i][combo_warehouse_id]",
        '${items[i]['combo_warehouseId']}',
      ),
    ]);

    formData.files.addAll([
      MapEntry(
        "orderLines[$i][image]",
        MultipartFile.fromBytes(
          items[i]['image'] ?? [],
          filename: "image[$i].jpg",
        ),
      ),
    ]);
  }

  Response response = await Dio()
      .post(
        kStoreDeliveryUrl,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      )
      .catchError((err) {
        return err.response;
      });

  return response.data;
}
