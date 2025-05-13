import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';



Future updateWarehouse(
    String id,
    String name,
    String address,
    String discontinued,
    String isMain,
    String blocked,
    ) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.put(
      Uri.parse('$kUpdateWarehouseUrl/$id'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "name": name,
        "address": address,
        "discontinued": discontinued,
        "blocked": blocked,
        "isMain": isMain,
      }
  );
  var p = json.decode(response.body);
  return p;
}


