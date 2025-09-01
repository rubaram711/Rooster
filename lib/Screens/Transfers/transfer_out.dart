import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import 'package:rooster_app/Screens/Transfers/print_transfer.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/ConfigurationsBackend/Warehouses/get_warehouse_qty.dart';
import '../../Backend/Transfers/Transfer_out/add_transfer_out.dart';
import '../../Backend/Transfers/Transfer_out/get_data_create_transfer_out.dart';
import '../../Controllers/transfer_controller.dart';
import '../../Controllers/warehouse_controller.dart';
import '../../Widgets/TransferWidgets/reusable_show_info_card.dart';
import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../Widgets/TransferWidgets/under_item_btn.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_drop_menu.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_more.dart';
import '../../Widgets/table_title.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import '../../const/functions.dart';

class TransferOut extends StatefulWidget {
  const TransferOut({super.key});

  @override
  State<TransferOut> createState() => _TransferOutState();
}

class _TransferOutState extends State<TransferOut> {
  TextEditingController refController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  late Uint8List imageFile;
  int currentStep = 0;

  List tabsList = ['order_lines', 'other_information'];
  String? selectedSrcWrhs = '';
  String? selectedDestWrhs = '';
  final TransferController transferController = Get.find();
  final HomeController homeController = Get.find();
  final WarehouseController warehouseController = Get.find();
  int progressVar = 0;
  bool isInfoFetched = false;
  String transferNumber = '';
  getFieldsForCreateTransferFromBack() async {
    setState(() {
      currentStep = 0;
      transferController.selectedTabIndex = 0;
      selectedSrcWrhs = '';
      selectedDestWrhs = '';
      progressVar = 0;
      transferNumber = '';
      transferController.transferToControllerInTransferOut.text = '';
      transferController.transferFromControllerInTransferOut.text = '';
      transferController.setTransferToIdInTransferOut('');
      transferController.setTransferFromIdInTransferOut('');
    });
    var p = await getTransferOutDataForCreate();
    transferNumber = p['transferNumber'];
    if ('$p' != '[]') {
      setState(() {
        transferNumber = '${p['transferNumber']}';
        isInfoFetched = true;
      });
    }
  }

  // getDefaultWarehouseFromLocalMemory() async {
  //   String name=await getDefaultWarehouseNameFromPref();
  //   String id=await getDefaultWarehouseIdFromPref();
  //   // print('defaultWarehouse ${defaultWarehouseController.defaultWarehouse}');
  //   transferController.transferToControllerInTransferOut.text = '';
  //   transferController.transferFromControllerInTransferOut.text = '';
  //   transferController.setTransferFromIdInTransferOut(id);
  // }
  @override
  void initState() {
    transferController.setIsSubmitAndPreviewClicked(false);
    transferController.rowsInListViewInTransferOut = [];
    transferController.orderLinesInTransferOutList = {};
    transferController.listViewLengthInTransferOut = 50;
    transferController.increment = 50;
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    getFieldsForCreateTransferFromBack();
    warehouseController.getWarehousesFromBack();
    transferController.resetTransferOut();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isInfoFetched
        ? GetBuilder<TransferController>(
          builder: (transferCont) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              height: MediaQuery.of(context).size.height * 0.85,
              child: SingleChildScrollView(
                child: GetBuilder<HomeController>(
                  builder: (homeCont) {
                    double containerItemRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.63
                            : MediaQuery.of(context).size.width * 0.78;

                    double firstCol =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.35
                            : MediaQuery.of(context).size.width * 0.40;
                    double secondCol =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.3
                            : MediaQuery.of(context).size.width * 0.4;
                    double refRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.18
                            : MediaQuery.of(context).size.width * 0.21;
                    double refFieldWidth =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.15
                            : MediaQuery.of(context).size.width * 0.18;
                    double transfer =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.25
                            : MediaQuery.of(context).size.width * 0.30;
                    double dateRow =
                        homeCont.isMenuOpened
                            ? MediaQuery.of(context).size.width * 0.20
                            : MediaQuery.of(context).size.width * 0.25;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [PageTitle(text: 'transfer_out'.tr)],
                        ),
                        gapH16,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                UnderTitleBtn(
                                  text: 'preview'.tr,
                                  onTap: () {
                                    // setState(() {
                                    //   progressVar += 1;
                                    // });
                                    bool isThereItemsEmpty = false;
                                    for (var map
                                        in transferCont
                                            .rowsInListViewInTransferOut) {
                                      if (map!["itemId"] == '' ||
                                          map!["qty"] == '' ||
                                          map!["qty"] == '0') {
                                        setState(() {
                                          isThereItemsEmpty = true;
                                        });
                                        break;
                                      }
                                    }
                                    if (transferController
                                            .transferToIdInTransferOut ==
                                        transferController
                                            .transferFromIdInTransferOut) {
                                      CommonWidgets.snackBar(
                                        'error',
                                        'The source warehouse  must not be the same as destination warehouse',
                                      );
                                    } else if (isThereItemsEmpty) {
                                      CommonWidgets.snackBar(
                                        'error',
                                        'check all order lines and enter the required fields',
                                      );
                                    } else {
                                      if (transferController
                                              .transferToIdInTransferOut !=
                                          '') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return PrintTransferIn(
                                                isInTransferOut: true,
                                                transferNumber: transferNumber,
                                                receivedDate: '',
                                                creationDate:
                                                    dateController.text,
                                                ref: refController.text,
                                                transferTo:
                                                    selectedDestWrhs ?? '',
                                                receivedUser: '',
                                                senderUser:
                                                    homeController.userName,
                                                status: 'sent',
                                                transferFrom:
                                                    selectedSrcWrhs ?? '',
                                                rowsInListViewInTransfer:
                                                    transferCont
                                                        .rowsInListViewInTransferOut,
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        CommonWidgets.snackBar(
                                          'error',
                                          'you must choose warehouses first',
                                        );
                                      }
                                    }
                                  },
                                ),
                                UnderTitleBtn(
                                  text: 'submit_and_preview'.tr,
                                  onTap: () async {
                                    bool isThereItemsEmpty = false;
                                    for (var map
                                        in transferCont
                                            .rowsInListViewInTransferOut) {
                                      if (map!["itemId"] == '' ||
                                          map!["transferredQty"] == '' ||
                                          map!["transferredQty"] == '0') {
                                        setState(() {
                                          isThereItemsEmpty = true;
                                        });
                                        break;
                                      }
                                    }
                                    if (transferController
                                            .transferToIdInTransferOut ==
                                        transferController
                                            .transferFromIdInTransferOut) {
                                      CommonWidgets.snackBar(
                                        'error',
                                        'The source warehouse  must not be the same as destination warehouse',
                                      );
                                    } else if (isThereItemsEmpty) {
                                      CommonWidgets.snackBar(
                                        'error',
                                        'check all order lines and enter the required fields',
                                      );
                                    } else {
                                      var res = await addTransferOut(
                                        transferController
                                            .transferToIdInTransferOut,
                                        transferController
                                            .transferFromIdInTransferOut,
                                        refController.text,
                                        '',
                                        dateController.text,
                                        transferController
                                            .rowsInListViewInTransferOut,
                                      );
                                      if (res['success'] == true) {
                                        transferCont
                                            .setIsSubmitAndPreviewClicked(true);
                                        CommonWidgets.snackBar(
                                          'Success',
                                          res['message'],
                                        );
                                        // ignore: use_build_context_synchronously
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return PrintTransferIn(
                                                isInTransferOut: true,
                                                transferNumber: transferNumber,
                                                receivedDate: '',
                                                creationDate:
                                                    dateController.text,
                                                ref: refController.text,
                                                transferTo:
                                                    selectedDestWrhs ?? '',
                                                receivedUser: '',
                                                senderUser:
                                                    homeController.userName,
                                                status: 'sent',
                                                transferFrom:
                                                    selectedSrcWrhs ?? '',
                                                rowsInListViewInTransfer:
                                                    transferCont
                                                        .rowsInListViewInTransferOut,
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        CommonWidgets.snackBar(
                                          'error',
                                          res['message'] ?? 'error'.tr,
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ReusableTimeLineTile(
                                  id: 0,
                                  progressVar: progressVar,
                                  isFirst: true,
                                  isLast: false,
                                  isPast: true,
                                  text: 'processing'.tr,
                                ),
                                ReusableTimeLineTile(
                                  id: 1,
                                  progressVar: progressVar,
                                  isFirst: false,
                                  isLast: false,
                                  isPast: false,
                                  text: 'pending'.tr,
                                ),
                                ReusableTimeLineTile(
                                  id: 2,
                                  progressVar: progressVar,
                                  isFirst: false,
                                  isLast: true,
                                  isPast: false,
                                  text: 'received'.tr,
                                ),
                              ],
                            ),
                          ],
                        ),
                        gapH16,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Others.divider),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(9),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: firstCol,
                                // width: MediaQuery.of(context).size.width * 0.35,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        isInfoFetched
                                            ? Text(
                                              transferNumber,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color:
                                                    TypographyColor.titleTable,
                                              ),
                                            )
                                            : const CircularProgressIndicator(),
                                        SizedBox(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.05,
                                        ),
                                        DialogTextField(
                                          textEditingController: refController,
                                          text: '${'ref'.tr}:',
                                          hint: 'manual_reference'.tr,
                                          rowWidth: refRow,
                                          textFieldWidth: refFieldWidth,
                                          // rowWidth:
                                          //     MediaQuery.of(context).size.width *
                                          //         0.18,
                                          // textFieldWidth:
                                          //     MediaQuery.of(context).size.width *
                                          //         0.15,
                                          validationFunc: (val) {},
                                        ),
                                      ],
                                    ),
                                    gapH16,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${'transfer_from'.tr}*'),
                                        GetBuilder<WarehouseController>(
                                          builder: (cont) {
                                            return DropdownMenu<String>(
                                              width: transfer,
                                              // MediaQuery.of(context).size.width *
                                              //     0.25,
                                              // requestFocusOnTap: false,
                                              enableSearch: true,
                                              controller:
                                                  transferCont
                                                      .transferFromControllerInTransferOut,
                                              hintText: '${'search'.tr}...',
                                              inputDecorationTheme: InputDecorationTheme(
                                                // filled: true,
                                                hintStyle: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                      20,
                                                      0,
                                                      25,
                                                      5,
                                                    ),
                                                // outlineBorder: BorderSide(color: Colors.black,),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Primary.primary
                                                            .withAlpha(
                                                              (0.2 * 255)
                                                                  .toInt(),
                                                            ),
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(9),
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Primary.primary
                                                            .withAlpha(
                                                              (0.4 * 255)
                                                                  .toInt(),
                                                            ),
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(9),
                                                          ),
                                                    ),
                                              ),
                                              // menuStyle: ,
                                              menuHeight: 250,
                                              dropdownMenuEntries:
                                                  cont.warehousesNameList.map<
                                                    DropdownMenuEntry<String>
                                                  >((String option) {
                                                    return DropdownMenuEntry<
                                                      String
                                                    >(
                                                      value: option,
                                                      label: option,
                                                    );
                                                  }).toList(),
                                              enableFilter: true,
                                              onSelected: (String? val) {
                                                transferCont.clearList();
                                                transferCont
                                                    .setListViewLengthInTransferOut(
                                                      50,
                                                    );
                                                setState(() {
                                                  selectedSrcWrhs = val!;
                                                });
                                                var index = cont
                                                    .warehousesNameList
                                                    .indexOf(val!);
                                                transferCont
                                                    .setTransferFromIdInTransferOut(
                                                      cont.warehouseIdsList[index],
                                                    );
                                                transferController
                                                    .getAllProductsFromBack(
                                                      transferCont
                                                          .transferFromIdInTransferOut,
                                                      '',
                                                      '',
                                                    );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    gapH16,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${'transfer_to'.tr}*'),
                                        GetBuilder<WarehouseController>(
                                          builder: (cont) {
                                            return DropdownMenu<String>(
                                              width: transfer,
                                              // MediaQuery.of(context).size.width *
                                              //     0.25,
                                              // requestFocusOnTap: false,
                                              enableSearch: true,
                                              controller:
                                                  transferCont
                                                      .transferToControllerInTransferOut,
                                              hintText: '${'search'.tr}...',
                                              inputDecorationTheme: InputDecorationTheme(
                                                // filled: true,
                                                hintStyle: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                      20,
                                                      0,
                                                      25,
                                                      5,
                                                    ),
                                                // outlineBorder: BorderSide(color: Colors.black,),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Primary.primary
                                                            .withAlpha(
                                                              (0.2 * 255)
                                                                  .toInt(),
                                                            ),
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(9),
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Primary.primary
                                                            .withAlpha(
                                                              (0.4 * 255)
                                                                  .toInt(),
                                                            ),
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                            Radius.circular(9),
                                                          ),
                                                    ),
                                              ),
                                              // menuStyle: ,
                                              menuHeight: 250,
                                              dropdownMenuEntries:
                                                  cont.warehousesNameList.map<
                                                    DropdownMenuEntry<String>
                                                  >((String option) {
                                                    return DropdownMenuEntry<
                                                      String
                                                    >(
                                                      value: option,
                                                      label: option,
                                                    );
                                                  }).toList(),
                                              enableFilter: true,
                                              onSelected: (String? val) async {
                                                // transferCont.clearList();
                                                // transferCont.setListViewLengthInTransferOut(50);
                                                setState(() {
                                                  selectedDestWrhs = val!;
                                                });
                                                var index = cont
                                                    .warehousesNameList
                                                    .indexOf(val!);
                                                transferCont
                                                    .setTransferToIdInTransferOut(
                                                      cont.warehouseIdsList[index],
                                                    );
                                                for (
                                                  int i = 0;
                                                  i <
                                                      transferCont
                                                          .rowsInListViewInTransferOut
                                                          .length;
                                                  i++
                                                ) {
                                                  var p = await getQTyOfItemInWarehouse(
                                                    transferCont
                                                        .rowsInListViewInTransferOut[i]['itemId'],
                                                    transferController
                                                        .transferToIdInTransferOut,
                                                  );
                                                  if ('$p' != '[]') {
                                                    String
                                                    val = formatPackagingInfo(
                                                      p['qtyOnHandPackages'] ??
                                                          {},
                                                    );
                                                    setState(() {
                                                      transferCont
                                                              .rowsInListViewInTransferOut[i]['qtyOnHandPackages'] =
                                                          val.isNotEmpty
                                                              ? val
                                                              : '0 ${p['item']['packageUnitName'] ?? ''}';
                                                    });
                                                  }
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: secondCol,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: transfer,
                                      // MediaQuery.of(context).size.width * 0.25,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('date'.tr),
                                          DialogDateTextField(
                                            textEditingController:
                                                dateController,
                                            text: '',
                                            textFieldWidth: dateRow,
                                            // MediaQuery.of(context).size.width *
                                            //     0.15,
                                            validationFunc: (val) {},
                                            onChangedFunc: (val) {
                                              dateController.text = val;
                                            },
                                            onDateSelected: (value) {
                                              dateController.text = value;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    gapH100,
                                    Text('${'total_qty'.tr}: '),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        gapH16,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 0.0,
                              direction: Axis.horizontal,
                              children:
                                  tabsList
                                      .map(
                                        (element) => _buildTabChipItem(
                                          element,
                                          tabsList.indexOf(element),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                        // tabsContent[selectedTabIndex],
                        transferCont.selectedTabIndex == 0
                            ? Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    // horizontal:
                                    // MediaQuery.of(context).size.width *
                                    //     0.01,
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Primary.primary,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(6),
                                    ),
                                  ),
                                  child: GetBuilder<HomeController>(
                                    builder: (homeCont) {
                                      double bigWidth =
                                          homeCont.isMenuOpened
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.15
                                              : MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.19;
                                      double mediumWidth =
                                          homeCont.isMenuOpened
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.12
                                              : MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.16;
                                      double smallWidth =
                                          homeCont.isMenuOpened
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.07
                                              : MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.09;
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.02,
                                          ),
                                          TableTitle(
                                            text: 'item'.tr,
                                            width: mediumWidth,
                                          ),
                                          TableTitle(
                                            text: 'description'.tr,
                                            width: bigWidth,
                                          ),
                                          TableTitle(
                                            text:
                                                'qty_available_at_src_wrhs'.tr,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.1,
                                          ),
                                          // TableTitle(
                                          //   text: 'pack'.tr,
                                          //   width: MediaQuery.of(context).size.width *
                                          //       0.03,
                                          // ),
                                          TableTitle(
                                            text:
                                                'qty_available_at_dest_wrhs'.tr,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.1,
                                          ),
                                          // TableTitle(
                                          //   text: 'pack'.tr,
                                          //   width: MediaQuery.of(context).size.width *
                                          //       0.03,
                                          // ),
                                          TableTitle(
                                            text: 'qty_to_trx'.tr,
                                            width: smallWidth,
                                          ),
                                          TableTitle(
                                            text: 'pack'.tr,
                                            width: smallWidth,
                                          ),
                                          TableTitle(
                                            text: 'more_options'.tr,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.07,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                        0.01,
                                  ),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6),
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height:
                                            transferCont
                                                .listViewLengthInTransferOut,
                                        child: ListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            // horizontal:  MediaQuery.of(context).size.width *
                                            //     0.01,
                                            vertical: 10,
                                          ),
                                          itemCount:
                                              transferCont
                                                  .rowsInListViewInTransferOut
                                                  .length,
                                          itemBuilder:
                                              (
                                                context,
                                                index,
                                              ) => ReusableItemRow(
                                                isMobile: false,
                                                index: index,
                                                info:
                                                    transferCont
                                                        .rowsInListViewInTransferOut[index],
                                              ),
                                          // itemCount: transferCont.orderLinesInTransferOutList.keys.toList()
                                          //     .length, //products is data from back res
                                          // itemBuilder: (context, index) {
                                          //   var keys=transferCont.orderLinesInTransferOutList.keys.toList();
                                          //   return transferCont.orderLinesInTransferOutList[keys[index]];}
                                          //     Row(
                                          //   children: [
                                          //     Container(
                                          //       width:  20,// MediaQuery.of(context).size.width * 0.03,
                                          //       height: 20,
                                          //       margin:
                                          //       const EdgeInsets.symmetric(
                                          //           vertical: 15),
                                          //       decoration: const BoxDecoration(
                                          //         image: DecorationImage(
                                          //           image: AssetImage(
                                          //               'assets/images/newRow.png'),
                                          //           fit: BoxFit.contain,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //     cont.orderLinesInTransferOutList[index],
                                          //     SizedBox(
                                          //       width: MediaQuery.of(context)
                                          //           .size
                                          //           .width *
                                          //           0.035,
                                          //       child: const ReusableMore(
                                          //         itemsList: [],
                                          //       ),
                                          //     ),
                                          //     SizedBox(
                                          //       width: MediaQuery.of(context)
                                          //           .size
                                          //           .width *
                                          //           0.035,
                                          //       child: InkWell(
                                          //         onTap: () {
                                          //           setState(() {
                                          //             cont.removeFromOrderLinesInTransferOutList(
                                          //                 index);
                                          //             listViewLength =
                                          //                 listViewLength -
                                          //                     increment;
                                          //           });
                                          //         },
                                          //         child: Icon(
                                          //           Icons.delete_outline,
                                          //           color: Primary.primary,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ReusableAddCard(
                                            text: 'item'.tr,
                                            onTap: () {
                                              if (transferCont
                                                          .transferToIdInTransferOut ==
                                                      '' ||
                                                  transferCont
                                                          .transferFromIdInTransferOut ==
                                                      '') {
                                                CommonWidgets.snackBar(
                                                  'error',
                                                  'you must choose warehouses first',
                                                );
                                              } else if (transferCont
                                                  .productsCodes
                                                  .isEmpty) {
                                                CommonWidgets.snackBar(
                                                  'error',
                                                  'The warehouse is empty. You must fill the warehouse with products first',
                                                );
                                              } else {
                                                addNewItem();
                                              }
                                            },
                                          ),
                                          gapW32,
                                          ReusableAddCard(
                                            text: 'image'.tr,
                                            onTap: () {
                                              // addNewImage();
                                            },
                                          ),
                                          gapW32,
                                          ReusableAddCard(
                                            text: 'note'.tr,
                                            onTap: () {
                                              // addNewNote();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            : const SizedBox(),
                        gapH28,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ReusableButtonWithColor(
                              width: MediaQuery.of(context).size.width * 0.15,
                              height: 45,
                              isDisable:
                                  transferCont
                                      .rowsInListViewInTransferOut
                                      .isEmpty,
                              onTapFunction: () async {
                                bool isThereItemsEmpty = false;
                                for (var map
                                    in transferCont
                                        .rowsInListViewInTransferOut) {
                                  if (map!["itemId"] == '' ||
                                      map!["transferredQty"] == '' ||
                                      map!["transferredQty"] == '0') {
                                    setState(() {
                                      isThereItemsEmpty = true;
                                    });
                                    break;
                                  }
                                }
                                if (transferController
                                        .transferToIdInTransferOut ==
                                    transferController
                                        .transferFromIdInTransferOut) {
                                  CommonWidgets.snackBar(
                                    'error',
                                    'The source warehouse  must not be the same as destination warehouse',
                                  );
                                } else if (isThereItemsEmpty) {
                                  CommonWidgets.snackBar(
                                    'error',
                                    'check all order lines and enter the required fields',
                                  );
                                } else {
                                  var res = await addTransferOut(
                                    transferController
                                        .transferToIdInTransferOut,
                                    transferController
                                        .transferFromIdInTransferOut,
                                    refController.text,
                                    '',
                                    dateController.text,
                                    transferController
                                        .rowsInListViewInTransferOut,
                                  );
                                  if (res['success'] == true) {
                                    CommonWidgets.snackBar(
                                      'Success',
                                      res['message'],
                                    );
                                    transferController
                                        .getAllTransactionsFromBack();
                                    homeController.selectedTab.value =
                                        'transfers';
                                  } else {
                                    CommonWidgets.snackBar(
                                      'error',
                                      res['message'] ?? 'error'.tr,
                                    );
                                  }
                                }
                              },
                              btnText: 'submit'.tr,
                            ),
                          ],
                        ),
                        gapH40,
                      ],
                    );
                  },
                ),
              ),
            );
          },
        )
        : const CircularProgressIndicator();
  }

  Widget _buildTabChipItem(String name, int index) {
    return GetBuilder<TransferController>(
      builder: (transferCont) {
        return GestureDetector(
          onTap: () {
            transferCont.setSelectedTabIndex(index);
          },
          child: ClipPath(
            clipper: const ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(9),
                ),
              ),
            ),
            child: Container(
              width:
                  name.length * 10, // MediaQuery.of(context).size.width * 0.09,
              height: MediaQuery.of(context).size.height * 0.07,
              decoration: BoxDecoration(
                color:
                    transferCont.selectedTabIndex == index
                        ? Primary.p20
                        : Colors.white,
                border:
                    transferCont.selectedTabIndex == index
                        ? Border(
                          top: BorderSide(color: Primary.primary, width: 3),
                        )
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                    spreadRadius: 9,
                    blurRadius: 9,
                    // offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Primary.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int transferOutCounter = 0;
  addNewItem() {
    setState(() {
      transferOutCounter += 1;
    });
    transferController.incrementListViewLengthInTransferOut(
      transferController.increment,
    );
    var p = {
      'itemId': '',
      'itemCode': '',
      'mainDescription': '',
      'transferredQty': '',
      'transferredQtyPackageName': '',
      'qtyOnHandPackages': '0',
      'qtyOnHandPackagesInSource': '0',
      'productsPackages': <String>[],
    };
    transferController.addToRowsInListViewInTransferOut(p);
  }

  addNewImage() {
    // setState(() {
    // listViewLength = listViewLength + 100;
    transferController.incrementListViewLengthInTransferOut(100);

    // });
    Widget p = GetBuilder<TransferController>(
      builder: (cont) {
        return InkWell(
          onTap: () async {
            final image = await ImagePickerHelper.pickImage();
            setState(() {
              imageFile = image!;
              cont.changeBoolVarInTransferOut(true);
              cont.increaseImageSpaceInTransferOut(90);
              // listViewLength = listViewLength + (cont.imageSpaceHeightInTransferOut) + 10;
              transferController.incrementListViewLengthInTransferOut(
                (cont.imageSpaceHeightInTransferOut) + 10,
              );
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: DottedBorder(
              dashPattern: const [10, 10],
              color: Others.borderColor,
              radius: const Radius.circular(9),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.63,
                height: cont.imageSpaceHeightInTransferOut,
                child:
                    cont.imageAvailableInTransferOut
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.memory(
                              imageFile,
                              height: cont.imageSpaceHeightInTransferOut,
                            ),
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            gapW20,
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: Others.iconColor,
                              size: 32,
                            ),
                            gapW20,
                            Text(
                              'drag_drop_image'.tr,
                              style: TextStyle(
                                color: TypographyColor.textTable,
                              ),
                            ),
                            Text(
                              'browse'.tr,
                              style: TextStyle(color: Primary.primary),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        );
      },
    );
    int index = transferController.orderLinesInTransferOutList.length + 1;
    transferController.addToOrderLinesInTransferOutList('$index', p);
  }

  addNewNote() {
    // setState(() {
    //   listViewLength = listViewLength + increment;
    // });
    transferController.incrementListViewLengthInTransferOut(
      transferController.increment,
    );
    Widget p = Container(
      width: MediaQuery.of(context).size.width * 0.63,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ReusableTextField(
        textEditingController: TextEditingController(), //todo
        isPasswordField: false,
        hint: 'note'.tr,
        onChangedFunc: (val) {},
        validationFunc: (val) {},
      ),
    );
    int index = transferController.orderLinesInTransferOutList.length + 1;
    transferController.addToOrderLinesInTransferOutList('$index', p);
  }

  List<Step> getSteps() => [
    Step(
      title: const Text(''),
      content: Container(
        //page
      ),
      isActive: currentStep >= 0,
    ),
    Step(
      title: const Text(''),
      content: Container(),
      isActive: currentStep >= 1,
    ),
    Step(
      title: const Text(''),
      content: Container(),
      isActive: currentStep >= 2,
    ),
  ];
}

class ReusableItemRow extends StatefulWidget {
  const ReusableItemRow({
    super.key,
    required this.index,
    required this.info,
    this.isMobile = false,
  });
  final int index;
  final bool isMobile;
  final Map info;
  @override
  State<ReusableItemRow> createState() => _ReusableItemRowState();
}

class _ReusableItemRowState extends State<ReusableItemRow> {
  String qty = '0';
  TextEditingController qtyController = TextEditingController();
  TextEditingController packageController = TextEditingController();
  TextEditingController productController = TextEditingController();
  final TransferController transferController = Get.find();
  List<String> productsPackages = [];
  String selectedPackage = '';
  String selectedItemId = '';
  bool isDataFetched = false;

  String defaultTransactionPackageType = '';
  getQTyOfItemInSourceWarehouseFromBack() async {
    var p = await getQTyOfItemInWarehouse(
      selectedItemId,
      transferController.transferFromIdInTransferOut,
    );
    if ('$p' != '[]') {
      setState(() {
        if (p['item']['packageUnitName'] != null) {
          productsPackages.add(p['item']['packageUnitName']);
        }
        if (p['item']['packageSetName'] != null) {
          productsPackages.add(p['item']['packageSetName']);
        }
        if (p['item']['packageSupersetName'] != null) {
          productsPackages.add(p['item']['packageSupersetName']);
        }
        if (p['item']['packagePaletteName'] != null) {
          productsPackages.add(p['item']['packagePaletteName']);
        }
        if (p['item']['packageContainerName'] != null) {
          productsPackages.add(p['item']['packageContainerName']);
        }
        defaultTransactionPackageType =
            '${p['item']['defaultTransactionPackageType'] ?? '1'}';
        if (defaultTransactionPackageType == '1') {
          packageController.text = p['item']['packageUnitName'];
        } else if (defaultTransactionPackageType == '2') {
          packageController.text = p['item']['packageSetName'];
        } else if (defaultTransactionPackageType == '3') {
          packageController.text = p['item']['packageSupersetName'];
        } else if (defaultTransactionPackageType == '4') {
          packageController.text = p['item']['packagePaletteName'];
        } else if (defaultTransactionPackageType == '5') {
          packageController.text = p['item']['packageContainerName'];
        }
        transferController.setPackageNameInTransferOut(
          widget.index,
          packageController.text,
        );
        transferController.setProductsPackagesInTransferOut(
          widget.index,
          productsPackages,
        );
        transferController.setItemDescriptionInTransferOut(
          widget.index,
          p['item']['mainDescription'] ?? '',
        );
        String val = formatPackagingInfo(p['qtyOnHandPackages'] ?? {});
        transferController.setQtyOnHandPackagesInSourceInTransferOut(
          widget.index,
          val.isNotEmpty ? val : '0 ${p['item']['packageUnitName'] ?? ''}',
        );
        isDataFetched = true;
      });
    }
  }

  getQTyOfItemInDesWarehouseFromBack() async {
    var p = await getQTyOfItemInWarehouse(
      selectedItemId,
      transferController.transferToIdInTransferOut,
    );
    if ('$p' != '[]') {
      String val = formatPackagingInfo(p['qtyOnHandPackages'] ?? {});
      transferController.setQtyOnHandPackagesTransferOut(
        widget.index,
        val.isNotEmpty ? val : '0 ${p['item']['packageUnitName'] ?? ''}',
      );
      setState(() {
        isDataFetched = true;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    qtyController.text =
        transferController.rowsInListViewInTransferOut[widget
            .index]['transferredQty'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(
      builder: (cont) {
        packageController.text =
            cont.rowsInListViewInTransferOut[widget
                .index]['transferredQtyPackageName'];
        productController.text =
            cont.rowsInListViewInTransferOut[widget.index]['itemCode'];
        return Container(
          // width: MediaQuery.of(context).size.width * 0.63,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Form(
            key: _formKey,
            child: GetBuilder<HomeController>(
              builder: (homeCont) {
                double bigWidth =
                    homeCont.isMenuOpened
                        ? MediaQuery.of(context).size.width * 0.15
                        : MediaQuery.of(context).size.width * 0.19;
                double mediumWidth =
                    homeCont.isMenuOpened
                        ? MediaQuery.of(context).size.width * 0.12
                        : MediaQuery.of(context).size.width * 0.16;
                double smallWidth =
                    homeCont.isMenuOpened
                        ? MediaQuery.of(context).size.width * 0.07
                        : MediaQuery.of(context).size.width * 0.09;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width:
                          widget.isMobile
                              ? 20
                              : MediaQuery.of(context).size.width * 0.02,
                      height: 20,
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/newRow.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    widget.isMobile ? gapW4 : SizedBox(),
                    DropdownMenu<String>(
                      width: widget.isMobile ? 150 : mediumWidth,
                      // requestFocusOnTap: false,
                      enableSearch: true,
                      controller: productController,
                      hintText: '${'search'.tr}...',
                      inputDecorationTheme: InputDecorationTheme(
                        // filled: true,
                        hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                        contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                        // outlineBorder: BorderSide(color: Colors.black,),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Primary.primary.withAlpha(
                              (0.2 * 255).toInt(),
                            ),
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(9),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Primary.primary.withAlpha(
                              (0.4 * 255).toInt(),
                            ),
                            width: 2,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(9),
                          ),
                        ),
                      ),
                      // menuStyle: ,
                      menuHeight: 250,
                      dropdownMenuEntries:
                          cont.productsCodes.map<DropdownMenuEntry<String>>((
                            String option,
                          ) {
                            return DropdownMenuEntry<String>(
                              value: option,
                              label: option,
                            );
                          }).toList(),
                      enableFilter: true,
                      onSelected: (String? value) {
                        productController.text = value!;
                        setState(() {
                          // pro = value;
                          selectedItemId =
                              '${cont.productsIds[cont.productsCodes.indexOf(value)]}';
                        });
                        cont.setItemIdInTransferOut(
                          widget.index,
                          selectedItemId,
                        );
                        cont.setItemNameInTransferOut(widget.index, value);
                        getQTyOfItemInSourceWarehouseFromBack();
                        getQTyOfItemInDesWarehouseFromBack();
                      },
                    ),
                    widget.isMobile ? gapW4 : SizedBox(),
                    ReusableShowInfoCard(
                      text:
                          cont.rowsInListViewInTransferOut[widget
                              .index]['mainDescription'],
                      width: widget.isMobile ? 200 : bigWidth,
                    ),
                    widget.isMobile ? gapW4 : SizedBox(),
                    ReusableShowInfoCard(
                      text:
                          cont.rowsInListViewInTransferOut[widget
                              .index]['qtyOnHandPackagesInSource'],
                      width:
                          widget.isMobile
                              ? 200
                              : MediaQuery.of(context).size.width * 0.1,
                    ),
                    widget.isMobile ? gapW4 : SizedBox(),
                    ReusableShowInfoCard(
                      text:
                          cont.rowsInListViewInTransferOut[widget
                              .index]['qtyOnHandPackages'],
                      width:
                          widget.isMobile
                              ? 200
                              : MediaQuery.of(context).size.width * 0.1,
                    ),
                    widget.isMobile ? gapW4 : SizedBox(),
                    SizedBox(
                      width: widget.isMobile ? 150 : smallWidth,
                      child: ReusableNumberField(
                        textEditingController: qtyController,
                        isPasswordField: false,
                        isCentered: true,
                        hint: '0',
                        onChangedFunc: (val) {
                          setState(() {
                            qty = val;
                          });
                          _formKey.currentState!.validate();
                          cont.setEnteredQtyInTransferOut(widget.index, qty);
                        },
                        validationFunc: (String? value) {
                          if (value!.isEmpty || double.parse(value) <= 0) {
                            return 'must be >0';
                          }
                          return null;
                        },
                      ),
                    ),
                    widget.isMobile ? gapW4 : SizedBox(),
                    DialogDropMenu(
                      optionsList:
                          cont.rowsInListViewInTransferOut[widget
                              .index]['productsPackages'],
                      text: '',
                      hint: '',
                      controller: packageController,
                      rowWidth: widget.isMobile ? 80 : smallWidth,
                      textFieldWidth: widget.isMobile ? 80 : smallWidth,
                      onSelected: (value) {
                        cont.setPackageNameInTransferOut(widget.index, value);
                        setState(() {
                          selectedPackage = value;
                        });
                      },
                    ),
                    widget.isMobile ? gapW4 : SizedBox(),
                    SizedBox(
                      width:
                          widget.isMobile
                              ? 100
                              : MediaQuery.of(context).size.width * 0.07,
                      child: Row(
                        children: [
                          SizedBox(
                            width:
                                widget.isMobile
                                    ? 50
                                    : MediaQuery.of(context).size.width * 0.03,
                            child: const ReusableMore(itemsList: []),
                          ),
                          SizedBox(
                            width:
                                widget.isMobile
                                    ? 50
                                    : MediaQuery.of(context).size.width * 0.03,
                            child: InkWell(
                              onTap: () {
                                // setState(() {
                                // cont.removeFromOrderLinesInTransferOutList('${widget.index}');
                                // cont.removeFromItemsListInTransferOut('${widget.index}');
                                transferController
                                    .decrementListViewLengthInTransferOut(
                                      transferController.increment,
                                    );
                                transferController
                                    .removeFromRowsInListViewInTransferOut(
                                      widget.index,
                                    );
                                // });
                              },
                              child: Icon(
                                Icons.delete_outline,
                                color: Primary.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class MobileTransferOut extends StatefulWidget {
  const MobileTransferOut({super.key});

  @override
  State<MobileTransferOut> createState() => _MobileTransferOutState();
}

class _MobileTransferOutState extends State<MobileTransferOut> {
  TextEditingController refController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  late Uint8List imageFile;
  int currentStep = 0;

  List tabsList = ['order_lines', 'other_information'];
  String? selectedSrcWrhs = '';
  String? selectedDestWrhs = '';
  final TransferController transferController = Get.find();
  final HomeController homeController = Get.find();
  final WarehouseController warehouseController = Get.find();
  int progressVar = 0;
  bool isInfoFetched = false;
  String transferNumber = '';
  getFieldsForCreateTransferFromBack() async {
    setState(() {
      currentStep = 0;
      transferController.selectedTabIndex = 0;
      selectedSrcWrhs = '';
      selectedDestWrhs = '';
      progressVar = 0;
      transferNumber = '';
      transferController.transferToControllerInTransferOut.text = '';
      transferController.transferFromControllerInTransferOut.text = '';
      transferController.setTransferToIdInTransferOut('');
      transferController.setTransferFromIdInTransferOut('');
    });
    var p = await getTransferOutDataForCreate();
    transferNumber = p['transferNumber'];
    if ('$p' != '[]') {
      setState(() {
        transferNumber = '${p['transferNumber']}';
        isInfoFetched = true;
      });
    }
  }

  @override
  void initState() {
    transferController.setIsSubmitAndPreviewClicked(false);
    transferController.rowsInListViewInTransferOut = [];
    transferController.orderLinesInTransferOutList = {};
    transferController.listViewLengthInTransferOut = 50;
    transferController.increment = 50;
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    getFieldsForCreateTransferFromBack();
    warehouseController.getWarehousesFromBack();
    transferController.resetTransferOut();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isInfoFetched
        ? GetBuilder<TransferController>(
          builder: (transferCont) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              height: MediaQuery.of(context).size.height * 0.85,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [PageTitle(text: 'transfer_out'.tr)],
                    ),
                    gapH16,
                    Row(
                      children: [
                        UnderTitleBtn(
                          text: 'preview'.tr,
                          onTap: () {
                            // setState(() {
                            //   progressVar += 1;
                            // });
                            bool isThereItemsEmpty = false;
                            for (var map
                                in transferCont.rowsInListViewInTransferOut) {
                              if (map!["itemId"] == '' ||
                                  map!["qty"] == '' ||
                                  map!["qty"] == '0') {
                                setState(() {
                                  isThereItemsEmpty = true;
                                });
                                break;
                              }
                            }
                            if (transferController.transferToIdInTransferOut ==
                                transferController
                                    .transferFromIdInTransferOut) {
                              CommonWidgets.snackBar(
                                'error',
                                'The source warehouse  must not be the same as destination warehouse',
                              );
                            } else if (isThereItemsEmpty) {
                              CommonWidgets.snackBar(
                                'error',
                                'check all order lines and enter the required fields',
                              );
                            } else {
                              if (transferController
                                      .transferToIdInTransferOut !=
                                  '') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return PrintTransferIn(
                                        isInTransferOut: true,
                                        transferNumber: transferNumber,
                                        receivedDate: '',
                                        creationDate: dateController.text,
                                        ref: refController.text,
                                        transferTo: selectedDestWrhs ?? '',
                                        receivedUser: '',
                                        senderUser: homeController.userName,
                                        status: 'sent',
                                        transferFrom: selectedSrcWrhs ?? '',
                                        rowsInListViewInTransfer:
                                            transferCont
                                                .rowsInListViewInTransferOut,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                CommonWidgets.snackBar(
                                  'error',
                                  'you must choose warehouses first',
                                );
                              }
                            }
                          },
                        ),
                        UnderTitleBtn(
                          text: 'submit_and_preview'.tr,
                          onTap: () async {
                            bool isThereItemsEmpty = false;
                            for (var map
                                in transferCont.rowsInListViewInTransferOut) {
                              if (map!["itemId"] == '' ||
                                  map!["transferredQty"] == '' ||
                                  map!["transferredQty"] == '0') {
                                setState(() {
                                  isThereItemsEmpty = true;
                                });
                                break;
                              }
                            }
                            if (transferController.transferToIdInTransferOut ==
                                transferController
                                    .transferFromIdInTransferOut) {
                              CommonWidgets.snackBar(
                                'error',
                                'The source warehouse  must not be the same as destination warehouse',
                              );
                            } else if (isThereItemsEmpty) {
                              CommonWidgets.snackBar(
                                'error',
                                'check all order lines and enter the required fields',
                              );
                            } else {
                              var res = await addTransferOut(
                                transferController.transferToIdInTransferOut,
                                transferController.transferFromIdInTransferOut,
                                refController.text,
                                '',
                                dateController.text,
                                transferController.rowsInListViewInTransferOut,
                              );
                              if (res['success'] == true) {
                                transferCont.setIsSubmitAndPreviewClicked(true);
                                CommonWidgets.snackBar(
                                  'Success',
                                  res['message'],
                                );
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return PrintTransferIn(
                                        isInTransferOut: true,
                                        transferNumber: transferNumber,
                                        receivedDate: '',
                                        creationDate: dateController.text,
                                        ref: refController.text,
                                        transferTo: selectedDestWrhs ?? '',
                                        receivedUser: '',
                                        senderUser: homeController.userName,
                                        status: 'sent',
                                        transferFrom: selectedSrcWrhs ?? '',
                                        rowsInListViewInTransfer:
                                            transferCont
                                                .rowsInListViewInTransferOut,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                CommonWidgets.snackBar(
                                  'error',
                                  res['message'] ?? 'error'.tr,
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    gapH16,
                    Row(
                      children: [
                        ReusableTimeLineTile(
                          id: 0,
                          progressVar: progressVar,
                          isFirst: true,
                          isLast: false,
                          isPast: true,
                          isDesktop: false,
                          text: 'processing'.tr,
                        ),
                        ReusableTimeLineTile(
                          id: 1,
                          progressVar: progressVar,
                          isFirst: false,
                          isLast: false,
                          isPast: false,
                          isDesktop: false,
                          text: 'pending'.tr,
                        ),
                        ReusableTimeLineTile(
                          id: 2,
                          progressVar: progressVar,
                          isFirst: false,
                          isLast: true,
                          isPast: false,
                          isDesktop: false,
                          text: 'received'.tr,
                        ),
                      ],
                    ),
                    gapH16,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Others.divider),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(9),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              isInfoFetched
                                  ? Text(
                                    transferNumber,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: TypographyColor.titleTable,
                                    ),
                                  )
                                  : const CircularProgressIndicator(),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                              ),
                              DialogTextField(
                                textEditingController: refController,
                                text: '${'ref'.tr}:',
                                hint: 'manual_reference'.tr,
                                rowWidth:
                                    MediaQuery.of(context).size.width * 0.45,
                                textFieldWidth:
                                    MediaQuery.of(context).size.width * 0.35,
                                validationFunc: (val) {},
                              ),
                            ],
                          ),
                          gapH16,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('date'.tr),
                              DialogDateTextField(
                                textEditingController: dateController,
                                text: '',
                                textFieldWidth:
                                    MediaQuery.of(context).size.width * 0.5,
                                validationFunc: (val) {},
                                onChangedFunc: (val) {
                                  dateController.text = val;
                                },
                                onDateSelected: (value) {
                                  dateController.text = value;
                                },
                              ),
                            ],
                          ),
                          gapH16,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${'transfer_from'.tr}*'),
                              GetBuilder<WarehouseController>(
                                builder: (cont) {
                                  return DropdownMenu<String>(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    // requestFocusOnTap: false,
                                    enableSearch: true,
                                    controller:
                                        transferCont
                                            .transferFromControllerInTransferOut,
                                    hintText: '${'search'.tr}...',
                                    inputDecorationTheme: InputDecorationTheme(
                                      // filled: true,
                                      hintStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        25,
                                        5,
                                      ),
                                      // outlineBorder: BorderSide(color: Colors.black,),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.2 * 255).toInt(),
                                          ),
                                          width: 1,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.4 * 255).toInt(),
                                          ),
                                          width: 2,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                    ),
                                    // menuStyle: ,
                                    menuHeight: 250,
                                    dropdownMenuEntries:
                                        cont.warehousesNameList
                                            .map<DropdownMenuEntry<String>>((
                                              String option,
                                            ) {
                                              return DropdownMenuEntry<String>(
                                                value: option,
                                                label: option,
                                              );
                                            })
                                            .toList(),
                                    enableFilter: true,
                                    onSelected: (String? val) {
                                      transferCont.clearList();
                                      transferCont
                                          .setListViewLengthInTransferOut(50);
                                      setState(() {
                                        selectedSrcWrhs = val!;
                                      });
                                      var index = cont.warehousesNameList
                                          .indexOf(val!);
                                      transferCont
                                          .setTransferFromIdInTransferOut(
                                            cont.warehouseIdsList[index],
                                          );
                                      transferController.getAllProductsFromBack(
                                        transferCont
                                            .transferFromIdInTransferOut,
                                        '',
                                        '',
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          gapH16,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${'transfer_to'.tr}*'),
                              GetBuilder<WarehouseController>(
                                builder: (cont) {
                                  return DropdownMenu<String>(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    // requestFocusOnTap: false,
                                    enableSearch: true,
                                    controller:
                                        transferCont
                                            .transferToControllerInTransferOut,
                                    hintText: '${'search'.tr}...',
                                    inputDecorationTheme: InputDecorationTheme(
                                      // filled: true,
                                      hintStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        25,
                                        5,
                                      ),
                                      // outlineBorder: BorderSide(color: Colors.black,),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.2 * 255).toInt(),
                                          ),
                                          width: 1,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.4 * 255).toInt(),
                                          ),
                                          width: 2,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                    ),
                                    // menuStyle: ,
                                    menuHeight: 250,
                                    dropdownMenuEntries:
                                        cont.warehousesNameList
                                            .map<DropdownMenuEntry<String>>((
                                              String option,
                                            ) {
                                              return DropdownMenuEntry<String>(
                                                value: option,
                                                label: option,
                                              );
                                            })
                                            .toList(),
                                    enableFilter: true,
                                    onSelected: (String? val) async {
                                      // transferCont.clearList();
                                      // transferCont.setListViewLengthInTransferOut(50);
                                      setState(() {
                                        selectedDestWrhs = val!;
                                      });
                                      var index = cont.warehousesNameList
                                          .indexOf(val!);
                                      transferCont.setTransferToIdInTransferOut(
                                        cont.warehouseIdsList[index],
                                      );
                                      for (
                                        int i = 0;
                                        i <
                                            transferCont
                                                .rowsInListViewInTransferOut
                                                .length;
                                        i++
                                      ) {
                                        var p = await getQTyOfItemInWarehouse(
                                          transferCont
                                              .rowsInListViewInTransferOut[i]['itemId'],
                                          transferController
                                              .transferToIdInTransferOut,
                                        );
                                        if ('$p' != '[]') {
                                          String val = formatPackagingInfo(
                                            p['qtyOnHandPackages'] ?? {},
                                          );
                                          setState(() {
                                            transferCont
                                                    .rowsInListViewInTransferOut[i]['qtyOnHandPackages'] =
                                                val.isNotEmpty
                                                    ? val
                                                    : '0 ${p['item']['packageUnitName'] ?? ''}';
                                          });
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    gapH16,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 0.0,
                          direction: Axis.horizontal,
                          children:
                              tabsList
                                  .map(
                                    (element) => _buildTabChipItem(
                                      element,
                                      tabsList.indexOf(element),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                    // tabsContent[selectedTabIndex],
                    transferCont.selectedTabIndex == 0
                        ? Column(
                          children: [
                            SingleChildScrollView(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 15,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Primary.primary,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                    Radius.circular(6),
                                                  ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TableTitle(
                                                  text: 'item'.tr,
                                                  width: 170,
                                                ),
                                                gapW4,
                                                TableTitle(
                                                  text: 'description'.tr,
                                                  width: 200,
                                                ),
                                                gapW4,
                                                TableTitle(
                                                  text:
                                                      'qty_available_at_src_wrhs'
                                                          .tr,
                                                  width: 200,
                                                ),
                                                gapW4,
                                                TableTitle(
                                                  text:
                                                      'qty_available_at_dest_wrhs'
                                                          .tr,
                                                  width: 200,
                                                ),
                                                gapW4,
                                                TableTitle(
                                                  text: 'qty_to_trx'.tr,
                                                  width: 150,
                                                ),
                                                gapW4,
                                                TableTitle(
                                                  text: 'pack'.tr,
                                                  width: 80,
                                                ),
                                                gapW4,
                                                TableTitle(
                                                  text: 'more_options'.tr,
                                                  width: 100,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            color: Colors.white,
                                            child: Column(
                                              children: List.generate(
                                                transferCont
                                                    .rowsInListViewInTransferOut
                                                    .length,
                                                (index) => ReusableItemRow(
                                                  index: index,
                                                  isMobile: true,
                                                  info:
                                                      transferCont
                                                          .rowsInListViewInTransferOut[index],
                                                ),
                                              ),
                                            ),
                                          ),
                                          gapH20,
                                          Row(
                                            children: [
                                              ReusableAddCard(
                                                text: 'item'.tr,
                                                onTap: () {
                                                  if (transferCont
                                                              .transferToIdInTransferOut ==
                                                          '' ||
                                                      transferCont
                                                              .transferFromIdInTransferOut ==
                                                          '') {
                                                    CommonWidgets.snackBar(
                                                      'error',
                                                      'you must choose warehouses first',
                                                    );
                                                  } else if (transferCont
                                                      .productsCodes
                                                      .isEmpty) {
                                                    CommonWidgets.snackBar(
                                                      'error',
                                                      'The warehouse is empty. You must fill the warehouse with products first',
                                                    );
                                                  } else {
                                                    addNewItem();
                                                  }
                                                },
                                              ),
                                              gapW32,
                                              ReusableAddCard(
                                                text: 'image'.tr,
                                                onTap: () {
                                                  // addNewImage();
                                                },
                                              ),
                                              gapW32,
                                              ReusableAddCard(
                                                text: 'note'.tr,
                                                onTap: () {
                                                  // addNewNote();
                                                },
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
                        )
                        : const SizedBox(),
                    gapH28,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ReusableButtonWithColor(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: 45,
                          isDisable:
                              transferCont.rowsInListViewInTransferOut.isEmpty,
                          onTapFunction: () async {
                            bool isThereItemsEmpty = false;
                            for (var map
                                in transferCont.rowsInListViewInTransferOut) {
                              if (map!["itemId"] == '' ||
                                  map!["transferredQty"] == '' ||
                                  map!["transferredQty"] == '0') {
                                setState(() {
                                  isThereItemsEmpty = true;
                                });
                                break;
                              }
                            }
                            if (transferController.transferToIdInTransferOut ==
                                transferController
                                    .transferFromIdInTransferOut) {
                              CommonWidgets.snackBar(
                                'error',
                                'The source warehouse  must not be the same as destination warehouse',
                              );
                            } else if (isThereItemsEmpty) {
                              CommonWidgets.snackBar(
                                'error',
                                'check all order lines and enter the required fields',
                              );
                            } else {
                              var res = await addTransferOut(
                                transferController.transferToIdInTransferOut,
                                transferController.transferFromIdInTransferOut,
                                refController.text,
                                '',
                                dateController.text,
                                transferController.rowsInListViewInTransferOut,
                              );
                              if (res['success'] == true) {
                                CommonWidgets.snackBar(
                                  'Success',
                                  res['message'],
                                );
                                transferController.getAllTransactionsFromBack();
                                homeController.selectedTab.value = 'transfers';
                              } else {
                                CommonWidgets.snackBar(
                                  'error',
                                  res['message'] ?? 'error'.tr,
                                );
                              }
                            }
                          },
                          btnText: 'submit'.tr,
                        ),
                      ],
                    ),
                    gapH40,
                  ],
                ),
              ),
            );
          },
        )
        : const CircularProgressIndicator();
  }

  Widget _buildTabChipItem(String name, int index) {
    return GetBuilder<TransferController>(
      builder: (transferCont) {
        return GestureDetector(
          onTap: () {
            transferCont.setSelectedTabIndex(index);
          },
          child: ClipPath(
            clipper: const ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(9),
                ),
              ),
            ),
            child: Container(
              width:
                  name.length * 10, // MediaQuery.of(context).size.width * 0.09,
              height: MediaQuery.of(context).size.height * 0.07,
              decoration: BoxDecoration(
                color:
                    transferCont.selectedTabIndex == index
                        ? Primary.p20
                        : Colors.white,
                border:
                    transferCont.selectedTabIndex == index
                        ? Border(
                          top: BorderSide(color: Primary.primary, width: 3),
                        )
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                    spreadRadius: 9,
                    blurRadius: 9,
                    // offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Primary.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int transferOutCounter = 0;
  addNewItem() {
    setState(() {
      transferOutCounter += 1;
    });
    // transferController
    //     .incrementListViewLengthInTransferOut(transferController.increment);
    var p = {
      'itemId': '',
      'itemCode': '',
      'mainDescription': '',
      'transferredQty': '',
      'transferredQtyPackageName': '',
      'qtyOnHandPackages': '0',
      'qtyOnHandPackagesInSource': '0',
      'productsPackages': <String>[],
    };
    transferController.addToRowsInListViewInTransferOut(p);
  }

  addNewImage() {
    // setState(() {
    // listViewLength = listViewLength + 100;
    transferController.incrementListViewLengthInTransferOut(100);

    // });
    Widget p = GetBuilder<TransferController>(
      builder: (cont) {
        return InkWell(
          onTap: () async {
            final image = await ImagePickerHelper.pickImage();
            setState(() {
              imageFile = image!;
              cont.changeBoolVarInTransferOut(true);
              cont.increaseImageSpaceInTransferOut(90);
              // listViewLength = listViewLength + (cont.imageSpaceHeightInTransferOut) + 10;
              transferController.incrementListViewLengthInTransferOut(
                (cont.imageSpaceHeightInTransferOut) + 10,
              );
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: DottedBorder(
              dashPattern: const [10, 10],
              color: Others.borderColor,
              radius: const Radius.circular(9),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.63,
                height: cont.imageSpaceHeightInTransferOut,
                child:
                    cont.imageAvailableInTransferOut
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.memory(
                              imageFile,
                              height: cont.imageSpaceHeightInTransferOut,
                            ),
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            gapW20,
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: Others.iconColor,
                              size: 32,
                            ),
                            gapW20,
                            Text(
                              'drag_drop_image'.tr,
                              style: TextStyle(
                                color: TypographyColor.textTable,
                              ),
                            ),
                            Text(
                              'browse'.tr,
                              style: TextStyle(color: Primary.primary),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        );
      },
    );
    int index = transferController.orderLinesInTransferOutList.length + 1;
    transferController.addToOrderLinesInTransferOutList('$index', p);
  }

  addNewNote() {
    // setState(() {
    //   listViewLength = listViewLength + increment;
    // });
    transferController.incrementListViewLengthInTransferOut(
      transferController.increment,
    );
    Widget p = Container(
      width: MediaQuery.of(context).size.width * 0.63,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ReusableTextField(
        textEditingController: TextEditingController(), //todo
        isPasswordField: false,
        hint: 'note'.tr,
        onChangedFunc: (val) {},
        validationFunc: (val) {},
      ),
    );
    int index = transferController.orderLinesInTransferOutList.length + 1;
    transferController.addToOrderLinesInTransferOutList('$index', p);
  }

  List<Step> getSteps() => [
    Step(
      title: const Text(''),
      content: Container(
        //page
      ),
      isActive: currentStep >= 0,
    ),
    Step(
      title: const Text(''),
      content: Container(),
      isActive: currentStep >= 1,
    ),
    Step(
      title: const Text(''),
      content: Container(),
      isActive: currentStep >= 2,
    ),
  ];
}
