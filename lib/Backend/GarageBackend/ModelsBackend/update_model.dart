import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';


Future editModel(String id,String name,
    // String carBrandId
    ) async {
  final uri = Uri.parse('$kUpdateCarModelsUrl/$id');
  String token = await getAccessTokenFromPref();
  var response = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "name":name,
        // "car_brand_id":carBrandId,
      }
  );

  var p = json.decode(response.body);
  return p;//p['success']==true
}