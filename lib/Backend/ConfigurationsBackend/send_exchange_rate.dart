import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future sendExchangeRate(
    String currencyId,
    String exchangeRate,
    String startDate,
    ) async {
  final uri = Uri.parse(kExchangeRateUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  }, body: {
    "currencyId": currencyId,
    "exchangeRate": exchangeRate.replaceAll(',', ''),
    "startDate": startDate,
  });

  var p = json.decode(response.body);
  return p; //p['success']==true
}
