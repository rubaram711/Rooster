import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';

Future createWarehouse(
    String name,
    String address,
    String discontinued,
    String isMain,
    String blocked,
    ) async {
  final uri = Uri.parse(kCreateWarehouseUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  }, body: {
    "name": name,
    "discontinued": discontinued,
    "isMain": isMain,
    "blocked": blocked,
    'address' :address
  });

  var p = json.decode(response.body);
  return p; //p['success']==true
}
