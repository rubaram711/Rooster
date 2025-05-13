// import 'package:dio/dio.dart';
//
// import '../../../Locale_Memory/save_user_info_locally.dart';
// import '../../../const/urls.dart';
//
//
//
// Future updateUser(
//     String id,
//     String companyId,
//     String name,
//     String email,
//     String password,
//     String passwordConfirmation,
//     String active,
//     List   selectedRolesIdsList,
//     String   posTerminalId,
//     ) async {
//   print('object $name');
//   print('object $email');
//   print('object $password');
//   print('object $passwordConfirmation');
//   print('object $active');
//   print('object $selectedRolesIdsList');
//   print('posTerminalId $posTerminalId');
//   print('object $companyId');
//   print('object $id');
//   String token = await getAccessTokenFromPref();
//   // final http.Response response = await http.put(
//   //     Uri.parse('$kUsersUrl/$id'),
//   //     headers: {
//   //       "Accept": "application/json",
//   //       "Authorization": "Bearer $token"
//   //     },
//   //     body: {
//   //       "companyId": companyId,
//   //       "name": name,
//   //       "email": email,
//   //       "password": password,
//   //       "active": active,
//   //       "password_confirmation": passwordConfirmation,
//   //       "roleId": roleId,
//   //       "posTerminalId": posTerminalId,
//   //       "is_salesperson": '1',
//   //     }
//   // );
//   // var p = json.decode(response.body);
//   // var response = await http.post(uri, headers: {
//   //   "Accept": "application/json",
//   //   "Authorization": "Bearer $token"
//   // }, body: {
//   //   "companyId": companyId,
//   //   "name": name,
//   //   "email": email,
//   //   "password": password,
//   //   "active": active,
//   //   "password_confirmation": passwordConfirmation,
//   //   "roleId": roleId,
//   //   "posTerminalId": posTerminalId,
//   //   "is_salesperson": '1',
//   // });
//   FormData formData = FormData.fromMap({
//     "companyId": companyId,
//     "name": name,
//     "email": email,
//     "password": password,
//     "active": active,
//     "password_confirmation": passwordConfirmation,
//     // "roleId": roleId,
//     "posTerminalId": posTerminalId,
//     "is_salesperson": '1',
//   });
//
//
//   for (int i = 0; i < selectedRolesIdsList.length; i++) {
//     formData.fields.add(MapEntry("roles[$i]", selectedRolesIdsList[i].toString()));
//     // formData.fields.addAll([
//     //   MapEntry("roles[$i]",'${selectedRolesIdsList[i]}'),
//     // ]);
//   }
//
//
//   Response response = await Dio().put(
//       '$kUsersUrl/$id',
//       data: formData,
//       options: Options(
//           headers: {
//             "Content-Type": "multipart/form-data",
//             "Accept": "application/json",
//             "Authorization": "Bearer $token"
//           }
//       )
//   )    .catchError((err) {
//     print('err $err');
//     return err.response;
//   });
//   print('object ${response.data}');
//   return response.data;
//   // return p;
// }
//
//



import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future<dynamic> updateUser(
    String id,
    String companyId,
    String name,
    String email,
    String password,
    String passwordConfirmation,
    String active,
    List selectedRolesIdsList,
    String posTerminalId,
    ) async {
  // Formatting roles as required (role[index]: value)
  Map<String, dynamic> roleData = {};
  for (int i = 0; i < selectedRolesIdsList.length; i++) {
    roleData['roles[$i]'] = selectedRolesIdsList[i].toString();
  }

  // Construct request body
  final Map<String, dynamic> body = {
    "companyId": companyId,
    "name": name,
    "email": email,
    "password": password,
    "password_confirmation": passwordConfirmation,
    "active": active,
    "posTerminalId": posTerminalId,
    "is_salesperson": '1',
    ...roleData, // Add roles dynamically
  };

  String token = await getAccessTokenFromPref();
  final http.Response response = await http.put(
      Uri.parse('$kUsersUrl/$id'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: body
  );
  var p = json.decode(response.body);
  return p;
}


