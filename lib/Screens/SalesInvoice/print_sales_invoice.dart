import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:rooster_app/Controllers/sales_invoice_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/const/Delta/convert_from_delta_to_pw_widget.dart';
import '../../../const/colors.dart';
import '../../Controllers/exchange_rates_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/page_title.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../const/Sizes.dart';
import '../../const/functions.dart';

class PrintSalesInvoice extends StatefulWidget {
  const PrintSalesInvoice({
    super.key,
    required this.quotationNumber,
    required this.salesOrderNumber,
    required this.salesInvoiceNumber,
    required this.ref,
    required this.creationDate,
    required this.receivedUser,
    required this.senderUser,
    required this.status,
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

    required this.totalPriceAfterSpecialDiscountBySalesInvoiceCurrency,
    required this.vatBySalesInvoiceCurrency,
    required this.finalPriceBySalesInvoiceCurrency,
    required this.salesPerson,
    required this.salesInvoiceCurrency,
    required this.salesInvoiceCurrencySymbol,
    required this.salesInvoiceCurrencyLatestRate,
    required this.clientPhoneNumber,
    required this.clientName,
    required this.termsAndConditions,
    required this.itemsInfoPrint,
    this.isInSalesInvoice = false,
    required this.isPrintedAsVatExempt,
    required this.isPrintedAs0,
    required this.isVatNoPrinted,
  });

  final String quotationNumber;
  final String salesOrderNumber;
  final String salesInvoiceNumber;
  final String ref;
  final String creationDate;
  final String receivedUser;
  final String senderUser;
  final String status;
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
  final String totalPriceAfterSpecialDiscountBySalesInvoiceCurrency;
  final String vatBySalesInvoiceCurrency;
  final String finalPriceBySalesInvoiceCurrency;

  final String salesPerson;
  final String salesInvoiceCurrency;
  final String salesInvoiceCurrencySymbol;
  final String salesInvoiceCurrencyLatestRate;
  final String clientPhoneNumber;
  final String clientName;
  final String termsAndConditions;
  final bool isInSalesInvoice;
  final List itemsInfoPrint;
  final bool isPrintedAsVatExempt;
  final bool isPrintedAs0;
  final bool isVatNoPrinted;

  @override
  State<PrintSalesInvoice> createState() => _PrintSalesInvoiceState();
}

class _PrintSalesInvoiceState extends State<PrintSalesInvoice> {
  bool isHomeHovered = false;
  final SalesInvoiceController salesInvoiceController = Get.find();
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
        widget.salesInvoiceCurrencyLatestRate.isEmpty
            ? '1'
            : widget.salesInvoiceCurrencyLatestRate,
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
                        if (salesInvoiceController.isSubmitAndPreviewClicked) {
                          salesInvoiceController.getAllSalesInvoiceFromBack();
                          Get.back();
                          homeController.selectedTab.value =
                              'sales_invoice_summary';
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
                    const PageTitle(text: 'Sales Invoice'),
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
                      homeController.selectedTab.value =
                          'sales_invoice_summary';
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            SizedBox(
              width: Sizes.deviceWidth * 0.8,
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
    // await preFetchImages(salesInvoiceController.itemList);
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    double width = MediaQuery.of(context).size.width;
    var gapW20 = pw.SizedBox(width: 20);
    var gapW180 = pw.SizedBox(width: 180);
    var gapH4 = pw.SizedBox(height: 4);
    var gapH2 = pw.SizedBox(height: 2);
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
            fontSize: 7,
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
            style: pw.TextStyle(fontSize: 7, font: arabicFont),
          ),
        ),
      );
    }

    reusableItemRowInSalesInvoice({
      required Map salesInvoiceItemInfo,
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
                gapH4,
                reusableShowInfoCard(
                  text:
                      salesInvoiceItemInfo['item_brand'] != ''
                          ? salesInvoiceItemInfo['item_brand']
                          : '---',
                  width: width * 0.05,
                ),

                gapH4,
                if (imageProvider != null)
                  pw.Image(
                    imageProvider,
                    fit: pw.BoxFit.contain,
                    width: 50,
                    height: 50,
                  ),
              ],
            ),
            reusableShowInfoCard(
              text: '${salesInvoiceItemInfo['item_name'] ?? ''}',
              width: width * 0.07,
            ),
            reusableShowInfoCard(
              text: '${salesInvoiceItemInfo['item_description'] ?? ''}',
              width: width * 0.08,
            ),
            reusableShowInfoCard(
              text: '${salesInvoiceItemInfo['item_quantity'] ?? ''}',
              width: width * 0.03,
            ),
            reusableShowInfoCard(
              text:
              // '${salesInvoiceItemInfo['item_unit_price'] ?? ''}',
              numberWithComma(
                double.parse(
                  '${double.parse('${salesInvoiceItemInfo['item_unit_price']}'.replaceAll(',', ''))}',
                  // '${double.parse('${salesInvoiceItemInfo['item_unit_price']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
                ).toStringAsFixed(2),
              ),
              width: width * 0.04,
            ),
            reusableShowInfoCard(
              text: '${salesInvoiceItemInfo['item_discount'] ?? '0'}',
              width: width * 0.02,
            ),
            reusableShowInfoCard(
              text:
              // '${quotationItemIn
              // fo['item_total'] ?? ''}',
              numberWithComma(
                double.parse(
                  '${double.parse('${salesInvoiceItemInfo['item_total']}'.replaceAll(',', ''))}',
                  // '${double.parse('${salesInvoiceItemInfo['item_total']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
                ).toStringAsFixed(2),
              ),
              width: width * 0.04,
            ),
          ],
        ),
      );
    }

    reusableRowInSalesInvoice({
      required Map salesInvoiceItemInfo,
      required int index,
      required pw.ImageProvider? imageProvider,
    }) {
      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child:
            salesInvoiceItemInfo['line_type_id'] == '3'
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Column(
                      children: [
                        gapH4,
                        reusableShowInfoCard(
                          text:
                              salesInvoiceItemInfo['combo_brand'] != ''
                                  ? salesInvoiceItemInfo['combo_brand']
                                  : '---',
                          width: width * 0.05,
                        ),

                        gapH4,
                        if (imageProvider != null)
                          pw.Image(
                            imageProvider,
                            fit: pw.BoxFit.contain,
                            width: 50,
                            height: 50,
                          ),
                      ],
                    ),
                    reusableShowInfoCard(
                      text: '${salesInvoiceItemInfo['item_name'] ?? ''}',
                      width: width * 0.07,
                    ),
                    reusableShowInfoCard(
                      text: '${salesInvoiceItemInfo['item_description'] ?? ''}',
                      width: width * 0.08,
                    ),
                    reusableShowInfoCard(
                      text: '${salesInvoiceItemInfo['item_quantity'] ?? ''}',
                      width: width * 0.03,
                    ),
                    reusableShowInfoCard(
                      text:
                      // '${salesInvoiceItemInfo['item_unit_price'] ?? ''}',
                      numberWithComma(
                        double.parse(
                          '${double.parse('${salesInvoiceItemInfo['item_unit_price']}'.replaceAll(',', ''))}',
                          // '${double.parse('${salesInvoiceItemInfo['item_unit_price']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
                        ).toStringAsFixed(2),
                      ),
                      width: width * 0.04,
                    ),
                    reusableShowInfoCard(
                      text: '${salesInvoiceItemInfo['item_discount'] ?? '0'}',
                      width: width * 0.02,
                    ),
                    reusableShowInfoCard(
                      text:
                      // '${quotationItemIn
                      // fo['item_total'] ?? ''}',
                      numberWithComma(
                        double.parse(
                          '${double.parse('${salesInvoiceItemInfo['item_total']}'.replaceAll(',', ''))}',
                          // '${double.parse('${salesInvoiceItemInfo['item_total']}'.replaceAll(',', '')) / double.parse(finallyRate)}',
                        ).toStringAsFixed(2),
                      ),
                      width: width * 0.04,
                    ),
                  ],
                )
                : salesInvoiceItemInfo['line_type_id'] == '1'
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Container(
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
                            '${salesInvoiceItemInfo['title'] ?? ''}',
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
                : salesInvoiceItemInfo['line_type_id'] == '5'
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 10),
                      width: width * 0.35,
                      child: pw.Text(
                        'Note : ${salesInvoiceItemInfo['note'] ?? ''}',
                        style: pw.TextStyle(
                          fontSize: 7,
                          font: italicRobotoFont,
                        ),
                      ),
                    ),
                  ],
                )
                : pw.SizedBox(),
      );
    }

    reusableUrlImageRowInSalesInvoice({
      required Map salesInvoiceItemInfo,
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

    reusableImageRowInSalesInvoice({
      required Map salesInvoiceItemInfo,
      required int index,
    }) {
      final image = pw.MemoryImage(salesInvoiceItemInfo['image']);

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
      return pw.Text(text, style: pw.TextStyle(fontSize: 7));
    }

    reusableNumber(String text) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [pw.Text(text, style: pw.TextStyle(fontSize: 7))],
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
      salesInvoiceController.logoBytes,
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
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: <pw.Widget>[
                                pw.Container(
                                  width: 180, // Set the desired width
                                  height: 70, // Set the desired height
                                  child: pw.Image(image),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(
                        width: width * 0.125,
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
                        width: width * 0.1,
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
                pw.Padding(
                  padding: pw.EdgeInsets.fromLTRB(10, 20, 0, 0),
                  child: pw.Row(
                    // crossAxisAlignment: pw.CrossAxisAlignment.end,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // pw.SizedBox(
                      //   width: width * 0.1,
                      //   child: pw.Row(
                      //     mainAxisAlignment: pw.MainAxisAlignment.start,
                      //     children: [
                      //       pw.Column(
                      //         crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //         children: [
                      //           pw.Text(
                      //             'sales_invoice'.tr,
                      //             style: pw.TextStyle(
                      //               fontSize: 12,
                      //               fontWeight: pw.FontWeight.bold,
                      //               color: PdfColors.black,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
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
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.normal,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,
                                pw.Text(
                                  '${'telephone'.tr}:',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.normal,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,
                                pw.Text(
                                  '${'address'.tr}:',
                                  style: pw.TextStyle(
                                    fontSize: 7,
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
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.normal,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,
                                pw.Text(
                                  '${'sales_person'.tr}:',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.normal,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,
                                pw.Text(
                                  '${'date'.tr}:',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.normal,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,
                                pw.Text(
                                  '${'currency'.tr}:',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.normal,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,
                              ],
                            ),
                            gapW20,
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                reusableText(widget.salesInvoiceNumber),
                                gapH4,
                                reusableText(
                                  widget.salesPerson.isEmpty
                                      ? '---'
                                      : widget.salesPerson,
                                ),
                                gapH5,
                                reusableText(widget.creationDate),
                                gapH5,
                                reusableText(widget.salesInvoiceCurrency),
                                gapH5,
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
                            text:
                                'Sales Invoice [${widget.salesInvoiceNumber}] ',
                            width: width * 0.06,
                          ),
                          widget.salesOrderNumber == ''
                              ? tableTitleForSequence(
                                text: 'is New Sales Invoice',
                                width: width * 0.06,
                              )
                              : pw.Row(
                                children: [
                                  tableTitleForSequence(
                                    text:
                                        'is Sales Order [${widget.salesOrderNumber}]',
                                    width: width * 0.06,
                                  ),
                                  widget.quotationNumber == ''
                                      ? tableTitleForSequence(
                                        text:
                                            ', This Sales Order is New Sales Order',
                                        width: width * 0.09,
                                      )
                                      : tableTitleForSequence(
                                        text:
                                            ', This Sales Order is Quotation [${widget.quotationNumber}]',
                                        width: width * 0.10,
                                      ),
                                ],
                              ),
                        ],
                      ),

                      gapH2,
                      widget.salesOrderNumber == ''
                          ? pw.SizedBox(
                            width: width * 0.22,
                            child: pw.Divider(
                              height: 5,
                              color: PdfColors.black,
                              // endIndent: 250
                            ),
                          )
                          : pw.SizedBox(
                            width: width * 0.18,
                            child: pw.Divider(
                              height: 5,
                              color: PdfColors.black,
                              // endIndent: 250
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
                            width: width * 0.08,
                          ),
                          tableTitle(text: 'qty'.tr, width: width * 0.03),
                          tableTitle(
                            text: 'unit_price'.tr,
                            width: width * 0.04,
                          ),
                          tableTitle(
                            text: '${'disc'.tr}%',
                            width: width * 0.02,
                          ),
                          tableTitle(
                            text: 'Total (${widget.salesInvoiceCurrency})',
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
                        itemBuilder: (context, index) {
                          final item = widget.itemsInfoPrint[index];
                          return item['line_type_id'] == '2'
                              ? reusableItemRowInSalesInvoice(
                                salesInvoiceItemInfo: item,
                                index: index,
                                imageProvider:
                                    imageProviders[item['item_image']], // Pass the pre-fetched ImageProvider
                                // width: width,
                              )
                              : item['line_type_id'] == '4' &&
                                  item['isImageList']
                              ? reusableImageRowInSalesInvoice(
                                salesInvoiceItemInfo: item,
                                index: index,
                              )
                              : item['line_type_id'] == '4' &&
                                  !item['isImageList']
                              ? reusableUrlImageRowInSalesInvoice(
                                salesInvoiceItemInfo: item,
                                index: index,
                                imageProvider: imageProviders[item['image']],
                              )
                              : reusableRowInSalesInvoice(
                                salesInvoiceItemInfo: item,
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
                  width: width * 0.365,
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
                                width: width * 0.245,
                                child: reusableText('total_price'.tr),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.05,
                                child: reusableNumber(
                                  widget.salesInvoiceCurrency,
                                ),
                                // child: reusableText(primaryCurrency),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.05,
                                child: reusableNumber(
                                  // widget.totalAllItems,
                                  numberWithComma(
                                    double.parse(
                                      '${double.parse(widget.totalAllItems.replaceAll(',', ''))}',
                                      // '${double.parse(widget.totalAllItems.replaceAll(',', '')) / double.parse(finallyRate)}',
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
                      widget.globalDiscount == '0.00' ||
                              widget.globalDiscount == '0'
                          ? pw.Text("")
                          : pw.Row(
                            children: [
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: width * 0.245,
                                    child: reusableText('dis_count'.tr),
                                  ),
                                ],
                              ),

                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: width * 0.05,
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
                                    width: width * 0.05,
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
                            children: [
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: width * 0.245,
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
                                    width: width * 0.05,
                                    child: reusableNumber(
                                      widget.salesInvoiceCurrency,
                                    ),
                                    // child: reusableText(primaryCurrency),
                                  ),
                                ],
                              ),
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: width * 0.05,
                                    child: reusableNumber(
                                      // '$totalPriceAfterDiscount',
                                      // widget.totalPriceAfterDiscount,
                                      numberWithComma(
                                        double.parse(
                                          '${double.parse(widget.totalPriceAfterDiscount.replaceAll(',', ''))}',
                                          // '${double.parse(widget.totalPriceAfterDiscount.replaceAll(',', '')) / double.parse(finallyRate)}',
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
                            children: [
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: width * 0.245,
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
                                    width: width * 0.05,
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
                                    width: width * 0.05,
                                    child: reusableNumber(
                                      // '${additionalSpecialDiscount.toStringAsFixed(2)}',
                                      widget.additionalSpecialDiscount,
                                      // style: pw.TextStyle(
                                      //   fontSize: 7,
                                      //   color: PdfColors.black,
                                      // ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      primaryCurrency == widget.salesInvoiceCurrency
                          ? pw.SizedBox.shrink()
                          : pw.Divider(
                            height: 5,
                            color: PdfColors.black,
                            // endIndent: 250
                          ),

                      // TOTAL PRICE AFTER SPECIAL DISCOUNT
                      if (primaryCurrency != widget.salesInvoiceCurrency)
                        pw.Row(
                          children: [
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  width: width * 0.245,
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
                                  width: width * 0.05,
                                  child: reusableNumber(
                                    widget.salesInvoiceCurrency,
                                  ),
                                  // child: reusableText(primaryCurrency),
                                ),
                              ],
                            ),
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  width: width * 0.05,
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
                      widget.isPrintedAsVatExempt
                          ? pw.Text("")
                          : pw.Row(
                            children: [
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: width * 0.245,
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
                                    width: width * 0.05,
                                    child:
                                        companyVat.isNotEmpty &&
                                                !widget.isPrintedAs0
                                            ? reusableNumber(
                                              widget.isVatNoPrinted ||
                                                      widget
                                                          .isPrintedAsVatExempt
                                                  ? ' '
                                                  : '$companyVat%',
                                            )
                                            : reusableNumber(' 0 %'),
                                  ),
                                ],
                              ),
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: width * 0.05,
                                    child: reusableNumber(
                                      widget.isVatNoPrinted ||
                                              widget.isPrintedAsVatExempt
                                          ? ' '
                                          : widget.vatBySalesInvoiceCurrency,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      widget.isVatNoPrinted
                          ? pw.SizedBox()
                          : widget.isPrintedAsVatExempt
                          ? pw.Text("")
                          : pw.Divider(
                            height: 5,
                            color: PdfColors.black,
                            // endIndent: 250
                          ),
                      // FINAL PRICE INCL. VAT
                      widget.isPrintedAsVatExempt
                          ? pw.Text("")
                          : pw.Row(
                            children: [
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: width * 0.245,

                                    child: pw.Text(
                                      'final_price_incl_vat'.tr,
                                      style: pw.TextStyle(
                                        fontSize: 7,
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
                                    width: width * 0.05,
                                    child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          widget.salesInvoiceCurrency,
                                          style: pw.TextStyle(
                                            fontSize: 7,
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
                                    width: width * 0.05,
                                    child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                          widget
                                              .finalPriceBySalesInvoiceCurrency,
                                          style: pw.TextStyle(
                                            fontSize: 7,
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

                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                      gapH6,
                      pw.Row(
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.245,
                                child: reusableText('final_price_incl_vat'.tr),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.05,
                                child: reusableNumber(primaryCurrency),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.05,
                                child: reusableNumber(
                                  widget.finalPriceBySalesInvoiceCurrency == '0'
                                      ? '0.00'
                                      : numberWithComma(
                                        '${roundUp(double.parse(widget.finalPriceBySalesInvoiceCurrency.replaceAll(',', '')) / double.parse(finallyRate), 2)}',
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
                                      child: pw.Image(image), //to be use again
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

// class PrintQuotations extends StatefulWidget {
//   const PrintQuotations({
//     super.key,
//     required this.salesInvoiceNumber,
//     required this.ref,
//     required this.rowsInListViewInQuotation,
//     required this.creationDate,
//     required this.receivedUser,
//     required this.senderUser,
//     required this.status,
//     this.isInSalesInvoice = false,
//   });
//
//   final String salesInvoiceNumber;
//   final String ref;
//   final String creationDate;
//   final String receivedUser;
//   final String senderUser;
//   final String status;
//   final bool isInSalesInvoice;
//   final List rowsInListViewInQuotation;
//
//   @override
//   State<PrintQuotations> createState() => _PrintQuotationsState();
// }
//
// class _PrintQuotationsState extends State<PrintQuotations> {
//   bool isHomeHovered = false;
//   final salesInvoiceController salesInvoiceController = Get.find();
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
//                         if (salesInvoiceController.isSubmitAndPreviewClicked) {
//                           salesInvoiceController.getAllQuotationsFromBack();
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
//     reusableItemRowInSalesInvoice({
//       required Map salesInvoiceItemInfo,
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
//             //     salesInvoiceController.itemsNames[ salesInvoiceItemInfo['item_id'] ]
//             //     ,
//             //     width: width * 0.05),
//             reusableShowInfoCard(
//               text: '${salesInvoiceItemInfo['item_id'] ?? ''}',
//               width: width * 0.05,
//             ),
//             reusableShowInfoCard(
//               text: '${salesInvoiceItemInfo['item_description'] ?? ''}',
//               width: width * 0.05,
//             ),
//             reusableShowInfoCard(
//               text: '${salesInvoiceItemInfo['item_quantity'] ?? ''}',
//               width: width * 0.04,
//             ),
//             reusableShowInfoCard(
//               text: '${salesInvoiceItemInfo['item_unit_price'] ?? ''}',
//               width: width * 0.04,
//             ),
//             reusableShowInfoCard(
//               text: '${salesInvoiceItemInfo['item_discount'] ?? '0'}',
//               width: width * 0.04,
//             ),
//             reusableShowInfoCard(
//               text: '${salesInvoiceItemInfo['item_total'] ?? ''}',
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
//                       '${widget.salesInvoiceNumber}',
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
//                       (context, index) => reusableItemRowInSalesInvoice(
//                     salesInvoiceItemInfo:
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
