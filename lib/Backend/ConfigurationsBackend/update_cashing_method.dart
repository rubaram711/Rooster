import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';


Future updateCashingMethod(
    String id,
    String title,
    String active,
    ) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.put(
      Uri.parse('$kUpdateCashingMethodUrl/$id'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "title": title,
        "active": active,
      }
  );
  var p = json.decode(response.body);
  return p;
}


