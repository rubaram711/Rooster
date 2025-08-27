import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rooster_app/Backend/InventoryBackend/store_inventory_data.dart';
import 'package:rooster_app/Screens/Inventory/print_inventory.dart';
import '../../Backend/ProductsBackend/get_an_item.dart';
import '../../Controllers/home_controller.dart';
import '../../Controllers/inventory_controller.dart';
import '../../Controllers/warehouse_controller.dart';
import '../../Models/Inventory/inventory_model.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_drop_menu.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_title.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../../const/functions.dart';
import '../Products/products_page.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
// ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;
import 'package:file_saver/file_saver.dart';
// import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class PhysicalInventory extends StatefulWidget {
  const PhysicalInventory({super.key});

  @override
  State<PhysicalInventory> createState() => _PhysicalInventoryState();
}

class _PhysicalInventoryState extends State<PhysicalInventory> {
  final TextEditingController filterController = TextEditingController();

  bool isGridClicked = false;

  final HomeController homeController = Get.find();
  List tabsList = [
    'form',
    'filter',
  ];
  List<Widget> pagesList = [
    const FormPage(),
    const FilterPage(),
  ];
  int selectedTabIndex = 0;

  WarehouseController warehouseController = Get.find();
  InventoryController inventoryController = Get.find();

  @override
  void initState() {
    inventoryController.warehouseMenuController.clear();
    warehouseController.getWarehousesFromBack();
    inventoryController.getCategoriesFromBack();
    inventoryController.getAllProductsFromBack();
    inventoryController.getGroupsFromBack();
    inventoryController.dateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(builder: (inventoryCont) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02),
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(text: 'physical_inventory'.tr),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('warehouse'.tr),
                    gapW10,
                    GetBuilder<WarehouseController>(builder: (cont) {
                      return cont.isWarehousesFetched
                          ? DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width * 0.15,
                              // requestFocusOnTap: false,
                              enableSearch: true,
                              controller: inventoryCont.warehouseMenuController,
                              hintText: '${'search'.tr}...',
                              inputDecorationTheme: InputDecorationTheme(
                                // filled: true,
                                hintStyle: const TextStyle(
                                    fontStyle: FontStyle.italic),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(20, 0, 25, 5),
                                // outlineBorder: BorderSide(color: Colors.black,),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                                      width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(9)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                                      width: 2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(9)),
                                ),
                              ),
                              // menuStyle: ,
                              menuHeight: 250,
                              dropdownMenuEntries: cont.warehousesNameList
                                  .map<DropdownMenuEntry<String>>(
                                      (String option) {
                                return DropdownMenuEntry<String>(
                                  value: option,
                                  label: option,
                                );
                              }).toList(),
                              enableFilter: true,
                              onSelected: (String? val) {
                                var index =
                                    cont.warehousesNameList.indexOf(val!);
                                inventoryCont.setSelectedWarehouseId(
                                    '${cont.warehouseIdsList[index]}');
                              },
                            )
                          : loading();
                    }),
                  ],
                ),
                gapW40,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('date'.tr),
                    gapW10,
                    DialogDateTextField(
                      textEditingController: inventoryCont.dateController,
                      text: '',
                      textFieldWidth: MediaQuery.of(context).size.width * 0.15,
                      validationFunc: (val) {},
                      onChangedFunc: (value) {
                        //dateController.text = value;
                      },
                      onDateSelected: (value) {
                        String rd =
                            DateFormat('yyyy-MM-dd').format(DateTime.now());
                        DateTime dt1 = DateTime.parse("$rd 00:00:00");
                        DateTime dt2 = DateTime.parse("$value 00:00:00");
                        if (dt2.isBefore(dt1) || dt2.isAtSameMomentAs(dt1)) {
                          inventoryCont.dateController.text = value;
                        } else {
                          CommonWidgets.snackBar(
                              'error', 'date can\'t be after today');
                        }
                      },
                    ),
                  ],
                ),
                gapW40,
                ReusableButtonWithColor(
                  btnText: 'Go',
                  onTapFunction: () async {
                    if (inventoryCont.warehouseMenuController.text.isEmpty) {
                      CommonWidgets.snackBar(
                          'error', 'Please select a warehouse');
                    } else {
                      inventoryCont.getInventoryDataFromBack();
                      setState(() {
                        selectedTabIndex = 0;
                      });
                    }
                  },
                  height: 45,
                  width: MediaQuery.of(context).size.width * 0.05,
                )
              ],
            ),
            gapH20,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Wrap(
                    spacing: 0.0,
                    direction: Axis.horizontal,
                    children: tabsList
                        .map((element) => ReusableBuildTabChipItem(
                              name: element,
                              index: tabsList.indexOf(element),
                              function: () {
                                setState(() {
                                  selectedTabIndex = tabsList.indexOf(element);
                                });
                              },
                              isClicked:
                                  selectedTabIndex == tabsList.indexOf(element),
                            ))
                        .toList()),
              ],
            ),
            gapH20,
            pagesList[selectedTabIndex],
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      inventoryCont.inventoryData = [];
                      inventoryCont.selectedWarehouseId = '';
                      inventoryCont.warehouseMenuController.clear();
                      inventoryCont.selectedCategoryId = '0';
                      inventoryCont.selectedCategoriesIdsList = [];
                      inventoryCont.categoryController.text = 'all_categories'.tr;
                      inventoryCont.itemsController.text = 'all_items'.tr;
                      inventoryCont.selectedItemId = '0';
                      inventoryCont.getGroupsFromBack();
                      inventoryCont.dateController.text =
                          DateFormat('yyyy-MM-dd').format(DateTime.now());
                    },
                    child: Text(
                      'discard'.tr,
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Primary.primary),
                    )),
                gapW24,
                ReusableButtonWithColor(
                  btnText: 'save'.tr,
                  onTapFunction: () async {
                    bool isAllQtyCounted = true;
                    for (var e in inventoryCont.physicalQtyControllersList) {
                      if (e.text.isEmpty) {
                        isAllQtyCounted = false;
                        break;
                      }
                    }
                    if (isAllQtyCounted) {
                      var res = await storeInventory(
                          inventoryCont.selectedWarehouseId,
                          inventoryCont.dateController.text,
                          inventoryCont.inventoryData,
                          inventoryCont.physicalQtyControllersList,
                          inventoryCont.difference,
                          inventoryCont.physicalCost,
                          inventoryCont.theoreticalCost,
                          inventoryCont.quantities);
                      if (res['success'] == true) {
                        CommonWidgets.snackBar('Success', res['message']);
                      } else {
                        CommonWidgets.snackBar(
                            'error', res['message'] ?? 'error'.tr);
                      }
                    } else {
                      CommonWidgets.snackBar('error',
                          'You have to inventory the quantities of all products');
                    }
                  },
                  width: 100,
                  height: 35,
                  isDisable: inventoryCont.inventoryData.isEmpty,
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  InventoryController inventoryController = Get.find();
  String searchKey = '';
  int? highlightedRowIndex; // Highlighted row index
  ScrollController scrollController = ScrollController(); // For scrolling

  // File picker to load Excel file
  Future<Uint8List?> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null) {
      return result.files.single.bytes;
    }
    return null;
  }

  Future<void> loadExcelFile() async {
    Uint8List? fileBytes = await pickExcelFile();
    if (fileBytes != null) {
      List<InventoryItem> parsedEmployees =
          await parseExcelToInventoryData(fileBytes);
        inventoryController.setInventoryData(parsedEmployees);
    }
  }

  // Search for a key and scroll to the corresponding row
  void searchAndHighlight(String key) {
    int? rowIndex;
    for (int i = 0; i < inventoryController.inventoryData.length; i++) {
      for (int j = 0;
          j < inventoryController.inventoryData[i].barcode!.length;
          j++) {
        if (inventoryController.inventoryData[i].barcode![j].code! == key) {
          rowIndex = i;
          inventoryController
              .physicalQtyControllersList[i].text = inventoryController
                  .physicalQtyControllersList[i].text.isEmpty
              ? '1'
              : '${double.parse(inventoryController.physicalQtyControllersList[i].text) + 1}';
          break;
        }
      }
    }

    if (rowIndex != null) {
      setState(() {
        highlightedRowIndex = rowIndex;
        searchKey = key;
      });

      // Scroll to the row
      double scrollOffset = rowIndex * 36; // Assuming row height is 60
      scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      setState(() {
        highlightedRowIndex = null;
        searchKey = key;
      });
    }
  }

  bool isBarcodeActive = false;
  TextEditingController barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(builder: (cont) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReusableButtonWithNoColor(
                width: MediaQuery.of(context).size.width * 0.15,
                height: 45,
                onTapFunction: () {
                  setState(() {
                    isBarcodeActive = !isBarcodeActive;
                  });
                },
                btnText: isBarcodeActive
                    ? 'stop_barcode_input'.tr
                    : 'switch_to_barcode_input'.tr,
              ),
              gapW4,
              ReusableButtonWithNoColor(
                width: MediaQuery.of(context).size.width * 0.15,
                height: 45,
                onTapFunction: () {
                  loadExcelFile();
                },
                btnText: 'import_excel'.tr,
              ),
              gapW4,
              ReusableButtonWithNoColor(
                width: MediaQuery.of(context).size.width * 0.15,
                height: 45,
                onTapFunction: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const PrintInventory(
                      // items: cont.inventoryData,
                    );
                  }));
                },
                btnText: 'print'.tr,
              ),
              gapW4,
              ReusableButtonWithNoColor(
                width: MediaQuery.of(context).size.width * 0.15,
                height: 45,
                onTapFunction: () {
                 exportExcelFile();
                },
                btnText: 'export_excel'.tr,
              ),
            ],
          ),
          gapH10,
          isBarcodeActive
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: ReusableSearchTextField(
                    hint: '${"enter_barcode".tr}...',
                    textEditingController: barcodeController,
                    onChangedFunc: (value) {
                      searchAndHighlight(value);
                    },
                    validationFunc: (val) {},
                  ),
                )
              : const SizedBox(),
          gapH10,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
            decoration: BoxDecoration(
                color: Primary.primary,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6), topRight: Radius.circular(6))),
            child: GetBuilder<HomeController>(
                builder: (homeCont) {
                  double bigWidth=homeCont.isMenuOpened? MediaQuery.of(context).size.width * 0.12:MediaQuery.of(context).size.width * 0.15;
                  double smallWidth=homeCont.isMenuOpened? MediaQuery.of(context).size.width * 0.1:MediaQuery.of(context).size.width * 0.12;
                return Row(
                  children: [
                    TableTitle(
                      text: 'item_code'.tr,
                      width: smallWidth,
                    ),
                    TableTitle(
                      text: 'item_name'.tr,
                      width: smallWidth,
                    ),
                    TableTitle(
                      text: 'theoretical_qty_on_hand'.tr,
                      width:bigWidth,
                    ),
                    TableTitle(
                      text: 'physical_qty_on_hand'.tr,
                      width:bigWidth,
                    ),
                    TableTitle(
                      text: 'difference'.tr,
                      width: smallWidth,
                    ),
                    TableTitle(
                      text: 'theoretical_cost'.tr,
                      width:smallWidth,
                    ),
                    TableTitle(
                      text: 'physical_cost'.tr,
                      width: smallWidth,
                    ),
                  ],
                );
              }
            ),
          ),
          cont.isInventoryDataFetched
              ? GetBuilder<HomeController>(
              builder: (homeCont) {
                double bigWidth=homeCont.isMenuOpened? MediaQuery.of(context).size.width * 0.12:MediaQuery.of(context).size.width * 0.15;
                double smallWidth=homeCont.isMenuOpened? MediaQuery.of(context).size.width * 0.1:MediaQuery.of(context).size.width * 0.12;
                  return SizedBox(
                      height:isBarcodeActive? MediaQuery.of(context).size.height * 0.3:MediaQuery.of(context).size.height * 0.35,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: {
                            0: FlexColumnWidth(
                                smallWidth),
                            1: FlexColumnWidth(
                                smallWidth),
                            2: FlexColumnWidth(
                               bigWidth),
                            3: FlexColumnWidth(
                                bigWidth),
                            4: FlexColumnWidth(
                                smallWidth),
                            5: FlexColumnWidth(
                                smallWidth),
                            6: FlexColumnWidth(
                                smallWidth),
                            // 7:FlexColumnWidth(MediaQuery.of(context).size.width * 0.1),
                          }, // Table borders
                          children: cont.inventoryData.map((item) {
                            int rowIndex = cont.inventoryData.indexOf(item);
                            // if(item.physicalQty!=null){
                            //   physicalQtyController.text= '${item.physicalQty!}';
                            // }
                            // if(item.difference!=null){
                            //   difference= item.difference!;
                            // }
                            // if(item.physicalCost!=null){
                            //   physicalCost= item.physicalCost!;
                            // }
                            // if(item.theoreticalCost!=null){
                            //   theoreticalCost= item.theoreticalCost!;
                            // }else{
                            //   theoreticalCost=item.quantity!*item.unitCost!;
                            // }
                            return TableRow(
                              decoration: BoxDecoration(
                                color: rowIndex == highlightedRowIndex
                                    ? Colors.red.withAlpha((0.5 * 255).toInt())
                                    : Colors.transparent,
                              ),
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: Text(item.mainCode ?? '')),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: Text(item.itemName ?? '')),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child:
                                            Text(numberWithComma('${cont.quantities[rowIndex]}'))),
                                  ),
                                ),
                                TableCell(
                                  child: TextField(
                                      controller:
                                          cont.physicalQtyControllersList[rowIndex],
                                      textAlign: TextAlign.center,
                                      cursorColor: Colors.black,
                                      onChanged: (val) {
                                        cont.setDifference(
                                            rowIndex,
                                            double.parse(val) -
                                                cont.quantities[rowIndex]);
                                        cont.setPhysicalCost(rowIndex,
                                            double.parse(val) * item.unitCost!);
                                      },
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: false,
                                        signed: true,
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[0-9.]')),
                                        // NumberFormatter(),
                                        // WhitelistingTextInputFormatter.digitsOnly
                                      ]),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child:
                                            Text(numberWithComma('${cont.difference[rowIndex]}'))),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text(
                            numberWithComma('${cont.theoreticalCost[rowIndex]}'))),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child:
                                            Text(numberWithComma('${cont.physicalCost[rowIndex]}'))),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                }
              )
              : loading(),
        ],
      );
    });
  }

  Future<void> exportExcelFile() async {
    // Create an Excel workbook
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Add header row
    sheet.getRangeByIndex(1, 1).setText('id'.tr);
    sheet.getRangeByIndex(1, 2).setText('item_code'.tr);
    sheet.getRangeByIndex(1, 3).setText('item_name'.tr);
    sheet.getRangeByIndex(1, 4).setText('theoretical_qty_on_hand'.tr);
    sheet.getRangeByIndex(1, 5).setText('physical_qty_on_hand'.tr);
    sheet.getRangeByIndex(1, 6).setText('difference'.tr);
    sheet.getRangeByIndex(1, 7).setText( 'theoretical_cost'.tr);
    sheet.getRangeByIndex(1, 8).setText( 'physical_cost'.tr);

    for(int i=0;i<inventoryController.inventoryData.length;i++){
        sheet.getRangeByIndex(i+2, 1).setText(inventoryController.inventoryData[i].id.toString());
        sheet.getRangeByIndex(i+2, 2).setText(inventoryController.inventoryData[i].mainCode);
        sheet.getRangeByIndex(i+2, 3).setText(inventoryController.inventoryData[i].itemName);
        sheet.getRangeByIndex(i+2, 4).setNumber(inventoryController.quantities[i]);
        sheet.getRangeByIndex(i+2, 5).setText(inventoryController.physicalQtyControllersList[i].text);
        sheet.getRangeByIndex(i+2, 6).setNumber(inventoryController.difference[i]);
        sheet.getRangeByIndex(i+2, 7).setNumber(inventoryController.theoreticalCost[i]);
        sheet.getRangeByIndex(i+2, 8).setNumber(inventoryController.physicalCost[i]);
      }

    const int columnCount = 8 ;
    for (int col = 1; col <= columnCount; col++) {
      sheet.autoFitColumn(col);
    }

    // Save workbook as bytes
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // // Trigger download in browser
    // final blob = html.Blob([Uint8List.fromList(bytes)]);
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // html.AnchorElement(href: url)
    //   ..target = 'blank'
    //   ..download = 'inventory.xlsx'
    //   ..click();
    // html.Url.revokeObjectUrl(url);

    // Convert to Uint8List
    final Uint8List fileData = Uint8List.fromList(bytes);

    // Save file without using dart:html
    await FileSaver.instance.saveFile(
      name: 'inventory',
      bytes: fileData,
      ext: 'xlsx',
      // mimeType: MimeType.MICROSOFT_EXCEL,
    );
  }


  Future<List<InventoryItem>> parseExcelToInventoryData(Uint8List fileBytes) async {
    var excel = Excel.decodeBytes(fileBytes);
    inventoryController.inventoryData=[];
    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet != null) {
        for (int i = 1; i < sheet.rows.length; i++) {
          // Skip the header row
          var row = sheet.rows[i];
          if (row.length >= 2) {
            String id = row[0]?.value.toString() ?? ''; // First column: id
            String code = row[1]?.value.toString() ?? '';
            String itemName = row[2]?.value.toString() ?? '';
            String quantity = row[3]?.value.toString() ?? '';
            String physicalQty = row[4]?.value.toString() ?? '';
            String difference = row[5]?.value.toString() ?? '';
            String theoreticalCost = row[6]?.value.toString() ?? '';
            String physicalCost = row[7]?.value.toString() ?? '';
            // int code = int.tryParse(row[1]?.value.toString() ?? '0') ??
            0; // Second column: Number
            List<Barcode>? barcode;
            var res =await getAnItem(id);
            if(res['success']==true){
              barcode=res['data']['barcode'].map<Barcode>((e)=>Barcode.fromJson(e)).toList();
            }
            inventoryController.inventoryData.add(InventoryItem(
              id: int.parse(id),
              mainCode: code,
              itemName: itemName,
              barcode: barcode
              // quantity: double.parse(quantity),
            ));


            inventoryController.physicalQtyControllersList
                .add(TextEditingController(text: physicalQty));
            inventoryController.difference.add(double.parse(difference));
            inventoryController.theoreticalCost
                .add(double.parse(theoreticalCost));
            inventoryController.physicalCost.add(double.parse(physicalCost));
            inventoryController.quantities.add(double.parse(quantity));
          }
        }
      }
    }

    return  inventoryController.inventoryData;
  }
}




class FilterPage extends StatefulWidget {
  const FilterPage({super.key, this.isMobile=false});
final bool isMobile;
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  InventoryController inventoryController = Get.find();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(builder: (cont) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DialogDropMenu(
                controller: cont.itemsController,
                optionsList: cont.itemsNamesList,
                text: 'item'.tr,
                hint: cont.itemsNamesList[
                    cont.itemsIdsList.indexOf(cont.selectedItemId)],
                rowWidth:widget.isMobile? MediaQuery.of(context).size.width * 0.9: MediaQuery.of(context).size.width * 0.25,
                textFieldWidth:widget.isMobile? MediaQuery.of(context).size.width * 0.65: MediaQuery.of(context).size.width * 0.15,
                onSelected: (String? val) {
                  var index = cont.itemsNamesList.indexOf(val!);
                  cont.setSelectedItemId(cont.itemsIdsList[index]);
                }),
            gapH24,
            DialogDropMenu(
                controller: cont.categoryController,
                optionsList: cont.categoriesNameList,
                text: 'category'.tr,
                hint: cont.categoriesNameList[
                    cont.categoriesIdsList.indexOf(cont.selectedCategoryId)],
                rowWidth:widget.isMobile? MediaQuery.of(context).size.width * 0.9: MediaQuery.of(context).size.width * 0.25,
                textFieldWidth:widget.isMobile? MediaQuery.of(context).size.width * 0.65: MediaQuery.of(context).size.width * 0.15,
                onSelected: (String? val) {
                  var index = cont.categoriesNameList.indexOf(val!);
                  cont.setSelectedCategoryId(cont.categoriesIdsList[index]);
                }),
            gapH24,
            Expanded(
              // height: MediaQuery.of(context).size.height * 0.35,
              child: ListView.builder(
                itemCount:
                    cont.groupsList.length, //products is data from back res
                itemBuilder: (context, index) => GroupRow(
                  isMobile: widget.isMobile,
                  data: cont.groupsList[index],
                  index: index,
                ),
              ),
            ),
            widget.isMobile?gapH20:SizedBox(),
            // Spacer()
          ],
        ),
      );
    });
  }


}

class GroupRow extends StatefulWidget {
  const GroupRow(
      {super.key,
      required this.data,
      required this.index,
      required this.isMobile});
  final Map data;
  final int index;
  final bool isMobile;
  @override
  State<GroupRow> createState() => _GroupRowState();
}

class _GroupRowState extends State<GroupRow> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(builder: (cont) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width:widget.isMobile? MediaQuery.of(context).size.width * 0.2: MediaQuery.of(context).size.width * 0.10,
              child: Text(widget.data['name']),
            ),
            DropdownMenu<String>(
              width: widget.isMobile? MediaQuery.of(context).size.width * 0.35:MediaQuery.of(context).size.width * 0.15,
              // requestFocusOnTap: false,
              enableSearch: true,
              controller: cont.textEditingControllerForGroups[widget.index],
              hintText: cont.selectedGroupsCodesForShow[widget.index].isNotEmpty
                  ? cont.selectedGroupsCodesForShow[widget.index][0]
                  : '',
              inputDecorationTheme: InputDecorationTheme(
                // filled: true,
                hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                // outlineBorder: BorderSide(color: Colors.black,),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(9)),
                ),
              ),
              // menuStyle: ,
              menuHeight: 250,
              dropdownMenuEntries: cont.childGroupsCodes[widget.index]
                  .map<DropdownMenuEntry<String>>((String option) {
                return DropdownMenuEntry<String>(
                  value: option,
                  label: option,
                );
              }).toList(),
              enableFilter: true,
              onSelected: (String? val) {
                var index = cont.childGroupsCodes[widget.index].indexOf(val!);
                cont.addIdToSelectedGroupsIdsList(
                    cont.groupsIds[widget.index][index]);
                cont.addSelectedGroupsIdsForShow(
                    [cont.groupsIds[widget.index][index]], widget.index);
                cont.addSelectedGroupsCodesForShow([val], widget.index);
                cont.addSelectedGroupsNamesForShow(
                    [cont.childGroupsNames[widget.index][index]], widget.index);
              },
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Container(
              height: 47,
              padding:   EdgeInsets.symmetric(horizontal:widget.isMobile?3: 10),
              width: MediaQuery.of(context).size.width * 0.15,
              // decoration: BoxDecoration(
              //   borderRadius:const BorderRadius.all( Radius.circular(9)),
              //   border:   Border.all(color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
              // ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    cont.selectedGroupsNamesForShow[widget.index].isNotEmpty
                        ? cont.selectedGroupsNamesForShow[widget.index][0]
                        : '',
                  ),
                ],
              ),
            )
            // DialogDropMenu(
            //   controller: textEditingController,
            //   optionsList: cont.groupBranches[widget.index]??[],
            //   text: widget.data['name'],
            //   hint: '',
            //   rowWidth: MediaQuery.of(context).size.width * 0.25,
            //   textFieldWidth: MediaQuery.of(context).size.width * 0.15,
            //   onSelected:  (String? val) {
            //     var index = cont.groupBranches[widget.index].indexOf(val!);
            //     cont.addIdToSelectedGroupsIdsList(cont.groupsIds[widget.index][index]);
            //   },
            // ),
          ],
        ),
      );
    });
  }
}


class MobilePhysicalInventory extends StatefulWidget {
  const MobilePhysicalInventory({super.key});

  @override
  State<MobilePhysicalInventory> createState() => _MobilePhysicalInventoryState();
}

class _MobilePhysicalInventoryState extends State<MobilePhysicalInventory> {
  final TextEditingController filterController = TextEditingController();
  FilterItems? selectedFilterItem;
  // GlobalKey filterKey = GlobalKey();
  bool isGridClicked = false;

  final HomeController homeController = Get.find();
  List tabsList = [
    'form',
    'filter',
  ];
  List<Widget> pagesList = [
    const MobileFormPage(),
    const FilterPage(isMobile: true,),
  ];
  int selectedTabIndex = 0;

  WarehouseController warehouseController = Get.find();
  InventoryController inventoryController = Get.find();

  @override
  void initState() {
    inventoryController.warehouseMenuController.clear();
    warehouseController.getWarehousesFromBack();
    inventoryController.getCategoriesFromBack();
    inventoryController.getAllProductsFromBack();
    inventoryController.getGroupsFromBack();
    inventoryController.dateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(builder: (inventoryCont) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02),
        // height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(text: 'physical_inventory'.tr),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('warehouse'.tr),
                gapW10,
                GetBuilder<WarehouseController>(builder: (cont) {
                  return cont.isWarehousesFetched
                      ? DropdownMenu<String>(
                    width: MediaQuery.of(context).size.width * 0.5,
                    // requestFocusOnTap: false,
                    enableSearch: true,
                    controller: inventoryCont.warehouseMenuController,
                    hintText: '${'search'.tr}...',
                    inputDecorationTheme: InputDecorationTheme(
                      // filled: true,
                      hintStyle: const TextStyle(
                          fontStyle: FontStyle.italic),
                      contentPadding:
                      const EdgeInsets.fromLTRB(20, 0, 25, 5),
                      // outlineBorder: BorderSide(color: Colors.black,),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                            width: 1),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                            width: 2),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(9)),
                      ),
                    ),
                    // menuStyle: ,
                    menuHeight: 250,
                    dropdownMenuEntries: cont.warehousesNameList
                        .map<DropdownMenuEntry<String>>(
                            (String option) {
                          return DropdownMenuEntry<String>(
                            value: option,
                            label: option,
                          );
                        }).toList(),
                    enableFilter: true,
                    onSelected: (String? val) {
                      var index =
                      cont.warehousesNameList.indexOf(val!);
                      inventoryCont.setSelectedWarehouseId(
                          '${cont.warehouseIdsList[index]}');
                    },
                  )
                      : loading();
                }),
              ],
            ),
            gapH10,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('date'.tr),
                gapW10,
                DialogDateTextField(
                  textEditingController: inventoryCont.dateController,
                  text: '',
                  textFieldWidth: MediaQuery.of(context).size.width * 0.5,
                  validationFunc: (val) {},
                  onChangedFunc: (value) {
                    //dateController.text = value;
                  },
                  onDateSelected: (value) {
                    String rd =
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
                    DateTime dt1 = DateTime.parse("$rd 00:00:00");
                    DateTime dt2 = DateTime.parse("$value 00:00:00");
                    if (dt2.isBefore(dt1) || dt2.isAtSameMomentAs(dt1)) {
                      inventoryCont.dateController.text = value;
                    } else {
                      CommonWidgets.snackBar(
                          'error', 'date can\'t be after today');
                    }
                  },
                ),
              ],
            ),
            gapH10,
            ReusableButtonWithColor(
              btnText: 'Go',
              onTapFunction: () async {
                if (inventoryCont.warehouseMenuController.text.isEmpty) {
                  CommonWidgets.snackBar(
                      'error', 'Please select a warehouse');
                } else {
                  inventoryCont.getInventoryDataFromBack();
                  setState(() {
                    selectedTabIndex = 0;
                  });
                }
              },
              height: 45,
              width: MediaQuery.of(context).size.width * 0.25,
            ),
            gapH20,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Wrap(
                    spacing: 0.0,
                    direction: Axis.horizontal,
                    children: tabsList
                        .map((element) => ReusableBuildTabChipItem(
                      name: element,
                      index: tabsList.indexOf(element),
                      function: () {
                        setState(() {
                          selectedTabIndex = tabsList.indexOf(element);
                        });
                      },
                      isClicked:
                      selectedTabIndex == tabsList.indexOf(element),
                    ))
                        .toList()),
              ],
            ),
            gapH20,
            pagesList[selectedTabIndex],
            // const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      inventoryCont.inventoryData = [];
                      inventoryCont.selectedWarehouseId = '';
                      inventoryCont.warehouseMenuController.clear();
                      inventoryCont.selectedCategoryId = '0';
                      inventoryCont.selectedCategoriesIdsList = [];
                      inventoryCont.categoryController.text = 'all_categories'.tr;
                      inventoryCont.itemsController.text = 'all_items'.tr;
                      inventoryCont.selectedItemId = '0';
                      inventoryCont.getGroupsFromBack();
                      inventoryCont.dateController.text =
                          DateFormat('yyyy-MM-dd').format(DateTime.now());
                    },
                    child: Text(
                      'discard'.tr,
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Primary.primary),
                    )),
                gapW24,
                ReusableButtonWithColor(
                  btnText: 'save'.tr,
                  onTapFunction: () async {
                    bool isAllQtyCounted = true;
                    for (var e in inventoryCont.physicalQtyControllersList) {
                      if (e.text.isEmpty) {
                        isAllQtyCounted = false;
                        break;
                      }
                    }
                    if (isAllQtyCounted) {
                      var res = await storeInventory(
                          inventoryCont.selectedWarehouseId,
                          inventoryCont.dateController.text,
                          inventoryCont.inventoryData,
                          inventoryCont.physicalQtyControllersList,
                          inventoryCont.difference,
                          inventoryCont.physicalCost,
                          inventoryCont.theoreticalCost,
                          inventoryCont.quantities);
                      if (res['success'] == true) {
                        CommonWidgets.snackBar('Success', res['message']);
                      } else {
                        CommonWidgets.snackBar(
                            'error', res['message'] ?? 'error'.tr);
                      }
                    } else {
                      CommonWidgets.snackBar('error',
                          'You have to inventory the quantities of all products');
                    }
                  },
                  width: 100,
                  height: 35,
                  isDisable: inventoryCont.inventoryData.isEmpty,
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}



class MobileFormPage extends StatefulWidget {
  const MobileFormPage({super.key});

  @override
  State<MobileFormPage> createState() => _MobileFormPageState();
}

class _MobileFormPageState extends State<MobileFormPage> {
  InventoryController inventoryController = Get.find();
  String searchKey = '';
  int? highlightedRowIndex; // Highlighted row index
  ScrollController scrollController = ScrollController(); // For scrolling

  // File picker to load Excel file
  Future<Uint8List?> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null) {
      return result.files.single.bytes;
    }
    return null;
  }

  Future<void> loadExcelFile() async {
    Uint8List? fileBytes = await pickExcelFile();
    if (fileBytes != null) {
      List<InventoryItem> parsedEmployees =
      await parseExcelToInventoryData(fileBytes);
      inventoryController.setInventoryData(parsedEmployees);
    }
  }

  // Search for a key and scroll to the corresponding row
  void searchAndHighlight(String key) {
    int? rowIndex;
    for (int i = 0; i < inventoryController.inventoryData.length; i++) {
      for (int j = 0;
      j < inventoryController.inventoryData[i].barcode!.length;
      j++) {
        if (inventoryController.inventoryData[i].barcode![j].code! == key) {
          rowIndex = i;
          inventoryController
              .physicalQtyControllersList[i].text = inventoryController
              .physicalQtyControllersList[i].text.isEmpty
              ? '1'
              : '${double.parse(inventoryController.physicalQtyControllersList[i].text) + 1}';
          break;
        }
      }
    }

    if (rowIndex != null) {
      setState(() {
        highlightedRowIndex = rowIndex;
        searchKey = key;
      });

      // Scroll to the row
      double scrollOffset = rowIndex * 36; // Assuming row height is 60
      scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      setState(() {
        highlightedRowIndex = null;
        searchKey = key;
      });
    }
  }

  bool isBarcodeActive = false;
  TextEditingController barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(builder: (cont) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReusableButtonWithNoColor(
                width: MediaQuery.of(context).size.width * 0.44,
                height: 45,
                onTapFunction: () {
                  setState(() {
                    isBarcodeActive = !isBarcodeActive;
                  });
                },
                btnText: isBarcodeActive
                    ? 'stop_barcode_input'.tr
                    : 'switch_to_barcode_input'.tr,
              ),
              gapW4,
              ReusableButtonWithNoColor(
                width: MediaQuery.of(context).size.width * 0.44,
                height: 45,
                onTapFunction: () {
                  loadExcelFile();
                },
                btnText: 'import_excel'.tr,
              ),
            ],
          ),
          gapH4,
          Row(
            children: [
              ReusableButtonWithNoColor(
                width: MediaQuery.of(context).size.width * 0.44,
                height: 45,
                onTapFunction: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return const PrintInventory(
                          isMobile: true,
                          // items: cont.inventoryData,
                        );
                      }));
                },
                btnText: 'print'.tr,
              ),
              gapW4,
              ReusableButtonWithNoColor(
                width: MediaQuery.of(context).size.width * 0.44,
                height: 45,
                onTapFunction: () {
                  exportExcelFile();
                },
                btnText: 'export_excel'.tr,
              ),
            ],
          ),
          gapH10,
          isBarcodeActive
              ? SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            child: ReusableSearchTextField(
              hint: '${"enter_barcode".tr}...',
              textEditingController: barcodeController,
              onChangedFunc: (value) {
                searchAndHighlight(value);
              },
              validationFunc: (val) {},
            ),
          )
              : const SizedBox(),
          gapH10,
          cont.isInventoryDataFetched
              ? SizedBox(
            height: isBarcodeActive
                ? MediaQuery.of(context).size.height * 0.3
                : MediaQuery.of(context).size.height * 0.35,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enable horizontal scrolling
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.vertical, // Enable vertical scrolling
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Primary.primary,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      child: Row(
                        children: [
                          TableTitle(
                            text: 'item_code'.tr,
                            width:150,
                          ),
                          TableTitle(
                            text: 'item_name'.tr,
                            width: 150,
                          ),
                          TableTitle(
                            text: 'theoretical_qty_on_hand'.tr,
                            width: 150,
                          ),
                          TableTitle(
                            text: 'physical_qty_on_hand'.tr,
                            width: 150,
                          ),
                          TableTitle(
                            text: 'difference'.tr,
                            width: 150,
                          ),
                          TableTitle(
                            text: 'theoretical_cost'.tr,
                            width: 150,
                          ),
                          TableTitle(
                            text: 'physical_cost'.tr,
                            width: 150,
                          ),
                        ],
                      ),
                    ),
                    Table(
                      border: TableBorder.all(color: Colors.grey),
                      columnWidths: const {
                        0: FixedColumnWidth(150),
                        1: FixedColumnWidth(150),
                        2: FixedColumnWidth(150),
                        3: FixedColumnWidth(150),
                        4: FixedColumnWidth(150),
                        5: FixedColumnWidth(150),
                        6: FixedColumnWidth(150),
                      },
                      children: cont.inventoryData.map((item) {
                        int rowIndex = cont.inventoryData.indexOf(item);
                        return TableRow(
                          decoration: BoxDecoration(
                            color: rowIndex == highlightedRowIndex
                                ? Colors.red.withAlpha((0.5 * 255).toInt())
                                : Colors.transparent,
                          ),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(child: Text(item.mainCode ?? '')),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(child: Text(item.itemName ?? '')),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text('${cont.quantities[rowIndex]}'),
                                ),
                              ),
                            ),
                            TableCell(
                              child: TextField(
                                controller:
                                cont.physicalQtyControllersList[rowIndex],
                                textAlign: TextAlign.center,
                                cursorColor: Colors.black,
                                onChanged: (val) {
                                  cont.setDifference(
                                      rowIndex,
                                      double.parse(val) -
                                          cont.quantities[rowIndex]);
                                  cont.setPhysicalCost(rowIndex,
                                      double.parse(val) * item.unitCost!);
                                },
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: false,
                                  signed: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp('[0-9.]')),
                                ],
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text('${cont.difference[rowIndex]}'),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text('${cont.theoreticalCost[rowIndex]}'),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text('${cont.physicalCost[rowIndex]}'),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          )
              : loading(),


        ],
      );
    });
  }

  Future<void> exportExcelFile() async {
    // Create an Excel workbook
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Add header row
    sheet.getRangeByIndex(1, 1).setText('id'.tr);
    sheet.getRangeByIndex(1, 2).setText('item_code'.tr);
    sheet.getRangeByIndex(1, 3).setText('item_name'.tr);
    sheet.getRangeByIndex(1, 4).setText('theoretical_qty_on_hand'.tr);
    sheet.getRangeByIndex(1, 5).setText('physical_qty_on_hand'.tr);
    sheet.getRangeByIndex(1, 6).setText('difference'.tr);
    sheet.getRangeByIndex(1, 7).setText( 'theoretical_cost'.tr);
    sheet.getRangeByIndex(1, 8).setText( 'physical_cost'.tr);

    for(int i=0;i<inventoryController.inventoryData.length;i++){
      sheet.getRangeByIndex(i+2, 1).setText(inventoryController.inventoryData[i].id.toString());
      sheet.getRangeByIndex(i+2, 2).setText(inventoryController.inventoryData[i].mainCode);
      sheet.getRangeByIndex(i+2, 3).setText(inventoryController.inventoryData[i].itemName);
      sheet.getRangeByIndex(i+2, 4).setNumber(inventoryController.quantities[i]);
      sheet.getRangeByIndex(i+2, 5).setText(inventoryController.physicalQtyControllersList[i].text);
      sheet.getRangeByIndex(i+2, 6).setNumber(inventoryController.difference[i]);
      sheet.getRangeByIndex(i+2, 7).setNumber(inventoryController.theoreticalCost[i]);
      sheet.getRangeByIndex(i+2, 8).setNumber(inventoryController.physicalCost[i]);
    }

    const int columnCount = 8 ;
    for (int col = 1; col <= columnCount; col++) {
      sheet.autoFitColumn(col);
    }

    // Save workbook as bytes
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // // Trigger download in browser
    // final blob = html.Blob([Uint8List.fromList(bytes)]);
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // html.AnchorElement(href: url)
    //   ..target = 'blank'
    //   ..download = 'inventory.xlsx'
    //   ..click();
    // html.Url.revokeObjectUrl(url);

    // Convert to Uint8List
    // final Uint8List fileData = Uint8List.fromList(bytes);
    //
    // // Save file without using dart:html
    // await FileSaver.instance.saveFile(
    //   name: 'inventory',
    //   bytes: fileData,
    //   ext: 'xlsx',
    //   // mimeType: MimeType.MICROSOFT_EXCEL,
    // );

    final directory = await _getDirectory();
    final String filePath = '${directory.path}/inventory.xlsx';
    final File file = File(filePath);
    await file.writeAsBytes(bytes);

    OpenFile.open(filePath);
  }

  Future<Directory> _getDirectory() async {
    // For Android devices, use getExternalStorageDirectory
    final directory = await getExternalStorageDirectory();

    // If directory is null (e.g. on iOS), fallback to app documents directory
    if (directory == null) {
      return await getApplicationDocumentsDirectory();
    }

    return directory;
  }

  Future<List<InventoryItem>> parseExcelToInventoryData(Uint8List fileBytes) async {
    var excel = Excel.decodeBytes(fileBytes);
    inventoryController.inventoryData=[];
    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet != null) {
        for (int i = 1; i < sheet.rows.length; i++) {
          // Skip the header row
          var row = sheet.rows[i];
          if (row.length >= 2) {
            String id = row[0]?.value.toString() ?? ''; // First column: id
            String code = row[1]?.value.toString() ?? '';
            String itemName = row[2]?.value.toString() ?? '';
            String quantity = row[3]?.value.toString() ?? '';
            String physicalQty = row[4]?.value.toString() ?? '';
            String difference = row[5]?.value.toString() ?? '';
            String theoreticalCost = row[6]?.value.toString() ?? '';
            String physicalCost = row[7]?.value.toString() ?? '';
            // int code = int.tryParse(row[1]?.value.toString() ?? '0') ??
            0; // Second column: Number
            List<Barcode>? barcode;
            var res =await getAnItem(id);
            if(res['success']==true){
              barcode=res['data']['barcode'].map<Barcode>((e)=>Barcode.fromJson(e)).toList();
            }
            inventoryController.inventoryData.add(InventoryItem(
                id: int.parse(id),
                mainCode: code,
                itemName: itemName,
                barcode: barcode
              // quantity: double.parse(quantity),
            ));


            inventoryController.physicalQtyControllersList
                .add(TextEditingController(text: physicalQty));
            inventoryController.difference.add(double.parse(difference));
            inventoryController.theoreticalCost
                .add(double.parse(theoreticalCost));
            inventoryController.physicalCost.add(double.parse(physicalCost));
            inventoryController.quantities.add(double.parse(quantity));
          }
        }
      }
    }

    return  inventoryController.inventoryData;
  }
}