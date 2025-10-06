import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';
import 'package:dio/dio.dart';

Future updateSalesInvoice(
  String id,
  bool isTermsAndConditionsUpdated,
  String manualReference,
  String clientId,
  String validity,
  String deliveredFromWarehouse,
  String paymentTerm,
  String priceList,
  String currency,
  String termsAndConditions,
  String salespersonId,
  String commissionMethodId,
  String cashingMethodId,
  String commissionRate,
  String commissionTotal,
  String totalBeforeVat,
  String specialDiscountPercentage,
  String specialDiscount,
  String globalDiscountPercentage,
  String globalDiscount,
  String vat,
  String vatLebanese,
  String total,
  String vatExempt,
  String notPrinted,
  String printedAsVatExempt,
  String printedAsPercentage,
  String vatInclusivePrices,
  String beforeVatPrices,
  String code,
  String status,
  Map orderLines,
  String inputDate,
  String invoiceDeliveryDate,
    List<int> orderedKeys ,
    String invoiceType,
    String companyHeaderId ,
) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "reference": manualReference,
    "clientId": clientId,
    "valueDate": validity,
    "paymentTerm": paymentTerm,
    // "contactDetails": contactdetails,
    "deliveredFromWarehouseId": deliveredFromWarehouse,
    "pricelistId": priceList,
    "currencyId": currency,
    // "termsAndConditions":termsAndConditions,
    "salespersonId": salespersonId,
    "commissionMethodId": commissionMethodId,
    "cashingMethodId": cashingMethodId,
    "commissionRate": commissionRate,
    "commissionTotal": commissionTotal,
    "totalBeforeVat": totalBeforeVat,
    "specialDiscountPercentage": specialDiscountPercentage,
    "specialDiscount": specialDiscount,
    "globalDiscountPercentage": globalDiscountPercentage,
    "globalDiscount": globalDiscount,
    "vat": vat,
    "vatLebanese": vatLebanese,
    "total": total,
    "vatExempt": vatExempt,
    "notPrinted": notPrinted,
    "printedAsVatExempt": printedAsVatExempt,
    "printedAsPercentage": printedAsPercentage,
    "vatInclusivePrices": vatInclusivePrices,
    "beforeVatPrices": beforeVatPrices,
    "code": code,
    "status": status,
    "inputDate": inputDate,
    "invoiceDeliveryDate": invoiceDeliveryDate,
    "invoiceType": invoiceType  ,
    "companyHeaderId": companyHeaderId,
  });

  if (isTermsAndConditionsUpdated) {
    formData.fields.add(MapEntry('termsAndConditions', termsAndConditions));
  }

  int i = 1;

  for (var key in orderedKeys) {
    formData.fields.addAll([
      ///MapEntry("back value",'front value')
      MapEntry("orderLines[$i][type]", '${orderLines[key]['line_type_id']}'),
      MapEntry("orderLines[$i][item]", '${orderLines[key]['item_id']}'),
      MapEntry(
        "orderLines[$i][mainCode]",
        '${orderLines[key]['item_main_code']}',
      ),
      MapEntry("orderLines[$i][itemName]", '${orderLines[key]['itemName']}'),
      MapEntry("orderLines[$i][discount]", '${orderLines[key]['item_discount']}'),
      MapEntry(
        "orderLines[$i][description]",
        '${orderLines[key]['item_description']}',
      ),
      MapEntry("orderLines[$i][quantity]", '${orderLines[key]['item_quantity']}'),
      MapEntry(
        "orderLines[$i][unitPrice]",
        '${orderLines[key]['item_unit_price']}',
      ),
      MapEntry("orderLines[$i][total]", '${orderLines[key]['item_total']}'),
      MapEntry("orderLines[$i][title]", '${orderLines[key]['title']}'),
      MapEntry("orderLines[$i][note]", '${orderLines[key]['note']}'),
      MapEntry("orderLines[$i][combo]", '${orderLines[key]['combo']}'),
      MapEntry(
        "orderLines[$i][comboPrice]",
        orderLines[key]['combo']==''||orderLines[key]['combo']==null?'':
          '${orderLines[key]['item_unit_price']}',
      ),
    ]);
    // print( 'hfrym  ${orderLines[key]['image']}');

    formData.files.addAll([
      MapEntry(
        "orderLines[$i][image]",
        MultipartFile.fromBytes(
          orderLines[key]['image'] ?? [],
          filename: "image[$i].jpg",
        ),
      ),
    ]);
    i++;
  }

  // '$kStoreQuotationUrl/$id',

  Response response = await Dio()
      .post(
        '$kUpdateSalesInvoiceUrl/$id',
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
        // print('100');
        // print(err.response);
        return err.response;
      });

  // print('response.data ${response.data}');
  // var p = json.decode(response.data);
  // print('updated $p');
  // return p; //p['success']==true
  return response.data;
}

// Future updateOldSalesInvoice(
//   String id,
//   String manualReference,
//   String clientId,
//   String validity,
//   String paymentTerm,
//   String priceList,
//   String currency,
//   String termsAndConditions,
//   String salespersonId,
//   String commissionMethodId,
//   String cashingMethodId,
//   String commissionRate,
//   String commissionTotal,
//
//   String totalBeforeVat,
//   String specialDiscountPercentage,
//   String specialDiscount,
//   String globalDiscountPercentage,
//   String globalDiscount,
//   String vat,
//   String vatLebanese,
//   String total,
//   String vatExempt,
//   String notPrinted,
//   String printedAsVatExempt,
//   String printedAsPercentage,
//
//   String vatInclusivePrices,
//   String beforeVatPrices,
//   String code,
//   String status,
//   // Map orderLines
// ) async
// {
//   final uri = Uri.parse('$kUpdateSalesOrder/$id');
//   String token = await getAccessTokenFromPref();
//   var response = await http.put(
//     uri,
//     headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
//     body: {
//       "manualReference": manualReference,
//       "clientId": clientId,
//       "validity": validity,
//       "paymentTerm": paymentTerm,
//       "priceList": priceList,
//       "currency": currency,
//       "termsAndConditions": termsAndConditions,
//       "salespersonId": salespersonId,
//       "commissionMethodId": commissionMethodId,
//       "cashingMethodId": cashingMethodId,
//       "commissionRate": commissionRate,
//       "commissionTotal": commissionTotal,
//
//       "totalBeforeVat": totalBeforeVat,
//       "specialDiscountPercentage": specialDiscountPercentage,
//       "specialDiscount": specialDiscount,
//       "globalDiscountPercentage": globalDiscountPercentage,
//       "globalDiscount": globalDiscount,
//       "vat": vat,
//       "vatLebanese": vatLebanese,
//       "total": total,
//       "vatExempt": vatExempt,
//       "notPrinted": notPrinted,
//       "printedAsVatExempt": printedAsVatExempt,
//       "printedAsPercentage": printedAsPercentage,
//       "vatInclusivePrices": vatInclusivePrices,
//       "beforeVatPrices": beforeVatPrices,
//       "code": code,
//       "status": status,
//     },
//   );
//
//   var p = json.decode(response.body);
//   // print('updated $p');
//   return p; //p['success']==true
// }
