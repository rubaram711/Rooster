import 'package:shared_preferences/shared_preferences.dart';

saveUserInfoLocally(
  String accessToken,
  String userId,
  String email,
  String name,
  String companyId,
  String companyName,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('accessToken', accessToken);
  prefs.setString('login_ID', userId);
  prefs.setString('email', email);
  prefs.setString('name', name);
  prefs.setString('companyId', companyId);
  prefs.setString('companyName', companyName);
}

Future<Map> getUserInfoFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String accessToken = prefs.getString('accessToken') ?? '';
  String userId = prefs.getString('login_ID') ?? '';
  String email = prefs.getString('email') ?? '';
  String name = prefs.getString('name') ?? '';
  String companyId = prefs.getString('companyId') ?? '';
  String companyName = prefs.getString('companyName') ?? '';
  return {
    'accessToken': accessToken,
    'login_ID': userId,
    'email': email,
    'name': name,
    'companyId': companyId,
    'companyName': companyName,
  };
}

Future<String> getAccessTokenFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String accessToken = prefs.getString('accessToken') ?? '';
  return accessToken;
}

Future<String> getEmailFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String email = prefs.getString('email') ?? '';
  return email;
}

Future<String> getNameFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String nike = prefs.getString('name') ?? '';
  return nike;
}

Future<String> getIdFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('login_ID') ?? '';
  return userId;
}

Future<String> getCompanyIdFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String companyId = prefs.getString('companyId') ?? '';
  return companyId;
}

Future<String> getCompanyNameFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String companyName = prefs.getString('companyName') ?? '';
  return companyName;
}

Future<String> getCostCalculationTypeFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String costCalculationType = prefs.getString('costCalculationType') ?? '';
  return costCalculationType;
}

Future<String> getShowQuantitiesOnPosFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String showQuantitiesOnPos = prefs.getString('showQuantitiesOnPos') ?? '';
  return showQuantitiesOnPos;
}

Future<String> getShowLogoOnPosFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String showLogoOnPos = prefs.getString('showLogoOnPos') ?? '';
  return showLogoOnPos;
}

saveCompanySettingsLocally(
  String costCalculationType,
  String showQuantitiesOnPos,
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
  String primaryCurrency,
  String primaryCurrencyId,
  String primaryCurrencySymbol,
  String companySubjectToVat,
  String posCurrency,
  String posCurrencyId,
  String posCurrencySymbol,
  String showLogoOnPos,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('costCalculationType', costCalculationType);
  prefs.setString('showQuantitiesOnPos', showQuantitiesOnPos);
  prefs.setString('showLogoOnPos', showLogoOnPos);
  prefs.setString('logo', logo);
  prefs.setString('fullCompanyName', fullCompanyName);
  prefs.setString('companyEmail', companyEmail);
  prefs.setString('vat', vat);
  prefs.setString('mobileNumber', mobileNumber);
  prefs.setString('phoneNumber', phoneNumber);
  prefs.setString('trn', trn);
  prefs.setString('bankInfo', bankInfo);
  prefs.setString('address', address);
  prefs.setString('phoneCode', phoneCode);
  prefs.setString('mobileCode', mobileCode);
  prefs.setString('localPayments', localPayments);
  prefs.setString('primaryCurrency', primaryCurrency);
  prefs.setString('primaryCurrencyId', primaryCurrencyId);
  prefs.setString('primaryCurrencySymbol', primaryCurrencySymbol);
  prefs.setString('posCurrency', posCurrency);
  prefs.setString('posCurrencyId', posCurrencyId);
  prefs.setString('posCurrencySymbol', posCurrencySymbol);
  prefs.setString('companySubjectToVat', companySubjectToVat);
}

Future<String> getFullCompanyNameFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String fullCompanyName = prefs.getString('fullCompanyName') ?? '';
  return fullCompanyName;
}

Future<String> getCompanyEmailFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String companyEmail = prefs.getString('companyEmail') ?? '';
  return companyEmail;
}

Future<String> getCompanyPhoneNumberFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String phoneNumber = prefs.getString('phoneNumber') ?? '';
  return phoneNumber;
}

Future<String> getCompanyMobileNumberFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String mobileNumber = prefs.getString('mobileNumber') ?? '';
  return mobileNumber;
}

Future<String> getCompanyVatFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String vat = prefs.getString('vat') ?? '0';
  return vat;
}

Future<String> getCompanyLogoFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String logo = prefs.getString('logo') ?? '';
  return logo;
}

Future<String> getCompanyTrnFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String trn = prefs.getString('trn') ?? '';
  return trn;
}

Future<String> getCompanyBankInfoFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String bankInfo = prefs.getString('bankInfo') ?? '';
  return bankInfo;
}

Future<String> getCompanyAddressFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String address = prefs.getString('address') ?? '';
  return address;
}

Future<String> getCompanyPhoneCodeFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String phoneCode = prefs.getString('phoneCode') ?? '';
  return phoneCode;
}

Future<String> getCompanyMobileCodeFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String mobileCode = prefs.getString('mobileCode') ?? '';
  return mobileCode;
}

Future<String> getCompanyLocalPaymentsFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String localPayments = prefs.getString('localPayments') ?? '';
  return localPayments;
}

Future<String> getCompanyPrimaryCurrencyFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String primaryCurrency = prefs.getString('primaryCurrency') ?? 'USD';
  return primaryCurrency;
}

Future<String> getCompanyPrimaryCurrencyIdFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String primaryCurrencyId = prefs.getString('primaryCurrencyId') ?? '';
  return primaryCurrencyId;
}

Future<String> getCompanyPrimaryCurrencySymbolFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String primaryCurrencySymbol = prefs.getString('primaryCurrencySymbol') ?? '';
  return primaryCurrencySymbol;
}

Future<String> getCompanyPosCurrencyFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String posCurrency = prefs.getString('posCurrency') ?? '';
  return posCurrency;
}

Future<String> getCompanyPosCurrencyIdFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String posCurrencyId = prefs.getString('posCurrencyId') ?? '';
  return posCurrencyId;
}

Future<String> getCompanyPosCurrencySymbolFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String posCurrencySymbol = prefs.getString('posCurrencySymbol') ?? '';
  return posCurrencySymbol;
}

Future<String> getCompanySubjectToVatFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String companySubjectToVat = prefs.getString('companySubjectToVat') ?? '';
  return companySubjectToVat;
}
