import 'package:dio/dio.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future updateRolesAndPermissions(List grants) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({});

  for (int i = 0; i < grants.length; i++) {
    formData.fields.addAll([
      MapEntry("grants[$i][roleId]", '${grants[i]['roleId']}'),
      MapEntry("grants[$i][permissionId]", '${grants[i]['permissionId']}'),
    ]);
  }

  Response response = await Dio()
      .post(kUpdateRolesAndPermissionsUrl,
          data: formData,
          options: Options(headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
            "Authorization": "Bearer $token"
          }))
      .catchError((err) {
    return err.response;

  });
  return response.data;

}
