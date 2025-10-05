import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';

Future updateHeader({
  required String headerId,
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
  required  String companySubjectToVat,
  required  String headerName,
  required  String quotationCurrency,
}
    ) async {
  String token = await getAccessTokenFromPref();
  var p={
    'vat':vat,
    'bankInfo':bankInformation,
    // 'trn':trn,
    'phoneNumber':phone,
    'mobileNumber':mobile,
    'phoneCode':selectedPhoneCode,
    'mobileCode':selectedMobileCode,
    'address':address,
    'fullCompanyName':companyName,
    'localPayments':localPayments,
    'companySubjectToVat':companySubjectToVat,
    'headerName':headerName,
  };
  if(email.isNotEmpty){
    p.addAll({'email':email,});
  }
  if(trn.isNotEmpty){
    p.addAll({'trn':trn,});
  }
  if(quotationCurrency.isNotEmpty){
    p.addAll({'defaultQuotationCurrencyId':quotationCurrency,});
  }
  FormData formData = FormData.fromMap(p);
  if(imageFile!=null) {
    formData.files.add(
      MapEntry("logo", MultipartFile.fromBytes(imageFile, filename: "image.jpg")),
    );
  }

  Response response = await Dio()
      .post(
    '$kHeadersUrl/$headerId/update',
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
