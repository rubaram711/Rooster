

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';
import 'package:dio/dio.dart';

Future updateDelivery(
  String id,
  String clientId,
  String driverId,
  String reference,
  String date,
  String expectedDelivery,
  String status,

  Map orderLines,
) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "reference": reference,
    "clientId": clientId,
    "driverId": driverId,
    "date": date,
    "paymentTerm": null,
    "expectedDelivery": expectedDelivery,
    "status": status,
  });

  for (int i = 1; i < orderLines.length + 1; i++) {
    formData.fields.addAll([
      ///MapEntry("back value",'front value')
      MapEntry("orderLines[$i][type]", '${orderLines[i]['line_type_id']}'),
      MapEntry("orderLines[$i][item]", '${orderLines[i]['item_id']}'),
      MapEntry(
        "orderLines[$i][mainCode]",
        '${orderLines[i]['item_main_code']}',
      ),
      MapEntry("orderLines[$i][itemName]", '${orderLines[i]['itemName']}'),
      MapEntry(
        "orderLines[$i][item_warehouse_id]",
        '${orderLines[i]['item_warehouseId']}',
      ),

      MapEntry(
        "orderLines[$i][description]",
        '${orderLines[i]['item_description']}',
      ),
      MapEntry("orderLines[$i][quantity]", '${orderLines[i]['item_quantity']}'),
      MapEntry("orderLines[$i][item_package_name]", ''),

      MapEntry("orderLines[$i][title]", '${orderLines[i]['title']}'),
      MapEntry("orderLines[$i][note]", '${orderLines[i]['note']}'),
      MapEntry("orderLines[$i][combo]", '${orderLines[i]['combo']}'),
      MapEntry(
        "orderLines[$i][comboPrice]",
        orderLines[i]['combo'] == '' || orderLines[i]['combo'] == null
            ? ''
            : '${orderLines[i]['item_unit_price']}',
      ),
      MapEntry(
        "orderLines[$i][combo_warehouse_id]",
        '${orderLines[i]['combo_warehouseId']}',
      ),
    ]);
    // print( 'hfrym  ${orderLines[i]['image']}');

    formData.files.addAll([
      MapEntry(
        "orderLines[$i][image]",
        MultipartFile.fromBytes(
          orderLines[i]['image'] ?? [0],
          filename: "image[$i].jpg",
        ),
      ),
    ]);
  }

  // '$kStoreQuotationUrl/$id',

  Response response = await Dio()
      .post(
        '$kUpdateDeliveryUrl/$id',
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

// Future updateOldDelivery(
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

//   String vatInclusivePrices,
//   String beforeVatPrices,
//   String code,
//   String status,
//   // Map orderLines
// ) async {
//   final uri = Uri.parse('$kUpdateDeliveryUrl/$id');
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

//   var p = json.decode(response.body);
//   // print('updated $p');
//   return p; //p['success']==true
// }
