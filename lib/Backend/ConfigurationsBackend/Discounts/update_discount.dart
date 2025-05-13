import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';



Future updateDiscount(
    String id,
    String type,
    String discountValue,
    ) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.put(
      Uri.parse('$kUpdateDiscountsUrl/$id'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "type": type,
        "discountValue": discountValue,
      }
  );
  var p = json.decode(response.body);
  return p;
}


