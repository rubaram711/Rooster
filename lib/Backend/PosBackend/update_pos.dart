import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';



Future updatePos(
    String id,
    String name,
    String address,
    String warehouseId,
    ) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.put(
      Uri.parse('$kUpdatePosUrl/$id'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "name": name,
        "address": address,
        "warehouseId": warehouseId,
      }
  );
  var p = json.decode(response.body);
  return p;
}


