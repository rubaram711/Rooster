import 'package:shared_preferences/shared_preferences.dart';

saveUserInfoLocally(
  String accessToken,
  String userId,
  String email,
  String name,
  String companyId,
  String companyName,
  String isItGarage,
  String isItHasDoubleBook,
  String isItHasMultiHeaders,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('accessToken', accessToken);
  prefs.setString('identifier2', userId);
  prefs.setString('email', email);
  prefs.setString('name', name);
  prefs.setString('companyId', companyId);
  prefs.setString('companyName', companyName);
  prefs.setString('isItGarage', isItGarage);
  prefs.setString('isItHasDoubleBook', isItHasDoubleBook);
  prefs.setString('isItHasMultiHeaders', isItHasMultiHeaders);
}

Future<Map> getUserInfoFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String accessToken = prefs.getString('accessToken') ?? '';
  String userId = prefs.getString('identifier2') ?? '';
  String email = prefs.getString('email') ?? '';
  String name = prefs.getString('name') ?? '';
  String companyId = prefs.getString('companyId') ?? '';
  String companyName = prefs.getString('companyName') ?? '';
  String isItGarage = prefs.getString('isItGarage') ?? '0';
  String isItHasDoubleBook = prefs.getString('isItHasDoubleBook') ?? '0';
  String isItHasMultiHeaders = prefs.getString('isItHasMultiHeaders') ?? '0';
  return {
    'accessToken': accessToken,
    'identifier2': userId,
    'email': email,
    'name': name,
    'companyId': companyId,
    'companyName': companyName,
    'isItGarage': isItGarage,
    'isItHasDoubleBook': isItHasDoubleBook,
    'isItHasMultiHeaders': isItHasMultiHeaders,
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
  String userId = prefs.getString('identifier2') ?? '';
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

Future<String> getIsItGarageFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String isItGarage = prefs.getString('isItGarage') ?? '0';
  return isItGarage;
}
Future<String> getIsItHasDoubleBookFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String isItHasDoubleBook = prefs.getString('isItHasDoubleBook') ?? '0';
  return isItHasDoubleBook;
}
Future<String> getIsItHasMultiHeadersFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String isItHasMultiHeaders = prefs.getString('isItHasMultiHeaders') ?? '0';
  return isItHasMultiHeaders;
}

saveCompanySettingsLocally(
  String costCalculationType,
  String showQuantitiesOnPos,
  // String logo,
  // String fullCompanyName,
  // String companyEmail,
  // String vat,
  // String mobileNumber,
  // String phoneNumber,
  // String trn,
  // String bankInfo,
  // String address,
  // String phoneCode,
  // String mobileCode,
  // String localPayments,
  String primaryCurrency,
  String primaryCurrencyId,
  String primaryCurrencySymbol,
  // String companySubjectToVat,
  String posCurrency,
  String posCurrencyId,
  String posCurrencySymbol,
    String primaryCurrencyLatestRate,
    String posCurrencyLatestRate,
  String showLogoOnPos,
  // String headerName,
) async
{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('costCalculationType', costCalculationType);
  prefs.setString('showQuantitiesOnPos', showQuantitiesOnPos);
  prefs.setString('showLogoOnPos', showLogoOnPos);
  // prefs.setString('logo', logo);
  // prefs.setString('fullCompanyName', fullCompanyName);
  // prefs.setString('companyEmail', companyEmail);
  // prefs.setString('vat', vat);
  // prefs.setString('mobileNumber', mobileNumber);
  // prefs.setString('phoneNumber', phoneNumber);
  // prefs.setString('trn', trn);
  // prefs.setString('bankInfo', bankInfo);
  // prefs.setString('address', address);
  // prefs.setString('phoneCode', phoneCode);
  // prefs.setString('mobileCode', mobileCode);
  // prefs.setString('localPayments', localPayments);
  prefs.setString('primaryCurrency', primaryCurrency);
  prefs.setString('primaryCurrencyId', primaryCurrencyId);
  prefs.setString('primaryCurrencySymbol', primaryCurrencySymbol);
  prefs.setString('posCurrency', posCurrency);
  prefs.setString('posCurrencyId', posCurrencyId);
  prefs.setString('posCurrencySymbol', posCurrencySymbol);
  prefs.setString('posCurrencyLatestRate', posCurrencyLatestRate);
  prefs.setString('primaryCurrencyLatestRate', primaryCurrencyLatestRate);
  // prefs.setString('companySubjectToVat', companySubjectToVat);
  // prefs.setString('headerName', headerName);
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
  String logo = prefs.getString('logo') ?? 'https://share.google/images/DwDJv41UrDDARwPui';
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


Future<String> getPosCurrencyLatestRateFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String posCurrencyLatestRate = prefs.getString('posCurrencyLatestRate') ?? '';
  return posCurrencyLatestRate;
}
Future<String> getPrimaryCurrencyLatestRateFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String primaryCurrencyLatestRate = prefs.getString('primaryCurrencyLatestRate') ?? '1';
  return primaryCurrencyLatestRate;
}

Future<String> getHeaderNameFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String headerName = prefs.getString('headerName') ?? '';
  return headerName;
}

Future<String> getHeaderIdFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String headerName = prefs.getString('headerId') ?? '';
  return headerName;
}
Future<String> getQuotationCurrencyNameFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String headerName = prefs.getString('quotationCurrencyName') ?? '';
  return headerName;
}

Future<String> getQuotationCurrencyIdFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String headerName = prefs.getString('quotationCurrencyId') ?? '';
  return headerName;
}


saveHeader1Locally(
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
    String quotationCurrencyId,
    String quotationCurrencyName,
    ) async
{
  SharedPreferences prefs = await SharedPreferences.getInstance();
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
  prefs.setString('companySubjectToVat', companySubjectToVat);
  prefs.setString('headerName', headerName);
  prefs.setString('headerId', headerId);
  prefs.setString('quotationCurrencyId', quotationCurrencyId);
  prefs.setString('quotationCurrencyName', quotationCurrencyName);
}

