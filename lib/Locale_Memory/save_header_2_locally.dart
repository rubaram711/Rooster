import 'package:shared_preferences/shared_preferences.dart';


saveHeader2Locally(
    String logo,
    String fullCompanyName,
    String companyEmail,
    String vat,
    String mobileNumber,
    String phoneNumber,
    String trn,
    String bankInfo,
    String address,
    String phoneCode,
    String mobileCode,
    String localPayments,
    String companySubjectToVat,
    String headerName,
    String headerId,
    ) async
{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('logo2', logo);
  prefs.setString('fullCompanyName2', fullCompanyName);
  prefs.setString('companyEmail2', companyEmail);
  prefs.setString('vat2', vat);
  prefs.setString('mobileNumber2', mobileNumber);
  prefs.setString('phoneNumber2', phoneNumber);
  prefs.setString('trn2', trn);
  prefs.setString('bankInfo2', bankInfo);
  prefs.setString('address2', address);
  prefs.setString('phoneCode2', phoneCode);
  prefs.setString('mobileCode2', mobileCode);
  prefs.setString('localPayments2', localPayments);
  prefs.setString('companySubjectToVat2', companySubjectToVat);
  prefs.setString('headerName2', headerName);
  prefs.setString('headerId2', headerId);
}


Future<String> getHeaderId2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String headerId = prefs.getString('headerId2') ?? '';
  return headerId;
}

Future<String> getHeaderName2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String headerName = prefs.getString('headerName2') ?? '';
  return headerName;
}


Future<String> getCompanySubjectToVat2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String companySubjectToVat = prefs.getString('companySubjectToVat2') ?? '';
  return companySubjectToVat;
}


Future<String> getFullCompanyName2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String fullCompanyName = prefs.getString('fullCompanyName2') ?? '';
  return fullCompanyName;
}

Future<String> getCompanyEmail2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String companyEmail = prefs.getString('companyEmail2') ?? '';
  return companyEmail;
}

Future<String> getCompanyPhoneNumber2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String phoneNumber = prefs.getString('phoneNumber2') ?? '';
  return phoneNumber;
}

Future<String> getCompanyMobileNumber2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String mobileNumber = prefs.getString('mobileNumber2') ?? '';
  return mobileNumber;
}

Future<String> getCompanyVat2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String vat = prefs.getString('vat2') ?? '0';
  return vat;
}

Future<String> getCompanyLogo2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String logo = prefs.getString('logo2') ?? '';
  return logo;
}

Future<String> getCompanyTrn2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String trn = prefs.getString('trn2') ?? '';
  return trn;
}

Future<String> getCompanyBankInfo2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String bankInfo = prefs.getString('bankInfo2') ?? '';
  return bankInfo;
}

Future<String> getCompanyAddress2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String address = prefs.getString('address2') ?? '';
  return address;
}

Future<String> getCompanyPhoneCode2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String phoneCode = prefs.getString('phoneCode2') ?? '';
  return phoneCode;
}

Future<String> getCompanyMobileCode2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String mobileCode = prefs.getString('mobileCode2') ?? '';
  return mobileCode;
}

Future<String> getCompanyLocalPayments2FromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String localPayments = prefs.getString('localPayments2') ?? '';
  return localPayments;
}