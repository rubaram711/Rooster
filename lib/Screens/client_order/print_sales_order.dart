import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:rooster_app/Controllers/sales_order_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import '../../../const/colors.dart';
import '../../Controllers/exchange_rates_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/page_title.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../const/Delta/convert_from_delta_to_pw_widget.dart';
import '../../const/Sizes.dart';
import '../../const/functions.dart';

class PrintSalesOrder extends StatefulWidget {
  const PrintSalesOrder({
    super.key,
    required this.quotationNumber,
    required this.salesOrderNumber,
    required this.ref,
    required this.creationDate,
    required this.receivedUser,
    required this.senderUser,
    required this.status,
    required this.vat,
    required this.fromPage,
    required this.totalBeforeVat,
    required this.discountOnAllItem,
    required this.totalAllItems,
    required this.globalDiscount,
    required this.totalPriceAfterDiscount,
    required this.additionalSpecialDiscount,
    required this.totalPriceAfterSpecialDiscount,

    // required this.itemCurrencyName,
    // required this.itemCurrencySymbol,
    // required this.itemCurrencyLatestRate,
    required this.specialDisc,
    required this.specialDiscount,
    required this.specialDiscountAmount,

    required this.totalPriceAfterSpecialDiscountBySalesOrderCurrency,
    required this.vatBySalesOrderCurrency,
    required this.finalPriceBySalesOrderCurrency,
    required this.salesPerson,
    required this.salesOrderCurrency,
    required this.salesOrderCurrencySymbol,
    required this.salesOrderCurrencyLatestRate,
    required this.clientPhoneNumber,
    required this.clientName,
    required this.termsAndConditions,
    required this.itemsInfoPrint,
    this.isInSalesOrder = false,
    required this.isPrintedAsVatExempt,
    required this.isPrintedAs0,
    required this.isVatNoPrinted,
  });

  final String quotationNumber;
  final String salesOrderNumber;
  final String ref;
  final String creationDate;
  final String receivedUser;
  final String senderUser;
  final String status;
  final String vat;
  final String fromPage;
  final String totalBeforeVat;
  final String discountOnAllItem;
  final String totalAllItems;

  final String globalDiscount;
  final String totalPriceAfterDiscount;
  final String additionalSpecialDiscount;
  final String totalPriceAfterSpecialDiscount;
  // final String itemCurrencyName;
  // final String itemCurrencySymbol;
  // final String itemCurrencyLatestRate;
  //
  final String specialDisc;
  final String specialDiscount;
  final String specialDiscountAmount;
  final String totalPriceAfterSpecialDiscountBySalesOrderCurrency;
  final String vatBySalesOrderCurrency;
  final String finalPriceBySalesOrderCurrency;

  final String salesPerson;
  final String salesOrderCurrency;
  final String salesOrderCurrencySymbol;
  final String salesOrderCurrencyLatestRate;
  final String clientPhoneNumber;
  final String clientName;
  final String termsAndConditions;
  final bool isInSalesOrder;
  final List itemsInfoPrint;
  final bool isPrintedAsVatExempt;
  final bool isPrintedAs0;
  final bool isVatNoPrinted;

  @override
  State<PrintSalesOrder> createState() => _PrintSalesOrderState();
}

class _PrintSalesOrderState extends State<PrintSalesOrder> {
  bool isHomeHovered = false;
  final SalesOrderController salesOrderController = Get.find();
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
  Future<void> headerRetrieve() async {
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
        widget.salesOrderCurrencyLatestRate.isEmpty
            ? '1'
            : widget.salesOrderCurrencyLatestRate,
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
                        if (salesOrderController.isSubmitAndPreviewClicked) {
                          salesOrderController.getAllSalesOrderFromBack();
                          Get.back();
                          homeController.selectedTab.value =
                              'sales_order_summary';
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
                    const PageTitle(text: 'Sales Order'),
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
                      homeController.selectedTab.value = 'sales_order_summary';
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
                pdfFileName:
                    '${widget.clientName} [${widget.salesOrderNumber}]',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // // load image from assets
  // Future<Uint8List> loadImage(String path) async {
  //   final data = await rootBundle.load(path);
  //   return data.buffer.asUint8List();
  // }

  // load image from network

  Future<Uint8List> _generatePdf(
    PdfPageFormat format,
    BuildContext context,
  ) async {
    bool hasDiscount = widget.itemsInfoPrint.any(
      (item) => double.parse('${item['item_discount']}') != 0,
    );

    Map<String, pw.ImageProvider?> imageProviders = {};
    for (var item in widget.itemsInfoPrint) {
      if (item['line_type_id'] == '2') {
        if (item['item_image'] != null) {
          try {
            final response = await http.get(Uri.parse(item['item_image']));
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
            final response = await http.get(Uri.parse(item['image']));
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
    // var gapH2 = pw.SizedBox(height: 2);
    var gapH5 = pw.SizedBox(height: 5);
    var gapH6 = pw.SizedBox(height: 6);
    final font = await rootBundle.load('assets/fonts/Tajawal-Medium.ttf');
    final arabicFont = pw.Font.ttf(font);
    final italicfont = await rootBundle.load('assets/fonts/Roboto-Italic.ttf');
    final italicRobotoFont = pw.Font.ttf(italicfont);
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

    reusableItemRowInSalesOrder({
      required Map salesOrderItemInfo,
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
                      salesOrderItemInfo['item_brand'] != ''
                          ? salesOrderItemInfo['item_brand']
                          : '---',
                  width: width * 0.05,
                ),

                reusableShowInfoCard(
                  text: '${salesOrderItemInfo['item_name'] ?? ''}',
                  width: width * 0.07,
                ),
                reusableShowInfoCard(
                  text: '${salesOrderItemInfo['item_description'] ?? ''}',
                  width: width * 0.07,
                ),
                reusableShowInfoCard(
                  text: '${salesOrderItemInfo['item_quantity'] ?? ''}',
                  width: width * 0.03,
                ),
                reusableShowInfoCard(
                  text:
                  // '${salesOrderItemInfo['item_unit_price'] ?? ''}',
                  numberWithComma(
                    double.parse(
                      '${double.parse('${salesOrderItemInfo['item_unit_price']}'.replaceAll(',', ''))}',
                      // '${double.parse('${salesOrderItemInfo['item_unit_price']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
                    ).toStringAsFixed(2),
                  ),
                  width: width * 0.04,
                ),
                hasDiscount
                    ? reusableShowInfoCard(
                      text: '${salesOrderItemInfo['item_discount'] ?? '0'}',
                      width: width * 0.03,
                    )
                    : pw.SizedBox.shrink(),
                reusableShowInfoCard(
                  text:
                  // '${quotationItemIn
                  // fo['item_total'] ?? ''}',
                  numberWithComma(
                    double.parse(
                      '${double.parse('${salesOrderItemInfo['item_total']}'.replaceAll(',', ''))}',
                      // '${double.parse('${salesOrderItemInfo['item_total']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
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
                // pw.Container(
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
                ),
              ],
            ),
          ],
        ),
      );
    }

    reusableRowInSalesOrder({
      required Map salesOrderItemInfo,
      required int index,
      required pw.ImageProvider? imageProvider,
    }) {
      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child:
            salesOrderItemInfo['line_type_id'] == '3'
                ? pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      children: [
                        reusableShowInfoCard(
                          text: salesOrderItemInfo['combo_brand'] ?? '---',
                          width: width * 0.05,
                        ),

                        reusableShowInfoCard(
                          text: '${salesOrderItemInfo['item_name'] ?? ''}',
                          width: width * 0.07,
                        ),
                        reusableShowInfoCard(
                          text:
                              '${salesOrderItemInfo['item_description'] ?? ''}',
                          width: width * 0.07,
                        ),
                        reusableShowInfoCard(
                          text: '${salesOrderItemInfo['item_quantity'] ?? ''}',
                          width: width * 0.03,
                        ),
                        reusableShowInfoCard(
                          text:
                          // '${salesOrderItemInfo['item_unit_price'] ?? ''}',
                          numberWithComma(
                            double.parse(
                              '${double.parse('${salesOrderItemInfo['item_unit_price']}'.replaceAll(',', ''))}',
                              // '${double.parse('${salesOrderItemInfo['item_unit_price']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
                            ).toStringAsFixed(2),
                          ),
                          width: width * 0.04,
                        ),
                        hasDiscount
                            ? reusableShowInfoCard(
                              text:
                                  '${salesOrderItemInfo['item_discount'] ?? '0'}',
                              width: width * 0.03,
                            )
                            : pw.SizedBox.shrink(),
                        reusableShowInfoCard(
                          text:
                          // '${quotationItemIn
                          // fo['item_total'] ?? ''}',
                          numberWithComma(
                            double.parse(
                              '${double.parse('${salesOrderItemInfo['item_total']}'.replaceAll(',', ''))}',
                              // '${double.parse('${salesOrderItemInfo['item_total']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
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
                        // pw.Container(
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
                        ),
                      ],
                    ),
                  ],
                )
                : salesOrderItemInfo['line_type_id'] == '1'
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.only(right: 20.00, left: 10.00),
                      width: MediaQuery.of(context).size.width * 0.40,
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
                            '${salesOrderItemInfo['title']}',
                            style: pw.TextStyle(fontSize: 12, font: arabicFont),
                          ),

                          // pw.Divider(
                          //   height: 5,
                          //   color: PdfColors.black,
                          //   // endIndent: 250
                          // ),
                        ],
                      ),
                    ),
                  ],
                )
                : salesOrderItemInfo['line_type_id'] == '5'
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 10),
                      width: width * 0.35,
                      child: pw.Text(
                        'Note : ${salesOrderItemInfo['note']}',
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

    reusableUrlImageRowInSalesOrder({
      required Map salesOrderItemInfo,
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
            height: 150,
          ),
        ),
      );
    }

    reusableImageRowInSalesOrder({
      required Map salesOrderItemInfo,
      required int index,
    }) {
      final image = pw.MemoryImage(salesOrderItemInfo['image']);

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
      salesOrderController.logoBytes,
    ); // to be use again

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
                  widget.status == 'cancelled' ? 'CANCELLED' : '',
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
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
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
                                  //  pw.Text("image"),
                                  pw.Image(image), //to be use again
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(
                        width: 200.w,
                        // width: width * 0.125,
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
                                    fontSize: 9.sp,
                                    fontWeight: pw.FontWeight.normal,
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

                      pw.SizedBox(
                        width: 160.w,
                        // width: width * 0.1,
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
                                gapH4,
                                pw.SizedBox(
                                  width: width * 0.1,
                                  child: pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start,

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
                  padding: pw.EdgeInsets.fromLTRB(0, 25, 0, 0),
                  child:
                  // to
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,

                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          tableTitleForSequence(
                            text: 'Sales Order [${widget.salesOrderNumber}] ',
                            width: width * 0.1,
                          ),
                          widget.quotationNumber == ''
                              ? tableTitleForSequence(
                            text: 'Is New Sales Order',
                            width: width * 0.07,
                          )
                              : tableTitleForSequence(
                            text:
                            'Is Quotation [${widget.quotationNumber}]',
                            width: width * 0.1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.fromLTRB(10, 20, 0, 0),
                  child: pw.Row(
                    // crossAxisAlignment: pw.CrossAxisAlignment.end,
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
                                reusableText(widget.clientPhoneNumber),
                                gapH4,
                                reusableText(companyAddress),
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
                                reusableText(widget.salesOrderNumber),
                                gapH4,
                                reusableText(
                                  widget.salesPerson.isEmpty
                                      ? '---'
                                      : widget.salesPerson,
                                ),
                                gapH5,
                                reusableText(widget.creationDate),
                                gapH5,
                                reusableText(widget.salesOrderCurrency),
                                gapH5,
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                pw.Padding(
                  padding: pw.EdgeInsets.fromLTRB(0, 25, 0, 0),
                  child:
                  // to
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          tableTitle(text: 'brand'.tr, width: width * 0.05),
                          tableTitle(text: 'item_'.tr, width: width * 0.07),
                          tableTitle(
                            text: 'description'.tr,
                            width: width * 0.07,
                          ),
                          tableTitle(text: 'qty'.tr, width: width * 0.03),
                          tableTitle(
                            text: 'unit_price'.tr,
                            width: width * 0.04,
                          ),
                          hasDiscount
                              ? tableTitle(
                                text: '${'disc'.tr}%',
                                width: width * 0.03,
                              )
                              : pw.SizedBox.shrink(),
                          tableTitle(
                            text: 'Total (${widget.salesOrderCurrency})',
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
                        padding: const pw.EdgeInsets.symmetric(vertical: 5),
                        // padding: const pw.EdgeInsets.symmetric(vertical: 10),
                        itemCount: widget.itemsInfoPrint.length,
                        itemBuilder: (context, index) {
                          final item = widget.itemsInfoPrint[index];
                          return item['line_type_id'] == '2'
                              ? reusableItemRowInSalesOrder(
                                salesOrderItemInfo: item,
                                index: index,
                                imageProvider:
                                    imageProviders[item['item_image']], // Pass the pre-fetched ImageProvider
                                // width: width,
                              )
                              : item['line_type_id'] == '4' &&
                                  item['isImageList']
                              ? reusableImageRowInSalesOrder(
                                salesOrderItemInfo: item,
                                index: index,
                              )
                              : item['line_type_id'] == '4' &&
                                  !item['isImageList']
                              ?
                              //  pw.Text("Image")
                              reusableUrlImageRowInSalesOrder(
                                salesOrderItemInfo: item,
                                index: index,
                                imageProvider: imageProviders[item['image']],
                              )
                              : reusableRowInSalesOrder(
                                salesOrderItemInfo: item,
                                index: index,
                                imageProvider:
                                    imageProviders[item['combo_image']],
                              );
                        },
                      ),
                    ],
                  ),
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
                                child: reusableNumber(
                                  widget.salesOrderCurrency,
                                ),
                                // child: reusableText(primaryCurrency),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.SizedBox(
                                width: 80.w,
                                // width: width * 0.045,
                                child: reusableNumber(
                                  numberWithComma(
                                    double.parse(
                                      '${double.parse(widget.totalAllItems.replaceAll(',', ''))}',
                                      // '${double.parse(widget.totalAllItems.replaceAll(',', '')) / double.parse(finallyRate)}',
                                    ).toStringAsFixed(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      widget.globalDiscount == '0.00' ||
                              widget.globalDiscount == '0'
                          ? pw.Text("")
                          : pw.Divider(
                            height: 5,
                            color: PdfColors.black,
                            // endIndent: 250
                          ),
                      widget.globalDiscount == '0.00' ||
                              widget.globalDiscount == '0'
                          ? pw.Text("")
                          : pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
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
                                    // widget.discountOnAllItem == '0'
                                    //     ? width * 0.08
                                    //     : width * 0.068,
                                    child: reusableNumber(
                                      '${widget.globalDiscount == '0.00' || widget.globalDiscount == '0' ? 0 : widget.globalDiscount}%',
                                    ),
                                  ),
                                ],
                              ),

                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.SizedBox(
                                    width: 80.w,
                                    // width: width * 0.045,
                                    // child: reusableText('$discountOnAllItem'),
                                    child: reusableNumber(
                                      widget.discountOnAllItem == '0' ||
                                              widget.discountOnAllItem == '0.00'
                                          ? '0.00'
                                          : widget.discountOnAllItem,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      widget.globalDiscount == '0.00' ||
                              widget.globalDiscount == '0'
                          ? pw.Text("")
                          : pw.Divider(
                            height: 5,
                            color: PdfColors.black,
                            // endIndent: 250
                          ),
                      // TOTAL PRICE AFTER  DISCOUNT
                      widget.globalDiscount == '0.00' ||
                              widget.globalDiscount == '0'
                          ? pw.Text("")
                          : pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
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
                                    child: reusableNumber(
                                      widget.salesOrderCurrency,
                                    ),
                                    // child: reusableText(primaryCurrency),
                                  ),
                                ],
                              ),
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.SizedBox(
                                    width: 80.w,
                                    // width: width * 0.045,
                                    child: reusableNumber(
                                      numberWithComma(
                                        double.parse(
                                          '${double.parse(widget.totalPriceAfterDiscount.replaceAll(',', ''))}',
                                        ).toStringAsFixed(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                      widget.globalDiscount == '0.00' ||
                              widget.globalDiscount == '0'
                          ? pw.Text("")
                          : pw.Divider(
                            height: 5,
                            color: PdfColors.black,
                            // endIndent: 250
                          ),
                      widget.specialDiscount == '0.00' ||
                              widget.specialDiscount == '0'
                          ? pw.Text("")
                          : pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
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
                                    // width:
                                    //     widget.additionalSpecialDiscount == '0'
                                    //         ? width * 0.08
                                    //         : width * 0.068,
                                    child: reusableNumber(
                                      '${widget.specialDiscount == '0.00' || widget.specialDiscount == '0' ? 0 : widget.specialDiscount}%',
                                    ),
                                  ),
                                ],
                              ),
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.SizedBox(
                                    width: 80.w,
                                    // width: width * 0.045,
                                    child: reusableNumber(
                                      widget.additionalSpecialDiscount,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      primaryCurrency == widget.salesOrderCurrency
                          ? pw.SizedBox.shrink()
                          : pw.Divider(
                            height: 5,
                            color: PdfColors.black,
                            // endIndent: 250
                          ),

                      // TOTAL PRICE AFTER SPECIAL DISCOUNT
                      if (primaryCurrency != widget.salesOrderCurrency)
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
                                  child: reusableNumber(
                                    widget.salesOrderCurrency,
                                  ),
                                  // child: reusableText(primaryCurrency),
                                ),
                              ],
                            ),
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              children: [
                                pw.SizedBox(
                                  width: 80.w,
                                  // width: width * 0.045,
                                  child: reusableNumber(
                                    // '${widget.specialDiscountAmount}',
                                    // widget.totalPriceAfterSpecialDiscount,
                                    numberWithComma(
                                      double.parse(
                                        '${double.parse(widget.totalPriceAfterSpecialDiscount.replaceAll(',', ''))}',
                                        // '${double.parse(widget.totalPriceAfterSpecialDiscount.replaceAll(',', '')) / double.parse(finallyRate)}',
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
                      //VAT
                      widget.vat == '' ||
                              widget.vat == '0.00' ||
                              widget.vat == '0'
                          ? pw.Text("")
                          : pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
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
                                        companyVat.isNotEmpty &&
                                                !widget.isPrintedAs0
                                            ? reusableNumber(
                                              widget.isVatNoPrinted ||
                                                      widget
                                                          .isPrintedAsVatExempt
                                                  ? ' '
                                                  : widget.fromPage ==
                                                      'createSo'
                                                  ? widget.vat
                                                  : '$companyVat%',
                                            )
                                            : reusableNumber(' 0 %'),
                                  ),
                                ],
                              ),
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.SizedBox(
                                    width: 80.w,
                                    // width: width * 0.045,
                                    child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          widget.isVatNoPrinted ||
                                                  widget.isPrintedAsVatExempt
                                              ? ' '
                                              : widget.vatBySalesOrderCurrency,
                                          style: pw.TextStyle(
                                            fontSize: 9.sp,
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

                      widget.vat == '' ||
                              widget.vat == '0.00' ||
                              widget.vat == '0'
                          ? pw.Text("")
                          : pw.Divider(
                            height: 5,
                            color: PdfColors.black,
                            // endIndent: 250
                          ),
                      // FINAL PRICE INCL. VAT
                      widget.vat == '' ||
                              widget.vat == '0.00' ||
                              widget.vat == '0'
                          ? pw.Text("")
                          : pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
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
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          widget.salesOrderCurrency,
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
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.SizedBox(
                                    width: 80.w,
                                    // width: width * 0.045,
                                    child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          widget.finalPriceBySalesOrderCurrency,
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

                      widget.vat == '' ||
                              widget.vat == '0.00' ||
                              widget.vat == '0'
                          ? pw.Text("")
                          : pw.Divider(
                            height: 5,
                            color: PdfColors.black,
                            // endIndent: 250
                          ),
                      gapH6,
                      widget.vat == '' ||
                              widget.vat == '0.00' ||
                              widget.vat == '0'
                          ? pw.Text("")
                          : pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.SizedBox(
                                    width: 80.w,
                                    // width: width * 0.045,
                                    child: reusableNumber(
                                      widget.finalPriceBySalesOrderCurrency ==
                                              '0'
                                          ? '0.00'
                                          : numberWithComma(
                                            '${roundUp(double.parse(widget.finalPriceBySalesOrderCurrency.replaceAll(',', '')) / double.parse(finallyRate), 2)}',
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                    ],
                  ),
                ),
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
                                          //  pw.Text("image"),
                                          pw.Image(image), //to be use aganin
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // pw.SizedBox(
                              //   width: width * 0.15,
                              //   child: pw.Row(
                              //     mainAxisAlignment: pw.MainAxisAlignment.start,
                              //     children: [
                              //       pw.Column(
                              //         crossAxisAlignment:
                              //             pw.CrossAxisAlignment.start,
                              //         children: [
                              //           gapH4,
                              //           reusableText(''),
                              //           gapH4,
                              //           reusableText(''),
                              //         ],
                              //       ),
                              //       gapW20,
                              //     ],
                              //   ),
                              // ),
                              // pw.SizedBox(
                              //   width: width * 0.15,
                              //   child: pw.Row(
                              //     mainAxisAlignment: pw.MainAxisAlignment.start,
                              //     children: [
                              //       pw.Column(
                              //         crossAxisAlignment:
                              //             pw.CrossAxisAlignment.start,
                              //         children: [
                              //           gapH4,
                              //           reusableText(''),
                              //           gapH4,
                              //           reusableText(''),
                              //         ],
                              //       ),
                              //       gapW20,
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),

                          // pw.Padding(
                          //   padding: pw.EdgeInsets.fromLTRB(0, 4, 0, 0),
                          //   child: pw.SizedBox(
                          //     // width: width * 0.15,
                          //     child: pw.Row(
                          //       mainAxisAlignment: pw.MainAxisAlignment.start,
                          //       children: [
                          //         // if( '${widget.termsAndConditions}' != '')
                          //         reusableText(fullCompanyName),
                          //
                          //         // if( '${widget.termsAndConditions}' != '')
                          //         reusableText('terms_and_conditions'.tr),
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          // if( '${widget.termsAndConditions}' != '')
                          pw.Divider(
                            height: 5,
                            color: PdfColors.black,
                            // endIndent: 250
                          ),
                          gapH6,
                          if (widget.termsAndConditions != '')
                            // pw.Padding(
                            //   padding: const pw.EdgeInsets.all(16),
                            //   child: quillDeltaToPdfWidget(widget.termsAndConditions),
                            // ),
                            pw.SizedBox(
                              // width: width * 0.15,
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
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

                          // For local payments,
                          // pw.Padding(
                          //   padding: pw.EdgeInsets.fromLTRB(0, 20, 0, 0),
                          //   child: pw.SizedBox(
                          //     // width: width * 0.15,
                          //     child: pw.Row(
                          //       mainAxisAlignment: pw.MainAxisAlignment.start,
                          //       children: [
                          //         pw.Column(
                          //           crossAxisAlignment: pw.CrossAxisAlignment.start,
                          //           children: [
                          //             gapH4,
                          //
                          //             // reusableText('.For local payments,',),
                          //             if (companyLocalPayments != '')
                          //               reusableText(
                          //                 '.For local payments, $companyLocalPayments',
                          //               ),
                          //
                          //             gapH4,
                          //             companyBankInfo != ''
                          //                 ? reusableText(' $companyBankInfo')
                          //                 : reusableText(''),
                          //           ],
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          pw.Padding(
                            padding: pw.EdgeInsets.fromLTRB(0, 200, 0, 0),
                            child: pw.Container(
                              alignment: pw.Alignment.centerRight,
                              margin: const pw.EdgeInsets.only(bottom: 0.5),
                              child: pw.Column(
                                children: [
                                  pw.Divider(height: 5, color: PdfColors.black),
                                  pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.end,
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
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.end,
                                    children: [
                                      buildDividersRow(1000),
                                      gapW180,
                                      buildDividersRow(950),
                                    ],
                                  ),

                                  pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.end,
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
                                                reusableText(widget.clientName),
                                                gapH4,
                                                reusableText(
                                                  '${'signature'.tr}:',
                                                ),
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
                                                reusableText(
                                                  '${'signature'.tr}:',
                                                ),
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
                    )
                    : pw.Text(""),

                // pw.Padding(
                //   padding: pw.EdgeInsets.fromLTRB(0, 0, 0, 0),
                //   child: pw.Column(
                //     crossAxisAlignment: pw.CrossAxisAlignment.end,
                //     children: [
                //       pw.Padding(
                //         padding: pw.EdgeInsets.fromLTRB(0, 50, 0, 0),
                //         child: pw.Container(
                //           alignment: pw.Alignment.centerRight,
                //           margin: const pw.EdgeInsets.only(bottom: 0.5),
                //           child: pw.Column(
                //             children: [
                //               pw.Divider(height: 5, color: PdfColors.black),
                //               pw.Row(
                //                 crossAxisAlignment:
                //                     pw.CrossAxisAlignment.end,
                //                 children: [
                //                   pw.SizedBox(
                //                     width: width * 0.25,
                //                     child: pw.Row(
                //                       mainAxisAlignment:
                //                           pw.MainAxisAlignment.start,
                //                       children: [
                //                         pw.Column(
                //                           crossAxisAlignment:
                //                               pw.CrossAxisAlignment.start,
                //                           children: [
                //                             reusableText(
                //                               '(${'the_client'.tr})',
                //                             ),
                //                           ],
                //                         ),
                //                       ],
                //                     ),
                //                   ),

                //                   //date
                //                   pw.SizedBox(
                //                     width: width * 0.1,
                //                     child: pw.Row(
                //                       mainAxisAlignment:
                //                           pw.MainAxisAlignment.start,
                //                       children: [
                //                         pw.Column(
                //                           crossAxisAlignment:
                //                               pw.CrossAxisAlignment.start,
                //                           children: [
                //                             reusableText(
                //                               '(${'the_supplier'.tr})',
                //                             ),
                //                           ],
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ],
                //               ),

                //               pw.Row(
                //                 crossAxisAlignment:
                //                     pw.CrossAxisAlignment.end,
                //                 children: [
                //                   buildDividersRow(1000),
                //                   gapW180,
                //                   buildDividersRow(950),
                //                 ],
                //               ),

                //               pw.Row(
                //                 crossAxisAlignment:
                //                     pw.CrossAxisAlignment.end,
                //                 children: [
                //                   pw.SizedBox(
                //                     width: width * 0.25,
                //                     child: pw.Row(
                //                       mainAxisAlignment:
                //                           pw.MainAxisAlignment.start,
                //                       children: [
                //                         pw.Column(
                //                           crossAxisAlignment:
                //                               pw.CrossAxisAlignment.start,
                //                           children: [
                //                             reusableText(widget.clientName),
                //                             gapH4,
                //                             reusableText(
                //                               '${'signature'.tr}:',
                //                             ),
                //                           ],
                //                         ),
                //                       ],
                //                     ),
                //                   ),

                //                   pw.SizedBox(
                //                     width: width * 0.1,
                //                     child: pw.Row(
                //                       mainAxisAlignment:
                //                           pw.MainAxisAlignment.start,
                //                       children: [
                //                         pw.Column(
                //                           crossAxisAlignment:
                //                               pw.CrossAxisAlignment.start,
                //                           children: [
                //                             reusableText(fullCompanyName),
                //                             gapH4,
                //                             reusableText(
                //                               '${'signature'.tr}:',
                //                             ),
                //                           ],
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
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
}

// class PrintQuotations extends StatefulWidget {
//   const PrintQuotations({
//     super.key,
//     required this.salesOrderNumber,
//     required this.ref,
//     required this.rowsInListViewInQuotation,
//     required this.creationDate,
//     required this.receivedUser,
//     required this.senderUser,
//     required this.status,
//     this.isInSalesOrder = false,
//   });
//
//   final String salesOrderNumber;
//   final String ref;
//   final String creationDate;
//   final String receivedUser;
//   final String senderUser;
//   final String status;
//   final bool isInSalesOrder;
//   final List rowsInListViewInQuotation;
//
//   @override
//   State<PrintQuotations> createState() => _PrintQuotationsState();
// }
//
// class _PrintQuotationsState extends State<PrintQuotations> {
//   bool isHomeHovered = false;
//   final QuotationController quotationController = Get.find();
//   HomeController homeController = Get.find();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: MediaQuery.of(context).size.width * 0.02,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: MediaQuery.of(context).size.height * 0.05),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         if (quotationController.isSubmitAndPreviewClicked) {
//                           quotationController.getAllQuotationsFromBack();
//                           Get.back();
//                           homeController.selectedTab.value = 'quotations';
//                         } else {
//                           Get.back();
//                         }
//                       },
//                       child: Icon(
//                         Icons.arrow_back,
//                         size: 22,
//                         // color: Colors.grey,
//                         color: Primary.primary,
//                       ),
//                     ),
//                     gapW10,
//                     const PageTitle(text: 'Quotation'),
//                   ],
//                 ),
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 6),
//                   child: InkWell(
//                     onHover: (val) {
//                       setState(() {
//                         isHomeHovered = val;
//                       });
//                     },
//                     child: Icon(
//                       Icons.home,
//                       size: 30,
//                       color: isHomeHovered ? Primary.primary : Colors.grey,
//                     ),
//                     onTap: () {
//                       Get.back();
//                       homeController.selectedTab.value = 'quotation_summary';
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: MediaQuery.of(context).size.height * 0.05),
//             SizedBox(
//               width: Sizes.deviceWidth * 0.8,
//               height: Sizes.deviceHeight * 0.85,
//               child: PdfPreview(
//                 build: (format) => _generatePdf(format, context),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<Uint8List> _generatePdf(
//       PdfPageFormat format,
//       BuildContext context,
//       ) async {
//     final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
//     double width = MediaQuery.of(context).size.width;
//     var gapW20 = pw.SizedBox(width: 20);
//     var gapH4 = pw.SizedBox(height: 4);
//     var gapH10 = pw.SizedBox(height: 10);
//     tableTitle({required String text, required double width}) {
//       return pw.SizedBox(
//         width: width,
//         child: pw.Text(
//           text,
//           textAlign: pw.TextAlign.center,
//           style: pw.TextStyle(
//             color: PdfColors.black,
//             fontSize: 9,
//             fontWeight: pw.FontWeight.bold,
//           ),
//         ),
//       );
//     }
//
//     reusableTitle({required String text}) {
//       return pw.Text(
//         text,
//         style: pw.TextStyle(
//           color: PdfColors.black,
//           fontSize: 12,
//           fontWeight: pw.FontWeight.bold,
//         ),
//       );
//     }
//
//     reusableShowInfoCard({required double width, required String text}) {
//       return pw.Container(
//         width: width,
//         padding: const pw.EdgeInsets.symmetric(horizontal: 2),
//         child: pw.Center(
//           child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
//         ),
//       );
//     }
//
//     reusableItemRowInSalesOrder({
//       required Map salesOrderItemInfo,
//       required int index,
//     }) {
//       return pw.Container(
//         margin: const pw.EdgeInsets.symmetric(vertical: 3),
//         child: pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
//           children: [
//             // reusableShowInfoCard(
//             //     text:
//             //
//             //     quotationController.itemsNames[ salesOrderItemInfo['item_id'] ]
//             //     ,
//             //     width: width * 0.05),
//             reusableShowInfoCard(
//               text: '${salesOrderItemInfo['item_id'] ?? ''}',
//               width: width * 0.05,
//             ),
//             reusableShowInfoCard(
//               text: '${salesOrderItemInfo['item_description'] ?? ''}',
//               width: width * 0.05,
//             ),
//             reusableShowInfoCard(
//               text: '${salesOrderItemInfo['item_quantity'] ?? ''}',
//               width: width * 0.04,
//             ),
//             reusableShowInfoCard(
//               text: '${salesOrderItemInfo['item_unit_price'] ?? ''}',
//               width: width * 0.04,
//             ),
//             reusableShowInfoCard(
//               text: '${salesOrderItemInfo['item_discount'] ?? '0'}',
//               width: width * 0.04,
//             ),
//             reusableShowInfoCard(
//               text: '${salesOrderItemInfo['item_total'] ?? ''}',
//               width: width * 0.04,
//             ),
//           ],
//         ),
//       );
//     }
//
//     reusableText(String text) {
//       return pw.Text(text, style: const pw.TextStyle(fontSize: 9));
//     }
//
//     pdf.addPage(
//       pw.MultiPage(
//         margin: const pw.EdgeInsets.all(10),
//         build: (context) {
//           return [
//             pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.start,
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 reusableTitle(
//                   text:
//                   ' Quotation '
//                       '${widget.salesOrderNumber}',
//
//                   // '${widget.ref!=''?'/${widget.ref}':''}'
//                 ),
//                 gapH10,
//                 reusableText('${'status'.tr}: ${widget.status}'),
//                 pw.Row(
//                   crossAxisAlignment: pw.CrossAxisAlignment.end,
//                   children: [
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         gapH4,
//                         reusableText(
//                           '${'quotation_date'.tr}: ${widget.creationDate}',
//                         ),
//                         gapH4,
//                         reusableText(
//                           '${'sender_user'.tr}: ${widget.senderUser}',
//                         ),
//                         gapH4,
//                       ],
//                     ),
//                     gapW20,
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       mainAxisAlignment: pw.MainAxisAlignment.end,
//                       children: [
//                         gapH4,
//                         reusableText(
//                           widget.receivedUser != ''
//                               ? '${'receiver_user'.tr}: ${widget.receivedUser}'
//                               : '',
//                         ),
//                         gapH4,
//                       ],
//                     ),
//                   ],
//                 ),
//                 gapH10,
//                 pw.Divider(
//                   color: PdfColors.black,
//                   // endIndent: 250
//                 ),
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
//                   children: [
//                     tableTitle(text: 'item_code'.tr, width: width * 0.05),
//                     tableTitle(text: 'description'.tr, width: width * 0.05),
//                     tableTitle(text: 'quantity'.tr, width: width * 0.04),
//                     tableTitle(text: 'unit_price'.tr, width: width * 0.04),
//                     tableTitle(text: '${'disc'.tr}. %', width: width * 0.04),
//                     tableTitle(text: 'total'.tr, width: width * 0.04),
//                   ],
//                 ),
//                 gapH4,
//                 pw.Divider(
//                   color: PdfColors.black,
//                   // endIndent: 250
//                 ),
//                 pw.ListView.builder(
//                   padding: const pw.EdgeInsets.symmetric(vertical: 10),
//                   itemCount:
//                   widget
//                       .rowsInListViewInQuotation
//                       .length, //products is data from back res
//
//                   itemBuilder:
//                       (context, index) => reusableItemRowInSalesOrder(
//                     salesOrderItemInfo:
//                     widget.rowsInListViewInQuotation[index],
//                     index: index,
//                   ),
//                 ),
//               ],
//             ),
//           ];
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
// }
