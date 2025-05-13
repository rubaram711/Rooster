import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';
import 'package:rooster_app/Controllers/inventory_controller.dart';
import 'package:rooster_app/Models/Inventory/inventory_model.dart';
import 'package:rooster_app/Widgets/loading.dart';
import '../../../const/colors.dart';
import '../../Controllers/home_controller.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;

import '../../const/Sizes.dart';

class PrintInventory extends StatefulWidget {
  const PrintInventory(
      {super.key,   this.isMobile=false,
        // required this.items,
      });
  // final List<InventoryItem> items;

  final bool isMobile;
  @override
  State<PrintInventory> createState() => _PrintInventoryState();
}

class _PrintInventoryState extends State<PrintInventory> {
  bool isHomeHovered = false;
  HomeController homeController=Get.find();
  InventoryController inventoryController=Get.find();
String groups='';
  convertListOfListsToString(List<List<String>> list){
    List<String> flattenedList = list.expand((x) => x).toList();
    String result = flattenedList.join(', ');
    return result;
  }
  int maxKeys = 0;
  getMaxLengthOfPackaging(List<QtyInDefaultPackaging> qtyInDefaultPackagingList){
    // Find the object with the maximum number of non-null keys

    for (var packaging in qtyInDefaultPackagingList) {
      // Count non-null keys
      int keyCount = [
        packaging.containerName,
        packaging.paletteName,
        packaging.supersetName,
        packaging.setName,
        packaging.unitName,
      ].where((element) => element != null).length;

      // Update max if this object has more keys
      if (keyCount > maxKeys) {
      setState(() {
        maxKeys = keyCount;
      });
      }
    }
  }

  @override
  void initState() {
    maxKeys = 0;
    inventoryController.qtyInDefaultPackagingList=[];
    inventoryController.getInventoryDataFromBack();
    // print('object ${widget.items}');
    groups=convertListOfListsToString(inventoryController.selectedGroupsNamesForShow);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                    // if(widget.isFromCountingForm){
                    //   Get.back();
                    //   homeController.selectedTab.value = 'counting_form';
                    // }else{
                    //   Get.back();
                    // }
                  },
                  child: Icon(Icons.arrow_back,
                      size: 22,
                      // color: Colors.grey,
                      color: Primary.primary),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            GetBuilder<InventoryController>(
              builder: (cont) {
                return cont.isInventoryDataFetched?SizedBox(
                  width: Sizes.deviceWidth ,
                  height: Sizes.deviceHeight * 0.85,
                  child: PdfPreview(
                    build: (format) => _generatePdf(format, context,cont.inventoryData,cont.qtyInDefaultPackagingList),
                  ),
                ):loading();
              }
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, BuildContext context, List<InventoryItem> items,List<QtyInDefaultPackaging> qtyInDefaultPackagingList) async {
    getMaxLengthOfPackaging(qtyInDefaultPackagingList);
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    // double width = MediaQuery.of(context).size.width;
    double cellWidth =widget.isMobile?100:

    inventoryController.isPrintWithQtyChecked && inventoryController.selectedValueForPackaging==1 && maxKeys>2
        ? MediaQuery.of(context).size.width * 0.02
        : MediaQuery.of(context).size.width * 0.05;
    var gapH4 = pw.SizedBox(height: 4);
    var gapH10 = pw.SizedBox(height: 10);
    // var gapW = pw.SizedBox(
    //     width: maxKeys==5?7:maxKeys==4?10:35
    //
    // );
    tableTitle({required String text, required double width}) {
      return pw.SizedBox(
          width: width,
          child: pw.Text(
            text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
                color: PdfColors.black,
                fontSize:inventoryController.isPrintWithQtyChecked && inventoryController.selectedValueForPackaging==1&& maxKeys>2?  5:9,
                fontWeight: pw.FontWeight.bold),
          ));
    }

    reusableTitle({required String text}) {
      return pw.Text(
        text,
        style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold),
      );
    }

    reusableShowInfoCard({required double width, required String text}) {
      return pw.Container(
        width: width,
        padding: const pw.EdgeInsets.symmetric(horizontal: 2),
        child: pw.Center(
            child: pw.Text(text, style:   pw.TextStyle(
              fontSize: inventoryController.isPrintWithQtyChecked && inventoryController.selectedValueForPackaging==1&& maxKeys>2?  5:9,))),
      );
    }

    reusableItemRowInTransferIn(
        {required InventoryItem item, required int index}) {
      return pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 3),
        child:pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly, // Ensures equal spacing
          children: [
            reusableShowInfoCard(text: '${item.mainCode}', width: cellWidth),
            reusableShowInfoCard(text: item.itemName ?? '', width: cellWidth),

            // if (!(inventoryController.isPrintWithQtyChecked && inventoryController.selectedValueForPackaging == 1))
            //   reusableShowInfoCard(text: '', width: cellWidth),
            //
            // if (inventoryController.isPrintWithQtyChecked && inventoryController.selectedValueForPackaging == 2)
            //   reusableShowInfoCard(
            //     text: inventoryController.quantities[index].toString(),
            //     width: cellWidth,
            //   ),

            if (inventoryController.isPrintWithQtyChecked && inventoryController.selectedValueForPackaging == 1) ...[
              if (maxKeys == 5)
                reusableShowInfoCard(
                  text: '${inventoryController.qtyInDefaultPackagingList[index].containerQty ?? ''} '
                      '${inventoryController.qtyInDefaultPackagingList[index].containerName ?? ''}',
                  width: cellWidth,
                ),
              if (maxKeys >= 4)
                reusableShowInfoCard(
                  text: '${inventoryController.qtyInDefaultPackagingList[index].paletteQty ?? ''} '
                      '${inventoryController.qtyInDefaultPackagingList[index].paletteName ?? ''}',
                  width: cellWidth,
                ),
              if (maxKeys >= 3)
                reusableShowInfoCard(
                  text: '${inventoryController.qtyInDefaultPackagingList[index].supersetQty ?? ''} '
                      '${inventoryController.qtyInDefaultPackagingList[index].supersetName ?? ''}',
                  width: cellWidth,
                ),
              if (maxKeys >= 2)
                reusableShowInfoCard(
                  text: '${inventoryController.qtyInDefaultPackagingList[index].setQty ?? ''} '
                      '${inventoryController.qtyInDefaultPackagingList[index].setName ?? ''}',
                  width: cellWidth,
                ),
              if (maxKeys >= 1)
                reusableShowInfoCard(
                  text: '${inventoryController.qtyInDefaultPackagingList[index].unitQty ?? ''} '
                      '${inventoryController.qtyInDefaultPackagingList[index].unitName ?? ''}',
                  width: cellWidth,
                ),
            ]
            else reusableShowInfoCard(
                text:inventoryController.isPrintWithQtyChecked
                    ? inventoryController.quantities[index].toString()
                    : '',
                width: cellWidth),


            if (inventoryController.isPrintWithQtyChecked && inventoryController.selectedValueForPackaging == 1)
              ...List.generate(
                maxKeys,
                    (index) => reusableShowInfoCard(text: '', width: cellWidth),
              )
            else
              reusableShowInfoCard(text: '', width: cellWidth),

            reusableShowInfoCard(text: '', width: cellWidth),
          ],
        )
      );
    }
    reusableText(String text){
      return  pw.Text(text, style: const pw.TextStyle(fontSize: 9,));
    }
    pdf.addPage(pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        build: (context) {
          return [
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                reusableTitle(
                    text: 'Inventory Counting Form'
                ),
                gapH4,
                pw.Divider(
                  color: PdfColors.black,
                  // endIndent: 250
                ),
                gapH4,
                reusableText('${'company'.tr}: ${homeController.companyName}  ,  ${'user'.tr}: ${homeController.userName}'),
                gapH4,
                inventoryController.itemsController.text.isEmpty?pw.SizedBox():reusableText('${'items'.tr}: ${inventoryController.itemsController.text}'),
                gapH4,
                inventoryController.categoryController.text.isEmpty?pw.SizedBox():reusableText('${'categories'.tr}: ${inventoryController.categoryController.text}'),
                gapH4,
                reusableText('${'groups'.tr}: ${groups.isEmpty?'All Groups':groups}'),
                gapH10,
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    tableTitle(text: 'item_code'.tr, width: cellWidth),
                    tableTitle(text: 'item_name'.tr, width: cellWidth),

                    if (!(inventoryController.isPrintWithQtyChecked && inventoryController.selectedValueForPackaging == 1))
                      tableTitle(text: 'theoretical_qty_on_hand'.tr, width: cellWidth),

                    if (inventoryController.isPrintWithQtyChecked && inventoryController.selectedValueForPackaging == 1) ...[
                      if (maxKeys == 5) tableTitle(text: 'theoretical_qty (Container)'.tr, width: cellWidth),
                      if (maxKeys >= 4) tableTitle(text: 'theoretical_qty (Palette)'.tr, width: cellWidth),
                      if (maxKeys >= 3) tableTitle(text: 'theoretical_qty (Superset)'.tr, width: cellWidth),
                      if (maxKeys >= 2) tableTitle(text: 'theoretical_qty (Set)'.tr, width: cellWidth),
                      if (maxKeys >= 1) tableTitle(text: 'theoretical_qty (Unit)'.tr, width: cellWidth),
                    ],

                    if (!(inventoryController.isPrintWithQtyChecked && inventoryController.selectedValueForPackaging == 1))
                      tableTitle(text: 'physical_qty_on_hand'.tr, width: cellWidth),

                    if (inventoryController.isPrintWithQtyChecked && inventoryController.selectedValueForPackaging == 1) ...[
                      if (maxKeys == 5) tableTitle(text: 'physical_qty (Container)'.tr, width: cellWidth),
                      if (maxKeys >= 4) tableTitle(text: 'physical_qty (Palette)'.tr, width: cellWidth),
                      if (maxKeys >= 3) tableTitle(text: 'physical_qty (Superset)'.tr, width: cellWidth),
                      if (maxKeys >= 2) tableTitle(text: 'physical_qty (Set)'.tr, width: cellWidth),
                      if (maxKeys >= 1) tableTitle(text: 'physical_qty (Unit)'.tr, width: cellWidth),
                    ],

                    tableTitle(text: 'difference'.tr, width: cellWidth),
                  ],
                ),
                gapH4,
                pw.Divider(
                  color: PdfColors.black,
                  // endIndent: 250
                ),
                pw.ListView.builder(
                  padding: const pw.EdgeInsets.symmetric(vertical: 10),
                  itemCount: items.length, //products is data from back res
                  itemBuilder: (context, index) => reusableItemRowInTransferIn(
                    item: items[index],
                    index: index,
                  ),
                ),
              ],
            ),
          ];
        }));

    return pdf.save();
  }
}

