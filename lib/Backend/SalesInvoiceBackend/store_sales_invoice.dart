import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';
import 'package:dio/dio.dart';

Future storeSalesInvoice(
  String manualReference,
  String clientId,
  String validity,
  String invoiceDeliveryDate,
  String deliveredFromWarehouseId,

  String paymentTerm,
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
  List<int> orderedKeys,
    String invoiceType,
    String companyHeaderId,
    ) async {
  String token = await getAccessTokenFromPref();

  FormData formData = FormData.fromMap({
    "reference": manualReference, //ok
    "clientId": clientId, //ok
    "valueDate": validity, //ok
    "inputDate": invoiceDeliveryDate, //ok
    "paymentTerm": paymentTerm, //ok
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
    "invoiceType": invoiceType  ,
    "companyHeaderId": companyHeaderId,

  });

  int i = 1;

  for (var key in orderedKeys) {
    formData.fields.addAll([
      MapEntry("orderLines[$i][type]", '${items[key]['line_type_id']}'),
      MapEntry(
        "orderLines[$i][item]",
        '${items[key]['item_id']}',
      ), //item means itemCodeId
      MapEntry("orderLines[$i][mainCode]", '${items[key]['item_main_code']}'),
      MapEntry("orderLines[$i][itemName]", '${items[key]['itemName']}'),
      MapEntry("orderLines[$i][discount]", '${items[key]['item_discount']}'),
      MapEntry(
        "orderLines[$i][description]",
        '${items[key]['item_description']}',
      ),
      MapEntry("orderLines[$i][quantity]", '${items[key]['item_quantity']}'),
      MapEntry("orderLines[$i][unitPrice]", '${items[key]['item_unit_price']}'),
      MapEntry("orderLines[$i][total]", '${items[key]['item_total']}'),
      // MapEntry("orderLines[$i][warehouseId]", '${items[key]['item_WarehouseId']}'),
      MapEntry("orderLines[$i][title]", '${items[key]['title']}'),
      MapEntry("orderLines[$i][note]", '${items[key]['note']}'),
      MapEntry("orderLines[$i][combo]", '${items[key]['combo']}'),
      MapEntry(
        "orderLines[$i][comboPrice]",
        items[key]['combo'] == '' || items[key]['combo'] == null
            ? ''
            : '${items[key]['item_unit_price']}',
      ),
    ]);

    formData.files.addAll([
      MapEntry(
        "orderLines[$i][image]",
        MultipartFile.fromBytes(
          items[key]['image'] ?? [],
          filename: "image[$i].jpg",
        ),
      ),
    ]);

    i++;
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
