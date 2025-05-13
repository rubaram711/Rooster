import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';

Future addPos(
    String name,
    String address,
    String warehouseId,
    ) async {
  final uri = Uri.parse(kAddPosUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  }, body: {
    "name": name,
    "address": address,
    "warehouseId": warehouseId,
  });

  var p = json.decode(response.body);
  return p; //p['success']==true
}
