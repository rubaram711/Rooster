import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';


Future addModel(String name,String carBrandId) async {
  final uri = Uri.parse(kCarModelsTermsUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "car_brand_id":carBrandId,
        "name":name,
      }
  );

  var p = json.decode(response.body);
  return p;//p['success']==true
}