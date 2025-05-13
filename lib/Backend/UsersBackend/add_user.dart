
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';
import 'package:dio/dio.dart';
Future addUser(
    String companyId,
    String name,
    String email,
    String password,
    String passwordConfirmation,
    String active,
    // String   roleId,
    String   posTerminalId,
    List selectedRolesIdsList
    ) async {
  // final uri = Uri.parse(kUsersUrl);
  String token = await getAccessTokenFromPref();
  // var response = await http.post(uri, headers: {
  //   "Accept": "application/json",
  //   "Authorization": "Bearer $token"
  // }, body: {
  //   "companyId": companyId,
  //   "name": name,
  //   "email": email,
  //   "password": password,
  //   "active": active,
  //   "password_confirmation": passwordConfirmation,
  //   "roleId": roleId,
  //   "posTerminalId": posTerminalId,
  //   "is_salesperson": '1',
  // });
  FormData formData = FormData.fromMap({
    "companyId": companyId,
    "name": name,
    "email": email,
    "password": password,
    "active": active,
    "password_confirmation": passwordConfirmation,
    // "roleId": roleId,
    "posTerminalId": posTerminalId,
    "is_salesperson": '1',
  });


  for (int i = 0; i < selectedRolesIdsList.length; i++) {
    formData.fields.addAll([
      MapEntry("roles[$i]",'${selectedRolesIdsList[i]}'),
    ]);
  }


  Response response = await Dio().post(
      kUsersUrl,
      data: formData,
      options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
            "Authorization": "Bearer $token"
          }
      )
  )    .catchError((err) {
    return err.response;
    // if (err is DioError) {
    //   print(err.response);
    // }
  });
  return response.data;
  // var p = json.decode(response.body);
  // return p; //p['success']==true
}
