import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';


Future storeTermsAndConditions(String termsAndConditions) async {
  final uri = Uri.parse(kAddTermsAndConditionsUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "termsAndConditions":termsAndConditions,
      }
  );

  var p = json.decode(response.body);
  return p;//p['success']==true
}