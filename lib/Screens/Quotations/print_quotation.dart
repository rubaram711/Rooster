import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import '../../../const/colors.dart';
import '../../Controllers/exchange_rates_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/page_title.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../const/Sizes.dart';
import '../../const/functions.dart';

class PrintQuotationData extends StatefulWidget {
  const PrintQuotationData({
    super.key,
    required this.quotationNumber,
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

    required this.totalPriceAfterSpecialDiscountByQuotationCurrency,
    required this.vatByQuotationCurrency,
    required this.finalPriceByQuotationCurrency,
    required this.salesPerson,
    required this.quotationCurrency,
    required this.quotationCurrencySymbol,
    required this.quotationCurrencyLatestRate,
    required this.clientPhoneNumber,
    required this.clientName,
    required this.termsAndConditions,
    required this.itemsInfoPrint,
    this.isInQuotation = false,
    required this.isPrintedAsVatExempt,
    required this.isPrintedAs0,
    required this.isVatNoPrinted,
  });

  final String quotationNumber;
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
  final String totalPriceAfterSpecialDiscountByQuotationCurrency;
  final String vatByQuotationCurrency;
  final String finalPriceByQuotationCurrency;

  final String salesPerson;
  final String quotationCurrency;
  final String quotationCurrencySymbol;
  final String quotationCurrencyLatestRate;
  final String clientPhoneNumber;
  final String clientName;
  final String termsAndConditions;
  final bool isInQuotation;
  final List itemsInfoPrint;
  final bool isPrintedAsVatExempt;
  final bool isPrintedAs0;
  final bool isVatNoPrinted;

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
                          quotationController.getAllQuotationsFromBack();
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
      if(item['line_type_id']=='2'){
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
      }else if(!item['isImageList']){
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
    }
    // await preFetchImages(quotationController.itemList);
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    double width = MediaQuery.of(context).size.width;
    var gapW20 = pw.SizedBox(width: 20);
    var gapW180 = pw.SizedBox(width: 180);
    var gapH4 = pw.SizedBox(height: 4);
    var gapH6 = pw.SizedBox(height: 6);
    final font = await rootBundle.load('assets/fonts/Tajawal-Medium.ttf');
    final arabicFont = pw.Font.ttf(font);
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
          child: pw.Text(text, style:  pw.TextStyle(fontSize: 7,font: arabicFont)),
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
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            pw.Column(
              children: [
                reusableShowInfoCard(
                  text:
                      quotationItemInfo['item_brand'] != ''
                          ? quotationItemInfo['item_brand']
                          : '---',
                  width: width * 0.05,
                ),
                gapH4,
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
              text: '${quotationItemInfo['item_name'] ?? ''}',
              width: width * 0.05,
            ),
            reusableShowInfoCard(
              text: '${quotationItemInfo['item_description'] ?? ''}',
              width: width * 0.06,
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
            reusableShowInfoCard(
              text: '${quotationItemInfo['item_discount'] ?? '0'}',
              width: width * 0.04,
            ),
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
      );
    }

    reusableRowInQuotations({
      required Map quotationItemInfo,
      required int index,
    }) {
      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child:
            quotationItemInfo['line_type_id'] == '3'
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    reusableShowInfoCard(text: '---', width: width * 0.05),
                    reusableShowInfoCard(
                      text: '${quotationItemInfo['item_name'] ?? ''}',
                      width: width * 0.05,
                    ),
                    reusableShowInfoCard(
                      text: '${quotationItemInfo['item_description'] ?? ''}',
                      width: width * 0.06,
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
                    reusableShowInfoCard(
                      text: '${quotationItemInfo['item_discount'] ?? '0'}',
                      width: width * 0.04,
                    ),
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
                )
                : quotationItemInfo['line_type_id'] == '1'
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 10),
                      width: width * 0.35,
                      child: pw.Text(
                        '${quotationItemInfo['title'] ?? ''}',
                        style:  pw.TextStyle(fontSize: 7,font: arabicFont),
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
                        '${quotationItemInfo['note'] ?? ''}',
                        style:  pw.TextStyle(fontSize: 7,font: arabicFont),
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
    })
     {
      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Center(child: pw.Image(imageProvider!,fit: pw.BoxFit.contain,
          // width: 50,
          height: 150,)),
      );
    }

    reusableImageRowInQuotations({
      required Map quotationItemInfo,
      required int index,
    }) {
      final pdf = pw.Document();
      final image = pw.MemoryImage(quotationItemInfo['image']);

      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Center(child: pw.Image(image)),
      );
    }

    reusableText(String text) {
      return pw.Text(text, style:  pw.TextStyle(fontSize: 7,font: arabicFont),);
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

    final image = pw.MemoryImage(quotationController.logoBytes);

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
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: <pw.Widget>[
                                pw.Container(
                                  width: 180, // Set the desired width
                                  height: 70, // Set the desired height
                                  child: pw.Image(image),

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
                                // gapH4,
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.fromLTRB(0, 4, 0, 0),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(
                        width: width * 0.15,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [reusableText(' ')],
                        ),
                      ),
                      pw.SizedBox(
                        width: width * 0.15,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [reusableText('')],
                        ),
                      ),

                      pw.SizedBox(
                        width: width * 0.1,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,

                          children: [reusableText(companyEmail)],
                        ),
                      ),
                    ],
                  ),
                ),
                //////////////////////////////////////////////////////////////
                // info quotation
                pw.Padding(
                  padding: pw.EdgeInsets.fromLTRB(10, 20, 0, 0),
                  child: pw.Row(
                    // crossAxisAlignment: pw.CrossAxisAlignment.end,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: width * 0.25,
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
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,
                                pw.Text(
                                  '${'sales_person'.tr}:',
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
                                gapH4,
                                pw.Text(
                                  '${'currency'.tr}:',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                ),
                                gapH4,
                                primaryCurrency != widget.quotationCurrency
                                    ? pw.Text(
                                      '${'$primaryCurrency/${widget.quotationCurrency} rate'.tr}:',
                                      style: pw.TextStyle(
                                        fontSize: 7,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.black,
                                      ),
                                    )
                                    : pw.SizedBox(),
                              ],
                            ),
                            gapW20,
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
                                gapH4,
                                reusableText(widget.creationDate),
                                gapH4,
                                reusableText(widget.quotationCurrency),
                                gapH4,
                                primaryCurrency != widget.quotationCurrency
                                    ? reusableText(
                                      '1 $primaryCurrencySymbol = ${numberWithComma(finallyRate)} ${widget.quotationCurrencySymbol}',
                                    )
                                    : pw.SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //////////////////////////////////////////////////////////////
                // orderLine quotation table
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
                          tableTitle(
                            text: '${'disc'.tr}%',
                            width: width * 0.04,
                          ),
                          tableTitle(
                            text: 'Total ($primaryCurrency)'.tr,
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
                              ? reusableItemRowInQuotations(
                                quotationItemInfo: item,
                                index: index,
                                imageProvider:
                                    imageProviders[item['item_image']], // Pass the pre-fetched ImageProvider
                                // width: width,
                              )
                              : item['line_type_id'] == '4' && item['isImageList']
                              ?reusableImageRowInQuotations(
                            quotationItemInfo: item,
                            index: index,
                          ):item['line_type_id'] == '4' && !item['isImageList']?reusableUrlImageRowInQuotations(
                            quotationItemInfo: item,
                            index: index,
                              imageProvider:
                              imageProviders[item['image']]
                          )

                              : reusableRowInQuotations(
                                quotationItemInfo: item,
                                index: index,
                              );
                        },
                      ),
                      // pw.ListView.builder(
                      //   padding: const pw.EdgeInsets.symmetric(vertical: 10),
                      //   itemCount:
                      //
                      //       quotationController
                      //           .itemList
                      //           .length, //products is data from back res
                      //   itemBuilder:
                      //       (context, index) =>
                      //       // buildQuotationListView(),
                      //           reusableItemRowInQuotations  (
                      //         quotationItemInfo:
                      //             quotationController.itemList[index],
                      //         index: index,
                      //         // img:  await fetchImage( quotationController.itemList[index]['images'][0]??[]),
                      //
                      //       ),
                      //
                      //   // itemBuilder: (context, index) {
                      //   //   var keys = quotationItemInfo.keys.toList();
                      //   //   return reusableItemRowInQuotations(
                      //   //     quotationItemInfo:
                      //   //     quotationItemInfo[keys[index]],
                      //   //     index: index,
                      //   //   );
                      //   // },
                      // ),
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
                                width: width * 0.25,
                                child: reusableText('total_price'.tr),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.05,
                                child: reusableText(widget.quotationCurrency),
                                // child: reusableText(primaryCurrency),
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
                                      '${double.parse(widget.totalAllItems.replaceAll(',', ''))}',
                                      // '${double.parse(widget.totalAllItems.replaceAll(',', '')) / double.parse(finallyRate)}',
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
                                width: width * 0.25,
                                child: reusableText('dis_count'.tr),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.05,
                                child: reusableText(
                                  '${widget.globalDiscount.isEmpty ? 0 : widget.globalDiscount}%',
                                ),
                              ),
                            ],
                          ),

                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.1,
                                // child: reusableText('$discountOnAllItem'),
                                child: reusableText(
                                  widget.discountOnAllItem == '0'
                                      ? '0.00'
                                      : widget.discountOnAllItem,
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
                      // TOTAL PRICE AFTER  DISCOUNT
                      pw.Row(
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.25,
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
                                child: reusableText(widget.quotationCurrency),
                                // child: reusableText(primaryCurrency),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.1,
                                child: pw.Text(
                                  // '$totalPriceAfterDiscount',
                                  // widget.totalPriceAfterDiscount,
                                  numberWithComma(
                                    double.parse(
                                      '${double.parse(widget.totalPriceAfterDiscount.replaceAll(',', ''))}',
                                      // '${double.parse(widget.totalPriceAfterDiscount.replaceAll(',', '')) / double.parse(finallyRate)}',
                                    ).toStringAsFixed(2),
                                  ),
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
                                width: width * 0.25,
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
                                child: reusableText(
                                  '${widget.specialDiscount.isEmpty ? 0 : widget.specialDiscount}%',
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.05,
                                child: pw.Text(
                                  // '${additionalSpecialDiscount.toStringAsFixed(2)}',
                                  widget.additionalSpecialDiscount,
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

                      // TOTAL PRICE AFTER SPECIAL DISCOUNT
                      if (primaryCurrency != widget.quotationCurrency)
                        pw.Row(
                          children: [
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  width: width * 0.25,
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
                                  child: reusableText(widget.quotationCurrency),
                                  // child: reusableText(primaryCurrency),
                                ),
                              ],
                            ),
                            pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  width: width * 0.1,
                                  child: pw.Text(
                                    // '${widget.specialDiscountAmount}',
                                    // widget.totalPriceAfterSpecialDiscount,
                                    numberWithComma(
                                      double.parse(
                                        '${double.parse(widget.totalPriceAfterSpecialDiscount.replaceAll(',', ''))}',
                                        // '${double.parse(widget.totalPriceAfterSpecialDiscount.replaceAll(',', '')) / double.parse(finallyRate)}',
                                      ).toStringAsFixed(2),
                                    ),
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
                      // if (primaryCurrency != widget.quotationCurrency)
                      //   pw.Divider(
                      //     height: 5,
                      //     color: PdfColors.black,
                      //     // endIndent: 250
                      //   ),
                      // TOTAL PRICE AFTER SPECIAL DISCOUNT
                      // pw.Row(
                      //   children: [
                      //     pw.Column(
                      //       mainAxisAlignment: pw.MainAxisAlignment.start,
                      //       children: [
                      //         pw.SizedBox(
                      //           width: width * 0.2,
                      //           child: reusableText(
                      //             'total_price_after_special_discount'.tr,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //
                      //     pw.Column(
                      //       mainAxisAlignment: pw.MainAxisAlignment.start,
                      //       children: [
                      //         pw.SizedBox(
                      //           width: width * 0.1,
                      //           child: pw.Text(
                      //             widget.quotationCurrency,
                      //             style: pw.TextStyle(
                      //               fontSize: 7,
                      //               color: PdfColors.black,
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     pw.Column(
                      //       mainAxisAlignment: pw.MainAxisAlignment.start,
                      //       children: [
                      //         pw.SizedBox(
                      //           width: width * 0.1,
                      //           child: pw.Text(
                      //             // '',
                      //             widget
                      //                 .totalPriceAfterSpecialDiscount,
                      //             // numberWithComma(
                      //             //   double.parse(
                      //             //     '${double.parse(widget.totalPriceAfterSpecialDiscount.replaceAll(',', '')) * double.parse(calculateRateCur1ToCur2(double.parse(primaryLatestRate), double.parse(widget.quotationCurrencyLatestRate)))}',
                      //             //   ).toStringAsFixed(2),
                      //             // ),
                      //             style: pw.TextStyle(
                      //               fontSize: 7,
                      //               color: PdfColors.black,
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ],
                      // ),
                      pw.Divider(
                        height: 5,
                        color: PdfColors.black,
                        // endIndent: 250
                      ),
                      //VAT
                      pw.Row(
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.25,
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
                                        ? pw.Text(
                                          widget.isVatNoPrinted ||
                                                  widget.isPrintedAsVatExempt
                                              ? ' '
                                              : '$companyVat%',
                                          style: pw.TextStyle(
                                            fontSize: 7,
                                            color: PdfColors.black,
                                          ),
                                        )
                                        : pw.Text(
                                          ' 0 %',
                                          style: pw.TextStyle(
                                            fontSize: 7,
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
                                  widget.isVatNoPrinted ||
                                          widget.isPrintedAsVatExempt
                                      ? ' '
                                      : widget.vatByQuotationCurrency,
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
                      widget.isVatNoPrinted
                          ? pw.SizedBox()
                          : pw.Divider(
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
                                width: width * 0.25,

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
                                width: width * 0.05,
                                child: pw.Text(
                                  widget.quotationCurrency,
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
                                  widget.finalPriceByQuotationCurrency,
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
                      gapH6,
                      pw.Row(
                        children: [
                          pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: width * 0.25,

                                child: pw.Text(
                                  'final_price_incl_vat'.tr,
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    // fontWeight: pw.FontWeight.bold,
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
                                child: pw.Text(
                                  primaryCurrency,
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    // fontWeight: pw.FontWeight.bold,
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
                                  widget.finalPriceByQuotationCurrency == '0'
                                      ? '0.00'
                                      : numberWithComma(
                                        '${roundUp(double.parse(widget.finalPriceByQuotationCurrency.replaceAll(',', '')) / double.parse(finallyRate), 2)}',
                                      ),
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    // fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
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
                                      child: pw.Image(image),
                                      // child: pw.Image(
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
                      if (widget.termsAndConditions != '')
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
                                    child: reusableText(
                                      widget.termsAndConditions,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                                  // reusableText(
                                  //   '${'Bank name'.tr}: ${widget.senderUser}',
                                  // ),
                                  // gapH4,
                                  // reusableText(
                                  //   '${'Account Name'.tr}: ${widget.senderUser}',
                                  // ),
                                  // gapH4,
                                  // reusableText(
                                  //   '${'Account Number'.tr}: ${widget.quotationNumber}',
                                  // ),
                                  // gapH4,
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // international payments
                      // pw.Padding(
                      //   padding: pw.EdgeInsets.fromLTRB(0, 30, 0, 0),
                      //   child: pw.SizedBox(
                      //     // width: width * 0.15,
                      //     child: pw.Row(
                      //       mainAxisAlignment: pw.MainAxisAlignment.start,
                      //       children: [
                      //         pw.Column(
                      //           crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //           children: [
                      //             gapH4,
                      //             reusableText(
                      //               '.For international payments via bank transfer, kindly refer to our account details mentioned',
                      //             ),
                      //             gapH4,
                      //             reusableText(
                      //               '${'Bank name'.tr}: ${widget.senderUser}',
                      //             ),
                      //             gapH4,
                      //             reusableText(
                      //               '${'Address'.tr}: ${widget.senderUser}',
                      //             ),
                      //             gapH4,
                      //             reusableText(
                      //               '${'ABA Number'.tr}: ${widget.quotationNumber}',
                      //             ),
                      //             gapH4,
                      //             reusableText(
                      //               '${'SWIFT Address'.tr}: ${widget.quotationNumber}',
                      //             ),
                      //             gapH4,
                      //             reusableText(
                      //               '${'Account Name'.tr}: ${widget.quotationNumber}',
                      //             ),
                      //             gapH4,
                      //             reusableText(
                      //               '${'Account Number'.tr}: ${widget.quotationNumber}',
                      //             ),
                      //             gapH4,
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      //
                      // // delivery
                      // pw.Padding(
                      //   padding: pw.EdgeInsets.fromLTRB(0, 20, 0, 0),
                      //   child: pw.SizedBox(
                      //     // width: width * 0.15,
                      //     child: pw.Row(
                      //       mainAxisAlignment: pw.MainAxisAlignment.start,
                      //       children: [
                      //         reusableText(
                      //           '  delivery terms and conditions',
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      //
                      // pw.Divider(
                      //   color: PdfColors.black,
                      //   // endIndent: 250
                      // ),
                      // delivery
                      // pw.Padding(
                      //   padding: pw.EdgeInsets.fromLTRB(0, 0, 0, 40),
                      //   child: pw.SizedBox(
                      //     // width: width * 0.15,
                      //     child: pw.Row(
                      //       mainAxisAlignment: pw.MainAxisAlignment.start,
                      //       children: [
                      //         pw.Column(
                      //           crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //           children: [
                      //             gapH4,
                      //             reusableText(
                      //               '${'.Delivery time for items available in stock'.tr}: ${widget.quotationNumber}',
                      //             ),
                      //             gapH4,
                      //             reusableText(
                      //               '${'.Delivery time for items not available in stock'.tr}: ${widget.quotationNumber}',
                      //             ),
                      //             gapH4,
                      //             reusableText('${'.Additional Note'.tr}:'),
                      //             gapH4,
                      //             reusableText(' ${widget.quotationNumber}'),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
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
//     required this.quotationNumber,
//     required this.ref,
//     required this.rowsInListViewInQuotation,
//     required this.creationDate,
//     required this.receivedUser,
//     required this.senderUser,
//     required this.status,
//     this.isInQuotation = false,
//   });
//
//   final String quotationNumber;
//   final String ref;
//   final String creationDate;
//   final String receivedUser;
//   final String senderUser;
//   final String status;
//   final bool isInQuotation;
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
//     reusableItemRowInQuotations({
//       required Map quotationItemInfo,
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
//             //     quotationController.itemsNames[ quotationItemInfo['item_id'] ]
//             //     ,
//             //     width: width * 0.05),
//             reusableShowInfoCard(
//               text: '${quotationItemInfo['item_id'] ?? ''}',
//               width: width * 0.05,
//             ),
//             reusableShowInfoCard(
//               text: '${quotationItemInfo['item_description'] ?? ''}',
//               width: width * 0.05,
//             ),
//             reusableShowInfoCard(
//               text: '${quotationItemInfo['item_quantity'] ?? ''}',
//               width: width * 0.04,
//             ),
//             reusableShowInfoCard(
//               text: '${quotationItemInfo['item_unit_price'] ?? ''}',
//               width: width * 0.04,
//             ),
//             reusableShowInfoCard(
//               text: '${quotationItemInfo['item_discount'] ?? '0'}',
//               width: width * 0.04,
//             ),
//             reusableShowInfoCard(
//               text: '${quotationItemInfo['item_total'] ?? ''}',
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
//                       '${widget.quotationNumber}',
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
//                       (context, index) => reusableItemRowInQuotations(
//                     quotationItemInfo:
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
