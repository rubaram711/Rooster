import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';
import 'package:dio/dio.dart';

Future updateQuotation(
    String id,
    // bool isTermsAndConditionsUpdated,
    String manualReference,
    String clientId,
    String validity,
    String inputDate,
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
    List<int> orderedKeys ,
    String cancellationReason,
    String deliveryTerms,
    String chance,
    String companyHeaderId,
    String termsAdnConditionId,
    ) async {
  String token = await getAccessTokenFromPref();
  var p={
    "manualReference": manualReference,
    "clientId": clientId,
    "validity": validity,
    "inputDate": inputDate,
    "paymentTerm": paymentTerm,
    "pricelistId": priceList,
    "currency": currency,
    "termsAndConditions": termsAndConditions,
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
    "cancellationReason":cancellationReason,
    "deliveryTermId":deliveryTerms,
    "chance":chance,
    "termsAdnConditionId":termsAdnConditionId,
  };
  if(companyHeaderId.isNotEmpty){
    p.addAll({"companyHeaderId":companyHeaderId,});
  }
  FormData formData = FormData.fromMap(p);

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
        "orderLines[$i][unitPrice]",orderLines[key]['combo']==''||orderLines[key]['combo']==null?
        '${orderLines[key]['item_unit_price']}':'',
      ),
      MapEntry("orderLines[$i][total]", '${orderLines[key]['item_total']}'),
      MapEntry("orderLines[$i][title]", '${orderLines[key]['title']}'),
      MapEntry("orderLines[$i][note]", '${orderLines[key]['note']}'),
      MapEntry("orderLines[$i][combo]", '${orderLines[key]['combo']}'),
      MapEntry(
        "orderLines[$i][comboPrice]",orderLines[key]['combo']==''||orderLines[key]['combo']==null?'':
        '${orderLines[key]['item_unit_price']}',
      ),
    ]);

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
        '$kUpdateQuotation/$id',
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

// Future updateQuotations(
//   String id,
//
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
// ) async {
//   final uri = Uri.parse('$kStoreQuotationUrl/$id');
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



