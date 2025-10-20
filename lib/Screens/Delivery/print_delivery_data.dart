import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:rooster_app/Controllers/delivery_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import '../../../const/colors.dart';
import '../../Controllers/exchange_rates_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/page_title.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../const/Sizes.dart';

class PrintDeliveryData extends StatefulWidget {
  const PrintDeliveryData({
    super.key,
    required this.deliveryNumber,

    required this.salesPerson,
    required this.creationDate,
    required this.expectedDate,
    required this.receivedUser,
    required this.senderUser,
    required this.clientPhoneNumber,
    required this.clientMobileNumber,
    required this.clientName,
    required this.clientAddress,
    required this.total,
    required this.itemsInfoPrint,
    this.isInDelivery = false,
  });

  final String deliveryNumber;

  final String salesPerson;
  final String creationDate;
  final String expectedDate;
  final String receivedUser;
  final String senderUser;
  final String clientPhoneNumber;
  final String clientMobileNumber;
  final String clientName;
  final String clientAddress;
  final String total;
  final List itemsInfoPrint;
  final bool isInDelivery;

  @override
  State<PrintDeliveryData> createState() => _PrintDeliveryDataState();
}

class _PrintDeliveryDataState extends State<PrintDeliveryData> {
  bool isHomeHovered = false;
  final DeliveryController deliveryController = Get.find();
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
                        if (deliveryController.isSubmitAndPreviewClicked) {
                          deliveryController.getAllDeliveryFromBack();
                          Get.back();
                          homeController.selectedTab.value = 'delivery_summary';
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
                    const PageTitle(text: 'Delivery'),
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
                      homeController.selectedTab.value = 'delivery_summary';
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
                pdfFileName: '${widget.clientName} [${widget.deliveryNumber}]',
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
    // 000
    // await preFetchImages(deliveryController.itemList);
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    double width = MediaQuery.of(context).size.width;
    var gapW20 = pw.SizedBox(width: 20);
    var gapW16 = pw.SizedBox(width: 16);
    var gapW180 = pw.SizedBox(width: 180);
    var gapH4 = pw.SizedBox(height: 4);
    var gapH30 = pw.SizedBox(height: 30);

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
                  width: width * 0.08,
                ),
                reusableShowInfoCard(
                  text: '${quotationItemInfo['item_quantity'] ?? ''}',
                  width: width * 0.03,
                ),
                reusableShowInfoCard(
                  text: '${quotationItemInfo['item_warehouse'] ?? ''}',
                  width: width * 0.03,
                ),
              ],
            ),
            gapH4,
            gapH4,
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.SizedBox(width: 50),
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

    reusableRowInDeliveries({
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
                          text:
                              quotationItemInfo['combo_brand'] != ''
                                  ? quotationItemInfo['combo_brand']
                                  : '---',
                          width: width * 0.05,
                        ),

                        reusableShowInfoCard(
                          text: '${quotationItemInfo['item_name'] ?? ''}',
                          width: width * 0.07,
                        ),
                        reusableShowInfoCard(
                          text:
                              '${quotationItemInfo['item_description'] ?? ''}',
                          width: width * 0.08,
                        ),
                        reusableShowInfoCard(
                          text: '${quotationItemInfo['item_quantity'] ?? ''}',
                          width: width * 0.03,
                        ),
                        reusableShowInfoCard(
                          text: '${quotationItemInfo['combo_warehouse'] ?? ''}',
                          width: width * 0.03,
                        ),
                      ],
                    ),
                    gapH4,
                    gapH4,
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.SizedBox(width: 50),
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                : quotationItemInfo['line_type_id'] == '1'
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 10),
                      width: width * 0.35,
                      child: pw.Column(
                        children: [
                          // pw.Divider(
                          //   height: 5,
                          //   color: PdfColors.black,
                          //   // endIndent: 250
                          // ),
                          // gapH4,
                          pw.Text(
                            '${quotationItemInfo['title'] ?? ''}',
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
                : quotationItemInfo['line_type_id'] == '5'
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 10),
                      width: width * 0.35,
                      child: pw.Text(
                        'Note : ${quotationItemInfo['note'] ?? ''}',
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
            height: 150,
          ),
        ),
      );
    }

    reusableImageRowInDeliveries({
      required Map quotationItemInfo,
      required int index,
    }) {
      // final pdf = pw.Document();
      final image = pw.MemoryImage(quotationItemInfo['image']);

      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Center(
          child: pw.Image(
            image,
            fit: pw.BoxFit.contain,
            // width: 50,
            height: 120,
            // height: 150,
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
      deliveryController.logoBytes,
    ); //to be use again

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
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
            pw.Padding(
              padding: pw.EdgeInsets.fromLTRB(10, 20, 0, 0),
              child: pw.Row(
                // crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    // width: width * 0.1,
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

                            // gapH4,

                            // gapH4,
                            // primaryCurrency != widget.deliveryCurrency
                            //     ? pw.Text(
                            //       '${'$primaryCurrency/${widget.deliveryCurrency} rate'.tr}:',
                            //       style: pw.TextStyle(
                            //         fontSize: 9.sp,
                            //         fontWeight: pw.FontWeight.normal,
                            //         color: PdfColors.black,
                            //       ),
                            //     )
                            //     : pw.SizedBox(),
                          ],
                        ),
                        // gapW20,
                        gapW16,
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            reusableText(widget.deliveryNumber),
                            gapH4,
                            reusableText(
                              widget.salesPerson.isEmpty
                                  ? '---'
                                  : widget.salesPerson,
                            ),
                            gapH4,
                            reusableText(widget.creationDate),
                            // gapH5,
                            // reusableText(widget.salesOrderCurrency),
                            // gapH5,
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
                        text: 'Delivery',
                        width: width * 0.07,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            gapH30,
            //////////////////////////////////////////////////////////////
            // orderLine quotation table
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                tableTitle(text: 'brand'.tr, width: width * 0.05),
                tableTitle(text: 'item_'.tr, width: width * 0.07),
                tableTitle(text: 'description'.tr, width: width * 0.08),
                tableTitle(text: 'qty'.tr, width: width * 0.03),
                tableTitle(text: 'warehouse'.tr, width: width * 0.04),
                // tableTitle(
                //   text: '${'expected_delivery_date'.tr}%',
                //   width: width * 0.04,
                // ),
                // tableTitle(
                //   text: 'Total ($primaryCurrency)'.tr,
                //   width: width * 0.04,
                // ),
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
                          imageProvider:
                              imageProviders[item['item_image']], // Pass the pre-fetched ImageProvider
                          // width: width,
                        )
                        : item['line_type_id'] == '4' && item['isImageList']
                        ? reusableImageRowInDeliveries(
                          quotationItemInfo: item,
                          index: index,
                        )
                        : item['line_type_id'] == '4' && !item['isImageList']
                        ? reusableUrlImageRowInQuotations(
                          quotationItemInfo: item,
                          index: index,
                          imageProvider: imageProviders[item['image']],
                        )
                        : reusableRowInDeliveries(
                          quotationItemInfo: item,
                          index: index,
                          imageProvider: imageProviders[item['combo_image']],
                        );
                  }).toList(),
            ),

            //////////////////////////////////////////////////////////////
            // total quotation
            // column row column
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
              // width: width * 0.365,
              height: 150.h,
              // height: 300,
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
                            child: reusableText('total_quantity'.tr),
                          ),
                        ],
                      ),

                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 135.w,
                            // width: width * 0.075,
                            child: pw.Text(''),
                            // child: reusableText(primaryCurrency),
                          ),
                        ],
                      ),
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 80.w,
                            // width: width * 0.055,
                            child: pw.Text(
                              widget.total,

                              style: pw.TextStyle(
                                fontSize: 9.sp,
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
