import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/PendingDocs/get_pending_docs.dart';

abstract class PendingDocsReviewControllerAbstract extends GetxController {
  getAllPendingDocs();
  setLogo(Uint8List val);
  setSearchInPendingDocsController(String value);
}

class PendingDocsReviewController extends PendingDocsReviewControllerAbstract {
  Uint8List logoBytes = Uint8List(0);
  @override
  setLogo(Uint8List val) {
    logoBytes = val;
    update();
  }

  TextEditingController searchInPendingDocsController = TextEditingController();
  @override
  setSearchInPendingDocsController(String value) {
    searchInPendingDocsController.text = value;
    update();
  }

  List quotationsPendingDocs = [];
  List salesOrdersPendingDocs = [];
  List salesInvoicesPendingDocs = [];
  List mergeQuotationAndSalesOrderPendingDocs = [];
  bool isPendingDocsFetched = false;
  @override
  getAllPendingDocs() async {
    quotationsPendingDocs = [];
    salesOrdersPendingDocs = [];
    salesInvoicesPendingDocs = [];
    mergeQuotationAndSalesOrderPendingDocs = [];

    isPendingDocsFetched = false;
    // update();
    var p = await getPendingDocsFromBack(searchInPendingDocsController.text);
    if ('$p' != '[]') {
      quotationsPendingDocs = p["quotations"];
      salesOrdersPendingDocs = p["salesOrders"];
      salesInvoicesPendingDocs = p["salesInvoices"];

      quotationsPendingDocs = quotationsPendingDocs.reversed.toList();
      salesOrdersPendingDocs = salesOrdersPendingDocs.reversed.toList();
      salesInvoicesPendingDocs = salesInvoicesPendingDocs.reversed.toList();

      // Add quotation items with "type"
      mergeQuotationAndSalesOrderPendingDocs.addAll(
        quotationsPendingDocs.map((item) => {...item, 'type': 'quotation'}),
      );

      // Add sales order items with "type"
      mergeQuotationAndSalesOrderPendingDocs.addAll(
        salesOrdersPendingDocs.map((item) => {...item, 'type': 'sales order'}),
      );
      // Add sales Invoice items with "type"
      mergeQuotationAndSalesOrderPendingDocs.addAll(
        salesInvoicesPendingDocs.map(
          (item) => {...item, 'type': 'sales invoice'},
        ),
      );

      isPendingDocsFetched = true;
    }
    isPendingDocsFetched = true;
    update();
  }
}
