import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future editQuantityOfProduct(
    String transferDate,
    String transferredQuantity,
    String id
    ) async {
  final uri = Uri.parse(kEditQuantityUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  }, body: {
    "transferDate": transferDate,
    "transferredQuantity": transferredQuantity,
    "id": id,
  });

  var p = json.decode(response.body);
  return p; //p['success']==true
}
