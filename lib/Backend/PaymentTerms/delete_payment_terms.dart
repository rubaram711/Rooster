import 'package:http/http.dart' as http;
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';


Future<http.Response> deletePaymentTerms(String id) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.delete(
    Uri.parse('$kPaymentTermsUrl/$id'),
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    },
  );
  return response;
}