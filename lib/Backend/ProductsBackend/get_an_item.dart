import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future getAnItem(String itemId) async {
  final uri = Uri.parse('$kGetAllProductsUrl/$itemId')
      .replace(queryParameters: {
    'itemId': itemId,
    // 'warehouseId':warehouseId,
  })
  ;
  String token = await getAccessTokenFromPref();
  var response = await http.get(
    uri,
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  var p = json.decode(response.body);
  // print('resyyyy $p');
  return p;
}




