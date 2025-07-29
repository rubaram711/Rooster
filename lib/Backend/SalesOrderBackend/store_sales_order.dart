import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';
import 'package:dio/dio.dart';

Future storeSalesOrder(
  String manualReference,
  String clientId,
  String validity,
  String inputDate,
  String paymentTerm,
  String salesOrderNumber,
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
  Map orderLines,
  String title,
) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "manualReference": manualReference,
    "clientId": clientId,
    "validity": validity,
    "inputDate": inputDate,
    "paymentTerm": paymentTerm,
    "salesOrderNumber": salesOrderNumber,
    "priceList": priceList,
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
    "title": title,
  });

  for (int i = 1; i < orderLines.length + 1; i++) {
    formData.fields.addAll([
      MapEntry("orderLines[$i][type]", '${orderLines[i]['line_type_id']}'),

      MapEntry(
        "orderLines[$i][item]",
        '${orderLines[i]['item_id']}',
      ), //item means itemCodeId
      MapEntry(
        "orderLines[$i][mainCode]",
        '${orderLines[i]['item_main_code']}',
      ),
      MapEntry("orderLines[$i][itemName]", '${orderLines[i]['itemName']}'),
      MapEntry("orderLines[$i][discount]", '${orderLines[i]['item_discount']}'),
      MapEntry(
        "orderLines[$i][description]",
        '${orderLines[i]['item_description']}',
      ),
      MapEntry("orderLines[$i][quantity]", '${orderLines[i]['item_quantity']}'),
      MapEntry(
        "orderLines[$i][item_warehouse_id]",
        '${orderLines[i]['item_warehouseId']}',
      ),
      MapEntry(
        "orderLines[$i][combo_warehouse_id]",
        '${orderLines[i]['item_warehouseId']}',
      ),
      MapEntry(
        "orderLines[$i][unitPrice]",
        '${orderLines[i]['item_unit_price']}',
      ),
      MapEntry("orderLines[$i][total]", '${orderLines[i]['item_total']}'),
      MapEntry("orderLines[$i][title]", '${orderLines[i]['title']}'),
      MapEntry("orderLines[$i][note]", '${orderLines[i]['note']}'),
      MapEntry("orderLines[$i][combo]", '${orderLines[i]['combo']}'),
      MapEntry(
        "orderLines[$i][comboPrice]",
        orderLines[i]['combo'] == '' || orderLines[i]['combo'] == null
            ? ''
            : '${orderLines[i]['item_unit_price']}',
      ),
    ]);

    formData.files.addAll([
      MapEntry(
        "orderLines[$i][image]",
        MultipartFile.fromBytes(
          orderLines[i]['image'] ?? [],
          filename: "image[$i].jpg",
        ),
      ),
    ]);
  }

  Response response = await Dio()
      .post(
        kStoreSalesOrderUrl,
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
      });

  return response.data;
}
