import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/Controllers/waste_reports_controller.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:file_saver/file_saver.dart';
import '../../../Models/Waste/waste_model.dart';
import '../../../Widgets/page_title.dart';
import '../../../const/colors.dart';
import '../../../const/functions.dart';

class WasteReport extends StatefulWidget {
  const WasteReport({super.key});

  @override
  State<WasteReport> createState() =>
      _WasteReportState();
}

class _WasteReportState extends State<WasteReport> {
  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();


  WasteReportsController wasteReportsController = Get.find();
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    final WasteDataSource wasteDataSource =
        WasteDataSource(
          wasteReportsController.wasteDetails,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                PageTitle(text: 'daily_qty_report'.tr),
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
                        onPressed: () {
                          exportDataGridToExcel();
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
                        onPressed: () {
                          exportDataGridToPDF();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GetBuilder<HomeController>(
            builder: (homeCont) {
              double width = homeCont.isMenuOpened?160:200;
              return Expanded(
                child: SfDataGrid(
                  key: _key,
                  source: wasteDataSource,
                  columns: <GridColumn>[
                    GridColumn(
                      width: width,
                      columnName: 'item_code',
                      label: Container(
                        padding: const EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: Text('item_code'.tr),
                      ),
                    ),
                    GridColumn(
                      width: width,
                      columnName: 'item_description',
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('item_description'.tr),
                      ),
                    ),
                    GridColumn(
                      width: width,
                      columnName: 'begin_quantity',
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text(
                          'begin_quantity'.tr,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    GridColumn(
                      width: width,
                      columnName: 'replenished_qty',
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text(
                          'replenished_qty'.tr,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    GridColumn(
                      width: width,
                      columnName: 'sales',
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('sales'.tr),
                      ),
                    ),
                    GridColumn(
                      width: width,
                      columnName: 'waste',
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('waste'.tr, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    GridColumn(
                      width: width,
                      columnName: 'qty_on_hand',
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text(
                          'qty_on_hand'.tr,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
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
    sheet.getRangeByIndex(1, 1).setText('item_code'.tr);
    sheet.getRangeByIndex(1, 2).setText('item_description'.tr);
    sheet.getRangeByIndex(1, 3).setText('begin_quantity'.tr);
    sheet.getRangeByIndex(1, 4).setText('replenished_qty'.tr);
    sheet.getRangeByIndex(1, 5).setText('sales'.tr);
    sheet.getRangeByIndex(1, 6).setText('waste'.tr);
    sheet.getRangeByIndex(1, 7).setText('qty_on_hand'.tr);

    for (int i = 0; i < wasteReportsController.wasteDetails.length; i++) {
        sheet
            .getRangeByIndex(i + 2, 1)
            .setText(wasteReportsController.wasteDetails[i].itemCode);
        sheet
            .getRangeByIndex(i + 2, 2)
            .setText(wasteReportsController.wasteDetails[i].itemDescription);
        sheet
            .getRangeByIndex(i + 2, 3)
            .setText(
              wasteReportsController.wasteDetails[i].beginQuantity.toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 4)
            .setText(
              wasteReportsController.wasteDetails[i].replenishedQty.toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 5)
            .setText(
              wasteReportsController.wasteDetails[i].sales
                  .toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 6)
            .setText(
              wasteReportsController.wasteDetails[i].waste
                  .toString(),
            );
        sheet
            .getRangeByIndex(i + 2, 7)
            .setText(
              wasteReportsController.wasteDetails[i].qtyOnHand
                  .toString(),
            );
      }

    final xlsio.Style style = workbook.styles.add('Style1');
    // style.fontSize = 14;
    style.bold = true;
    style.fontColor = '#000000'; // Red color.

    // Apply the style to the cell.
    sheet
        .getRangeByIndex(wasteReportsController.wasteDetails.length, 1)
        .cellStyle = style;
    sheet
        .getRangeByIndex(wasteReportsController.wasteDetails.length + 1, 1)
        .cellStyle = style;

    final int columnCount =7;
    for (int col = 1; col <= columnCount; col++) {
      sheet.autoFitColumn(col);
    }

    // Save workbook as bytes
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final Uint8List fileData = Uint8List.fromList(bytes);
    // var suf = '';
    // if (wasteReportsController.sessionNumberController.text.isNotEmpty) {
    //   suf = wasteReportsController.sessionNumberController.text;
    // }

    await FileSaver.instance.saveFile(
      name: 'daily-qty-report',
      bytes: fileData,
      ext: 'xlsx',
    );
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

    PdfGrid pdfGrid = PdfGrid();
    pdfGrid.columns.add(count: 7);
    pdfGrid.headers.add(1);

    // for(int i=0;i<pdfGrid.columns.count;i++){
    //   pdfGrid.columns[i].width = 160;
    // }

    // Set header text
    PdfGridRow header = pdfGrid.headers[0];
    header.cells[0].value = 'item_code'.tr;
    header.cells[1].value = 'item_description'.tr;
    header.cells[2].value = 'begin_quantity'.tr;
    header.cells[3].value = 'replenished_qty'.tr;
    header.cells[4].value = 'sales'.tr;
    header.cells[5].value = 'waste'.tr;
    header.cells[6].value = 'qty_on_hand'.tr;


    for (int i = 0; i < header.cells.count; i++) {
      header.cells[i].style = headerStyle;
    }
    // Add rows
    PdfGridRow row = pdfGrid.rows.add();
    for (int i = 0; i < wasteReportsController.wasteDetails.length; i++) {
        row.cells[0].value = wasteReportsController.wasteDetails[i].itemCode;
        row.cells[1].value = '${wasteReportsController.wasteDetails[i].itemDescription}';
        row.cells[2].value =
            '${wasteReportsController.wasteDetails[i].beginQuantity}';
        row.cells[3].value =
            '${wasteReportsController.wasteDetails[i].replenishedQty}';
        row.cells[4].value =
            '${wasteReportsController.wasteDetails[i].sales}';
        row.cells[5].value =
            '${wasteReportsController.wasteDetails[i].waste}';
        row.cells[6].value =
            '${wasteReportsController.wasteDetails[i].qtyOnHand}';
        row = pdfGrid.rows.add();
      }


    for (int i = 0; i < row.cells.count; i++) {
      row.cells[i].style = cellStyle;
      row.cells[i].style.cellPadding = PdfPaddings(
        left: 10,
        top: 15,
        right: 10,
        bottom: 15,
      );
    }

    // Draw the grid on the page
    pdfGrid.draw(page: page, bounds: const Rect.fromLTWH(0, 0, 0, 0));

    // Save the document as bytes
    final List<int> bytes = await document.save();
    document.dispose();

    final Uint8List fileData = Uint8List.fromList(bytes);
    // var suf = '';
    // if (wasteReportsController.sessionNumberController.text.isNotEmpty) {
    //   suf = wasteReportsController.sessionNumberController.text;
    // }

    await FileSaver.instance.saveFile(
      name: 'daily-qty-report',
      bytes: fileData,
      ext: 'pdf',
    );
  }
}

class WasteDataSource extends DataGridSource {

  WasteDataSource(this.wasteReportData)
     {
    _dataGridRows =
        wasteReportData.map<DataGridRow>((e) {
          List<DataGridCell> cells = [];
            cells = [
              DataGridCell<String>(
                columnName: 'item_code',
                value: e.itemCode,
              ),
              DataGridCell<String>(
                columnName: 'item_description',
                value: e.itemDescription,
              ),
              DataGridCell<String>(
                columnName: 'begin_quantity',
                value: numberWithComma(e.beginQuantity.toString()),
              ),
              DataGridCell<String>(
                columnName: 'replenished_qty',
                value: numberWithComma(e.replenishedQty.toString()),
              ),
              DataGridCell<String>(
                columnName: 'sales',
                value: numberWithComma(e.sales.toString()),
              ),
              DataGridCell<String>(
                columnName: 'waste',
                value: numberWithComma(e.waste.toString()),
              ),
              DataGridCell<String>(
                columnName: 'qty_on_hand',
                value: numberWithComma(e.qtyOnHand.toString()),
              ),
            ];
          return DataGridRow(cells: cells);
        }).toList();
  }

  final List<WasteModel> wasteReportData;
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
