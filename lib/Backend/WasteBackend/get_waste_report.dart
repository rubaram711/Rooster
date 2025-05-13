import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';


Future getWasteDetails(
    {required String date,
      required String posId,
      required String sessionId}) async {
  final uri = Uri.parse(kWasteReportUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(
    uri,
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    },
    body: {
      'posTerminalId': posId,
      'date': date,
      'sessionId': sessionId,
      'isPaginated':'0',
    }
  );

  var p = json.decode(response.body);
  return p;
}

