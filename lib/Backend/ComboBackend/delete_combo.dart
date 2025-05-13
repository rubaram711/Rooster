import 'package:http/http.dart' as http;
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/const/urls.dart';

Future<http.Response> deleteCombo(String id) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.delete(
    Uri.parse('$testCombosUrl/$id'),
    headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
  );

  return response;
}
