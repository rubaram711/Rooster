import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';

import 'package:rooster_app/Controllers/transfer_controller.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Widgets/page_title.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';

// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;


class PrintReplenish extends StatefulWidget {
  const PrintReplenish(
      {super.key,
        required this.replenishNumber,
        required this.ref,
        required this.destWarehouse,
        required this.rowsInListViewInReplenish,
        required this.receivedDate,
        required this.creationDate,
        required this.currency,
        required this.status});
  final String replenishNumber;
  final String ref;
  final String receivedDate;
  final String creationDate;

  final String currency;
  final String destWarehouse;
  final String status;
  final Map rowsInListViewInReplenish;

  @override
  State<PrintReplenish> createState() => _PrintReplenishState();
}

class _PrintReplenishState extends State<PrintReplenish> {
  bool isHomeHovered = false;
  final TransferController transferController=Get.find();
  final HomeController homeController=Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if(transferController.isSubmitAndPreviewClicked){
                          // Navigator.pushReplacement(context,
                          //     MaterialPageRoute(
                          //         builder: (BuildContext context) {
                          //           return const HomePage();
                          //         }));
                          transferController.getAllTransactionsFromBack();
                          Get.back();
                          homeController.selectedTab.value = 'transfers';
                        }else{Get.back();}
                        // Navigator.pushReplacement(context, MaterialPageRoute(
                        //     builder: (BuildContext context) {
                        //       return const CashTrayOptions();
                        //     }));
                      },
                      child: Icon(Icons.arrow_back,
                          size: 22,
                          // color: Colors.grey,
                          color: Primary.primary),
                    ),
                    gapW10,
                    const PageTitle(text: 'Inter-Warehouse Replenish'),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    onHover: (val) {
                      setState(() {
                        isHomeHovered = val;
                      });
                    },
                    child: Icon(
                      Icons.home,
                      size: 30,
                      color:
                      isHomeHovered ? Primary.primary : Colors.grey,
                    ),
                    onTap: () {
                      Get.back();
                      homeController.selectedTab.value = 'transfers';
                      // Navigator.pushReplacement(context,
                      //     MaterialPageRoute(
                      //         builder: (BuildContext context) {
                      //           return const HomePage();
                      //         }));
                      // productController.resetAll();
                      // paymentController.resetAll();
                      // // productController.resetAll();
                      // // paymentController.resetAll();
                      // Navigator.pushReplacement(context,
                      //     MaterialPageRoute(
                      //         builder: (BuildContext context) {
                      //           return const HomePage();
                      //         }));
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            SizedBox(
              width:homeController.isMobile.value?Sizes.deviceWidth: Sizes.deviceWidth * 0.8,
              height: Sizes.deviceHeight * 0.85,
              child: PdfPreview(
                build: (format) => _generatePdf(format, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, BuildContext context) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    double width = MediaQuery.of(context).size.width;
    // var gapW20 = pw.SizedBox(width: 20);
    var gapH4 = pw.SizedBox(height: 4);
    var gapH10 = pw.SizedBox(height: 10);
    tableTitle({required String text, required double width}) {
      return pw.SizedBox(
          width: width,
          child: pw.Text(
            text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
                color: PdfColors.black,
                fontSize:homeController.isMobile.value?13: 9,
                fontWeight: pw.FontWeight.bold),
          ));
    }

    reusableTitle({required String text}) {
      return pw.Text(
        text,
        style: pw.TextStyle(
            color: PdfColors.black,
            fontSize:homeController.isMobile.value?20: 14,
            fontWeight: pw.FontWeight.bold),
      );
    }

    reusableShowInfoCard({required double width, required String text}) {
      return pw.Container(
        width: width,
        padding: const pw.EdgeInsets.symmetric(horizontal: 2),
        child: pw.Center(
            child: pw.Text(text, style:   pw.TextStyle(fontSize:homeController.isMobile.value?13: 9))),
      );
    }

    reusableItemRowInTransferIn(
        {required Map transferredItemInfo, required int index}) {
      return pw.Container(
        // margin: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            reusableShowInfoCard(
                text: transferredItemInfo['itemCode'] ?? '',
                width:homeController.isMobile.value? width * 0.15: width * 0.05),
            reusableShowInfoCard(
                text: transferredItemInfo['mainDescription'] ?? '',
                width:homeController.isMobile.value? width * 0.2: width * 0.05),
            reusableShowInfoCard(
                text: '${transferredItemInfo['qtyOnHandPackagesInSource'] ?? ''}',
                width:homeController.isMobile.value? width * 0.2: width * 0.04),
            reusableShowInfoCard(
                text: '${transferredItemInfo['replenishedQty'] ?? ''}',
                width:homeController.isMobile.value? width * 0.16: width * 0.04),
            reusableShowInfoCard(
                text:
                '${transferredItemInfo['replenishedQtyPackage'] ?? ''}',
                width: homeController.isMobile.value? width * 0.1:width * 0.04),
            reusableShowInfoCard(
                text:
                '${transferredItemInfo['cost'] ?? ''}',
                width:homeController.isMobile.value? width * 0.1: width * 0.04),
            reusableShowInfoCard(
                text:
                '${transferredItemInfo['note'] ?? ''}',
                width:homeController.isMobile.value? width * 0.1: width * 0.04),
          ],
        ),
      );
    }
    reusableText(String text){
      return  pw.Text(text, style:   pw.TextStyle(fontSize:homeController.isMobile.value? 13: 9,));
    }
    pdf.addPage(pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        build: (context) {
          return [
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                reusableTitle(
                    text: 'Inter-Warehouse Replenish '
                        '${widget.replenishNumber}'
                        '${widget.ref!=''?'/${widget.ref}':''}'),
                gapH10,
                reusableText('${'status'.tr}: ${widget.status}'),
                gapH4,
                reusableText('${'date'.tr}: ${widget.creationDate}'),
                gapH4,
                reusableText('${'currency'.tr}: ${widget.currency}'),
                gapH4,
                reusableText('${'dest_whse'.tr}: ${widget.destWarehouse}'),
                gapH10,
                pw.Divider(
                  color: PdfColors.black,
                  // endIndent: 250
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    tableTitle(
                      text: 'item'.tr,
                      width:homeController.isMobile.value? width * 0.15: width * 0.05,
                    ),
                    tableTitle(
                      text: 'description'.tr,
                      width:homeController.isMobile.value? width * 0.2: width * 0.05,
                    ),
                    tableTitle(
                      text: 'qty_available_at_wrhs'.tr,
                      width:homeController.isMobile.value? width * 0.2: width * 0.04,
                    ),
                    tableTitle(
                      text: 'replenish_qty'.tr,
                      width:homeController.isMobile.value? width * 0.16: width * 0.04,
                    ),
                    tableTitle(
                      text: 'pack'.tr,
                      width:homeController.isMobile.value? width * 0.1: width * 0.04,
                    ),
                    tableTitle(
                      text: 'unit_cost'.tr,
                      width:homeController.isMobile.value? width * 0.1: width * 0.04,
                    ),
                    tableTitle(
                      text: 'note'.tr,
                      width:homeController.isMobile.value? width * 0.1: width * 0.04,
                    ),
                  ],
                ),
                gapH4,
                pw.Divider(
                  color: PdfColors.black,
                  // endIndent: 250
                ),
                pw.ListView.builder(
                  padding: const pw.EdgeInsets.symmetric(vertical: 10),
                  itemCount: widget.rowsInListViewInReplenish
                      .length, //products is data from back res
                  itemBuilder: (context, index) {
                    var keys =
                    widget.rowsInListViewInReplenish.keys.toList();
                    return reusableItemRowInTransferIn(
                    transferredItemInfo: widget.rowsInListViewInReplenish[keys[index]],
                    index: index,
                  );
                  },
                ),
              ],
            ),
          ];
        }));

    return pdf.save();
  }
}
