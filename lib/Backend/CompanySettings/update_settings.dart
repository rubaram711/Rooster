import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';

Future updateSettings({required String companyId,
  required String costCalculationType,
  required String showQuantitiesOnPos,
  Uint8List? imageFile,
  required  String selectedPhoneCode,
  required  String selectedMobileCode,
  required  String companyName,
  required  String address,
  required  String mobile,
  required  String phone,
  required  String email,
  required  String trn,
  required  String bankInformation,
  required  String localPayments,
  required  String vat,
  required  String primaryCurrencyId,
  required  String companySubjectToVat,
  required  String posCurrencyId,
  required  String showLogoOnPos,
}
) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "companyId": companyId,
    "costCalculationType": costCalculationType,
    "showQuantitiesOnPos": showQuantitiesOnPos,
    'email':email,
    'vat':vat,
    'bankInfo':bankInformation,
    'trn':trn,
    'phoneNumber':phone,
    'mobileNumber':mobile,
    'phoneCode':selectedPhoneCode,
    'mobileCode':selectedMobileCode,
    'address':address,
    'fullCompanyName':companyName,
    'localPayments':localPayments,
    'primaryCurrencyId':primaryCurrencyId,
    'companySubjectToVat':companySubjectToVat,
    'posCurrencyId':posCurrencyId,
    'showLogoOnPos':showLogoOnPos,
  });
if(imageFile!=null) {
  formData.files.add(
    MapEntry("logo", MultipartFile.fromBytes(imageFile, filename: "image.jpg")),
  );
}

  Response response = await Dio()
      .post(
        kSettingsUrl,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      )
      .catchError((err) {
        // if (err is DioError) {
        //   print(err.response);
        // }
        return err.response;
      });
  // print('lll #%${response.data['data']}');
  return response.data;
}
