import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import '../../../Controllers/cash_trays_controller.dart';
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../Widgets/loading.dart';
import '../../../Widgets/page_title.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../const/functions.dart';

class CashTraysReport extends StatefulWidget {
  const CashTraysReport({super.key});

  @override
  State<CashTraysReport> createState() => _CashTraysReportState();
}

class _CashTraysReportState extends State<CashTraysReport> {
  final CashTraysController cashTrayController = Get.find();
  String searchValue = '';
  Timer? searchOnStoppedTyping;
  bool isHomeHovered = false;
  final HomeController homeController = Get.find();
  ExchangeRatesController exchangeRatesController = Get.find();

  String posCurrency = '';
  String primaryCurrency = '';
  String posLatestRate = '';
  String primaryLatestRate = '';
  String finallyRate = '';
  getCurrencies() async {
    var pos = await getCompanyPosCurrencyFromPref();
    var prim = await getCompanyPrimaryCurrencyFromPref();
    setState(() {
      primaryCurrency = prim;
      if (pos.isNotEmpty) {
        posCurrency = pos;
      } else {
        posCurrency = primaryCurrency;
      }

      if (posCurrency == primaryCurrency) {
        finallyRate = '1';
      } else {
        var posResult = exchangeRatesController.exchangeRatesList.firstWhere(
          (item) => item["currency"] == posCurrency,
          orElse: () => null,
        );
        posLatestRate =
            posResult != null ? '${posResult["exchange_rate"]}' : '1';

        var primResult = exchangeRatesController.exchangeRatesList.firstWhere(
          (item) => item["currency"] == primaryCurrency,
          orElse: () => null,
        );
        primaryLatestRate =
            primResult != null ? '${primResult["exchange_rate"]}' : '1';

        finallyRate = calculateRateCur1ToCur2(
          double.parse(primaryLatestRate),
          double.parse(posLatestRate.isEmpty ? '1' : posLatestRate),
        );
      }
    });
  }

  @override
  void initState() {
    print('{cashTrayController.report ${cashTrayController.report}');
    getCurrencies();
    cashTrayController.getCashTraysFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<CashTraysController>(
        builder: (cont) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            Get.back();
                            homeController.selectedTab.value =
                                'cash_tray_report';
                          },
                          child: Icon(
                            Icons.arrow_back,
                            size: 22,
                            // color: Colors.grey,
                            color: Primary.primary,
                          ),
                        ),
                        gapW10,
                        PageTitle(text: 'cash_trays_report'.tr),
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
                          color: isHomeHovered ? Primary.primary : Colors.grey,
                        ),
                        onTap: () {
                          Get.back();
                          homeController.selectedTab.value = 'cash_tray_report';
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                cont.isCashTraysFetched
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Sizes.deviceWidth * 0.35,
                          height: Sizes.deviceHeight * 0.85,
                          child: PdfPreview(
                            build:
                                (format) =>
                                    _generatePdf(format, 'title', context),
                          ),
                        ),
                      ],
                    )
                    : loading(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Uint8List> _generatePdf(
    PdfPageFormat format,
    String title,
    BuildContext context,
  ) async {
    // var endDivider=MediaQuery.of(context).size.width * 0.5;
    // var descriptionWidth=MediaQuery.of(context).size.width * 0.25;
    // var indent= MediaQuery.of(context).size.width * 0.15;
    final font = await rootBundle.load('assets/fonts/Tajawal-Medium.ttf');
    final arabicFont = pw.Font.ttf(font);

    double width = MediaQuery.of(context).size.width;
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    var gapH40 = pw.SizedBox(height: 40);
    var gapH4 = pw.SizedBox(height: 4);
    var gapH15 = pw.SizedBox(height: 15);
    // var gapH16 = pw.SizedBox(height: 16);
    reusableTitle({required String text}) {
      return pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.black,
          fontSize: 26,
          fontWeight: pw.FontWeight.bold,
        ),
      );
    }

    reusableRowInReport({
      required String keyText,
      required String value,
      bool isBold = false,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(0, 5.0, 20.0, 5.0),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.SizedBox(
              width: width * 0.25,
              child: pw.Text(
                keyText,
                style:
                    isBold
                        ? pw.TextStyle(
                          fontSize: 23,
                          fontWeight: pw.FontWeight.bold,
                        )
                        : const pw.TextStyle(fontSize: 23),
              ),
            ),
            pw.Text(
              value,
              style:
                  isBold
                      ? pw.TextStyle(
                        fontSize: 23,
                        fontWeight: pw.FontWeight.bold,
                      )
                      : const pw.TextStyle(fontSize: 23),
            ),
          ],
        ),
      );
    }

    reusableCashingMethodRowInReport({
      required String keyText,
      required String posValue,
      required String primaryValue,
      bool isBold = false,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(0, 5.0, 20.0, 5.0),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.SizedBox(
              width: width * 0.15,
              child: pw.Text(keyText, style: const pw.TextStyle(fontSize: 23)),
            ),
            pw.SizedBox(
              width: width * 0.1,
              child: pw.Text(
                posValue,
                style:
                    isBold
                        ? pw.TextStyle(
                          fontSize: 23,
                          fontWeight: pw.FontWeight.bold,
                        )
                        : const pw.TextStyle(fontSize: 23),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.SizedBox(
              width: width * 0.1,
              child: pw.Text(
                primaryValue,
                style:
                    isBold
                        ? pw.TextStyle(
                          fontSize: 23,
                          fontWeight: pw.FontWeight.bold,
                        )
                        : const pw.TextStyle(fontSize: 23),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    reusableItemRowInReport({
      required String keyText,
      required String firstValue,
      required String secondValue,
      bool isBold = false,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(0, 5.0, 20.0, 5.0),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.SizedBox(
              width: width * 0.15,
              child: pw.Text(
                keyText,
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(fontSize: 23, font: arabicFont),
              ),
            ),
            pw.SizedBox(
              width: width * 0.1,
              child: pw.Text(
                firstValue,
                style:
                    isBold
                        ? pw.TextStyle(
                          fontSize: 23,
                          fontWeight: pw.FontWeight.bold,
                        )
                        : pw.TextStyle(fontSize: 23, font: arabicFont),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.SizedBox(
              width: width * 0.1,
              child: pw.Text(
                secondValue,
                style:
                    isBold
                        ? pw.TextStyle(
                          fontSize: 23,
                          fontWeight: pw.FontWeight.bold,
                        )
                        : pw.TextStyle(fontSize: 23, font: arabicFont),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        build: (context) {
          return [
            gapH40,
            reusableTitle(text: homeController.companyName),
            gapH4,
            homeController.companyAddress.isEmpty
                ? pw.SizedBox()
                : pw.Column(
                  children: [
                    pw.Text(
                      homeController.companyAddress,
                      style: const pw.TextStyle(fontSize: 23),
                    ),
                    gapH4,
                  ],
                ),
            pw.Divider(
              height: 4,
              color: PdfColors.black,
              // endIndent: 250
              thickness: 2,
            ),
            pw.Divider(
              height: 4,
              color: PdfColors.black,
              thickness: 2,
              // endIndent: 250
            ),
            gapH4,
            pw.Row(children: [reusableTitle(text: 'CASH TRAY CLOSING REPORT')]),
            gapH4,
            pw.Divider(height: 4, color: PdfColors.black, thickness: 2),
            pw.Divider(height: 4, color: PdfColors.black, thickness: 2),
            gapH15,
            pw.Text(
              'Pos: ${cashTrayController.report['pos']}       Session: ${cashTrayController.report['sessionNumber']}',
              style: const pw.TextStyle(fontSize: 23),
            ),
            gapH15,
            pw.Text(
              'CT: ${cashTrayController.report['trayNumber']}       User: ${cashTrayController.report['user']}',
              style: const pw.TextStyle(fontSize: 23),
            ),
            gapH15,
            pw.Text(
              '    Session Started on:    ${cashTrayController.report['sessionStartedOn']}',
              style: const pw.TextStyle(fontSize: 23),
            ),
            gapH15,
            pw.Text(
              '    Session  Ended on:    ${cashTrayController.report['sessionEndedOn']??''}',
              style: const pw.TextStyle(fontSize: 23),
            ),
            gapH15,
            pw.Text(
              cashTrayController.report['ordersString'],
              style: const pw.TextStyle(fontSize: 23),
            ),
            gapH40,
            pw.Row(
              children: [
                pw.SizedBox(
                  width: width * 0.25,
                  child: reusableTitle(text: 'Description'),
                ),
                reusableTitle(text: 'Amount'),
              ],
            ),
            gapH4,
            pw.Divider(color: PdfColors.black),
            gapH4,
            primaryCurrency == posCurrency
                ? pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    reusableRowInReport(
                      keyText: '${'revenues_sales'.tr} ($primaryCurrency)',
                      value: numberWithComma(
                        '${cashTrayController.report['revenuesSales']}',
                      ),
                    ),
                    reusableRowInReport(
                      keyText: '${'paid_ins'.tr} ($primaryCurrency)',
                      value: numberWithComma(
                        '${cashTrayController.report['primaryCurrencyPaidIn']}',
                      ),
                    ),

                    reusableRowInReport(
                      keyText: '${'paid_outs'.tr} ($primaryCurrency)',
                      value: numberWithComma(
                        '${cashTrayController.report['primaryCurrencyPaidOut']}',
                      ),
                    ),

                    pw.Divider(
                      height: 4,
                      color: PdfColors.black,
                      // endIndent: 250
                      thickness: 2,
                    ),
                    pw.Divider(
                      height: 4,
                      color: PdfColors.black,
                      thickness: 2,
                      // endIndent: 250
                    ),
                    gapH4,
                    pw.Divider(
                      height: 4,
                      color: PdfColors.black,
                      // endIndent: 250
                      thickness: 2,
                    ),
                    pw.Divider(
                      height: 4,
                      color: PdfColors.black,
                      thickness: 2,
                      // endIndent: 250
                    ),
                    gapH4,
                    pw.Row(
                      children: [
                        reusableTitle(text: 'Cashing Detailed Report'),
                      ],
                    ),
                    gapH4,
                    pw.Divider(height: 4, color: PdfColors.black, thickness: 2),
                    pw.Divider(
                      height: 4,
                      // endIndent: endDivider,
                      color: PdfColors.black,
                      thickness: 2,
                    ),
                    reusableRowInReport(keyText: '', value: primaryCurrency),
                    pw.Divider(
                      height: 4,
                      // endIndent: endDivider,
                      color: PdfColors.black,
                      thickness: 2,
                    ),
                    pw.ListView.builder(
                      itemCount:
                          cashTrayController
                              .report['cashingMethodsTotals']
                              .length ??
                          0,
                      itemBuilder:
                          (context, index) => reusableRowInReport(
                            keyText:
                                '${cashTrayController.report['cashingMethodsTotals'][index]['title']}',
                            value: numberWithComma(
                              '${cashTrayController.report['cashingMethodsTotals'][index]['primaryCurrencyValue']}',
                            ),
                          ),
                    ),
                    // reusableRowInReport(
                    //   keyText: 'On Account'.tr,
                    //   value:
                    //   numberWithComma('${cashTrayController.report['onAccountPrimaryCurrencyTotal'] ?? '0'}'),
                    // ),
                    pw.Divider(
                      height: 4,
                      // endIndent: endDivider,
                      color: PdfColors.black,
                      thickness: 2,
                    ),
                    reusableRowInReport(
                      keyText: 'total'.tr,
                      value:
                          '${cashTrayController.report['allMethodsPrimaryTotal']}',
                      isBold: true,
                    ),
                  ],
                )
                : pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    reusableRowInReport(
                      keyText: '${'revenues_sales'.tr} ($primaryCurrency)',
                      value: numberWithComma(
                        '${cashTrayController.report['revenuesSales']}',
                      ),
                    ),
                    reusableRowInReport(
                      keyText: '${'equivalent_in'.tr} ($posCurrency)',
                      value: numberWithComma(
                        '${cashTrayController.report['posCurrencyEquivalent']}',
                      ),
                    ),
                    reusableRowInReport(
                      keyText: 'rate'.tr,
                      value: numberWithComma(finallyRate),
                    ),
                    reusableRowInReport(
                      keyText: '${'paid_ins'.tr} ($primaryCurrency)',
                      value: numberWithComma(
                        '${cashTrayController.report['primaryCurrencyPaidIn']}',
                      ),
                    ),
                    reusableRowInReport(
                      keyText: '${'paid_ins'.tr} ($posCurrency)',
                      value: numberWithComma(
                        '${cashTrayController.report['posCurrencyPaidIn']}',
                      ),
                    ),
                    reusableRowInReport(
                      keyText: '${'paid_outs'.tr} ($primaryCurrency)',
                      value: numberWithComma(
                        '${cashTrayController.report['primaryCurrencyPaidOut']}',
                      ),
                    ),
                    reusableRowInReport(
                      keyText: '${'paid_outs'.tr} ($posCurrency)',
                      value: numberWithComma(
                        '${cashTrayController.report['posCurrencyPaidOut']}',
                      ),
                    ),
                    pw.Divider(
                      height: 4,
                      color: PdfColors.black,
                      // endIndent: 250
                      thickness: 2,
                    ),
                    pw.Divider(
                      height: 4,
                      color: PdfColors.black,
                      thickness: 2,
                      // endIndent: 250
                    ),
                    gapH4,
                    pw.Divider(
                      height: 4,
                      color: PdfColors.black,
                      // endIndent: 250
                      thickness: 2,
                    ),
                    pw.Divider(
                      height: 4,
                      color: PdfColors.black,
                      thickness: 2,
                      // endIndent: 250
                    ),
                    gapH4,
                    pw.Row(
                      children: [
                        reusableTitle(text: 'Cashing Detailed Report'),
                      ],
                    ),
                    gapH4,
                    pw.Divider(height: 4, color: PdfColors.black, thickness: 2),
                    pw.Divider(
                      height: 4,
                      // endIndent: endDivider,
                      color: PdfColors.black,
                      thickness: 2,
                    ),
                    reusableCashingMethodRowInReport(
                      keyText: '',
                      posValue: posCurrency,
                      primaryValue: primaryCurrency,
                    ),
                    pw.Divider(
                      height: 4,
                      // endIndent: endDivider,
                      color: PdfColors.black,
                      thickness: 2,
                    ),
                    pw.ListView.builder(
                      itemCount:
                          cashTrayController
                              .report['cashingMethodsTotals']
                              .length ??
                          0,
                      itemBuilder:
                          (context, index) => reusableCashingMethodRowInReport(
                            keyText:
                                '${cashTrayController.report['cashingMethodsTotals'][index]['title']}',
                            posValue: numberWithComma(
                              '${cashTrayController.report['cashingMethodsTotals'][index]['posCurrencyValue']}',
                            ),
                            primaryValue: numberWithComma(
                              '${cashTrayController.report['cashingMethodsTotals'][index]['primaryCurrencyValue']}',
                            ),
                          ),
                    ),
                    // reusableCashingMethodRowInReport(
                    //   keyText:
                    //       'On Account'.tr,
                    //   primaryValue:
                    //   numberWithComma('${cashTrayController.report['onAccountPrimaryCurrencyTotal'] ?? '0'}'),
                    //   posValue:
                    //   numberWithComma('${cashTrayController.report['onAccountPosCurrencyTotal'] ?? '0'}'),
                    // ),
                    reusableCashingMethodRowInReport(
                      isBold: true,
                      keyText: '${'total'.tr} ($primaryCurrency)',
                      primaryValue: numberWithComma(
                        '${cashTrayController.report['allMethodsPrimaryTotal'] ?? '0'}',
                      ),
                      posValue: numberWithComma(
                        '${cashTrayController.report['allMethodsPosTotal'] ?? '0'}',
                      ),
                    ),
                  ],
                ),
            gapH40,
            reusableRowInReport(
              keyText: 'net_cash_due'.tr,
              value: numberWithComma(
                '${cashTrayController.report['primaryCurrencyNetCashDue']}',
              ),
            ),
            reusableRowInReport(
              keyText: 'begin_cash_amount'.tr,
              value: numberWithComma(
                '${cashTrayController.report['primaryCurrencyBeginCashAmount']}',
              ),
            ),
            reusableRowInReport(
              keyText: 'gross_cash_due'.tr,
              value: numberWithComma(
                '${cashTrayController.report['primaryCurrencyGrossCashDue']}',
              ),
            ),
            reusableRowInReport(
              keyText: 'endCashAmnt'.tr,
              value: numberWithComma(
                '${cashTrayController.report['primaryCurrencyEndCashAmnt']}',
              ),
            ),
            gapH40,
            reusableRowInReport(
              keyText:
                  cashTrayController.report['primaryCurrencyShort'] != 0
                      ? 'short'.tr
                      : cashTrayController.report['primaryCurrencyOver'] != 0
                      ? 'over'.tr
                      : 'short'.tr,
              value:
                  cashTrayController.report['primaryCurrencyShort'] != 0
                      ? numberWithComma(
                        '${cashTrayController.report['primaryCurrencyShort']}',
                      )
                      : cashTrayController.report['primaryCurrencyOver'] != 0
                      ? numberWithComma(
                        '${cashTrayController.report['primaryCurrencyOver']}',
                      )
                      : "0.00",
            ),
            gapH40,
            pw.Divider(
              height: 4,
              color: PdfColors.black,
              // endIndent: 250
              thickness: 2,
            ),
            pw.Divider(
              height: 4,
              color: PdfColors.black,
              thickness: 2,
              // endIndent: 250
            ),
            gapH4,
            pw.Row(children: [reusableTitle(text: 'Sales Report')]),
            gapH4,
            pw.Divider(height: 4, color: PdfColors.black, thickness: 2),
            pw.Divider(
              height: 4,
              // endIndent: endDivider,
              color: PdfColors.black,
              thickness: 2,
            ),

            reusableItemRowInReport(
              keyText: 'Item',
              firstValue: 'Qty',
              secondValue: 'Total',
            ),
            pw.Divider(
              height: 4,
              // endIndent: endDivider,
              color: PdfColors.black,
              thickness: 2,
            ),
            pw.ListView.builder(
              itemCount: cashTrayController.report['salesReport'].length ?? 0,
              itemBuilder:
                  (context, index) => reusableItemRowInReport(
                    keyText:
                        '${cashTrayController.report['salesReport'][index]['item_name']}',
                    firstValue: numberWithComma(
                      '${cashTrayController.report['salesReport'][index]['qty']}',
                    ),
                    secondValue: numberWithComma(
                      '${cashTrayController.report['salesReport'][index]['total']}',
                    ),
                  ),
            ),
            pw.Divider(
              height: 4,
              // endIndent: endDivider,
              color: PdfColors.black,
              thickness: 2,
            ),
            reusableItemRowInReport(
              keyText: '',
              firstValue: '${cashTrayController.report['salesReportTotalQty']}',
              secondValue: double.parse(
                '${cashTrayController.report['salesReportTotalOfTotals']}',
              ).toStringAsFixed(2),
              isBold: true,
            ),
            gapH40,
            pw.Divider(
              height: 4,
              color: PdfColors.black,
              // endIndent: 250
              thickness: 2,
            ),
            pw.Divider(
              height: 4,
              color: PdfColors.black,
              thickness: 2,
              // endIndent: 250
            ),
            gapH4,
            pw.Row(
              children: [
                pw.Text(
                  'Report printed by ${cashTrayController.report['user']}',
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontStyle: pw.FontStyle.italic,
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            gapH40,
          ];
          // );
        },
      ),
    );
    return pdf.save();
  }
}
