import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';



Future updateTask(
    String quotationId,
    String taskId,
    String status,
    String taskType,
    String date,
    String summary,
    String note,
    String userId
    ) async {
  // print('eeeeeee $taskId dd $status');
  // print('taskType $taskType dd $date');
  // print('summary $summary' );
  String token = await getAccessTokenFromPref();
  final uri = Uri.parse('$kTasksUrl/$taskId');
  final http.Response response = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "status": status,
        "taskType": taskType,
        "date": date,
        "summary": summary,
        "userId": userId,
        "quotationId": quotationId,
        'note':note
      }
  );
  var p = json.decode(response.body);
  // print('p');
  // print(p);
  return p;
}


