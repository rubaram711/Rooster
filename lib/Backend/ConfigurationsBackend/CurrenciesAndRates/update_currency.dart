import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';



Future updateCurrency(
    String id,
    String name,
    String symbol,
    ) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.put(
      Uri.parse('$kUpdateCurrenciesUrl/$id'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "name": name,
        "symbol": symbol,
        "active": '1',
      }
  );
  var p = json.decode(response.body);
  return p;
}


