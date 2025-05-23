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
  });
  for (int i = 1; i < items.length + 1; i++) {
    formData.fields.addAll([
      //   MapEntry("back value",'front value')
      MapEntry("items[$i][id]", '${items[i]['itemId']}'),
      MapEntry("items[$i][description]", '${items[i]['itemDescription']}'),
      MapEntry("items[$i][quantity]", '${items[i]['quantity']}'),
      MapEntry("items[$i][unitPrice]", '${items[i]['price']}'),
      MapEntry("items[$i][discount]", '${items[i]['discount']}'),
    ]);
  }
  print("formdata*******************");
  print(formData.fields);

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
        print("+++++++Error stor Combo Connect+++++++++++++++++");
        print(err.response);
        print("++++++++++++++++++++++++");
        return err.response;
      });

  return response.data;
}
