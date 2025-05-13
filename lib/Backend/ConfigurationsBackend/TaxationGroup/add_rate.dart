import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';

Future addRate(
    String taxationGroupId,
    String taxRate,
    String startDate,
    ) async {
  final uri = Uri.parse(kAddRateUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  }, body: {
    "taxationGroupId": taxationGroupId,
    "taxRate": taxRate,
    "startDate": startDate,
  });

  var p = json.decode(response.body);
  return p; //p['success']==true
}
