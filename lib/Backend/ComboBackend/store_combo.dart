import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:dio/dio.dart';
import 'package:rooster_app/const/urls.dart';

Future storeCombo(
  String companyId,
  String name,
  String code,
  String description,
  String currencyId,
  String price,
  String active,
  String brand,
  List<int> featureimage,
  Map items,
) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "company_id": companyId,
    "name": name,
    "code": code,
    "description": description,
    "currencyId": currencyId,
    "price": price,
    "active": '1',
    'brand': brand,
    // "image": MultipartFile.fromBytes(image, filename: "image.jpg"),
  });
  formData.files.addAll([
    MapEntry(
      "image",
      MultipartFile.fromBytes(featureimage ?? [], filename: "featureimage.jpg"),
    ),
  ]);
  for (int i = 1; i < items.length + 1; i++) {
    formData.fields.addAll([
      //   MapEntry("back value",'front value')
      MapEntry("items[$i][id]", '${items[i]['item_id']}'),
      MapEntry("items[$i][description]", '${items[i]['description']}'),
      MapEntry("items[$i][quantity]", '${items[i]['quantity']}'),
      MapEntry("items[$i][unitPrice]", '${items[i]['unit_price']}'),
      MapEntry("items[$i][discount]", '${items[i]['discount']}'),
    ]);
  }
  Response response = await Dio()
      .post(
        kStoreComboUrl,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      )
      .catchError((err) {
        // print("+++++++Error store Combo Connect+++++++++++++++++");
        // print(err.response);
        // print("++++++++++++++++++++++++");
        return err.response;
      });

  return response.data;
}
