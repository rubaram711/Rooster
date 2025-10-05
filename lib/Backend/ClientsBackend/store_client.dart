import 'package:dio/dio.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';






Future storeClient(
    String reference,
    String showOnPos,
    String grantedDiscount,
    String isBlocked,
    String clientType,
    String name,
    String clientNumber,
    String country,
    String city,
    String state,
    String zip,
    String street,
    String floorBldg,
    String jobPosition,
    String phoneCode,
    String phone,
    String mobileCode,
    String mobile,
    String email,
    String title,
    String tags,
    String taxId,
    String website,
    String addressType,
    String contactName,
    String countryContact,
    String cityContact,
    String stateContact,
    String zipContact,
    String streetContact,
    String phoneContactCode,
    String phoneContact,
    String mobileContactCode,
    String mobileContact,
    String emailContact,
    String salesperson,
    String paymentTerm,
    String pricelist,
    String internalNote,
    String clientCompany,
    List contacts,
    List cars,
    ) async
{
  // print('object111');
  String token = await getAccessTokenFromPref();
  var body={
    "showOnPos": showOnPos,
    "grantedDiscount": grantedDiscount,
    "isBlocked": isBlocked,
    "clientType": clientType,
    "name": name,
    "reference": reference,
    "clientNumber": clientNumber,
    "country": country,
    "city": city,
    "state": state,
    "zip": zip,
    "street": street,
    "floorBldg": floorBldg,
    "jobPosition": jobPosition,
    "phoneCode": phoneCode,
    "phone": phone,
    "mobileCode": mobileCode,
    "mobile": mobile,
    "email": email,
    "title": title,
    "tags": tags,
    "taxId": taxId,
    "website": website,
    "addressType": addressType,
    "contactName": contactName,
    "countryContact": countryContact,
    "cityContact": cityContact,
    "stateContact": stateContact,
    "zipContact": zipContact,
    "streetContact": streetContact,
    "phoneContactCode": phoneContactCode,
    'phoneContact': phoneContact,
    'mobileContactCode': mobileContactCode,
    'mobileContact': mobileContact,
    'emailContact': emailContact,
    'salesperson': salesperson,
    'paymentTerm': paymentTerm,
    'pricelist': pricelist,
    'internalNote': internalNote,
    'clientCompany': clientCompany,
  };
  if(taxId.isEmpty){
    body.remove('taxId');
  }
  if(clientNumber.isEmpty){
    body.remove('clientNumber');
  }
  FormData formData = FormData.fromMap(body);
  for (int i = 0; i < contacts.length; i++) {
    formData.fields.addAll([
      MapEntry("addresses[$i][type]", '${contacts[i]['type']}'),
      MapEntry("addresses[$i][name]", '${contacts[i]['name']}',),
      MapEntry("addresses[$i][title]", '${contacts[i]['title']}',),
      MapEntry("addresses[$i][jobPosition]", '${contacts[i]['jobPosition']}',),
      MapEntry("addresses[$i][deliveryAddress]", '${contacts[i]['deliveryAddress']}',),
      MapEntry("addresses[$i][phoneCode]", '${contacts[i]['phoneCode']}',),
      MapEntry("addresses[$i][phoneNumber]", '${contacts[i]['phoneNumber']}',),
      MapEntry("addresses[$i][extension]", '${contacts[i]['extension']}',),
      MapEntry("addresses[$i][mobileCode]", '${contacts[i]['mobileCode']}',),
      MapEntry("addresses[$i][mobileNumber]", '${contacts[i]['mobileNumber']}',),
      MapEntry("addresses[$i][email]", '${contacts[i]['email']}',),
      MapEntry("addresses[$i][note]", '${contacts[i]['note']}',),
      MapEntry("addresses[$i][internalNote]", '${contacts[i]['internalNote']}',),
    ]);
  }

  for (int i = 0; i < cars.length; i++) {
    formData.fields.addAll([
      MapEntry("cars[$i][carBrandId]", '${cars[i]['brand'].isNotEmpty?cars[i]['brand']['id']:''}'),
      MapEntry("cars[$i][carModelId]", '${cars[i]['model'].isNotEmpty?cars[i]['model']['id']:''}',),
      MapEntry("cars[$i][carColorId]", '${cars[i]['color'].isNotEmpty?cars[i]['color']['id']:''}',),
      MapEntry("cars[$i][carTechnicianId]", '${cars[i]['technician'].isNotEmpty?cars[i]['technician']['id']:''}',),
      MapEntry("cars[$i][plateNumber]", '${cars[i]['registration']}',),
      MapEntry("cars[$i][chassisNumber]", '${cars[i]['chassis_no']}',),
      MapEntry("cars[$i][carFax]", '${cars[i]['car_fax']}',),
      MapEntry("cars[$i][year]", '${cars[i]['year']}',),
      MapEntry("cars[$i][rating]", '${cars[i]['rating']}',),
      MapEntry("cars[$i][odometer]", '${cars[i]['odometer']}',),
      MapEntry("cars[$i][comment]", '${cars[i]['comment']}',),
    ]);
  }

  Response response = await Dio()
      .post(
    kClientUrl,
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
    return err.response;
    // if (err is DioError) {
    //   print(err.response);
    // }
  });
  // String name='${response.data['data']['order_number']}';
  // print('response.data ${response.data}');
  return response.data;
}




//Future oldStoreClient(
//   String reference,
//   String showOnPos,
//   String grantedDiscount,
//   String isBlocked,
//   String clientType,
//   String name,
//   String clientNumber,
//   String country,
//   String city,
//   String state,
//   String zip,
//   String street,
//   String floorBldg,
//   String jobPosition,
//   String phoneCode,
//   String phone,
//   String mobileCode,
//   String mobile,
//   String email,
//   String title,
//   String tags,
//   String taxId,
//   String website,
//   String addressType,
//   String contactName,
//   String countryContact,
//   String cityContact,
//   String stateContact,
//   String zipContact,
//   String streetContact,
//   String phoneContactCode,
//   String phoneContact,
//   String mobileContactCode,
//   String mobileContact,
//   String emailContact,
//   String salesperson,
//   String paymentTerm,
//   String pricelist,
//   String internalNote,
//   String clientCompany,
// ) async
// {
//   final uri = Uri.parse(kClientUrl);
//   String token = await getAccessTokenFromPref();
//   var body={
//     "showOnPos": showOnPos,
//     "grantedDiscount": grantedDiscount,
//     "isBlocked": isBlocked,
//     "clientType": clientType,
//     "name": name,
//     "reference": reference,
//     "clientNumber": clientNumber,
//     "country": country,
//     "city": city,
//     "state": state,
//     "zip": zip,
//     "street": street,
//     "floorBldg": floorBldg,
//     "jobPosition": jobPosition,
//     "phoneCode": phoneCode,
//     "phone": phone,
//     "mobileCode": mobileCode,
//     "mobile": mobile,
//     "email": email,
//     "title": title,
//     "tags": tags,
//     "taxId": taxId,
//     "website": website,
//     "addressType": addressType,
//     "contactName": contactName,
//     "countryContact": countryContact,
//     "cityContact": cityContact,
//     "stateContact": stateContact,
//     "zipContact": zipContact,
//     "streetContact": streetContact,
//     "phoneContactCode": phoneContactCode,
//     'phoneContact': phoneContact,
//     'mobileContactCode': mobileContactCode,
//     'mobileContact': mobileContact,
//     'emailContact': emailContact,
//     'salesperson': salesperson,
//     'paymentTerm': paymentTerm,
//     'pricelist': pricelist,
//     'internalNote': internalNote,
//     'clientCompany': clientCompany,
//   };
//   if(taxId.isEmpty){
//     body.remove('taxId');
//   }
//   if(clientNumber.isEmpty){
//     body.remove('clientNumber');
//   }
//   var response = await http.post(uri, headers: {
//     "Accept": "application/json",
//     "Authorization": "Bearer $token"
//   },
//       body: body);
//
//   var p = json.decode(response.body);
//   return p; //p['success']==true
// }