import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:rooster_app/Controllers/combo_controller.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/Widgets/page_title.dart';
import 'package:rooster_app/const/colors.dart';
import 'package:rooster_app/const/functions.dart';
import 'package:rooster_app/const/sizes.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class PrintCombo extends StatefulWidget {
  const PrintCombo({
    super.key,
    required this.creationDate,
    required this.itemsInfoPrint,
    required this.comboName,
    required this.comboDescription,
    required this.comboPrice,
    required this.currencyName,
    required this.currencySymbol,
    required this.comboCurrencyLatestRate,
    required this.totalAllItems,
  });
  final String comboName;
  final String comboDescription;
  final String comboPrice;
  final String currencyName;
  final String currencySymbol;
  final String creationDate;
  final List itemsInfoPrint;
  final String totalAllItems;
  final String comboCurrencyLatestRate;
  @override
  State<PrintCombo> createState() => _PrintComboState();
}

class _PrintComboState extends State<PrintCombo> {
  bool isHomeHovered = false;
  final ComboController comboController = Get.find();
  HomeController homeController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();

  String fullCompanyName = '';
  String companyEmail = '';
  String companyPhoneNumber = '';
  String companyTrn = '';
  String companyMobileNumber = '';
  String companyLogo = '';
  String companyBankInfo = '';
  String companyAddress = '';
  String companyPhoneCode = '';
  String companyMobileCode = '';
  String companyLocalPayments = '';
  String primaryCurrency = '';
  String primaryCurrencyId = '';
  String primaryCurrencySymbol = '';
  String primaryLatestRate = '';
  String finallyRate = '';
  Future<void> headerRetrieve() async {
    fullCompanyName = await getFullCompanyNameFromPref();
    fullCompanyName =
        fullCompanyName == '' ? 'fullCompanyName' : fullCompanyName;
    companyEmail = await getCompanyEmailFromPref();
    companyEmail = companyEmail == '' ? 'companyEmail' : companyEmail;
    companyPhoneNumber = await getCompanyPhoneNumberFromPref();
    companyPhoneNumber =
        companyPhoneNumber == '' ? 'companyPhoneNumber' : companyPhoneNumber;
    companyTrn = await getCompanyTrnFromPref();
    companyTrn = companyTrn == '' ? 'companyTrn' : companyTrn;
    companyMobileNumber = await getCompanyMobileNumberFromPref();
    companyMobileNumber =
        companyMobileNumber == '' ? 'companyMobileNumber' : companyMobileNumber;
    companyLogo = await getCompanyLogoFromPref();

    companyBankInfo = await getCompanyBankInfoFromPref();
    companyBankInfo =
        companyBankInfo == '' ? 'companyBankInfo' : companyBankInfo;
    companyAddress = await getCompanyAddressFromPref();
    companyAddress = companyAddress == '' ? 'companyAddress' : companyAddress;
    companyPhoneCode = await getCompanyPhoneCodeFromPref();
    companyPhoneCode =
        companyPhoneCode == '' ? 'companyPhoneCode' : companyPhoneCode;
    companyMobileCode = await getCompanyMobileCodeFromPref();
    companyMobileCode =
        companyMobileCode == '' ? 'companyMobileCode' : companyMobileCode;
    companyLocalPayments = await getCompanyLocalPaymentsFromPref();
    companyLocalPayments =
        companyLocalPayments == ''
            ? 'companyLocalPayments'
            : companyLocalPayments;
    primaryCurrency = await getCompanyPrimaryCurrencyFromPref();
    primaryCurrency =
        primaryCurrency == '' ? 'primaryCurrency' : primaryCurrency;
    primaryCurrencyId = await getCompanyPrimaryCurrencyIdFromPref();
    primaryCurrencyId =
        primaryCurrencyId == '' ? primaryCurrencyId : primaryCurrencyId;
    primaryCurrencySymbol = await getCompanyPrimaryCurrencySymbolFromPref();
    primaryCurrencySymbol =
        primaryCurrencySymbol == ''
            ? 'primaryCurrencySymbol'
            : primaryCurrencySymbol;
    var result = exchangeRatesController.exchangeRatesList.firstWhere(
      (item) => item["currency"] == primaryCurrency,
      orElse: () => null,
    );
    primaryLatestRate = result != null ? '${result["exchange_rate"]}' : '1';
    finallyRate = calculateRateCur1ToCur2(
      double.parse(primaryLatestRate),
      double.parse(
        widget.comboCurrencyLatestRate.isEmpty
            ? '1'
            : widget.comboCurrencyLatestRate,
      ),
    );
  }

  @override
  void initState() {
    headerRetrieve();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.02,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if (comboController.isSubmitAndPreviewClicked) {
                          comboController.getAllCombosFromBackWithSeach('');
                          Get.back();
                          homeController.selectedTab.value = 'combo_summary';
                        } else {
                          Get.back();
                        }
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: 22,

                        color: Primary.primary,
                      ),
                    ),
                    gapW10,
                    const PageTitle(text: 'Combos'),
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
                      homeController.selectedTab.value = 'combo_summary';
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            SizedBox(
              width: Sizes.deviceWidth * 0.8,
              height: Sizes.deviceHeight * 0.85,
              child:
              // Optional: You can customize the preview appearance here
              PdfPreview(build: (format) => _generatePdf(format, context)),
            ),
          ],
        ),
      ),
    );
  } //end build

  Future<Uint8List> _generatePdf(
    PdfPageFormat format,
    BuildContext context,
  ) async {
    Map<String, pw.ImageProvider?> imageProviders = {};
    // for (var item in widget.itemsInfoPrint) {
    //   if (!item['item_image'].isEmpty) {
    //     final response = await http.get(item['item_image']);

    //     if (response.statusCode == 200) {
    //       print('Status code: ${response.statusCode}');
    //       print("status=200");

    //       final contentType = response.headers['content-type'];
    //       if (contentType != null && contentType.startsWith('image/')) {
    //         print('Response is an image. Content-Type: $contentType');
    //       } else {
    //         print('Response is not an image. Content-Type: $contentType');
    //       }
    //       imageProviders[item['item_image']] = pw.MemoryImage(
    //         response.bodyBytes,
    //       );
    //     } else {
    //       print("+++error connect++++");
    //       imageProviders[item['item_image']] =
    //           null; // Store null if image fails to load
    //     }
    //   }
    // }
    // final image = pw.MemoryImage(comboController.logoBytes);
    // print("pw.Image(image)");
    // print(imageProviders);

    // await preFetchImages(quotationController.itemList);
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    // ignore: use_build_context_synchronously
    double width = MediaQuery.of(context).size.width;
    var gapW20 = pw.SizedBox(width: 20);
    var gapW180 = pw.SizedBox(width: 180);
    var gapH4 = pw.SizedBox(height: 4);
    tableTitle({required String text, required double width}) {
      return pw.SizedBox(
        width: width,
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
    }

    reusableShowInfoCard({required double width, required String text}) {
      return pw.Container(
        width: width,
        padding: const pw.EdgeInsets.symmetric(horizontal: 2),
        child: pw.Center(
          child: pw.Text(text, style:  pw.TextStyle(fontSize: 7),),
        ),
      );
    }

    reusableItemRowInCombos({
      required Map comboItemInfo,
      required int index,
      required pw.ImageProvider? imageProvider,
    }) {
      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            pw.Column(
              children: [
                reusableShowInfoCard(
                  text:
                      comboItemInfo['item_brand'] != ''
                          ? comboItemInfo['item_brand']
                          : '---',
                  width: width * 0.05,
                ),
                gapH4,
                gapH4,
                if (imageProvider != null)
                  pw.Image(
                    imageProvider,
                    fit: pw.BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
              ],
            ),
            reusableShowInfoCard(
              text: '${comboItemInfo['item_name'] ?? ''}',
              width: width * 0.05,
            ),
            reusableShowInfoCard(
              text: '${comboItemInfo['item_description'] ?? ''}',
              width: width * 0.06,
            ),
            reusableShowInfoCard(
              text: '${comboItemInfo['item_quantity'] ?? ''}',
              width: width * 0.03,
            ),
            reusableShowInfoCard(
              text: numberWithComma(
                double.parse(
                  '${double.parse('${comboItemInfo['item_unit_price']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
                ).toStringAsFixed(2),
              ),
              width: width * 0.04,
            ),
          ],
        ),
      );
    }

    reusableText(String text) {
      return pw.Text(text, style:  pw.TextStyle(fontSize: 7,),);
    }

    buildDividersRow(double width) {
      return pw.Row(
        children: [
          pw.SizedBox(
            width: width * 0.1,
            child: pw.Divider(height: 5, color: PdfColors.black),
          ),
          pw.SizedBox(
            width: width * 0.1,
            child: pw.Divider(height: 5, color: PdfColors.black),
          ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        build: (context) {
          return [
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: width * 0.15,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: <pw.Widget>[
                                pw.Container(
                                  width: 180, // Set the desired width
                                  height: 70, // Set the desired height
                                  child: pw.Text(
                                    '${widget.comboName} Infornation',
                                  ),
                                  // pw.Image(image),

                                  // pw.Image(
                                  //   pw.MemoryImage(
                                  //     (quotationController.logoBytes).buffer.asUint8List(),
                                  //   ),
                                  //   fit:
                                  //       pw
                                  //           .BoxFit
                                  //           .contain, // Display the image at its original size
                                  // ),
                                  // alignment: pw.Alignment.topLeft, // Align the image to the top-left (optional, but recommended)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //2inrow
                      // pw.SizedBox(
                      //   width: width * 0.15,
                      //   child: pw.Row(
                      //     mainAxisAlignment: pw.MainAxisAlignment.start,
                      //     children: [
                      //       pw.Column(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //         children: [
                      //           gapH4,
                      //           gapH4,
                      //           pw.Text(
                      //             fullCompanyName,
                      //             style: pw.TextStyle(
                      //               fontSize: 7,
                      //               fontWeight: pw.FontWeight.bold,
                      //               color: PdfColors.black,
                      //             ),
                      //           ),
                      //           gapH4,
                      //           reusableText(companyAddress),
                      //         ],
                      //       ),
                      //       gapW20,
                      //     ],
                      //   ),
                      // ),
                      //3inrow
                      // pw.SizedBox(
                      //   width: width * 0.1,
                      //   child: pw.Row(
                      //     mainAxisAlignment: pw.MainAxisAlignment.start,

                      //     children: [
                      //       pw.Column(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //         children: [
                      //           gapH4,
                      //           // reusableText('T 234-814-159 6534'),
                      //           reusableText(
                      //             'T $companyPhoneCode $companyPhoneNumber $companyTrn',
                      //           ),
                      //           gapH4,

                      //           reusableText(
                      //             'T $companyMobileCode $companyMobileNumber',
                      //           ),
                      //           // gapH4,
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      //    2inrow
                      pw.SizedBox(
                        width: width * 0.15,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                gapH4,
                                gapH4,
                                pw.Text(
                                  fullCompanyName,
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,
                                reusableText(companyAddress),
                              ],
                            ),
                            gapW20,
                          ],
                        ),
                      ),
                      //   3inrow
                      gapW20,
                      pw.SizedBox(
                        width: width * 0.15,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,

                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                gapH4,
                                // reusableText('T 234-814-159 6534'),
                                reusableText(
                                  'T $companyPhoneCode $companyPhoneNumber $companyTrn',
                                ),
                                gapH4,

                                reusableText(
                                  'T $companyMobileCode $companyMobileNumber',
                                ),
                                // gapH4,
                              ],
                            ),
                          ],
                        ),
                      ),
                      gapW20,
                      pw.SizedBox(
                        width: width * 0.2,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,

                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                gapH4,
                                // reusableText('T 234-814-159 6534'),
                                reusableText('Email:'),
                                gapH4,

                                reusableText(companyEmail),
                                // gapH4,
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                //////////////////////////////////////////////////////////////
                // info combo with
                pw.Padding(
                  padding: pw.EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      //    2inrow
                      pw.SizedBox(
                        width: width * 0.15,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                gapH4,
                                gapH4,
                                pw.Text(
                                  '${'to'.tr}:',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,
                                pw.Text(
                                  '${'telephone'.tr}:',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ],
                            ),
                            gapW20,
                          ],
                        ),
                      ),
                      //   3inrow
                      gapW20,
                      pw.SizedBox(
                        width: width * 0.15,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,

                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                gapH4,
                                // reusableText('T 234-814-159 6534'),
                                pw.Text(
                                  '${'currency'.tr}:',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,
                                primaryCurrency != widget.currencyName
                                    ? pw.Text(
                                      '${'$primaryCurrency/${widget.currencyName} rate'.tr}:',
                                      style: pw.TextStyle(
                                        fontSize: 7,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.black,
                                      ),
                                    )
                                    : pw.SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      gapW20,
                      pw.SizedBox(
                        width: width * 0.2,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,

                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  '${'offer_no'.tr}:',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,

                                pw.Text(
                                  '${'date'.tr}:',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                //////////////////////////////////////////////////////////////

                //////////////////////////////////////////////////////////////
                // items combo table
                pw.Padding(
                  padding: pw.EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child:
                  // to
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          tableTitle(text: 'brand'.tr, width: width * 0.05),
                          tableTitle(text: 'item_'.tr, width: width * 0.05),
                          tableTitle(
                            text: 'description'.tr,
                            width: width * 0.06,
                          ),
                          tableTitle(text: 'qty'.tr, width: width * 0.03),
                          tableTitle(
                            text: 'unit_price'.tr,
                            width: width * 0.04,
                          ),
                        ],
                      ),

                      gapH4,
                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                      pw.ListView.builder(
                        padding: const pw.EdgeInsets.symmetric(vertical: 10),
                        itemCount: widget.itemsInfoPrint.length,
                        itemBuilder: (context, i) {
                          final item = widget.itemsInfoPrint[i];
                          return reusableItemRowInCombos(
                            comboItemInfo: item,
                            index: i,
                            imageProvider:
                                imageProviders[item['item_image']], // Pass the pre-fetched ImageProvider
                            // width: width,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                //////////////////////////////////////////////////////////////
                // total quotation
                // column row column
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(
                    horizontal: width * 0.01,
                    vertical: 25,
                  ),
                  width: width * 0.36,
                  height: 300,
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(9)),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                      pw.Row(
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.2,
                                child: reusableText('total_price'.tr),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.1,
                                child: reusableText(primaryCurrency),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.1,
                                child: pw.Text(
                                  // widget.totalAllItems,
                                  numberWithComma(
                                    double.parse(
                                      '${double.parse(widget.totalAllItems.replaceAll(',', '')) / double.parse(finallyRate)}',
                                    ).toStringAsFixed(2),
                                  ),
                                  // '${quotationController.totalAllItems}',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                      pw.Row(
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.2,
                                child: reusableText('dis_count'.tr),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                      // TOTAL PRICE AFTER  DISCOUNT
                      pw.Row(
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.2,
                                child: reusableText(
                                  'total_price_after_discount'.tr,
                                ),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.1,
                                child: reusableText(primaryCurrency),
                              ),
                            ],
                          ),
                        ],
                      ),

                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                      pw.Row(
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.2,
                                child: reusableText(
                                  'additional_special_discount'.tr,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),

                      // TOTAL PRICE AFTER SPECIAL DISCOUNT
                      if (primaryCurrency != widget.currencyName)
                        pw.Row(
                          children: [
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  width: width * 0.2,
                                  child: reusableText(
                                    'total_price_after_special_discount'.tr,
                                  ),
                                ),
                              ],
                            ),

                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  width: width * 0.1,
                                  child: reusableText(primaryCurrency),
                                ),
                              ],
                            ),
                            pw.Column(),
                          ],
                        ),
                      if (primaryCurrency != widget.currencyName)
                        pw.Divider(
                          height: 5,
                          color: PdfColors.black,
                          // endIndent: 250
                        ),
                      // TOTAL PRICE AFTER SPECIAL DISCOUNT
                      pw.Row(
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.2,
                                child: reusableText(
                                  'total_price_after_special_discount'.tr,
                                ),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.1,
                                child: pw.Text(
                                  widget.currencyName,
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                      //VAT
                      pw.Row(children: [
                  
                        
                        ],
                      ),

                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                      // FINAL PRICE INCL. VAT
                      pw.Row(
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.2,

                                child: pw.Text(
                                  'final_price_incl_vat'.tr,
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.1,
                                child: pw.Text(
                                  widget.currencyName,
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                    ],
                  ),
                ),

                //////////////////////////////////////////////////////////////

                // footer
                pw.Padding(
                  padding: pw.EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      //image logo
                      pw.Row(
                        children: [
                          pw.SizedBox(
                            width: width * 0.15,
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: <pw.Widget>[
                                    pw.Container(
                                      width: 180,
                                      height: 70,
                                      child: pw.Text("text"),

                                      // alignment: pw.Alignment.topLeft, // Align the image to the top-left (optional, but recommended)
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(
                            width: width * 0.15,
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    gapH4,
                                    reusableText(''),
                                    gapH4,
                                    reusableText(''),
                                  ],
                                ),
                                gapW20,
                              ],
                            ),
                          ),
                          pw.SizedBox(
                            width: width * 0.15,
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    gapH4,
                                    reusableText(''),
                                    gapH4,
                                    reusableText(''),
                                  ],
                                ),
                                gapW20,
                              ],
                            ),
                          ),
                        ],
                      ),

                      pw.Padding(
                        padding: pw.EdgeInsets.fromLTRB(0, 4, 0, 0),
                        child: pw.SizedBox(
                          // width: width * 0.15,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              // if( '${widget.termsAndConditions}' != '')
                              reusableText(fullCompanyName),

                              // if( '${widget.termsAndConditions}' != '')
                              reusableText('terms_and_conditions'.tr),
                            ],
                          ),
                        ),
                      ),

                      // if( '${widget.termsAndConditions}' != '')
                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),

                      // For local payments,
                      pw.Padding(
                        padding: pw.EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: pw.SizedBox(
                          // width: width * 0.15,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  gapH4,

                                  // reusableText('.For local payments,',),
                                  if (companyLocalPayments != '')
                                    reusableText(
                                      '.For local payments, $companyLocalPayments',
                                    ),

                                  gapH4,
                                  companyBankInfo != ''
                                      ? reusableText(' $companyBankInfo')
                                      : reusableText(''),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      //signature
                      pw.Padding(
                        padding: pw.EdgeInsets.fromLTRB(0, 200, 0, 0),
                        child: pw.Container(
                          alignment: pw.Alignment.centerRight,
                          margin: const pw.EdgeInsets.only(bottom: 0.5),
                          child: pw.Column(
                            children: [
                              pw.Divider(height: 5, color: PdfColors.black),
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.SizedBox(
                                    width: width * 0.25,
                                    child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.start,
                                      children: [
                                        pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            reusableText(
                                              '(${'the_client'.tr})',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  //date
                                  pw.SizedBox(
                                    width: width * 0.1,
                                    child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.start,
                                      children: [
                                        pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            reusableText(
                                              '(${'the_supplier'.tr})',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  buildDividersRow(1000),
                                  gapW180,
                                  buildDividersRow(950),
                                ],
                              ),

                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.SizedBox(
                                    width: width * 0.25,
                                    child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.start,
                                      children: [
                                        pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            // reusableText(widget.clientName),
                                            //gapH4,
                                            reusableText('${'signature'.tr}:'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  pw.SizedBox(
                                    width: width * 0.1,
                                    child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.start,
                                      children: [
                                        pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            reusableText(fullCompanyName),
                                            gapH4,
                                            reusableText('${'signature'.tr}:'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
