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
  List<int> orderedKeys,
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

  int i = 1;

  for (var key in orderedKeys) {
    formData.fields.addAll([
      MapEntry("orderLines[$i][type]", '${orderLines[key]['line_type_id']}'),

      MapEntry(
        "orderLines[$i][item]",
        '${orderLines[key]['item_id']}',
      ), //item means itemCodeId
      MapEntry(
        "orderLines[$i][mainCode]",
        '${orderLines[key]['item_main_code']}',
      ),
      MapEntry("orderLines[$i][itemName]", '${orderLines[key]['itemName']}'),
      MapEntry(
        "orderLines[$i][discount]",
        '${orderLines[key]['item_discount']}',
      ),
      MapEntry(
        "orderLines[$i][description]",
        '${orderLines[key]['item_description']}',
      ),
      MapEntry(
        "orderLines[$i][quantity]",
        '${orderLines[key]['item_quantity']}',
      ),
      MapEntry(
        "orderLines[$i][item_warehouse_id]",
        '${orderLines[key]['item_warehouseId']}',
      ),
      MapEntry(
        "orderLines[$i][combo_warehouse_id]",
        '${orderLines[key]['combo_warehouseId']}',
      ),
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
        orderLines[key]['combo'] == '' || orderLines[key]['combo'] == null
            ? ''
            : '${orderLines[key]['item_unit_price']}',
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
  print("InBackTo StoreSalesOrder------------");
  print(formData.files);
  print("------------------------------------");
  print(formData.fields);

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
