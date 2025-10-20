import 'package:rooster_app/Widgets/reusable_btn.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/const/urls.dart';
import '../../../const/colors.dart';
import '../../Controllers/exchange_rates_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/page_title.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../const/Sizes.dart';
import '../../const/functions.dart';
import '../../const/Delta/convert_from_delta_to_pw_widget.dart';

class PrintQuotationData extends StatefulWidget {
  const PrintQuotationData({
    super.key,
    required this.quotationNumber,
    required this.ref,
    required this.creationDate,
    required this.receivedUser,
    required this.senderUser,
    required this.status,
    required this.cancellationReason,
    required this.vat,
    required this.fromPage,
    required this.totalBeforeVat,
    required this.discountOnAllItem,
    required this.totalAllItems,
    required this.globalDiscount,
    required this.totalPriceAfterDiscount,
    required this.totalPriceAfterSpecialDiscount,
    required this.specialDisc,
    required this.specialDiscount,
    required this.specialDiscountAmount,
    required this.totalPriceAfterSpecialDiscountByQuotationCurrency,
    required this.vatByQuotationCurrency,
    required this.finalPriceByQuotationCurrency,
    required this.salesPerson,
    required this.quotationCurrency,
    required this.quotationCurrencySymbol,
    required this.quotationCurrencyLatestRate,
    required this.clientPhoneNumber,
    required this.clientMobileNumber,
    required this.clientName,
    required this.clientAddress,
    required this.termsAndConditionsNote,
    required this.itemsInfoPrint,
    this.isInQuotation = false,
    required this.isPrintedAsVatExempt,
    required this.isPrintedAs0,
    required this.isVatNoPrinted,
    required this.header,
    required this.termsAndConditions,
    required this.globalDiscountAmount,
  });

  final String quotationNumber;
  final String ref;
  final String creationDate;
  final String receivedUser;
  final String senderUser;
  final String status;
  final String cancellationReason;
  final String vat;
  final String fromPage;
  final String totalBeforeVat;
  final String discountOnAllItem;
  final String totalAllItems;
  final String globalDiscount;
  final String globalDiscountAmount;
  final String totalPriceAfterDiscount;
  final String totalPriceAfterSpecialDiscount;
  final String specialDisc;
  final String specialDiscount;
  final String specialDiscountAmount;
  final String totalPriceAfterSpecialDiscountByQuotationCurrency;
  final String vatByQuotationCurrency;
  final String finalPriceByQuotationCurrency;
  final String salesPerson;
  final String quotationCurrency;
  final String quotationCurrencySymbol;
  final String quotationCurrencyLatestRate;
  final String clientPhoneNumber;
  final String clientMobileNumber;
  final String clientName;
  final String clientAddress;
  final String termsAndConditionsNote;
  final String termsAndConditions;
  final bool isInQuotation;
  final List itemsInfoPrint;
  final bool isPrintedAsVatExempt;
  final bool isPrintedAs0;
  final bool isVatNoPrinted;
  final Map? header;

  @override
  State<PrintQuotationData> createState() => _PrintQuotationDataState();
}

class _PrintQuotationDataState extends State<PrintQuotationData> {
  bool isHomeHovered = false;
  final QuotationController quotationController = Get.find();
  HomeController homeController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();

  String fullCompanyName = '';
  String companyEmail = '';
  String companyPhoneNumber = '';
  String companyVat = '';
  String companyMobileNumber = '';
  String companyLogo = '';
  String companyTrn = '';
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

  Future<void> generatePdfFromImageUrl(String companyLogo) async {
    // 1. Download image
    String helper = '';
    if (companyLogo.isEmpty) {
      companyLogo = 'https://share.google/images/jVwJ4FCsP2pxEK8vV';
      helper = '$baseImage$companyLogo';
    } else {
      helper = '$baseImage$companyLogo';
    }
    final response = await http.get(Uri.parse(helper));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    } else {
      final Uint8List imageBytes = response.bodyBytes;
      quotationController.logoBytes = imageBytes;
    }
    // quotationController.setLogo(imageBytes);
  }

  Future<void> headerRetrieve() async {
    fullCompanyName = await getFullCompanyNameFromPref();
    if (widget.header != null && widget.header!.isNotEmpty) {
      fullCompanyName = widget.header!['full_company_name'] ?? '';
      companyEmail = widget.header!['email'] ?? '';
      companyPhoneNumber = widget.header!['phone_number'] ?? '';
      companyVat = widget.header!['vat'] ?? '0';
      companyMobileNumber = widget.header!['mobile_number'] ?? '';
      companyLogo = widget.header!['logo'] ?? '';
      companyTrn = widget.header!['trn'] ?? '';
      companyBankInfo = widget.header!['bank_info'] ?? '';
      companyAddress = widget.header!['address'] ?? '';
      companyPhoneCode = widget.header!['phone_code'] ?? '';
      companyMobileCode = widget.header!['mobile_code'] ?? '';
      companyLocalPayments = widget.header!['local_payments'] ?? '';
    } else {
      fullCompanyName = await getFullCompanyNameFromPref();
      companyEmail = await getCompanyEmailFromPref();
      companyPhoneNumber = await getCompanyPhoneNumberFromPref();
      companyVat = await getCompanyVatFromPref();
      companyMobileNumber = await getCompanyMobileNumberFromPref();
      companyLogo = await getCompanyLogoFromPref();
      companyTrn = await getCompanyTrnFromPref();
      companyBankInfo = await getCompanyBankInfoFromPref();
      companyAddress = await getCompanyAddressFromPref();
      companyPhoneCode = await getCompanyPhoneCodeFromPref();
      companyMobileCode = await getCompanyMobileCodeFromPref();
      companyLocalPayments = await getCompanyLocalPaymentsFromPref();
    }
    // if (companyLogo.isEmpty) {
    //   companyLogo = 'https://share.google/images/DwDJv41UrDDARwPui';
    // }

    generatePdfFromImageUrl(companyLogo);
    primaryCurrency = await getCompanyPrimaryCurrencyFromPref();
    primaryCurrencyId = await getCompanyPrimaryCurrencyIdFromPref();
    primaryCurrencySymbol = await getCompanyPrimaryCurrencySymbolFromPref();
    var result = exchangeRatesController.exchangeRatesList.firstWhere(
      (item) => item["currency"] == primaryCurrency,
      orElse: () => null,
    );
    primaryLatestRate = result != null ? '${result["exchange_rate"]}' : '1';
    finallyRate = calculateRateCur1ToCur2(
      double.parse(primaryLatestRate),
      double.parse(
        widget.quotationCurrencyLatestRate.isEmpty
            ? '1'
            : widget.quotationCurrencyLatestRate,
      ),
    );
  }

  // String itemImage = '';

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
                        if (quotationController.isSubmitAndPreviewClicked) {
                          quotationController
                              .getAllQuotationsWithoutPendingFromBack();
                          Get.back();
                          homeController.selectedTab.value = 'quotations';
                        } else {
                          Get.back();
                        }
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: 22,
                        // color: Colors.grey,
                        color: Primary.primary,
                      ),
                    ),
                    gapW10,
                    const PageTitle(text: 'Quotation'),
                    gapW20,
                    ReusableButtonWithColor(
                      width: 100,
                      height: 45,
                      btnText: 'Save as PDF',
                      onTapFunction: () {
                        _savePdf(context);
                      },
                    ),
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
                      homeController.selectedTab.value = 'quotation_summary';
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            SizedBox(
              width: Sizes.deviceWidth * 0.8,
              height: Sizes.deviceHeight * 0.80,
              child: PdfPreview(
                build: (format) => _generatePdf(format, context),
                pdfFileName: '${widget.clientName} [${widget.quotationNumber}]',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePdf(BuildContext context) async {
    final bytes = await _generatePdf(PdfPageFormat.a4, context);

    final blob = web.Blob([bytes.toJS] as JSArray<web.BlobPart>);
    final url = web.URL.createObjectURL(blob);
    final anchor =
        web.HTMLAnchorElement()
          ..href = url
          ..download = '${widget.clientName} [${widget.quotationNumber}].pdf'
          ..style.display = 'none'
          ..click();

    web.URL.revokeObjectURL(url);
  }

  Future<Uint8List> _generatePdf(
    PdfPageFormat format,
    BuildContext context,
  ) async {
    Map<String, pw.ImageProvider?> imageProviders = {};

    bool hasDiscount = widget.itemsInfoPrint.any(
      (item) => double.parse('${item['item_discount']}') != 0,
    );

    for (var item in widget.itemsInfoPrint) {
      if (item['line_type_id'] == '2') {
        if (item['item_image'] != null) {
          try {
            var helper = '';
            if ('${item['item_image']}'.startsWith('https://')) {
              helper = '${item['item_image']}';
            } else {
              helper = '$baseImage${item['item_image']}';
            }
            final response = await http.get(Uri.parse(helper));
            if (response.statusCode == 200) {
              imageProviders[item['item_image']] = pw.MemoryImage(
                response.bodyBytes,
              );
            } else {
              imageProviders[item['item_image']] =
                  null; // Store null if image fails to load
            }
          } catch (e) {
            imageProviders[item['item_image']] = null;
          }
        } else {
          imageProviders[item['item_image']] = null;
        }
      } else if (!item['isImageList']) {
        if (item['image'] != null) {
          try {
            var helper = '';
            if ('${item['image']}'.startsWith('https://')) {
              helper = '${item['image']}';
            } else {
              helper = '$baseImage${item['image']}';
            }
            final response = await http.get(Uri.parse(helper));
            if (response.statusCode == 200) {
              imageProviders[item['image']] = pw.MemoryImage(
                response.bodyBytes,
              );
            } else {
              imageProviders[item['image']] =
                  null; // Store null if image fails to load
            }
          } catch (e) {
            imageProviders[item['image']] = null;
          }
        } else {
          imageProviders[item['image']] = null;
        }
      }
      if (item['line_type_id'] == '3') {
        if (item['combo_image'] != null) {
          try {
            final response = await http.get(Uri.parse(item['combo_image']));
            if (response.statusCode == 200) {
              imageProviders[item['combo_image']] = pw.MemoryImage(
                response.bodyBytes,
              );
            } else {
              imageProviders[item['combo_image']] =
                  null; // Store null if image fails to load
            }
          } catch (e) {
            imageProviders[item['combo_image']] = null;
          }
        } else {
          imageProviders[item['combo_image']] = null;
        }
      }
    }
    // await preFetchImages(quotationController.itemList);
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    double width = MediaQuery.of(context).size.width;
    var gapW20 = pw.SizedBox(width: 20);
    var gapW16 = pw.SizedBox(width: 16);
    var gapW180 = pw.SizedBox(width: 180);
    var gapH4 = pw.SizedBox(height: 4);
    var gapH30 = pw.SizedBox(height: 30);
    var gapH5 = pw.SizedBox(height: 5);
    var gapH6 = pw.SizedBox(height: 6);
    final font = await rootBundle.load('assets/fonts/Tajawal-Medium.ttf');
    final arabicFont = pw.Font.ttf(font);
    final italicfont = await rootBundle.load('assets/fonts/Roboto-Italic.ttf');
    final italicRobotoFont = pw.Font.ttf(italicfont);
    tableTitle({required String text, required double width}) {
      return pw.SizedBox(
        width: width,
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: 9.sp,
            fontWeight: pw.FontWeight.normal,
            // decoration: pw.TextDecoration.underline,
          ),
        ),
      );
    }

    tableTitleForSequence({required String text, required double width}) {
      return pw.SizedBox(
        width: width,
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: 12,
            fontWeight: pw.FontWeight.normal,
            decoration: pw.TextDecoration.underline,
          ),
        ),
      );
    }

    reusableShowInfoCard({required double width, required String text}) {
      return pw.Container(
        width: width,
        padding: const pw.EdgeInsets.symmetric(horizontal: 2),
        child: pw.Center(
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 9.sp, font: arabicFont),
          ),
        ),
      );
    }

    reusableItemRowInQuotations({
      required Map quotationItemInfo,
      required int index,
      required pw.ImageProvider? imageProvider,
    }) {
      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                reusableShowInfoCard(
                  text:
                      quotationItemInfo['item_brand'] != ''
                          ? quotationItemInfo['item_brand']
                          : '---',
                  width: width * 0.05,
                ),

                reusableShowInfoCard(
                  text: '${quotationItemInfo['item_name'] ?? ''}',
                  width: width * 0.07,
                ),
                reusableShowInfoCard(
                  text: '${quotationItemInfo['item_description'] ?? ''}',
                  width: width * 0.07,
                ),
                reusableShowInfoCard(
                  text: '${quotationItemInfo['item_quantity'] ?? ''}',
                  width: width * 0.03,
                ),
                reusableShowInfoCard(
                  text:
                  // '${quotationItemInfo['item_unit_price'] ?? ''}',
                  numberWithComma(
                    double.parse(
                      '${double.parse('${quotationItemInfo['item_unit_price']}'.replaceAll(',', ''))}',
                      // '${double.parse('${quotationItemInfo['item_unit_price']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
                    ).toStringAsFixed(2),
                  ),
                  width: width * 0.04,
                ),
                hasDiscount
                    ? reusableShowInfoCard(
                      text: '${quotationItemInfo['item_discount'] ?? '0'}',
                      width: width * 0.03,
                    )
                    : pw.SizedBox.shrink(),
                reusableShowInfoCard(
                  text:
                  // '${quotationItemIn
                  // fo['item_total'] ?? ''}',
                  numberWithComma(
                    double.parse(
                      '${double.parse('${quotationItemInfo['item_total']}'.replaceAll(',', ''))}',
                      // '${double.parse('${quotationItemInfo['item_total']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
                    ).toStringAsFixed(2),
                  ),
                  width: width * 0.04,
                ),
              ],
            ),
            gapH4,
            gapH4,
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.SizedBox(width: 30),
                pw.Container(
                  width: 125,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.white,
                      width: 1.00,
                      style: pw.BorderStyle.solid,
                    ),
                  ),
                  child: pw.Center(
                    child: pw.Column(
                      children: [
                        gapH4,

                        if (imageProvider != null)
                          pw.Image(
                            imageProvider,
                            fit: pw.BoxFit.contain,
                            width: 120,
                            height: 100,
                          ),
                        gapH4,
                      ],
                    ),
                  ),
                ), // pw.Container(
              ],
            ),
          ],
        ),
      );
    }

    reusableRowInQuotations({
      required Map quotationItemInfo,
      required int index,
      required pw.ImageProvider? imageProvider,
    }) {
      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child:
            quotationItemInfo['line_type_id'] == '3'
                ? pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      children: [
                        reusableShowInfoCard(
                          text: quotationItemInfo['combo_brand'] ?? '---',
                          width: width * 0.05,
                        ),

                        reusableShowInfoCard(
                          text: '${quotationItemInfo['item_name'] ?? ''}',
                          width: width * 0.07,
                        ),
                        reusableShowInfoCard(
                          text:
                              '${quotationItemInfo['item_description'] ?? ''}',
                          width: width * 0.07,
                        ),
                        reusableShowInfoCard(
                          text: '${quotationItemInfo['item_quantity'] ?? ''}',
                          width: width * 0.03,
                        ),
                        reusableShowInfoCard(
                          text: numberWithComma(
                            double.parse(
                              '${double.parse('${quotationItemInfo['item_unit_price'] ?? '0'}'.replaceAll(',', ''))}',
                              // '${double.parse('${quotationItemInfo['item_unit_price']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
                            ).toStringAsFixed(2),
                          ),
                          width: width * 0.04,
                        ),
                        hasDiscount
                            ? reusableShowInfoCard(
                              text:
                                  '${quotationItemInfo['item_discount'] ?? '0'}',
                              width: width * 0.03,
                            )
                            : pw.SizedBox.shrink(),
                        reusableShowInfoCard(
                          text:
                          // '${quotationItemIn
                          // fo['item_total'] ?? ''}',
                          numberWithComma(
                            double.parse(
                              '${double.parse('${quotationItemInfo['item_total'] ?? '0'}'.replaceAll(',', ''))}',
                              // '${double.parse('${quotationItemInfo['item_total']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
                            ).toStringAsFixed(2),
                          ),
                          width: width * 0.04,
                        ),
                      ],
                    ),
                    gapH4,
                    gapH4,
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.SizedBox(width: 30),

                        pw.Container(
                          width: 125,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              color: PdfColors.white,
                              width: 1.00,
                              style: pw.BorderStyle.solid,
                            ),
                          ),
                          child: pw.Center(
                            child: pw.Column(
                              children: [
                                gapH4,

                                if (imageProvider != null)
                                  pw.Image(
                                    imageProvider,
                                    fit: pw.BoxFit.contain,
                                    width: 120,
                                    height: 100,
                                  ),
                                gapH4,
                              ],
                            ),
                          ),
                        ), // pw.Container(
                        //   width: 50,
                        //   height: 50,
                        //   decoration: pw.BoxDecoration(
                        //     color: PdfColors.black,
                        //     border: pw.Border.all(
                        //       color: PdfColors.black,
                        //       width: 1.00,
                        //       style: pw.BorderStyle.solid,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                )
                : quotationItemInfo['line_type_id'] == '1'
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Center(
                      child: pw.Container(
                        padding: pw.EdgeInsets.only(left: 10, right: 20),
                        width: width * 0.35,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            // pw.Divider(
                            //   height: 5,
                            //   color: PdfColors.black,
                            //   // endIndent: 250
                            // ),
                            // gapH4,
                            pw.Text(
                              '${quotationItemInfo['title'] ?? ''}',
                              style: pw.TextStyle(
                                fontSize: 12,
                                font: arabicFont,
                              ),
                            ),
                            // pw.Divider(
                            //   height: 5,
                            //   color: PdfColors.black,
                            //   // endIndent: 250
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                : quotationItemInfo['line_type_id'] == '5'
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 10),
                      width: width * 0.35,
                      child: pw.Text(
                        'Note :${quotationItemInfo['note'] ?? ''}',
                        style: pw.TextStyle(
                          fontSize: 9.sp,
                          font: italicRobotoFont,
                        ),
                      ),
                    ),
                  ],
                )
                : pw.SizedBox(),
      );
    }

    reusableUrlImageRowInQuotations({
      required Map quotationItemInfo,
      required int index,
      required pw.ImageProvider? imageProvider,
    }) {
      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Center(
          child: pw.Image(
            imageProvider!,
            fit: pw.BoxFit.contain,
            // width: 50,
            height: 120,
            // height: 150,
          ),
        ),
      );
    }

    reusableImageRowInQuotations({
      required Map quotationItemInfo,
      required int index,
    }) {
      final image = pw.MemoryImage(quotationItemInfo['image']);

      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Center(
          child: pw.Image(
            image,
            fit: pw.BoxFit.contain,
            // width: 50,
            height: 150,
          ),
        ),
      );
    }

    reusableText(String text) {
      return pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9.sp,
          fontWeight: pw.FontWeight.normal,
          color: PdfColors.black,
        ),
      );
    }

    reusableNumber(String text) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 9.sp,
              fontWeight: pw.FontWeight.normal,
              color: PdfColors.black,
            ),
          ),
        ],
      );
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

    final image = pw.MemoryImage(
      quotationController.logoBytes,
    ); //to be use again

    final myTheme = pw.PageTheme(
      margin: const pw.EdgeInsets.all(10),
      buildBackground:
          (context) => pw.FullPage(
            ignoreMargins: false,
            child:
            // pw.Column(
            //   children: [
            //     pw.SizedBox(height: 30);
            pw.Transform.rotate(
              angle: -0.4, // radians ~ -23°
              child: pw.Opacity(
                opacity: 0.1, // transparent watermark
                child: pw.Text(
                  widget.status == 'cancelled' ? 'LOST' : '',
                  // widget.status == 'cancelled' ? 'CANCELLED' : '',
                  style: pw.TextStyle(
                    fontSize: 68,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ),
            //   ]
            // )
            // ),
          ),
    );

    pdf.addPage(
      pw.MultiPage(
        // margin: const pw.EdgeInsets.all(10),
        pageTheme: myTheme,
        build: (context) {
          return [
            pw.Padding(
              padding: pw.EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.SizedBox(
                    width: 240.w,
                    // width: width * 0.15,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Container(
                              width: 180, // Set the desired width
                              height: 70, // Set the desired height
                              child:
                              // pw.Text("image"),
                              pw.Image(image), //to be use again
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(
                    width: 220.w,
                    // width: width * 0.125,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // gapH4,
                            // gapH4,
                            pw.Text(
                              fullCompanyName,
                              style: pw.TextStyle(
                                fontSize: 9.sp,
                                fontWeight: pw.FontWeight.normal,
                                color: PdfColors.black,
                              ),
                            ),
                            gapH4,
                            pw.SizedBox(
                              width: 200.w,
                              child: reusableText(companyAddress),
                            ),
                          ],
                        ),
                        gapW20,
                      ],
                    ),
                  ),

                  pw.SizedBox(
                    width: 170.w,
                    // width: width * 0.1,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,

                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // gapH4,
                            reusableText(
                              companyPhoneNumber.isNotEmpty
                                  ? 'T $companyPhoneCode $companyPhoneNumber $companyTrn'
                                  : '',
                            ),
                            companyMobileNumber.isNotEmpty
                                ? gapH4
                                : pw.SizedBox.shrink(),
                            companyMobileNumber.isNotEmpty
                                ? reusableText(
                                  companyMobileNumber.isNotEmpty
                                      ? 'T $companyMobileCode $companyMobileNumber'
                                      : '',
                                )
                                : pw.SizedBox.shrink(),
                            gapH4,
                            pw.SizedBox(
                              width: width * 0.1,
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [reusableText(companyEmail)],
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
            // sequence of workflow
            pw.Padding(
              padding: pw.EdgeInsets.fromLTRB(0, 10, 0, 0),
              child:
              // to
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      tableTitleForSequence(
                        text: 'Quotation',
                        // text: 'Quotation',
                        width: width * 0.2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.fromLTRB(10, 20, 0, 0),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: width * 0.1,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '${'to'.tr}:',
                              style: pw.TextStyle(
                                fontSize: 9.sp,
                                fontWeight: pw.FontWeight.normal,
                                color: PdfColors.black,
                              ),
                            ),
                            gapH4,
                            pw.Text(
                              '${'telephone'.tr}:',
                              style: pw.TextStyle(
                                fontSize: 9.sp,
                                fontWeight: pw.FontWeight.normal,
                                color: PdfColors.black,
                              ),
                            ),
                            gapH4,
                            pw.Text(
                              '${'address'.tr}:',
                              style: pw.TextStyle(
                                fontSize: 9.sp,
                                fontWeight: pw.FontWeight.normal,
                                color: PdfColors.black,
                              ),
                            ),
                          ],
                        ),
                        gapW20,
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            reusableText(
                              widget.clientName.isEmpty
                                  ? '---'
                                  : widget.clientName,
                            ),
                            gapH4,
                            reusableText(
                              widget.clientPhoneNumber != '---' &&
                                      widget.clientMobileNumber != '---'
                                  ? '${widget.clientPhoneNumber}  (mobile: ${widget.clientMobileNumber})'
                                  : widget.clientPhoneNumber != '---' &&
                                      widget.clientMobileNumber == '---'
                                  ? widget.clientPhoneNumber
                                  : widget.clientMobileNumber,
                            ),
                            gapH4,
                            reusableText(widget.clientAddress),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //date
                  pw.SizedBox(
                    width: width * 0.1,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '${'offer_no'.tr}:',
                              style: pw.TextStyle(
                                fontSize: 9.sp,
                                fontWeight: pw.FontWeight.normal,
                                color: PdfColors.black,
                              ),
                            ),
                            gapH4,
                            pw.Text(
                              '${'sales_person'.tr}:',
                              style: pw.TextStyle(
                                fontSize: 9.sp,
                                fontWeight: pw.FontWeight.normal,
                                color: PdfColors.black,
                              ),
                            ),
                            gapH4,
                            pw.Text(
                              '${'date'.tr}:',
                              style: pw.TextStyle(
                                fontSize: 9.sp,
                                fontWeight: pw.FontWeight.normal,
                                color: PdfColors.black,
                              ),
                            ),
                            gapH4,
                            pw.Text(
                              '${'currency'.tr}:',
                              style: pw.TextStyle(
                                fontSize: 9.sp,
                                fontWeight: pw.FontWeight.normal,
                                color: PdfColors.black,
                              ),
                            ),
                            gapH4,
                          ],
                        ),
                        gapW16,
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            reusableText(widget.quotationNumber),
                            gapH4,
                            reusableText(
                              widget.salesPerson.isEmpty
                                  ? '---'
                                  : widget.salesPerson,
                            ),
                            gapH5,
                            reusableText(widget.creationDate),
                            gapH5,
                            reusableText(widget.quotationCurrency),
                            gapH5,
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            gapH30,

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                tableTitle(text: 'brand'.tr, width: width * 0.05),
                tableTitle(text: 'item_'.tr, width: width * 0.07),
                tableTitle(text: 'description'.tr, width: width * 0.07),
                tableTitle(text: 'qty'.tr, width: width * 0.03),
                tableTitle(text: 'unit_price'.tr, width: width * 0.04),
                hasDiscount
                    ? tableTitle(text: '${'disc'.tr}%', width: width * 0.03)
                    : pw.SizedBox.shrink(),
                tableTitle(
                  text: 'Total (${widget.quotationCurrency})',
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
            pw.Column(
              children:
                  widget.itemsInfoPrint.map((item) {
                    final index = widget.itemsInfoPrint.indexOf(item);
                    return item['line_type_id'] == '2'
                        ? reusableItemRowInQuotations(
                          quotationItemInfo: item,
                          index: index,
                          imageProvider: imageProviders[item['item_image']],
                        )
                        : item['line_type_id'] == '4' && item['isImageList']
                        ? reusableImageRowInQuotations(
                          quotationItemInfo: item,
                          index: index,
                        )
                        : item['line_type_id'] == '4' && !item['isImageList']
                        ? reusableUrlImageRowInQuotations(
                          quotationItemInfo: item,
                          index: index,
                          imageProvider: imageProviders[item['image']],
                        )
                        : reusableRowInQuotations(
                          quotationItemInfo: item,
                          index: index,
                          imageProvider: imageProviders[item['combo_image']],
                        );
                  }).toList(),
            ),
            pw.Container(
              padding: pw.EdgeInsets.symmetric(
                horizontal: width * 0.01,
                vertical: 25,
              ),
              width:
                  width < 833
                      ? 2000.w
                      : width < 875
                      ? 1500.w
                      : 1000.w,
              // width: width * 0.385,
              // height: 200.h,
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
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 355.w,
                            // width: width * 0.255,
                            child: reusableText('total_price'.tr),
                          ),
                        ],
                      ),

                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 135.w,
                            // width: width * 0.055,
                            child: reusableNumber(widget.quotationCurrency),
                          ),
                        ],
                      ),
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 80.w,
                            // width: width * 0.045,
                            child: reusableNumber(
                              numberWithComma(
                                double.parse(
                                  '${double.parse(widget.totalAllItems.replaceAll(',', ''))}',
                                ).toStringAsFixed(2),
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
                  widget.globalDiscount == '0.00' ||
                          widget.globalDiscount == '0' ||
                          widget.globalDiscount == ''
                      ? pw.SizedBox.shrink()
                      : pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 355.w,
                                // width: width * 0.255,
                                child: reusableText('dis_count'.tr),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 135.w,
                                // width: width * 0.055,
                                child: reusableNumber(
                                  '${widget.globalDiscount == '0.00' || widget.globalDiscount == '0' ? 0 : widget.globalDiscount}%',
                                ),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 80.w,
                                // width: width * 0.045,
                                child: reusableNumber(
                                  widget.globalDiscountAmount == '0'
                                      ? '0.00'
                                      : widget.globalDiscountAmount,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  widget.globalDiscount == '0.00' ||
                          widget.globalDiscount == '0' ||
                          widget.globalDiscount == ''
                      ? pw.SizedBox.shrink()
                      : pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                  // TOTAL PRICE AFTER  DISCOUNT
                  widget.globalDiscount == '0.00' ||
                          widget.globalDiscount == '0' ||
                          widget.globalDiscount == ''
                      ? pw.SizedBox.shrink()
                      : pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 355.w,
                                // width: width * 0.255,
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
                                width: 135.w,
                                // width: width * 0.055,
                                child: reusableNumber(widget.quotationCurrency),
                                // child: reusableText(primaryCurrency),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 80.w,
                                // width: width * 0.045,
                                child: reusableNumber(
                                  numberWithComma(
                                    double.parse(
                                      '${double.parse((widget.totalAllItems).replaceAll(',', '')) - double.parse((widget.globalDiscountAmount).replaceAll(',', ''))}',
                                    ).toStringAsFixed(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  widget.globalDiscount == '0.00' ||
                          widget.globalDiscount == '0' ||
                          widget.globalDiscount == ''
                      ? pw.SizedBox.shrink()
                      : pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                  widget.specialDiscount == '0.00' ||
                          widget.specialDiscount == '0' ||
                          widget.specialDiscount == ''
                      ? pw.SizedBox.shrink()
                      : pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 355.w,
                                // width: width * 0.255,
                                child: reusableText(
                                  'additional_special_discount'.tr,
                                ),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 135.w,
                                // width: width * 0.055,
                                child: reusableNumber(
                                  '${widget.specialDiscount == '0.00' || widget.specialDiscount == '0' ? 0 : widget.specialDiscount}%',
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 80.w,
                                // width: width * 0.045,
                                child: reusableNumber(
                                  widget.specialDiscountAmount,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  primaryCurrency == widget.quotationCurrency
                      ? pw.SizedBox.shrink()
                      : pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),

                  // TOTAL PRICE AFTER SPECIAL DISCOUNT
                  if (primaryCurrency != widget.quotationCurrency)
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.SizedBox(
                              width: 355.w,
                              // width: width * 0.255,
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
                              width: 135.w,
                              // width: width * 0.055,
                              child: reusableNumber(widget.quotationCurrency),
                              // child: reusableText(primaryCurrency),
                            ),
                          ],
                        ),
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.SizedBox(
                              width: 80.w,
                              // width: width * 0.045,
                              child: reusableNumber(
                                numberWithComma(
                                  double.parse(
                                    '${double.parse(widget.totalPriceAfterSpecialDiscount.replaceAll(',', ''))}',
                                  ).toStringAsFixed(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  widget.specialDiscount == '0.00' ||
                          widget.specialDiscount == '0' ||
                          widget.specialDiscount == ''
                      ? pw.SizedBox.shrink()
                      : pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),

                  //VAT
                  widget.vat == '' || widget.vat == '0.00' || widget.vat == '0'
                      ? pw.SizedBox.shrink()
                      : pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 355.w,
                                // width: width * 0.255,
                                child: reusableText(
                                  widget.isVatNoPrinted
                                      ? ' '
                                      : widget.isPrintedAsVatExempt
                                      ? 'vat_exempt'.tr.toUpperCase()
                                      : widget.isPrintedAs0
                                      ? '${'vat'.tr} 0%'
                                      : 'vat'.tr,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 135.w,
                                // width: width * 0.055,
                                child:
                                    widget.vat.isNotEmpty ||
                                            !widget.isPrintedAs0
                                        ? reusableNumber(
                                          widget.isVatNoPrinted ||
                                                  widget.isPrintedAsVatExempt
                                              ? ' '
                                              : widget.fromPage ==
                                                  'createQuotation'
                                              ? widget.vat
                                              : '${widget.vat}%',
                                        )
                                        : reusableNumber('0 %'),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 80.w,
                                // width: width * 0.045,
                                child: reusableNumber(
                                  widget.isVatNoPrinted ||
                                          widget.isPrintedAsVatExempt
                                      ? ' '
                                      : widget.vatByQuotationCurrency,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                  widget.vat == '' || widget.vat == '0.00' || widget.vat == '0'
                      ? pw.SizedBox.shrink()
                      : pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),

                  // FINAL PRICE INCL. VAT
                  widget.vat == '' || widget.vat == '0.00' || widget.vat == '0'
                      ? pw.SizedBox.shrink()
                      : pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 355.w,
                                // width: width * 0.255,
                                child: pw.Text(
                                  'final_price_incl_vat'.tr,
                                  style: pw.TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: pw.FontWeight.normal,
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
                                width: 135.w,
                                // width: width * 0.055,
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    pw.Text(
                                      widget.quotationCurrency,
                                      style: pw.TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: pw.FontWeight.normal,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 80.w,
                                // width: width * 0.045,
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    pw.Text(
                                      widget.finalPriceByQuotationCurrency,
                                      style: pw.TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: pw.FontWeight.normal,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                  widget.vat == '' || widget.vat == '0.00' || widget.vat == '0'
                      ? pw.SizedBox.shrink()
                      : pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                  gapH6,

                  widget.vat == '' || widget.vat == '0.00' || widget.vat == '0'
                      ? pw.SizedBox.shrink()
                      : pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 355.w,

                                // width: width * 0.255,
                                child: pw.Text(
                                  'final_price_incl_vat'.tr,
                                  style: pw.TextStyle(
                                    fontSize: 9.sp,
                                    // fontWeight: pw.FontWeight.normal,
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
                                width: 135.w,
                                // width: width * 0.055,
                                child: reusableNumber(primaryCurrency),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 80.w,
                                // width: width * 0.045,
                                child: reusableNumber(
                                  widget.finalPriceByQuotationCurrency == '0'
                                      ? '0.00'
                                      : numberWithComma(
                                        '${roundUp(double.parse(widget.finalPriceByQuotationCurrency.replaceAll(',', '')) / double.parse(finallyRate), 2)}',
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                  // pw.Spacer(),
                  gapH30,
                  widget.cancellationReason.isNotEmpty
                      ? pw.Column(
                        children: [
                          pw.Divider(
                            height: 5,
                            color: PdfColors.black,
                            // endIndent: 250
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              reusableText(
                                'Cancellation Reason : ${widget.cancellationReason}',
                              ),
                            ],
                          ),
                          pw.Divider(
                            height: 5,
                            color: PdfColors.black,
                            // endIndent: 250
                          ),
                        ],
                      )
                      : pw.SizedBox.shrink(),
                ],
              ),
            ),

            widget.termsAndConditionsNote != "[{\"insert\":\"\\n\"}]" &&
                    widget.termsAndConditions != "[{\"insert\":\"\\n\"}]"
                ? pw.Padding(
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
                                      child:
                                      // pw.Text("image"),
                                      pw.Image(image), //to be use again
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                      gapH6,
                      pw.SizedBox(
                        // width: width * 0.15,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  width: width * 0.25,
                                  child: quillDeltaToPdfWidget(
                                    widget.termsAndConditionsNote,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      gapH6,
                      pw.SizedBox(
                        // width: width * 0.15,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  width: width * 0.25,
                                  child: quillDeltaToPdfWidget(
                                    widget.termsAndConditions,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                : pw.SizedBox.shrink(),
          ];
        },
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Padding(
              padding: pw.EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.fromLTRB(0, 50, 0, 0),
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
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  children: [
                                    pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        reusableText('(${'the_client'.tr})'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              //date
                              pw.SizedBox(
                                width: width * 0.1,
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  children: [
                                    pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        reusableText('(${'the_supplier'.tr})'),
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
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  children: [
                                    pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        reusableText(widget.clientName),
                                        gapH4,
                                        reusableText('${'signature'.tr}:'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              pw.SizedBox(
                                width: width * 0.1,
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
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
          );
        },
      ),
    );

    return pdf.save();
  }

  // void _sharePdf(BuildContext context, PdfPageFormat format) async {
  //   final pdfBytes = await _generatePdf(format, context);
  //   final fileName =
  //       '${widget.clientName} Quotation ${widget.quotationNumber}.pdf';
  //   await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  // }
}
