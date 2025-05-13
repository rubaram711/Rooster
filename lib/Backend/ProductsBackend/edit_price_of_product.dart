import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future editPriceOfProduct(
    String transferDate,
    String updatedPrice,
    String id,
    String currencyId
    ) async {
  final uri = Uri.parse(kEditPriceUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  }, body: {
    "startDate": transferDate,
    "updatedPrice": updatedPrice,
    "id": id,
    "currencyId": currencyId,
  });

  var p = json.decode(response.body);
  return p; //p['success']==true
}
