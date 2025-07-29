import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future getQuantitiesOfProduct(
    String itemId
    ) async {
  final uri = Uri.parse(kGetQuantitiesUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  }, body: {
    "itemId": itemId,
  });

  var p = json.decode(response.body);
  // print('object $p');
  return p; //p['success']==true
}
