import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rooster_app/Controllers/session_controller.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import '../../../Models/Sessions/sessions_model.dart';
import '../../../Widgets/page_title.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class MobileSessionDetailsAfterFilter extends StatefulWidget {
  const MobileSessionDetailsAfterFilter({super.key});

  @override
  State<MobileSessionDetailsAfterFilter> createState() =>
      _MobileSessionDetailsAfterFilterState();
}

class _MobileSessionDetailsAfterFilterState
    extends State<MobileSessionDetailsAfterFilter> {
  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  double width = 160;
  SessionController sessionController = Get.find();
  @override
  Widget build(BuildContext context) {
    final MobileSessionOrderDataSource sessionOrderDataSource =
        MobileSessionOrderDataSource(
          sessionController.sessionsDetails,
          sessionController.selectedCurrencyName,
        );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PageTitle(text: 'sessions_details'.tr),
                gapH10,
                Row(
                  children: [
                    SizedBox(
                      height: 40.0,
                      width: 150.0,
                      child: MaterialButton(
                        color: Primary.primary,
                        child: const Center(
                          child: Text(
                            'Export to Excel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          await exportDataGridToExcel();
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(20)),
                    SizedBox(
                      height: 40.0,
                      width: 150.0,
                      child: MaterialButton(
                        color: Primary.primary,
                        child: const Center(
                          child: Text(
                            'Export to PDF',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          exportDataGridToPDF();
                          // CommonWidgets.snackBar('success', 'PDF file saved successfully');
                          // askForPermissions(permission: Permission.camera);
                          // PermissionStatus status =
                          //     await Permission.manageExternalStorage.request();
                          //
                          // if (status.isGranted) {
                          //   print("MANAGE_EXTERNAL_STORAGE permission granted");
                          //   // You can proceed with your file management operation
                          //   await exportDataGridToPDF();
                          // } else {
                          //   print(
                          //     "Permission denied for MANAGE_EXTERNAL_STORAGE",
                          //   );
                          //   // Optionally, guide the user to enable it manually in the device settings
                          // }
                          // if (await Permission.storage.isGranted) {
                          //   // If storage permission is already granted, proceed with the export
                          //   await exportDataGridToPDF();
                          // } else {
                          //   // If not granted, request permission
                          //   PermissionStatus status =
                          //       await Permission.storage.request();
                          //   if (status.isGranted) {
                          //     await exportDataGridToPDF();
                          //   } else {
                          //     print(
                          //       "Permission denied. Redirecting to app settings.",
                          //     );
                          //     openAppSettings(); // This will open app settings
                          //   }
                          // }
                          // if (Platform.isAndroid) {
                          //   final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
                          //   final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
                          //   if ((info.version.sdkInt ?? 0) >= 33)
                          //     return true;
                          // }
                          // if (!await requestPermission(<Permission>[Permission.storage])) {
                          //
                          //   return false;
                          // }
                          // return true;
                        },
                      ),
                    ),
                  ],
                ),
                gapH10,
              ],
            ),
          ),
          Expanded(
            child: SfDataGrid(
              key: _key,
              source: sessionOrderDataSource,
              columns: <GridColumn>[
                GridColumn(
                  width: width,
                  columnName: 'order_number',
                  label: Container(
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    child: Text('order_number'.tr),
                  ),
                ),
                GridColumn(
                  width: width,
                  columnName: 'usd_total',
                  label: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('${'total'.tr}(${'usd'.tr})'),
                  ),
                ),
                GridColumn(
                  width: width,
                  columnName: 'usd_taxes',
                  label: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text(
                      '${'taxes'.tr} (${'usd'.tr})',
                      overflow: TextOverflow.ellipsis, //todo
                    ),
                  ),
                ),
                GridColumn(
                  width: width,
                  columnName: 'usd_discount',
                  label: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text(
                      '${'discount'.tr} (${'usd'.tr})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                GridColumn(
                  width: width,
                  columnName: 'other_currency_total',
                  label: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('${'total'.tr} (${'lbp'.tr})'),
                  ),
                ),
                GridColumn(
                  width: width,
                  columnName: 'other_currency_taxes',
                  label: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text(
                      '${'taxes'.tr} (${'lbp'.tr})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                GridColumn(
                  width: width,
                  columnName: 'other_currency_discount',
                  label: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text(
                      '${'discount'.tr} (${'lbp'.tr})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                GridColumn(
                  width: width,
                  columnName: 'received',
                  label: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('${'received'.tr} (${'usd'.tr})'),
                  ),
                ),
                GridColumn(
                  width: width,
                  columnName: 'other_currency_received',
                  label: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('${'received'.tr} (${'lbp'.tr})'),
                  ),
                ),
                GridColumn(
                  width: width,
                  columnName: 'opened_at',
                  label: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('opened_at'.tr),
                  ),
                ),
                GridColumn(
                  width: width,
                  columnName: 'closed_at',
                  label: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('closed_at'.tr),
                  ),
                ),
                ...List.generate(sessionOrderDataSource.maxPaymentMethods, (
                  index,
                ) {
                  return [
                    GridColumn(
                      width: 160,
                      columnName: 'method$index',
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('Cashing Method ${index + 1}'),
                      ),
                    ),
                    GridColumn(
                      width: 160,
                      columnName: 'amount$index',
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('Amount ${index + 1}'),
                      ),
                    ),
                  ];
                }).expand((columns) => columns),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> exportDataGridToExcel() async {
    // Create an Excel workbook
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Add header row
    sheet.getRangeByIndex(1, 1).setText('order_number'.tr);
    sheet.getRangeByIndex(1, 2).setText('${'total'.tr}(${'usd'.tr})');
    sheet.getRangeByIndex(1, 3).setText('${'taxes'.tr} (${'usd'.tr})');
    sheet.getRangeByIndex(1, 4).setText('${'discount'.tr} (${'usd'.tr})');
    sheet.getRangeByIndex(1, 5).setText('${'total'.tr} (${'lbp'.tr})');
    sheet.getRangeByIndex(1, 6).setText('${'taxes'.tr} (${'lbp'.tr})');
    sheet.getRangeByIndex(1, 7).setText('${'discount'.tr} (${'lbp'.tr})');
    sheet.getRangeByIndex(1, 8).setText('${'received'.tr} (${'usd'.tr})');
    sheet.getRangeByIndex(1, 9).setText('${'received'.tr} (${'lbp'.tr})');
    sheet.getRangeByIndex(1, 10).setText('opened_at'.tr);
    sheet.getRangeByIndex(1, 11).setText('closed_at'.tr);
    int maxPaymentMethods = sessionController.sessionsDetails
        .map((e) => e.paymentDetails == null ? 0 : e.paymentDetails!.length)
        .reduce((curr, next) => curr > next ? curr : next);
    int counter = 0;
    for (int i = 0; i < maxPaymentMethods; i++) {
      sheet.getRangeByIndex(1, 12 + counter).setText('Cashing Method ${i + 1}');
      sheet.getRangeByIndex(1, 13 + counter).setText('Amount ${i + 1}');
      counter += 2;
    }

    for (int i = 0; i < sessionController.sessionsDetails.length; i++) {
      if (sessionController.sessionsDetails[i].orderNumber == 'TOTAL') {
        sheet.getRangeByIndex(i + 2, 1).setText('totals'.tr);
        sheet
            .getRangeByIndex(i + 2, 2)
            .setText(sessionController.sessionsDetails[i].primaryCurrencyTotal.toString());
        sheet
            .getRangeByIndex(i + 2, 3)
            .setText(
              sessionController.sessionsDetails[i].primaryCurrencyTaxValue.toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 4)
            .setText(
              sessionController.sessionsDetails[i].primaryCurrencyDiscountValue.toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 5)
            .setText(
              sessionController.sessionsDetails[i].posCurrencyTotal
                  .toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 6)
            .setText(
              sessionController.sessionsDetails[i].posCurrencyTaxValue
                  .toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 7)
            .setText(
              sessionController.sessionsDetails[i].posCurrencyDiscountValue
                  .toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 8)
            .setText(sessionController.sessionsDetails[i].received.toString());
        sheet
            .getRangeByIndex(i + 2, 9)
            .setText(
              sessionController.sessionsDetails[i].receivedOtherCurrency
                  .toString(),
            );
      } else if (sessionController.sessionsDetails[i].orderNumber ==
          'selectedCurrencyTOTAL') {
        sheet
            .getRangeByIndex(i + 2, 1)
            .setText(
              '${'totals'.tr} (${sessionController.selectedCurrencyName})',
            );
        sheet
            .getRangeByIndex(i + 2, 2)
            .setText(
              sessionController.sessionsDetails[i].selectedCurrTotal.toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 3)
            .setText(
              sessionController.sessionsDetails[i].selectedCurrTaxTotal
                  .toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 4)
            .setText(
              sessionController.sessionsDetails[i].selectedCurrDiscountTotal
                  .toString(),
            );
      } else {
        sheet
            .getRangeByIndex(i + 2, 1)
            .setText(sessionController.sessionsDetails[i].orderNumber);
        sheet
            .getRangeByIndex(i + 2, 2)
            .setText(sessionController.sessionsDetails[i].primaryCurrencyTotal.toString());
        sheet
            .getRangeByIndex(i + 2, 3)
            .setText(
              sessionController.sessionsDetails[i].primaryCurrencyTaxValue.toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 4)
            .setText(
              sessionController.sessionsDetails[i].primaryCurrencyDiscountValue.toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 5)
            .setText(
              sessionController.sessionsDetails[i].posCurrencyTotal
                  .toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 6)
            .setText(
              sessionController.sessionsDetails[i].posCurrencyTaxValue
                  .toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 7)
            .setText(
              sessionController.sessionsDetails[i].posCurrencyDiscountValue
                  .toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 8)
            .setText(sessionController.sessionsDetails[i].received.toString());
        sheet
            .getRangeByIndex(i + 2, 9)
            .setText(
              sessionController.sessionsDetails[i].receivedOtherCurrency
                  .toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 10)
            .setText(sessionController.sessionsDetails[i].openedAt ?? '');
        sheet
            .getRangeByIndex(i + 2, 11)
            .setText(sessionController.sessionsDetails[i].closedAt ?? '');
        int count = 0;
        for (int j = 0; j < maxPaymentMethods; j++) {
          sheet
              .getRangeByIndex(i + 2, 12 + count)
              .setText(
                j < sessionController.sessionsDetails[i].paymentDetails!.length
                    ? sessionController
                        .sessionsDetails[i]
                        .paymentDetails![j]
                        .cashingMethod
                    : '',
              );
          sheet
              .getRangeByIndex(i + 2, 13 + count)
              .setText(
                j < sessionController.sessionsDetails[i].paymentDetails!.length
                    ? sessionController
                                .sessionsDetails[i]
                                .paymentDetails![j]
                                .usdAmount ==
                            0
                        ? '${sessionController.sessionsDetails[i].paymentDetails![j].otherCurrencyAmount} ${'lbp'.tr}'
                        : '${sessionController.sessionsDetails[i].paymentDetails![j].usdAmount} USD'
                    : '',
              );
          count += 2;
        }
      }
    }

    final xlsio.Style style = workbook.styles.add('Style1');
    // style.fontSize = 14;
    style.bold = true;
    style.fontColor = '#000000'; // Red color.

    // Apply the style to the cell.
    sheet
        .getRangeByIndex(sessionController.sessionsDetails.length, 1)
        .cellStyle = style;
    sheet
        .getRangeByIndex(sessionController.sessionsDetails.length + 1, 1)
        .cellStyle = style;

    final int columnCount = 11 + maxPaymentMethods;
    for (int col = 1; col <= columnCount; col++) {
      sheet.autoFitColumn(col);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    final directory = await _getDirectory();
    var suf = '';
    if (sessionController.sessionNumberController.text.isNotEmpty) {
      suf = sessionController.sessionNumberController.text;
    } else if (sessionController.fromSessionController.text.isNotEmpty) {
      suf =
          '${sessionController.fromSessionController.text}-${sessionController.toSessionController.text}';
    } else {
      suf =
          '${sessionController.fromDateController.text}-${sessionController.toDateController.text}';
    }
    final String filePath = '${directory.path}/session-report($suf).xlsx';
    final File file = File(filePath);
    await file.writeAsBytes(bytes);

    OpenFile.open(filePath);
  }

  Future<void> exportDataGridToPDF() async {
    // Create a PDF document
    PdfDocument document = PdfDocument();
    PdfPage page = document.pages.add();

    PdfGridCellStyle headerStyle = PdfGridCellStyle();
    headerStyle.borders.all = PdfPens.black;
    headerStyle.backgroundBrush = PdfBrushes.lightGray;
    headerStyle.stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );

    PdfGridCellStyle cellStyle = PdfGridCellStyle();
    cellStyle.stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    cellStyle.font = PdfStandardFont(PdfFontFamily.helvetica, 5);

    int maxPaymentMethods = sessionController.sessionsDetails
        .map((e) => e.paymentDetails == null ? 0 : e.paymentDetails!.length)
        .reduce((curr, next) => curr > next ? curr : next);

    // Add table data
    PdfGrid pdfGrid = PdfGrid();
    pdfGrid.columns.add(count: 11 + (maxPaymentMethods * 2));
    pdfGrid.headers.add(1);

    // Set header text dynamically
    PdfGridRow header = pdfGrid.headers[0];
    header.cells[0].value = 'order_number'.tr;
    header.cells[1].value = '${'total'.tr}(${'usd'.tr})';
    header.cells[2].value = '${'taxes'.tr} (${'usd'.tr})';
    header.cells[3].value = '${'discount'.tr} (${'usd'.tr})';
    header.cells[4].value = '${'received'.tr} (${'usd'.tr})';
    header.cells[5].value = '${'total'.tr} (${'lbp'.tr})';
    header.cells[6].value = '${'taxes'.tr} (${'lbp'.tr})';
    header.cells[7].value = '${'discount'.tr} (${'lbp'.tr})';
    header.cells[8].value = '${'received'.tr} (${'lbp'.tr})';
    header.cells[9].value = 'opened_at'.tr;
    header.cells[10].value = 'closed_at'.tr;

    int counter = 0;
    for (int i = 0; i < maxPaymentMethods; i++) {
      header.cells[11 + counter].value = 'Cashing Method ${i + 1}';
      header.cells[12 + counter].value = 'Amount ${i + 1}';
      counter += 2;
    }

    // Apply styles to header
    for (int i = 0; i < header.cells.count; i++) {
      header.cells[i].style = headerStyle;
    }

    // Add rows dynamically
    PdfGridRow row;
    for (int i = 0; i < sessionController.sessionsDetails.length; i++) {
      row = pdfGrid.rows.add();

      // Make sure paymentDetails is not null
      var paymentDetails = sessionController.sessionsDetails[i].paymentDetails;
      if (sessionController.sessionsDetails[i].orderNumber == 'TOTAL') {
        row.cells[0].value = 'totals'.tr;
        row.cells[1].value = '${sessionController.sessionsDetails[i].primaryCurrencyTotal}';
        row.cells[2].value =
            '${sessionController.sessionsDetails[i].primaryCurrencyTaxValue}';
        row.cells[3].value =
            '${sessionController.sessionsDetails[i].primaryCurrencyDiscountValue}';
        row.cells[4].value =
            '${sessionController.sessionsDetails[i].receivedOtherCurrency}';
        row.cells[5].value =
            '${sessionController.sessionsDetails[i].posCurrencyTotal}';
        row.cells[6].value =
            '${sessionController.sessionsDetails[i].posCurrencyTaxValue}';
        row.cells[7].value =
            '${sessionController.sessionsDetails[i].posCurrencyDiscountValue}';
        row.cells[8].value = '${sessionController.sessionsDetails[i].received}';
      } else {
        row.cells[0].value = sessionController.sessionsDetails[i].orderNumber;
        row.cells[1].value = '${sessionController.sessionsDetails[i].primaryCurrencyTotal}';
        row.cells[2].value =
            '${sessionController.sessionsDetails[i].primaryCurrencyTaxValue}';
        row.cells[3].value =
            '${sessionController.sessionsDetails[i].primaryCurrencyDiscountValue}';
        row.cells[4].value =
            '${sessionController.sessionsDetails[i].receivedOtherCurrency}';
        row.cells[5].value =
            '${sessionController.sessionsDetails[i].posCurrencyTotal}';
        row.cells[6].value =
            '${sessionController.sessionsDetails[i].posCurrencyTaxValue}';
        row.cells[7].value =
            '${sessionController.sessionsDetails[i].posCurrencyDiscountValue}';
        row.cells[8].value = '${sessionController.sessionsDetails[i].received}';
        row.cells[9].value =
            sessionController.sessionsDetails[i].openedAt ?? '';
        row.cells[10].value =
            sessionController.sessionsDetails[i].closedAt ?? '';

        // Check for null before accessing paymentDetails
        if (paymentDetails != null) {
          int count = 0;
          for (int j = 0; j < maxPaymentMethods; j++) {
            row.cells[11 + count].value =
                j < paymentDetails.length
                    ? paymentDetails[j].cashingMethod
                    : '';
            row.cells[12 + count].value =
                j < paymentDetails.length
                    ? paymentDetails[j].usdAmount == 0
                        ? '${paymentDetails[j].otherCurrencyAmount} ${'lbp'.tr}'
                        : '${paymentDetails[j].usdAmount} USD'
                    : '';
            count += 2;
          }
        }
      }

      // Apply style to cells
      for (int i = 0; i < row.cells.count; i++) {
        row.cells[i].style = cellStyle;
        row.cells[i].style.cellPadding = PdfPaddings(
          left: 10,
          top: 15,
          right: 10,
          bottom: 15,
        );
        if ('${row.cells[i].value}'.startsWith('totals'.tr)) {
          row.cells[i].style.font = PdfStandardFont(
            PdfFontFamily.helvetica,
            12,
            style: PdfFontStyle.bold,
          );
        }
      }
    }

    // Calculate page width and scale grid dynamically for mobile
    double pageWidth = page.getClientSize().width;
    double pageHeight = page.getClientSize().height;

    // Adjust the grid layout to fit the page width (mobile view)
    pdfGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 0, pageWidth - 10, pageHeight - 10),
    );
    // Save the document as bytes
    final List<int> bytes = await document.save();
    document.dispose();

    final Uint8List fileData = Uint8List.fromList(bytes);

    final directory = await _getDirectory();
    var suf = '';
    if (sessionController.sessionNumberController.text.isNotEmpty) {
      suf = sessionController.sessionNumberController.text;
    } else if (sessionController.fromSessionController.text.isNotEmpty) {
      suf =
          '${sessionController.fromSessionController.text}-${sessionController.toSessionController.text}';
    } else {
      suf =
          '${sessionController.fromDateController.text}-${sessionController.toDateController.text}';
    }
    // Create a file path
    final filePath = '${directory.path}/session-report($suf).pdf';
    final file = File(filePath);
    await file.writeAsBytes(fileData);
    // Save file using a file saving library or package
    // await FileSaver.instance.saveFile(
    //   filePath: filePath,
    //   name: 'session-report',
    //   bytes: fileData,
    //   ext: 'pdf',
    //
    // );
    OpenFile.open(filePath);
  }
}

class MobileSessionOrderDataSource extends DataGridSource {
  final int maxPaymentMethods;

  MobileSessionOrderDataSource(this.sessionOrders, this.selectedCurrency)
    : maxPaymentMethods = sessionOrders
          .map((e) => e.paymentDetails == null ? 0 : e.paymentDetails!.length)
          .reduce((curr, next) => curr > next ? curr : next) {
    _dataGridRows =
        sessionOrders.map<DataGridRow>((e) {
          List<DataGridCell> cells = [];
          if (e.orderNumber == 'TOTAL') {
            cells = [
              DataGridCell<String>(
                columnName: 'order_number',
                value: 'totals'.tr,
              ),
              DataGridCell<String>(
                columnName: 'usd_total',
                value: e.primaryCurrencyTotal.toString(),
              ),
              DataGridCell<String>(
                columnName: 'usd_taxes',
                value: e.primaryCurrencyTaxValue.toString(),
              ),
              DataGridCell<String>(
                columnName: 'other_currency_taxes',
                value: e.posCurrencyTaxValue.toString(),
              ),
              DataGridCell<String>(
                columnName: 'other_currency_total',
                value: e.posCurrencyTotal.toString(),
              ),
              DataGridCell<String>(
                columnName: 'other_currency_discount',
                value: e.posCurrencyDiscountValue.toString(),
              ),
              DataGridCell<String>(
                columnName: 'usd_discount',
                value: e.primaryCurrencyDiscountValue.toString(),
              ),
              DataGridCell<String>(
                columnName: 'received',
                value: e.received.toString(),
              ),
              DataGridCell<String>(
                columnName: 'other_currency_received',
                value: e.receivedOtherCurrency.toString(),
              ),
              const DataGridCell<String>(columnName: 'closed_at', value: ''),
              const DataGridCell<String>(columnName: 'opened_at', value: ''),
            ];

            // Add cells for departments dynamically
            for (int i = 0; i < maxPaymentMethods; i++) {
              cells.add(
                DataGridCell<String>(
                  columnName: 'method$i',
                  value: '', // Empty if no department
                ),
              );
              cells.add(
                DataGridCell<String>(
                  columnName: 'amount$i',
                  value: '', // Empty if no department
                ),
              );
            }
          } else if (e.orderNumber == 'selectedCurrencyTOTAL') {
            cells = [
              DataGridCell<String>(
                columnName: 'order_number',
                value: '${'totals'.tr} ($selectedCurrency)',
              ),
              DataGridCell<String>(
                columnName: 'usd_total',
                value: e.selectedCurrTotal.toString(),
              ),
              DataGridCell<String>(
                columnName: 'usd_taxes',
                value: e.selectedCurrTaxTotal.toString(),
              ),
              DataGridCell<String>(
                columnName: 'usd_discount',
                value: e.selectedCurrDiscountTotal.toString(),
              ),
              const DataGridCell<String>(
                columnName: 'other_currency_taxes',
                value: '',
              ),
              const DataGridCell<String>(
                columnName: 'other_currency_total',
                value: '',
              ),
              const DataGridCell<String>(
                columnName: 'other_currency_discount',
                value: '',
              ),
              const DataGridCell<String>(columnName: 'received', value: ''),
              const DataGridCell<String>(
                columnName: 'other_currency_received',
                value: '',
              ),
              const DataGridCell<String>(columnName: 'closed_at', value: ''),
              const DataGridCell<String>(columnName: 'opened_at', value: ''),
            ];

            // Add cells for departments dynamically
            for (int i = 0; i < maxPaymentMethods; i++) {
              cells.add(
                DataGridCell<String>(
                  columnName: 'method$i',
                  value: '', // Empty if no department
                ),
              );
              cells.add(
                DataGridCell<String>(
                  columnName: 'amount$i',
                  value: '', // Empty if no department
                ),
              );
            }
          } else {
            cells = [
              DataGridCell<String>(
                columnName: 'order_number',
                value: e.orderNumber,
              ),
              DataGridCell<String>(
                columnName: 'usd_total',
                value: e.primaryCurrencyTotal.toString(),
              ),
              DataGridCell<String>(
                columnName: 'usd_taxes',
                value: e.primaryCurrencyTaxValue.toString(),
              ),
              DataGridCell<String>(
                columnName: 'other_currency_taxes',
                value: e.posCurrencyTaxValue.toString(),
              ),
              DataGridCell<String>(
                columnName: 'other_currency_total',
                value: e.posCurrencyTotal.toString(),
              ),
              DataGridCell<String>(
                columnName: 'other_currency_discount',
                value: e.posCurrencyDiscountValue.toString(),
              ),
              DataGridCell<String>(
                columnName: 'usd_discount',
                value: e.primaryCurrencyDiscountValue.toString(),
              ),
              DataGridCell<String>(
                columnName: 'received',
                value: '${e.received ?? 0}',
              ),
              DataGridCell<String>(
                columnName: 'other_currency_received',
                value: e.receivedOtherCurrency.toString(),
              ),
              DataGridCell<String>(
                columnName: 'closed_at',
                value: e.closedAt ?? '',
              ),
              DataGridCell<String>(
                columnName: 'opened_at',
                value: e.openedAt ?? '',
              ),
            ];

            // Add cells for departments dynamically
            for (int i = 0; i < maxPaymentMethods; i++) {
              cells.add(
                DataGridCell<String>(
                  columnName: 'method$i',
                  value:
                      i < e.paymentDetails!.length
                          ? e.paymentDetails![i].cashingMethod
                          : '', // Empty if no department
                ),
              );
              cells.add(
                DataGridCell<String>(
                  columnName: 'amount$i',
                  value:
                      i < e.paymentDetails!.length
                          ? e.paymentDetails![i].usdAmount == 0
                              ? '${e.paymentDetails![i].otherCurrencyAmount} ${'lbp'.tr}'
                              : '${e.paymentDetails![i].usdAmount} USD'
                          : '', // Empty if no department
                ),
              );
            }
          }

          return DataGridRow(cells: cells);
        }).toList();
  }

  final List<SessionOrder> sessionOrders;
  final String selectedCurrency;
  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  DataGridCell<dynamic> getCellValue(
    DataGridRow dataGridRow,
    String columnName,
  ) {
    return dataGridRow
        .getCells()
        .firstWhere((cell) => cell.columnName == columnName)
        .value;
  }

  Widget buildWidget(
    DataGridCell<dynamic> cell,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    CellSubmit submitCell,
  ) {
    return Container(
      width:
          column.columnName.startsWith('method') ||
                  column.columnName.startsWith('Amount')
              ? 160
              : 140,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        cell.value.toString(),
        textAlign: TextAlign.center,
        style:
            cell.value == 'totals'.tr
                ? const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                )
                : const TextStyle(),
      ),
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((cell) {
            return Container(
              // color:cell.value=='totals'.tr? Colors.grey:Colors.white,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cell.value.toString(),
                textAlign: TextAlign.center,
                style:
                    '${cell.value}'.startsWith('totals'.tr)
                        ? const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )
                        : const TextStyle(),
              ),
            );
          }).toList(),
    );
  }
}

Future<void> askForPermissions({required Permission permission}) async {
  final status = await permission.status;
  if (status.isGranted) {
  } else if (status.isDenied) {
    if (await permission.request().isGranted) {
    } else {}
  } else {}
}

// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/services.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<void> exportDataGridToPDF4() async {
  // Create a PDF document
  PdfDocument document = PdfDocument();
  PdfPage page = document.pages.add();
  PdfGridCellStyle headerStyle = PdfGridCellStyle();
  headerStyle.borders.all = PdfPens.black;
  headerStyle.backgroundBrush = PdfBrushes.lightGray;
  headerStyle.stringFormat = PdfStringFormat(
    alignment: PdfTextAlignment.center,
    lineAlignment: PdfVerticalAlignment.middle,
  );
  PdfGridCellStyle cellStyle = PdfGridCellStyle();
  cellStyle.stringFormat = PdfStringFormat(
    alignment: PdfTextAlignment.center,
    lineAlignment: PdfVerticalAlignment.middle,
  );

  // Add your table data here (same as your original code)

  // Draw the grid on the page
  PdfGrid pdfGrid = PdfGrid();
  pdfGrid.draw(page: page, bounds: const Rect.fromLTWH(0, 0, 0, 0));

  // Save the document as bytes
  final List<int> bytes = await document.save();
  document.dispose();

  // Convert bytes to Uint8List
  final Uint8List fileData = Uint8List.fromList(bytes);

  // Check permissions (Request storage permissions for Android)
  await _requestPermission();

  // Get the directory to store the file
  final directory = await _getDirectory();

  // Create a file path
  final filePath = '${directory.path}/session-report.pdf';

  // Save the file
  final file = File(filePath);
  await file.writeAsBytes(fileData);

  // Optionally, notify user that file is saved
}

// Request permission to access storage (Android only)
Future<void> _requestPermission() async {
  final status = await Permission.storage.request();
  if (!status.isGranted) {}
}

// Get the directory to save the file
Future<Directory> _getDirectory() async {
  // For Android devices, use getExternalStorageDirectory
  final directory = await getExternalStorageDirectory();

  // If directory is null (e.g. on iOS), fallback to app documents directory
  if (directory == null) {
    return await getApplicationDocumentsDirectory();
  }

  return directory;
}
