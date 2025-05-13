import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';



Future storeTask(String quotationId, String userId, String summary, String taskType, String date) async {
  String token = await getAccessTokenFromPref();
  final uri = Uri.parse(kTasksUrl);
  // print('object $summary');
  var response = await http.post(uri,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
    'quotationId': quotationId,
    'userId': userId,
    'summary': summary,
    'taskType': taskType,
    'date': date,
  });
  var p = json.decode(response.body);
  return p;
}
