import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';
import 'package:dio/dio.dart';

Future storeSalesInvoice(
  String manualReference,
  String clientId,
  String validity,
  String invoiceDeliveryDate,
  String deliveredFromWarehouseId,

  // String paymentTerm,
  String salesInvoiceNumber,
  String priceList,
  String currency,
  // String contactDetails,
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
  Map items,
) async {
  String token = await getAccessTokenFromPref();

  FormData formData = FormData.fromMap({
    "reference": manualReference, //ok
    "clientId": clientId, //ok
    "valueDate": validity, //ok
    "invoiceDeliveryDate": invoiceDeliveryDate, //ok
    "paymentTermId": null, //ok
    "salesInvoiceNumber": salesInvoiceNumber, //?????
    "priceList": priceList, //ok
    "currencyId": currency, //ok

    "termsAndConditions": termsAndConditions,
    "salespersonId": salespersonId, //ok
    "deliveredFromWarehouseId": deliveredFromWarehouseId, //ok
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
    "vatExempt": vatExempt, //ok
    "notPrinted": notPrinted, //ok
    "printedAsVatExempt": printedAsVatExempt, //ok
    "printedAsPercentage": printedAsPercentage, //ok
    "vatInclusivePrices": vatInclusivePrices, //ok
    "beforeVatPrices": beforeVatPrices, //ok
    "code": code,
  });

  for (int i = 1; i < items.length + 1; i++) {
    formData.fields.addAll([
      MapEntry("orderLines[$i][type]", '${items[i]['line_type_id']}'),
      MapEntry(
        "orderLines[$i][item]",
        '${items[i]['item_id']}',
      ), //item means itemCodeId
      MapEntry("orderLines[$i][mainCode]", '${items[i]['item_main_code']}'),
      MapEntry("orderLines[$i][itemName]", '${items[i]['itemName']}'),
      MapEntry("orderLines[$i][discount]", '${items[i]['item_discount']}'),
      MapEntry(
        "orderLines[$i][description]",
        '${items[i]['item_description']}',
      ),
      MapEntry("orderLines[$i][quantity]", '${items[i]['item_quantity']}'),
      MapEntry("orderLines[$i][unitPrice]", '${items[i]['item_unit_price']}'),
      MapEntry("orderLines[$i][total]", '${items[i]['item_total']}'),
      // MapEntry("orderLines[$i][warehouseId]", '${items[i]['item_WarehouseId']}'),
      MapEntry("orderLines[$i][title]", '${items[i]['title']}'),
      MapEntry("orderLines[$i][note]", '${items[i]['note']}'),
      MapEntry("orderLines[$i][combo]", '${items[i]['combo']}'),
      MapEntry("orderLines[$i][comboPrice]",items[i]['combo']==''||items[i]['combo']==null?'': '${items[i]['item_unit_price']}'),
    ]);

    formData.files.addAll([
      MapEntry(
        "orderLines[$i][image]",
        MultipartFile.fromBytes(
          items[i]['image'] ?? [],
          filename: "image[$i].jpg",
        ),
      ),
    ]);
  }

  Response response = await Dio()
      .post(
        kStoreSalesInvoiceUrl,
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
