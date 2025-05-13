import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';

Future addDiscounts(
    String type,
    String discountValue,
    ) async {
  final uri = Uri.parse(kAddDiscountsUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  }, body: {
    "type": type,
    "discountValue": discountValue,
  });

  var p = json.decode(response.body);
  return p; //p['success']==true
}
